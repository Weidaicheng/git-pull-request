#! /usr/bin/env pwsh

# import functions
Import-Module -Force "$PSScriptRoot/module/UtilityModule"
Import-Module -Force "$PSScriptRoot/module/HelpModule"
Import-Module -Force "$PSScriptRoot/module/VersionModule"
Import-Module -Force "$PSScriptRoot/module/ListPRModule"
Import-Module -Force "$PSScriptRoot/module/ShowPRModule"
Import-Module -Force "$PSScriptRoot/module/NewPRModule"
Import-Module -Force "$PSScriptRoot/module/ClosePRModule"
Import-Module -Force "$PSScriptRoot/module/OpenPRModule"
Import-Module -Force "$PSScriptRoot/module/MergePRModule"
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
        Compare-CommandOptions $args @("--remote", "-r", "--owner", "-o", "--state", "-s")

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
        $owner = Get-CommandOptionValue $args @("--owner", "-o") $owner, ""
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
        $options = @("--remote", "-r", "--owner", "-o")

        Compare-CommandOptions $args $options

        if ($args[1] -eq "--help" -or $args[1] -eq "-h") {
            Show-ShowHelp
            exit 0
        }
    
        $remote = Get-CommandOptionValue $args @("--remote", "-r") "origin" ""
        $number = Get-RequiredArgument $args $options "PR number required."

        $pullUrl = git remote get-url --all $remote
        if (-not $?) {
            exit 0
        }
        $arr = $pullUrl -split "/" | Where-Object { $_ -ne "" }
        $owner = $arr[$arr.Length - 2]
        $owner = Get-CommandOptionValue $args @("--owner", "-o") $owner, ""
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

# create new pull request
# git pull-request new [options] [arguments] <title>
if ($arg1 -eq "new") {
    try {
        $options = @("--owner", "-o", "--remote", "-r", "--head", "-e", "--base", "-b", "--body", "-d")

        Compare-CommandOptions $args $options

        if ($args[1] -eq "--help" -or $args[1] -eq "-h") {
            Show-NewHelp
            exit 0
        }

        $remote = Get-CommandOptionValue $args @("--remote", "-r") "origin" ""
        $pushUrl = git remote get-url --push $remote
        if (-not $?) {
            exit 0
        }
        $arr = $pushUrl -split "/" | Where-Object { $_ -ne "" }
        $owner = $arr[$arr.Length - 2]
        $repo = $arr[$arr.Length - 1]
        if ($repo.EndsWith('.git')) {
            $repo = $repo.Substring(0, $repo.Length - 4)
        }
        $owner = Get-CommandOptionValue $args @("--owner", "-o") $owner ""

        $title = Get-RequiredArgument $args $options "Title required."
        $head = git rev-parse --abbrev-ref HEAD
        $base = "master"
        $body = ""

        $head = Get-CommandOptionValue $args @("--head", "-e") $head ""
        $base = Get-CommandOptionValue $args @("--base", "-b") $base ""
        $body = Get-CommandOptionValue $args @("--body", "-d") $body ""

        $result = New-PullRequest $owner $repo $title $head $base $body
        Write-Host "PR $($result.number) created"
        Write-Host "View online at $($result.url)"
    }
    catch {
        Write-Host -ForegroundColor $Global:settings.Global.ErrorColor $_.Exception.Message
    }
    finally {
        exit 0
    }
}

# close pull request
# git pull-request close [options] [arguments] <number>
if ($arg1 -eq "close") {
    try {
        $options = @("--owner", "-o", "--remote", "-r")

        Compare-CommandOptions $args $options

        if ($args[1] -eq "--help" -or $args[1] -eq "-h") {
            Show-CloseHelp
            exit 0
        }

        $remote = Get-CommandOptionValue $args @("--remote", "-r") "origin" ""
        $pushUrl = git remote get-url --push $remote
        if (-not $?) {
            exit 0
        }
        $arr = $pushUrl -split "/" | Where-Object { $_ -ne "" }
        $owner = $arr[$arr.Length - 2]
        $repo = $arr[$arr.Length - 1]
        if ($repo.EndsWith('.git')) {
            $repo = $repo.Substring(0, $repo.Length - 4)
        }
        $owner = Get-CommandOptionValue $args @("--owner", "-o") $owner ""

        $number = Get-RequiredArgument $args $options "PR number required."

        Close-PullRequest $owner $repo $number
        Write-Host "PR $number closed"
    }
    catch {
        Write-Host -ForegroundColor $Global:settings.Global.ErrorColor $_.Exception.Message
    }
    finally {
        exit 0
    }
}

# open pull request
# git pull-request open [options] [arguments] <number>
if ($arg1 -eq "open") {
    try {
        $options = @("--owner", "-o", "--remote", "-r")

        Compare-CommandOptions $args $options

        if ($args[1] -eq "--help" -or $args[1] -eq "-h") {
            Show-OpenHelp
            exit 0
        }

        $remote = Get-CommandOptionValue $args @("--remote", "-r") "origin" ""
        $pushUrl = git remote get-url --push $remote
        if (-not $?) {
            exit 0
        }
        $arr = $pushUrl -split "/" | Where-Object { $_ -ne "" }
        $owner = $arr[$arr.Length - 2]
        $repo = $arr[$arr.Length - 1]
        if ($repo.EndsWith('.git')) {
            $repo = $repo.Substring(0, $repo.Length - 4)
        }
        $owner = Get-CommandOptionValue $args @("--owner", "-o") $owner ""

        $number = Get-RequiredArgument $args $options "PR number required."

        Open-PullRequest $owner $repo $number
        Write-Host "PR $number closed"
    }
    catch {
        Write-Host -ForegroundColor $Global:settings.Global.ErrorColor $_.Exception.Message
    }
    finally {
        exit 0
    }
}

# merge pull request
# git pull-request merge [options] [arguments] <number>
if ($arg1 -eq "merge") {
    try {
        $options = @("--owner", "-o", "--remote", "-r")

        Compare-CommandOptions $args $options

        if ($args[1] -eq "--help" -or $args[1] -eq "-h") {
            Show-MergeHelp
            exit 0
        }

        $remote = Get-CommandOptionValue $args @("--remote", "-r") "origin" ""
        $pushUrl = git remote get-url --push $remote
        if (-not $?) {
            exit 0
        }
        $arr = $pushUrl -split "/" | Where-Object { $_ -ne "" }
        $owner = $arr[$arr.Length - 2]
        $repo = $arr[$arr.Length - 1]
        if ($repo.EndsWith('.git')) {
            $repo = $repo.Substring(0, $repo.Length - 4)
        }
        $owner = Get-CommandOptionValue $args @("--owner", "-o") $owner ""

        $number = Get-RequiredArgument $args $options "PR number required."

        Merge-PullRequest $owner $repo $number
        Write-Host "PR $number merged"
    }
    catch {
        Write-Host -ForegroundColor $Global:settings.Global.ErrorColor $_.Exception.Message
    }
    finally {
        exit 0
    }
}

# unrecognized command
Write-Host -ForegroundColor $Global:settings.Global.ErrorColor "Unrecognized command $arg1"
# show help
Show-Help
exit 0