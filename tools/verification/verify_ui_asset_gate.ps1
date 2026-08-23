param(
    [string]$GodotPath,
    [string[]]$AssetPaths = @(
        "assets/sprites/ui/settings/volume_pipe_selected.png",
        "assets/sprites/ui/settings/value_popups_toggle_on.png",
        "assets/sprites/ui/settings/value_popups_toggle_off.png"
    ),
    [int]$RuntimeSeconds = 3
)

$ErrorActionPreference = "Stop"

function Resolve-GodotPath {
    param([string]$RequestedPath)

    if ($RequestedPath) {
        if (-not (Test-Path -LiteralPath $RequestedPath -PathType Leaf)) {
            throw "Godot executable not found: $RequestedPath"
        }
        return (Resolve-Path -LiteralPath $RequestedPath).Path
    }

    $candidate = Get-Command godot -ErrorAction SilentlyContinue
    if ($candidate) {
        return $candidate.Source
    }
    throw "Pass -GodotPath or add the Godot executable to PATH."
}

function Invoke-Godot {
    param(
        [string]$Executable,
        [string[]]$Arguments,
        [string]$Label
    )

    $output = & $Executable @Arguments 2>&1
    $exitCode = $LASTEXITCODE
    $output | ForEach-Object { Write-Output $_ }
    # PowerShell can expose a successful native invocation as `$null` when
    # editor output is captured. Only an explicit non-zero code is a failure.
    if ($null -ne $exitCode -and $exitCode -ne 0) {
        throw "$Label failed with exit code $exitCode"
    }

    # Keep environment-only editor warnings (certificate store/settings write)
    # out of the gate, but never accept an asset, scene, or script load failure.
    $fatalPatterns = @(
        "SCRIPT ERROR:",
        "Parser Error:",
        "Parse Error:",
        "Failed to load script",
        "Failed to preload",
        "Cannot open.*res://",
        "ERROR:.*res://"
    )
    $fatal = @($output | Where-Object {
        $line = [string]$_
        foreach ($pattern in $fatalPatterns) {
            if ($line -match $pattern) { return $true }
        }
        return $false
    })
    if ($fatal.Count -gt 0) {
        throw "$Label emitted a project load error: $($fatal -join [Environment]::NewLine)"
    }
}

function Assert-ImportedAssetCurrent {
    param(
        [string]$RepoRoot,
        [string]$AssetPath
    )

    $sourcePath = Join-Path $RepoRoot $AssetPath
    $importPath = "$sourcePath.import"
    if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
        throw "Missing UI asset: $AssetPath"
    }
    if (-not (Test-Path -LiteralPath $importPath -PathType Leaf)) {
        throw "Godot import file was not generated: $AssetPath.import"
    }

    $importText = Get-Content -Raw -LiteralPath $importPath
    $remap = [regex]::Match($importText, 'path="res://\.godot/imported/([^\"]+\.ctex)"')
    if (-not $remap.Success) {
        throw "Missing imported texture remap for: $AssetPath"
    }

    $importedTexture = Join-Path $RepoRoot (Join-Path ".godot/imported" $remap.Groups[1].Value)
    $importedMd5 = [System.IO.Path]::ChangeExtension($importedTexture, ".md5")
    if (-not (Test-Path -LiteralPath $importedTexture -PathType Leaf) -or -not (Test-Path -LiteralPath $importedMd5 -PathType Leaf)) {
        throw "Godot imported texture payload is missing for: $AssetPath"
    }

    $md5Text = Get-Content -Raw -LiteralPath $importedMd5
    $sourceMatch = [regex]::Match($md5Text, 'source_md5="([0-9a-fA-F]+)"')
    if (-not $sourceMatch.Success) {
        throw "Godot import checksum is missing for: $AssetPath"
    }
    $actualSourceMd5 = (Get-FileHash -LiteralPath $sourcePath -Algorithm MD5).Hash.ToLowerInvariant()
    if ($actualSourceMd5 -ne $sourceMatch.Groups[1].Value.ToLowerInvariant()) {
        throw "Stale Godot import for: $AssetPath"
    }

    Write-Output "UI_ASSET_IMPORT_OK path=$AssetPath md5=$actualSourceMd5"
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$godot = Resolve-GodotPath $GodotPath

# Starts a new editor process so import discovery and script registration occur
# before checksum inspection. It never removes a contributor's .godot cache.
Invoke-Godot -Executable $godot -Arguments @("--headless", "--path", $repoRoot, "--editor", "--quit") -Label "Godot import scan"
foreach ($assetPath in $AssetPaths) {
    Assert-ImportedAssetCurrent -RepoRoot $repoRoot -AssetPath $assetPath
}

# A separate fresh process loads project autoloads, Main, UI scenes, and their
# preloads in runtime order. This catches load-order failures missed by import.
Invoke-Godot -Executable $godot -Arguments @("--headless", "--path", $repoRoot, "--quit-after", $RuntimeSeconds.ToString()) -Label "Godot clean runtime smoke"

Write-Output "UI_ASSET_GATE_PASSED assets=$($AssetPaths.Count) runtime_seconds=$RuntimeSeconds"
