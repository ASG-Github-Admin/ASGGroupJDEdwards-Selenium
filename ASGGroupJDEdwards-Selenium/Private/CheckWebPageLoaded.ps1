function CheckWebPageLoaded {

    [Cmdletbinding()]

    param (

        # Selenium web driver
        [Parameter(Mandatory)][OpenQA.Selenium.Remote.RemoteWebDriver] $Driver,

        # Web element name
        [Parameter(Mandatory)][string] $ElementName,

        # Web element type
        [Parameter(Mandatory)]
        [ValidateSet("Name", "Id", "ClassName", "LinkText", "PartialLinkText", "TagName")]
        [string] $ElementType,

        # Wait for web element to load
        [Parameter()][bool] $Wait = $true,

        # Web element load timeout
        [Parameter()][int32] $Timeout = 60,

        # Text property validation
        [Parameter()][string] $TextValidation,

        # Switch for output to generate boolean instead of exceptions
        [Parameter()][switch] $Silent
    )

    # Create an error record object
    $ErrRec = [System.Management.Automation.ErrorRecord]::new(

        [System.Exception]::new("The web page failed to load"),
        "Selenium.WebElement.PageValidationFailure",
        [System.Management.Automation.ErrorCategory]::ResourceUnavailable,
        $null
    )

    try {        

        # Find a web element on the page
        $Params = @{
    
            Driver                         = $Driver
            $PSBoundParameters.ElementType = $ElementName
            Wait                           = $Wait
            Timeout                        = $Timeout
        }
        $Element = Find-SeElement @Params

        # Element was not found
        if (-not $Element) {
        
            if ($Silent) { return $false } # Return false if silent is enabled
            else { Write-Error -ErrorAction Stop -ErrorRecord $ErrRec } # Write an error record
        }
        
        # Text validation parameter set
        if ($TextValidation) {
        
            if ($Element.Text -eq $TextValidation) { if ($Silent) { return $true } } # Return true if exact match
            else {
            
                if ($Silent) { return $false } # Return false if silent is enabled
                else { Write-Error -ErrorAction Stop -ErrorRecord $ErrRec } # Write an error record
            }
        }
    }
    catch [System.Management.Automation.MethodInvocationException] {

        # Base exception is a 'no such element' exception
        if ($PSItem.Exception.GetBaseException() -is [OpenQA.Selenium.NoSuchElementException]) {
        
            if ($Silent) { return $false } # Return false if silent is enabled
            else { $PSCmdlet.ThrowTerminatingError($ErrRec) } # Throw the custom exception instead
        }
        else { $PSCmdlet.ThrowTerminatingError($PSItem) } # Throw the original exception
    }
    catch { $PSCmdlet.ThrowTerminatingError($PSItem) }
}