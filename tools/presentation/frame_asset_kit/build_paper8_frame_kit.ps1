param(
    [string]$Source = "docs/design/mockups/drafts/frame-paper8-steampunk-lab-v1.png",
    [string]$Output = "assets/sprites/ui/frame/paper8_lab_v1"
)

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing @'
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;
using System.Runtime.InteropServices;

public static class Paper8FrameKit {
    private static readonly Color[] Palette = new Color[] {
        ColorTranslator.FromHtml("#1f244b"),
        ColorTranslator.FromHtml("#654053"),
        ColorTranslator.FromHtml("#a8605d"),
        ColorTranslator.FromHtml("#d1a67e"),
        ColorTranslator.FromHtml("#f6e79c"),
        ColorTranslator.FromHtml("#b6cf8e"),
        ColorTranslator.FromHtml("#60ae7b"),
        ColorTranslator.FromHtml("#3c6b64")
    };

    public static void BuildMaster(string sourcePath, string logicalPath, string masterPath) {
        using (var source = new Bitmap(sourcePath))
        using (var logical = Resize(source, 800, 450, InterpolationMode.NearestNeighbor)) {
            Quantize(logical);
            logical.Save(logicalPath, ImageFormat.Png);
            using (var master = Resize(logical, 1600, 900, InterpolationMode.NearestNeighbor)) {
                master.Save(masterPath, ImageFormat.Png);
            }
        }
    }

    public static void Crop(string masterPath, string outputPath, int x, int y, int width, int height, bool transparentVoid) {
        using (var master = new Bitmap(masterPath))
        using (var crop = master.Clone(new Rectangle(x, y, width, height), PixelFormat.Format32bppArgb)) {
            if (transparentVoid) MakeVoidTransparent(crop, 4);
            EnforcePixelGrid(crop, 2);
            crop.Save(outputPath, ImageFormat.Png);
        }
    }

    public static void CropEllipse(string masterPath, string outputPath, int x, int y, int width, int height) {
        using (var master = new Bitmap(masterPath))
        using (var crop = master.Clone(new Rectangle(x, y, width, height), PixelFormat.Format32bppArgb)) {
            double centerX = (width - 1) / 2.0;
            double centerY = (height - 1) / 2.0;
            double radiusX = width / 2.0;
            double radiusY = height / 2.0;
            for (int yy = 0; yy < height; yy++) {
                for (int xx = 0; xx < width; xx++) {
                    double dx = (xx - centerX) / radiusX;
                    double dy = (yy - centerY) / radiusY;
                    if (dx * dx + dy * dy > 1.0) crop.SetPixel(xx, yy, Color.Transparent);
                }
            }
            EnforcePixelGrid(crop, 2);
            crop.Save(outputPath, ImageFormat.Png);
        }
    }

    public static void ResizeFile(string sourcePath, string outputPath, int width, int height) {
        using (var source = new Bitmap(sourcePath))
        using (var resized = Resize(source, width, height, InterpolationMode.NearestNeighbor)) {
            EnforcePixelGrid(resized, 2);
            resized.Save(outputPath, ImageFormat.Png);
        }
    }

    public static void CreateFieldBezel(string masterPath, string outputPath) {
        using (var master = new Bitmap(masterPath))
        using (var bezel = master.Clone(new Rectangle(350, 0, 910, 900), PixelFormat.Format32bppArgb)) {
            for (int y = 50; y < 850; y++) {
                for (int x = 50; x < 860; x++) bezel.SetPixel(x, y, Color.Transparent);
            }
            EnforcePixelGrid(bezel, 2);
            bezel.Save(outputPath, ImageFormat.Png);
        }
    }

