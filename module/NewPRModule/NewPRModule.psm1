function Show-NewHelp {
    Write-Host (Get-DocText "new")
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

    try {
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

        if ($statusCode -eq '201') {
            return @{
                number = $response.number
                url    = $response.url
            }
        }
        elseif ($statusCode -eq '404') {
            throw "Pull request creation failed, please check you parameters."
        }
        elseif ($statusCode -eq '422') {
            throw $response.errors[0].message
        }
        else {
            throw "Pull request $number creation failed."
        }
    }
    catch {
        throw $_.Exception.Message
    }
}

Export-ModuleMember -Function Show-NewHelp, New-PullRequest