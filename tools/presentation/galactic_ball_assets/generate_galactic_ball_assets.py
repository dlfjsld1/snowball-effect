"""Deterministic native-grid generator for the Galactic ball family.

Every output pixel is authored directly at its runtime LOD. The generator does
not resize, antialias, blur, or consume AI-generated image output.
"""

from __future__ import annotations

import math
from pathlib import Path
from typing import Iterable

from PIL import Image, ImageDraw


REPOSITORY_ROOT = Path(__file__).resolve().parents[3]
OUTPUT_ROOT = REPOSITORY_ROOT / "assets/sprites/balls/galactic/runtime"

TRANSPARENT = (0, 0, 0, 0)
VOID = (2, 4, 12, 255)  # #02040C
OUTLINE = (11, 16, 38, 255)  # #0B1026
DEEP = (22, 20, 62, 255)  # #16143E
PURPLE = (52, 39, 102, 255)  # #342766
INDIGO = (81, 70, 163, 255)  # #5146A3
VIOLET = (128, 92, 255, 255)  # #805CFF
BLUE = (57, 119, 184, 255)  # #3977B8
PINK = (201, 107, 175, 255)  # #C96BAF
CYAN = (87, 196, 200, 255)  # #57C4C8
TEAL = (133, 222, 209, 255)  # #85DED1
GOLD = (241, 198, 107, 255)  # #F1C66B
CORE = (255, 241, 184, 255)  # #FFF1B8
WHITE = (247, 250, 255, 255)  # #F7FAFF


JOBS = (
    (10, 0, "galaxy", 8, "ball_lv10_galaxy_8.png"),
    (11, 1, "galaxy_cluster", 16, "ball_lv11_galaxy_cluster_16.png"),
    (12, 2, "quasar", 32, "ball_lv12_quasar_32.png"),
    (13, 3, "event_horizon", 64, "ball_lv13_event_horizon_64.png"),
    (14, 4, "black_hole", 128, "ball_lv14_black_hole_128.png"),
)


def main() -> None:
    OUTPUT_ROOT.mkdir(parents=True, exist_ok=True)
    for global_level, local_level, visual_name, size, filename in JOBS:
        image = build_sprite(visual_name, size)
        validate_native_output(image, size, visual_name)
        path = OUTPUT_ROOT / filename
        image.save(path, format="PNG", optimize=False, compress_level=9)
        print(
            "GALACTIC_BALL_WRITTEN "
            f"global={global_level} local={local_level} size={size}x{size} path={path}"
        )


def build_sprite(visual_name: str, size: int) -> Image.Image:
    if visual_name == "galaxy":
        return paint_symbolic_galaxy()
    if visual_name == "galaxy_cluster":
        return paint_galaxy_cluster(size)
    if visual_name == "quasar":
        return paint_quasar(size)
    if visual_name == "event_horizon":
        return paint_event_horizon(size)
    if visual_name == "black_hole":
        return paint_black_hole(size)
    raise ValueError(f"Unknown Galactic visual: {visual_name}")


def paint_symbolic_galaxy() -> Image.Image:
    """A separately authored 8x8 spiral, never reduced from the 128px hero."""
    image = Image.new("RGBA", (8, 8), TRANSPARENT)
    legend = {
        "o": OUTLINE,
        "i": INDIGO,
        "p": PINK,
        "c": CYAN,
        "g": GOLD,
        "w": WHITE,
    }
    rows = (
        "...cg...",
        ".ooog...",
        "oc..o...",
        "g.cww.po",
        "o.pww.ci",
        "...o..io",
        "...ppo..",
        "...i....",
    )
    for y, row in enumerate(rows):
        for x, token in enumerate(row):
            if token != ".":
                image.putpixel((x, y), legend[token])
    return image


