function Test-JDEMobileApprovalsSignInWebPage {

    <#
    .SYNOPSIS
    Tests that the JD Edwards Mobile Approvals sign in web page is available.
    .DESCRIPTION
    The Test-JDEMobileApprovalsSignInWebPage function uses the Selenium PowerShell module to test that the JD
    Edwards Mobile Approvals sign in web page is available, and loads as expected.
    .EXAMPLE
    PS C:\> Test-JDEMobileApprovalsSignInWebPage -URL http://WebServer:1234/Approvals
    Description
    -----------
    This tests the JD Edwards Mobile Approvals sign in web page on the URL 'http://WebServer:1234/Approvals'.
    .PARAMETER URL
    Specifies the URL of the JD Edwards Mobile Approvals sign in web page.
    .INPUTS
    System.String.
    .OUTPUTS
    None
    #>

    [CmdLetBinding()]
    param (
        
        # Web server URL
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $URL
    )

    try {

        VerifyURL -URL $URL # Check that the web page is available

        $Driver = Start-SeFirefox -Headless -SuppressLogging # Start the web driver with logging supressed

        # Web driver not running
        if (-not $Driver) {
        
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

        GoToWebPage -Driver $Driver -URL $URL # Go to the web page

        # Check that the username field is present
        if (-not (Find-SeElement -Driver $Driver -Id "username")) {

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

        # Check that the password field is present
        if (-not (Find-SeElement -Driver $Driver -Id "password")) {

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

        # Check that the login button is present
        if (-not (Find-SeElement -Driver $Driver -Id "login-button")) {

            # Write an error record
            Write-Error -ErrorAction Stop -ErrorRecord (
                
                [System.Management.Automation.ErrorRecord]::new(

                    [System.Exception]::new("The login button cannot be found"),
                    "Selenium.WebElement.NotFound",
                    [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                    $null
                )
            )
        }
    }
    catch { $PSCmdlet.ThrowTerminatingError($PSItem) }
    finally { if ($Driver) { Stop-SeDriver -Driver $Driver } } # Dispose of the web driver
}