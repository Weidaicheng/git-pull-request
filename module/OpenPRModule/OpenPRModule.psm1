function Show-OpenHelp {
    Write-LogInfo "$($MyInvocation.MyCommand)"
    Write-Host (Get-DocText "open")
}

function Open-PullRequest {
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
    $json = @{
        state = "open"
    } | ConvertTo-Json
    $response = Invoke-RestMethod -Uri "$($Global:settings.Api.Url)/repos/$owner/$repo/pulls/$number" -Method "Patch" -ContentType "application/json" -Headers $headers -Body $json -SkipHttpErrorCheck -StatusCodeVariable statusCode
    $statusCode -eq "200" ? (Write-LogInfo "status code $statusCode") : (Write-LogError "status code $statusCode")
        
    if ($statusCode -eq '200') {
        return
    }
    else {
        Write-LogError $response

        $errorMsg = "Pull request $number re-open failed."
        if ($statusCode -eq "404") {
            $errorMsg = "Pull request $number doesn't exist, please check the parameters."
        }
        elseif ($statusCode -eq "422") {
            $errorMsg = $response.errors[0].message
        }

        throw $errorMsg
    }
}

Export-ModuleMember -Function Show-OpenHelp, Open-PullRequest