# https://itpro-tips.com/2020/update-all-powershell-modules-at-once/
# https://itpro-tips.com/2020/mettre-a-jour-tous-les-modules-powershell-en-une-fois/

# This script provides informations about the module version (current and the latest available on PowerShell Gallery) and update to the latest version
# If you have a module with two or more versions, the script delete them and reinstall only the latest.

# PowerShell 5.0 for PowerShell Gallery  
#Requires -Version 5.0
#Requires -RunAsAdministrator

Write-Host -ForegroundColor cyan 'Define PowerShell to use TLS1.2 in this session, needed since 1st April 2020 (https://devblogs.microsoft.com/powershell/powershell-gallery-tls-support/)'
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

# if needed
# Register PSGallery PSprovider and set as Trusted source
# Register-PSRepository -Default -ErrorAction SilentlyContinue
# Set-PSRepository -Name PSGallery -InstallationPolicy trusted -ErrorAction SilentlyContinue

$modules = Get-InstalledModule

foreach ($module in $modules.Name) {
    $currentVersion = $null
	
    if ($null -ne (Get-InstalledModule -Name $module -ErrorAction SilentlyContinue)) {
        $currentVersion = (Get-InstalledModule -Name $module -AllVersions).Version
    }
	
    $moduleInfos = Find-Module -Name $module
	
    if ($null -eq $currentVersion) {
        Write-Host -ForegroundColor Cyan "$($moduleInfos.Name) - Install from PowerShellGallery version $($moduleInfos.Version). Release date: $($moduleInfos.PublishedDate)"  
		
        try {
            Install-Module -Name $module -Force
        }
        catch {
            Write-Host -ForegroundColor red "$_.Exception.Message"
        }
    }
    elseif ($moduleInfos.Version -eq $currentVersion) {
        Write-Host -ForegroundColor Green "$($moduleInfos.Name) already installed in the latest version ($currentVersion. Release date: $($moduleInfos.PublishedDate))"
    }
    elseif ($currentVersion.count -gt 1) {
        Write-Warning "$module is installed in $($currentVersion.count) versions (versions: $($currentVersion -join ' | '))"
        Write-Host -ForegroundColor Cyan "Uninstall previous $module versions"
        
        try {
            Get-InstalledModule -Name $module -AllVersions | Where-Object {$_.Version -ne $moduleInfos.Version} | Uninstall-Module -Force
        }
        catch {
            Write-Host -ForegroundColor red "$_.Exception.Message"
        }
        
        Write-Host -ForegroundColor Cyan "$($moduleInfos.Name) - Install from PowerShellGallery version $($moduleInfos.Version). Release date: $($moduleInfos.PublishedDate)"  
    
        try {
            Install-Module -Name $module -Force
        }
        catch {
            Write-Host -ForegroundColor red "$_.Exception.Message"
        }
    }
    else {       
        Write-Host -ForegroundColor Cyan "$($moduleInfos.Name) - Update from PowerShellGallery from version $currentVersion to $($moduleInfos.Version). Release date: $($moduleInfos.PublishedDate)" 
        try {
            Update-Module -Name $module -Force
        }
        catch {
            Write-Host -ForegroundColor red "$_.Exception.Message"
        }
    }
}