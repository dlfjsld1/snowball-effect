param(
    [string]$AssetRoot = "assets/backgrounds/stage_world"
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
$root = (Resolve-Path (Join-Path $repoRoot $AssetRoot)).Path
$manifest = Get-Content -Raw -LiteralPath (Join-Path $root "manifest.json") | ConvertFrom-Json

if ($manifest.schema -ne 1) { throw "Unexpected manifest schema" }
if (($manifest.authoring_canvas -join "x") -ne "1600x900") { throw "Unexpected authoring canvas" }
if (($manifest.logical_canvas -join "x") -ne "800x450") { throw "Unexpected logical canvas" }
if ($manifest.assets.Count -ne 3) { throw "Expected three Stage World backgrounds" }

$validated = 0
foreach ($asset in $manifest.assets) {
    $path = Join-Path $root ("runtime\" + $asset.path)
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing background: $($asset.path)" }
    $allowed = @{}
    foreach ($hex in $asset.palette) {
        $allowed[[System.Drawing.ColorTranslator]::FromHtml($hex).ToArgb() -band 0x00ffffff] = $true
    }

    $image = [System.Drawing.Bitmap]::FromFile($path)
    try {
        if ($image.Width -ne 1600 -or $image.Height -ne 900) { throw "Unexpected size: $($asset.path)" }
        for ($y = 0; $y -lt 900; $y += 2) {
            for ($x = 0; $x -lt 1600; $x += 2) {
                $sample = $image.GetPixel($x, $y)
                if ($sample.A -ne 255) { throw "Non-opaque background pixel: $($asset.path) $x,$y" }
                if (-not $allowed.ContainsKey($sample.ToArgb() -band 0x00ffffff)) { throw "Off-palette pixel: $($asset.path) $x,$y" }
                $argb = $sample.ToArgb()
                if ($image.GetPixel($x + 1, $y).ToArgb() -ne $argb -or
                    $image.GetPixel($x, $y + 1).ToArgb() -ne $argb -or
                    $image.GetPixel($x + 1, $y + 1).ToArgb() -ne $argb) {
                    throw "Broken 2x2 grid: $($asset.path) $x,$y"
                }
            }
        }
    } finally {
        $image.Dispose()
    }
    $validated++
}

Write-Output "STAGE_WORLD_BACKGROUNDS_VERIFIED assets=$validated canvas=1600x900 grid=2"
