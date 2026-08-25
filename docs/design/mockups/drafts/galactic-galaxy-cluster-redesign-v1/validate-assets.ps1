$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Add-Type -AssemblyName System.Drawing

$source = @'
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Runtime.InteropServices;

public sealed class PngMetrics
{
    public int Width;
    public int Height;
    public string PixelFormat = "";
    public int AlphaMin = 255;
    public int AlphaMax = 0;
    public int EdgeMaxAlpha;
    public long NonZeroAlphaPixels;
    public long OpaquePixels;
    public long PartialAlphaPixels;
    public long TransparentRgbNonZeroPixels;
    public int UniqueVisibleRgbColors;
    public int MinX = Int32.MaxValue;
    public int MinY = Int32.MaxValue;
    public int MaxX = -1;
    public int MaxY = -1;
    public int Components8;
    public int Components4;
    public int LargestComponentPixels;
}

public static class PngAudit
{
    private static Bitmap Clone32(string path, out string originalFormat)
    {
        using (var source = new Bitmap(path))
        {
            originalFormat = source.PixelFormat.ToString();
            return source.Clone(new Rectangle(0, 0, source.Width, source.Height), PixelFormat.Format32bppArgb);
        }
    }

    private static byte[] ReadPixels(Bitmap bitmap, ImageLockMode mode, out BitmapData data)
    {
        data = bitmap.LockBits(new Rectangle(0, 0, bitmap.Width, bitmap.Height), mode, PixelFormat.Format32bppArgb);
        var bytes = new byte[Math.Abs(data.Stride) * bitmap.Height];
        Marshal.Copy(data.Scan0, bytes, 0, bytes.Length);
        return bytes;
    }

    private static int Offset(int x, int y, int stride)
    {
        return y * stride + x * 4;
    }

    private static void LabelComponents(bool[] mask, int width, int height, out int count, out int largest, out int[] labels)
    {
        labels = new int[mask.Length];
        for (int i = 0; i < labels.Length; i++) labels[i] = -1;
        var queue = new int[mask.Length];
        count = 0;
        largest = 0;

        for (int start = 0; start < mask.Length; start++)
        {
            if (!mask[start] || labels[start] >= 0) continue;
            int head = 0;
            int tail = 0;
            int size = 0;
            queue[tail++] = start;
            labels[start] = count;

            while (head < tail)
            {
                int index = queue[head++];
                size++;
                int x = index % width;
                int y = index / width;

                for (int dy = -1; dy <= 1; dy++)
                {
                    int ny = y + dy;
                    if (ny < 0 || ny >= height) continue;
                    for (int dx = -1; dx <= 1; dx++)
                    {
                        if (dx == 0 && dy == 0) continue;
                        int nx = x + dx;
                        if (nx < 0 || nx >= width) continue;
                        int next = ny * width + nx;
                        if (mask[next] && labels[next] < 0)
                        {
                            labels[next] = count;
                            queue[tail++] = next;
                        }
                    }
                }
            }

            if (size > largest) largest = size;
            count++;
        }
    }

    private static int CountComponents4(bool[] mask, int width, int height)
    {
        var visited = new bool[mask.Length];
        var queue = new int[mask.Length];
        int count = 0;
        int[] dx = { 1, -1, 0, 0 };
        int[] dy = { 0, 0, 1, -1 };

        for (int start = 0; start < mask.Length; start++)
        {
            if (!mask[start] || visited[start]) continue;
            int head = 0;
            int tail = 0;
            queue[tail++] = start;
            visited[start] = true;

            while (head < tail)
            {
                int index = queue[head++];
                int x = index % width;
                int y = index / width;
                for (int direction = 0; direction < 4; direction++)
                {
                    int nx = x + dx[direction];
                    int ny = y + dy[direction];
                    if (nx < 0 || nx >= width || ny < 0 || ny >= height) continue;
                    int next = ny * width + nx;
                    if (mask[next] && !visited[next])
                    {
                        visited[next] = true;
                        queue[tail++] = next;
                    }
                }
            }
            count++;
        }
        return count;
    }

