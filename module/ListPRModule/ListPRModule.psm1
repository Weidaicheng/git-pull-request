function Show-ListHelp {
    Write-LogInfo "$($MyInvocation.MyCommand)"

    # get help text from doc
    # TODO: abstract get doc function
    $helpText = (Get-Content -Path "$Global:root/doc/usage-list.txt") -Join "`n"
    Write-Host $helpText    
}

function Show-PullRequests {
    param (
        [string]$owner,
        [string]$repo,
        [string]$state,
        [string]$direction
    )
    Write-LogInfo "$($MyInvocation.MyCommand) $owner $repo $state $direction"
    
    $response = Invoke-RestMethod -Uri "$($Global:settings.Api.Url)/repos/$owner/$repo/pulls?state=$state&direction=$direction" -SkipHttpErrorCheck -StatusCodeVariable statusCode
    $statusCode -eq "200" ? (Write-LogInfo "status code $statusCode") : (Write-LogError "status code $statusCode")

    if ($statusCode -eq "200") {
        if (-not ($null -ne $response -and $response -ne 0)) {
            Write-LogInfo "No pull request found."
            Write-Host "No pull request found."
            return
        }
    
        $prNumberMaxLength = ($response | Measure-Object -Property number -Maximum).Maximum.ToString().Length
        $prNumberMaxLength = $prNumberMaxLength -lt 2 ? 2 : $prNumberMaxLength
    
        # write header
        $headerString = ""
        for ($i = 0; $i -lt $prNumberMaxLength - 2; $i++) {
            $headerString += " "
        }
        $headerString += "PR  "
        $headerString += "State   "
        $headerString += "Title"
        Write-Host $headerString
        
        foreach ($pr in $response) {
            # write pr number
            for ($i = 0; $i -lt $prNumberMaxLength - $pr.number.ToString().Length; $i++) {
                Write-Host -NoNewline " "
            }
            Write-Host -NoNewline "$($pr.number)  "
    
            # write pr state
            if ($pr.state -eq "open") {
                Write-Host -NoNewline -ForegroundColor $Global:settings.Global.OpenStateColor "open   "
            }
            elseif ($pr.state -eq "closed") {
                if ($null -eq $pr.merged_at) {
                    Write-Host -NoNewline -ForegroundColor $Global:settings.Global.ClosedStateColor "closed "    
                }
                else {
                    Write-Host -NoNewline -ForegroundColor $Global:settings.Global.MergedStateColor 'merged '
                }
            }
    
            # write pr title
            Write-Host -NoNewline " $($pr.title)"
    
            # write new line
            Write-Host
        }
    }
    else {
        Write-LogError $response

        $errorMsg = "Http error, code: $statusCode"

        throw $errorMsg
    }
}

Export-ModuleMember -Function Show-ListHelp, Show-PullRequests