function Show-Help {
    # get help text from doc
    # TODO: abstract get doc function
    $helpText = (Get-Content -Path "$Global:root/doc/usage.txt") -Join "`n"
    Write-Host $helpText
}

Export-ModuleMember -Function Show-Help