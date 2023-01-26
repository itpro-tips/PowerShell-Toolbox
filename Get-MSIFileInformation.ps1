function Get-MSIFileInformation {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo[]]$FilePath
    ) 
  
    # https://learn.microsoft.com/en-us/windows/win32/msi/installer-opendatabase
    $msiOpenDatabaseModeReadOnly = 0
    
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

    $summaryInfoHashTable = @{
        1  = 'Codepage'
        2  = 'Title'
        3  = 'Subject'
        4  = 'Author'
        5  = 'Keywords'
        6  = 'Comment'
        7  = 'Template'
        8  = 'LastAuthor'
        9  = 'RevisionNumber'
        10 = 'EditTime'
        11 = 'LastPrinted'
        12 = 'CreationDate'
        13 = 'LastSaved'
        14 = 'PageCount'
        15 = 'WordCount'
        16 = 'CharacterCount'
        18 = 'ApplicationName'
        19 = 'Security'
    }

    $properties = @('ProductVersion', 'ProductCode', 'ProductName', 'Manufacturer', 'ProductLanguage', 'UpgradeCode')
   
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

    # open read only    
    $msiDatabase = $windowsInstallerObject.GetType().InvokeMember('OpenDatabase', 'InvokeMethod', $null, $windowsInstallerObject, @($file.FullName, $msiOpenDatabaseModeReadOnly))

    foreach ($property in $properties) {
        $view = $null
        $query = "SELECT Value FROM Property WHERE Property = '$($property)'"
        $view = $msiDatabase.GetType().InvokeMember('OpenView', 'InvokeMethod', $null, $msiDatabase, ($query))
        $view.GetType().InvokeMember('Execute', 'InvokeMethod', $null, $view, $null)
        $record = $view.GetType().InvokeMember('Fetch', 'InvokeMethod', $null, $view, $null)

        try {
            $value = $record.GetType().InvokeMember('StringData', 'GetProperty', $null, $record, 1)
        }
        catch {
            Write-Verbose "Unable to get '$property' $($_.Exception.Message)"
            $value = ''
        }
        
        if ($property -eq 'ProductLanguage') {
            $value = "$value ($($productLanguageHashTable[$value]))"
        }

        $object | Add-Member -MemberType NoteProperty -Name $property -Value $value
    }

    $summaryInfo = $msiDatabase.GetType().InvokeMember('SummaryInformation', 'GetProperty', $null, $msiDatabase, $null)
    $summaryInfoPropertiesCount = $summaryInfo.GetType().InvokeMember('PropertyCount', 'GetProperty', $null, $summaryInfo, $null)

    (1..$summaryInfoPropertiesCount) | ForEach-Object {
        $value = $SummaryInfo.GetType().InvokeMember("Property", "GetProperty", $Null, $SummaryInfo, $_)

        if ($null -eq $value) {
            $object | Add-Member -MemberType NoteProperty -Name $summaryInfoHashTable[$_] -Value ''
        }
        else {
            $object | Add-Member -MemberType NoteProperty -Name $summaryInfoHashTable[$_] -Value $value
        }
    }

    #$msiDatabase.GetType().InvokeMember('Commit', 'InvokeMethod', $null, $msiDatabase, $null)
    $view.GetType().InvokeMember('Close', 'InvokeMethod', $null, $view, $null)
 
    # Run garbage collection and release ComObject
    $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($windowsInstallerObject) 
    [System.GC]::Collect()

    return $object  
} 