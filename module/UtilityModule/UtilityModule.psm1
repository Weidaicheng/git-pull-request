# variable initialize
$logLevels = New-Object "System.Collections.Generic.Dictionary[string,int]"
$logLevels["Info"] = 1
$logLevels["Warn"] = 2
$logLevels["Error"] = 4

function Get-Settings {
    return Get-Content "$Global:root/configuration/settings.json" | ConvertFrom-Json
}

function Write-File {
    param (
        [string]$path,
        [string]$text
    )
    
    $text | Out-File -FilePath $path
}

function Get-IsLogBegin {
    <#
        .SYNOPSIS
            Get if the log line starts with [LogLevel]
    #>
    param (
        [string]$line
    )
    
    [string[]]$logKeys = $logLevels.Keys | ForEach-Object { "[$_]" }
    
    $isBegin = $false
    foreach ($item in $logKeys) {
        if ($line.StartsWith($item)) {
            $isBegin = $true
            break
        }
    }

    return $isBegin
}

function Clear-Logs {
    <#
        .SYNOPSIS
            Clear old logs.
    #>

    $allSettings = Get-Settings
    $now = Get-Date
    $logFile = "$Global:root/logs/log.log"

    # if today has cleared logs, exit function
    $lastClearedDate = $allSettings.LogClear.LastClearDate
    $lastClearedDate = $lastClearedDate -eq "" ? "Jan 1 1970" : $lastClearedDate
    if (([datetime]$lastClearedDate).Date -ge $now.Date) {
        return
    }

    # if log file doesn't exist, exit function
    if (-not (Test-Path $logFile -PathType Leaf)) {
        return
    }

    # get saved days
    try {
        $logSavedDays = [int]$allSettings.Global.LogSavedDays
        if ($logSavedDays -le 0) {
            throw
        }
    }
    catch {
        # default is 30 days if the value not set or less than 0
        $logSavedDays = 30
    }

    # if last modified time grater than LogSavedDays, delete log file and exit function
    if ((New-Timespan -Start (Get-Item $logFile).LastWriteTime -End ($now)).Days -gt $logSavedDays) {
        Remove-Item $logFile
        return
    }

    $content = Get-Content -Path $logFile
    $newContent = ""
    for ($i = 0; $i -lt $content.Length; $i++) {
        $contentI = $content[$i].ToString()

        if ((Get-IsLogBegin $contentI)) {
            # this line is a log beginning
            try {
                $logTime = [DateTime]($contentI -split "]")[1].ToString().TrimStart('[')
            }
            catch {
                # invalid log time, set this log expired
                $logTime = $now.AddDays(0 - $logSavedDays - 1)
            }
            if ((New-TimeSpan -Start $logTime -End ($now)).Days -lt $logSavedDays) {
                # this log hasn't expired yet
                $newContent += $contentI
                if ($i + 1 -lt $content.Length) {
                    $newContent += "`n"
                }

                for ($j = $i + 1; $j -lt $content.Length; $j++) {
                    $contentJ = $content[$j].ToString()

                    if ((Get-IsLogBegin $contentJ)) {
                        # next line is a log beginning
                        $i = $j - 1
                        break;
                    }
                    else {
                        # this line belongs to last log which hasn't exipred yet
                        $newContent += $contentJ
                        if ($j + 1 -lt $content.Length) {
                            $newContent += "`n"
                        }
                    }
                }
            }
            else {
                # this log has expired
                for ($j = $i + 1; $j -lt $content.Length; $j++) {
                    $contentJ = $content[$j].ToString()

                    if ((Get-IsLogBegin $contentJ)) {
                        # next line is a log beginning
                        $i = $j - 1
                        break;
                    }
                    else {
                        # this line beglongs to last log which has expired, do nothing
                    }
                }
            }
        }
    }
    $newContent | Set-Content -Path $logFile

    $allSettings.LogClear.LastClearDate = $now.ToString("MMM dd yyyy")
    Write-File "$Global:root/configuration/settings.json" ($allSettings | ConvertTo-Json)
}

