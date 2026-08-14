param(
    [string]$Kit = "assets/sprites/ui/frame/paper8_lab_v1"
)

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing @'
using System;
using System.Collections.Generic;
using System.Drawing;

public static class Paper8FrameKitVerifier {
    public static string Validate(string path, string[] palette, int grid, bool expectTransparent) {
        var allowed = new HashSet<int>();
        foreach (string hex in palette) allowed.Add(ColorTranslator.FromHtml(hex).ToArgb() & 0x00ffffff);

        using (var image = new Bitmap(path)) {
            int transparent = 0;
            int opaque = 0;
            for (int y = 0; y < image.Height; y++) {
                for (int x = 0; x < image.Width; x++) {
                    Color pixel = image.GetPixel(x, y);
                    if (pixel.A == 0) { transparent++; continue; }
                    if (pixel.A != 255) throw new Exception(path + ": partial alpha at " + x + "," + y);
                    if (!allowed.Contains(pixel.ToArgb() & 0x00ffffff)) throw new Exception(path + ": off-palette pixel at " + x + "," + y);
                    opaque++;
                }
            }

            if (expectTransparent && transparent == 0) throw new Exception(path + ": expected transparent void");
            if (opaque == 0) throw new Exception(path + ": contains no visible pixels");

            if (grid > 1) {
                if (image.Width % grid != 0 || image.Height % grid != 0) throw new Exception(path + ": size is not grid-aligned");
                for (int y = 0; y < image.Height; y += grid) {
                    for (int x = 0; x < image.Width; x += grid) {
                        int sample = image.GetPixel(x, y).ToArgb();
                        for (int yy = y; yy < y + grid; yy++) {
                            for (int xx = x; xx < x + grid; xx++) {
                                if (image.GetPixel(xx, yy).ToArgb() != sample) throw new Exception(path + ": broken pixel grid at " + x + "," + y);
                            }
                        }
                    }
                }
            }
            return image.Width + "x" + image.Height + ":opaque=" + opaque + ":transparent=" + transparent;
        }
    }
}
'@

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
$kitPath = (Resolve-Path (Join-Path $repoRoot $Kit)).Path
$manifestPath = Join-Path $kitPath "manifest.json"
$manifest = Get-Content -Raw -LiteralPath $manifestPath | ConvertFrom-Json

if (($manifest.authoring_canvas -join "x") -ne "1600x900") { throw "Unexpected authoring canvas" }
if (($manifest.logical_source -join "x") -ne "800x450") { throw "Unexpected logical source" }
if ($manifest.palette.Count -ne 8) { throw "Expected exactly eight palette colors" }
if ($manifest.assets.Count -ne 46) { throw "Expected 46 split and runtime assets" }

$validated = 0
foreach ($asset in $manifest.assets) {
    $assetPath = Join-Path $kitPath $asset.path
    if (-not (Test-Path -LiteralPath $assetPath -PathType Leaf)) { throw "Missing asset: $($asset.path)" }
    $expectedSize = $asset.size -join "x"
    $result = [Paper8FrameKitVerifier]::Validate(
        $assetPath,
        [string[]]$manifest.palette,
        [int]$asset.pixel_grid,
        [bool]$asset.transparent_void
    )
    if (-not $result.StartsWith($expectedSize + ":")) { throw "Unexpected size: $($asset.path) -> $result" }
    $validated++
}

$masterResult = [Paper8FrameKitVerifier]::Validate(
    (Join-Path $kitPath "master\frame_paper8_lab_master_1600x900.png"),
    [string[]]$manifest.palette,
    2,
    $false
)

Write-Output "PAPER8_FRAME_KIT_VERIFIED assets=$validated palette=8 master=$masterResult"
