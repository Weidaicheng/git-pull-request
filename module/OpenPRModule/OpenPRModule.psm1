function Show-OpenHelp {
    # get help text from doc
    # TODO: abstract get doc function
    $helpText = (Get-Content -Path "$Global:root/doc/usage-open.txt") -Join "`n"
    Write-Host $helpText    
}

function Open-PullRequest {
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
            state = "open"
        } | ConvertTo-Json
        $response = Invoke-RestMethod -Uri "$($Global:settings.Api.Url)/repos/$owner/$repo/pulls/$number" -Method "Patch" -ContentType "application/json" -Headers $headers -Body $json -SkipHttpErrorCheck -StatusCodeVariable statusCode
        
        if ($statusCode -eq '200') {
            return
        }
        elseif ($statusCode -eq '404') {
            throw "Pull request $number doesn't exist, please check the parameters."
        }
        elseif ($statusCode -eq '422') {
            throw $response.errors[0].message
        }
        else {
            throw "Pull request $number re-open failed."
        }
    }
    catch {
        throw $_.Exception.Message
    }
}

Export-ModuleMember -Function Show-OpenHelp, Open-PullRequest