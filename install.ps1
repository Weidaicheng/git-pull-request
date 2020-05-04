#! /usr/bin/env pwsh

function Get-Setting {
    <#
        .SYNOPSIS
            Get merged setting.
    #>
    param (
        [object]$newSetting,
        [object]$oldSetting
    )

    $newSetting.PSObject.Properties | ForEach-Object {
        $name = $_.Name

        if (($newSetting.$name) -is [System.Management.Automation.PSCustomObject]) {
            $newSetting.$name = Get-Setting $newSetting.$name $oldSetting.$name
        }
        else {
            $newSetting.$name = $null -eq $oldSetting.$name ? $newSetting.$name : $oldSetting.$name
        }
    }

    return $newSetting
}

# check if git has installed or not
if (-not(Get-Command "git" -ErrorAction SilentlyContinue)) {
    Write-Host -ForegroundColor Red "Please install git first."
    exit
}

# set relesse file path
$releasePath = "$PSScriptRoot/release"
Write-Host "File path $releasePath"

# 1. copy all files to program location
# get destination folder
$destination = ""
if ($IsWindows) {
    # on windows: ~/AppData/Local/git-pull-request
    $destination = "$($Env:USERPROFILE)/AppData/Local"
}
elseif ($IsLinux) {
    # check WSL
    if ($null -ne $Env:WSL_DISTRO_NAME) {
        Write-Host "WSL $Env:WSL_DISTRO_NAME"

        if (($Env:PATH | %{ $_ -match "/AppData/Local/git-pull-request" }) -contains $true) {
            # has already installed in windows host
            Write-Host "Host has already installed, existing installation..."
            exit
        }
    }

    # on Linux: ~/.pss/git-pull-request
    $destination = "~/.pss"
}
elseif ($IsMacOS) {
    # on Mac: /Application/git-pull-request
    $destination = "/Application"
}
else {
    Write-Host -ForegroundColor Red "Uncognized OS."
    exit
}
$destination = "$destination/git-pull-request"
Write-Host "Install path $destination"

if (-not(Test-Path -Path $destination -PathType Container)) {
    # new install
    Write-Host "New installation"
    Write-Host "Creating folder..."
    $tmp = New-Item -ItemType Directory -Path $destination
    Write-Host "Installing all files..."
    Copy-Item -Path "$releasePath/*" -Destination $destination -Recurse
}
else {
    # update
    Write-Host "Update"
    # copy main scripts
    Write-Host "Updating main scripts..."
    Copy-Item "$releasePath/git-pull-request*" -Destination $destination -Force
    # copy modules
    if (-not(Test-Path -Path "$destination/module" -PathType Container)) {
        Write-Host "Creating module folder..."
        $tmp = New-Item -ItemType Directory -Path "$destination/module"
    }
    Write-Host "Updating modules..."
    Copy-Item -Path "$releasePath/module/*" -Destination "$destination/module" -Recurse -Force
    # copy docs
    if (-not(Test-Path -Path "$destination/doc" -PathType Container)) {
        Write-Host "Creating doc folder..."
        $tmp = New-Item -ItemType Directory -Path "$destination/doc"
    }
    Write-Host "Updating docs..."
    Copy-Item -Path "$releasePath/doc/*" -Destination "$destination/doc" -Recurse -Force
    # merge settings
    if (-not(Test-Path -Path "$destination/configuration" -PathType Container)) {
        Write-Host "No settings detected"
        Write-Host "Creating configuration folder..."
        $tmp = New-Item -ItemType Directory -Path "$destination/configuration"
        Write-Host "Installing settings..."
        Copy-Item "$releasePath/configuration/settings.json" -Destination "$destination/configuration"
    }
    elseif (-not(Test-Path -Path "$destination/configuration/settings.json" -PathType Leaf)) {
        Write-Host "No settings detected"
        Write-Host "Installing settings..."
        Copy-Item "$releasePath/configuration/settings.json" -Destination "$destination/configuration"
    }
    else {
        Write-Host "Dtected settings"
        Write-Host "Updating settings..."
        $newSettings = Get-Content "$releasePath/configuration/settings.json" | ConvertFrom-Json
        $oldSettings = Get-Content "$destination/configuration/settings.json" | ConvertFrom-Json

        $newSettings = Get-Setting $newSettings $oldSettings
        ($newSettings | ConvertTo-Json) | Out-File -FilePath "$destination/configuration/settings.json"
    }
}

# 2. set up PATH
if ($IsWindows) {
    $path = [Environment]::GetEnvironmentVariable("PATH", "user")
    if ($path.IndexOf($destination) -gt -1) {
        Write-Host "Path exists, skipping setting path..."
    }
    else {
        Write-Host "Setting new PATH $destination"  
        [Environment]::SetEnvironmentVariable("PATH", $path + ";$destination", "User")  
    }
}
elseif ($IsLinux) {
    if (((Get-Content -Path "~/.bashrc") | %{ $_ -match "~/.pss/git-pull-request" }) -contains $true) {
        Write-Host "Path exists in ~/.bashrc, skipping setting path..."
    }
    else {
        Write-Host "Setting new PATH $destination in ~/.bashrc"  
        Add-Content -Path "~/.bashrc" -Value ("PATH=$" + "PATH:$destination`nexport PATH")
    }
    if (((Get-Content -Path "~/.profile") | %{ $_ -match "~/.pss/git-pull-request" }) -contains $true) {
        Write-Host "Path exists in ~/.profile, skipping setting path..."
    }
    else {
        Write-Host "Setting new PATH $destination in ~/.profile"  
        Add-Content -Path "~/.profile" -Value ("PATH=$" + "PATH:$destination`nexport PATH")
    }
}
elseif ($IsMacOS) {
    # TODO: Mac
}
else {
    Write-Host -ForegroundColor Red "Uncognized machine type."
    exit
}

# 3. installation finish
Write-Host "Installation finish."