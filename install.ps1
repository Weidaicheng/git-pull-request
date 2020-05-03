#! /usr/bin/env pwsh

# 1. request root authorize on Linux & Mac
if ($IsLinux) {
    $currentUser = $env:USER
	if ($currentUser -ne "root") {
		sudo pwsh test.ps1 $currentUser
		exit
	}
}
if ($IsMacOS) {
    # TODO: Mac
}

# 2. get current user
if ($IsWindows) {
    $user = $env:USERNAME
}
elseif ($IsLinux) {
    $user = $args[0]
    $user = $null -eq $user -or $user -eq "" ? $env:USER : $user
}
elseif ($IsMacOS) {
    # TODO: Mac
}
else {
    Write-Host -ForegroundColor Red "Uncognized machine type."
    exit
}

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

# set relesse file path
$releasePath = "$PSScriptRoot/release"
Write-Host "File path $releasePath"

# 3. copy all files to program location
# get destination folder
$destination = ""
if ($IsWindows) {
    # on windows: ~/AppData/Local/git-pull-request
    $destination = "$($Env:USERPROFILE)/AppData/Local"
}
elseif ($IsLinux) {
    # on Linux: /usr/bin/git-pull-request
    $destination = "/usr/bin"
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

# 4. set up PATH
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
    $path = [Environment]::GetEnvironmentVariable("PATH")
    if ($path.IndexOf($destination) -gt -1) {
        Write-Host "Path exists, skipping setting path..."
    }
    else {
        Write-Host "Setting new PATH $destination"  
        [Environment]::SetEnvironmentVariable("PATH", $path + ":$destination")  
    }
}
elseif ($IsMacOS) {
    # TODO: Mac
}
else {
    Write-Host -ForegroundColor Red "Uncognized machine type."
    exit
}

# 5. installation finish
Write-Host "Installation finish."