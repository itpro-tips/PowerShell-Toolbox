# format is:
# <incremental id>
# 00:52:23,360 --> 00:52:26,160
Param(
    [Parameter(Mandatory = $false)]
    [string]$filename
)   

$filename = 'xxxx.srt'

$regex = '^\d+$|^\d\d:\d\d:\d\d,\d\d\d --> \d\d:\d\d:\d\d,\d\d\d$'

[System.Collections.Generic.List[PSObject]]$contentArray = @()

$baseName = [System.IO.Path]::GetfilenameWithoutExtension($filename)

Get-Content $file | ForEach-Object {
    if ($_ -match $regex) {
        # ignore the line}

    }
    else {
        $contentArray.Add($_)
    }
}

# export to the same path as the original file
$path = Split-Path $filename
$contentArray | Out-File "$path\$baseName-TextOnly.srt" -Encoding UTF8