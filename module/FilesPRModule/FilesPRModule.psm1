function Show-FilesHelp {
    Write-LogInfo "$($MyInvocation.MyCommand)"
    Write-Host (Get-DocText "files")
}

function Show-Files {
    param (
        [string]$owner,
        [string]$repo,
        [int]$number
    )
    Write-LogInfo "$($MyInvocation.MyCommand) $owner $repo $number"

    $response = Invoke-RestMethod -Uri "$($Global:settings.Api.Url)/repos/$owner/$repo/pulls/$number/files" -SkipHttpErrorCheck -StatusCodeVariable statusCode
    $statusCode -eq "200" ? (Write-LogInfo "status code $statusCode") : (Write-LogError "status code $statusCode")

    if ($statusCode -eq "200") {
        foreach ($item in $response) {
            # write sha
            Write-Host -ForegroundColor Yellow "commit $($item.sha)"

            # write filename
            Write-Host "File  : $($item.filename)"

            # write status
            Write-Host "Status: $($item.status)"

            # write statics
            Write-Host "Additions: $($item.additions)"
            Write-Host "Deletions: $($item.deletions)"
            Write-Host "Changes  : $($item.changes)"

            # write new line
            Write-Host
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

Export-ModuleMember -Function Show-FilesHelp, Show-Files