    public static void CreateWingBackplate(string outputPath) {
        using (var image = new Bitmap(152, 900, PixelFormat.Format32bppArgb)) {
            using (var graphics = Graphics.FromImage(image)) graphics.Clear(Palette[0]);
            for (int y = 0; y < 900; y += 2) {
                for (int x = 0; x < 152; x += 2) {
                    int paletteIndex = 0;
                    if (x < 4 || x >= 148) paletteIndex = 3;
                    else if (x < 8 || x >= 144) paletteIndex = 2;
                    else if (x < 12 || x >= 140) paletteIndex = 1;
                    if ((y < 6 || y >= 894) && x >= 8 && x < 144) paletteIndex = 3;
                    else if ((y < 10 || y >= 890) && x >= 12 && x < 140) paletteIndex = 2;
                    if (y % 96 < 4 && x >= 12 && x < 140) paletteIndex = 1;
                    image.SetPixel(x, y, Palette[paletteIndex]);
                    image.SetPixel(x + 1, y, Palette[paletteIndex]);
                    image.SetPixel(x, y + 1, Palette[paletteIndex]);
                    image.SetPixel(x + 1, y + 1, Palette[paletteIndex]);
                }
            }
            for (int y = 32; y < 884; y += 64) {
                for (int yy = y; yy < y + 4; yy++) {
                    for (int xx = 14; xx < 18; xx++) image.SetPixel(xx, yy, Palette[3]);
                    for (int xx = 134; xx < 138; xx++) image.SetPixel(xx, yy, Palette[3]);
                }
            }
            image.Save(outputPath, ImageFormat.Png);
        }
    }

    public static void CreateScanlineTile(string outputPath) {
        using (var image = new Bitmap(8, 4, PixelFormat.Format32bppArgb)) {
            using (var graphics = Graphics.FromImage(image)) graphics.Clear(Palette[7]);
            for (int x = 0; x < 8; x++) {
                image.SetPixel(x, 0, Palette[6]);
                image.SetPixel(x, 1, Palette[7]);
                image.SetPixel(x, 2, Palette[6]);
                image.SetPixel(x, 3, Palette[0]);
            }
            image.Save(outputPath, ImageFormat.Png);
        }
    }

    public static void CreateEnamelTile(string outputPath) {
        using (var image = new Bitmap(16, 16, PixelFormat.Format32bppArgb)) {
            using (var graphics = Graphics.FromImage(image)) graphics.Clear(Palette[1]);
            for (int x = 0; x < 16; x++) {
                image.SetPixel(x, 0, Palette[2]);
                image.SetPixel(x, 1, Palette[2]);
                image.SetPixel(x, 14, Palette[0]);
                image.SetPixel(x, 15, Palette[0]);
            }
            image.Save(outputPath, ImageFormat.Png);
        }
    }

    public static void CreateBolt(string outputPath) {
        using (var image = new Bitmap(8, 8, PixelFormat.Format32bppArgb)) {
            for (int y = 0; y < 8; y++) for (int x = 0; x < 8; x++) image.SetPixel(x, y, Color.Transparent);
            int[,] pixels = new int[,] {
                {3,0,0},{4,0,0},{2,1,0},{3,1,3},{4,1,3},{5,1,0},
                {1,2,0},{2,2,3},{3,2,1},{4,2,1},{5,2,3},{6,2,0},
                {0,3,0},{1,3,3},{2,3,1},{3,3,4},{4,3,0},{5,3,1},{6,3,3},{7,3,0},
                {0,4,0},{1,4,3},{2,4,1},{3,4,0},{4,4,4},{5,4,1},{6,4,3},{7,4,0},
                {1,5,0},{2,5,3},{3,5,1},{4,5,1},{5,5,3},{6,5,0},
                {2,6,0},{3,6,3},{4,6,3},{5,6,0},{3,7,0},{4,7,0}
            };
            for (int i = 0; i < pixels.GetLength(0); i++) image.SetPixel(pixels[i,0], pixels[i,1], Palette[pixels[i,2]]);
            image.Save(outputPath, ImageFormat.Png);
        }
    }

