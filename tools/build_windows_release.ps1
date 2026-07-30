[CmdletBinding()]
param(
    [string]$GodotExecutable,
    [string]$PresetName = 'Windows Desktop',
    [string]$OutputDirectory,
    [string]$SigningCertificatePath = $env:BTDT_SIGNING_CERTIFICATE_PATH,
    [string]$SigningCertificatePassword = $env:BTDT_SIGNING_CERTIFICATE_PASSWORD,
    [switch]$RequireSignature
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
$manifestPath = Join-Path $OutputDirectory 'release-manifest.json'
$launchLogPath = Join-Path $OutputDirectory 'release-launch.log'
$launchErrorLogPath = Join-Path $OutputDirectory 'release-launch-error.log'

& $GodotExecutable --headless --path $projectRoot --export-release $PresetName $exportPath
if ($LASTEXITCODE -ne 0) {
    throw "Godot release export failed for preset '$PresetName'. Install the matching export templates and inspect the Godot output above."
}
if (-not (Test-Path -LiteralPath $exportPath -PathType Leaf)) {
    throw "Godot completed without producing the expected executable: $exportPath"
}

$signed = $false
if (-not [string]::IsNullOrWhiteSpace($SigningCertificatePath)) {
    $SigningCertificatePath = [System.IO.Path]::GetFullPath($SigningCertificatePath)
    if (-not (Test-Path -LiteralPath $SigningCertificatePath -PathType Leaf)) {
        throw "Signing certificate not found: $SigningCertificatePath"
    }
    $signTool = Get-Command signtool.exe -ErrorAction SilentlyContinue
    if ($null -eq $signTool) {
        throw 'signtool.exe is required when BTDT_SIGNING_CERTIFICATE_PATH is set.'
    }
    & $signTool.Source sign /fd SHA256 /td SHA256 /tr 'http://timestamp.digicert.com' /f $SigningCertificatePath /p $SigningCertificatePassword $exportPath
    if ($LASTEXITCODE -ne 0) {
        throw 'Authenticode signing failed.'
    }
    & $signTool.Source verify /pa /all $exportPath
    if ($LASTEXITCODE -ne 0) {
        throw 'Authenticode signature verification failed.'
    }
    $signed = $true
} elseif ($RequireSignature) {
    throw 'A signed public release requires BTDT_SIGNING_CERTIFICATE_PATH and BTDT_SIGNING_CERTIFICATE_PASSWORD.'
}

$userDataDirectory = Join-Path $OutputDirectory 'isolated-user-data'
New-Item -ItemType Directory -Force -Path $userDataDirectory | Out-Null
$launchEnvironment = @{
    APPDATA = $userDataDirectory
    LOCALAPPDATA = $userDataDirectory
}
$launch = Start-Process -FilePath $exportPath -ArgumentList @('--headless', '--quit-after', '30') -Environment $launchEnvironment -PassThru -Wait -NoNewWindow -RedirectStandardOutput $launchLogPath -RedirectStandardError $launchErrorLogPath
if ($launch.ExitCode -ne 0) {
    throw "Exported release launch failed with exit code $($launch.ExitCode)."
}
$launchOutput = (Get-Content -LiteralPath $launchLogPath -Raw -ErrorAction SilentlyContinue) + "`n" + (Get-Content -LiteralPath $launchErrorLogPath -Raw -ErrorAction SilentlyContinue)
if ($launchOutput -match '(?i)script error|parse error|mcp bridge') {
    throw 'Exported release launch log contains a forbidden runtime or development-only marker.'
}

$hashAlgorithm = [System.Security.Cryptography.SHA256]::Create()
$fileStream = [System.IO.File]::OpenRead($exportPath)
try {
	$hash = ([System.BitConverter]::ToString($hashAlgorithm.ComputeHash($fileStream))).Replace('-', '')
} finally {
	$fileStream.Dispose()
	$hashAlgorithm.Dispose()
}
$godotVersion = (& $GodotExecutable --version | Select-Object -First 1).Trim()
$commit = (& git -C $workspaceRoot rev-parse HEAD).Trim()
$versionContract = Get-Content -LiteralPath (Join-Path $projectRoot 'ben_rpg\release\release_contract.json') -Raw | ConvertFrom-Json
$manifest = [ordered]@{
    schemaVersion = 1
    commit = $commit
    product = $versionContract.product.name
    publisher = $versionContract.product.publisher
    version = $versionContract.product.shippingVersion
    platform = 'windows-x86_64'
    preset = $PresetName
    godotVersion = $godotVersion
    path = $exportPath
    bytes = (Get-Item -LiteralPath $exportPath).Length
    sha256 = $hash
    signed = $signed
    launchVerified = $true
    launchFrames = 30
}
$manifest | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $manifestPath -Encoding utf8
Write-Output "WINDOWS_RELEASE_BUILD_OK preset=$PresetName path=$exportPath bytes=$($manifest.bytes) sha256=$hash signed=$signed launch=true manifest=$manifestPath"
