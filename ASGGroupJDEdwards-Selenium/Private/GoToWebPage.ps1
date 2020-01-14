function GoToWebPage {

    [Cmdletbinding()]

    param (
    
        # Selenium web driver
        [Parameter(Mandatory)][OpenQA.Selenium.Remote.RemoteWebDriver] $Driver,

        # Web page URL
        [Parameter(Mandatory)][string] $URL
    )

    # Create an error record object
    $ErrRec = [System.Management.Automation.ErrorRecord]::new(

        [System.Exception]::new("The web page '$URL' took too long to load"),
        "Selenium.WebDriver.OperationTimedOut",
        [System.Management.Automation.ErrorCategory]::OperationTimeout,
        $null
    )

    try { Enter-SeUrl -Driver $Driver -Url $URL } # Go to the URL using the web driver
    catch [System.Management.Automation.MethodInvocationException] {

        # Base exception is a 'web exception' exception
        if ($PSItem.Exception.GetBaseException() -is [System.Net.WebException]) {
        
            $PSCmdlet.ThrowTerminatingError($ErrRec) # Throw the custom exception in place of the one caught
        }
        else { $PSCmdlet.ThrowTerminatingError($PSItem) } # Throw the original exception
    }
    catch { $PSCmdlet.ThrowTerminatingError($PSItem) }
}