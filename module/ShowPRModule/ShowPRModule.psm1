function Show-ShowHelp {
    # get help text from doc
    # TODO: abstract get doc function
    $helpText = (Get-Content -Path "$Global:root/doc/usage-show.txt") -Join "`n"
    Write-Host $helpText    
}

function Show-PullRequest {
    param (
        [string]$owner,
        [string]$repo,
        [int]$number
    )

    try {
        $response = Invoke-RestMethod -Uri "$($Global:settings.Api.Url)/repos/$owner/$repo/pulls/$number" -SkipHttpErrorCheck -StatusCodeVariable statusCode

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
        elseif ($statusCode -eq "404") {
            throw "Pull request $number not found, please check your parameters."
        }
        else {
            throw "Http error, code: $statusCode"
        }
    }
    catch {
        throw $_.Exception.Message
    }
}

Export-ModuleMember -Function Show-ShowHelp, Show-PullRequest