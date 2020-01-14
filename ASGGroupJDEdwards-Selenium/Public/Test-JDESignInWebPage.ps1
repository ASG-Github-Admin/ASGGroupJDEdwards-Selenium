function Test-JDESignInWebPage {

    <#
    .SYNOPSIS
    Tests that the JD Edwards sign in web page is available.
    .DESCRIPTION
    The Test-SignInWebPage function uses the Selenium PowerShell module to test that the JD Edwards user sign in
    web page is available, and loads as expected. An output of the test and its results is provided.
    .EXAMPLE
    PS C:\> Test-JDESignInWebPage -Server poljws01 -Port (@(9105) + @(9110..9119))
    Description
    -----------
    This tests the JD Edwards user sign in web page on web server 'poljws01' on port 9105, and 9110 through to
    9119.
    .PARAMETER Server
    Specifies the name Domain Name System (DNS name) of the web server that hosts the JD Edwards user sign in web
    page.
    .PARAMETER Port
    Specifies the TCP/IP port number that the JD Edwards user sign in web page resides on.
    .INPUTS
    System.String for the server name, and System.Int32 for the TCP/IP port number.
    .OUTPUTS
    pscustomobject
    #>

    [CmdLetBinding()]
    param (
        
        # Web server name
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][Alias('WebServer', 'ServerName')][string] $Server,

        # Web server port
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][Alias('WebServerPort')][int32[]] $Port
    )

    begin {

        # Start the Selenium web driver
        Write-Verbose -Message "Starting the Selenium web driver"
        $Drvr = Start-SeFirefox -Headless -SuppressLogging
        if (-not $Drvr) { throw "The Selenium web driver failed to start" }
        Write-Debug -Message "Selenium Web driver information:`n$(Out-String -InputObject $Drvr)"
    }

    process {

        foreach ($TCPIPPort in $Port) {

            try {

                # Create output object
                Write-Verbose -Message "Creating the output object"
                $Out = [pscustomobject]@{ ServerName = $Server; Port = $TCPIPPort; URL = $null; Status = $null }
                Write-Debug -Message "Object information:`n$(Out-String -InputObject $Out)"

                # Build the URL
                Write-Verbose -Message "Building the URL"
                $URL = "http://$Server`:$TCPIPPort/jde/E1Menu.maf"
                Write-Debug -Message "Sign in URL: $URL"
                $Out.URL = $URL

                # Check that the page is available
                Write-Verbose -Message "Checking that the page is available"
                $WebReq = Invoke-WebRequest -Uri $URL
                if ($WebReq.StatusCode -ne 200) {
            
                    $Out.Status = "Error: The page did not respond with a status code of 200"
                    continue
                }
                Write-Debug -Message "Web request information:`n$(Out-String -InputObject $WebReq)"

                # Navigate to the URL
                Write-Verbose -Message "Navigating to the URL"
                Enter-SeURL -Driver $Drvr -URL $URL

                # Check that the sign in page has loaded
                Write-Verbose -Message "Checking that the sign in page has loaded"
                $Element = Find-SeElement -Driver $Drvr -ClassName "loginlabel"
                if (-not $Element) {

                    $Out.Status = "Error: The sign in page failed to load"
                    continue
                }
                elseif ($Element.Text -ne "Sign In") {

                    $Out.Status = "Error: The sign in page did not load as expected"
                    continue
                }
                Write-Debug -Message "Element information:`n$(Out-String -InputObject $Element)"
            }
            catch { $Out.Status = "Error: $($PSItem.Exception.Message)" } # Catch any unexpected errors
            finally {

                # Write out object
                Write-Verbose -Message "Writing out object"
                if ($null -eq $Out.Status) { $Out.Status = "Successful" }
                Write-Debug -Message "Object information:`n$(Out-String -InputObject $Out)"
                Write-Output -InputObject $Out
            }
        }        
    }

    end {

        # Stop the web driver (if started)
        if ($Drvr) {

            Write-Verbose -Message "Stopping the Selenium web driver"
            Stop-SeDriver -Driver $Drvr
        }
    }
}