function Hide-LogText {
    <#
        .SYNOPSIS
            Hide information to log, for example token
    #>
    
    param (
        [string]$logTxt,
        [string]$key,
        [char]$hidden
    )
    $logTxtHidden = ""

    if ($logTxt.IndexOf(" ") -gt -1) {
        $arr = $logTxt -split " " | Where-Object { $_ -ne "" }
        for ($i = 0; $i -lt $arr.Length; $i++) {
            $logTxtHidden += $arr[$i]

            $keyHidden = " "
            if ($arr[$i].IndexOf($key) -gt -1 -and $i + 1 -lt $arr.Length) {
                for ($j = 0; $j -lt $arr[$i + 1].Length; $j++) {
                    $keyHidden += $hidden
                }
                $keyHidden += " "
                $i++
            }
        
            $logTxtHidden += $keyHidden
        }
    }
    else {
        $logTxtHidden = $logTxt
    }

    return $logTxtHidden
}

function Write-Log {
    <#
        .SYNOPSIS
            Write log
    #>

    param (
        [string]$logLevel,
        [string]$logTxt
    )

    try {
        # get log level from setting
        [int]$setlogLevel = $null -eq $logLevels[(Get-Settings).Global.LogLevel] ? $logLevels[($logLevels.Keys)[0]] : $logLevels[(Get-Settings).Global.LogLevel]
        [int]$currentLogLevel = $logLevels[$logLevel]

        if ($currentLogLevel -lt $setlogLevel) {
            return
        }

        # clear old log
        Clear-Logs
    
        # create log folder if it doesn't exist
        $logFolder = "$Global:root/logs"
        if (-not (Test-Path $logFolder -PathType Container)) {
            $tmp = New-Item -ItemType Directory -Path $logFolder
        }
        # hide token value
        $logTxt = Hide-LogText $logTxt "Token" "*"
        # get timestamp
        $now = (Get-Date).ToString((Get-Settings).Global.TimeFormat)
        # write log
        Add-Content -Path "$logFolder/log.log" -Value "[$logLevel][$now] $logTxt"
    }
    catch {
        # ignored
        # Write-Host $_.Exception   
    }
}

function Write-LogInfo {
    <#
        .SYNOPSIS
            Write info level log
    #>

    param (
        [string]$logTxt
    )
    
    Write-Log "Info" $logTxt
}

function Write-LogWarn {
    <#
        .SYNOPSIS
            Write warn level log
    #>

    param (
        [string]$logTxt
    )
    
    Write-Log "Warn" $logTxt
}

function Write-LogError {
    <#
        .SYNOPSIS
            Write error level log
    #>

    param (
        [string]$logTxt
    )
    
    Write-Log "Error" $logTxt
}

function Compare-CommandOptions {
    param (
        [string[]]$arguments,
        [string[]]$options
    )
    
    for ($i = 1; $i -lt $arguments.Count; $i += 2) {
        $passed = $false

        if ($null -eq $arguments[$i + 1]) {
            continue
        }

        foreach ($option in $options) {
            if ($option -eq $arguments[$i]) {
                $passed = $true
                break
            }
        }

        if (-not $passed) {
            throw "Unconigazed option: $($arguments[$i])"
        }
    }
}

function Get-CommandOptionValue {
    param (
        [string[]]$arguments,
        [string[]]$options,
        [string]$default = $null,
        [string]$errMsg = ""
    )
    
    $options = $options | Where-Object { $null -ne $_ -and $_ -ne "" }

    if ($null -eq $options -or $options.Length -eq 0) {
        throw "Please provide at list one option."
    }
    
    $value = $default
    for ($i = 1; $i -lt $arguments.Count; $i += 2) {
        foreach ($option in $options) {
            if ($option -eq $arguments[$i]) {
                $value = $arguments[$i + 1]

                if ($null -eq $value) {
                    if ($errMsg -eq "") {
                        throw "Please provide value for option: $option."
                    }
                    else {
                        throw $errMsg
                    }
                }

                break
            }
        }
    }

    return $value.TrimEnd()
}

function Get-RequiredArgument {
    param (
        [string[]]$arguments,
        [string[]]$options,
        [string]$errMsg = ""
    )
    
    for ($i = 1; $i -lt $arguments.Count; $i += 2) {
        if ($null -eq $arguments[$i + 1]) {
            return $arguments[$i]
        }
    }

    if ($errMsg -eq "") {
        throw "Argument required."
    }
    else {
        throw $errMsg
    }
}

function Get-DocText {
    param (
        [string]$module
    )
    
    return (Get-Content -Path "$Global:root/doc/$($module -eq '' ? 'usage' : 'usage-' + $module).txt") -Join "`n"
}

Export-ModuleMember -Function Get-Settings, Write-File, Write-LogInfo, Write-LogWarn, Write-LogError, Compare-CommandOptions, Get-CommandOptionValue, Get-RequiredArgument, Get-DocText