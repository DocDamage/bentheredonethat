[CmdletBinding()]
param(
    [string]$GodotExecutable,
    [string]$PresetName = 'Windows Desktop',
    [string]$OutputDirectory
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$workspaceRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$projectRoot = [System.IO.Path]::GetFullPath((Join-Path $workspaceRoot 'game'))
if ([string]::IsNullOrWhiteSpace($GodotExecutable)) {
    $GodotExecutable = Join-Path $workspaceRoot 'Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe'
}
$GodotExecutable = [System.IO.Path]::GetFullPath($GodotExecutable)
if (-not (Test-Path -LiteralPath $GodotExecutable -PathType Leaf)) {
    throw "Godot executable not found: $GodotExecutable"
}
if (-not (Test-Path -LiteralPath (Join-Path $projectRoot 'export_presets.cfg') -PathType Leaf)) {
    throw "Missing tracked export preset: $(Join-Path $projectRoot 'export_presets.cfg')"
}
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $OutputDirectory = Join-Path $workspaceRoot 'output\windows'
}
$OutputDirectory = [System.IO.Path]::GetFullPath($OutputDirectory)
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$exportPath = Join-Path $OutputDirectory 'BenThereDoneThat.exe'

& $GodotExecutable --headless --path $projectRoot --export-release $PresetName $exportPath
if ($LASTEXITCODE -ne 0) {
    throw "Godot release export failed for preset '$PresetName'. Install the matching export templates and inspect the Godot output above."
}
if (-not (Test-Path -LiteralPath $exportPath -PathType Leaf)) {
    throw "Godot completed without producing the expected executable: $exportPath"
}

$hashAlgorithm = [System.Security.Cryptography.SHA256]::Create()
$fileStream = [System.IO.File]::OpenRead($exportPath)
try {
	$hash = ([System.BitConverter]::ToString($hashAlgorithm.ComputeHash($fileStream))).Replace('-', '')
} finally {
	$fileStream.Dispose()
	$hashAlgorithm.Dispose()
}
Write-Output "WINDOWS_RELEASE_BUILD_OK preset=$PresetName path=$exportPath bytes=$((Get-Item -LiteralPath $exportPath).Length) sha256=$hash"
