function ChangePageSizeView {

    [Cmdletbinding()]

    param (

        # Drop down menu web element
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [OpenQA.Selenium.Remote.RemoteWebElement[]] $WebElement,

        # Drop down menu view option name
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $ViewOptionName
    )

    process {

        foreach ($WebElmnt in $WebElement) { 

            try {

                # Find a select tag (drop down menu) within the web element
                $Element = Find-SeElement -Element $WebElmnt -TagName "select"
            
                # Element not found
                if (-not $Element) {
            
                    # Write an error record
                    Write-Error -ErrorAction Stop -ErrorRecord (
                
                        [System.Management.Automation.ErrorRecord]::new(

                            [System.Exception]::new("The 'page size' drop down menu cannot be found"),
                            "Selenium.WebElement.NotFound",
                            [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                            $WebElmnt
                        )
                    )
                }
            
                # Find the specified option within the drop down menu
                $View = Find-SeElement -Element $Element -TagName "option" |
                Where-Object -Property "Text" -EQ $ViewOptionName
            
                # View element not found
                if (-not $View) {
                
                    # Write an error record
                    Write-Error -ErrorAction Stop -ErrorRecord (
                
                        [System.Management.Automation.ErrorRecord]::new(

                            [System.Exception]::new("'$ViewOptionName' was not found"),
                            "Selenium.WebElement.NotFound",
                            [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                            $Element
                        )
                    )
                }

                if ($View.Selected -eq $true) { return } # Return if the required view option is already set

                Invoke-SeClick -Element $View # Select view option

                $Element = Find-SeElement -Element $WebElmnt -TagName "select" # Check drop down menu still exists
            
                # Element not found    
                if (-not $Element) {
            
                    # Write an error record
                    Write-Error -ErrorAction Stop -ErrorRecord (
                
                        [System.Management.Automation.ErrorRecord]::new(

                            [System.Exception]::new("The 'page size' drop down menu cannot be found"),
                            "Selenium.WebElement.NotFound",
                            [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                            $WebElmnt
                        )
                    )
                }
            
                # Find the specified option within the drop down menu
                $View = Find-SeElement -Element $Element -TagName "option" |
                Where-Object -Property "Text" -EQ $ViewOptionName
            
                # View option is not selected
                if ($View.Selected -ne $true) {

                    # Write an error record
                    Write-Error -ErrorAction Stop -ErrorRecord (
                
                        [System.Management.Automation.ErrorRecord]::new(

                            [System.Exception]::new("'$ViewOptionName' is not the active option"),
                            "Selenium.WebElement.SelectionInvalid",
                            [System.Management.Automation.ErrorCategory]::InvalidResult,
                            $View
                        )
                    )
                }
            }
            catch { $PSCmdlet.ThrowTerminatingError($PSItem) }
        }
    }
}