    private static Bitmap Resize(Bitmap source, int width, int height, InterpolationMode mode) {
        var target = new Bitmap(width, height, PixelFormat.Format32bppArgb);
        using (var graphics = Graphics.FromImage(target)) {
            graphics.CompositingMode = CompositingMode.SourceCopy;
            graphics.CompositingQuality = CompositingQuality.HighSpeed;
            graphics.InterpolationMode = mode;
            graphics.PixelOffsetMode = PixelOffsetMode.Half;
            graphics.SmoothingMode = SmoothingMode.None;
            graphics.DrawImage(source, new Rectangle(0, 0, width, height), 0, 0, source.Width, source.Height, GraphicsUnit.Pixel);
        }
        return target;
    }

    private static void Quantize(Bitmap bitmap) {
        var rect = new Rectangle(0, 0, bitmap.Width, bitmap.Height);
        var data = bitmap.LockBits(rect, ImageLockMode.ReadWrite, PixelFormat.Format32bppArgb);
        int bytes = Math.Abs(data.Stride) * bitmap.Height;
        byte[] buffer = new byte[bytes];
        Marshal.Copy(data.Scan0, buffer, 0, bytes);
        for (int y = 0; y < bitmap.Height; y++) {
            for (int x = 0; x < bitmap.Width; x++) {
                int offset = y * data.Stride + x * 4;
                int best = 0;
                int bestDistance = Int32.MaxValue;
                for (int p = 0; p < Palette.Length; p++) {
                    int db = buffer[offset] - Palette[p].B;
                    int dg = buffer[offset + 1] - Palette[p].G;
                    int dr = buffer[offset + 2] - Palette[p].R;
                    int distance = db * db + dg * dg + dr * dr;
                    if (distance < bestDistance) { bestDistance = distance; best = p; }
                }
                buffer[offset] = Palette[best].B;
                buffer[offset + 1] = Palette[best].G;
                buffer[offset + 2] = Palette[best].R;
                buffer[offset + 3] = 255;
            }
        }
        Marshal.Copy(buffer, 0, data.Scan0, bytes);
        bitmap.UnlockBits(data);
    }

    private static void MakeVoidTransparent(Bitmap bitmap, int radius) {
        var rect = new Rectangle(0, 0, bitmap.Width, bitmap.Height);
        var data = bitmap.LockBits(rect, ImageLockMode.ReadWrite, PixelFormat.Format32bppArgb);
        int bytes = Math.Abs(data.Stride) * bitmap.Height;
        byte[] buffer = new byte[bytes];
        Marshal.Copy(data.Scan0, buffer, 0, bytes);
        bool[] foreground = new bool[bitmap.Width * bitmap.Height];
        Color voidColor = Palette[0];
        for (int y = 0; y < bitmap.Height; y++) {
            for (int x = 0; x < bitmap.Width; x++) {
                int offset = y * data.Stride + x * 4;
                foreground[y * bitmap.Width + x] = buffer[offset] != voidColor.B || buffer[offset + 1] != voidColor.G || buffer[offset + 2] != voidColor.R;
            }
        }
        for (int y = 0; y < bitmap.Height; y++) {
            for (int x = 0; x < bitmap.Width; x++) {
                int index = y * bitmap.Width + x;
                if (foreground[index]) continue;
                bool nearForeground = false;
                for (int yy = Math.Max(0, y - radius); yy <= Math.Min(bitmap.Height - 1, y + radius) && !nearForeground; yy++) {
                    for (int xx = Math.Max(0, x - radius); xx <= Math.Min(bitmap.Width - 1, x + radius); xx++) {
                        if (foreground[yy * bitmap.Width + xx]) { nearForeground = true; break; }
                    }
                }
                if (!nearForeground) buffer[y * data.Stride + x * 4 + 3] = 0;
            }
        }
        Marshal.Copy(buffer, 0, data.Scan0, bytes);
        bitmap.UnlockBits(data);
    }

