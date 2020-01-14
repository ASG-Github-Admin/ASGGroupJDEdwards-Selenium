function AuthenticateJDEEnterpriseOneServerManager {

    [Cmdletbinding()]

    param (

        # Selenium web driver
        [Parameter(Mandatory)][OpenQA.Selenium.Remote.RemoteWebDriver] $Driver,

        # PowerShell credential
        [Parameter(Mandatory)][pscredential] $Credential
    )

    try {

        # Find the username web element on the page
        $Element = Find-SeElement -Driver $Driver -Id "j_username"
        
        # Element was not found
        if (-not $Element) {
            
            # Write an error record
            Write-Error -ErrorAction Stop -ErrorRecord (
                
                [System.Management.Automation.ErrorRecord]::new(

                    [System.Exception]::new("The username field cannot be found"),
                    "Selenium.WebElement.NotFound",
                    [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                    $null
                )
            )
        }

        # Enter in the username into the field
        Send-SeKeys -Element $Element -Keys $Credential.UserName

        # Find the password web element on the page
        $Element = Find-SeElement -Driver $Driver -Id "j_password"
        
        # Element was not found
        if (-not $Element) {
            
            # Write an error record
            Write-Error -ErrorAction Stop -ErrorRecord (
                
                [System.Management.Automation.ErrorRecord]::new(

                    [System.Exception]::new("The password field cannot be found"),
                    "Selenium.WebElement.NotFound",
                    [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                    $null
                )
            )
        }

        # Enter in the password into the field
        Send-SeKeys -Element $Element -Keys $Credential.GetNetworkCredential().Password

        # Send the enter key
        Send-SeKeys -Element $Element -Keys ([OpenQA.Selenium.Keys]::Enter)

        # Find the authentication error element on the page
        $AuthError = Find-SeElement -Driver $Driver -ClassName "error"

        # Element was found
        if ($AuthError) {
            
            # Write an error record
            Write-Error -ErrorAction Stop -ErrorRecord (
                
                [System.Management.Automation.ErrorRecord]::new(

                    [System.Exception]::new($AuthError.Text),
                    "JDEdwards.EnterpriseOneServerManager.AuthenticationFailed",
                    [System.Management.Automation.ErrorCategory]::AuthenticationError,
                    $AuthError
                )
            )
        }
    }
    catch { $PSCmdlet.ThrowTerminatingError($PSItem) }
}