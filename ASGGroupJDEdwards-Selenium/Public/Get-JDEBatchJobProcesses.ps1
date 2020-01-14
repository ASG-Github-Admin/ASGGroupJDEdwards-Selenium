function Get-JDEBatchJobProcesses {

    <#
    .SYNOPSIS
    Gets the JD Edwards batch job processes from a server.
    .DESCRIPTION
    Gets the running batch job processes from a specified server or set of servers.
    .EXAMPLE
    PS C:\> Get-JDEBatchJobProcess -Server BatchServer01
    Description
    -----------
    Gets the running batch job processes from the specified JD Edwards server.
    .PARAMETER Server
    The JD Edwards batch job server name.
    .INPUTS
    System.String
    .OUTPUTS
    pscustomobject
    #>
    
    [Cmdletbinding()]

    param (
    
        # Batch job server name
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string[]] $Server
    )

    process {

        try {

            VerifySession -Driver $ManagerSession # Verify that the web driver is still active

            $URL = [uri] $ManagerSession.Url # Parse the URL property from the web driver

            foreach ($Svr in $Server) {

                try {

                    # Create a base custom PowerShell object
                    $Out = [pscustomobject]@{
                    
                        ServerName  = $Svr
                        Status      = $null
                        Count       = $null
                        ProcessInfo = $null
                    }

                    # Build the batch job server URL
                    $SvrURL = "$($URL.Scheme)://$($URL.Authority)/manage/target?" +
                    "&hostName=$Svr" +
                    "&instanceName=$Svr`_EntServer" +
                    "&targetType=entserver" +
                    "&jdeHome=%2Fu10%2Fjdedwardsppack%2Fjde_home%2FSCFHA" +
                    "&action=processes"

                    VerifyURL -URL $SvrURL # Check that the web page is available

                    GoToWebPage -Driver $ManagerSession -Url $SvrURL # Go to the web page

                    # Check that the web page loaded
                    $Params = @{

                        Driver      = $ManagerSession
                        ElementName = "table"
                        ElementType = "ClassName"
                    }
                    CheckWebPageLoaded @Params

                    # Find the web element with the table containing the page size view drop down menu
                    $Element = Find-SeElement -Driver $ManagerSession -ClassName "table"

                    # Change the page size view to show all rows
                    ChangePageSizeView -WebElement $Element -ViewOptionName "All"

                    # Find the web element with the table containing the required process data
                    $Element = Find-SeElement -Driver $ManagerSession -Id "processTable"

                    # Get the rows containing running batch job processes
                    $Rows = Find-SeElement -Element $Element -TagName "tr" |
                    Where-Object -Property "Text" -Match " Runbatch \d+ "

                    # No rows found
                    if (-not $Rows) {
        
                        $Out.Status = "No processes found" # Update the status of the base object
                        $Out.Count = 0 # Set the running batch job count to zero on the base object
                        continue
                    }
                    else { $Out.Count = ($Rows | Measure-Object).Count } # Count the number of rows found

                    # Capture processes from each row
                    $Processes = foreach ($Row in $Rows) {

                        # Create an array from the text of each row
                        $Data = (Find-SeElement -Element $Row -TagName "td").Text
    
                        # Create a custom PowerShell object for each process
                        [pscustomobject]@{

                            ProcessName       = $Data[1]
                            ProcessType       = $Data[2]
                            ProcessId         = $Data[3]
                            ProcessStatus     = $Data[4]
                            JDELogFileSize    = $Data[5]
                            DebugLogSize      = $Data[6]
                            ConnectedUsers    = $Data[7]
                            TotalReqs         = $Data[8]
                            OutstandingReqs   = $Data[9]
                            MemoryMB          = $Data[10]
                            CPUPercentage     = $Data[11]
                            Threads           = $Data[12]
                            JDECaches         = $Data[13]
                            TotalOpenJDBTxns  = $Data[14]
                            ManualOpenJDBTxns = $Data[15]
                            DatabaseCxns      = $Data[16]
                        }
                    }

                    $Out.ProcessInfo = $Processes # Assign the array to the process info of the base object
                    $Out.Status = "Process(es) found" # Update the status of the base object
                }
                catch {
                
                    # Update the status of the base object with any errors encountered
                    $Out.Status = "Error: $($PSItem.Exception.Message)" 
                }
                finally { $Out } # Write out the custom PowerShell object
            }
        }
        catch { $PSCmdlet.ThrowTerminatingError($PSItem) }
    }
}