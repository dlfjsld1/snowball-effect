"""Deterministic native-grid generator for the Planetary ball family.

Every output pixel is written directly at its runtime LOD. The generator does
not resize, antialias, blur, or consume AI-generated image output.
"""

from __future__ import annotations

import math
from pathlib import Path
from typing import Iterable

from PIL import Image, ImageDraw


REPOSITORY_ROOT = Path(__file__).resolve().parents[3]
OUTPUT_ROOT = REPOSITORY_ROOT / "assets/sprites/balls/planetary/runtime"

TRANSPARENT = (0, 0, 0, 0)
OUTLINE = (11, 16, 38, 255)  # #0B1026

MOON_SHADOW = (70, 70, 70, 255)
MOON_DARK = (98, 98, 98, 255)
MOON_MID = (145, 145, 145, 255)
MOON_LIGHT = (204, 204, 204, 255)
MOON_PEAK = (241, 241, 241, 255)

SUN_DEEP = (115, 46, 24, 255)
SUN_DARK = (180, 70, 28, 255)
SUN_ORANGE = (225, 113, 57, 255)
SUN_GOLD = (248, 174, 91, 255)
SUN_LIGHT = (255, 222, 170, 255)
SUN_CORE = (255, 241, 184, 255)

SUPERNOVA_DEEP = (52, 39, 102, 255)
SUPERNOVA_PURPLE = (125, 65, 150, 255)
SUPERNOVA_MAGENTA = (201, 107, 175, 255)
SUPERNOVA_ORANGE = (225, 113, 57, 255)
SUPERNOVA_GOLD = (248, 174, 91, 255)
SUPERNOVA_CORE = (255, 241, 184, 255)

EARTH_DEEP = (12, 48, 91, 255)
EARTH_OCEAN = (20, 96, 148, 255)
EARTH_BLUE = (39, 151, 190, 255)
EARTH_SHALLOW = (80, 196, 202, 255)
EARTH_LAND_DARK = (45, 103, 61, 255)
EARTH_LAND = (74, 142, 71, 255)
EARTH_LAND_LIGHT = (126, 177, 84, 255)
EARTH_CLOUD = (224, 239, 235, 255)
EARTH_ICE = (250, 252, 248, 255)

GALAXY_DEEP = (22, 20, 62, 255)
GALAXY_PURPLE = (52, 39, 102, 255)
GALAXY_INDIGO = (81, 70, 163, 255)
GALAXY_BLUE = (57, 119, 184, 255)
GALAXY_PINK = (201, 107, 175, 255)
GALAXY_CYAN = (87, 196, 200, 255)
GALAXY_TEAL = (133, 222, 209, 255)
GALAXY_GOLD = (241, 198, 107, 255)
GALAXY_CORE = (255, 241, 184, 255)
GALAXY_WHITE = (247, 250, 255, 255)


JOBS = (
    (4, 0, "moon", 8, "ball_lv04_moon_8.png"),
    (5, 1, "earth", 16, "ball_lv05_earth_16.png"),
    (6, 2, "sun", 32, "ball_lv06_sun_32.png"),
    (8, 3, "supernova", 64, "ball_lv08_supernova_64.png"),
    (10, 4, "galaxy", 128, "ball_lv10_galaxy_128.png"),
)


def main() -> None:
    OUTPUT_ROOT.mkdir(parents=True, exist_ok=True)
    for global_level, local_level, visual_name, size, filename in JOBS:
        image = build_sprite(visual_name, size)
        path = OUTPUT_ROOT / filename
        image.save(path, format="PNG", optimize=False, compress_level=9)
        print(
            "PLANETARY_BALL_WRITTEN "
            f"global={global_level} local={local_level} size={size}x{size} path={path}"
        )


def build_sprite(visual_name: str, size: int) -> Image.Image:
    if visual_name == "moon":
        return paint_symbolic_moon()
    if visual_name == "earth":
        return paint_earth(size)
    if visual_name == "sun":
        return paint_sun(size)
    if visual_name == "supernova":
        return paint_supernova(size)
    if visual_name == "galaxy":
        return paint_galaxy(size)
    raise ValueError(f"Unknown Planetary visual: {visual_name}")


def paint_symbolic_moon() -> Image.Image:
    """A separately authored 8x8 symbol, never derived from Ground Moon."""
    image = Image.new("RGBA", (8, 8), TRANSPARENT)
    legend = {
        "o": OUTLINE,
        "s": MOON_SHADOW,
        "d": MOON_DARK,
        "m": MOON_MID,
        "l": MOON_LIGHT,
        "h": MOON_PEAK,
    }
    rows = (
        "...lh...",
        ".olhhho.",
        "omllhhho",
        "osdllhho",
        "ossmllho",
        "oossdmmo",
        ".ooossm.",
        "...oo...",
    )
    for y, row in enumerate(rows):
        for x, token in enumerate(row):
            if token != ".":
                image.putpixel((x, y), legend[token])
    return image


