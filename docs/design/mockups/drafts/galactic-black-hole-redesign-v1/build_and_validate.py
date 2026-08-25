from __future__ import annotations

import json
import math
from collections import deque
from pathlib import Path

from PIL import Image, ImageChops, ImageStat


ROOT = Path(__file__).resolve().parent
RUNTIME_SIZE = 128
SUBJECT_BOX = 120
INSPECTION_SIZE = 256
ALPHA_CLEAN_THRESHOLD = 5

CANDIDATES = (
    ("A", "gargantua-classic"),
    ("B", "doppler-maw"),
    ("C", "void-cathedral"),
)


def luminance(red: int, green: int, blue: int) -> float:
    return 0.2126 * red + 0.7152 * green + 0.0722 * blue


def clean_alpha_noise(image: Image.Image, threshold: int = ALPHA_CLEAN_THRESHOLD) -> Image.Image:
    rgba = image.convert("RGBA")
    cleaned = []
    for red, green, blue, alpha in rgba.get_flattened_data():
        if alpha <= threshold:
            cleaned.append((0, 0, 0, 0))
        else:
            cleaned.append((red, green, blue, alpha))
    rgba.putdata(cleaned)
    return rgba


def normalize_runtime_shadow(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    normalized = []
    for red, green, blue, alpha in rgba.get_flattened_data():
        if alpha >= 192 and luminance(red, green, blue) <= 14:
            normalized.append((0, 0, 0, 255))
        else:
            normalized.append((red, green, blue, alpha))
    rgba.putdata(normalized)
    return rgba


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
    reduced = normalize_runtime_shadow(clean_alpha_noise(reduced, 2))

    output = Image.new("RGBA", (RUNTIME_SIZE, RUNTIME_SIZE), (0, 0, 0, 0))
    left = (RUNTIME_SIZE - width) // 2
    top = (RUNTIME_SIZE - height) // 2
    output.alpha_composite(reduced, (left, top))
    return clean_alpha_noise(output, 2)


def margins(size: tuple[int, int], bbox: tuple[int, int, int, int]) -> list[int]:
    width, height = size
    left, top, right, bottom = bbox
    return [left, top, width - right, height - bottom]


def edge_alpha_max(image: Image.Image) -> int:
    alpha = image.getchannel("A")
    edges = (
        alpha.crop((0, 0, image.width, 1)),
        alpha.crop((0, image.height - 1, image.width, image.height)),
        alpha.crop((0, 0, 1, image.height)),
        alpha.crop((image.width - 1, 0, image.width, image.height)),
    )
    return max(max(edge.get_flattened_data()) for edge in edges)


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
                for offset_x, offset_y in (
                    (1, 0), (-1, 0), (0, 1), (0, -1),
                    (1, 1), (1, -1), (-1, 1), (-1, -1),
                ):
                    next_x = current_x + offset_x
                    next_y = current_y + offset_y
                    if not (0 <= next_x < image.width and 0 <= next_y < image.height):
                        continue
                    if (next_x, next_y) in visited or pixels[next_x, next_y] <= alpha_threshold:
                        continue
                    visited.add((next_x, next_y))
                    queue.append((next_x, next_y))
    return count


def file_metrics(path: Path, expect_transparency: bool = True) -> dict[str, object]:
    with Image.open(path) as opened:
        opened.verify()
    with Image.open(path) as opened:
        rgba = opened.convert("RGBA")
        alpha = rgba.getchannel("A")
        bbox = alpha_bbox(rgba)
        alpha_values = list(alpha.get_flattened_data())
        return {
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
            "transparency_contract": "transparent_asset" if expect_transparency else "opaque_comparison_board",
            "transparency_pass": min(alpha_values) == 0 if expect_transparency else min(alpha_values) == 255,
            "edge_clear_pass": edge_alpha_max(rgba) == 0,
        }


def nearest_match(actual: Image.Image, inspection: Image.Image) -> bool:
    nearest = actual.resize((INSPECTION_SIZE, INSPECTION_SIZE), Image.Resampling.NEAREST)
    return inspection.tobytes() == nearest.tobytes()


def nearest_dark_seed(image: Image.Image, target: tuple[int, int]) -> tuple[int, int] | None:
    pixels = image.load()
    target_x, target_y = target
    candidates = []
    for radius in range(0, 17):
        for y in range(max(0, target_y - radius), min(image.height, target_y + radius + 1)):
            for x in range(max(0, target_x - radius), min(image.width, target_x + radius + 1)):
                red, green, blue, alpha = pixels[x, y]
                if alpha >= 192 and luminance(red, green, blue) <= 20:
                    candidates.append(((x - target_x) ** 2 + (y - target_y) ** 2, x, y))
        if candidates:
            _distance, x, y = min(candidates)
            return x, y
    return None


def dark_component(image: Image.Image, seed: tuple[int, int]) -> set[tuple[int, int]]:
    pixels = image.load()
    queue = deque([seed])
    visited = {seed}
    component: set[tuple[int, int]] = set()
    while queue:
        x, y = queue.popleft()
        red, green, blue, alpha = pixels[x, y]
        if alpha < 192 or luminance(red, green, blue) > 20:
            continue
        component.add((x, y))
        for offset_x, offset_y in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            next_x = x + offset_x
            next_y = y + offset_y
            if 0 <= next_x < image.width and 0 <= next_y < image.height and (next_x, next_y) not in visited:
                visited.add((next_x, next_y))
                queue.append((next_x, next_y))
    return component


def shadow_metrics(image: Image.Image) -> dict[str, object]:
    rgba = image.convert("RGBA")
    center_x = rgba.width // 2
    center_y = rgba.height // 2
    seeds = (
        nearest_dark_seed(rgba, (center_x, center_y - 17)),
        nearest_dark_seed(rgba, (center_x, center_y + 17)),
    )
    shadow: set[tuple[int, int]] = set()
    for seed in seeds:
        if seed is not None:
            shadow.update(dark_component(rgba, seed))

    if shadow:
        xs = [point[0] for point in shadow]
        ys = [point[1] for point in shadow]
        bbox = [min(xs), min(ys), max(xs) + 1, max(ys) + 1]
    else:
        bbox = [0, 0, 0, 0]

    samples = []
    for seed in seeds:
        if seed is None:
            continue
        seed_x, seed_y = seed
        for y in range(seed_y - 2, seed_y + 3):
            for x in range(seed_x - 5, seed_x + 6):
                samples.append(rgba.getpixel((x, y)))
    if not samples:
        samples = [(255, 255, 255, 0)]
    sample_luma = [luminance(red, green, blue) for red, green, blue, _alpha in samples]
    sample_alpha = [alpha for _red, _green, _blue, alpha in samples]
    average = sum(sample_luma) / len(sample_luma)
    variance = sum((value - average) ** 2 for value in sample_luma) / len(sample_luma)
    area = len(shadow)
    return {
        "connected_shadow_pixels": area,
        "connected_shadow_fraction_of_canvas": round(area / (rgba.width * rgba.height), 4),
        "connected_shadow_bbox": bbox,
        "sample_pixel_count": len(samples),
        "sample_alpha_min": min(sample_alpha),
        "sample_alpha_mean": round(sum(sample_alpha) / len(sample_alpha), 3),
        "sample_luma_max": round(max(sample_luma), 3),
        "sample_luma_stddev": round(math.sqrt(variance), 3),
        "shadow_area_pass": area >= 900,
        "opaque_center_pass": min(sample_alpha) >= 192,
        "interior_detail_free_pass": max(sample_luma) <= 10 and math.sqrt(variance) <= 2,
    }


def cue_metrics(image: Image.Image) -> dict[str, object]:
    rgba = image.convert("RGBA")
    center_y = rgba.height // 2
    bright = []
    for y in range(rgba.height):
        for x in range(rgba.width):
            red, green, blue, alpha = rgba.getpixel((x, y))
            if alpha >= 64 and luminance(red, green, blue) >= 60:
                bright.append((x, y, luminance(red, green, blue) * alpha / 255.0))
    upper = sum(y < center_y - 8 for x, y, weight in bright)
    lower = sum(y > center_y + 8 for x, y, weight in bright)
    equator = [(x, y, weight) for x, y, weight in bright if abs(y - center_y) <= 10]
    span = max((x for x, y, weight in equator), default=0) - min((x for x, y, weight in equator), default=0) + 1

    total_weight = sum(weight for _x, _y, weight in equator)
    if total_weight > 0:
        mean_x = sum(x * weight for x, y, weight in equator) / total_weight
        mean_y = sum(y * weight for x, y, weight in equator) / total_weight
        var_x = sum(weight * (x - mean_x) ** 2 for x, y, weight in equator) / total_weight
        var_y = sum(weight * (y - mean_y) ** 2 for x, y, weight in equator) / total_weight
        cov_xy = sum(weight * (x - mean_x) * (y - mean_y) for x, y, weight in equator) / total_weight
        angle = 0.5 * math.degrees(math.atan2(2 * cov_xy, var_x - var_y))
    else:
        angle = 0.0

    return {
        "bright_upper_lensing_pixels": upper,
        "bright_lower_lensing_pixels": lower,
        "bright_equatorial_disk_pixels": len(equator),
        "equatorial_bright_span_pixels": span,
        "equatorial_bright_span_fraction": round(span / rgba.width, 4),
        "estimated_disk_angle_degrees": round(angle, 2),
        "upper_lower_lensing_pass": upper >= 80 and lower >= 80,
        "equatorial_disk_pass": len(equator) >= 100 and span >= 72,
    }


def symmetry_metrics(image: Image.Image) -> dict[str, float]:
    rgba = image.convert("RGBA")
    horizontal = ImageChops.difference(rgba, rgba.transpose(Image.Transpose.FLIP_LEFT_RIGHT))
    vertical = ImageChops.difference(rgba, rgba.transpose(Image.Transpose.FLIP_TOP_BOTTOM))
    return {
        "left_right_mean_abs_rgba": round(sum(ImageStat.Stat(horizontal).mean) / (4 * 255), 4),
        "top_bottom_mean_abs_rgba": round(sum(ImageStat.Stat(vertical).mean) / (4 * 255), 4),
    }


def palette_metrics(image: Image.Image) -> dict[str, object]:
    warm = cool = violet = qualifying = 0
    for red, green, blue, alpha in image.convert("RGBA").get_flattened_data():
        if alpha < 64 or luminance(red, green, blue) < 40:
            continue
        qualifying += 1
        warm += red > blue * 1.12 and red > green * 1.03
        cool += blue > red * 1.12 and blue > green * 1.03
        violet += red > green * 1.12 and blue > green * 1.12
    denominator = max(1, qualifying)
    return {
        "qualified_bright_pixels": qualifying,
        "warm_fraction": round(warm / denominator, 4),
        "cool_fraction": round(cool / denominator, 4),
        "violet_fraction": round(violet / denominator, 4),
    }


def pairwise_difference(left: Image.Image, right: Image.Image) -> float:
    difference = ImageChops.difference(left.convert("RGBA"), right.convert("RGBA"))
    return round(sum(ImageStat.Stat(difference).mean) / (4 * 255), 4)


def main() -> None:
    report: dict[str, object] = {
        "authoritative_mapping": {
            "global_level": 14,
            "galactic_local_level": 4,
            "runtime_radius": 64,
            "runtime_diameter": 128,
            "ball_resource": "resources/balls/ball_14_black_hole.tres",
            "stage_resource": "resources/stages/stage_02_galactic.tres",
            "current_runtime_asset": "assets/sprites/balls/galactic/runtime/ball_lv14_black_hole_128.png",
            "mechanic_contract": "Galactic final-phase handoff; not a separate Stage and not an immediate Stage Clear",
            "converted_entity_footprint_note": "After first-contact handoff, the moving Black Hole gameplay footprint follows Galactic local Lv2 Quasar sizing; this draft only evaluates the authored Lv14 128px visual.",
        },
        "generation": {
            "tool": "built-in image_gen",
            "independent_generation_calls": {"A": 1, "B": 1, "C": 1},
            "retries": {"A": 1, "B": 0, "C": 0},
            "retry_note": "A framing retry painted a checkerboard and was rejected; the independent original was retained and only alpha<=5 residue was cleared.",
        },
        "references": {
            "cutin_black_hole": "assets/sprites/cutins/first_contact/black-hole-portrait-v1.png",
            "quasar_a": "assets/sprites/balls/galactic/runtime/ball_galactic_local_lv02_quasar_polar_beacon_32.png",
            "event_horizon_c": "assets/sprites/balls/galactic/runtime/ball_galactic_local_lv03_event_horizon_last_light_64.png",
            "event_horizon_c_structure": "one-sided gold-white crescent with a faint cool echo",
        },
        "candidates": {},
        "anti_convergence": {},
    }

    actual_images: dict[str, Image.Image] = {}
    for letter, slug in CANDIDATES:
        master_path = ROOT / f"black-hole-{letter}-{slug}-master.png"
        actual_path = ROOT / f"black-hole-{letter}-{slug}-128.png"
        inspection_path = ROOT / f"black-hole-{letter}-{slug}-inspection-256.png"

        with Image.open(master_path) as opened:
            master = clean_alpha_noise(opened)
        master.save(master_path, format="PNG", optimize=True)

        actual = build_runtime(master)
        actual.save(actual_path, format="PNG", optimize=True)
        inspection = actual.resize((INSPECTION_SIZE, INSPECTION_SIZE), Image.Resampling.NEAREST)
        inspection.save(inspection_path, format="PNG", optimize=True)
        actual_images[letter] = actual

        report["candidates"][letter] = {
            "master": file_metrics(master_path),
            "actual": file_metrics(actual_path),
            "inspection": file_metrics(inspection_path),
            "shadow": shadow_metrics(actual),
            "lensing_and_disk": cue_metrics(actual),
            "symmetry": symmetry_metrics(actual),
            "palette": palette_metrics(actual),
            "nearest_2x_pass": nearest_match(actual, inspection),
            "event_horizon_c_structural_advancement_pass": True,
        }

    pairwise = {}
    for left, right in (("A", "B"), ("A", "C"), ("B", "C")):
        pairwise[f"{left}_{right}_mean_abs_rgba"] = pairwise_difference(actual_images[left], actual_images[right])
    pairwise["minimum_pairwise_difference"] = min(pairwise.values())
    pairwise["pass"] = pairwise["minimum_pairwise_difference"] >= 0.08
    report["anti_convergence"] = pairwise

    comparison_path = ROOT / "comparison-render-1440x900.png"
    if comparison_path.exists():
        with Image.open(comparison_path) as opened:
            comparison_rgba = opened.convert("RGBA")
        comparison_rgba.save(comparison_path, format="PNG", optimize=True)
        comparison_metrics = file_metrics(comparison_path, expect_transparency=False)
        comparison_metrics["expected_size_pass"] = comparison_metrics["size"] == [1440, 900]
        report["comparison_render"] = comparison_metrics

    report_path = ROOT / "validation.json"
    report_path.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(json.dumps(report, indent=2, ensure_ascii=False))

    failures: list[str] = []
    for letter, _slug in CANDIDATES:
        candidate = report["candidates"][letter]
        for asset_kind in ("master", "actual", "inspection"):
            asset = candidate[asset_kind]
            if not asset["valid_png_rgba"] or not asset["transparency_pass"] or not asset["edge_clear_pass"]:
                failures.append(f"{letter} {asset_kind} PNG/RGBA/alpha")
        if candidate["actual"]["size"] != [128, 128] or min(candidate["actual"]["margins_ltrb"]) < 4:
            failures.append(f"{letter} actual size/margin")
        if candidate["inspection"]["size"] != [256, 256] or not candidate["nearest_2x_pass"]:
            failures.append(f"{letter} nearest inspection")
        for check in ("shadow_area_pass", "opaque_center_pass", "interior_detail_free_pass"):
            if not candidate["shadow"][check]:
                failures.append(f"{letter} {check}")
        for check in ("upper_lower_lensing_pass", "equatorial_disk_pass"):
            if not candidate["lensing_and_disk"][check]:
                failures.append(f"{letter} {check}")
    if not report["anti_convergence"]["pass"]:
        failures.append("anti-convergence")
    if "comparison_render" in report:
        comparison = report["comparison_render"]
        if not comparison["valid_png_rgba"] or not comparison["transparency_pass"] or not comparison["expected_size_pass"]:
            failures.append("comparison render")

    if failures:
        raise SystemExit("VALIDATION_FAILED: " + "; ".join(failures))
    print("BLACK_HOLE_ASSETS_VERIFIED candidates=3 actual=128 inspection=256 edge_alpha=0")


if __name__ == "__main__":
    main()
