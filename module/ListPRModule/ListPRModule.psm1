function Show-ListHelp {
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
    
    $prs = Invoke-RestMethod -Uri "$($Global:settings.Api.Url)/repos/$owner/$repo/pulls?state=$state&direction=$direction"
    if ($null -ne $prs -and $prs -ne 0) {
        Write-Host "PR   State"
    }
    else {
        Write-Host "No pr request found."
    }
    foreach ($pr in $prs) {
        Write-Host -NoNewline "$($pr.number): "
        if ($pr.state -eq "open") {
            Write-Host -ForegroundColor $Global:settings.Global.OpenStateColor $pr.state
        }
        elseif ($pr.state -eq "closed") {
            if ($null -eq $pr.merged_at) {
                Write-Host -ForegroundColor $Global:settings.Global.ClosedStateColor $pr.state    
            }
            else {
                Write-Host -ForegroundColor $Global:settings.Global.MergedStateColor 'merged'
            }
        }
    }
}

Export-ModuleMember -Function Show-ListHelp, Show-PullRequests