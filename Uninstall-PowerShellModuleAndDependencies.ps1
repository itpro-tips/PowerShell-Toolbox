<#
do{
$mod=Get-InstalledModule Vmware* -ErrorAction SilentlyContinue
$mod | % {$_.Name
$_ | Uninstall-Module}}until($(Get-InstalledModule Vmware* -ErrorAction SilentlyContinue) -eq $null)
#>

function Uninstall-PowerShellModuleAndDependencies {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Module
    )
    
    [System.Collections.Generic.List[String]] $script:modulesOrDependencies = @()

    function Get-RecursivePowerShellDepencies {
        param (
            [Parameter(Mandatory = $true)]
            [string]$Module
        )

        $target = Find-Module $Module

        if ($target.Dependencies.count -eq 0) {
            if ($script:modulesOrDependencies -notcontains $target.Name) {
                $script:modulesOrDependencies.Add($target.name)    
            }
        }
        else {
            $target.Dependencies | ForEach-Object {
                # add current dependency
                if ($script:modulesOrDependencies -notcontains $target.Name) {
                    $script:modulesOrDependencies.Add($target.name)    
                }

                # search for dependencies of current dependency
                Get-RecursivePowerShellDepencies -Module $_.name
            }
        }      
    }

    Write-Host "$module - Creating list of dependencies" -ForegroundColor Cyan

    Get-RecursivePowerShellDepencies -Module $Module

    foreach ($modulesOrDependency in $modulesOrDependencies) {
        Write-Host "$modulesOrDependency - Uninstalling" -ForegroundColor Cyan

        try {
            #Uninstall-Module -Name $module.name -Force -ErrorAction Stop
        }
        catch {
            Write-Warning "modulesOrDependency $($_.Exception.Message)"
        }
    }
}