# Paper-8 Laboratory Frame Kit v1

Status: production-clean modular asset kit; not wired into the runtime scene yet.

This kit translates the approved `frame-paper8-steampunk-lab-v1.png` concept into deterministic, Godot-loadable pixel assets. The original AI image remains a visual source only.

## Contract

- Authoring canvas: `1600x900`
- Logical cleanup source: `800x450`
- Authoring pixel block: `2x2`
- Palette: exact Paper-8 eight colors only
- Alpha: binary (`0` or `255`), never partial
- Import: nearest filtering, mipmaps disabled
- CRT scanlines: tile `tiles/crt_scanline_tile_8x4.png`; do not vertically stretch a complete CRT bitmap

## Folders

- `master/`: normalized full-frame references
- `modules/`: coarse cabinet references; useful for comparison, not direct runtime layout
- `bezel/`: four fixed corners and four straight edge sources
- `crt/`: six CRT module and glass proportion references
- `machinery/`: fine pipe, gauge, console, spine, and indicator cutouts
- `tiles/`: deterministic scanline, enamel edge, and bolt tiles
- `runtime/`: exact-size full-height bezel, 152px wing, unique CRT, and machinery pieces used by `gameplay_frame.tscn`
- `manifest.json`: source rectangles, dimensions, roles, and import contract

The runtime assembly preserves 152px moving wings and uses the bezel's 50px inner edge as the shared Play Field boundary. Its outside frame spans `y=0..900`; the opening spans `y=50..850`.

Rebuild and verify:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\presentation\frame_asset_kit\build_paper8_frame_kit.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\presentation\frame_asset_kit\verify_paper8_frame_kit.ps1
```
