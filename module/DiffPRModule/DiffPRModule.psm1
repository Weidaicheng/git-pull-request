function Show-DiffHelp {
    Write-LogInfo "$($MyInvocation.MyCommand)"
    Write-Host (Get-DocText "diff")
}

function Show-DiffInfo {
    param (
        [string]$owner,
        [string]$repo,
        [int]$number
    )
    Write-LogInfo "$($MyInvocation.MyCommand) $owner $repo $number"

    $response = Invoke-RestMethod -Uri "$($Global:settings.Api.Url)/repos/$owner/$repo/pulls/$number" -SkipHttpErrorCheck -StatusCodeVariable statusCode
    $statusCode -eq "200" ? (Write-LogInfo "status code $statusCode") : (Write-LogError "status code $statusCode")

    if ($statusCode -eq "200") {
        # write diff info
        $diffResponse = Invoke-RestMethod -Uri $($response.diff_url) -SkipHttpErrorCheck -StatusCodeVariable statusCodeDiff
        $statusCodeDiff -eq "200" ? (Write-LogInfo "status code $statusCodeDiff") : (Write-LogError "status code $statusCodeDiff")

        if ($statusCodeDiff -eq "200") {
            Write-Host
            Write-Host "Diff info:"
            Write-Host $diffResponse
        }
        else {
            Write-Error $diffResponse
            Write-Host "Please view diff info online: $($response.html_url)"
        }
    }
    else {
        Write-LogError $response

        $errorMsg = "Http error, code: $statusCode"
        if ($statusCode -eq "404") {
            $errorMsg = "Pull request $number not found, please check your parameters."
        }

        throw $errorMsg
    }
}

Export-ModuleMember -Function Show-DiffHelp, Show-DiffInfo