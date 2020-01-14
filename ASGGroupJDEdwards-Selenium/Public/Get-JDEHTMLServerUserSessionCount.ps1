function Get-JDEHTMLServerUserSessionCount {

    <#
    .SYNOPSIS
    Gets the JD Edwards HTML server user session count.
    .DESCRIPTION
    Queries the user session count for all JD Edwards HTML servers.
    .EXAMPLE
    PS C:\> Get-JDEHTMLServerUserSessionCount
    Description
    -----------
    Gets the user sessions count for all JD Edwards HTML servers.
    .EXAMPLE
    PS C:\> Get-JDEHTMLServerUserSessionCount -UserCountFilter 25
    Description
    -----------
    Gets the JD Edwards HTML servers with a user count over 25.
    .PARAMETER UserCountFilter
    Filters out JD Edwards HTML servers with a user count over a certain number, the default is '-1' which will
    return all.
    .INPUTS
    System.Int32
    .OUTPUTS
    pscustomobject
    #>

    [Cmdletbinding()]

    param (
    
        # User count filter
        [Parameter()][int32]$UserCountFilter = -1
    )

    process {

        try {

            VerifySession -Driver $ManagerSession # Verify that the web driver is still active

            $URL = [uri] $ManagerSession.Url # Parse the URL property from the web driver
            $SvrHomeURL = "$($URL.Scheme)://$($URL.Authority)/manage/home/servers" # Build the server list URL

            VerifyURL -URL $SvrHomeURL # Check that the web page is available

            GoToWebPage -Driver $ManagerSession -Url $SvrHomeURL # Go to the web page

            # Check that the web page loaded
            CheckWebPageLoaded -Driver $ManagerSession -ElementName "svrsByType1" -ElementType Id

            # Find the web element containing HTML instances
            $Element = Find-SeElement -Driver $ManagerSession -ClassName "h2content" |
            Where-Object -Property Text -Like "*HTML*"

            ChangePageSizeView -WebElement $Element -ViewOptionName "All" # Change the page view size to all

            # Check that the web page is still showing the data we need
            CheckWebPageLoaded -Driver $ManagerSession -ElementName "svrsByType1" -ElementType Id

            $Element = Find-SeElement -Driver $ManagerSession -Id "svrsByType1" # Get the HTML instance table

            # Get the rows containing HTML instance data
            $Rows = Find-SeElement -Element $Element -TagName "tr" | Where-Object -Property Text -Like "*HTML*"

            foreach ($Row in $Rows) {

                $Text = $Row.Text.Split(" ") # Split the text from each row into their components
                $InstanceName = $Text[0] # HTML WebLogic instance name
                $UserCount = if ($Text[-1] -match "None.") { [int32] 0 } else { [int32] $Text[-1] } # User count

                # Output custom PowerShell object if user count is greater than the filter set
                if ($UserCount -gt $UserCountFilter) {
                
                    [pscustomobject]@{ InstanceName = $InstanceName; UserCount = $UserCount }
                }
            }
        }
        catch { $PSCmdlet.ThrowTerminatingError($PSItem) }
    }
}