function Show-CommitsHelp {
    # get help text from doc
    # TODO: abstract get doc function
    $helpText = (Get-Content -Path "$Global:root/doc/usage-commits.txt") -Join "`n"
    Write-Host $helpText    
}

function Show-Commits {
    param (
        [string]$owner,
        [string]$repo,
        [int]$number
    )

    try {
        $response = Invoke-RestMethod -Uri "$($Global:settings.Api.Url)/repos/$owner/$repo/pulls/$number/commits" -SkipHttpErrorCheck -StatusCodeVariable statusCode

        if ($statusCode -eq "200") {
            foreach ($item in $response) {
                # write sha
                Write-Host -ForegroundColor Yellow "commit $($item.sha)"

                # write author
                Write-Host "Author: $($item.commit.author.name) <$($item.commit.author.email)>"

                # write date
                $timeZone = Get-TimeZone
                $localTime = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId($item.commit.author.date, $timeZone.Id)
                Write-Host "Date  : $($localTime.ToString($Global:settings.Global.TimeFormat)) [$($timeZone.Id)]"

                # write message
                Write-Host
                $message = $item.commit.message -replace "\n\n", "`n    "
                Write-Host "    $message"

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

Export-ModuleMember -Function Show-CommitsHelp, Show-Commits