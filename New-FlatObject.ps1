function New-FlatObject {
    Param 
    (
        [Parameter(Mandatory, ValueFromPipeline)]
        $object
    )

    process {
        $returnHashTable = [ordered]@{ }
        foreach ($prop in $object.psobject.Properties) {
            if ($prop.Value -is [array]) {
                #if (($prop.Value -ne $null) -and (-not $prop.Value.GetType().isValueType))
                $counter = 0
                foreach ($value in $prop.Value) {
                    if ($value -is [array]) {
                        #if (($prop.Value -ne $null) -and (-not $prop.Value.GetType().isValueType)) 
                        foreach ($recurse in (New-FlatObject -object $value).psobject.Properties) {
                            $returnHashTable["$($prop.Name)-$($recurse.Name)"] = $recurse.Value
                        }
                    }
                    $returnHashTable["$($prop.Name)-$counter"] = $value
                    $counter++
                }
            }
            else {
                $returnHashTable[$prop.Name] = $prop.Value
            }
        }
        return [PSCustomObject]$returnHashTable | Sort-Object @{Expression = { (($_.psobject.properties) | Measure-Object).count } } -Descending
    }
}