    private static void EnforcePixelGrid(Bitmap bitmap, int grid) {
        for (int y = 0; y < bitmap.Height; y += grid) {
            for (int x = 0; x < bitmap.Width; x += grid) {
                Color sample = bitmap.GetPixel(x, y);
                for (int yy = y; yy < Math.Min(y + grid, bitmap.Height); yy++) {
                    for (int xx = x; xx < Math.Min(x + grid, bitmap.Width); xx++) {
                        bitmap.SetPixel(xx, yy, sample);
                    }
                }
            }
        }
    }
}
'@

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
$sourcePath = (Resolve-Path (Join-Path $repoRoot $Source)).Path
$outputPath = Join-Path $repoRoot $Output
$masterDir = Join-Path $outputPath "master"
$modulesDir = Join-Path $outputPath "modules"
$bezelDir = Join-Path $outputPath "bezel"
$crtDir = Join-Path $outputPath "crt"
$machineryDir = Join-Path $outputPath "machinery"
$tilesDir = Join-Path $outputPath "tiles"
$runtimeDir = Join-Path $outputPath "runtime"

foreach ($directory in @($outputPath, $masterDir, $modulesDir, $bezelDir, $crtDir, $machineryDir, $tilesDir, $runtimeDir)) {
    New-Item -ItemType Directory -Force -Path $directory | Out-Null
}

$logicalPath = Join-Path $masterDir "frame_paper8_lab_source_800x450.png"
$masterPath = Join-Path $masterDir "frame_paper8_lab_master_1600x900.png"
[Paper8FrameKit]::BuildMaster($sourcePath, $logicalPath, $masterPath)

$assets = @(
    @{name="module_left_bank"; family="modules"; rect=@(0,0,370,900); transparent=$false; role="coarse left cabinet reference"},
    @{name="module_center_bezel"; family="modules"; rect=@(350,0,910,900); transparent=$false; role="coarse central frame reference"},
    @{name="module_right_bank"; family="modules"; rect=@(1230,0,370,900); transparent=$false; role="coarse right cabinet reference"},

    @{name="bezel_corner_top_left"; family="bezel"; rect=@(350,0,100,100); transparent=$true; role="top-left fixed corner"},
    @{name="bezel_edge_top"; family="bezel"; rect=@(430,10,760,70); transparent=$true; role="horizontal tile/stretch source"},
    @{name="bezel_corner_top_right"; family="bezel"; rect=@(1170,0,100,100); transparent=$true; role="top-right fixed corner"},
    @{name="bezel_edge_left"; family="bezel"; rect=@(350,80,80,740); transparent=$true; role="vertical tile/stretch source"},
    @{name="bezel_edge_right"; family="bezel"; rect=@(1180,80,80,740); transparent=$true; role="vertical tile/stretch source"},
    @{name="bezel_corner_bottom_left"; family="bezel"; rect=@(350,800,100,100); transparent=$true; role="bottom-left fixed corner"},
    @{name="bezel_edge_bottom"; family="bezel"; rect=@(430,830,760,70); transparent=$true; role="horizontal tile/stretch source"},
    @{name="bezel_corner_bottom_right"; family="bezel"; rect=@(1170,800,100,100); transparent=$true; role="bottom-right fixed corner"},

    @{name="crt_stage_module"; family="crt"; rect=@(24,20,280,200); transparent=$false; role="stage CRT module reference"},
    @{name="crt_time_module"; family="crt"; rect=@(28,208,260,110); transparent=$false; role="time CRT and gauge module reference"},
    @{name="crt_genealogy_module"; family="crt"; rect=@(44,310,270,470); transparent=$false; role="vertical genealogy CRT module reference"},
    @{name="crt_score_module"; family="crt"; rect=@(1310,20,280,220); transparent=$false; role="score CRT module reference"},
    @{name="crt_item_module"; family="crt"; rect=@(1310,284,280,390); transparent=$false; role="vertical item CRT module reference"},
    @{name="crt_pause_module"; family="crt"; rect=@(1240,734,350,166); transparent=$false; role="pause-retry CRT module reference"},
    @{name="crt_stage_glass_reference"; family="crt"; rect=@(52,46,220,150); transparent=$false; role="glass proportion reference; use scanline tile for runtime"},
    @{name="crt_time_glass_reference"; family="crt"; rect=@(54,230,112,62); transparent=$false; role="glass proportion reference; use scanline tile for runtime"},
    @{name="crt_genealogy_glass_reference"; family="crt"; rect=@(72,338,198,400); transparent=$false; role="glass proportion reference; use scanline tile for runtime"},
    @{name="crt_score_glass_reference"; family="crt"; rect=@(1340,48,214,150); transparent=$false; role="glass proportion reference; use scanline tile for runtime"},
    @{name="crt_item_glass_reference"; family="crt"; rect=@(1340,316,210,310); transparent=$false; role="glass proportion reference; use scanline tile for runtime"},
    @{name="crt_pause_glass_reference"; family="crt"; rect=@(1268,766,278,104); transparent=$false; role="glass proportion reference; use scanline tile for runtime"},

    @{name="machinery_left_outer_spine"; family="machinery"; rect=@(0,18,64,820); transparent=$true; role="outer pipe and bolt strip"},
    @{name="machinery_left_inner_spine"; family="machinery"; rect=@(278,0,100,900); transparent=$true; role="inner instrument spine"},
    @{name="machinery_right_inner_spine"; family="machinery"; rect=@(1220,0,112,730); transparent=$true; role="inner conduit spine"},
    @{name="machinery_right_outer_spine"; family="machinery"; rect=@(1530,18,70,860); transparent=$true; role="outer bolt and indicator strip"},
    @{name="machinery_left_bottom_console"; family="machinery"; rect=@(18,766,330,124); transparent=$true; role="vent and indicator console"},
    @{name="machinery_right_middle_console"; family="machinery"; rect=@(1310,634,270,110); transparent=$true; role="gauge and switch console"},
    @{name="machinery_round_gauge_left"; family="machinery"; rect=@(178,210,96,104); transparent=$true; shape="ellipse"; role="round gauge ornament"},
    @{name="machinery_round_gauge_right"; family="machinery"; rect=@(1430,650,92,86); transparent=$true; shape="ellipse"; role="round gauge ornament"},
    @{name="machinery_indicator_strip_left"; family="machinery"; rect=@(286,42,52,178); transparent=$true; role="vertical indicator strip"},
    @{name="machinery_indicator_strip_right"; family="machinery"; rect=@(1538,320,50,300); transparent=$true; role="vertical indicator strip"}
)

