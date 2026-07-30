[CmdletBinding()]
param(
    [string[]]$Scene,
    [switch]$AllSmoke,
    [string[]]$FixtureSave,
    [string]$GodotExecutable,
    [ValidateRange(1, 3600)]
    [int]$TimeoutSeconds = 300,
    [switch]$KeepArtifacts,
    [switch]$CleanArtifacts,
    [switch]$Windowed
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-NormalizedPath([string]$Path) {
    return [System.IO.Path]::GetFullPath($Path)
}

function Get-Sha256([string]$Path) {
    $hashAlgorithm = [System.Security.Cryptography.SHA256]::Create()
    $fileStream = [System.IO.File]::OpenRead($Path)
    try {
        return ([System.BitConverter]::ToString($hashAlgorithm.ComputeHash($fileStream))).Replace('-', '')
    }
    finally {
        $fileStream.Dispose()
        $hashAlgorithm.Dispose()
    }
}

function Assert-ChildPath([string]$Child, [string]$Parent, [string]$Label) {
    $normalizedChild = Resolve-NormalizedPath $Child
    $normalizedParent = (Resolve-NormalizedPath $Parent).TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
    $prefix = $normalizedParent + [System.IO.Path]::DirectorySeparatorChar
    if (-not $normalizedChild.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "$Label must stay below $normalizedParent; received $normalizedChild"
    }
    return $normalizedChild
}

$workspaceRoot = Resolve-NormalizedPath (Join-Path $PSScriptRoot '..')
$projectRoot = Resolve-NormalizedPath (Join-Path $workspaceRoot 'game')
$artifactRoot = Resolve-NormalizedPath (Join-Path $workspaceRoot 'test-artifacts')
if (-not (Test-Path -LiteralPath (Join-Path $projectRoot 'project.godot') -PathType Leaf)) {
    throw "Godot project not found at $projectRoot"
}
if ([string]::IsNullOrWhiteSpace($GodotExecutable)) {
    $GodotExecutable = Join-Path $workspaceRoot 'Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe'
}
$GodotExecutable = Resolve-NormalizedPath $GodotExecutable
if (-not (Test-Path -LiteralPath $GodotExecutable -PathType Leaf)) {
    throw "Godot executable not found: $GodotExecutable"
}

New-Item -ItemType Directory -Force -Path $artifactRoot | Out-Null
if ($CleanArtifacts) {
    $existingRuns = Get-ChildItem -LiteralPath $artifactRoot -Directory -ErrorAction SilentlyContinue
    foreach ($run in $existingRuns) {
        $validatedRun = Assert-ChildPath $run.FullName $artifactRoot 'Artifact cleanup target'
        Remove-Item -LiteralPath $validatedRun -Recurse -Force
    }
    Write-Output "ISOLATED_ARTIFACTS_CLEANED root=$artifactRoot"
    return
}

$projectNameMatch = Select-String -LiteralPath (Join-Path $projectRoot 'project.godot') -Pattern '^config/name="(.+)"$' | Select-Object -First 1
$projectName = if ($projectNameMatch) { $projectNameMatch.Matches[0].Groups[1].Value } else { 'BenThereDoneThat' }
$appDataRoot = if ([string]::IsNullOrWhiteSpace($env:APPDATA)) { [Environment]::GetFolderPath([Environment+SpecialFolder]::ApplicationData) } else { $env:APPDATA }
$productionUserData = Resolve-NormalizedPath (Join-Path $appDataRoot (Join-Path 'Godot\app_userdata' $projectName))
$runName = '{0:yyyyMMdd-HHmmss}-{1}' -f (Get-Date), ([guid]::NewGuid().ToString('N').Substring(0, 8))
$runRoot = Assert-ChildPath (Join-Path $artifactRoot $runName) $artifactRoot 'Isolated run directory'
$testAppData = Assert-ChildPath (Join-Path $runRoot 'appdata') $artifactRoot 'Isolated AppData directory'
$testUserHome = Assert-ChildPath (Join-Path $testAppData (Join-Path 'Godot\app_userdata' $projectName)) $artifactRoot 'Isolated Godot user directory'
if ($testUserHome.Equals($productionUserData, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to run tests against the production Godot user-data directory: $productionUserData"
}
New-Item -ItemType Directory -Force -Path $testAppData | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $runRoot 'logs') | Out-Null

foreach ($fixture in @($FixtureSave)) {
    if ([string]::IsNullOrWhiteSpace($fixture)) { continue }
    $fixturePath = Resolve-NormalizedPath $fixture
    if (-not (Test-Path -LiteralPath $fixturePath -PathType Leaf)) {
        throw "Fixture save does not exist: $fixturePath"
    }
    Copy-Item -LiteralPath $fixturePath -Destination (Join-Path $testUserHome (Split-Path -Leaf $fixturePath)) -Force
}

$scenesToRun = @()
if ($AllSmoke) {
    $scenesToRun += Get-ChildItem -LiteralPath (Join-Path $projectRoot 'tests') -Filter '*_smoke.tscn' -File |
        Sort-Object Name |
        ForEach-Object { 'res://tests/' + $_.Name }
}
foreach ($requestedScene in @($Scene)) {
    if ([string]::IsNullOrWhiteSpace($requestedScene)) { continue }
    $scenesToRun += if ($requestedScene.StartsWith('res://')) { $requestedScene } else { 'res://' + $requestedScene.TrimStart([char[]]@('/', '\')) }
}
$scenesToRun = @($scenesToRun | Select-Object -Unique)
if ($scenesToRun.Count -eq 0) {
    throw 'Specify -AllSmoke or at least one -Scene path.'
}

$productionSentinel = Join-Path $productionUserData 'save_slot_1.json'
$sentinelBefore = if (Test-Path -LiteralPath $productionSentinel -PathType Leaf) { Get-Sha256 $productionSentinel } else { $null }
$priorUserHome = $env:GODOT_USER_HOME
$priorAppData = $env:APPDATA
# Godot 4.7 on Windows resolves user:// through APPDATA. GODOT_USER_HOME is
# retained as a diagnostic/compatibility marker, while APPDATA provides the
# actual per-process isolation.
$env:GODOT_USER_HOME = $testUserHome
$env:APPDATA = $testAppData
$failed = @()
try {
    foreach ($scenePath in $scenesToRun) {
        $safeName = ($scenePath -replace '^res://', '' -replace '[\\/:*?"<>|]', '_')
        $logPath = Join-Path $runRoot ('logs\' + $safeName + '.log')
        $arguments = @('--path', $projectRoot, '--audio-driver', 'Dummy', '--log-file', $logPath, '--scene', $scenePath)
        if (-not $Windowed) { $arguments = @('--headless') + $arguments }
        Write-Output "ISOLATED_RUN scene=$scenePath user_home=$testUserHome"
        $argumentLine = ($arguments | ForEach-Object { '"' + $_ + '"' }) -join ' '
        $processInfo = New-Object System.Diagnostics.ProcessStartInfo
        $processInfo.FileName = $GodotExecutable
        $processInfo.Arguments = $argumentLine
        $processInfo.WorkingDirectory = $projectRoot
        $processInfo.UseShellExecute = $false
        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = $processInfo
        if (-not $process.Start()) {
            throw "Could not start Godot for $scenePath"
        }
        if (-not $process.WaitForExit($TimeoutSeconds * 1000)) {
            & taskkill.exe /PID $process.Id /T /F | Out-Null
            $process.Dispose()
            $failed += "$scenePath (timed out after $TimeoutSeconds seconds)"
            continue
        }
        $exitCode = $process.ExitCode
        $process.Dispose()
        if ($exitCode -ne 0) {
            $failed += "$scenePath (exit $exitCode)"
        }
    }
}
finally {
    if ($null -eq $priorUserHome) { Remove-Item Env:GODOT_USER_HOME -ErrorAction SilentlyContinue } else { $env:GODOT_USER_HOME = $priorUserHome }
    if ($null -eq $priorAppData) { Remove-Item Env:APPDATA -ErrorAction SilentlyContinue } else { $env:APPDATA = $priorAppData }
}

$sentinelAfter = if (Test-Path -LiteralPath $productionSentinel -PathType Leaf) { Get-Sha256 $productionSentinel } else { $null }
if ($sentinelBefore -ne $sentinelAfter) {
    throw "Production save sentinel changed during an isolated run: $productionSentinel"
}
if ($failed.Count -gt 0) {
    throw "Isolated Godot run failed: $($failed -join '; '). Logs and fixture data are retained at $runRoot"
}

Write-Output "ISOLATED_RUN_OK scenes=$($scenesToRun.Count) artifacts=$runRoot sentinel=$([bool]$sentinelBefore)"
if (-not $KeepArtifacts) {
    Write-Output 'Artifacts are retained by default for reproducibility. Remove them explicitly with -CleanArtifacts.'
}
