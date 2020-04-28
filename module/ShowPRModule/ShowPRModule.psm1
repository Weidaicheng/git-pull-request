function Show-ShowHelp {
    Write-LogInfo "$($MyInvocation.MyCommand)"
    Write-Host (Get-DocText "show")
}

function Show-PullRequest {
    param (
        [string]$owner,
        [string]$repo,
        [int]$number
    )
    Write-LogInfo "$($MyInvocation.MyCommand) $owner $repo $number"

    $response = Invoke-RestMethod -Uri "$($Global:settings.Api.Url)/repos/$owner/$repo/pulls/$number" -SkipHttpErrorCheck -StatusCodeVariable statusCode
    $statusCode -eq "200" ? (Write-LogInfo "status code $statusCode") : (Write-LogError "status code $statusCode")
    
    if ($statusCode -eq "200") {
        # write title
        Write-Host $response.title
        Write-Host

        # write flow
        Write-Host "  $($response.base.label) <- $($response.head.label)"

        # write state
        Write-Host -NoNewline "  State: "

        if ($response.state -eq "open") {
            Write-Host -ForegroundColor $Global:settings.Global.OpenStateColor "open"
        }
        elseif ($response.state -eq "closed") {
            if ($response.merged) {
                Write-Host -NoNewline -ForegroundColor $Global:settings.Global.MergedStateColor "merged"
                Write-Host " by $($response.merged_by.login)"
            }
            else {
                Write-Host -ForegroundColor $Global:settings.Global.ClosedStateColor "closed"
            }
        }

        # write mergeable
        Write-Host -NoNewline "  Mergeable: "
        $mergeable = $null -eq $response.mergeable ? $false : $response.mergeable
        Write-Host -ForegroundColor $Global:settings.Global."Boolean${mergeable}Color" ($mergeable ? "✓" : "✗")

        # write commits
        Write-Host "  Commits: $($response.commits)"

        # write changed files
        Write-Host "  Changed files: $($response.changed_files)"

        # write body
        if ($response.body -ne "") {
            Write-Host
            Write-Host "Body: "
            Write-Host $response.body
        }
    }
    else {
        Write-LogError $response

        $errorMsg = "Http error, code: $statusCode"
        if ($statusCode -eq "404") {
            $errorMsg = "Pull request $number not found, please check your parameters."
        }

        throw $errorMsg
    }
}

Export-ModuleMember -Function Show-ShowHelp, Show-PullRequest