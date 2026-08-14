param(
    [string]$AssetRoot = "assets/backgrounds/stage_world"
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
$root = (Resolve-Path (Join-Path $repoRoot $AssetRoot)).Path
$sourceRoot = Join-Path $root "source"
$runtimeRoot = Join-Path $root "runtime"
New-Item -ItemType Directory -Force $runtimeRoot | Out-Null

$palettes = @{
    ground = @("#1f285d", "#4b849a", "#98d8b1", "#ecf2cb")
    planetary = @(
        "#050718", "#0b1235", "#0000cd", "#4169e1", "#228b22", "#32cd32", "#8b4513", "#f0fff0",
        "#696969", "#808080", "#a8a9a9", "#dcdcdc", "#ffe4b5", "#f8f8ff", "#708090", "#e6e6fa",
        "#a52a2a", "#d2691e", "#ff8c00", "#cd853f", "#f0e68c", "#ffee00", "#ffa500", "#ff4500", "#b22222", "#fffacd"
    )
    galactic = @(
        "#050718", "#0b1235", "#174c56", "#1b7f79", "#2aa69a", "#5fd0c4",
        "#4b3d8f", "#6a54b8", "#a47be8", "#d8d5ff", "#f2f5ff"
    )
}

function Get-NearestColor([System.Drawing.Color]$color, [System.Drawing.Color[]]$palette) {
    $best = $palette[0]
    $bestDistance = [double]::MaxValue
    foreach ($candidate in $palette) {
        $dr = [int]$color.R - [int]$candidate.R
        $dg = [int]$color.G - [int]$candidate.G
        $db = [int]$color.B - [int]$candidate.B
        $distance = $dr * $dr + $dg * $dg + $db * $db
        if ($distance -lt $bestDistance) {
            $bestDistance = $distance
            $best = $candidate
        }
    }
    return $best
}

$assets = @()
foreach ($stage in @("ground", "planetary", "galactic")) {
    $sourcePath = Join-Path $sourceRoot "$stage-stage-world-source.png"
    $runtimeName = "background_${stage}_1600x900.png"
    $runtimePath = Join-Path $runtimeRoot $runtimeName
    $palette = [System.Drawing.Color[]]($palettes[$stage] | ForEach-Object { [System.Drawing.ColorTranslator]::FromHtml($_) })

    $source = [System.Drawing.Bitmap]::FromFile($sourcePath)
    try {
        $cropHeight = [int][Math]::Round($source.Width * 9.0 / 16.0)
        $cropY = if ($stage -eq "ground") { 0 } else { [int](($source.Height - $cropHeight) / 2) }
        $logical = New-Object System.Drawing.Bitmap 800, 450
        try {
            $graphics = [System.Drawing.Graphics]::FromImage($logical)
            try {
                $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
                $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
                $graphics.DrawImage($source, (New-Object System.Drawing.Rectangle 0, 0, 800, 450), (New-Object System.Drawing.Rectangle 0, $cropY, $source.Width, $cropHeight), [System.Drawing.GraphicsUnit]::Pixel)
            } finally {
                $graphics.Dispose()
            }

            $runtime = New-Object System.Drawing.Bitmap 1600, 900
            try {
                for ($y = 0; $y -lt 450; $y++) {
                    for ($x = 0; $x -lt 800; $x++) {
                        $color = Get-NearestColor $logical.GetPixel($x, $y) $palette
                        $runtime.SetPixel($x * 2, $y * 2, $color)
                        $runtime.SetPixel($x * 2 + 1, $y * 2, $color)
                        $runtime.SetPixel($x * 2, $y * 2 + 1, $color)
                        $runtime.SetPixel($x * 2 + 1, $y * 2 + 1, $color)
                    }
                }
                $runtime.Save($runtimePath, [System.Drawing.Imaging.ImageFormat]::Png)
            } finally {
                $runtime.Dispose()
            }
        } finally {
            $logical.Dispose()
        }
    } finally {
        $source.Dispose()
    }

    $assets += @{
        stage = $stage
        path = $runtimeName
        size = @(1600, 900)
        pixel_grid = 2
        palette = $palettes[$stage]
    }
}

$manifest = @{
    schema = 1
    authoring_canvas = @(1600, 900)
    logical_canvas = @(800, 450)
    assets = $assets
}
$manifest | ConvertTo-Json -Depth 6 | Set-Content -Encoding UTF8 (Join-Path $root "manifest.json")
Write-Output "STAGE_WORLD_BACKGROUNDS_FINALIZED assets=3 canvas=1600x900 grid=2"