foreach ($asset in $assets) {
    $rect = $asset.rect
    $assetPath = Join-Path (Join-Path $outputPath $asset.family) ($asset.name + ".png")
    if ($asset.shape -eq "ellipse") {
        [Paper8FrameKit]::CropEllipse($masterPath, $assetPath, $rect[0], $rect[1], $rect[2], $rect[3])
    } else {
        [Paper8FrameKit]::Crop($masterPath, $assetPath, $rect[0], $rect[1], $rect[2], $rect[3], [bool]$asset.transparent)
    }
}

[Paper8FrameKit]::CreateScanlineTile((Join-Path $tilesDir "crt_scanline_tile_8x4.png"))
[Paper8FrameKit]::CreateEnamelTile((Join-Path $tilesDir "enamel_edge_tile_16.png"))
[Paper8FrameKit]::CreateBolt((Join-Path $tilesDir "bolt_8.png"))

[Paper8FrameKit]::CreateFieldBezel($masterPath, (Join-Path $runtimeDir "field_bezel_910x900.png"))
[Paper8FrameKit]::CreateWingBackplate((Join-Path $runtimeDir "wing_backplate_152x900.png"))

$runtimeAssets = @(
    @{name="crt_stage_132x94"; source="crt\crt_stage_module.png"; size=@(132,94); role="stage CRT at runtime size"},
    @{name="crt_time_132x64"; source="crt\crt_time_module.png"; size=@(132,64); role="time CRT at runtime size"},
    @{name="crt_genealogy_132x400"; source="crt\crt_genealogy_module.png"; size=@(132,400); role="vertical genealogy CRT at runtime size"},
    @{name="crt_score_132x104"; source="crt\crt_score_module.png"; size=@(132,104); role="stage score CRT at runtime size"},
    @{name="crt_item_132x230"; source="crt\crt_item_module.png"; size=@(132,230); role="active item CRT at runtime size"},
    @{name="crt_pause_132x94"; source="crt\crt_pause_module.png"; size=@(132,94); role="pause and retry CRT at runtime size"},
    @{name="machinery_left_console_132x52"; source="machinery\machinery_left_bottom_console.png"; size=@(132,52); role="left lower machinery filler"},
    @{name="machinery_right_console_132x54"; source="machinery\machinery_right_middle_console.png"; size=@(132,54); role="right middle machinery filler"}
)

