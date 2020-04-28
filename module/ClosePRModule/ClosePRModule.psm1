function Show-CloseHelp {
    Write-LogInfo "$($MyInvocation.MyCommand)"

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
    Write-LogInfo "$($MyInvocation.MyCommand) $owner $repo $number"

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
    $statusCode -eq "200" ? (Write-LogInfo "status code $statusCode") : (Write-LogError "status code $statusCode")
        
    if ($statusCode -eq '200') {
        return
    }
    else {
        Write-LogError $response

        $errorMsg = "Pull request $number close failed."
        if ($statusCode -eq "404") {
            $errorMsg = "Pull request $number doesn't exist, please check the parameters."
        }

        throw $errorMsg
    }
}

Export-ModuleMember -Function Show-CloseHelp, Close-PullRequest