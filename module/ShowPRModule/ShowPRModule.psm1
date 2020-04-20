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
        $pr = Invoke-RestMethod -Uri "$($Global:settings.Api.Url)/repos/$owner/$repo/pulls/$number"

        try {
            if ($pr.state -eq "open") {
                Write-Host -ForegroundColor Green "status: $($pr.state)"
            }
            elseif ($pr.state -eq "closed") {
                Write-Host -ForegroundColor Red "status: $($pr.state)"
            }
            $diffTxt = Invoke-RestMethod -Uri $($pr.diff_url)
            Write-Host $diffTxt
        }
        catch {
            Write-Host "Please view online: $($pull.html_url)"
        }
    }
    catch {
        if ($_.Exception.Response.StatusCode.Value__ -eq "404") {
            Write-Host -ForegroundColor Red "Invalid pull request number: $number"
        }
        else {
            Write-Host -ForegroundColor Red $_.Exception
        }
    }
}

Export-ModuleMember -Function Show-ShowHelp, Show-PullRequest