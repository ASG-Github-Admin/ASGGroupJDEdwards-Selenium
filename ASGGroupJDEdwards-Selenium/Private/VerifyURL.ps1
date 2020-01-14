function VerifyURL {

    [Cmdletbinding()]

    param ([Parameter(Mandatory)][string] $URL) # Web page URL
        
    $WebReq = Invoke-WebRequest -Uri $URL # Invoke web request

    # Response not ok
    if ($WebReq.StatusCode -ne 200) {
    
        # Write an error record
        Write-Error -ErrorAction Stop -ErrorRecord (
                
            [System.Management.Automation.ErrorRecord]::new(

                [System.Exception]::new("'$URL' did not respond with a status code of 200"),
                "WebRequest.OKResponseNotReceived",
                [System.Management.Automation.ErrorCategory]::InvalidResult,
                $WebReq
            )
        )
    }
}