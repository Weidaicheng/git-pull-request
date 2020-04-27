function Show-MergeHelp {
    Write-Host (Get-DocText "merge")
}

function Merge-PullRequest {
    param (
        [string]$owner,
        [string]$repo,
        [int]$number
    )

    try {
        if ($Global:settings.Global.Token -eq "") {
            throw "Token not set, please use setting command to set."
        }

        $headers = @{
            Authorization = "token $($Global:settings.Global.Token)"
        }
        $response = Invoke-RestMethod -Uri "$($Global:settings.Api.Url)/repos/$owner/$repo/pulls/$number/merge" -Method "Put" -ContentType "application/json" -Headers $headers -SkipHttpErrorCheck -StatusCodeVariable statusCode
        
        if ($statusCode -eq '200') {
            return
        }
        elseif ($statusCode -eq '404') {
            throw "Pull request $number doesn't exist, please check the parameters."
        }
        elseif ($statusCode -eq '405') {
            throw "Pull Request is not mergeable."
        }
        elseif ($statusCode -eq '409') {
            throw "Head branch was modified. Review and try the merge again."
        }
        else {
            throw "Pull request $number re-open failed."
        }
    }
    catch {
        throw $_.Exception.Message
    }
}

Export-ModuleMember -Function Show-MergeHelp, Merge-PullRequest