def paint_earth(size: int) -> Image.Image:
    if size != 16:
        raise ValueError("Planetary Earth must be its approved 16px native master")
    image = quantized_sphere(size, 1.0, (EARTH_DEEP, EARTH_OCEAN, EARTH_BLUE, EARTH_SHALLOW, EARTH_CLOUD))
    for x, y in ((5, 4), (6, 4), (4, 5), (5, 5), (5, 6), (6, 6), (7, 6), (8, 7), (9, 7), (10, 8), (10, 9), (9, 10), (8, 10), (7, 11), (6, 12)):
        set_if_opaque(image, x, y, EARTH_LAND)
    for x, y in ((10, 4), (11, 5), (11, 6), (12, 7), (12, 8), (11, 9)):
        set_if_opaque(image, x, y, EARTH_LAND_DARK)
    for x, y in ((4, 3), (5, 3), (6, 3), (7, 4), (8, 4), (3, 9), (4, 10), (5, 10), (10, 11), (11, 10)):
        set_if_opaque(image, x, y, EARTH_CLOUD)
    for x, y in ((6, 2), (7, 2), (8, 2), (7, 13), (8, 13), (9, 13)):
        set_if_opaque(image, x, y, EARTH_ICE)
    return image


def paint_sun(size: int) -> Image.Image:
    if size != 32:
        raise ValueError("Planetary Sun must be its approved 32px native master")
    image = quantized_sphere(size, 1.0, (SUN_DEEP, SUN_DARK, SUN_ORANGE, SUN_GOLD, SUN_LIGHT, SUN_CORE))
    rays = ((15, 0), (16, 0), (31, 15), (31, 16), (15, 31), (16, 31), (0, 15), (0, 16), (5, 4), (26, 4), (5, 27), (26, 27))
    for x, y in rays:
        image.putpixel((x, y), OUTLINE)
    for x, y in ((15, 1), (16, 1), (30, 15), (30, 16), (15, 30), (16, 30), (1, 15), (1, 16), (6, 5), (25, 5), (6, 26), (25, 26)):
        image.putpixel((x, y), SUN_GOLD)
    for x, y in ((11, 9), (12, 8), (13, 8), (20, 21), (19, 22), (18, 22)):
        set_if_opaque(image, x, y, SUN_CORE)
    return image


def paint_supernova(size: int) -> Image.Image:
    if size != 64:
        raise ValueError("Planetary Supernova must be its approved 64px native master")
    image = quantized_sphere(size, 1.0, (SUPERNOVA_DEEP, SUPERNOVA_PURPLE, SUPERNOVA_MAGENTA, SUPERNOVA_ORANGE))
    # The CUT-IN reference is a dense unstable orb: bright orbit ribbons pass
    # over dark violet cells and converge on one white-gold rupture point.
    for start, end in (((4, 23), (59, 41)), ((9, 46), (54, 13)), ((14, 7), (49, 56))):
        draw_line_clipped(image, start, end, SUPERNOVA_GOLD, 4)
    for start, end in (((6, 25), (58, 40)), ((10, 48), (53, 15)), ((15, 9), (48, 54))):
        draw_line_clipped(image, start, end, SUPERNOVA_CORE, 1)
    for x, y in ((29, 28), (30, 28), (31, 28), (32, 28), (28, 29), (29, 29), (30, 29), (31, 29), (32, 29), (33, 29), (28, 30), (29, 30), (30, 30), (31, 30), (32, 30), (33, 30), (34, 30), (29, 31), (30, 31), (31, 31), (32, 31), (33, 31), (30, 32), (31, 32), (32, 32), (31, 33)):
        set_if_opaque(image, x, y, SUPERNOVA_CORE)
    for x, y in ((10, 19), (12, 18), (15, 18), (43, 17), (48, 21), (13, 42), (18, 48), (45, 44), (51, 38)):
        set_if_opaque(image, x, y, SUPERNOVA_ORANGE)
    return image


