# Paper-8 Laboratory Frame v2

Active Godot runtime frame asset kit.

- `runtime/`: nine palette-clean, binary-alpha, 2x2-grid PNGs loaded by Godot.
- `source_alpha/`: cleaned high-resolution source renders; excluded from Godot import.
- `manifest.json`: exact runtime dimensions and component roles.

The assets are independently designed from the approved full-frame reference. They are not crops of that image. Rebuild with `tools/presentation/frame_asset_kit/finalize_paper8_frame_v2.ps1` and validate with `verify_paper8_frame_v2.ps1`.
