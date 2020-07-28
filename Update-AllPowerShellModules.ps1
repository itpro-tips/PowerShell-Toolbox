# PowerShell 5.0 pour PowerShell Gallery  
#Requires -Version 5.0
#Requires -RunAsAdministrator

Write-Host -ForegroundColor cyan 'Define PowerShell to use TLS1.2 in this session, needed since 1st April 2020 (https://devblogs.microsoft.com/powershell/powershell-gallery-tls-support/)'
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

#>
# Register PSGallery PSprovider and set as Trusted source
Register-PSRepository -Default -ErrorAction SilentlyContinue
Set-PSRepository -Name PSGallery -InstallationPolicy trusted -ErrorAction SilentlyContinue

$modules = Get-InstalledModule

foreach ($module in $modules.Name) {
    $currentVersion = $null
	
    if ($null -ne (Get-InstalledModule -Name $module -ErrorAction SilentlyContinue)) {
        $currentVersion = (Get-InstalledModule -Name $module -AllVersions).Version
    }
	
    $moduleInfos = Find-Module -Name $module
	
    if ($null -eq $currentVersion) {
        Write-Host -ForegroundColor Cyan "Install from PowerShellGallery : $($moduleInfos.Name) - $($moduleInfos.Version) published on $($moduleInfos.PublishedDate)"  
		
        try {
            Install-Module -Name $module -Force
        }
        catch {
            Write-Host -ForegroundColor red "$_.Exception.Message"
        }
    }
    elseif ($moduleInfos.Version -eq $currentVersion) {
        Write-Host -ForegroundColor Green "$($moduleInfos.Name) already installed in the last version"
    }
    elseif ($currentVersion.count -gt 1) {
        Write-Warning "$module is installed in $($currentVersion.count) versions (versions: $currentVersion)"
        Write-Host -ForegroundColor Cyan "Uninstall all $module PowerShell module versions"
        
        try {
            Get-InstalledModule -Name $module -AllVersions | Uninstall-Module -Force
        }
        catch {
            Write-Host -ForegroundColor red "$_.Exception.Message"
        }
        
        Write-Host -ForegroundColor Cyan "Install from PowerShellGallery : $($moduleInfos.Name) - $($moduleInfos.Version) published on $($moduleInfos.PublishedDate)"  
    
        try {
            Install-Module -Name $module -Force
        }
        catch {
            Write-Host -ForegroundColor red "$_.Exception.Message"
        }
    }
    else {       
        Write-Host -ForegroundColor Cyan "Update from PowerShellGallery from $currentVersion to $($moduleInfos.Name) - $($moduleInfos.Version) published on $($moduleInfos.PublishedDate)" 
        try {
            Update-Module -Name $module -Force
        }
        catch {
            Write-Host -ForegroundColor red "$_.Exception.Message"
        }
    }
}