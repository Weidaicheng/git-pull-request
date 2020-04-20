function Get-Settings {
    return Get-Content "$Global:root/configuration/settings.json" | ConvertFrom-Json
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

    return $value
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

Export-ModuleMember -Function Get-Settings, Compare-CommandOptions, Get-CommandOptionValue, Get-RequiredArgument