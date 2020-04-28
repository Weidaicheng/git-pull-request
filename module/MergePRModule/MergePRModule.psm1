function Show-MergeHelp {
    Write-LogInfo "$($MyInvocation.MyCommand)"
    Write-Host (Get-DocText "merge")
}

function Merge-PullRequest {
    param (
        [string]$owner,
        [string]$repo,
        [int]$number
    )
    Write-LogInfo "$($MyInvocation.MyCommand) $owner $repo $number"

    if ($Global:settings.Global.Token -eq "") {
        throw "Token not set, please use setting command to set."
    }

    $headers = @{
        Authorization = "token $($Global:settings.Global.Token)"
    }
    $response = Invoke-RestMethod -Uri "$($Global:settings.Api.Url)/repos/$owner/$repo/pulls/$number/merge" -Method "Put" -ContentType "application/json" -Headers $headers -SkipHttpErrorCheck -StatusCodeVariable statusCode
    $statusCode -eq "200" ? (Write-LogInfo "status code $statusCode") : (Write-LogError "status code $statusCode")
        
    if ($statusCode -eq '200') {
        return
    }
    else {
        Write-LogError $response

        $errorMsg = "Pull request $number merge failed."
        if ($statusCode -eq "404") {
            $errorMsg = "Pull request $number doesn't exist, please check the parameters."
        }
        elseif ($statusCode -eq "405") {
            $errorMsg = "Pull Request is not mergeable."
        }
        elseif ($statusCode -eq "409") {
            $errorMsg = "Head branch was modified. Review and try the merge again."
        }

        throw $errorMsg
    }
}

Export-ModuleMember -Function Show-MergeHelp, Merge-PullRequest