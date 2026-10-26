Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem
$siteDir = Join-Path $PSScriptRoot "site"
$zipPath = Join-Path $PSScriptRoot "site.zip"
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
$z = [IO.Compression.ZipFile]::Open($zipPath, 'Create')
Get-ChildItem $siteDir -Recurse -File | ForEach-Object {
  $rel = $_.FullName.Substring($siteDir.Length + 1).Replace('\','/')
  [void][IO.Compression.ZipFileExtensions]::CreateEntryFromFile($z, $_.FullName, $rel)
}
$z.Dispose()
Write-Host "Done: $zipPath"
