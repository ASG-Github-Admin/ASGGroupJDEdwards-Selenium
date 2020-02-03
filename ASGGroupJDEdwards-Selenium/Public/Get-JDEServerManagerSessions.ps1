function Get-JDEServerManagerSessions {

    <#
    .SYNOPSIS
    Gets the JD Edwards Server Manager Sessions.
    .DESCRIPTION
    Queries the manager sessions for the JD Edwards EnterpriseOne Server Manager.
    .EXAMPLE
    PS C:\> Get-JDEServerManagerSessions -ManagerServerName "Server01"
    Description
    -----------
    Gets the server manager sessions the JD Edwards EnterpriseOne Server Manager server 'Server01'.
    .PARAMETER ManagerServerName
    The name of the manager server.
    .PARAMETER Username
    Filters out manager sessions by username, the default is '*' which will return all.
    .PARAMETER RemoteHost
    Filters out manager sessions by the remote host name, the default is '*' which will return all.
    .PARAMETER LoginTime
    Filters out manager sessions by the login time, the default will return all.
    .PARAMETER IdleSeconds
    Filters out manager sessions by the idle time (seconds), the default is '-1' which will return all.
    .INPUTS
    System.String, System.DateTime, System.Int32
    .OUTPUTS
    pscustomobject
    #>

    [Cmdletbinding()]

    param (
    
        # Manager server name
        [Parameter(Mandatory)][string]$ManagerServerName,
        
        # Username filter
        [Parameter()][string]$Username = "*",

        # Remote host filter
        [Parameter()][string]$RemoteHost = "*",

        # Logon time filter
        [Parameter()][datetime]$LogonTime = (Get-Date).AddYears(-50),

        # Idle time filter
        [Parameter()][int32]$IdleSeconds = -1
    )

    process {

        try {

            VerifySession -Driver $ManagerSession # Verify that the web driver is still active

            $URL = [uri] $ManagerSession.Url # Parse the URL property from the web driver
            
            # Build the manager server URL
            "$($URL.Scheme)://$($URL.Authority)/manage/target" +
            "?action=sessions" +
            "&hostName=$ManagerServerName" +
            "&instanceName=home" +
            "&targetType=mgmtconsole" +
            "&jdeHome=D%3A%5Cjde_home%5CSCFMC"

            VerifyURL -URL $SvrHomeURL # Check that the web page is available

            GoToWebPage -Driver $ManagerSession -Url $SvrHomeURL # Go to the web page

            # Check that the web page loaded
            CheckWebPageLoaded -Driver $ManagerSession -ElementName "userSessionTable" -ElementType Id

            # Find the web element containing server manager sessions
            $Element = Find-SeElement -Driver $ManagerSession -ClassName "table"

            ChangePageSizeView -WebElement $Element -ViewOptionName "All" # Change the page view size to all

            # Check that the web page is still showing the data we need
            CheckWebPageLoaded -Driver $ManagerSession -ElementName "userSessionTable" -ElementType Id

            $Element = Find-SeElement -Driver $ManagerSession -Id "userSessionTable" # Get the session table

            # Get the rows containing session data
            $Rows = Find-SeElement -Element $Element -TagName "tr" | Select-Object -Skip 1

            foreach ($Row in $Rows) {

                # Get the data from each row
                $Data = Find-SeElement -Element $Row -TagName "td" | Select-Object -Skip 1

                # Output a custom PowerShell object according to the filter that is set
                if (
                    ([string] $Data[0].Text -like $Username) -and
                    ([string] $Data[1].Text -like $RemoteHost) -and
                    ([datetime] $Data[2].Text -gt $LogonTime) -and
                    ([int32] $Data[3].Text -gt $RemoteHost)
                ) {
                
                    [pscustomobject]@{
                        
                        Username    = [string] $Data[0].Text
                        RemoteHost  = [string] $Data[1].Text
                        LogonTime   = [datetime] $Data[2].Text
                        IdleSeconds = [int32] $Data[3].Text
                    }
                }
            }
        }
        catch { $PSCmdlet.ThrowTerminatingError($PSItem) }
    }
}