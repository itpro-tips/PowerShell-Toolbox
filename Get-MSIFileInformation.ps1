function Get-MSIFileInformation {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo[]]$FilePath
    ) 
  
    $productLanguageHashTable = @{
        '1025' = 'Arabic'
        '1026' = 'Bulgarian'
        '1027' = 'Catalan'
        '1028' = 'Chinese - Traditional'
        '1029' = 'Czech'
        '1030' = 'Danish'
        '1031' = 'German'
        '1032' = 'Greek'
        '1033' = 'English'
        '1034' = 'Spanish'
        '1035' = 'Finnish'
        '1036' = 'French'
        '1037' = 'Hebrew'
        '1038' = 'Hungarian'
        '1040' = 'Italian'
        '1041' = 'Japanese'
        '1042' = 'Korean'
        '1043' = 'Dutch'
        '1044' = 'Norwegian'
        '1045' = 'Polish'
        '1046' = 'Brazilian'
        '1048' = 'Romanian'
        '1049' = 'Russian'
        '1050' = 'Croatian'
        '1051' = 'Slovak'
        '1053' = 'Swedish'
        '1054' = 'Thai'
        '1055' = 'Turkish'
        '1058' = 'Ukrainian'
        '1060' = 'Slovenian'
        '1061' = 'Estonian'
        '1062' = 'Latvian'
        '1063' = 'Lithuanian'
        '1081' = 'Hindi'
        '1087' = 'Kazakh'
        '2052' = 'Chinese - Simplified'
        '2070' = 'Portuguese'
        '2074' = 'Serbian'
    }

    $properties = @('ProductVersion', 'ProductCode', 'ProductName', 'Manufacturer', 'ProductLanguage', 'FullVersion')
   
    try {
        $file = Get-ChildItem $FilePath -ErrorAction Stop
    }
    catch {
        Write-Warning "Unable to get file $FilePath $($_.Exception.Message)"
        return
    }

    $object = [PSCustomObject][ordered]@{
        FileName     = $file.Name
        FilePath     = $file.FullName
        'Length(MB)' = $file.Length / 1MB
    }

    # Read property from MSI database
    $windowsInstallerObject = New-Object -ComObject WindowsInstaller.Installer
    $MSIDatabase = $windowsInstallerObject.GetType().InvokeMember('OpenDatabase', 'InvokeMethod', $null, $windowsInstallerObject, @($file.FullName, 0))

    foreach ($property in $properties) {
        $view = $null
        $query = "SELECT Value FROM Property WHERE Property = '$($property)'"
        $view = $MSIDatabase.GetType().InvokeMember('OpenView', 'InvokeMethod', $null, $MSIDatabase, ($query))
        $view.GetType().InvokeMember('Execute', 'InvokeMethod', $null, $view, $null)
        $record = $view.GetType().InvokeMember('Fetch', 'InvokeMethod', $null, $view, $null)

        try {
            $value = $record.GetType().InvokeMember('StringData', 'GetProperty', $null, $record, 1)
        }
        catch {
            Write-Warning "Unable to get '$property' $($_.Exception.Message)"
            continue
        }
        
        if ($property -eq 'ProductLanguage') {
            $value = "$value ($($productLanguageHashTable[$value]))"
        }

        $object | Add-Member -MemberType NoteProperty -Name $property -Value $value
    }


    $MSIDatabase.GetType().InvokeMember('Commit', 'InvokeMethod', $null, $MSIDatabase, $null)
    $view.GetType().InvokeMember('Close', 'InvokeMethod', $null, $view, $null)
 
    # Run garbage collection and release ComObject
    $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($windowsInstallerObject) 
    [System.GC]::Collect()

    return $object  
} 