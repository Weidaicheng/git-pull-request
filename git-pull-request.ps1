#! /usr/bin/env pwsh

# import functions
Import-Module -Force "$PSScriptRoot/module/UtilityModule"
Import-Module -Force "$PSScriptRoot/module/HelpModule"
Import-Module -Force "$PSScriptRoot/module/VersionModule"
Import-Module -Force "$PSScriptRoot/module/ListPRModule"
Import-Module -Force "$PSScriptRoot/module/ShowPRModule"
Import-Module -Force "$PSScriptRoot/module/SettingModule"

# global variables
$Global:root = $PSScriptRoot
$Global:settings = Get-Settings

# first argument
$arg1 = $args[0]
if ($null -eq $arg1) {
    $arg1 = "--help"
}

# get help
# git pull-request --help|-l
if ($arg1 -eq "--help" -or $arg1 -eq "-h") {
    try {
        Show-Help
    }
    catch {
        Write-Host -ForegroundColor $Global:settings.Global.ErrorColor $_.Exception.Message
    }
    finally {
        exit 0
    }
}

# get version information
# git pull-request --version|-v
if ($arg1 -eq "--version" -or $arg1 -eq "-v") {
    try {
        Show-Version
    }
    catch {
        Write-Host -ForegroundColor $Global:settings.Global.ErrorColor $_.Exception.Message
    }
    finally {
        exit 0
    }
}

# settings
# git pull-request setting.[sub setting] [new setting]
if ($arg1.StartsWith("setting")) {
    try {
        if ($arg1 -eq "setting") {
            if ($args[1] -eq "--help" -or $args[1] -eq "-h") {
                Show-SettingHelp
                exit 0
            }
            
            Show-AllSettings
        }
        else {
            $subSetting = $arg1.Replace("setting.", "")
    
            if ($null -eq $args[1]) {
                # display specific setting
                Show-Setting $subSetting
            }
            else {
                # set specific setting
                $Global:settings = Update-Setting $subSetting $args[1]
            }
        }
    }
    catch {
        Write-Host -ForegroundColor $Global:settings.Global.ErrorColor $_.Exception.Message
    }
    finally {
        exit 0
    }
}

# list pull requests
# git pull-request list
if ($arg1 -eq "list") {
    try {
        Compare-CommandOptions $args @("--remote", "-r", "--state", "-s")

        if ($args[1] -eq "--help" -or $args[1] -eq "-h") {
            Show-ListHelp
            exit 0
        }
    
        $remote = Get-CommandOptionValue $args @("--remote", "-r") "origin" ""
        $state = Get-CommandOptionValue $args @("--state", "-s") "open" ""

        $pullUrl = git remote get-url --all $remote
        if (-not $?) {
            exit 0
        }
        $arr = $pullUrl -split "/" | Where-Object { $_ -ne "" }
        $owner = $arr[$arr.Length - 2]
        $repo = $arr[$arr.Length - 1]
        if ($repo.EndsWith('.git')) {
            $repo = $repo.Substring(0, $repo.Length - 4)
        }
    
        Show-PullRequests $owner $repo $state
    }
    catch {
        Write-Host -ForegroundColor $Global:settings.Global.ErrorColor $_.Exception.Message
    }
    finally {
        exit 0
    }
}

# show pull request
# git pull-request show <number>
if ($arg1 -eq "show") {
    try {
        Compare-CommandOptions $args @("--remote", "-r")

        if ($args[1] -eq "--help" -or $args[1] -eq "-h") {
            Show-ShowHelp
            exit 0
        }
    
        $remote = Get-CommandOptionValue $args @("--remote", "-r") "origin" ""
        $number = Get-RequiredArgument $args @("--remote", "-r") "PR number required."

        $pullUrl = git remote get-url --all $remote
        if (-not $?) {
            exit 0
        }
        $arr = $pullUrl -split "/" | Where-Object { $_ -ne "" }
        $owner = $arr[$arr.Length - 2]
        $repo = $arr[$arr.Length - 1].TrimEnd(".git")
    
        Show-PullRequest $owner $repo $number
    }
    catch {
        Write-Host -ForegroundColor $Global:settings.Global.ErrorColor $_.Exception.Message
    }
    finally {
        exit 0
    }
}