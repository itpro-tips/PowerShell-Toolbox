function Get-MSIFileInformation {
    param(
        [parameter(Mandatory = $true)]

        [ValidateNotNullOrEmpty()] [System.IO.FileInfo]$Path
    ) 
    Process {
        $properties = @('ProductVersion', 'ProductCode', 'ProductName', 'Manufacturer', 'ProductLanguage', 'FullVersion')
   
        $object = [PSCustomObject][ordered]@{
            File = $Path.Name
        }

        # Read property from MSI database
        $WindowsInstaller = New-Object -ComObject WindowsInstaller.Installer
        $MSIDatabase = $WindowsInstaller.GetType().InvokeMember('OpenDatabase', 'InvokeMethod', $null, $WindowsInstaller, @($Path.FullName, 0))

        foreach ($property in $properties) {
            $View = $null
            $Query = "SELECT Value FROM Property WHERE Property = '$($Property)'"
            $View = $MSIDatabase.GetType().InvokeMember('OpenView', 'InvokeMethod', $null, $MSIDatabase, ($Query))
            $View.GetType().InvokeMember('Execute', 'InvokeMethod', $null, $View, $null)
            $Record = $View.GetType().InvokeMember('Fetch', 'InvokeMethod', $null, $View, $null)
            try {
                $Value = $Record.GetType().InvokeMember('StringData', 'GetProperty', $null, $Record, 1) 
            }
            catch {
                Write-Warning "Unable to get '$property' $($_.Exception.Message)"
                continue
            }
            
            $object | Add-Member -MemberType NoteProperty -Name $property -Value $Value
        } 

        # Commit database and close view
        $MSIDatabase.GetType().InvokeMember('Commit', 'InvokeMethod', $null, $MSIDatabase, $null)
        $View.GetType().InvokeMember('Close', 'InvokeMethod', $null, $View, $null)
 
        
    }
    End {
        # Run garbage collection and release ComObject
        $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($WindowsInstaller) 
        [System.GC]::Collect()

        return $object
    }
} 
