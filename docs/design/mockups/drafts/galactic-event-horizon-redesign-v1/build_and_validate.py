from __future__ import annotations

import json
import math
from collections import deque
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parent
RUNTIME_SIZE = 64
SUBJECT_BOX = 60
INSPECTION_SIZE = 256

CANDIDATES = (
    ("A", "void-aperture"),
    ("B", "gravity-wound"),
    ("C", "last-light"),
)


def clear_invisible_rgb(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    pixels = list(rgba.get_flattened_data())
    cleaned = []
    for red, green, blue, alpha in pixels:
        if alpha <= 1:
            cleaned.append((0, 0, 0, 0))
        else:
            cleaned.append((red, green, blue, alpha))
    rgba.putdata(cleaned)
    return rgba


def remove_detached_specks(image: Image.Image, alpha_threshold: int = 8) -> Image.Image:
    rgba = image.convert("RGBA")
    alpha = rgba.getchannel("A")
    pixels = alpha.load()
    visited: set[tuple[int, int]] = set()
    components: list[list[tuple[int, int]]] = []
    for y in range(rgba.height):
        for x in range(rgba.width):
            if (x, y) in visited or pixels[x, y] <= alpha_threshold:
                continue
            component: list[tuple[int, int]] = []
            queue = deque([(x, y)])
            visited.add((x, y))
            while queue:
                current_x, current_y = queue.popleft()
                component.append((current_x, current_y))
                for offset_x, offset_y in ((1, 0), (-1, 0), (0, 1), (0, -1), (1, 1), (1, -1), (-1, 1), (-1, -1)):
                    next_x = current_x + offset_x
                    next_y = current_y + offset_y
                    if not (0 <= next_x < rgba.width and 0 <= next_y < rgba.height):
                        continue
                    if (next_x, next_y) in visited or pixels[next_x, next_y] <= alpha_threshold:
                        continue
                    visited.add((next_x, next_y))
                    queue.append((next_x, next_y))
            components.append(component)

    if len(components) <= 1:
        return rgba
    largest = max(components, key=len)
    output = rgba.copy()
    output_pixels = output.load()
    for component in components:
        if component is largest:
            continue
        for x, y in component:
            output_pixels[x, y] = (0, 0, 0, 0)
    return output


def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    bbox = image.getchannel("A").getbbox()
    if bbox is None:
        raise ValueError("Image has no visible alpha subject")
    return bbox


def build_runtime(master: Image.Image) -> Image.Image:
    source = master.crop(alpha_bbox(master))
    scale = min(SUBJECT_BOX / source.width, SUBJECT_BOX / source.height)
    width = max(1, round(source.width * scale))
    height = max(1, round(source.height * scale))
    reduced = source.resize((width, height), Image.Resampling.LANCZOS)
    reduced = clear_invisible_rgb(reduced)

    output = Image.new("RGBA", (RUNTIME_SIZE, RUNTIME_SIZE), (0, 0, 0, 0))
    left = (RUNTIME_SIZE - width) // 2
    top = (RUNTIME_SIZE - height) // 2
    output.alpha_composite(reduced, (left, top))
    return clear_invisible_rgb(output)


def margins(size: tuple[int, int], bbox: tuple[int, int, int, int]) -> list[int]:
    width, height = size
    left, top, right, bottom = bbox
    return [left, top, width - right, height - bottom]


def edge_alpha_max(image: Image.Image) -> int:
    alpha = image.getchannel("A")
    values = []
    values.extend(alpha.crop((0, 0, image.width, 1)).get_flattened_data())
    values.extend(alpha.crop((0, image.height - 1, image.width, image.height)).get_flattened_data())
    values.extend(alpha.crop((0, 0, 1, image.height)).get_flattened_data())
    values.extend(alpha.crop((image.width - 1, 0, image.width, image.height)).get_flattened_data())
    return max(values)


def component_count(image: Image.Image, alpha_threshold: int = 8) -> int:
    alpha = image.getchannel("A")
    pixels = alpha.load()
    visited: set[tuple[int, int]] = set()
    count = 0
    for y in range(image.height):
        for x in range(image.width):
            if (x, y) in visited or pixels[x, y] <= alpha_threshold:
                continue
            count += 1
            queue = deque([(x, y)])
            visited.add((x, y))
            while queue:
                current_x, current_y = queue.popleft()
                for offset_x, offset_y in ((1, 0), (-1, 0), (0, 1), (0, -1), (1, 1), (1, -1), (-1, 1), (-1, -1)):
                    next_x = current_x + offset_x
                    next_y = current_y + offset_y
                    if not (0 <= next_x < image.width and 0 <= next_y < image.height):
                        continue
                    if (next_x, next_y) in visited or pixels[next_x, next_y] <= alpha_threshold:
                        continue
                    visited.add((next_x, next_y))
                    queue.append((next_x, next_y))
    return count


def luminance(red: int, green: int, blue: int) -> float:
    return 0.2126 * red + 0.7152 * green + 0.0722 * blue


def void_metrics(image: Image.Image) -> dict[str, float | int | bool | list[int]]:
    rgba = image.convert("RGBA")
    pixels = rgba.load()
    center = (image.width // 2, image.height // 2)

    queue = deque([center])
    visited = {center}
    void_pixels: list[tuple[int, int]] = []
    while queue:
        x, y = queue.popleft()
        red, green, blue, alpha = pixels[x, y]
        if alpha < 192 or luminance(red, green, blue) > 16:
            continue
        void_pixels.append((x, y))
        for offset_x, offset_y in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            next_x = x + offset_x
            next_y = y + offset_y
            if 0 <= next_x < image.width and 0 <= next_y < image.height and (next_x, next_y) not in visited:
                visited.add((next_x, next_y))
                queue.append((next_x, next_y))

    if void_pixels:
        xs = [point[0] for point in void_pixels]
        ys = [point[1] for point in void_pixels]
        void_bbox = [min(xs), min(ys), max(xs) + 1, max(ys) + 1]
    else:
        void_bbox = [0, 0, 0, 0]

    center_luma = []
    for y in range(center[1] - 8, center[1] + 8):
        for x in range(center[0] - 8, center[0] + 8):
            red, green, blue, _alpha = pixels[x, y]
            center_luma.append(luminance(red, green, blue))
    average = sum(center_luma) / len(center_luma)
    variance = sum((value - average) ** 2 for value in center_luma) / len(center_luma)

    bright_boundary_pixels = 0
    for red, green, blue, alpha in rgba.get_flattened_data():
        if alpha >= 64 and luminance(red, green, blue) >= 70:
            bright_boundary_pixels += 1

    void_area = len(void_pixels)
    return {
        "connected_void_pixels": void_area,
        "connected_void_fraction_of_canvas": round(void_area / (image.width * image.height), 4),
        "connected_void_bbox": void_bbox,
        "center_16x16_luma_max": round(max(center_luma), 3),
        "center_16x16_luma_stddev": round(math.sqrt(variance), 3),
        "bright_boundary_pixels": bright_boundary_pixels,
        "void_area_pass": void_area >= 500,
        "interior_detail_free_pass": max(center_luma) <= 10 and math.sqrt(variance) <= 2,
        "outer_cue_pass": bright_boundary_pixels >= 16,
    }


def file_metrics(path: Path, expect_transparency: bool = True) -> dict[str, object]:
    with Image.open(path) as opened:
        opened.verify()
    with Image.open(path) as opened:
        rgba = opened.convert("RGBA")
        alpha = rgba.getchannel("A")
        bbox = alpha_bbox(rgba)
        alpha_values = list(alpha.get_flattened_data())
        metrics: dict[str, object] = {
            "file": path.name,
            "format": opened.format,
            "mode": rgba.mode,
            "size": list(rgba.size),
            "alpha_min": min(alpha_values),
            "alpha_max": max(alpha_values),
            "transparent_pixels": sum(value == 0 for value in alpha_values),
            "opaque_pixels": sum(value == 255 for value in alpha_values),
            "partial_alpha_pixels": sum(0 < value < 255 for value in alpha_values),
            "alpha_bbox": list(bbox),
            "margins_ltrb": margins(rgba.size, bbox),
            "edge_alpha_max": edge_alpha_max(rgba),
            "components_alpha_gt_8": component_count(rgba),
            "valid_png_rgba": opened.format == "PNG" and rgba.mode == "RGBA",
            "transparency_pass": (min(alpha_values) == 0) if expect_transparency else True,
            "edge_clear_pass": edge_alpha_max(rgba) == 0,
        }
        return metrics


def nearest_match(actual: Image.Image, inspection: Image.Image) -> bool:
    return inspection.tobytes() == actual.resize((INSPECTION_SIZE, INSPECTION_SIZE), Image.Resampling.NEAREST).tobytes()


def main() -> None:
    report: dict[str, object] = {
        "authoritative_mapping": {
            "global_level": 13,
            "galactic_local_level": 3,
            "runtime_radius": 32,
            "runtime_diameter": 64,
        },
        "candidates": {},
    }

    for letter, slug in CANDIDATES:
        master_path = ROOT / f"event-horizon-{letter}-{slug}-master.png"
        actual_path = ROOT / f"event-horizon-{letter}-{slug}-64.png"
        inspection_path = ROOT / f"event-horizon-{letter}-{slug}-inspection-256.png"

        with Image.open(master_path) as opened:
            master = remove_detached_specks(clear_invisible_rgb(opened))
        master.save(master_path, format="PNG", optimize=True)

        actual = build_runtime(master)
        actual.save(actual_path, format="PNG", optimize=True)
        inspection = actual.resize((INSPECTION_SIZE, INSPECTION_SIZE), Image.Resampling.NEAREST)
        inspection.save(inspection_path, format="PNG", optimize=True)

        candidate_report = {
            "master": file_metrics(master_path),
            "actual": file_metrics(actual_path),
            "inspection": file_metrics(inspection_path),
            "void": void_metrics(actual),
            "nearest_4x_pass": nearest_match(actual, inspection),
        }
        report["candidates"][letter] = candidate_report

    report_path = ROOT / "validation.json"
    report_path.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(json.dumps(report, indent=2, ensure_ascii=False))

    failures: list[str] = []
    for letter, _slug in CANDIDATES:
        candidate = report["candidates"][letter]
        for asset_kind in ("master", "actual", "inspection"):
            asset = candidate[asset_kind]
            if not asset["valid_png_rgba"] or not asset["transparency_pass"] or not asset["edge_clear_pass"]:
                failures.append(f"{letter} {asset_kind} PNG/RGBA/alpha validation")
        if min(candidate["actual"]["margins_ltrb"]) < 2:
            failures.append(f"{letter} actual transparent margin")
        if candidate["actual"]["components_alpha_gt_8"] != 1:
            failures.append(f"{letter} actual connected silhouette")
        if not candidate["nearest_4x_pass"]:
            failures.append(f"{letter} nearest 4x inspection")
        for check in ("void_area_pass", "interior_detail_free_pass", "outer_cue_pass"):
            if not candidate["void"][check]:
                failures.append(f"{letter} {check}")

    if failures:
        raise SystemExit("VALIDATION_FAILED: " + "; ".join(failures))
    print("EVENT_HORIZON_ASSETS_VERIFIED candidates=3 actual=64 inspection=256 edge_alpha=0")


if __name__ == "__main__":
    main()