foreach ($asset in $runtimeAssets) {
    $sourceAsset = Join-Path $outputPath $asset.source
    $targetAsset = Join-Path $runtimeDir ($asset.name + ".png")
    [Paper8FrameKit]::ResizeFile($sourceAsset, $targetAsset, $asset.size[0], $asset.size[1])
}

$manifest = [ordered]@{
    schema = 1
    source = $Source.Replace("\", "/")
    authoring_canvas = @(1600, 900)
    logical_source = @(800, 450)
    render_scale = 2
    palette = @("#1f244b", "#654053", "#a8605d", "#d1a67e", "#f6e79c", "#b6cf8e", "#60ae7b", "#3c6b64")
    import = [ordered]@{ filter = "nearest"; mipmaps = $false; repeat = "disabled except explicit tiles" }
    notes = @(
        "The AI image is a concept source, not a production bitmap.",
        "Master and crops are palette-quantized and aligned to a 2px authoring block.",
        "CRT glass reference crops are proportion references; runtime scanlines use tiles/crt_scanline_tile_8x4.png.",
        "Fine cutouts use transparent void with a four-pixel outline-preservation radius.",
        "Existing C4 runtime assets remain untouched until a separate adoption/wiring change is approved."
    )
    assets = @($assets | ForEach-Object {
        [ordered]@{
            path = ("{0}/{1}.png" -f $_.family, $_.name)
            family = $_.family
            source_rect = $_.rect
            size = @($_.rect[2], $_.rect[3])
            transparent_void = [bool]$_.transparent
            shape = if ($_.shape) { $_.shape } else { "rect" }
            pixel_grid = 2
            role = $_.role
        }
    }) + @(
        [ordered]@{path="runtime/field_bezel_910x900.png"; family="runtime"; size=@(910,900); transparent_void=$true; pixel_grid=2; role="full-height dynamic field bezel with transparent opening"},
        [ordered]@{path="runtime/wing_backplate_152x900.png"; family="runtime"; size=@(152,900); transparent_void=$false; pixel_grid=2; role="full-height narrow machine wing backplate"}
    ) + @($runtimeAssets | ForEach-Object {
        [ordered]@{
            path = ("runtime/{0}.png" -f $_.name)
            family = "runtime"
            size = $_.size
            transparent_void = $false
            pixel_grid = 2
            role = $_.role
        }
    }) + @(
        [ordered]@{path="tiles/crt_scanline_tile_8x4.png"; family="tiles"; size=@(8,4); transparent_void=$false; pixel_grid=1; role="uniform one-pixel CRT scanline tile"},
        [ordered]@{path="tiles/enamel_edge_tile_16.png"; family="tiles"; size=@(16,16); transparent_void=$false; pixel_grid=1; role="repeatable enamel edge material tile"},
        [ordered]@{path="tiles/bolt_8.png"; family="tiles"; size=@(8,8); transparent_void=$true; pixel_grid=1; role="small machine bolt ornament"}
    )
}

$manifest | ConvertTo-Json -Depth 8 | Set-Content -Encoding UTF8 (Join-Path $outputPath "manifest.json")
Write-Output "PAPER8_FRAME_KIT_BUILT output=$Output assets=$($manifest.assets.Count) master=1600x900 logical=800x450 palette=8"
