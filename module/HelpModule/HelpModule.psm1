function Show-Help {
    Write-LogInfo "$($MyInvocation.MyCommand)"
    Write-Host (Get-DocText "")
}

Export-ModuleMember -Function Show-Help