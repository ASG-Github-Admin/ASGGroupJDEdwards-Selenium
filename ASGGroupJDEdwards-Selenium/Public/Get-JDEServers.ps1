function Get-JDEServers {

    <#
    .SYNOPSIS
    Gets JD Edwards server information.
    .DESCRIPTION
    Gets the base information of the JD Edwards servers.
    .EXAMPLE
    PS C:\> Get-JDEServers
    Description
    -----------
    Gets the base information of all JD Edwards servers.
    .PARAMETER Type
    A filter to return JD Edwards of a certain type.
    .PARAMETER Group
    A filter to return JD Edwards of a certain group.
    .PARAMETER State
    A filter to return JD Edwards of a certain state.
    .INPUTS
    System.String
    .OUTPUTS
    pscustomobject
    #>
    
    [Cmdletbinding()]

    param (
    
        # JD Edwards server instance type
        [Parameter()]
        [ValidateSet("All", "Enterprise", "HTML", "BusinessServices", "ApplicationInterfaceServices")]
        [string] $Type = "All",
        
        # JD Edwards server instance group
        [Parameter()]
        [ValidateSet("All", "DV", "EOM", "PD", "PS", "PY", "TR", "UA")]
        [string] $Group = "All",
        
        # JD Edwards server instance state
        [Parameter()]
        [ValidateSet("All", "Running", "Stopped", "Starting", "Stopping", "Failed", "Undetermined")]
        [string] $State = "All"
    )

    process {

        try {
        
            VerifySession -Driver $ManagerSession # Verify that the web driver is still active

            $URL = [uri] $ManagerSession.Url # Parse the web driver URL property

            # Build the server home web page URL
            $SvrHomeURL = "$($URL.Scheme)://$($URL.Authority)/manage/home/servers"

            VerifyURL -URL $SvrHomeURL # Check that the web page is available

            GoToWebPage -Driver $ManagerSession -Url $SvrHomeURL # Go to the web page

            $TableIds = @("svrsByType0", "svrsByType1", "svrsByType2", "svrsByType3") # Table ID array
            
            foreach ($Id in $TableIds) {

                # Check that the table has loaded
                CheckWebPageLoaded -Driver $ManagerSession -ElementName $Id -ElementType Id
            }

            # Change the page view size to all on all drop down menus 
            Find-SeElement -Driver $ManagerSession -ClassName "navBar" |
            ChangePageSizeView -ViewOptionName "All"

            foreach ($Id in $TableIds) {

                # Create the instance type based upon the table identifier
                $InstanceType = `
                    if ($Id -like "*0") { "Enterprise" }
                elseif ($Id -like "*1") { "HTML" }
                elseif ($Id -like "*2") { "BusinessServices" }
                elseif ($Id -like "*3") { "ApplicationInterfaceServices" }

                # Skip depending upon the filter that is set
                if (($Type -ne "All") -and ($Type -ne $InstanceType)) { continue }

                # Find the web element containing the table
                $Element = Find-SeElement -Driver $ManagerSession -Id $Id

                # Get the rows containing the instance data
                $Rows = Find-SeElement -Element $Element -TagName "tr" | Select-Object -Skip 1

                foreach ($Row in $Rows) {

                    # Create an array from the text of each row
                    $Data = (Find-SeElement -Element $Row -TagName "td").Text

                    # Skip depending upon the filter that is set
                    if (($Group -ne "All") -and ($Data[1] -notlike "$Group*")) { continue }
                    if (($State -ne "All") -and ($Data[2] -ne $State)) { continue }
                    
                    # Create a custom PowerShell object for each instance
                    [pscustomobject]@{
                    
                        InstanceType = $InstanceType
                        InstanceName = $Data[0]
                        ServerGroup  = $Data[1]
                        State        = $Data[2]
                        UserActivity = $Data[3]
                    }
                }     
            }
        }
        catch { $PSCmdlet.ThrowTerminatingError($PSItem) }
    }
}