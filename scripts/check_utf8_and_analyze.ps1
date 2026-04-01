param(
  [string]$Root = "."
)

$ErrorActionPreference = "Stop"

function Test-Utf8Strict {
  param([string]$Path)
  $bytes = [IO.File]::ReadAllBytes($Path)
  $utf8 = New-Object System.Text.UTF8Encoding($false, $true)
  [void]$utf8.GetString($bytes)
}

Write-Host "Checking UTF-8 for source files..."
$files = Get-ChildItem -Path $Root -Recurse -File -Include *.dart,*.md,*.yaml,*.yml,*.json
foreach ($file in $files) {
  Test-Utf8Strict -Path $file.FullName
}
Write-Host "UTF-8 check passed for $($files.Count) files."

Write-Host "Running flutter analyze..."
flutter analyze --no-pub