def paint_galaxy(size: int) -> Image.Image:
    """Condense the CUT-IN's folded violet galaxy sphere into a readable ball."""
    image = quantized_sphere(size, 1.5, (GALAXY_DEEP, GALAXY_PURPLE, GALAXY_INDIGO, GALAXY_BLUE))
    # Crossed cyan, violet and cream ribbon lanes are the shared Galaxy motif.
    for start, end, shadow, light in (
        ((12, 47), (115, 80), GALAXY_PURPLE, GALAXY_CYAN),
        ((25, 97), (101, 25), GALAXY_INDIGO, GALAXY_TEAL),
        ((42, 13), (94, 112), GALAXY_PURPLE, GALAXY_GOLD),
    ):
        draw_line_clipped(image, start, end, shadow, 8)
        draw_line_clipped(image, start, end, light, 3)
    for start, end in (((16, 49), (114, 79)), ((27, 96), (100, 27)), ((44, 15), (92, 110))):
        draw_line_clipped(image, start, end, GALAXY_CORE, 1)
    for x, y, color in ((39, 43, GALAXY_PINK), (78, 36, GALAXY_TEAL), (92, 67, GALAXY_PINK), (59, 91, GALAXY_CYAN), (70, 63, GALAXY_WHITE), (71, 64, GALAXY_CORE)):
        set_if_opaque(image, x, y, color)
    return image


def quantized_sphere(
    size: int,
    outline_width: float,
    fills: tuple[tuple[int, int, int, int], ...],
) -> Image.Image:
    image = Image.new("RGBA", (size, size), TRANSPARENT)
    center = (float(size - 1) * 0.5, float(size - 1) * 0.5)
    radius = float(size) * 0.5 - 0.01
    for y in range(size):
        for x in range(size):
            dx = x - center[0]
            dy = y - center[1]
            distance = math.sqrt(dx * dx + dy * dy)
            if distance > radius:
                continue
            edge_depth = radius - distance
            if edge_depth < outline_width:
                image.putpixel((x, y), fills[-1] if dx + dy < -radius * 0.28 else OUTLINE)
                continue
            nx = dx / max(radius, 1.0)
            ny = dy / max(radius, 1.0)
            normal_z = math.sqrt(max(0.0, 1.0 - nx * nx - ny * ny))
            light = 0.38 - nx * 0.22 - ny * 0.25 + normal_z * 0.22
            fill_index = min(len(fills) - 1, max(0, math.floor(light * len(fills))))
            image.putpixel((x, y), fills[fill_index])
    return image


def draw_crater(
    image: Image.Image,
    center: tuple[int, int],
    radius: int,
    rim_color: tuple[int, int, int, int],
    shadow_color: tuple[int, int, int, int],
    light_color: tuple[int, int, int, int],
) -> None:
    radius_squared = radius * radius
    inner_squared = max(radius - 1, 1) ** 2
    for y in range(center[1] - radius, center[1] + radius + 1):
        for x in range(center[0] - radius, center[0] + radius + 1):
            if not is_opaque(image, x, y):
                continue
            dx = x - center[0]
            dy = y - center[1]
            distance_squared = dx * dx + dy * dy
            if distance_squared > radius_squared:
                continue
            if distance_squared > inner_squared:
                image.putpixel((x, y), light_color if dx + dy < 0 else rim_color)
            else:
                image.putpixel((x, y), shadow_color if dx + dy > 0 else rim_color)


def paint_polygon_clipped(
    image: Image.Image,
    points: Iterable[tuple[int, int]],
    color: tuple[int, int, int, int],
) -> None:
    mask = Image.new("1", image.size, 0)
    ImageDraw.Draw(mask).polygon(tuple(points), fill=1)
    for y in range(image.height):
        for x in range(image.width):
            if mask.getpixel((x, y)) and is_opaque(image, x, y):
                image.putpixel((x, y), color)


def draw_line_clipped(
    image: Image.Image,
    start: tuple[int, int],
    end: tuple[int, int],
    color: tuple[int, int, int, int],
    width: int,
) -> None:
    mask = Image.new("1", image.size, 0)
    ImageDraw.Draw(mask).line((start, end), fill=1, width=width)
    for y in range(image.height):
        for x in range(image.width):
            if mask.getpixel((x, y)) and is_opaque(image, x, y):
                image.putpixel((x, y), color)


def set_if_opaque(
    image: Image.Image,
    x: int,
    y: int,
    color: tuple[int, int, int, int],
) -> None:
    if is_opaque(image, x, y):
        image.putpixel((x, y), color)


def set_block(
    image: Image.Image,
    x: int,
    y: int,
    size: int,
    color: tuple[int, int, int, int],
) -> None:
    for offset_y in range(size):
        for offset_x in range(size):
            point = (x + offset_x, y + offset_y)
            if 0 <= point[0] < image.width and 0 <= point[1] < image.height:
                image.putpixel(point, color)


def is_opaque(image: Image.Image, x: int, y: int) -> bool:
    return 0 <= x < image.width and 0 <= y < image.height and image.getpixel((x, y))[3] == 255


if __name__ == "__main__":
    main()
