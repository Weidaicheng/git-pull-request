function Show-Version {
    Write-Host $Global:settings.About.Version
}

Export-ModuleMember -Function Show-Version