function Convert-ListToString {
    [CmdletBinding()]
    param (
        [Parameter()]
        $InputArray
    )

    $string = New-Object -TypeName System.Text.StringBuilder
    foreach ($object in $InputArray) {
        [void]$string.Append($object)
    }

    return $string.ToString()
}