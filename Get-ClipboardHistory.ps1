<#

from: https://gist.githubusercontent.com/mutaguchi/019ad33e156637585a22a656d8fd3f46/raw/38cba2de838e52004e75c400c254877a4f8e6ad3/ClipboardHistory.ps1
Get-ClipboardHistory: Get the texts contained in the clipboard history.
Clear-ClipboardHistory: Clearing the clipboard history

In PowerShell 7.1 or later, use the following command to install Microsoft.Windows.SDK.NET.Ref with administrative privileges.
Find-Package -ProviderName NuGet -Source https://www.nuget.org/api/v2 -Name Microsoft.Windows.SDK.NET.Ref | Install-Package
#>

$needsSDK = $PSVersionTable.PSVersion -ge "7.1.0" 

if ($needsSDK) {
    $sdkLib = Split-Path -Path (Get-Package -ProviderName NuGet -Name Microsoft.Windows.SDK.NET.Ref | Select-Object -ExpandProperty Source) -Parent | Join-Path -ChildPath "\lib"
    Add-Type -Path "$sdkLib\Microsoft.Windows.SDK.NET.dll"
    Add-Type -Path "$sdkLib\WinRT.Runtime.dll"
}
else {
    Add-Type -AssemblyName System.Runtime.WindowsRuntime
}

$clipboard = if ($needsSDK) {
    [Windows.ApplicationModel.DataTransfer.Clipboard]
}
else {
    [Windows.ApplicationModel.DataTransfer.Clipboard, Windows.ApplicationModel.DataTransfer, ContentType = WindowsRuntime]
}
get-
function await {
    param($AsyncTask, [Type]$ResultType)

    $method = [WindowsRuntimeSystemExtensions].GetMember("GetAwaiter") | Where-Object { $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' } | Select-Object -First 1  $method.MakeGenericMethod($ResultType).Invoke($null, @($AsyncTask)).GetResult()
}

function Get-ClipboardHistory {
    $type = if ($script:needsSDK) {
        [Windows.ApplicationModel.DataTransfer.ClipboardHistoryItemsResult]
    }
    else {
        [Windows.ApplicationModel.DataTransfer.ClipboardHistoryItemsResult, Windows.ApplicationModel.DataTransfer, ContentType = WindowsRuntime]
    }

    $result = await $script:clipboard::GetHistoryItemsAsync() $type
    
    $outItems = if ($script:needsSDK) {
        @($result.Items.AdditionalTypeData.Values)
    }
    else {
        @($result.Items)
    }

    $outItems | Where-Object { $_.Content.Contains("Text") } | ForEach-Object {
        await $_.Content.GetTextAsync() ([string])
    }
}

function Clear-ClipboardHistory {
    $null = $script:clipboard::ClearHistory()
}