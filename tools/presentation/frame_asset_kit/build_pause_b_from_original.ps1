Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
$basePath = Join-Path $root 'assets\sprites\ui\frame\paper8_lab_v2\runtime\crt_pause_v2_176x104.png'
$referencePath = Join-Path $root 'assets\sprites\ui\frame\paper8_lab_v2\source_alpha\crt_pause_b_v2.png'
$targetPath = Join-Path $root 'assets\sprites\ui\frame\paper8_lab_v2\runtime\crt_pause_b_v2_176x104.png'

$base = [System.Drawing.Bitmap]::FromFile($basePath)
$reference = [System.Drawing.Bitmap]::FromFile($referencePath)
$target = New-Object System.Drawing.Bitmap(176, 104, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$graphics = [System.Drawing.Graphics]::FromImage($target)
$graphics.DrawImageUnscaled($base, 0, 0)
$graphics.Dispose()
$base.Dispose()

$referenceScaled = New-Object System.Drawing.Bitmap(176, 104, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$graphics = [System.Drawing.Graphics]::FromImage($referenceScaled)
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$graphics.DrawImage($reference, [System.Drawing.Rectangle]::new(0, 0, 176, 104))
$graphics.Dispose()
$reference.Dispose()

$void = [System.Drawing.Color]::FromArgb(255, 24, 31, 48)
for ($y = 30; $y -le 90; $y++) {
    for ($x = 14; $x -le 161; $x++) {
        $pixel = $target.GetPixel($x, $y)
        if ($pixel.G -gt $pixel.R + 18 -and $pixel.G -gt $pixel.B + 8) {
            $target.SetPixel($x, $y, $void)
        }
    }
}

function Copy-ReferencePixel([int]$x, [int]$y) {
    $referencePixel = $referenceScaled.GetPixel($x, $y)
    if ($referencePixel.A -gt 0) {
        $target.SetPixel($x, $y, $referencePixel)
    }
}

for ($y = 20; $y -le 91; $y++) {
    for ($x = 14; $x -le 162; $x++) {
        $leftDistance = [Math]::Sqrt(($x - 50) * ($x - 50) + ($y - 55) * ($y - 55))
        $rightDistance = [Math]::Sqrt(($x - 126) * ($x - 126) + ($y - 55) * ($y - 55))
        if ($leftDistance -le 34 -or $rightDistance -le 34) {
            Copy-ReferencePixel $x $y
        }
    }
}

# The two central bolts are part of the selected B design and bridge the buttons into one original CRT housing.
for ($y = 46; $y -le 65; $y++) {
    for ($x = 84; $x -le 92; $x++) {
        Copy-ReferencePixel $x $y
    }
}

$referenceScaled.Dispose()
$target.Save($targetPath, [System.Drawing.Imaging.ImageFormat]::Png)
$target.Dispose()
Write-Output "PAUSE_B_ORIGINAL_HOUSING_EDIT base=crt_pause_v2 reference=crt_pause_b_v2 target=crt_pause_b_v2_176x104"
