function Show-FilesHelp {
    # get help text from doc
    # TODO: abstract get doc function
    $helpText = (Get-Content -Path "$Global:root/doc/usage-files.txt") -Join "`n"
    Write-Host $helpText    
}

function Show-Files {
    param (
        [string]$owner,
        [string]$repo,
        [int]$number
    )

    try {
        $response = Invoke-RestMethod -Uri "$($Global:settings.Api.Url)/repos/$owner/$repo/pulls/$number/files" -SkipHttpErrorCheck -StatusCodeVariable statusCode

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

Export-ModuleMember -Function Show-FilesHelp, Show-Files