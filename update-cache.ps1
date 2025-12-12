$cachePath = Join-Path $env:USERPROFILE ".claude\plugins\cache\postsharp-engineering"
$srcPath = $PSScriptRoot

if (Test-Path $cachePath) {
    Remove-Item -Recurse -Force $cachePath
}

foreach ($pluginDir in Get-ChildItem -Directory (Join-Path $srcPath "plugins")) {
    $pluginJson = Join-Path $pluginDir.FullName ".claude-plugin\plugin.json"
    if (Test-Path $pluginJson) {
        $plugin = Get-Content $pluginJson | ConvertFrom-Json
        $destPath = Join-Path $cachePath "$($plugin.name)\$($plugin.version)"
        Copy-Item -Recurse $pluginDir.FullName $destPath
        Write-Host "Installed $($plugin.name) v$($plugin.version)"
    }
}

Write-Host "Cache updated at $cachePath"