    public static long Normalize(string path, int alphaThreshold)
    {
        string originalFormat;
        using (var bitmap = Clone32(path, out originalFormat))
        {
            BitmapData data;
            byte[] pixels = ReadPixels(bitmap, ImageLockMode.ReadWrite, out data);
            int stride = Math.Abs(data.Stride);
            bool[] mask = new bool[bitmap.Width * bitmap.Height];
            long cleared = 0;

            for (int y = 0; y < bitmap.Height; y++)
            {
                for (int x = 0; x < bitmap.Width; x++)
                {
                    int offset = Offset(x, y, stride);
                    int alpha = pixels[offset + 3];
                    if (alpha <= alphaThreshold)
                    {
                        if (alpha > 0 || pixels[offset] != 0 || pixels[offset + 1] != 0 || pixels[offset + 2] != 0) cleared++;
                        pixels[offset] = 0;
                        pixels[offset + 1] = 0;
                        pixels[offset + 2] = 0;
                        pixels[offset + 3] = 0;
                    }
                    else
                    {
                        mask[y * bitmap.Width + x] = true;
                    }
                }
            }

            int componentCount;
            int largestSize;
            int[] labels;
            LabelComponents(mask, bitmap.Width, bitmap.Height, out componentCount, out largestSize, out labels);
            int largestLabel = -1;
            if (componentCount > 0)
            {
                var sizes = new int[componentCount];
                for (int i = 0; i < labels.Length; i++) if (labels[i] >= 0) sizes[labels[i]]++;
                for (int i = 0; i < sizes.Length; i++) if (sizes[i] == largestSize) { largestLabel = i; break; }
            }

            for (int y = 0; y < bitmap.Height; y++)
            {
                for (int x = 0; x < bitmap.Width; x++)
                {
                    int index = y * bitmap.Width + x;
                    int offset = Offset(x, y, stride);
                    if (pixels[offset + 3] > 0 && labels[index] != largestLabel)
                    {
                        pixels[offset] = 0;
                        pixels[offset + 1] = 0;
                        pixels[offset + 2] = 0;
                        pixels[offset + 3] = 0;
                        cleared++;
                    }
                }
            }

            Marshal.Copy(pixels, 0, data.Scan0, pixels.Length);
            bitmap.UnlockBits(data);

            string temp = path + ".normalized.png";
            bitmap.Save(temp, ImageFormat.Png);
            bitmap.Dispose();
            File.Replace(temp, path, null);
            return cleared;
        }
    }

    public static PngMetrics Analyze(string path)
    {
        string originalFormat;
        using (var bitmap = Clone32(path, out originalFormat))
        {
            BitmapData data;
            byte[] pixels = ReadPixels(bitmap, ImageLockMode.ReadOnly, out data);
            int stride = Math.Abs(data.Stride);
            bitmap.UnlockBits(data);

            var result = new PngMetrics { Width = bitmap.Width, Height = bitmap.Height, PixelFormat = originalFormat };
            var colors = new HashSet<int>();
            var mask = new bool[bitmap.Width * bitmap.Height];

            for (int y = 0; y < bitmap.Height; y++)
            {
                for (int x = 0; x < bitmap.Width; x++)
                {
                    int offset = Offset(x, y, stride);
                    int blue = pixels[offset];
                    int green = pixels[offset + 1];
                    int red = pixels[offset + 2];
                    int alpha = pixels[offset + 3];
                    result.AlphaMin = Math.Min(result.AlphaMin, alpha);
                    result.AlphaMax = Math.Max(result.AlphaMax, alpha);
                    if (x == 0 || y == 0 || x == bitmap.Width - 1 || y == bitmap.Height - 1)
                        result.EdgeMaxAlpha = Math.Max(result.EdgeMaxAlpha, alpha);

                    if (alpha == 0)
                    {
                        if (blue != 0 || green != 0 || red != 0) result.TransparentRgbNonZeroPixels++;
                        continue;
                    }

                    mask[y * bitmap.Width + x] = true;
                    result.NonZeroAlphaPixels++;
                    if (alpha == 255) result.OpaquePixels++; else result.PartialAlphaPixels++;
                    result.MinX = Math.Min(result.MinX, x);
                    result.MinY = Math.Min(result.MinY, y);
                    result.MaxX = Math.Max(result.MaxX, x);
                    result.MaxY = Math.Max(result.MaxY, y);
                    colors.Add((red << 16) | (green << 8) | blue);
                }
            }

            int[] labels;
            LabelComponents(mask, bitmap.Width, bitmap.Height, out result.Components8, out result.LargestComponentPixels, out labels);
            result.Components4 = CountComponents4(mask, bitmap.Width, bitmap.Height);
            result.UniqueVisibleRgbColors = colors.Count;
            if (result.NonZeroAlphaPixels == 0)
            {
                result.MinX = result.MinY = result.MaxX = result.MaxY = -1;
            }
            return result;
        }
    }

    public static bool NearestEqual(string candidatePath, string inspectionPath)
    {
        using (var candidate = new Bitmap(candidatePath))
        using (var inspection = new Bitmap(inspectionPath))
        {
            if (candidate.Width != 16 || candidate.Height != 16 || inspection.Width != 256 || inspection.Height != 256) return false;
            for (int y = 0; y < 256; y++)
                for (int x = 0; x < 256; x++)
                    if (candidate.GetPixel(x / 16, y / 16).ToArgb() != inspection.GetPixel(x, y).ToArgb()) return false;
            return true;
        }
    }

    public static int CountColor(string path, int argb)
    {
        using (var bitmap = new Bitmap(path))
        {
            int count = 0;
            for (int y = 0; y < bitmap.Height; y++)
                for (int x = 0; x < bitmap.Width; x++)
                    if (bitmap.GetPixel(x, y).ToArgb() == argb) count++;
            return count;
        }
    }
}
'@

