<#
.SYNOPSIS
This script concatenates multiple CSV files into a single CSV file.

.DESCRIPTION
The Invoke-ConcatenateCSV.ps1 script concatenates multiple CSV files from a specified directory into a single CSV file, adding the source filename as the first column.
A oneliner exists:
Get-ChildItem -Filter *.csv | Select-Object -ExpandProperty FullName | Import-Csv | Export-Csv .\merged.csv -NoTypeInformation -Append
But we don't have the source file name in the output file and we can handle different properties in the CSV files.

.PARAMETER InputDirectory
Specifies the directory containing the CSV files to be concatenated.

.PARAMETER OutputFile
Specifies the path and name of the output CSV file that will contain the concatenated data.

.EXAMPLE
PS C:\> .\Invoke-ConcatenateCSV.ps1 -InputDirectory "C:\CSVFiles" -OutputFile "C:\Output\Combined.csv"

.NOTES
Author: Bastien Perez
Date: 2024/11/22
Version: 1.2
#>

function Invoke-ConcatenateCSV {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$InputDirectory = '.',
    
        [Parameter(Mandatory = $false)]
        [string]$OutputFile = 'Concatenated.csv',

        [Parameter(Mandatory = $false)]
        [string]$Delimiter = ';' ,

        [Parameter(Mandatory = $false)]
        [switch]$AddSourceFile
    )

    # Create empty array to store all data
    [System.Collections.Generic.List[Object]]$allData = @()
    # Get all CSV files in the specified directory
    $files = Get-ChildItem -Path $InputDirectory -Filter '*.csv'

    if ($files.Count -eq 0) {
        Write-Warning "No CSV files found in directory: $InputDirectory"
        return
    }

    foreach ($file in $files) {
        Write-Verbose "Processing file: $($file.Name)"
    
        try {
            # Import CSV content
            Write-Verbose "Importing CSV content from: $($file.FullName)"
            $csvContent = Import-Csv -Path $file.FullName -Delimiter $Delimiter
        
            # Add source filename to each row
            foreach ($row in $csvContent) {
                if ($AddSourceFile) {
                    Write-Verbose "Adding source file = $($file.Name) to the row"
                    $row.PSObject.Properties.Add('SourceFile', $file.Name)
                }
            
                $newRow = @{}
                # Add all other properties from the original row
                foreach ($property in $row.PSObject.Properties) {
                    Write-Verbose "Adding property: $($property.Name) = $($property.Value)"
                    $newRow[$property.Name] = $property.Value
                }
            
                # Add the modified row to our collection
                $allData.Add([PSCustomObject]$newRow)
            }
        }
        catch {
            Write-Warning "Error processing file $($file.Name): $_"
            continue
        }
    }

    if ($allData.Count -gt 0) {
        try {
            # Export all data to the output file
            $allData | Export-Csv -Path $OutputFile -NoTypeInformation -Encoding UTF8
            Write-Host "Successfully concatenated $($files.Count) files to: $OutputFile"
            Write-Host "Total rows: $($allData.Count)"
        }
        catch {
            Write-Error "Error writing output file: $_"
        }
    }
    else {
        Write-Warning 'No data was collected from the CSV files'
    }
}