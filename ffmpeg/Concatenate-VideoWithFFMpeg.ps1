# Get the list of video files from a specific directory
$videoDirectory = "."
$videoFiles = Get-ChildItem -Path $videoDirectory -Filter "*.mp4"

# Create a temporary file to list all video files for ffmpeg
$tempFile = New-TemporaryFile
foreach ($videoFile in $videoFiles) {
    Add-Content -Path $tempFile.FullName -Value "file '$($videoFile.FullName)'"
}

# Output file name
$outputVideo = "outputVideo.mp4"

# Concatenate videos using ffmpeg
& ffmpeg -f concat -safe 0 -i $tempFile.FullName -c copy $outputVideo

# Clean up the temporary file
Remove-Item -Path $tempFile.FullName