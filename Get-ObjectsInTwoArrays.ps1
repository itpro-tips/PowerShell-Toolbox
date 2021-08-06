function Get-ObjectsInTwoArrays {
    [CmdletBinding()]
    param (
        [Parameter()]
        $Array,
        [Parameter()]
        $ArrayToCompare,
        [Parameter(Mandatory)]
        [ValidateSet('In', 'NotIn')]
        $ComparisonMethod,
        [Parameter(Mandatory)]
        [ValidateSet('String', 'int','PSObject')]
        $ObjectType
    )
    
    if($ObjectType -eq 'String'){
        $arrayIndex = [System.Collections.Generic.HashSet[String]]$Array
    }
    elseif($ObjectType -eq 'int'){
        $arrayIndex = [System.Collections.Generic.HashSet[int]]$Array
    }
    elseif($ObjectType -eq 'PSObject'){
        $arrayIndex = [System.Collections.Generic.HashSet[PSObject]]$Array
    }
    
    [System.Collections.Generic.List[PSObject]]$res = @()

    if ($ComparisonMethod -eq 'In') {
        foreach ($object in $ArrayToCompare) {
            if ($arrayIndex.Contains($object)) {
                $res.Add($object)
            }
        }
    }
    elseif ($ComparisonMethod -eq 'NotIn') {
        foreach ($object in $ArrayToCompare) {
            if (-not($arrayIndex.Contains($object))) {
                $res.Add($object)
            }
        }
    }

    Write-Host "$($res.count) $ComparisonMethod two arrays"
    return $res
}