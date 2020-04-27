function Show-SettingHelp {
    Write-Host (Get-DocText "setting")
}

function Show-AllSettings {
    ($Global:settings.Global.PSObject.Properties) | ForEach-Object {
        Write-Host "$($_.Name):$($_.Value)"
    }
}

function Show-Setting {
    param (
        [string]$name
    )

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