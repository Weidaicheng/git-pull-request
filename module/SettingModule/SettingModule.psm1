function Show-SettingHelp {
    Write-LogInfo "$($MyInvocation.MyCommand)"

    # get help text from doc
    # TODO: abstract get doc function
    $helpText = (Get-Content -Path "$Global:root/doc/usage-setting.txt") -Join "`n"
    Write-Host $helpText    
}

function Show-AllSettings {
    Write-LogInfo "$($MyInvocation.MyCommand)"

    ($Global:settings.Global.PSObject.Properties) | ForEach-Object {
        Write-Host "$($_.Name):$($_.Value)"
    }
}

function Show-Setting {
    param (
        [string]$name
    )
    Write-LogInfo "$($MyInvocation.MyCommand) $name"

    if ($null -eq $Global:settings.Global.$name) {
        throw "Unrecognized setting: $name"
    }
    
    Write-Host $Global:settings.Global.$name
}

function Update-Setting {
    param (
        [string]$name,
        [string]$newValue
    )
    Write-LogInfo "$($MyInvocation.MyCommand) $name $newValue"

    if ($null -eq $Global:settings.Global.$name) {
        throw "Unrecognized setting: $name"
    }
    
    # set specific setting
    $Global:settings.Global.$name = $newValue
    Write-File "$Global:root/configuration/settings.json" ($Global:settings | ConvertTo-Json)
    # output new value
    Write-Host $newValue
    # re-get setting
    return Get-Settings
}

Export-ModuleMember -Function Show-SettingHelp, Show-AllSettings, Show-Setting, Update-Setting