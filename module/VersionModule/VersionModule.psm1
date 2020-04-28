function Show-Version {
    Write-LogInfo "$($MyInvocation.MyCommand)"
    
    Write-Host $Global:settings.About.Version
}

Export-ModuleMember -Function Show-Version