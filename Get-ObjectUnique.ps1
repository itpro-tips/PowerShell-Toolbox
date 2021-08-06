function Get-ObjectUnique {
    [CmdletBinding()]
    param (
        [Parameter()]
        $InputArray
    )

    return [System.Collections.Generic.HashSet[string]]$InputArray
}