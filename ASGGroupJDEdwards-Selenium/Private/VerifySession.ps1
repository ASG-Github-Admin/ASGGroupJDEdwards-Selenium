function VerifySession {

    [Cmdletbinding()]

    param ([Parameter(Mandatory)][OpenQA.Selenium.Remote.RemoteWebDriver] $Driver) # Selenium web driver

    # Check that the URL property exists on the web driver
    if (-not $Driver.Url) {
            
        Write-Error -ErrorAction Stop -ErrorRecord (
                
            [System.Management.Automation.ErrorRecord]::new(

                [System.Exception]::new("The URL property was not found"),
                "Selenium.WebDriver.PropertyNotFound",
                [System.Management.Automation.ErrorCategory]::InvalidData,
                $Driver
            )
        )
    }
}