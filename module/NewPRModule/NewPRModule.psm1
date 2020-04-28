function Show-NewHelp {
    Write-LogInfo "$($MyInvocation.MyCommand)"
    Write-Host (Get-DocText "new"
}

function New-PullRequest {
    param (
        [string]$owner,
        [string]$repo,
        [string]$title,
        [string]$head,
        [string]$base,
        [string]$body
    )
    Write-LogInfo "$($MyInvocation.MyCommand) $owner $repo $title $head $base $body"

    if ($Global:settings.Global.Token -eq "") {
        throw "Token not set, please use setting command to set."
    }

    $headers = @{
        Authorization = "token $($Global:settings.Global.Token)"
    }
    $json = @{
        title = $title;
        head  = $head;
        base  = $base;
        body  = $body;
    } | ConvertTo-Json
    $response = Invoke-RestMethod -Uri "$($Global:settings.Api.Url)/repos/$owner/$repo/pulls" -Method "Post" -ContentType "application/json" -Headers $headers -Body $json -SkipHttpErrorCheck -StatusCodeVariable statusCode
    $statusCode -eq "201" ? (Write-LogInfo "status code $statusCode") : (Write-LogError "status code $statusCode")

    if ($statusCode -eq '201') {
        return @{
            number = $response.number
            url    = $response.url
        }
    }
    else {
        Write-LogError $response

        $errorMsg = "Pull request $number creation failed."
        if ($statusCode -eq "404") {
            $errorMsg = "Pull request creation failed, please check you parameters."
        }
        elseif ($statusCode -eq "422") {
            $errorMsg = $response.errors[0].message
        }

        throw $errorMsg
    }
}

Export-ModuleMember -Function Show-NewHelp, New-PullRequest