def paint_galaxy_cluster(size: int) -> Image.Image:
    """A loose gravity-bound group of galaxy bodies, not an enclosing sphere."""
    image = Image.new("RGBA", (size, size), TRANSPARENT)
    interior: dict[tuple[int, int], tuple[int, int, int, int]] = {}

    stamp_ellipse(interior, (8, 8), (4, 2), INDIGO)
    stamp_ellipse(interior, (8, 8), (2, 1), CORE)
    stamp_ellipse(interior, (3, 4), (2, 1), CYAN)
    stamp_ellipse(interior, (12, 3), (2, 1), PINK)
    stamp_ellipse(interior, (13, 11), (2, 2), VIOLET)
    stamp_ellipse(interior, (4, 13), (2, 1), BLUE)
    for point, color in (
        ((0, 8), TEAL),
        ((15, 7), GOLD),
        ((9, 0), WHITE),
        ((7, 15), PINK),
        ((2, 10), CORE),
        ((11, 14), CYAN),
    ):
        interior[point] = color

    paint_outlined_pixels(image, interior, 1)
    for point, color in (
        ((6, 7), CYAN),
        ((9, 8), WHITE),
        ((10, 7), GOLD),
        ((2, 4), WHITE),
        ((12, 3), CORE),
        ((13, 11), PINK),
    ):
        image.putpixel(point, color)
    return image


def paint_quasar(size: int) -> Image.Image:
    """A compact radiant nucleus with a stepped disk and opposing polar jets."""
    image = Image.new("RGBA", (size, size), TRANSPARENT)
    layers: list[tuple[Iterable[tuple[int, int]], tuple[int, int, int, int]]] = [
        (((14, 12), (15, 0), (18, 0), (18, 12)), BLUE),
        (((15, 20), (16, 31), (19, 31), (18, 20)), PURPLE),
        (((0, 16), (5, 12), (12, 10), (19, 11), (26, 9), (31, 13), (27, 18), (19, 21), (11, 20), (4, 22)), INDIGO),
        (((2, 16), (9, 13), (16, 13), (24, 11), (30, 14), (23, 17), (16, 19), (8, 18)), PINK),
        (((5, 15), (13, 12), (22, 12), (27, 14), (21, 16), (12, 17)), CYAN),
        (((12, 12), (20, 12), (22, 16), (19, 20), (13, 19), (10, 15)), GOLD),
        (((14, 13), (19, 13), (20, 17), (17, 19), (13, 17)), CORE),
        (((15, 14), (18, 14), (19, 17), (16, 18), (14, 16)), WHITE),
    ]
    interior: dict[tuple[int, int], tuple[int, int, int, int]] = {}
    for polygon, color in layers:
        stamp_polygon(interior, size, polygon, color)
    paint_outlined_pixels(image, interior, 1)

    # Fixed jet knots and dust-lane interruptions keep the phenomenon crisp.
    for y, color in ((1, WHITE), (4, TEAL), (7, CYAN), (24, VIOLET), (28, INDIGO), (31, PINK)):
        set_block(image, 16 if y < 16 else 17, y, 2, color)
    draw_line_clipped(image, (4, 18), (13, 15), DEEP, 1)
    draw_line_clipped(image, (20, 15), (29, 12), DEEP, 1)
    return image


