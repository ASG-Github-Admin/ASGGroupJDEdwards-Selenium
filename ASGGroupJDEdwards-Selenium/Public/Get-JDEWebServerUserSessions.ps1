function Get-JDEWebServerUserSessions {

    <#
    .SYNOPSIS
    Gets JD Edwards web server user sessions.
    .DESCRIPTION
    Gets the user sessions from a specified server or set of servers.
    .EXAMPLE
    PS C:\> Get-JDEWebServerUserSessions
    Description
    -----------
    Gets the user sessions from the specified JD Edwards web server.
    .PARAMETER InstanceName
    The JD Edwards web server instance name.
    .INPUTS
    System.String
    .OUTPUTS
    pscustomobject
    #>
    
    [Cmdletbinding()]

    param (

        # JD Edwards HTML instance name
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string[]] $InstanceName
    )

    process {

        try {

            VerifySession -Driver $ManagerSession # Verify that the web driver is still active

            $URL = [uri] $ManagerSession.Url # Parse the URL property from the web driver

            foreach ($Svr in $InstanceName) {

                try {
                    
                    # Create a base custom PowerShell object
                    $Out = [pscustomobject]@{
                    
                        InstanceName = $Svr
                        Status       = $null
                        Count        = $null
                        UserSessions = $null
                    }

                    # Build the web server instance URL
                    $InstanceURL = "$($URL.Scheme)://$($URL.Authority)/manage/target?action=sessions" +
                    "&instanceName=$Svr" +
                    "&targetType=webserver" +
                    "&jdeHome=%2Fu01%2Foracle%2Fjde_home%2FSCFHA"


                    VerifyURL -URL $InstanceURL # Check that the web page is available

                    GoToWebPage -Driver $ManagerSession -Url $InstanceURL # Go to the web page

                    # Check that the web page loaded
                    $Params = @{

                        Driver      = $ManagerSession
                        ElementName = "instance"
                        ElementType = "Id"
                    }
                    CheckWebPageLoaded @Params

                    # Get the user session count from the page
                    [int32] $Count = (Find-SeElement -Driver $ManagerSession -Id "instance").Text.Split("`n")[6]
                    
                    # No users
                    if ($Count -eq 0) {
                    
                        $Out.Status = "No sessions found" # Update the status of the base object
                        $Out.Count = 0 # Set the user session count to zero on the base object
                        continue
                    }
                    
                    # Check that the web page loaded
                    $Params = @{

                        Driver      = $ManagerSession
                        ElementName = "sessions"
                        ElementType = "Id"
                    }
                    CheckWebPageLoaded @Params

                    # Find the web element with the table containing the page size view drop down menu
                    $Element = Find-SeElement -Driver $ManagerSession -ClassName "table" |
                    Where-Object -Property Text -Like "*User Session*"

                    # Change the page size view to show all rows if the user count is above a certain number
                    if ($Count -gt 12) { ChangePageSizeView -WebElement $Element -ViewOptionName "All" }

                    # Find the web element within the table containing the required user session data
                    $Element = Find-SeElement -Driver $ManagerSession -Id "sessions"

                    # Get the rows containing user sessions
                    $Rows = Find-SeElement -Element $Element -TagName "tr" |
                    Where-Object -Property Text -NotMatch "    User Name"

                    # Count the nuber of rows found and update the user session count property on the base object
                    $Out.Count = ($Rows | Measure-Object).Count

                    # Capture user session data from each row
                    $Sessions = foreach ($Row in $Rows) {

                        # Create an array from the text of each row
                        $Data = (Find-SeElement -Element $Row -TagName "td").Text
    
                        # Create a custom PowerShell object for each user session
                        [pscustomobject]@{

                            Username           = $Data[1]
                            ClientIPAddress    = $Data[2]
                            Environment        = $Data[3]
                            DislayMode         = $Data[4]
                            LoginTime          = $Data[5]
                            IdleTime           = $Data[6]
                            RemoteEnvironments = $Data[7]
                            SessionId          = $Data[8]
                            OpenApplications   = if ($Data[9]) { $Data[9] } else { $null }
                        }
                    }

                    $Out.UserSessions = $Sessions # Assign the array to the user session property
                    $Out.Status = "Session(s) found" # Update the status property
                }
                catch {
                
                    # Update the status property with any errors encountered
                    $Out.Status = "Error: $($PSItem.Exception.Message)"
                }
                finally { $Out } # Write out the object
            }
        }
        catch { $PSCmdlet.ThrowTerminatingError($PSItem) }
    }
}