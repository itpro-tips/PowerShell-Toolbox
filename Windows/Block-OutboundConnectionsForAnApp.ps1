# block outbound connections for an .exe path
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, HelpMessage = "The path to the application")]
    [String]$ApplicationPath
)


# Test if application exists
if (-not (Test-Path $ApplicationPath)) {
    Write-Warning "'$ApplicationPath' does not exist"
    return
}

$fileInfo = Get-Item $ApplicationPath
$appName = $fileInfo.Name
$productName = $fileInfo.VersionInfo.ProductName
$string = ""

if (-not [string]::IsNullOrEmpty($productName)) {
    $string = $productName.Trim()
}
else {
    $string = $fileInfo.BaseName.Trim()
}

if (-not [string]::IsNullOrEmpty($appName)) {
    $string = $string + " - " + $appName
}

$ruleName = "[Custom] Block outbound access for $string ($applicationPath)"

# Test if the rule already exists
try {
    $ruleExists = [boolean](Get-NetFirewallRule -Direction Outbound  | Where-Object { $_.DisplayName -eq "$ruleName" })
}
catch {
    Write-Warning "Failed to check if the rule already exists $($_.Exception.Message)."
}

if ($ruleExists) {
    Write-Warning "The rule '$ruleName' already exists"
    return
}

# create a new rule
try {
    Write-Host -ForegroundColor Cyan "Creating a new rule to block outbound connections for the application: $ApplicationPath"
    New-NetFirewallRule -DisplayName $ruleName -Direction Outbound -Program $ApplicationPath -Action Block -Enabled True -ErrorAction Stop
    Write-Host -ForegroundColor Green "The rule has been created successfully."
}
catch {
    Write-Host "Failed to create the rule. The rule may already exist."
}