def paint_event_horizon(size: int) -> Image.Image:
    """CUT-IN-derived fractured dark sphere with a right-side lens flare."""
    image = Image.new("RGBA", (size, size), TRANSPARENT)
    center = ((size - 1) * 0.5, (size - 1) * 0.5)
    interior: dict[tuple[int, int], tuple[int, int, int, int]] = {}

    for y in range(size):
        for x in range(size):
            dx = x - center[0]
            dy = y - center[1]
            distance = math.sqrt(dx * dx + dy * dy)
            angle = math.atan2(dy, dx)
            color = None

            # The portrait's large navy body: this is an opaque mass, not an
            # illustrated badge floating inside a generic circle.
            body_radius = math.sqrt((dx / 26.5) ** 2 + (dy / 25.0) ** 2)
            if body_radius <= 1.0:
                color = DEEP
            elif body_radius <= 1.13:
                color = DEEP if dx < 4.0 else PURPLE

            # Unlike Black Hole, Event Horizon is still a cracked physical
            # mass in the portrait. Only its inner core falls into void.
            if distance <= 16.5:
                color = VOID

            # A hard, bright crescent bends around the portrait's right edge.
            crescent_radius = math.sqrt(((dx - 5.0) / 28.0) ** 2 + (dy / 27.0) ** 2)
            if 0.91 <= crescent_radius <= 1.05 and dx > 8.0:
                color = WHITE if dx > 20.0 else CORE
            elif 0.98 <= crescent_radius <= 1.13 and dx > 11.0:
                color = GOLD if dy < 4.0 else PINK

            # Broken violet contour lines on the left deliberately echo the
            # portrait's fractured shell without filling the void.
            shell_radius = math.sqrt(((dx + 4.0) / 28.0) ** 2 + (dy / 26.0) ** 2)
            fracture = math.sin(angle * 5.0 - dy * 0.18)
            if 0.79 <= shell_radius <= 0.88 and dx < 15.0 and fracture > -0.28:
                color = VIOLET if dy < -2.0 else PURPLE
            if 0.92 <= shell_radius <= 1.02 and dx < -6.0 and fracture > 0.20:
                color = PINK if dy < 4.0 else INDIGO

            # Thin teal orbital dashes sit beyond the body just like the
            # portrait's detached lensing marks.
            orbit_radius = math.sqrt(((dx + 2.0) / 31.0) ** 2 + (dy / 29.0) ** 2)
            if 0.96 <= orbit_radius <= 1.02 and (angle < -2.40 or angle > 2.45 or -0.98 < angle < -0.56):
                color = TEAL if angle < -0.56 else CYAN
            if color is not None:
                interior[(x, y)] = color

    paint_outlined_pixels(image, interior, 2)
    # Chipped cracks on the dark face, plus sparse scale anchors.
    for start, end, color in (
        ((10, 23), (23, 29), PURPLE),
        ((14, 38), (27, 33), PINK),
        ((19, 49), (29, 42), INDIGO),
        ((42, 16), (54, 23), VIOLET),
    ):
        draw_line_clipped(image, start, end, color, 1)
    for x, y, color in (
        (0, 31, CYAN),
        (63, 29, WHITE),
        (31, 0, TEAL),
        (34, 63, INDIGO),
        (7, 16, GOLD),
        (57, 47, CORE),
    ):
        set_block(image, x, y, 1 if x in (0, 63) or y in (0, 63) else 2, color)
    return image


def paint_black_hole(size: int) -> Image.Image:
    """CUT-IN-derived hero: round void, segmented violet ring, cardinal flares."""
    image = Image.new("RGBA", (size, size), TRANSPARENT)
    center = ((size - 1) * 0.5, (size - 1) * 0.5)
    interior: dict[tuple[int, int], tuple[int, int, int, int]] = {}
    for y in range(size):
        for x in range(size):
            dx = x - center[0]
            dy = y - center[1]
            distance = math.sqrt(dx * dx + dy * dy)
            angle = math.atan2(dy, dx)
            color = None
            segment = math.sin(angle * 8.0 + 0.35)

            # The canonical portrait has an unambiguous, perfectly dark hole.
            if distance <= 34.5:
                color = VOID
            elif distance <= 37.0:
                color = WHITE
            elif distance <= 39.5:
                color = CORE if dy < 0.0 else GOLD
            elif distance <= 43.5:
                color = PINK if dx > 0.0 else VIOLET

            # A thick but interrupted purple torus is the primary body. The
            # separation gaps are intentional: it keeps the silhouette from
            # becoming a generic smooth icon.
            if 40.0 <= distance <= 57.0 and segment > -0.32:
                if distance < 45.0:
                    color = PURPLE
                elif segment > 0.35:
                    color = VIOLET
                else:
                    color = DEEP
            if 47.0 <= distance <= 55.0 and segment > 0.55:
                color = PINK if dy < 0.0 else INDIGO

            # Detached cyan orbit dashes echo the outermost portrait contour.
            if 58.0 <= distance <= 61.5 and segment > 0.10:
                color = TEAL if dy < -7.0 else CYAN
            if color is not None:
                interior[(x, y)] = color

    paint_outlined_pixels(image, interior, 2)

    # Four cardinal starbursts make the level-four silhouette immediately
    # recognisable at gameplay scale. They terminate in single-pixel anchors
    # so the native 128px collision extent is preserved without a frame.
    for start, end, color, width in (
        ((63, 2), (63, 26), CORE, 3),
        ((64, 101), (64, 125), GOLD, 3),
        ((2, 63), (26, 63), CORE, 3),
        ((101, 64), (125, 64), WHITE, 3),
        ((51, 63), (76, 63), PINK, 1),
        ((63, 51), (63, 76), VIOLET, 1),
    ):
        draw_line_clipped(image, start, end, color, width)
    for x, y, color in (
        (0, 63, GOLD),
        (127, 64, WHITE),
        (63, 0, CORE),
        (64, 127, GOLD),
        (18, 33, TEAL),
        (109, 95, CYAN),
    ):
        set_block(image, x, y, 1 if x in (0, 127) or y in (0, 127) else 3, color)
    return image


