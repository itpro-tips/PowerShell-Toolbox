
# Define the input video file
$inputVideo = "xxx"   
$outputVideo = "xxx"
$startCut = 45  # Starting cut time in seconds
$endCut = 12    # Ending cut time in seconds

# Get video duration using FFmpeg
$duration = & ffmpeg -i $inputVideo 2>&1 | Select-String -Pattern "Duration: (\d+):(\d+):(\d+\.\d+)" | ForEach-Object { $_.Matches.Groups[1].Value, $_.Matches.Groups[2].Value, $_.Matches.Groups[3].Value -join ":" }

# Convert duration string to TimeSpan
$durationTimeSpan = [TimeSpan]::Parse($duration)

# Calculate new duration by subtracting 10 seconds (5 seconds from the start and 5 from the end)
$newDuration = $durationTimeSpan.Subtract([TimeSpan]::FromSeconds($startCut + $endCut))

# Format new duration for FFmpeg
$newDuration = "{0:00}:{1:00}:{2:00}.{3:000}" -f $newDuration.Hours, $newDuration.Minutes, $newDuration.Seconds, $newDuration.Milliseconds

# Use FFmpeg to cut the video
& ffmpeg -ss 00:00:$startCut -i $inputVideo -t $newDuration -c copy $outputVideo