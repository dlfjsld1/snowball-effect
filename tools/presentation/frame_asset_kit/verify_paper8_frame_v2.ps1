param(
    [string]$Kit = "assets/sprites/ui/frame/paper8_lab_v2"
)

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing @'
using System;
using System.Collections.Generic;
using System.Drawing;

public static class Paper8FrameV2Verifier {
    public static string Validate(string path, string[] palette, int grid) {
        var allowed = new HashSet<int>();
        foreach (string hex in palette) allowed.Add(ColorTranslator.FromHtml(hex).ToArgb() & 0x00ffffff);

        using (var image = new Bitmap(path)) {
            int visible = 0;
            for (int y = 0; y < image.Height; y++) {
                for (int x = 0; x < image.Width; x++) {
                    Color pixel = image.GetPixel(x, y);
                    if (pixel.A == 0) continue;
                    if (pixel.A != 255) throw new Exception(path + ": partial alpha at " + x + "," + y);
                    if (!allowed.Contains(pixel.ToArgb() & 0x00ffffff)) throw new Exception(path + ": off-palette pixel at " + x + "," + y);
                    visible++;
                }
            }
            if (visible == 0) throw new Exception(path + ": contains no visible pixels");
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
            return image.Width + "x" + image.Height + ":visible=" + visible;
        }
    }
}
'@

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
$kitPath = (Resolve-Path (Join-Path $repoRoot $Kit)).Path
$manifest = Get-Content -Raw -LiteralPath (Join-Path $kitPath "manifest.json") | ConvertFrom-Json

if ($manifest.schema -ne 2) { throw "Unexpected manifest schema" }
if (($manifest.authoring_canvas -join "x") -ne "1600x900") { throw "Unexpected authoring canvas" }
if ($manifest.palette.Count -ne 8) { throw "Expected exactly eight palette colors" }
if ($manifest.assets.Count -ne 9) { throw "Expected nine independently designed runtime assets" }

$validated = 0
foreach ($asset in $manifest.assets) {
    $assetPath = Join-Path $kitPath ("runtime\" + $asset.path)
    if (-not (Test-Path -LiteralPath $assetPath -PathType Leaf)) { throw "Missing asset: $($asset.path)" }
    $result = [Paper8FrameV2Verifier]::Validate($assetPath, [string[]]$manifest.palette, [int]$asset.pixel_grid)
    if (-not $result.StartsWith(($asset.size -join "x") + ":")) { throw "Unexpected size: $($asset.path) -> $result" }
    $validated++
}

Write-Output "PAPER8_FRAME_V2_VERIFIED assets=$validated palette=8 binary_alpha=true grid=2"