def stamp_ellipse(
    pixels: dict[tuple[int, int], tuple[int, int, int, int]],
    center: tuple[int, int],
    radii: tuple[int, int],
    color: tuple[int, int, int, int],
) -> None:
    rx = max(radii[0], 1)
    ry = max(radii[1], 1)
    for y in range(center[1] - ry, center[1] + ry + 1):
        for x in range(center[0] - rx, center[0] + rx + 1):
            if ((x - center[0]) / rx) ** 2 + ((y - center[1]) / ry) ** 2 <= 1.0:
                pixels[(x, y)] = color


def stamp_polygon(
    pixels: dict[tuple[int, int], tuple[int, int, int, int]],
    size: int,
    points: Iterable[tuple[int, int]],
    color: tuple[int, int, int, int],
) -> None:
    mask = Image.new("1", (size, size), 0)
    ImageDraw.Draw(mask).polygon(tuple(points), fill=1)
    for y in range(size):
        for x in range(size):
            if mask.getpixel((x, y)):
                pixels[(x, y)] = color


def paint_outlined_pixels(
    image: Image.Image,
    interior: dict[tuple[int, int], tuple[int, int, int, int]],
    radius: int,
) -> None:
    outline_pixels: set[tuple[int, int]] = set()
    for x, y in interior:
        for offset_y in range(-radius, radius + 1):
            for offset_x in range(-radius, radius + 1):
                if offset_x * offset_x + offset_y * offset_y > radius * radius:
                    continue
                point = (x + offset_x, y + offset_y)
                if (
                    0 <= point[0] < image.width
                    and 0 <= point[1] < image.height
                    and point not in interior
                ):
                    outline_pixels.add(point)
    for point in outline_pixels:
        image.putpixel(point, OUTLINE)
    for point, color in interior.items():
        if 0 <= point[0] < image.width and 0 <= point[1] < image.height:
            image.putpixel(point, color)


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
            if mask.getpixel((x, y)) and image.getpixel((x, y))[3] == 255:
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


def validate_native_output(image: Image.Image, expected_size: int, label: str) -> None:
    if image.mode != "RGBA" or image.size != (expected_size, expected_size):
        raise ValueError(f"{label} is not an RGBA {expected_size}x{expected_size} native master")
    for y in range(image.height):
        for x in range(image.width):
            pixel = image.getpixel((x, y))
            if pixel[3] not in (0, 255):
                raise ValueError(f"{label} contains non-binary alpha")
            if pixel[3] == 0 and pixel[:3] != (0, 0, 0):
                raise ValueError(f"{label} contains transparent matte RGB")


if __name__ == "__main__":
    main()
