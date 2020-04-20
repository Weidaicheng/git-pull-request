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
        [string]$state
    )
    
    $prs = Invoke-RestMethod -Uri "$($Global:settings.Api.Url)/repos/$owner/$repo/pulls?state=$state"
    if ($null -ne $prs -and $prs -ne 0) {
        Write-Host "PR   State"
    }
    else {
        Write-Host "No pr request found."
    }
    foreach ($pr in $prs) {
        Write-Host -NoNewline "$($pr.number): "
        if ($pr.state -eq "open") {
            Write-Host -ForegroundColor Green $pr.state
        }
        elseif ($pr.state -eq "closed") {
            Write-Host -ForegroundColor Red $pr.state
        }
    }
}

Export-ModuleMember -Function Show-ListHelp, Show-PullRequests