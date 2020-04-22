function Show-CloseHelp {
    # get help text from doc
    # TODO: abstract get doc function
    $helpText = (Get-Content -Path "$Global:root/doc/usage-close.txt") -Join "`n"
    Write-Host $helpText    
}

function Close-PullRequest {
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
        $json = @{
            state = "closed"
        } | ConvertTo-Json
        $response = Invoke-RestMethod -Uri "$($Global:settings.Api.Url)/repos/$owner/$repo/pulls/$number" -Method "Patch" -ContentType "application/json" -Headers $headers -Body $json
    }
    catch {
        if ($_.Exception.Response.StatusCode.Value__ -eq "404") {
            throw "Pull request not found, please check you parameters."
        }
        else {
            throw $_.Exception.Message
        }
    }
}

Export-ModuleMember -Function Show-CloseHelp, Close-PullRequest