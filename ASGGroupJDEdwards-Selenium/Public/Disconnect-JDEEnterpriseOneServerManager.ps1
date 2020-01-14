function Disconnect-JDEEnterpriseOneServerManager {

    <#
    .SYNOPSIS
    Disconnects from the JD Edwards EnterpriseOne Server Manager.
    .DESCRIPTION
    Logs off the JD Edwards EnterpriseOne Server Manager within the existing session, and closes the Selenium 
    web driver.
    .EXAMPLE
    PS C:\> Disconnect-JDEEnterpriseOneServerManager
    Description
    -----------
    Disconnects from the JD Edwards EnterpriseOne Server Manager on an existing session.
    .INPUTS
    None
    .OUTPUTS
    None
    #>
    
    [Cmdletbinding()]

    param ()

    try {

        VerifySession -Driver $ManagerSession # Verify that the web driver is still active

        $URL = [uri]$ManagerSession.Url # Parse the URL property from the web driver
        $LogoutURL = "$($URL.Scheme)://$($URL.Authority)/manage/logon?action=logout" # Build the logout URL

        VerifyURL -URL $LogoutURL # Check the web page is available

        GoToWebPage -Driver $ManagerSession -Url $LogoutURL # Go to the web page

        # Check that the web page loaded
        $Params = @{
            
            Driver         = $ManagerSession
            ElementName    = "loginlabel"
            ElementType    = "ClassName"
            TextValidation = "Sign In"
            Silent         = $true
        }
        $PageChk = CheckWebPageLoaded @Params
            
        # Web page did not load
        if ($PageChk -ne $true) {
            
            Write-Warning -Message "The sign out operation did not complete as expected"
        }
    }
    catch { $PSCmdlet.ThrowTerminatingError($PSItem) }
    finally { 
        
        # Web driver exists
        if ($ManagerSession) {
            
            $ManagerSession.Dispose() # Dispose of the web driver
            Remove-Variable -Name ManagerSession -Force -Scope Global # Force remove the web driver variable
        }
    }
}