Add-Type -TypeDefinition $source -ReferencedAssemblies System.Drawing

$dir = $PSScriptRoot
$masterSpecs = @(
    @{ Id = 'A'; File = 'master-a-triad-cluster.png' },
    @{ Id = 'B'; File = 'master-b-spiral-swarm-crown.png' },
    @{ Id = 'C'; File = 'master-c-colliding-web.png' }
)

$candidateSpecs = @(
    @{ Id = 'A'; File = 'candidate-a-triad-cluster-16.png'; Inspection = 'inspection-a-triad-cluster-256.png'; CoreColor = '#FFF6D2'; ExpectedCores = 3 },
    @{ Id = 'B'; File = 'candidate-b-spiral-swarm-crown-16.png'; Inspection = 'inspection-b-spiral-swarm-crown-256.png'; CoreColor = '#F9FFFF'; ExpectedCores = 5 },
    @{ Id = 'C'; File = 'candidate-c-colliding-web-16.png'; Inspection = 'inspection-c-colliding-web-256.png'; CoreColor = '#FFF7E3'; ExpectedCores = 5 }
)

$masterResults = foreach ($spec in $masterSpecs) {
    $path = Join-Path $dir $spec.File
    $cleared = [PngAudit]::Normalize($path, 1)
    $metrics = [PngAudit]::Analyze($path)
    [ordered]@{
        id = $spec.Id
        file = $spec.File
        width = $metrics.Width
        height = $metrics.Height
        pixel_format = $metrics.PixelFormat
        alpha_min = $metrics.AlphaMin
        alpha_max = $metrics.AlphaMax
        opaque_pixels = $metrics.OpaquePixels
        partial_alpha_pixels = $metrics.PartialAlphaPixels
        nonzero_alpha_pixels = $metrics.NonZeroAlphaPixels
        visible_rgb_colors = $metrics.UniqueVisibleRgbColors
        bounds = @($metrics.MinX, $metrics.MinY, $metrics.MaxX, $metrics.MaxY)
        margins_ltrb = @($metrics.MinX, $metrics.MinY, ($metrics.Width - 1 - $metrics.MaxX), ($metrics.Height - 1 - $metrics.MaxY))
        edge_max_alpha = $metrics.EdgeMaxAlpha
        transparent_rgb_nonzero = $metrics.TransparentRgbNonZeroPixels
        components_8 = $metrics.Components8
        components_4 = $metrics.Components4
        largest_component_pixels = $metrics.LargestComponentPixels
        normalized_pixels = $cleared
    }
}

$candidateResults = foreach ($spec in $candidateSpecs) {
    $path = Join-Path $dir $spec.File
    $inspection = Join-Path $dir $spec.Inspection
    $metrics = [PngAudit]::Analyze($path)
    $core = [System.Drawing.ColorTranslator]::FromHtml($spec.CoreColor)
    $corePixels = [PngAudit]::CountColor($path, $core.ToArgb())
    [ordered]@{
        id = $spec.Id
        file = $spec.File
        inspection = $spec.Inspection
        width = $metrics.Width
        height = $metrics.Height
        pixel_format = $metrics.PixelFormat
        alpha_min = $metrics.AlphaMin
        alpha_max = $metrics.AlphaMax
        opaque_pixels = $metrics.OpaquePixels
        partial_alpha_pixels = $metrics.PartialAlphaPixels
        visible_rgb_colors = $metrics.UniqueVisibleRgbColors
        bounds = @($metrics.MinX, $metrics.MinY, $metrics.MaxX, $metrics.MaxY)
        margins_ltrb = @($metrics.MinX, $metrics.MinY, ($metrics.Width - 1 - $metrics.MaxX), ($metrics.Height - 1 - $metrics.MaxY))
        edge_max_alpha = $metrics.EdgeMaxAlpha
        transparent_rgb_nonzero = $metrics.TransparentRgbNonZeroPixels
        components_8 = $metrics.Components8
        components_4 = $metrics.Components4
        core_pixels = $corePixels
        expected_cores = $spec.ExpectedCores
        core_check = ($corePixels -eq $spec.ExpectedCores)
        nearest_16x_check = [PngAudit]::NearestEqual($path, $inspection)
    }
}

$report = [ordered]@{
    schema = 1
    generated_at = [DateTime]::UtcNow.ToString('o')
    contract = [ordered]@{
        global_level = 11
        galactic_local_level = 1
        radius = 8
        diameter = 16
        galactic_chain = @(10, 11, 12, 13, 14)
    }
    masters = @($masterResults)
    candidates = @($candidateResults)
}

$json = $report | ConvertTo-Json -Depth 8
[System.IO.File]::WriteAllText((Join-Path $dir 'validation.json'), $json, [System.Text.UTF8Encoding]::new($false))
$json
