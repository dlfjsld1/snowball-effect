$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Add-Type -AssemblyName System.Drawing

$outputDir = $PSScriptRoot
$transparent = [System.Drawing.Color]::FromArgb(0, 0, 0, 0)

function Convert-HexColor {
    param([Parameter(Mandatory = $true)][string]$Hex)

    $value = $Hex.TrimStart('#')
    return [System.Drawing.Color]::FromArgb(
        255,
        [Convert]::ToInt32($value.Substring(0, 2), 16),
        [Convert]::ToInt32($value.Substring(2, 2), 16),
        [Convert]::ToInt32($value.Substring(4, 2), 16)
    )
}

function Set-Pixels {
    param(
        [Parameter(Mandatory = $true)][System.Drawing.Bitmap]$Bitmap,
        [Parameter(Mandatory = $true)][System.Drawing.Color]$Color,
        [Parameter(Mandatory = $true)][object[]]$Points
    )

    foreach ($point in $Points) {
        $Bitmap.SetPixel([int]$point[0], [int]$point[1], $Color)
    }
}

function New-Inspection {
    param(
        [Parameter(Mandatory = $true)][System.Drawing.Bitmap]$Source,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $scale = 16
    $inspection = [System.Drawing.Bitmap]::new(256, 256, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    try {
        for ($y = 0; $y -lt 16; $y++) {
            for ($x = 0; $x -lt 16; $x++) {
                $color = $Source.GetPixel($x, $y)
                for ($dy = 0; $dy -lt $scale; $dy++) {
                    for ($dx = 0; $dx -lt $scale; $dx++) {
                        $inspection.SetPixel(($x * $scale) + $dx, ($y * $scale) + $dy, $color)
                    }
                }
            }
        }
        $inspection.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $inspection.Dispose()
    }
}

function New-Candidate {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][hashtable]$Palette,
        [Parameter(Mandatory = $true)][object[]]$Layers
    )

    $candidate = [System.Drawing.Bitmap]::new(16, 16, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    try {
        for ($y = 0; $y -lt 16; $y++) {
            for ($x = 0; $x -lt 16; $x++) {
                $candidate.SetPixel($x, $y, $transparent)
            }
        }

        foreach ($layer in $Layers) {
            Set-Pixels -Bitmap $candidate -Color $Palette[$layer.Color] -Points $layer.Points
        }

        $candidatePath = Join-Path $outputDir "candidate-$Name-16.png"
        $inspectionPath = Join-Path $outputDir "inspection-$Name-256.png"
        $candidate.Save($candidatePath, [System.Drawing.Imaging.ImageFormat]::Png)
        New-Inspection -Source $candidate -Path $inspectionPath
    }
    finally {
        $candidate.Dispose()
    }
}

$paletteA = @{
    N = Convert-HexColor '#101536'
    B = Convert-HexColor '#2947B8'
    V = Convert-HexColor '#8157E6'
    C = Convert-HexColor '#61DDF5'
    P = Convert-HexColor '#B98BEA'
    G = Convert-HexColor '#F1C45F'
    W = Convert-HexColor '#FFF6D2'
}

$layersA = @(
    @{ Color = 'N'; Points = @(
        @(8,6), @(8,7), @(7,8), @(8,8), @(9,8), @(6,9), @(7,9), @(8,9), @(9,9), @(10,9),
        @(7,10), @(8,10), @(9,10), @(8,11), @(5,14)
    ) },
    @{ Color = 'B'; Points = @(
        @(8,1), @(6,2), @(9,2), @(5,4), @(11,4), @(5,5), @(11,5), @(6,6), @(10,6), @(7,7), @(9,7),
        @(5,8), @(11,8), @(3,9), @(6,9), @(9,9), @(12,9), @(2,11), @(8,11), @(14,11), @(2,12), @(8,12), @(14,12),
        @(3,13), @(7,13), @(9,13), @(13,13), @(4,14), @(6,14), @(10,14), @(12,14)
    ) },
    @{ Color = 'V'; Points = @(
        @(7,2), @(8,2), @(6,3), @(7,3), @(9,3), @(10,4), @(6,4), @(7,5), @(9,5), @(8,6), @(9,6),
        @(4,9), @(5,9), @(10,9), @(11,9), @(3,10), @(4,10), @(6,10), @(10,10), @(12,10), @(13,10),
        @(3,11), @(7,11), @(9,11), @(13,11), @(4,12), @(6,12), @(10,12), @(12,12), @(5,13), @(11,13)
    ) },
    @{ Color = 'C'; Points = @(
        @(6,2), @(9,2), @(6,5), @(10,5), @(7,6), @(9,6),
        @(4,8), @(11,8), @(3,9), @(6,9), @(9,9), @(12,9), @(3,12), @(7,12), @(9,12), @(13,12), @(4,13), @(10,13), @(6,14), @(11,14)
    ) },
    @{ Color = 'P'; Points = @(
        @(7,3), @(9,4), @(5,10), @(6,11), @(4,12), @(10,10), @(12,11), @(10,12)
    ) },
    @{ Color = 'G'; Points = @(
        @(7,4), @(8,5), @(4,11), @(5,12), @(10,11), @(11,12)
    ) },
    @{ Color = 'W'; Points = @(
        @(8,4), @(5,11), @(11,11)
    ) }
)

$paletteB = @{
    N = Convert-HexColor '#111638'
    I = Convert-HexColor '#29399A'
    V = Convert-HexColor '#7248C8'
    L = Convert-HexColor '#BC83F1'
    C = Convert-HexColor '#24D2ED'
    P = Convert-HexColor '#BDF9FF'
    W = Convert-HexColor '#F9FFFF'
}

$layersB = @(
    @{ Color = 'N'; Points = @(
        @(6,4), @(7,4), @(8,4), @(9,4), @(5,5), @(6,5), @(7,5), @(8,5), @(9,5), @(10,5),
        @(5,6), @(6,6), @(7,6), @(8,6), @(9,6), @(10,6), @(6,7), @(7,7), @(8,7), @(9,7), @(10,7),
        @(5,8), @(6,8), @(7,8), @(8,8), @(9,8), @(10,8), @(6,9), @(7,9), @(8,9), @(9,9), @(10,9),
        @(5,10), @(6,10), @(7,10), @(8,10), @(9,10), @(10,10), @(11,10), @(6,11), @(7,11), @(8,11), @(9,11), @(10,11),
        @(4,3), @(11,3), @(3,4), @(12,11)
    ) },
    @{ Color = 'I'; Points = @(
        @(3,2), @(4,2), @(10,2), @(11,2), @(2,4), @(6,4), @(9,4), @(13,4), @(2,5), @(5,5), @(10,5), @(13,5),
        @(3,6), @(4,6), @(11,6), @(12,6), @(5,7), @(10,7), @(5,9), @(10,9), @(2,10), @(4,9), @(12,10), @(14,12),
        @(2,11), @(6,11), @(10,11), @(14,13), @(3,12), @(6,12), @(11,13), @(13,14)
    ) },
    @{ Color = 'V'; Points = @(
        @(5,3), @(12,3), @(6,4), @(9,4), @(5,5), @(10,5), @(4,6), @(11,6),
        @(3,9), @(4,9), @(5,10), @(6,11), @(5,12), @(4,13),
        @(11,10), @(12,10), @(13,11), @(14,12), @(13,13), @(12,14)
    ) },
    @{ Color = 'L'; Points = @(
        @(3,3), @(5,4), @(4,5), @(10,3), @(12,4), @(11,5),
        @(3,10), @(5,11), @(4,12), @(11,11), @(13,12), @(12,13)
    ) },
    @{ Color = 'C'; Points = @(
        @(7,5), @(8,5), @(9,6), @(10,7), @(10,8), @(9,9), @(8,10), @(7,10), @(6,9), @(5,8), @(6,7)
    ) },
    @{ Color = 'P'; Points = @(
        @(7,7), @(8,7), @(9,8), @(8,9), @(7,9), @(6,8)
    ) },
    @{ Color = 'W'; Points = @(
        @(4,4), @(11,4), @(8,8), @(4,11), @(12,12)
    ) }
)

$paletteC = @{
    N = Convert-HexColor '#10152F'
    B = Convert-HexColor '#1D4B91'
    T = Convert-HexColor '#1598A9'
    C = Convert-HexColor '#42E2E5'
    V = Convert-HexColor '#8349C8'
    M = Convert-HexColor '#ED4DB5'
    P = Convert-HexColor '#FFC1E8'
    W = Convert-HexColor '#FFF7E3'
}

$layersC = @(
    @{ Color = 'N'; Points = @(
        @(7,5), @(8,5), @(7,6), @(8,6), @(6,7), @(7,7), @(8,7), @(9,7), @(6,8), @(7,8), @(8,8), @(9,8), @(10,8),
        @(5,9), @(6,9), @(7,9), @(8,9), @(9,9), @(10,9), @(6,10), @(7,10), @(8,10), @(9,10), @(7,11), @(8,11), @(7,12)
    ) },
    @{ Color = 'B'; Points = @(
        @(3,2), @(4,2), @(2,3), @(3,3), @(6,3), @(2,4), @(7,4), @(2,5), @(7,5), @(3,6), @(7,6), @(4,7), @(5,7), @(6,7),
        @(2,10), @(3,10), @(4,10), @(2,11), @(4,12), @(3,13)
    ) },
    @{ Color = 'T'; Points = @(
        @(5,3), @(6,4), @(3,4), @(2,5), @(3,6), @(4,7), @(5,7), @(6,6),
        @(4,9), @(5,9), @(3,10), @(2,11), @(3,12), @(4,12), @(5,11), @(6,10), @(7,9)
    ) },
    @{ Color = 'C'; Points = @(
        @(4,4), @(5,4), @(6,5), @(5,6), @(4,6), @(3,5), @(6,7), @(7,7), @(8,8),
        @(3,10), @(4,11), @(3,12), @(5,10), @(6,9)
    ) },
    @{ Color = 'V'; Points = @(
        @(10,2), @(11,2), @(9,3), @(12,3), @(9,4), @(10,4), @(11,4), @(12,4), @(8,5), @(8,6),
        @(9,7), @(10,7), @(11,7), @(12,8), @(13,8), @(14,9), @(14,10), @(13,11), @(13,12), @(12,13), @(11,13), @(10,12),
        @(6,11), @(7,11), @(6,12), @(8,12), @(6,13), @(8,13), @(7,14)
    ) },
    @{ Color = 'M'; Points = @(
        @(10,3), @(11,4), @(9,5), @(9,6), @(10,7), @(9,8), @(10,8), @(11,8), @(12,9), @(13,9), @(13,10), @(12,11), @(11,12), @(10,11), @(9,10), @(8,9),
        @(7,10), @(7,11), @(7,12), @(6,13), @(7,14), @(8,13)
    ) },
    @{ Color = 'P'; Points = @(
        @(10,4), @(9,7), @(10,9), @(11,9), @(12,10), @(11,11), @(7,12), @(8,13)
    ) },
    @{ Color = 'W'; Points = @(
        @(5,5), @(11,3), @(11,10), @(3,11), @(7,13)
    ) }
)

New-Candidate -Name 'a-triad-cluster' -Palette $paletteA -Layers $layersA
New-Candidate -Name 'b-spiral-swarm-crown' -Palette $paletteB -Layers $layersB
New-Candidate -Name 'c-colliding-web' -Palette $paletteC -Layers $layersC

Write-Output 'RUNTIME_CANDIDATES_BUILT=3'
