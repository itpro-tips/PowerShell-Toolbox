
<#
feat: Add PowerShell script for automating typing

This commit adds a new PowerShell script, `Invoke-AutoType.ps1`, which allows for automating typing on both Windows and macOS operating systems. The script takes a string as input and types it character by character with a small delay between each character.

The script includes separate logic for Windows and macOS, utilizing the `System.Windows.Forms.SendKeys` class for Windows and AppleScript for macOS.

This feature will be useful for automating repetitive typing tasks, such as filling out forms or entering text in applications.
#>

# The string to type
$type = ''

$sleepMillisecondsBetweenCharacters = 1

# Sleep for 5 seconds before starting to type to go to the right window
Start-Sleep -Seconds 5

# If Operating System is Windows
if ($IsWindows) {
    # Loop over each character in the string
    foreach ($char in $type.ToCharArray()) {
        # Send the character
        [System.Windows.Forms.SendKeys]::SendWait($char)

        # Sleep for 5 milliseconds between characters
        Start-Sleep -Milliseconds $sleepMillisecondsBetweenCharacters
    }
}

if ($IsMacOS) {
    # Boucle sur chaque caractère de la chaîne
    foreach ($char in $type.ToCharArray()) {
        $script = @"
tell application "System Events"
    keystroke "$char"
end tell
"@
    }

    # Exécution du script AppleScript pour chaque caractère
    osascript -e $script

    # Pause de 5 millisecondes entre les caractères
    Start-Sleep -Milliseconds $sleepMillisecondsBetweenCharacters
}