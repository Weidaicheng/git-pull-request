function Show-DiffHelp {
    Write-Host (Get-DocText "diff")
}

function Show-DiffInfo {
    param (
        [string]$owner,
        [string]$repo,
        [int]$number
    )

    try {
        $response = Invoke-RestMethod -Uri "$($Global:settings.Api.Url)/repos/$owner/$repo/pulls/$number" -SkipHttpErrorCheck -StatusCodeVariable statusCode

        if ($statusCode -eq "200") {
            # write diff info
            $diffResponse = Invoke-RestMethod -Uri $($response.diff_url) -SkipHttpErrorCheck -StatusCodeVariable statusCodeDiff
            if ($statusCodeDiff -eq "200") {
                Write-Host
                Write-Host "Diff info:"
                Write-Host $diffResponse
            }
            else {
                Write-Host "Please view diff info online: $($response.html_url)"
            }
        }
        elseif ($statusCode -eq "404") {
            throw "Pull request $number not found, please check your parameters."
        }
        else {
            throw "Http error, code: $statusCode"
        }
    }
    catch {
        throw $_.Exception.Message
    }
}

Export-ModuleMember -Function Show-DiffHelp, Show-DiffInfo