function Show-CloseHelp {
    Write-Host (Get-DocText "close")
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
        $response = Invoke-RestMethod -Uri "$($Global:settings.Api.Url)/repos/$owner/$repo/pulls/$number" -Method "Patch" -ContentType "application/json" -Headers $headers -Body $json -SkipHttpErrorCheck -StatusCodeVariable statusCode
        
        if ($statusCode -eq '200') {
            return
        }
        elseif ($statusCode -eq '404') {
            throw "Pull request $number doesn't exist, please check the parameters."
        }
        else {
            throw "Pull request $number close failed."
        }
    }
    catch {
        throw $_.Exception.Message
    }
}

Export-ModuleMember -Function Show-CloseHelp, Close-PullRequest