function Connect-JDEEnterpriseOneServerManager {

    <#
    .SYNOPSIS
    Connects to the JD Edwards EnterpriseOne Server Manager.
    .DESCRIPTION
    Creates a web session with the JD Edwards EnterpriseOne Server Manager using a Selenium web driver and
    authenticates with the credential provided.
    .EXAMPLE
    PS C:\> Connect-JDEEnterpriseOneServerManager -URL http://ServerManager:1234/manage/logon
    Description
    -----------
    Authenticates with the JD Edwards EnterpriseOne Server Manager on the specifed URL and creates a session.
    .PARAMETER URL
    The URL for the JD Edwards EnterpriseOne Server Manager, preferably the logon web page.
    .PARAMETER Credential
    The username and password for the JD Edwards EnterpriseOne Server Manager.
    .INPUTS
    System.String, pscredential
    .OUTPUTS
    None
    #>
    
    [Cmdletbinding()]

    param (
    
        # JD Edwards EnterpriseOne Server Manager logon URL
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $URL,

        # JD Edwards EnterpriseOne Server Manager credential
        [Parameter(Mandatory)][pscredential] $Credential
    )

    process {

        try {
    
            VerifyURL -URL $URL # Check that the web page is available
            
            $Drvr = Start-SeFirefox -SuppressLogging -Headless # Start the web driver with logging supressed
        
            # Web driver not running
            if (-not $Drvr) {
            
                # Write an error record
                Write-Error -ErrorAction Stop -ErrorRecord (
                
                    [System.Management.Automation.ErrorRecord]::new(

                        [System.Exception]::new("The Selenium web driver failed to start"),
                        "Selenium.FirefoxWebDriver.FailedStart",
                        [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                        $null
                    )
                )
            }

            GoToWebPage -Driver $Drvr -Url $URL # Go to the web page

            # Check that the web page loaded
            $Params = @{
            
                Driver         = $Drvr
                ElementName    = "loginlabel"
                ElementType    = "ClassName"
                TextValidation = "Sign In"
            }
            CheckWebPageLoaded @Params

            # Authenticate with the JD Edwards EnterpriseOne Server Manager with the provided credential
            AuthenticateJDEEnterpriseOneServerManager -Driver $Drvr -Credential $Credential
            
            $Global:ManagerSession = $Drvr # Create a global scope variable for the web driber
        }
        catch { $PSCmdlet.ThrowTerminatingError($PSItem) }
        finally {
        
            # Dispose of the web driver if process incomplete
            if ((-not $ManagerSession) -and ($Drvr)) { $Drvr.Dispose() }
        }
    }
}