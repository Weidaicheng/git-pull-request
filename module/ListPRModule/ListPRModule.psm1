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
    if (-not ($null -ne $prs -and $prs -ne 0)) {
        Write-Host "No pull request found."
        return
    }

    $prNumberMaxLength = ($prs | Measure-Object -Property number -Maximum).Maximum.ToString().Length
    $prNumberMaxLength = $prNumberMaxLength -lt 2 ? 2 : $prNumberMaxLength

    # write header
    $headerString = New-Object -TypeName "System.Text.StringBuilder"
    for ($i = 0; $i -lt $prNumberMaxLength - 2; $i++) {
        $headerString.Append(" ");
    }
    $headerString.Append("PR  ");
    $headerString.Append("State   ");
    $headerString.Append("Title");
    Write-Host $headerString
    
    foreach ($pr in $prs) {
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

Export-ModuleMember -Function Show-ListHelp, Show-PullRequests