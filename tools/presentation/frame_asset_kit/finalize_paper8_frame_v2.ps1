param(
    [string]$Source = "assets/sprites/ui/frame/paper8_lab_v2/source_alpha",
    [string]$Output = "assets/sprites/ui/frame/paper8_lab_v2/runtime"
)

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing @'
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;

public static class Paper8V2Finalizer {
    private static readonly Color[] Palette = new Color[] {
        ColorTranslator.FromHtml("#1f244b"), ColorTranslator.FromHtml("#654053"),
        ColorTranslator.FromHtml("#a8605d"), ColorTranslator.FromHtml("#d1a67e"),
        ColorTranslator.FromHtml("#f6e79c"), ColorTranslator.FromHtml("#b6cf8e"),
        ColorTranslator.FromHtml("#60ae7b"), ColorTranslator.FromHtml("#3c6b64")
    };

    public static void Finalize(string sourcePath, string outputPath, int width, int height) {
        using (var source = new Bitmap(sourcePath)) {
            Rectangle bounds = FindVisibleBounds(source);
            using (var crop = source.Clone(bounds, PixelFormat.Format32bppArgb))
            using (var resized = Resize(crop, width, height)) {
                QuantizeAndBinarize(resized);
                EnforceGrid(resized, 2);
                resized.Save(outputPath, ImageFormat.Png);
            }
        }
    }

    private static Rectangle FindVisibleBounds(Bitmap image) {
        int minX = image.Width, minY = image.Height, maxX = -1, maxY = -1;
        for (int y = 0; y < image.Height; y++) {
            for (int x = 0; x < image.Width; x++) {
                if (image.GetPixel(x, y).A < 128) continue;
                minX = Math.Min(minX, x); minY = Math.Min(minY, y);
                maxX = Math.Max(maxX, x); maxY = Math.Max(maxY, y);
            }
        }
        if (maxX < minX || maxY < minY) throw new Exception("No visible pixels in " + image);
        minX = Math.Max(0, minX - 4); minY = Math.Max(0, minY - 4);
        maxX = Math.Min(image.Width - 1, maxX + 4); maxY = Math.Min(image.Height - 1, maxY + 4);
        return new Rectangle(minX, minY, maxX - minX + 1, maxY - minY + 1);
    }

    private static Bitmap Resize(Bitmap source, int width, int height) {
        var target = new Bitmap(width, height, PixelFormat.Format32bppArgb);
        using (var graphics = Graphics.FromImage(target)) {
            graphics.Clear(Color.Transparent);
            graphics.CompositingMode = CompositingMode.SourceCopy;
            graphics.InterpolationMode = InterpolationMode.NearestNeighbor;
            graphics.PixelOffsetMode = PixelOffsetMode.Half;
            graphics.SmoothingMode = SmoothingMode.None;
            graphics.DrawImage(source, new Rectangle(0, 0, width, height), 0, 0, source.Width, source.Height, GraphicsUnit.Pixel);
        }
        return target;
    }

    private static void QuantizeAndBinarize(Bitmap image) {
        for (int y = 0; y < image.Height; y++) {
            for (int x = 0; x < image.Width; x++) {
                Color pixel = image.GetPixel(x, y);
                if (pixel.A < 128) { image.SetPixel(x, y, Color.Transparent); continue; }
                int best = 0;
                int bestDistance = Int32.MaxValue;
                for (int index = 0; index < Palette.Length; index++) {
                    int dr = pixel.R - Palette[index].R;
                    int dg = pixel.G - Palette[index].G;
                    int db = pixel.B - Palette[index].B;
                    int distance = dr * dr + dg * dg + db * db;
                    if (distance < bestDistance) { bestDistance = distance; best = index; }
                }
                image.SetPixel(x, y, Color.FromArgb(255, Palette[best]));
            }
        }
    }

    private static void EnforceGrid(Bitmap image, int grid) {
        for (int y = 0; y < image.Height; y += grid) {
            for (int x = 0; x < image.Width; x += grid) {
                Color sample = image.GetPixel(x, y);
                for (int yy = y; yy < Math.Min(y + grid, image.Height); yy++) {
                    for (int xx = x; xx < Math.Min(x + grid, image.Width); xx++) image.SetPixel(xx, yy, sample);
                }
            }
        }
    }
}
'@

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
$sourcePath = (Resolve-Path (Join-Path $repoRoot $Source)).Path
$outputPath = Join-Path $repoRoot $Output
New-Item -ItemType Directory -Force -Path $outputPath | Out-Null

$assets = @(
    @{source="bezel-v2.png"; output="field_bezel_v2_910x900.png"; size=@(910,900); role="dynamic central bezel"},
    @{source="left-wing-v2.png"; output="left_wing_v2_200x900.png"; size=@(200,900); role="continuous left machine chassis"},
    @{source="right-wing-v2.png"; output="right_wing_v2_200x900.png"; size=@(200,900); role="continuous right machine chassis"},
    @{source="crt-stage-v2.png"; output="crt_stage_v2_176x108.png"; size=@(176,108); role="stage CRT"},
    @{source="crt-time-v2.png"; output="crt_time_v2_176x80.png"; size=@(176,80); role="time CRT with integrated gauge"},
    @{source="crt-genealogy-v2.png"; output="crt_genealogy_v2_176x400.png"; size=@(176,400); role="bottom-to-top genealogy CRT"},
    @{source="crt-score-v2.png"; output="crt_score_v2_176x112.png"; size=@(176,112); role="stage score CRT"},
    @{source="crt-item-v2.png"; output="crt_item_v2_176x300.png"; size=@(176,300); role="current item CRT"},
    @{source="crt-pause-v2.png"; output="crt_pause_v2_176x104.png"; size=@(176,104); role="pause and retry CRT"}
)

foreach ($asset in $assets) {
    [Paper8V2Finalizer]::Finalize(
        (Join-Path $sourcePath $asset.source),
        (Join-Path $outputPath $asset.output),
        $asset.size[0],
        $asset.size[1]
    )
}

$manifest = [ordered]@{
    schema = 2
    design_reference = "docs/design/mockups/drafts/frame-paper8-steampunk-lab-v1.png"
    authoring_canvas = @(1600, 900)
    palette = @("#1f244b", "#654053", "#a8605d", "#d1a67e", "#f6e79c", "#b6cf8e", "#60ae7b", "#3c6b64")
    assets = @($assets | ForEach-Object {
        [ordered]@{
            path = $_.output
            size = $_.size
            pixel_grid = 2
            binary_alpha = $true
            role = $_.role
        }
    })
}
$manifest | ConvertTo-Json -Depth 5 | Set-Content -Encoding utf8 (Join-Path (Split-Path $outputPath -Parent) "manifest.json")
Write-Output "PAPER8_FRAME_V2_FINALIZED assets=$($assets.Count) palette=8 output=$Output"
