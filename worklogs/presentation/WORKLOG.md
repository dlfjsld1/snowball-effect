# Presentation Worklog

> Append-only. 실제 작업과 검증만 기록한다.

## 2026-08-09 — S1-G4 최소 HUD

Owner: Presentation
Branch: `main` working tree

### 작업

- Core의 점수와 활성 공 수 신호를 읽기만 하는 최소 HUD를 구현했다.

### 변경

- Stage Score, Run Score, active ball count label과 source binding API.
- 표시만 초기화하는 `reset_view()`와 source disconnect 처리.
- HUD가 gameplay 값을 변경하지 않는 자동검증.

### 확인

- Primary `godot` MCP validate 4/4.
- Godot 4.7.1 headless: exit 0, `S1_G4_VERIFIED score_readonly=true ball_count=1 reset_view=display_only`.

### 다음 작업 / 주의

- Main mount와 실제 source 연결은 S1-G6 Integration 소유다.

## 2026-08-10 — Retro Pixel Arcade visual direction 문서 정교화

Owner: Presentation
Branch: `main` working tree

### 작업

- 구현 없이 기존 디자인 문서의 Retro Pixel Arcade Machine 방향을 dark retro arcade / dim CRT machine 톤으로 구체화했다.

### 변경

- 어두운 기본 팔레트, 제한적 강조색, CRT·기계 프레임 HUD 방향을 명시했다.
- Merge와 Cashout 효과의 재질을 각진 픽셀 파편·도트·사각형 스파크로 정리했다.
- 밝은 캐주얼 퍼즐풍, 파스텔, 과도한 soft bloom, 둥근 모바일 UI, 연기·마법형 파티클을 피할 방향으로 기록했다.

### 확인

- `00_VISUAL_IDENTITY`, `01_SCREEN_COMPOSITION`, `03_GAMEPLAY_EFFECTS`만 수정했다.
- runtime 코드, Scene, 테스트, Goal 상태는 변경하지 않았다.

## 2026-08-12 — V5 Ball/HUD/Black Hole Phase 디자인 동기화

Owner: Presentation
Branch: `ui-design` working tree

### 작업

- 사용자 최신 결정에 맞춰 Ball catalog, HUD genealogy, 네 Frame profile과 Galactic Black Hole 최종 국면을 문서 전반에 동기화했다.
- 승인된 V4 Frozen Enamel 방향을 계승한 팀 공유 V5 interactive HTML과 1600×900/1280×720 PNG export를 제작했다.

### 변경

- 기본 Stage chain을 Ground `[0,1,2,3,4]`, Planetary `[4,5,6,8,10]`, Galactic `[10,11,12,13,14]`로 고정하고 Lv14를 `Final Snowball (working title)`로 Black Hole 기믹과 분리했다.
- L3를 terminal profile에서 Galactic `Black Hole Phase Transition` 이후 gameplay profile로 변경했다.
- HUD에 Stage 이름과 세로 5칸 progressive reveal을 추가하고 `ball_merged(result_level, world_position)` 2인자 계약을 동기화했다.
- S3-G6/S5-G1·G2·G4/S8-G1·G4와 새 S8-G5의 Owner, Integration Point, Verification을 갱신했다.

### 확인

- `git diff --check` 통과, 변경 Markdown relative link 0건 오류, fence mismatch 0건.
- HTML selector 8/8, duplicate id 0, CSS `font-size` 14px 미만 0.
- system Chrome headless software rendering으로 1600×900 8개 화면과 1280×720 Black Hole Phase를 렌더하고 육안 점검했다.
- Godot runtime Scene/Script/Resource는 수정하지 않았고 CLI/MCP 게임 검증은 수행하지 않았다.

### 다음 작업 / 주의

- S2-G1 runtime Resource는 최신 catalog와 달라 `PENDING` 재검증이 필요하다.
- Black Hole Phase의 정확한 발동 조건은 S8 Core/Content 계약에서 확정해야 한다.
- Pause Stage Restart 계약은 이번 변경에서 수정하지 않았다.

## 2026-08-12 — V5.1 Lv14 Black Hole 명칭 복원

Owner: Presentation
Branch: `ui-design` working tree

### 작업

- 사용자 최신 결정을 우선해 Lv14 Ball의 이름과 visual key를 `Black Hole`/`black_hole`로 확정했다.
- 동명인 Lv14 BallDefinition과 Galactic 이동 Black Hole 맵 기믹을 별도 gameplay entity로 문서·Goal·목업에서 구분했다.

### 변경

- `Final Snowball (working title)` 및 `final_snowball` 구계약을 active split 문서에서 제거했다.
- Black Hole Phase 목업에서 작은 `LV14 BLACK HOLE BALL`과 거대한 `BLACK HOLE FIELD · MAP GIMMICK`을 scale·outline·field distortion으로 구분했다.
- S2-G1은 Lv14 Resource가 이미 최신 계약과 일치함을 기록하되, Lv6/Lv7/Lv9/Lv10 catalog drift 때문에 `PENDING`을 유지했다.

### 확인

- Godot runtime Scene/Script/Resource는 수정하지 않았다. 기존 `ball_14_black_hole.tres`의 display name, visual key, score를 read-only로 확인했다.
- V5.1 HTML과 Black Hole Phase PNG를 system Chrome headless로 1600×900/1280×720 재렌더하고, 작은 Ball과 큰 맵 기믹의 label·scale·outline 구분을 육안 검증했다.

## 2026-08-12 — S3-G6 Stage HUD

Owner: Presentation
Branch: `codex/s3-g6-stage-hud`

### 작업

- 현재 Stage의 이름, 남은 시간, Stage/Run Score, Clear Target을 HUD에 읽기 전용으로 표시했다.
- 현재 Stage chain을 고정 세로 5칸 genealogy로 표시하고, Stage 진입에는 첫 공만 공개하며 실제 Merge 결과가 처음 생성될 때만 다음 칸을 공개했다.

### 확인

- Godot 4.7.1 CLI headless S3-G6와 S1-G4 HUD verification: exit 0.
- Primary `godot` MCP validate 5/5, Desktop Main에서 Ground readout과 Snowflake → Snowball → Big Snowball 공개, runtime error 0.
- MCP 종료 후 clean Web release export를 In-app Browser에서 검증: Canvas와 live HUD/genealogy 정상, console warning/error 0.

## 2026-08-12 — S2-G5 Merge 표시 통합

Owner: Presentation
Branch: `codex/s2-g5-merge-presentation`

### 작업

- `ball_merged(result_level, world_position)`을 read-only 구독하는 HUD 내부 `EffectManager`를 추가했다.
- 결과 공의 catalog 이름·기본색·`fx_tier`와 `ScoreFormatter` 값으로 짧은 픽셀 파편/원형 flash 및 `VALUE` 표시를 생성한다.

### 확인 / 남은 검증

- Primary `godot` validate 7/7, Desktop Main에서 Merge 1회당 FX 1개, score 상태 불변, `10K`와 `1.00e+43` 포맷, runtime error 0을 확인했다.
- clean Web release export는 성공했다. 다만 이 환경에서는 local HTTP port bind가 `WinError 10013`으로 차단되어 browser smoke가 남아 S2-G5는 `IMPLEMENTED`로 유지한다.

## 2026-08-12 — Stage-local runtime radius 정정

- 잘못 적용했던 global Lv0~14 radius 일괄 2배 변경을 전부 되돌렸다.
- 실제 visual/collision 반지름은 현재 Stage local level 기준 `4, 8, 16, 32, 64`로 계산하도록 정정했다.
- 공유 공 Moon과 Galaxy는 다음 Stage의 local Lv0가 되면 visual/collision 반지름 모두 `4`로 다시 시작한다.

## 2026-08-13 — S5-G4 C4 Godot Frame Kit 도입

Owner: Presentation
Branch: `ui-design`

### 작업

- 승인된 C4 Selective-Waist CRT Cabinet의 투명 PNG 10개를 Presentation-owned runtime 경로로 도입했다.
- `GameplayFrame` Scene과 profile script를 추가해 L0/L1/L2/L3에서 field와 고정 폭 wing이 화면 중심 `x=800`을 기준으로 함께 이동하도록 구성했다.
- CRT shell과 phosphor glass를 별도 layer로 유지하고, 왼쪽 full housing·오른쪽 top/bottom housing·CRT가 없는 18px selective waist 구조를 반영했다.

### 변경 파일과 계약

- Goal: `S5-G4`, lane: Presentation, 상태: `IN PROGRESS`.
- 추가 Owned Files: `scripts/presentation/gameplay_frame.gd`, `assets/sprites/ui/frame/c4/**`.
- Integration-owned Main/StageManager와 S5-G3 임시 adapter는 변경하지 않았다.
- 기존 `stage_shift_started(next_definition, shift_id)` 및 `stage_shift_presentation_finished(shift_id)` wiring은 이번 frame asset 단위에서 의도적으로 제외했다.

### 확인 / 남은 검증

- 10개 PNG의 선언 크기와 partial alpha 0을 정적 검사했다.
- Scene의 `res://` 참조 11개가 모두 존재하고 `git diff --check`가 통과했다.
- L0/L1/L2/L3 중심축·field width·152px wing 위치를 자동 검증하는 Godot test Scene을 추가했다.
- Godot 4.7.1 CLI로 프로젝트 import/load exit 0, 전용 test Scene exit 0과 `4 profiles, fixed wings, centered field`를 확인했다.
- Primary `godot` MCP 3.2.2를 Codex에 등록하고 `get_project_info`에서 Godot `4.7.1.stable`과 프로젝트 구조 응답을 확인했다.
- 프레임 kit 검증은 통과했지만 Stage World·Shift presentation 전체는 남아 있으므로 S5-G4는 `IN PROGRESS`를 유지한다.

## 2026-08-13 — S5-G4 플레이 프레임 하단 레이아웃 보정

- 물리 Play Field와 시각적 Cashout corridor를 분리하고, Ground의 최대 cashout 가능 공이 완전히 퇴장할 때까지 중앙 베젤 안에 보이도록 하단 여유를 64px 확보했다.
- 왼쪽 housing은 세로 Genealogy CRT 하단 + 12px까지 축소하고, 오른쪽 상단 housing도 Item CRT 하단 + 12px까지 축소했다.
- 오른쪽 하단 Pause CRT/housing/button을 하나의 패널로 합치고 중앙 베젤과 `y=900` 바닥선을 맞췄다.
- Godot 4.7.1 CLI에서 S5-G4 frame kit 및 playable integration 검증과 S1-G5/S3-G6/S5-G3 회귀 검증이 모두 통과했다.

## 2026-08-13 — S5-G4 CRT 스캔라인 보정

- 80px CRT glass NinePatch의 중앙 행이 세로로 확대되어 긴 CRT에 굵은 검은 띠가 생기던 원인을 확인했다.
- 별도 색상 변형 에셋 대신 모든 CRT glass의 세로 stretch mode를 `TILE`로 통일해 원본 1px 스캔라인과 승인 팔레트를 유지했다.
- S5-G4 frame kit 및 playable integration Godot CLI 검증이 통과했다.

## 2026-08-14 — Pixel Design Guidelines 편입

- 외부 `PIXEL_DESIGN_GUIDELINES.md`를 기존 Foundations, Stage-local radius, Web resize, asset production 계약과 대조했다.
- logical pixel, 크기별 Ball LOD, FX·Background·HUD 밀도, AI 생성물 cleanup을 `docs/design/12_PIXEL_DESIGN_GUIDELINES.md`의 단일 제작 기준으로 편입했다.
- `1600×900`을 고정 runtime 출력으로 해석하지 않고 authoring 기준으로 제한했으며, 개별 에셋의 정수 transform과 전체 Web viewport fractional fit을 구분했다.
- runtime Scene·Script·Resource와 Goal 상태는 변경하지 않았다. 문서 링크와 핵심 계약 정적 검증이 통과했다.

## 2026-08-14 — S5-G4 Paper-8 Laboratory modular frame kit

- Owner lane: Presentation. Goal remains `IN PROGRESS`; no Integration lock was used.
- Audited the approved concept source: `1672x941`, 114,963 unique colors, and 13 exact Paper-8 pixels.
- Added a deterministic cleanup pipeline that normalizes through `800x450`, quantizes to the exact eight-color Paper-8 palette, and exports at `1600x900` with enforced `2x2` authoring blocks.
- Exported 36 modular PNGs: 3 coarse modules, 8 bezel pieces, 12 CRT references, 10 machinery cutouts, and 3 deterministic tiles.
- Added an exploded image-generation reference for component-boundary guidance only; it is explicitly excluded from runtime use.
- Fixed both round-gauge cutouts after validation found an opaque rectangular crop; dedicated ellipse masks now produce binary-alpha ornaments.
- `verify_paper8_frame_kit.ps1` passed all 36 assets for exact palette, alpha, dimensions, and pixel-grid compliance.
- Godot 4.7.1 `--import` completed successfully. The dedicated Godot test loaded all 36 PNGs as `Texture2D` and passed; the existing four-profile C4 frame regression also passed.
- Intentionally excluded runtime wiring and replacement of the current 152px C4 wings. That adoption requires a separate approved layout change.

## 2026-08-14 — S5-G4 Paper-8 runtime reassembly and field-boundary alignment

- Replaced the C4 frame scene visuals with exact-size Paper-8 runtime pieces while keeping the approved centered four-profile expansion and 152px moving wings.
- Rebuilt the central bezel as a transparent 50px frame whose outside spans `y=0..900`; removed the previous 120px top presentation gap.
- Defined the visible and physical Play Field as the bezel's inner pixel opening: L0/L1/L2/L3 widths `560/720/880/1040`, shared vertical range `y=50..850`.
- Existing Main frame wiring now applies that single Rect to Simulation, Paddle, Backdrop, and Spawn. The simulation's strict lower test removes a ball only when `ball_top > 850`, after the full sprite clears the opening.
- Added 10 runtime assembly assets, bringing the validated manifest to 46 PNGs. Removed the obsolete `crt_genealogy_132x360` intermediate after replacing it with the final 132x400 panel; it can be recreated from the source crop by restoring the old build size parameter.
- Updated the directly coupled Main integration verification expectations without changing Integration-owned runtime files or signal contracts.
- Verification: exact palette/alpha/grid `46/46`; Godot 4.7.1 asset import; Paper-8 Texture2D load; four-profile frame and ball-boundary checks; Main frame/bounds/HUD/Pause integration; S3-G6 HUD and S1-G5 Pause regressions; clean Main load.
- Native OpenGL render captured a `1600x900` L0 preview with the top and bottom frame pixels touching the viewport edges and no runtime errors.
- Goal remains `IN PROGRESS` because Stage backgrounds and Scale Shift animation are still outstanding.

## 2026-08-14 — S5-G4 Paper-8 frame v2 independent-component rebuild

- Rejected the crop-derived runtime assembly and retained the approved full-frame image only as a visual reference.
- Independently designed nine new components: one dynamic central bezel, two continuous full-height chassis, and six purpose-built CRTs.
- Removed separate machinery filler sprites from the runtime scene. Empty chassis regions now come from the continuous left/right body art instead of pasted fragments.
- Expanded each moving wing from 152px to 200px while preserving centered L0/L1/L2/L3 field widths and the authoritative `y=50..850` physics opening.
- Archived chroma and cleaned alpha sources outside Godot import; finalized runtime PNGs use the exact Paper-8 palette, binary alpha, and an enforced 2x2 authoring grid.
- Verification: `PAPER8_FRAME_V2_VERIFIED assets=9`; Godot 4.7.1 Texture2D load; four-profile frame/ball-boundary test; Main HUD/Pause integration test; native OpenGL 1600x900 capture.
- Preview: `docs/design/mockups/drafts/frame-paper8-runtime-preview-v2.png`.
- S5-G4 remains `IN PROGRESS`; Stage backgrounds and Scale Shift animation are intentionally not claimed complete.

## 2026-08-14 — S5-G4 Stage World and Scale Shift completion

- Documented two deferred improvements without implementing them: stronger open-Cashout direction cues and powered CRT phosphor/static treatment.
- Generated independent Ground, Planetary, and Galactic Stage World sources with built-in ImageGen, then normalized them to `1600x900`, approved per-Stage palettes, opaque pixels, and a strict 2x2 authoring grid.
- Ground uses snow banks/conifers plus 48 moving snow particles. Planetary uses an Earth horizon aligned to the Ground side banks, Mercury/Moon/Mars/Sun, and 28 twinkling stars. Galactic uses a separated spiral galaxy and teal nebula plus 44 twinkling stars.
- Added `BackgroundManager`, `StageAmbientLayer`, and `PresentationManager`. The `0.9s` Shift crossfades Stage World, moves the bezel and both 200px wings around center x=800, keeps HUD/Pause aligned, and emits the matching completion ID once.
- Verification: `STAGE_WORLD_BACKGROUNDS_VERIFIED assets=3 canvas=1600x900 grid=2`; Godot 4.7.1 Stage World/Shift test; frame bounds and HUD/Pause regressions; Native OpenGL Ground and mid-Shift captures at 1600x900.
- Runtime visual load: three static backgrounds total 4,320,000 pixels, approximately 16.48 MiB uncompressed RGBA; dynamic overlay peak 48 small draw-rect particles. FPS was not measured in this Goal and remains part of S5-G5 Web integration evidence.
- Preview paths: `docs/design/mockups/drafts/frame-paper8-stage-world-preview.png` and `frame-paper8-scale-shift-preview.png`.
- S5-G4 is `VERIFIED`; three-Stage Desktop/Web completion remains S5-G5.

## 2026-08-18 — S2-G5 contract repair and S6-G2 design preparation

Owner: Presentation
Branch: `fx-design`

### 작업

- `ball_merged(result_level, world_position)` 2인자 계약에 없는 score amount 추측을 제거하고 catalog name만 표시하도록 정정했다.
- D안 `FIRST CONTACT` CUT-IN을 공통 배경과 공별 문구·공 레이어로 분리하고, 대상 6종을 Ground `Giant Snowball`·`Moon`, Planetary `Supernova`·`Galaxy`, Galactic `Event Horizon`·`Black Hole`로 확정했다.
- 후속 Goal로 local Lv4 즉시 Clear 제거(S3-G7), Stage Score gauge(S3-G8), 축하 메시지·`Next Stage` 확인(S5-G6/G6I), Galactic 투명 배경(S5-G7)을 문서화했다.

### 검증

- Godot 4.7.1 CLI project load exit 0. S2-G5, S6-G1, S6-G3, S6-G4 foundation, S6-G4 wiring 검증이 모두 exit 0으로 통과했다. S6-G4 wiring 종료 시 기존 ObjectDB 12개/resource 6개 leak 진단이 남지만 test assertion과 exit code는 정상이다.
- S2-G5 fixture는 현재 Stage-local Merge 계약에 맞게 Ground chain을 명시했다. Core runtime은 변경하지 않았다.
- CUT-IN layer asset 12개는 투명 alpha와 1600×900 공통 배경 조립 규격을 사용한다.
- `git diff --check` 통과. MCP/Web은 이번 문서·asset 준비 변경에 사용하지 않았다.
- push 직전 `origin/main` `dbd62bb`를 pull해 S6-G4 VERIFIED 오디오 갱신을 병합했다. STATUS 단일 충돌은 원격 S6-G4 최신 증거와 신규 PENDING Goal을 모두 보존해 해결했으며, 병합 뒤 Godot 4.7.1 CLI project load, S2-G5, S6-G4 foundation/wiring, Main 120-frame smoke가 모두 exit 0이었다.

### 제외

- S6-G2 runtime controller, pause/handoff, Run-scoped 중복 억제는 구현하지 않았다.
- S3-G7/S3-G8/S5-G6/S5-G6I/S5-G7은 PENDING 문서 계약이며 runtime 파일을 수정하지 않았다.
- 사용자가 별도로 결정한 Stage Restart 계약은 변경하지 않았다.

## 2026-08-19 — S6-G6 Minimal Final Settlement presentation

Owner: Presentation
Branch: `fx-design`

### 작업

- `TIME_UP_LOCKED` 뒤 simulation render snapshot을 read-only로 캡처해, 단일 `Node2D`가 최대 64개 표본만 그리는 0.5초 pixel dissolve·score stream을 구현했다.
- HUD Stage Score는 authoritative score를 변경하지 않고 presentation 동안 표시값만 count-up한 뒤 최종값에 고정한다.
- `final_settlement_presentation_finished()`를 exactly once 제공하며 Settlement 계산·공 제거·Clear/Failure 판정은 수정하지 않았다.
- 실제 순서 대기는 `S6-G6I`로 분리했다. 활성 `S8-G4` Integration lock 때문에 `stage_manager.gd`와 Main scene은 변경하지 않았다.

### 검증

- Godot 4.7.1 CLI: `S6_G6_VERIFIED samples=64 duration=0.5 score_countup=true completion=1 core_readonly=true`.
- S6-G1 FX budget, S3-G6 Stage HUD 회귀 통과.
- Main 120-frame smoke는 runtime error 없이 종료했으며 기존 ObjectDB 3개/resource 1개 leak 경고가 남았다.
- Native Main을 실행해 `F7` Time Up Score 경로로 확인할 수 있게 했다.

### 제외

- Presentation 완료 전 Core의 Clear/Failure/Shift 진행을 대기시키는 Integration wiring.
- Web Browser 시각 검증과 최종 성능 Gate.

## 2026-08-20 — S8-G5 Black Hole Phase presentation

Owner: Presentation
Branch: `fx-design`

### 작업

- `black_hole_phase_started(phase_id, from_rect, to_rect)`를 소비하는 `PresentationManager` producer를 구현했다. L2 `880`에서 L3 `1040`으로 Frame, 표시용 Play Field side fill, 고정 200px HUD housing을 중심 X `800` 기준 좌우 각 80씩 함께 확장하고 matching `phase_id` 완료를 정확히 한 번 발행한다.
- BH-01·BH-03/04 draft를 runtime 방향으로 사용해 단일 draw node에 compact black core, 4px cyan/teal event horizon, 300-unit dashed influence ring, near-field arc, sparse orbit pixel과 최대 4개 motion marker를 조립했다. shader나 개별 particle Node는 사용하지 않는다.
- phase 완료 뒤 `Galactic` Stage 이름, gameplay HUD, persistent Black Hole visual을 유지한다. terminal snapshot은 두 core mutual orbit·압축→pixel ring/explosion을 재생하고 gameplay HUD/Pause를 숨긴 뒤 `black_hole_finale_presentation_finished(phase_id)`를 한 번 발행한다. S8-G3 Result UI 자체는 수정하지 않았다.
- Reduced Effects는 phase 0.18초/finale 0.34초로 단축하고 trail을 생략하지만 상태명, exact field edge, core/horizon, orbit/explosion을 보존한다.
- `reset_black_hole_presentation()`이 active Tween을 kill하고 Run generation을 증가시켜, Retry 뒤 같은 숫자의 phase ID가 재사용돼도 이전 Run callback이 완료로 들어오지 않게 했다.

### 검증

- Godot 4.7.1 CLI project editor load/parse: exit 0.
- 전용 scene: `S8_G5_VERIFIED phase_completions=3 finale_completions=2 field=880_to_1040 symmetric=80 core_ring=true influence=true reduced=true stale_safe=true core_readonly=true`.
- 회귀: S5-G4 Stage World Shift, S3-G6 HUD, S6-G6 Final Settlement 모두 exit 0. Main 120-frame headless smoke도 runtime error 없이 exit 0이며 기존 ObjectDB 3개/resource 1개 leak warning은 유지된다.
- 기존 `s5_g4_frame_kit_verification.gd`는 이번 변경 전부터 현재 `32 logical units` safety strip과 불일치하는 구 assertion(`field.size.y == 800`, visual/logical Rect 동일)을 사용해 line 25에서 실패한다. `gameplay_frame.gd`는 S8-G5에서 수정하지 않았고 전용 test는 현행 logical Rect를 사용한다.
- Native OpenGL Compatibility, Intel Arc 130V에서 1600×900 phase/finale 캡처를 확인했다. persistent phase 60-frame 측정은 평균 `61.3 FPS`, 최저 `54.9 FPS`, 최대 frame `18.21ms`였다.
- 현재 세션에는 Primary `godot` MCP 도구가 제공되지 않아 MCP runtime 검증은 수행하지 않았다. CLI/native 성공을 프로젝트 기준선으로 사용했다.

### Integration handoff / 제외

- S8-G4가 `configure_black_hole_sources(stage_manager, simulation)`과 phase/finale 완료를 Main에 연결하고 `auto_complete_black_hole_phase_presentation` 임시 adapter를 제거해야 한다.
- Integration은 terminal snapshot을 보관한 뒤 matching finale 완료에서만 S8-G3 Result를 표시하고, Retry/Main에서 `reset_black_hole_presentation()`을 호출해야 한다.
- `scripts/core/game_manager.gd`, `scripts/core/stage_manager.gd`, `scenes/main/main.tscn`, `tests/integration/**`, S8-G3 Result UI, S8-G4-owned 파일은 수정하지 않았다.
- CUT-IN, Galactic 투명 배경, Stage Score gauge, Clear 확인, legacy local Lv4 종료 계약, Web Browser 전체 Run은 의도적으로 제외했다.

## 2026-08-20 — S5-G7 Galactic transparent Stage World

Owner: Presentation
Branch: `fx-design`

### 작업

- 기존 opaque Galactic 이미지를 runtime에서 제거하고 완전 투명 plate 위에 stars, galaxy, nebula를 각각 alpha-composite하는 네 Sprite layer 구조로 바꿨다. 생성 소스는 기존 승인 구도를 보존한 ImageGen background-extraction 결과이며, runtime asset은 1600×900, Paper-8 palette, nearest 2×2 grid로 정규화했다.
- Ground/Planetary는 기존 단일 opaque texture 경로와 ambient behavior를 유지했다. Galactic의 중앙 gameplay negative space를 보존하고 galaxy/nebula alpha를 제한해 L2/L3 Balls, Paddle, moving Black Hole horizon, Frame, HUD 대비를 확보했다.
- `BackgroundManager.set_reduced_effects(enabled)`는 Galactic composite alpha를 낮추고 ambient twinkle process를 중지한다. 상태·Frame·HUD·Black Hole horizon 같은 필수 cue는 제거하지 않는다.
- `tests/presentation/s5_g7_galactic_stage_world_verification.*`와 runtime capture fixture를 추가하고 기존 S5-G4 test를 multi-layer manager 구조에 맞춰 갱신했다.
- `project.godot`, Main Scene, Core, Integration tests, S8-G5 runtime 파일은 수정하지 않았다. 활성 S8-G4 Integration lock도 사용하지 않았다.

### 검증

- Godot 4.7.1 headless editor load/parse: exit 0. 기존 dirty S6 fixture의 누락 `.uid` cache 복구 warning 외 S5-G7 parse/runtime error는 없었다.
- 전용 scene: `S5_G7_VERIFIED alpha_layers=4 plate_visible_blocks=0 stars=1493 galaxy=38941 nebula=63433 l2_avg_luma=0.0101 l2_bright_ratio=0.0033 l3_avg_luma=0.0127 l3_bright_ratio=0.0078 paddle_contrast_l3=15.21 horizon_contrast_l3=13.80 reduced=true ground_planetary_opaque=true`.
- 회귀: `S5_G4_STAGE_WORLD_SHIFT_VERIFIED backgrounds=3 dynamic_ambient=true shift_once=true`, `S8_G5_VERIFIED phase_completions=3 finale_completions=2 field=880_to_1040 symmetric=80 core_ring=true influence=true reduced=true stale_safe=true core_readonly=true`, `S3_G6_VERIFIED stage_time=true score_readonly=true genealogy_reveal=true`, legacy `STAGE_WORLD_BACKGROUNDS_VERIFIED assets=3 canvas=1600x900 grid=2`.
- Native OpenGL Compatibility, Intel Arc 130V에서 L2/L3/Reduced 1600×900 캡처를 확인했다. normal 120-frame 평균 `60.3 FPS`, 최저 `42.3 FPS`, 최대 frame `23.66ms`; reduced 120-frame 평균 `60.7 FPS`, 최저 `51.9 FPS`, 최대 frame `19.27ms`였다.
- Primary `godot` MCP는 현재 세션에 제공되지 않아 별도 runtime MCP 검증은 수행하지 않았다.
- Web debug export 명령 `Godot_v4.7.1-stable_win64_console.exe --headless --audio-driver Dummy --path . --export-debug Web build/s5-g7-web/index.html`은 Godot 4.7.1 export template `web_nothreads_debug.zip`과 `web_nothreads_release.zip`이 설치되지 않아 실패했다. 따라서 Browser screenshot/console Gate를 수행하지 못했고 Goal은 `IMPLEMENTED`로 유지한다.

### Integration handoff / 제외

- S8-G4가 향후 Reduced Effects 설정을 wiring할 때 기존 S8-G5 `PresentationManager.reduced_effects`와 함께 `BackgroundManager.set_reduced_effects(enabled)`를 동일 값으로 호출해야 한다. S8-G5-owned `presentation_manager.gd`를 이번 Goal에서 수정하지 않았다.
- Galactic key, L2 `880`, L3 `1040`, frame/HUD source interface는 변경하지 않았으므로 S8-G4에 필요한 추가 display/source adjustment는 없다.
- S6-G2, S3-G8, S5-G6, S6-G6I, legacy local Lv4 Stage-clear 계약은 구현하지 않았다.

## 2026-08-20 — S5-G7 Web Browser Gate completion

Owner: Presentation
Branch: `fx-design`

### Template setup

- Godot executable은 `C:\Users\gktjd\AppData\Local\Programs\Godot\Godot_v4.7.1-stable_win64_console.exe`, runtime version은 `4.7.1.stable.official.a13da4feb`다.
- 공식 `godotengine/godot-builds` 4.7.1-stable release의 `Godot_v4.7.1-stable_export_templates.tpz`를 사용했다. package SHA-256은 GitHub release digest와 일치한 `86409db6200b6f8fd3230989c2d2002851f3dd18acf11d7bdbafddf5a0dd0f72`다.
- `%APPDATA%\Godot\export_templates\4.7.1.stable`에 official `version.txt`, `web_nothreads_debug.zip`, `web_nothreads_release.zip`만 설치했다. Web archive SHA-256은 각각 `eb6ca0ca168c405e73b20a4439d6dc048d74ae65eb31cc7675b6bc3cf7ad1815`, `b7b7d7da29fc6cc2f4934fdd26cc571a40e7af57f716ea3eb7e18da720dae28a`다.

### Web export / Browser verification

- dirty working tree를 보존한 채 `Godot_v4.7.1-stable_win64_console.exe --headless --audio-driver Dummy --path . --export-debug Web <scoped-temp>\index.html`을 실행해 exit 0을 확인했다. Main HTML/JS/WASM/PCK와 S5-G7 capture build의 같은 네 파일은 local HTTP에서 모두 200이었다.
- actual browser는 Chrome `151.0.7922.138`, WebGL2 renderer는 Intel Arc 130V Direct3D11이었다. Main Canvas startup, focus, `A` 입력 전달 뒤 120 browser RAF는 평균 `60.47 FPS`, 최저 `59.17 FPS`, 최대 frame `16.90ms`; console warning/error, exception, network failure는 0이었다.
- official Web binary는 command-line scene override를 막으므로 repository 밖 disposable project copy에서만 `run/main_scene`을 기존 `s5_g7_galactic_stage_world_runtime_capture.tscn`으로 바꿨다. Web debug의 `get_tree().quit()` keepalive assertion을 피하고 CDP가 pure L2를 캡처하도록 disposable copy의 fixture에만 Web hold/no-quit를 적용했다. 저장소의 `project.godot`, capture fixture, runtime implementation은 수정하지 않았다.
- 1600×900 actual Web Canvas에서 L2 `880`, transition `880→1040`, L3 `1040`, Reduced screenshot을 확인했다. 투명 Galactic plate와 stars/galaxy/nebula가 바깥 void와 합성되고 Balls, Paddle, Black Hole horizon, Frame, HUD가 읽혔다.
- fixture `S5_G7_CAPTURED`: normal 평균 `60.5 FPS`, 최저 `57.8 FPS`, 최대 frame `17.30ms`; reduced 평균 `60.4 FPS`, 최저 `57.5 FPS`, 최대 frame `17.40ms`. 최종 browser run의 console warning/error, exception, network failure는 모두 0이었다.
- repository의 전용 CLI scene도 다시 실행해 `S5_G7_VERIFIED alpha_layers=4 plate_visible_blocks=0 stars=1493 galaxy=38941 nebula=63433 l2_avg_luma=0.0101 l3_avg_luma=0.0127 paddle_contrast_l3=15.21 horizon_contrast_l3=13.80 reduced=true ground_planetary_opaque=true`와 exit 0을 확인했다.
- vendored gstack browse Windows bundle은 `server-node.mjs` 부재로 실행되지 않아 설치·수정하지 않았고, 이미 설치된 system Chrome을 CDP로 직접 제어했다. Primary `godot` MCP는 세션에 없었다.

### 상태 / 제외

- Native와 Web screenshot, Web export/startup/Canvas/console Gate가 모두 충족되어 S5-G7을 `VERIFIED`로 변경했다.
- Core/Integration files, project configuration, export preset, runtime implementation은 변경하지 않았다. disposable validation output은 `%TEMP%\s5-g7-web-validation-20260820`에 남겼다.

## 2026-08-20 — S3-G8 Stage Score gauge

Owner: Presentation
Branch: `fx-design`

### 작업

- 기존 HUD Score CRT 안에 `stage_score / clear_score`를 0~100%로 표시하는 112×18 pixel gauge를 추가했다. 25/50/75% tick, percent label, 목표 달성 시 beige/gold fill을 사용해 Paper-8/CRT 스타일을 유지했다.
- 기존 `score_changed(stage_score, run_score)`와 `StageDefinition.clear_score`만 read-only로 소비한다. 감소한 점수는 fill을 줄이고, 초과 점수는 100%로 clamp하며, Stage score reset은 0%로 되돌린다.
- `clear_score <= 0`인 Galactic에서는 gauge 전체를 숨긴다. Presentation은 Clear/Failure/Shift를 판정하거나 Core state를 변경하지 않는다.
- S6-G6 Final Settlement 중에는 authoritative 최종값으로 먼저 뛰지 않고 기존 Stage Score count-up의 presentation 값과 gauge를 함께 보간한 뒤 최종 authoritative 값에 고정한다.

### 검증

- Godot 4.7.1 editor load/parse: exit 0.
- 전용 headless scene: `S3_G8_VERIFIED zero=true partial=true complete=true overflow_clamped=true decrease=true reset=true galactic_hidden=true core_readonly=true`.
- 회귀: S1-G4 HUD, S3-G6 Stage HUD, S6-G6 Final Settlement, S8-G5 Black Hole Phase, S5-G4 Stage World Shift가 모두 exit 0.
- Main 120-frame headless smoke는 exit 0이며 기존 shutdown-only ObjectDB 3개/resource 1개 leak warning은 유지된다.
- Native OpenGL Compatibility, Intel Arc 130V에서 1600×900의 0%, 63%, 100%, Galactic hidden 캡처를 직접 확인했다. partial gauge 120-frame 측정은 평균 `60.8 FPS`, 최저 `51.6 FPS`, 최대 frame `19.40ms`였다.
- 현재 세션에는 Primary `godot` MCP가 제공되지 않아 MCP 검증은 수행하지 않았다. CLI/headless와 실제 Native renderer를 기준선으로 사용했다.

### 상태 / Integration handoff / 제외

- S3-G8의 Goal-specific Verification과 Native 시각 확인을 충족해 `VERIFIED`로 변경했다.
- 활성 S8-G4 Integration lock과 잠긴 파일은 사용하지 않았다. `project.godot`, Main scene, StageManager, GameManager, StageRuntime, StageDefinition, Integration test는 변경하지 않았다.
- S3-G7 local Lv4 비종료 migration, S5-G6 Clear 확인 UI, S6-G6I Settlement wiring은 구현하지 않았다.
- S3-G8 자체의 Goal Verification에는 Web Browser가 요구되지 않고 S3 Slice는 S3-G7 미완료로 종료할 수 없어 Web export/browser를 실행하지 않았다. S3 Slice Exit Web smoke는 후속 통합 Gate에 남는다.
## 2026-08-20 — S8-G5 Black Hole Phase Presentation 구현

- Owner lane: Presentation/UI
- Goal: S8-G5
- Owned files: `scripts/presentation/presentation_manager.gd`, `scripts/presentation/black_hole_presentation_overlay.gd`, `scenes/backgrounds/gameplay_frame.tscn`, `scenes/effects/black_hole_presentation_overlay.tscn`, `tests/presentation/s8_g5_black_hole_presentation_verification.*`.
- 구현: Galactic L2→L3 Frame/HUD visual profile 보간, 중복·stale phase ID 방어, Black Hole field pulse/ring overlay, terminal two-Black-Hole orbit·burst overlay, gameplay HUD/Pause hide와 retry-reset API를 추가했다.
- Integration contract: `black_hole_phase_presentation_finished(phase_id)` 및 `black_hole_finale_presentation_finished()`를 제공한다. S8-G4는 실제 Main에서 phase 요청/완료와 terminal Result 지연 표시를 연결해야 한다.
- Verification: Godot 4.7.1 CLI/headless `s8_g5_black_hole_presentation_verification.tscn` exit 0 (`l2_to_l3=true`, phase ID single-flight, finale once); `s5_g4_stage_world_shift_verification.tscn` exit 0.
- 상태: Presentation 산출물은 `IMPLEMENTED`; S8-G4 실제 wiring과 S8-G3 Result handoff 이후 Desktop/Web 최종 관찰이 남아 있다.

## 2026-08-20 — Pause/Retry B-design control module

- Owner lane: Presentation/UI
- Scope: 기존 우측 하단 Pause/Retry CRT 모듈을 사용자가 선택한 B안(이중 원형 청록 CRT + 밝은 금속 베젤)으로 원본 `176×104` 스프라이트의 팔레트·도트 밀도·외곽 배치를 유지해 직접 편집한 런타임 스프라이트로 교체했다.
- Owned files: `assets/sprites/ui/frame/paper8_lab_v2/**`, `scenes/backgrounds/gameplay_frame.tscn`, `scenes/ui/pause_menu.tscn`.
- Compatibility: 기존 `pause_requested`/`retry_requested` 신호와 Button 라벨 렌더링은 유지한다. 새 원형 버튼의 중심·면적에 맞춰 투명 Button 입력 영역을 재정렬했다.
- Verification: 새 PNG를 Godot import한 뒤 Web release export `savepack` exit 0을 확인했다. 이 환경의 standalone headless scene test는 `user://logs` open 실패 뒤 signal 11로 종료되어 UI action regression 증거로 사용하지 않았다.

## 2026-08-20 — Empty current-item slot

- Owner lane: Presentation/UI
- Scope: 우측 `CURRENT ITEM` CRT의 중앙 녹색 필드를 빈 슬롯 유휴색 `#1F244B`로 교체했다. 프레임·파이프·indicator는 보존했다.
- Intent: 아이템 미보유 상태가 활성 녹색 표시처럼 보이지 않도록 한다.
- Verification: 런타임 `176×300` 텍스처에서 중앙 연결 필드 20,956px만 변경했으며 Web release export를 재생성한다.

## 2026-08-20 — S3-G8 20-cell Stage Score gauge 및 Pause/Retry CRT 재구성

- Owner lane: Presentation/UI. Goal S3-G8은 `IMPLEMENTED`로 전환했다.
- 우측 빈 CRT에 `stage_score / clear_score`를 read-only로 표시하는 20칸 세로 게이지를 추가했다. 0점에는 셀을 보이지 않고, 점수에 따라 아래부터 채우며 70%는 14칸, overflow는 20칸으로 clamp한다. 다음 Scale Shift target이 없는 Galactic은 gauge를 숨긴다. HUD는 Clear 판정이나 점수 변경을 하지 않는다.
- Pause/Retry는 별도 이미지를 덧붙이지 않고 원본 `crt_pause_v2_176x104`의 녹색 버튼 내부 픽셀을 직접 원형 청록 CRT/밝은 금속 베젤로 치환해 `crt_pause_b_v2_176x104`를 재생성했다. 원래 cabinet 외곽·상단 표시등·하단 패널은 그대로 보존했고, 실제 Button hit 영역과 글자를 두 원 중심에 맞췄다.
- 변경: `scripts/ui/stage_score_gauge.gd`, HUD scene/script, pause layout, `build_pause_b_from_original.ps1`, runtime PNG와 manifest, S3-G8 verification scene.
- Verification: Godot 4.7.1 Web release export가 `[ DONE ] savepack`으로 성공해 새 script/scene/texture가 Web PCK에 포함됨을 확인했다. 이 환경에서 headless scene test는 project assertion 전에 `user://logs`를 열지 못하고 Godot process가 signal 11로 종료되어, S3-G8의 실제 Web visual/hit-area 확인은 남겼다.

## 2026-08-20 — Pause modal terminal overlay ordering

- Black Hole overlay가 GameplayFrame 내부 `z_index=100`으로 Pause modal보다 앞에 그려지던 회귀를 수정했다.
- PauseMenu root를 `z_index=200`으로 올려 Pause modal과 dim layer가 Black Hole Phase/Finale overlay를 포함한 gameplay presentation보다 항상 전면에 렌더링되게 했다.
- Godot 4.7.1 Web release export `[ DONE ] savepack` 성공. 실제 Galactic Pause 화면은 Web 수동 확인이 남아 있다.

## 2026-08-20 — Pause/Retry B안 기준 재적용

- 직전 직접 픽셀 재구성이 사용자가 채택한 B안의 넓은 강철 원형 베젤·중앙 결합부·외곽 파이프 비율과 다르다는 피드백을 반영했다.
- 사용자가 제공한 B안의 버튼 모듈을 기준 자산으로 보존하고, `176×104` runtime PNG를 nearest-neighbor로 rasterize했다. 두 버튼의 명칭은 자산 내부 도트 텍스트만 사용하며, 별도 Godot Button 텍스트를 제거해 중첩을 막았다.
- 기존 hit 영역은 원형 버튼 중심 `(50, 54)`·`(126, 54)`과 일치한다. Runtime PNG는 `176×104`, binary alpha(부분 alpha 0px), 80개의 투명 모서리 픽셀을 확인했다.
- Godot 4.7.1 Web release export `[ DONE ] savepack` 성공.

## 2026-08-20 — Pause/Retry B안 외곽 판 제거

- B안 전체의 검은 배경 판이 원래 오른쪽 하단 CRT 위에 덧씌워진 것처럼 보인다는 피드백을 반영했다.
- `crt_pause_v2_176x104`를 최종 베이스로 유지하고, 내부 녹색 사각 버튼 픽셀만 빈 CRT색으로 치환한 뒤 B안의 두 원형 버튼과 중앙 결합 볼트 영역만 직접 복사했다. 따라서 외곽 투명 alpha·상단 표시등·원래 하우징의 도트 픽셀은 유지되고, 검은 바깥 여백은 존재하지 않는다.
- Godot 4.7.1 Web release export `[ DONE ] savepack` 성공.

## 2026-08-20 — Pause/Retry B안 수직 정렬

- 원형 버튼과 중앙 결합부가 원래 하우징에 비해 낮아 보이는 피드백을 반영해 B안 삽입 픽셀만 4px 위로 이동했다.
- 실제 Button hit 영역 중심(`y=52`)과 새 원형 버튼 중심(`y=51`)을 맞췄다. Web release export `[ DONE ] savepack` 성공.

## 2026-08-20 — Pause/Retry B안 수직 정렬 재보정

- 4px 보정이 실제 게임 크기에서 충분히 드러나지 않아, B안 삽입부를 원래 기준에서 총 8px 위로 옮겼다.
- hit 영역도 `y=12` offset으로 함께 이동해 원형 버튼 중심(`y=47`)과 맞췄다. Web release export `[ DONE ] savepack` 성공.

## 2026-08-20 — Pause/Retry 위치 이동 취소

- 사용자 지시에 따라 4px 및 8px 수직 위치 이동을 모두 취소했다. 원형 버튼·중앙 결합부와 Button hit 영역은 원래 기준 좌표로 복귀했다.
- 다음 보정은 node/asset translation이 아니라 원본 CRT 내부의 도트 픽셀 재작화로만 수행한다. Web release export `[ DONE ] savepack` 성공.

## 2026-08-20 — S5-G6 Stage Clear 확인 UI

- Final Settlement Score Clear 뒤 gameplay를 바꾸지 않는 `StageClearPanel`을 추가했다. panel은 authoritative snapshot의 Stage 이름/점수와 `NEXT STAGE` action만 표시하며 `clear_id` 요청을 한 번 발행한다.
- 통합 검증에서 panel 표시, focus, matching request 이후 hide를 확인했다.

## 2026-08-21 — S8-G5 final player-path verification

Owner: Presentation

- 사용자 실제 플레이로 첫 Black Hole Snowball 뒤 phase 진입·기믹 생성, L2→L3 Frame/HUD 확장 뒤 Galactic 재개, 두 번째 Black Hole 충돌 뒤 finale→Result 경로를 확인했다.
- 기존 S8-G5 CLI phase/finale verification과 S5-G4 regression evidence를 합쳐 S8-G5를 `VERIFIED`로 갱신했다.

## 2026-08-21 — fx-design/latest Main Presentation 병합 해소

Owner: Presentation / senior integration

- latest Main의 Pause/Retry B, 90px frame margin, 단일 `BlackHolePresentationOverlay`, canonical 20-cell Stage Score gauge를 active scene wiring으로 유지했다. 로컬의 중복 horizontal gauge와 중복 Black Hole effect mount는 제거했다.
- S6-G6 Final Settlement의 read-only Stage Score count-up를 canonical gauge에 연결하고, S5-G7 Galactic alpha world와 S8-G5 reduced-effects·run-generation·duplicate/stale callback 방어를 보존했다. 외부 finale 완료 계약은 latest Main caller와 맞는 no-argument `black_hole_finale_presentation_finished()`로 정렬했다.
- Godot 4.7.1 CLI/headless에서 S3-G8 `cells=20 progress=70pct_14cells`, S5-G4 Stage World, S5-G7, S6-G6, latest S8-G5와 enhanced S8-G5 검증이 모두 exit 0이었다. Main headless와 Native OpenGL Compatibility smoke도 exit 0이며 Native renderer는 Intel Arc 130V/OpenGL 3.3을 사용했다.
- Web release export는 임시 디렉터리로 exit 0이었다. 브라우저 smoke는 `browse`의 Windows `server-node.mjs` 번들이 없어 실행하지 못했고 프로젝트 파일을 바꾸는 일회성 빌드는 수행하지 않았다. Primary Godot MCP는 현재 세션에 제공되지 않아 CLI/Native를 baseline으로 사용했다.
- 기존 latest Main에서도 재현되는 stale fixture 세 건은 범위 밖으로 남겼다: Pause B 이전 위치/Paddle 경계를 기대하는 S5-G4 playable, obsolete `TOP_BALL_CLEAR`를 호출하는 shift wiring, Pause B 추가 전 9개 asset count를 기대하는 frame-v2 asset 검증. Main smoke의 shutdown-only ObjectDB 3개/resource 1개 warning도 유지된다.
- Integration lock은 없으며 released 상태를 유지한다. 보호된 Time CRT 디자인 파일 세 개는 이 병합에서 편집·스테이징하지 않았다.

## 2026-08-21 — S5-G6 Stage Clear 확인 UI 재활성화

Owner: Presentation/UI

- 최신 사용자 지시에 따라 2026-08-20 automatic Shift 방향을 supersede하고 `SCORE_CLEAR → CLEAR_LOCKED → SETTLING → CLEARED (matching Next Stage 대기) → SHIFTING` 계약을 권위 문서에 복원했다. Clear 판정과 Settlement는 즉시 유지하고 Shift 시작만 `clear_id` 확인 뒤로 미룬다. automatic 구현/검증 기록은 삭제하지 않고 당시 역사적 evidence로 표시했다.
- self-contained `StageClearPanel`과 mock verification/capture scene을 추가했다. Panel은 deep-copied `outcome=CLEARED` snapshot과 별도 `clear_id`만 소비해 완료 Stage, Stage Score, Run Score, `NEXT STAGE`를 표시하고 Core/StageManager/GameManager/score/timer/spawn/Paddle/Shift에 접근하지 않는다.
- 실제 Godot Button focus와 Enter 입력, first press 1회, duplicate/hidden/stale callback 억제, matching hide, Retry/Main/new Run reset, process-lifetime stale-ID high-water, Galactic/failure/Result 제외, reduced-effects를 검증했다.
- Paper8 v2 central bezel, 청록 CRT glass/scanline, 황동 bezel/bolt, 승인 팔레트와 nearest filtering을 재사용했다. Time Bonus와 Result/failure 문구는 표시하지 않는다.
- Godot 4.7.1 CLI/headless: S5-G6 marker와 S1-G4, S3-G6, S3-G8, S5-G4 Stage World/Shift, S5-G7, S6-G6 회귀가 모두 exit 0. S3-G6 fixture의 기존 hard-coded `TARGET 4M`만 현재 StageDefinition `4e8` source-of-truth formatter assertion으로 교정했다.
- Main 120-frame headless smoke는 exit 0. 기존 shutdown-only ObjectDB 3개/resource 1개 warning은 그대로다.
- Native OpenGL Compatibility / Intel Arc 130V capture: PNG error 0, 120 frames 평균 `60.1 FPS`, 최대 frame `19.56ms`. Capture: `C:/Users/gktjd/AppData/Roaming/Godot/app_userdata/Snowball Effect/s5_g6_stage_clear_panel_capture.png`.
- 상태는 `IMPLEMENTED`다. Main mount, `stage_clear_ready`, matching request consumer, 별도 `shift_id` 발급, reset wiring과 Desktop/Web 3-Stage 확인은 Integration-owned S5-G6I `PENDING`으로 남겼다. 개별 producer 계약은 Native layout capture까지이며 Main이 mount하지 않아 Browser에서 도달할 수 없으므로 이번 Goal에서 Web export/browser 검증을 요구하거나 주장하지 않는다.
- Integration-owned 파일과 Integration tests는 변경하지 않았다. Integration lock은 없으며 `project.godot`, Main, StageManager, GameManager는 untouched다. 기존 dirty Time CRT `docs/design/11_FX_CATALOG.md`와 `docs/design/mockups/approved-fx/`도 보존했다.

## 2026-08-21 — Time CRT Pulse 승인 디자인

Owner: Presentation / design-only

- ST-02 시간 부족 경고와 ST-03 Time Up Lock의 승인 방향을 `A · CRT PULSE`로 확정했다. normal → low-time → time-up 상태 변화는 Time CRT 숫자, 제한된 phosphor halo, 짧은 scanline jitter 안에서만 표현한다.
- cabinet frame, corner lamp, side rail을 전역 경보처럼 점멸하지 않으며 Settlement, Score Clear, 실패를 예고하거나 Core 판정을 대신하지 않는다.
- 승인 기준 이미지는 `docs/design/mockups/approved-fx/time-crt-pulse-v1.png`, 사용 범위와 비계약 요소는 같은 폴더의 `README.md`, authoritative FX 규칙은 `docs/design/11_FX_CATALOG.md`에 기록했다.
- 이번 기록은 문서와 디자인 에셋 승인만 다룬다. HUD/Time CRT runtime 구현, Core/Integration 시간 판정, Web/Native runtime evidence는 추가하거나 변경하지 않았으며 후속 구현 전까지 `PENDING`이다.

## 2026-08-21 — S8-G5 active renderer 출고 리뷰 보정

Owner: Presentation

- 출고 전 리뷰에서 `BlackHolePhaseEffect`가 작성·검증됐지만 active `GameplayFrame`은 reconciliation 이전의 중앙 placeholder overlay를 계속 mount하고 있음을 확인했다.
- active scene을 `BlackHolePhaseEffect`로 교체하고 PresentationManager가 read-only simulation snapshot, phase field progress, finale progress를 이 단일 draw node에 전달하도록 정렬했다. Main/Core/Integration 신호와 gameplay state는 변경하지 않았다.
- S8-G5 verification은 active node type과 그 node의 실제 visual metrics를 직접 확인하도록 보강했다. no-argument finale 완료 handoff와 run-generation/stale callback 방어는 유지한다.

## 2026-08-21 — S6-G6 Settlement reset 출고 리뷰 보정

Owner: Presentation

- Final Settlement draw node가 metadata 기반 gameplay FX registry 밖에서 관리되어 Retry/Main reset 중 남을 수 있던 lifecycle 누락을 수정했다.
- `reset_runtime_fx()`와 반복 Settlement 시작이 active draw node의 processing을 중지하고 retire하며, 완료 callback은 현재 active instance와 일치할 때만 한 번 수락한다.
- S6-G6 verification에 effect 진행 중 reset 뒤 stale draw node 제거와 다음 Run으로 completion이 유출되지 않는 회귀를 추가했다. Settlement 계산·점수·Stage state는 변경하지 않았다.

## 2026-08-21 — Design mockup export·Time CRT handoff 보정

Owner: Presentation / design-only

- `export_filter="all_resources"`에서 문서용 mockup PNG가 Web payload로 import될 수 있어 `docs/design/mockups/.gdignore`로 전체 mockup tree를 runtime import/export 대상에서 제외했다. repository 문서와 Markdown 링크는 유지한다.
- Time CRT 승인 계약에 Reduced Effects의 정적 황색 outline·상태 문구 fallback과 Time Up 감광 cleanup 경계를 추가했다.
- 런타임 HUD/Time 구현이나 Core/Integration 판정은 변경하지 않았으며 후속 구현 상태는 계속 `PENDING`이다.

## 2026-08-21 — Presentation lifecycle 최종 출고 보정

Owner: Presentation

- Main Menu의 실제 `StageManager.READY` 전환에서도 active Final Settlement draw node를 즉시 retire하도록 EffectManager 상태 소비를 보강하고, verification이 직접 reset helper 대신 이 READY 경로를 실행하도록 수정했다.
- S8-G5 renderer 교체 뒤 consumer가 사라진 기존 `BlackHolePresentationOverlay` scene/script/UID를 제거했다. active `BlackHolePhaseEffect`와 외부 Core/Integration handoff는 그대로 유지한다.

## 2026-08-21 — Ground Lv0–Lv4 production ball assets

Owner: Presentation / delegated game-asset implementation

- 사용자의 명시적 구현 승인으로 Ground `Snowflake/Snowball/Big Snowball/Giant Snowball/Moon`만 실제 runtime diameter `8/16/32/64/128px` native grid에 deterministic hand-authored PNG로 제작했다. 리뷰 보드는 silhouette/mass/motif 참조로만 사용했고 ImageGen 출력이나 board crop은 final asset에 사용하지 않았다.
- `assets/sprites/balls/ground/manifest.json`에 centered anchor, 1px canonical grid, 11색 family palette, binary alpha, nearest, mipmap off와 개별 motif를 기록했다. 실제 불투명 색 수는 level 순서대로 `6/6/8/8/9`다.
- 기존 `BallDefinition.texture` 5개와 global-level MultiMesh batch를 연결했다. renderer는 exact runtime diameter와 source texture 크기가 일치할 때만 texture를 사용해 Ground hero Moon 128px를 Planetary local Lv0 8px로 축소하지 않는다. exact-size LOD가 없는 경우 기존 procedural circle fallback을 유지한다.
- simulation snapshot, radius transform, collision, mass, score, Merge/Cashout/Stage data는 변경하지 않았다. Integration-owned 파일과 lock은 사용하지 않았고 Goal 상태도 변경하지 않았다.
- 자동 검증: `GROUND_BALL_ASSETS_VERIFIED sizes=8/16/32/64/128 alpha=binary palette_colors=[6, 6, 8, 8, 9] nearest=true mipmaps=false bindings=5 fallback_levels=5-13`; `S2_G1_VERIFIED`; `S4_G4_MULTIMESH_VERIFIED`; generator 재실행 전후 5개 SHA-256 동일.
- Native OpenGL Compatibility / Intel Arc 130V에서 1280×720, 1366×768 요청(실제 16:9 Canvas 1365×768), 1600×900, 1920×1080 capture로 실제 MultiMesh 5개와 대표 runtime 크기를 확인했다. `ground_ball_assets_runtime_capture_{1280x720,1366x768,1600x900,1920x1080}.png`, save error 0, runtime error 0.
- Main 120-frame headless smoke는 exit 0이며 기존 shutdown-only ObjectDB 3개/resource 1개 warning은 유지됐다. 이번 소규모 capture에서는 성능 수치를 측정하지 않았다.
- Planetary/Galactic production family와 Planetary-base Moon symbolic `8×8px` LOD는 후속 범위다.

## 2026-08-21 — Planetary Lv0–Lv4 production ball assets

Owner: Presentation / delegated game-asset implementation

- 사용자의 명시적 구현 승인으로 Planetary ordered chain `[4,5,6,8,10]`의 visual identity `Moon/Mercury/Mars/Earth/Galaxy`를 실제 runtime diameter `8/16/32/64/128px` native grid에 deterministic hand-authored PNG로 제작했다. ImageGen 결과·Ground crop·resized intermediate·antialiasing은 사용하지 않았다.
- Moon은 Ground `128px` hero와 pixel data가 다른 별도 `8px` symbolic master다. Moon/Mercury body grayscale, Mars warm red/orange, Earth blue/green/white, Galaxy open two-arm phenomenon을 manifest와 자동 검증으로 고정했다. 불투명 색 수는 local level 순서대로 `6/6/7/10/11`, 모든 alpha는 `0/255`, transparent matte RGB는 `0`이다.
- global Lv5/Lv6/Lv8/Lv10의 `BallDefinition.texture`를 연결했다. 공유 Lv4는 Ground hero primary binding을 보존하고 Presentation-owned `BallTextureLodCatalog`가 runtime diameter `8`에서만 Planetary Moon을 선택한다. Galactic base Galaxy는 전용 `8px` LOD가 없어 기존 procedural fallback을 유지한다.
- renderer는 existing global-level `MultiMeshInstance2D`와 runtime radius transform을 그대로 사용한다. simulation snapshot, collision/physics, score/mass/fx tier, Merge/Cashout/Stage data, Content catalog display name/visual key, FIRST_CONTACT identity와 Integration-owned 파일은 변경하지 않았고 Goal 상태도 갱신하지 않았다.
- generator 재실행 전후 5개 SHA-256이 모두 동일했다. Python/Pillow 정적 audit는 sizes, binary alpha, clear-black transparency, declared palette와 per-asset color cap을 모두 통과했다.
- Godot 4.7.1 CLI import/load exit 0. 전용 scene은 `PLANETARY_BALL_ASSETS_VERIFIED chain=4/5/6/8/10 sizes=8/16/32/64/128 alpha=binary palette_colors=[6, 6, 7, 10, 11] nearest=true moon_native=true bindings=5 ground_galactic_unchanged=true`; Ground asset, S2-G1 BallCatalog, S4-G4 MultiMesh 회귀도 각각 exit 0이다.
- Main 120-frame headless smoke exit 0. 기존 shutdown-only ObjectDB 3/resource 1 warning과 Windows root certificate store warning은 유지되며 새 runtime/script error는 없다. 이번 5공 fixture는 성능 benchmark 대상이 아니어서 FPS 수치를 만들지 않았다.
- native `1600×900` capture scene은 추가했지만 visible Windows/OpenGL 실행 승인이 환경에서 거부되어 실제 native PNG는 `UNVERIFIED — tool permission`. headless dummy renderer는 viewport texture를 제공하지 않아 native 전용 guard로 명시했고, ignored local static native-size preview로 family hierarchy만 별도 시각 검수했다.

## 2026-08-21 — Galactic Lv0–Lv4 production ball assets

Owner: Presentation / game-asset implementation

- 사용자의 명시적 구현 승인으로 Galactic ordered chain `[10,11,12,13,14]`의 `Galaxy/Galaxy Cluster/Quasar/Event Horizon/Black Hole`을 실제 runtime diameter `8/16/32/64/128px` native grid에 deterministic hand-authored PNG로 제작했다. ImageGen 결과, Planetary Galaxy resize, antialiasing, blur, filtered intermediate는 사용하지 않았다.
- Galaxy `8px`는 Planetary `128px` hero와 pixel data가 다른 symbolic master다. compact galaxy group, accretion disk·polar jets, broken lensing band와 opaque void를 generic circular container 없이 단계별 silhouette로 구성했다. palette는 최대 13색, 실제 불투명 색 수는 `6/10/12/11/13`, alpha는 모두 `0/255`, transparent matte RGB는 `0`이다.
- Presentation-owned `BallTextureLodCatalog`에 다섯 exact-size binding을 추가했다. 기존 MultiMesh는 Lv10~13만 소비하고 Lv14 hero는 Black Hole creation/CUT-IN handoff로 등록했다. Lv14 special fallback과 이동 Black Hole renderer/footprint/force/conversion/phase/finale, collision·physics·score·Stage transition·FIRST_CONTACT, Content resource와 Integration-owned 파일은 변경하지 않았다. Goal status와 Integration lock도 변경하지 않았다.
- generator 재실행 전후 5개 SHA-256이 모두 동일했다. 전용 Godot verifier는 `GALACTIC_BALL_ASSETS_VERIFIED chain=10/11/12/13/14 sizes=8/16/32/64/128 alpha=binary palette_colors=[6, 10, 12, 11, 13] opaque_pixels=[28, 149, 462, 3023, 9945] nearest=true galaxy_native=true bindings=5 black_hole_special_unchanged=true ground_planetary_unchanged=true`로 exit 0이었다.
- Ground, Planetary, S2-G1 BallCatalog, S4-G4 MultiMesh 회귀는 모두 exit 0이었다. Main 120-frame headless smoke도 exit 0이며 기존 Windows root certificate store warning과 shutdown-only ObjectDB 3/resource 1 warning만 유지됐다.
- native `1600×900` capture scene과 60-frame timing probe를 추가했지만 visible Windows/OpenGL 실행 승인이 환경에서 두 번 거부되어 실제 PNG와 FPS는 `UNVERIFIED — tool permission`; capture path는 생성되지 않았다. headless dummy renderer를 runtime capture로 오인하지 않도록 native-only guard를 유지했다.

## 2026-08-21 — S6-G2 FIRST CONTACT CUT-IN Presentation producer

Owner: Presentation

- 기존 S6-G2I Main wiring을 수정하지 않고 `PresentationManager.play_first_contact_cutin(payload) -> bool`, `reset_first_contact_cutin(run_epoch)`와 `first_contact_cutin_finished(event_id, run_epoch)`를 실제 `CutInController`에 연결했다. Integration-owned 파일과 lock은 사용하지 않았다.
- approved draft의 공통 `1600×900` background 1개와 정확한 6종 `Giant Snowball/Moon/Supernova/Galaxy/Event Horizon/Black Hole` transparent title·portrait layer를 byte-identical copy해 runtime 조립한다. Galaxy Cluster와 Quasar draft는 asset path와 roster 모두에 등록하지 않았다.
- normal enter/hold/exit는 `0.12/0.26/0.12s`로 총 `0.50s`, reduced-effects는 slide를 제거한 `0.10/0.25/0.10s`로 총 `0.45s`다. 전체 16:9 dim과 공통 frame은 기존 gameplay 위에서 동작하며 normal exit 후 dim을 복원·hide한 다음 matching completion을 한 번 발행한다.
- Controller는 payload v1의 11개 필드 type, six-identity별 Stage/global/local/handoff/Black Hole ordinal을 검증하고 active/completed `(run_epoch,event_id)`와 process-lifetime monotonic high-water로 duplicate/stale을 거부한다. reset은 matching/previous visual Tween을 즉시 취소하지만 completion을 만들지 않으며 Core/Stage/Simulation을 조회하거나 변경하지 않는다.
- Godot 4.7.1 CLI 전용 검증은 `S6_G2_VERIFIED mappings=6 common_background=true duration=0.50 reduced_duration=0.45 duplicate_stale=true reset_no_emit=true exact_once=true main_handoff=true core_readonly=true`, exit 0. S6-G2I, S8-G4, S8-G5 phase와 finale Presentation 회귀도 각각 exit 0이었다.
- Main 120-frame headless smoke exit 0. pre-existing Windows root certificate store warning과 shutdown-only ObjectDB 3/resource 1 warning이 유지됐다. 별도 S5-G4 wiring fixture는 latest Main Title 시작을 반영하지 않은 기존 `get_current_stage().clear_score` null assertion에서 중단됐고 S6-G2 범위에서는 수정하지 않았다.
- Native OpenGL Compatibility / Intel Arc 130V의 실제 Main producer fixture에서 pause lock 아래 visible hold를 캡처했다. `C:/Users/gktjd/Desktop/gangnam/snowball-effect/tmp/s6_g2_first_contact_cutin_main_capture.png`, save error 0, 8-frame sample 평균 `31.9 FPS`, 최대 frame `31.68ms`, matching completion 1회와 pause release를 확인했다.
- 실제 Web/browser Tween·dim·입력 복귀 품질 검증은 남아 있어 Goal은 `IMPLEMENTED`이며 `VERIFIED`로 올리지 않았다.

## 2026-08-21 — S6-G2 same-Run Stage reset regression

Owner: Presentation

- Root cause는 `CutInController.reset_first_contact_cutin(run_epoch)`가 `_reset_epoch_high_water`를 올린 뒤 `play_first_contact_cutin`이 `run_epoch <= _reset_epoch_high_water`를 거부한 것이었다. GameManager의 Stage 전환 visual cleanup은 Run epoch를 유지하므로 Ground 뒤 같은 Run의 Planetary/Galactic payload가 모두 차단됐다.
- Presentation-owned controller의 reset watermark 비교만 strict older-epoch(`<`)로 바꿨다. 기존 process-lifetime event ID high-water, completed pair, active pair와 highest Run epoch 방어는 유지했고 GameManager/StageManager/Main/Core/Integration은 수정하지 않았다.
- S6-G2 verification을 Ground `epoch N/event 100` 정상 완료→`reset_first_contact_cutin(N)` Stage cleanup→Planetary `epoch N/event 101` 수락·visible·matching completion 1회로 갱신했다. 같은 fixture에서 active duplicate, completed pair, non-monotonic old event ID, older Run epoch를 계속 거부하고 active visual reset은 즉시 hide/cancel하되 completion 0회임을 확인한다.
- 수정 전 새 회귀는 `A later Planetary event in the same Run epoch must survive Stage-transition visual reset`에서 재현됐다. 수정 후 Godot 4.7.1 headless는 `S6_G2_VERIFIED mappings=6 common_background=true duration=0.50 reduced_duration=0.45 same_epoch_stage_reset=true duplicate_stale=true reset_no_emit=true exact_once=true main_handoff=true core_readonly=true`, exit 0이다.
- S6-G2I Integration regression은 `S6_G2I_VERIFIED fifo=true pause=true stale_rejected=true black_hole_gate=true reset=true`, exit 0이다. 두 성공 실행에는 기존 Windows root certificate store warning만 있었고 새 GDScript/runtime error는 없다. 기본 `user://logs` 경로 실행은 log write 실패 뒤 Godot signal 11이어서 workspace `--log-file`로 재실행해 프로젝트와 tooling 문제를 구분했다.
- 수정 뒤 Native OpenGL Compatibility로 Main CUT-IN capture를 새로 실행했다. Intel Arc 130V, `1600×900`, 8-frame 평균 `145.4 FPS`, 최대 `10.41ms`, completion 1회를 확인했으며 artifact `tmp/s6_g2_first_contact_cutin_main_capture.png`를 갱신했다.
- 실제 Web/manual Tween·dim·입력 복귀 검증은 여전히 pending이므로 S6-G2는 `IMPLEMENTED`를 유지한다.
- CUT-IN의 normal/reduced 총 노출 시간을 사용자 요청대로 `2.00s/1.80s`로 조정했다. enter/hold/exit의 기존 비율과 completion·pause handoff는 유지하며 전용 verifier의 timing contract도 함께 갱신했다.

## 2026-08-22 — S6-G2 Play Field 횡단 CUT-IN

Owner: Presentation (사용자 요청 handoff)

- FIRST CONTACT CUT-IN의 gameplay pause, payload 검증, exact-once completion과 S8 Black Hole handoff는 그대로 두고 표시 범위만 active visual Play Field 내부로 변경했다. HUD·좌우 기계 UI·Stage World를 덮거나 dim하지 않으며 FieldClip이 banner와 dim을 실제 field rect에 한정한다.
- 배너는 field 폭 전체와 높이 `44%`를 사용해 오른쪽에서 진입, 중앙 hold, 왼쪽으로 퇴장한다. normal `0.20/0.65/0.25s` 총 `1.10s`, reduced-effects는 이동 없이 `0.12/0.55/0.18s` 총 `0.85s` fade다. 공통 background와 6종 title/portrait 원화는 새로 만들거나 변경하지 않았다.
- PresentationManager가 매 visible request 전에 `GameplayFrame.get_field_visual_rect()`를 controller에 전달한다. 따라서 Ground/Planetary/Galactic의 서로 다른 Stage field 폭에도 field-local clip과 banner 크기가 다시 계산된다.
- Godot 4.7.1 CLI S6-G2 verification exit 0, Primary validate controller/manager/scene 3/3, Primary Main runtime screenshot에서 Planetary field 내부 배너·외부 HUD/기계 UI 비가림·runtime error 0을 확인했다. clean Web의 실제 수동 Tween·입력 복귀 확인이 남아 Goal은 `IMPLEMENTED`를 유지한다.

## 2026-08-21 — Planetary visual-chain correction

Owner: Presentation

- 사용자 승인 방향인 Planetary visual chain `Moon → Earth → Sun → Supernova → Galaxy`를 global `[4,5,6,8,10]`, native `8/16/32/64/128px` master에 다시 적용했다. 기존 Content-owned BallDefinition의 display name·score·physics·primary texture는 수정하지 않았다.
- Presentation-owned `BallTextureLodCatalog`가 Planetary exact-size master를 primary texture보다 먼저 선택하도록 해, 이전 Mercury/Mars/Earth 그림이 Earth/Sun/Supernova 데이터에 표시되던 drift를 고쳤다. Galactic local Lv0의 Galaxy `8px` LOD와 Ground Moon hero primary는 보존한다.
- Supernova와 Galaxy FIRST CONTACT portrait를 해당 `64px/128px` runtime master의 nearest-only `512px` 확대본으로 재생성했다. verification은 모든 source pixel이 portrait의 대응 block 전체에 동일함을 확인해 CUT-IN과 in-game visual identity가 분리되지 않게 한다.
- Godot 4.7.1 CLI: `PLANETARY_BALL_ASSETS_VERIFIED chain=4/5/6/8/10 sizes=8/16/32/64/128 alpha=binary palette_colors=[6, 8, 7, 6, 11] nearest=true moon_native=true bindings=5 ground_primary_unchanged=true galactic_lod_separate=true`; `S6_G2_VERIFIED ... duration=2.00 reduced_duration=1.80 ...`, 모두 exit 0.
- Native OpenGL Compatibility / Intel Arc 130V에서 `tmp/planetary_ball_family_corrected.png`를 생성했다. save error 0, standard ball 5이며 실제 MultiMesh가 `Moon/Earth/Sun/Supernova/Galaxy` 라벨과 native size로 표시됐다.

## 2026-08-21 — CUT-IN reference priority correction

Owner: Presentation

- 사용자 지시에 따라 Supernova·Galaxy CUT-IN portrait를 canonical draft의 byte-identical 원본으로 복원했다. CUT-IN은 인게임 asset으로부터 파생하지 않으며, 원화가 인게임 디자인의 기준이다.
- Planetary Supernova `64px`는 CUT-IN의 white-gold rupture core·warm-violet orbit ribbon을, Galaxy `128px`는 folded violet body·cyan/gold/cream ribbon lane을 native-grid로 축약한다. 기존의 Supernova shock-petal과 Galaxy open-spiral 방향은 폐기했다.
- Presentation verification은 runtime CUT-IN 파일과 approved draft의 bytes equality를 확인하고, in-game master가 각각의 canonical motif color language를 갖는지 검사한다.

## 2026-08-21 — Galactic Lv3/Lv4 CUT-IN-aligned runtime masters

Owner: Presentation

- 사용자 지시대로 approved FIRST CONTACT CUT-IN illustration은 변경하지 않고, in-game Galactic Lv3 Event Horizon과 Lv4 Black Hole만 원화에 맞춰 다시 제작했다.
- Event Horizon `64px`는 금 간 남색 구체, 보랏빛 shell, 분리된 cyan lensing dash, 우측 white/gold flare로 축약했다. Black Hole `128px`는 완전한 dark void, 밝은 inner rim, segmented violet torus, cyan outer marks, 네 방향 starburst로 축약했다.
- verifier에 runtime CUT-IN portrait와 approved draft의 byte-for-byte equality를 추가하고, Event Horizon의 우측 flare와 Black Hole의 상단 starburst 픽셀도 검사한다. CUT-IN 원화 파일 자체는 수정하지 않았다.
- Godot 4.7.1 CLI: `GALACTIC_BALL_ASSETS_VERIFIED chain=10/11/12/13/14 sizes=8/16/32/64/128 alpha=binary palette_colors=[6, 10, 12, 12, 12] opaque_pixels=[28, 149, 462, 3403, 10362] nearest=true galaxy_native=true bindings=5 black_hole_special_unchanged=true ground_planetary_unchanged=true`, exit 0.
- Native OpenGL Compatibility / Intel Arc 130V capture: `tmp/galactic_ball_family_cutin_aligned.png`, `1600x900`, save error `0`, standard balls `4`, Black Hole hero `true`, average `59.9 FPS`, minimum `34.4 FPS`, max frame `29.10ms`.

## 2026-08-23 — S10-G3 Settings visual·focus

Owner: Presentation

- Settings v1 panel을 existing Title/Pause의 dark mechanical CRT visual language 안에서 확인했다. 현행 `500×420` modal, lime border, warm title, dim layer와 Title artwork의 조합은 logical `1600×900`에서 중앙에 안정적으로 표시되며, `1280×720`보다 작은 minimum size로 clip 여유를 확보한다.
- Presentation-owned verifier `tests/presentation/s10_g3_settings_visual_focus_verification.*`를 추가했다. margin-contained content와 Master → BGM → SFX → Value Popups → Apply → Close → Master focus cycle, entry focus를 고정한다.
- Primary Godot validate 4/4: SettingsPanel scene, G3 verifier script/scene, GameManager 모두 valid. G3 fixture process는 exit 0으로 완료됐으며 bridge 초기화 전에 종료되는 short-fixture 특성상 MCP가 shutdown warning만 보고했다.
- 실제 Main background runtime에서 Title Settings를 열고, Tab 5회로 `CLOSE` focus ring을 확인했다. Enter close 뒤 focus owner는 `/root/Main/UI/TitleScreen/SettingsButton`였고 panel은 hidden이었다. Gameplay/Pause origin의 close return은 existing S10-G2I fixture로 보존한다.
- persistence, AudioServer, gameplay state, Web acceptance/export는 변경하지 않았다. 다음 순차 작업은 S10-G4 Web acceptance·update다.

## 2026-08-23 — S10-G3 Settings visual polish follow-up

Owner: Presentation

- 기존 Title/Pause의 dark mechanical CRT 언어에 맞춰 Settings panel을 실제로 고도화했다. copper/lime double frame과 shadow, `SYSTEM AUDIO // LIVE CALIBRATION` header, live-preview rule/copy, dark teal slider rail, warm value ink, 버튼 hover/pressed/focus 상태를 추가했다.
- Apply/Close의 pointer cursor와 명확한 hover/focus outline을 제공한다. layout은 `520×450` logical modal로 조정했으며 1280×720보다 작아 기존 focus cycle/return semantics는 유지한다.
- Primary Godot validate 4/4 및 `S10_G3_SETTINGS_VISUAL_FOCUS_VERIFIED viewport_fit=true focus_cycle=true entry_focus=true` fixture exit 0. clean Web export를 local `http://127.0.0.1:8080`의 actual browser 1280×720에서 열어 panel과 Apply hover를 확인했고 console error 0이었다.

## 2026-08-23 — S10-G3 Pause-language alignment

Owner: Presentation

- 사용자 지시에 맞춰 평면형 calibration panel을 제거하고 Pause 모달과 같은 `field_bezel_v2_910x900` copper/lime 프레임, 각진 CRT chamber, dark inset으로 교체했다.
- Apply와 Close를 Pause와 같은 full-width copper `field_bezel_96` bezel 버튼과 corner bolt로 재구성했다. 기존 live preview, Apply/Close 동작과 keyboard focus 순서는 변경하지 않았다.
- Primary Godot scene/script validation 2/2을 통과했다. Main runtime에서 Title Settings를 실제 열어 새 모달의 frame, three-volume rows, toggle, two action buttons를 확인했다. Web release export를 갱신했고 local browser title smoke의 console error는 0건이었다.

## 2026-08-23 — S10-G3 Escape close

Owner: Presentation

- Settings가 표시된 동안 `ui_cancel`(Esc)을 `_input` 단계에서 선점해 Close와 동일한 rollback request로 보낸다. 따라서 pause 단축키와 겹쳐도 Settings만 닫히며 key repeat은 무시된다.
- Primary validation 3/3 후 Main runtime에서 Title Settings를 열고 Esc로 닫혀 Title 화면만 남는 것을 확인했다. Web release export도 갱신했다.

## 2026-08-23 — S10-G3 Settings inset correction

Owner: Presentation

- copper pipe와 내부 CRT chamber 사이가 투명하게 비쳐 보이던 영역에 opaque dark backing을 추가했다. `LIVE PREVIEW · APPLY TO SAVE` 안내 문구는 제거했다.
- Value Popups를 label/toggle row로 분리해 볼륨 label과 같은 left edge, 색, 글자 크기를 사용하게 했다.
- Primary scene/script validation 3/3과 Main runtime screenshot으로 세 변경사항을 확인하고 Web release export를 갱신했다.

## 2026-08-23 — S10-G3 Settings option spacing

Owner: Presentation

- Settings modal의 `540×560` 외곽 크기는 유지한 채 Master, BGM, SFX, Value Popups 각 행의 최소 높이를 `38px`로 고정해 옵션 사이의 세로 간격을 늘렸다. 확장 spacer가 줄어들므로 action buttons는 기존 위치를 유지한다.
- Primary scene validation과 Main runtime screenshot을 확인하고 Web release export를 갱신했다.

## 2026-08-23 — S10-G3 Brass pipe volume gauge

Owner: Presentation/UI

- 사용자가 선택한 ImageGen concept-reference의 상단 좌측 황동 관측창을 기준으로, 생성 이미지를 runtime asset으로 사용하지 않고 `PipeVolumeGauge`를 Godot draw API로 새로 작성했다. heavy coupling, square bolts, ten independent sight-glass chambers, amber active cells와 dark-brown inactive cells만 사용한다.
- Master/BGM/SFX는 이제 직접 드래그할 수 없는 `0..10` read-only pipe gauge다. 양옆 `−`/`+`가 한 번에 한 칸(실제 adapter snapshot의 10%)만 조절하며, preview·Apply·Close rollback 계약은 유지한다. 기존 arbitrary 0..100값은 panel 진입 시 nearest step으로 표시된다.
- Primary validation 6/6, Main runtime에서 Title Settings 진입과 Master `−` 두 번에 10→8 amber chamber로 즉시 갱신되는 것을 확인했다. runtime errors 0, Web release export 갱신 완료.

## 2026-08-23 — S10-G3 Pipe gauge silhouette correction

Owner: Presentation/UI

- 첫 runtime 구현이 선택한 concept-reference의 실루엣보다 지나치게 사각 프레임에 가까웠다는 사용자 피드백을 반영했다. pipe gauge body를 위·아래의 노출 황동 파이프, 양끝의 두꺼운 bolt clamp, 중앙 black sight-glass로 다시 구성했다.
- 10개 amber chamber 및 0..10 read-only step contract는 유지한다. Primary scene/script validation과 Main runtime capture에서 새 silhouette을 확인하고 Web release export를 갱신했다.

## 2026-08-23 — S10-G3 Selected pipe artwork applied

Owner: Presentation/UI

- 사용자가 명시적으로 선택한 황동 파이프 이미지를 투명 배경의 runtime texture `assets/sprites/ui/settings/volume_pipe_selected.png`로 추출해 적용했다. 이전의 draw-API 재해석은 제거했다.
- `PipeVolumeGauge`는 volume 10일 때 선택 원본의 clamp, rail, sight-glass, amber cell을 그대로 그린다. 0..9에서는 비어야 하는 셀만 dark mask로 덮어 `−`/`+`의 기존 0..10 계약을 유지한다.
- Godot CLI editor import로 PNG import를 생성한 뒤 Primary validate 2/2(script, scene)를 통과했다. Main runtime에서 Settings 진입, 10칸 원본 외형, Master `−` 1회 후 마지막 칸 비활성화를 확인했다.
- Web release export를 갱신했고, `http://127.0.0.1:8080/index.html` Chrome에서 Settings를 열어 세 게이지가 원본 pipe texture로 표시되는 것을 확인했다. browser console error는 0건이었다.

## 2026-08-23 — S10-G3 Pipe gauge alignment and baseline level

Owner: Presentation/UI + Settings contract

- 세 volume label의 fixed width를 통일해 Master/BGM/SFX pipe gauge의 x 좌표를 정확히 맞췄다. gauge는 38px row 안에서 중앙 정렬한 32px 높이로 다시 그려, 외곽 modal 크기를 바꾸지 않고 약간 더 얇게 만들었다.
- 선택 텍스처의 외곽에 남아 있던 near-white matte pixel을 제거해 흰 테두리를 없앴다.
- Volume model을 0..10 정수 level로 변경했다. 기본값 5는 Master/BGM/SFX 모두 기존 authored 음량(0 dB 보정)을 유지하며, 사운드 에셋 자체를 절반으로 낮추지 않는다.
- Primary validate 5/5, Main runtime에서 세 gauge rect가 모두 `x=788`, default level `[5,5,5]`, Master bus `0 dB`임을 확인했다. Web export와 Chrome `127.0.0.1:8080` Settings screenshot에서도 aligned/thinner/no-white-outline 상태 및 console error 0을 확인했다. Headless fixture는 환경의 `user://logs` 접근 실패 후 Godot engine crash로 실행 증거를 남기지 못했다.

## 2026-08-23 — S10-G3 Step-button focus state

Owner: Presentation/UI

- Settings entry focus는 Master `−`에 그대로 유지하되, focus style을 hover style과 분리했다. 초기 진입에는 normal dark fill과 1px subtle brass outline만 표시되며, pointer hover만 기존의 밝은 amber fill을 사용한다.
- Primary scene validation과 Main runtime Settings-entry screenshot으로 entry state가 hover처럼 밝아지지 않는 것을 확인했다.

## 2026-08-23 — S10-G3 Compact step buttons

Owner: Presentation/UI

- 모든 `−`/`+` button의 minimum height를 28px에서 24px로 줄이고, 38px option row 안에서 vertical shrink-center로 정렬했다. 게이지와 행의 크기·가로 폭은 유지한다.
- Primary scene validation 및 Main runtime Settings screenshot으로 더 낮아진 step button을 확인했다.

## 2026-08-23 — S10-G3 Value Popups sliding breaker

Owner: Presentation/UI

- 사용자가 선택한 1번 sliding-breaker concept에서 OFF/ON 상태를 각각 `value_popups_toggle_off.png`, `value_popups_toggle_on.png`으로 추출해 runtime asset으로 적용했다.
- 기존 CheckButton을 `BrassPopupToggle`로 교체했다. Button toggle/focus/keyboard contract와 Settings preview·Apply·Close 값 계약은 유지하면서, 상태에 따라 선택 artwork를 nearest filtering으로 그린다.
- Primary validate 3/3, Main runtime의 on→off preview와 clean debug output, Web export 및 Chrome `127.0.0.1:8080` Settings screenshot/console error 0을 확인했다.

## 2026-08-23 — S10-G3 Corrected Value Popups ON artwork

Owner: Presentation/UI

- 사용자가 정정해 지정한 단일 sliding-breaker artwork를 ON texture로 교체했다. Value Popups의 fresh default는 기존대로 `true`이며, Main runtime에서 ON texture와 `value_popups_enabled=true`를 함께 확인했다.
- OFF texture도 같은 외형에서 앰버 관측창만 소등한 상태로 재생성했다. Web release export를 갱신했다.

## 2026-08-23 — S10-G3 Final Value Popups breaker source

Owner: Presentation/UI

- 사용자가 마지막으로 첨부한 sliding-breaker 이미지를 ON 원본으로 다시 추출해 적용했다. OFF 상태는 동일한 장치 외형을 유지하고 오른쪽 앰버 관측창만 소등한다.
- 중간 축소 요청은 취소되어 toggle의 원래 86×24px layout과 22px 표시 높이를 유지한다. 기본 상태는 ON이다.
- Godot CLI import, Primary validate 2/2, Main runtime Settings screenshot을 통과했다. runtime에서 `value_popups_on=true`, toggle size `86×24`, debug error 0을 확인했다. Web release export와 `127.0.0.1:8080` Chrome Settings 화면도 갱신했고 console error는 0건이었다.

## 2026-08-23 — S10-G3 Compact Value Popups toggle

Owner: Presentation/UI

- 사용자의 요청에 따라 Value Popups toggle의 가로 폭만 약 70%로 줄였다: `86×24px` → `60×24px`.
- Godot CLI import, Primary scene validation, Main runtime Settings screenshot에서 ON 기본 상태와 실제 `60×24px` layout을 확인했다. Web release export와 `127.0.0.1:8080` Chrome 화면에서도 적용 상태 및 console error 0을 확인했다.

## 2026-08-23 — S10-G3 Value Popups OFF lever position

Owner: Presentation/UI

- OFF texture에서 황동 레버를 왼쪽 고정점으로 이동시켜, ON의 오른쪽 결합 위치와 명확히 다른 실제 switch position을 만들었다. 오른쪽 앰버 관측창의 소등도 유지한다.
- Godot CLI import 및 Main runtime OFF-state screenshot을 확인했다. Web release export와 `127.0.0.1:8080` Chrome에서 실제 toggle click으로 OFF 레버 위치와 console error 0을 확인했다.

## 2026-08-23 — S10-G3 Remove Settings focus outlines

Owner: Presentation/UI

- Value Popups toggle의 커스텀 focus rectangle을 제거했다. APPLY/CLOSE에는 hover 강조색만 남기고, 클릭 후 focus state가 hover의 노란 2px border를 재사용하지 않도록 별도 무테 focus style을 적용했다.
- Godot CLI import, Primary validate 2/2, Main runtime에서 Toggle과 APPLY focus 상태를 각각 확인했다. Web release export와 `127.0.0.1:8080` Chrome toggle-click 상태에서도 노란 외곽선이 없고 console error 0을 확인했다.

## 2026-08-23 — S10-G3 Full-range pipe gauge correction

Owner: Presentation/UI

- 선택 원본의 7칸 점등 예시를 그대로 남기고 빈 칸만 가리던 방식을 제거했다. 이제 황동 pipe shell 위의 10개 chamber를 매번 모두 다시 그리므로 0~2에서의 잔광과 8~10에서의 점등 상한이 없다.
- Godot CLI import, Primary script validation, Main runtime에서 `[0, 2, 10]`과 `[7, 8, 9]` 조합을 각각 표시해 0의 잔광 제거와 8~10의 추가 점등을 확인했다. runtime error는 0건이었다.
- 최신 Web release export를 실제 브라우저에서 열어 Master Volume을 10까지 올렸고, 10개 chamber가 모두 점등되는 것과 browser console error 0건을 확인했다. CLOSE로 테스트 preview는 저장하지 않고 되돌렸다.

## 2026-08-23 — S10-G3 Pipe gauge source-coordinate correction

Owner: Presentation/UI

- 사용자 재현 화면을 검토해 이전 보정의 chamber 시작 좌표가 선택 원본보다 오른쪽으로 어긋났음을 확인했다. 원본 194px texture의 관측창 시작 x=36에 맞춰 첫 칸의 x 비율과 폭을 보정했다.
- Native runtime에서 `[0, 7, 10]`으로 0칸, 7칸, 10칸을 같은 화면에 검증했다. Web release를 재export한 뒤 실제 브라우저에서 Master를 0까지 낮춰 잔광이 없음을, 10까지 올려 10칸 전체가 점등됨을 확인했다. console error는 0건이며 CLOSE로 preview를 저장하지 않았다.

## 2026-08-23 — S10-G3 Exact ten-chamber pipe gauge

Owner: Presentation/UI

- source texture의 sample divider가 개별 redraw cell 사이로 비쳐 11칸처럼 보이던 문제를 수정했다. 관측창의 sample meter 전체를 먼저 소등한 뒤, 서로 겹치지 않는 폭의 chamber 10개만 렌더한다.
- Godot CLI script validation과 native `[0, 5, 10]` runtime screenshot을 확인했다. 최신 Web release에서 Master를 10으로 올려 분리된 정확히 10개 chamber와 console error 0건을 확인했으며, CLOSE로 preview를 되돌렸다.

## 2026-08-23 — S10-G3 Centred ten-cell bank

Owner: Presentation/UI

- 10칸 meter가 11칸 폭의 관측창 왼쪽에 치우쳐 최대치에서도 우측 공백이 더 커 보이던 문제를 수정했다. cell bank를 반 칸만큼 우측으로 옮겨 좌우 gutter가 각각 반 칸이 되도록 중앙 정렬했다.
- Godot CLI validation과 native runtime에서 `[10, 4, 0]` 상태를 확인했다. 최신 Web export와 release ZIP을 갱신했다.

## 2026-08-23 — S10-G3 Half-cell gutters around the ten-level meter

Owner: Presentation/UI

- 10-cell bank만 움직였던 이전 정렬은 원본 11-pitch meter의 마지막 dark chamber 일부를 남겼다. source-meter 전 폭을 지운 뒤, 10개 chamber를 반 pitch 우측 이동해 좌우에 각각 반 칸 gutter가 남도록 보정했다.
- Godot CLI validation 및 native `[10, 5, 0]` runtime을 확인했다. 최신 Web release에서도 Master 10, console error 0건을 확인하고 CLOSE로 test preview를 되돌렸다. release ZIP을 갱신했다.
## 2026-08-22 — S5-G6 Stage Clear confirmation Web verification

Owner: Presentation

- current Main의 기존 S5-G6 producer와 S5-G6I integration을 변경하지 않고, Godot 4.7.1 CLI 전용 panel verifier와 integration confirmation fixture를 재실행했다. 각각 `S5_G6_VERIFIED open=true scores=true focus=true request_once=true duplicate_hidden_stale=true reset=true exclusions=true reduced=true core_readonly=true`, `S5_G6I_VERIFIED confirmation_gate=true stale_rejected=true failure_result=true`로 exit 0이었다.
- Web release에서는 의도적으로 `OS.is_debug_build()` guard를 둔 F7 test trigger가 비활성임을 확인했다. 동일 Web runtime의 Debug export를 localhost Chrome/Playwright에서 실행해 Canvas 표시·focus→실제 Ground Score Clear panel(`STAGE CLEAR!`, Stage/Run score, `NEXT STAGE`)→Enter 입력→Planetary PLAYING/배경 전환을 screenshot으로 검증했다. browser console error는 0건이었다.
- gstack `browse` Windows launcher는 companion server bundle 경로와 daemon start 문제로 project interaction 전에 실패했다. 이에 게임 코드를 변경하지 않고 direct Chromium/Playwright로 대체했으며, Godot export·Canvas·keyboard 경로는 정상임을 분리 확인했다.

## 2026-08-22 — S6-G6 Final Settlement final validation

Owner: Presentation

- Final Settlement producer fixture는 Godot 4.7.1 CLI에서 `S6_G6_VERIFIED samples=64 duration=0.5 score_countup=true completion=1 ready_main_stale_safe=true core_readonly=true`로 통과했다. Core Settlement(`S3_G4_VERIFIED base_only=true top_included=true idempotent=true`)와 FX budget(`S6_G1_VERIFIED ...`) 회귀도 exit 0이었다.
- 그러나 latest Main Debug Web export에서 Ground Run을 시작한 뒤 F7 Score Clear로 실제 Settlement를 발생시켜 50ms·250ms frame을 캡처한 결과, Stage Clear Panel이 같은 frame에 전면 표시됐다. 0.5초 Settlement draw와 HUD Stage Score count-up은 panel/dim 아래에 가려 player-visible로 읽히지 않았다. browser console error는 0건이었다.
- 이에 따라 S6-G6은 `IMPLEMENTED`를 유지한다. 다음 작업은 Final Settlement visual을 먼저 독립적으로 노출한 뒤 완료 signal 또는 명시적 presentation delay를 통해 Stage Clear Panel을 열도록 Integration 계약을 재정의·구현하는 것이다. 이번 검증은 Core score/state/Settlement 계산이나 retired S6-G6I를 변경하지 않았다.

## 2026-08-22 — Integration S6-G6J handoff and Presentation regression cleanup

Owner: Presentation documentation / S2-G5 test maintenance

- Final Settlement visual이 실제 Main에서 가려지는 결과를 Integration이 바로 처리할 수 있도록 새 `S6-G6J Final Settlement UI reveal handoff`를 S6 slice, Status, Integration contracts에 추가했다. Core의 Settlement와 `CLEARED`/`FAILED`는 즉시 확정하고, GameManager가 copied clear/result outcome과 visual-finished latch가 모두 준비된 뒤에만 Clear/Result UI를 열도록 한다. Retry/Main/fresh Run stale completion 폐기와 Core state 불변도 계약에 포함했다.
- S2-G5 Presentation fixture는 stale direct `configure_stage_ball_levels([0,1,2,3,4])` 대신 Ground `StageDefinition`을 `apply_stage_definition()`으로 적용하게 고쳤다. Godot 4.7.1 CLI에서 `S2_G5_VERIFIED merge_fx_once=true catalog_name=true presentation_readonly=true` 및 S2-G3 `pairs=deterministic one_consume_per_tick=true top_event=true`가 모두 exit 0이었다.
- S4-G4 clean Web evidence는 ignored `tmp/`를 제외한 detached worktree `11b5b40` Release export로 보강했다. localhost Chrome에서 Ground 시작 뒤 16-frame 자연 Cashout sequence와 score `0→7`, Canvas/focus, console error 0을 확인했다. 다만 low-level 자연 낙하만으로 high-radius bottom boundary를 증명할 수 없었고, texture batch에서 `material=null`인 renderer 경로는 clip shader uniform을 받지 않는다. Core-owned boundary fixture/texture-material correction 전에는 누수 부재를 확정하지 않아 S4-G4를 `IMPLEMENTED`로 유지한다.

## 2026-08-22 — S6-G2 FIRST CONTACT CUT-IN Web quality gate

Owner: Presentation

- 현재 `f2bc3fc`에서 전용 CLI verifier를 재실행해 `S6_G2_VERIFIED mappings=6 common_background=true duration=2.00 reduced_duration=1.80 same_epoch_stage_reset=true duplicate_stale=true reset_no_emit=true exact_once=true main_handoff=true core_readonly=true`와 S6-G2I pause/handoff 회귀가 통과한 상태를 확인했다.
- 원본 브랜치를 바꾸지 않는 `tmp/s6-g2-web-verify` 임시 worktree에서 Main을 마운트하는 기존 runtime fixture를 Debug Web으로 export하고 localhost Chromium/Playwright로 실행했다. 실제 Canvas click 뒤 `1600×900` canvas, dimmed `FIRST CONTACT / GIANT SNOWBALL` hold, A key 입력 뒤에도 유지되는 CUT-IN, matching completion 1회와 pause release를 확인했다. `S6_G2_CAPTURE ... size=1600x900 frames=8 avg_fps=71.2 max_frame_ms=16.80 completion=1`; 실행 중 page error `0`이었다. capture는 `tmp/s6_g2_web_cutin_playwright.png`다.
- gstack `browse` Windows launcher의 `server-node.mjs` 누락과 Node-repl path 오류는 게임 코드와 분리했고, local Playwright/Chromium 결과로 실제 Web Gate를 닫았다. 검증 후 임시 worktree와 Playwright tool cache는 제거했으며 원본 runtime source·Integration-owned 파일은 수정하지 않았다.

## 2026-08-22 — S7 Item Ball presentation design review

Owner: Presentation / design-only

- 최신 S7 Item Ball·Orb producer/Integration 계약, 기존 Item Box 탐색안, 현재 Blizzard visual과 Paper-8/pixel guideline을 대조했다. canonical body는 `48px` Item Ball, `32px` Orb, 공통 5-hit이며 rarity·3/6/10 durability·hidden identity는 현 계약에 없는 오래된 제안으로 분리했다.
- `docs/design/16_ITEM_BALL_PRESENTATION_DESIGN_REVIEW.md`에 Orbital Cage, Cracked Geode Planet, Stepped Signal Mine 3안을 비교하고 **Cracked Geode Planet**을 추천했다. 0~4 hit mask와 5번째 break handoff, Blizzard/Fire/Magnet glyph, palette, native LOD, event별 effect 경계와 optional 목록을 명시했다.
- `docs/design/mockups/item-ball-candidate-board-v1.png`는 approved Paper-8 frame/current Blizzard crystal/Item CRT를 reference로 만든 ImageGen concept board다. production sprite로 crop/import하지 않고 native grid에서 다시 그리는 정책을 문서에 기록했다.
- 현재 `1254×1254px` Blizzard AI source의 `64px` 축소 표시, gameplay `48px` body와의 footprint 차이, 11px hit label과 shell 밖 crack을 production handoff 전 해결점으로 남겼다.
- Runtime Scene/Script/Resource/import, Core/Integration, Goal status와 lock은 변경하지 않았으며 실행 검증은 design-only 범위라 수행하지 않았다.

## 2026-08-22 — Cashout Direction Readability backlog implementation

Owner: Presentation / S5-G4 frame-owned maintenance (exact Goal ID 없음)

- `docs/design/TODOS.md`의 첫 Presentation 개선 항목을 사용자 승인에 따라 구현했다. 기존 세 후보 중 하단 내부의 아래 방향 chevron row를 선택했고, 하단 bezel 제거·suction flow·text label은 추가하지 않았다. `STATUS.md`에는 이 backlog와 정확히 일치하는 Goal이 없어 상태와 lock을 변경하지 않았다.
- `CashoutDirectionCue`는 현재 HUD CRT 게이지의 승인 원본 `StageScoreGauge.CELL_COLOR = Color("60ae7b")`를 직접 재사용하고, 2×2 hard pixel 7개로 V-chevron 하나를 만들어 profile 폭에 따라 10~20개를 48px 간격으로 배치한다. normal은 `0.84s` top-to-bottom repeat, reduced-effects는 같은 색·방향 identity의 static row다. solid fill, antialias, blur, gradient, collision/input surface는 없다.
- cue rect는 Ground/Planetary/Galactic/Black Hole L3의 authoritative visual width를 따라가며 actual logical Cashout line `y=818` 바로 위 `y=792..812`에 유지된다. Scale Shift/L2→L3 lerp 중에도 폭과 x를 보간한다. Main에서는 기존 `PlayField`의 Backdrop 다음·Simulation/Paddle 이전 child로 Presentation node를 mount해 회전 Paddle이나 공과 겹칠 때 gameplay가 위에 그려진다.
- cue lifetime은 Run당 active gameplay 누적 `10.0s`다. 기존 HUD/Pause visibility와 SceneTree pause, Presentation의 Shift/FIRST CONTACT/Black Hole phase/finale lifecycle을 사용하므로 Title·Pause·CUT-IN·Clear/Result·transition/finale 동안 숨고 시간이 멈춘다. Stage 변경은 누적 시간을 유지하고, Main이 Start/Retry에 공통 호출하는 기존 Presentation Run reset에서만 초기화한다. reduced-effects도 static 표시만 다르고 같은 10초 계약을 따른다. 새 Core signal, Cashout 계산, collision/bounds, Stage state는 추가하거나 변경하지 않았다.
- 전용 CLI verifier는 `S5_G4_CASHOUT_CUE_VERIFIED profiles=4 aligned=true open=true color=60ae7b lifetime=10.0 pause_freeze=true stage_no_reset=true retry_new_run_reset=true reduced_static=true`; 기존 frame kit, S5-G4 Shift, S6-G2 CUT-IN, S8-G5 Black Hole phase/finale 회귀와 Main headless smoke도 모두 exit 0이었다.
- Godot 4.7.1 editor/headless project load는 exit 0이었다. Windows root certificate store와 editor settings 저장 접근 오류, Main 종료 시 기존 ObjectDB 3/resource 1 warning은 tooling/shutdown issue로 분리했고 새 GDScript/runtime error는 없었다.
- Native OpenGL Compatibility / Intel Arc 130V의 actual Main Ground mount에서 CRT 녹색 cue가 보이는 `tmp/s5_g4_cashout_direction_cue_ground.png`를 다시 저장했다. static frame 120-frame 비교는 cue off `31.7 FPS`/max `33.14ms`, cue on `31.7 FPS`/max `38.79ms`, average frame delta `+0.048ms`였다. 동일 실행 환경의 근사 비교이며 Web/browser 검증은 exact Goal 계약이 아니어서 실행하지 않았다.

## 2026-08-22 — Static CRT phosphor surface and text readability

Owner: Presentation / S5-G4 frame-owned maintenance (exact Goal ID 없음)

- `docs/design/TODOS.md`의 CRT Emission and Static 후속 항목을 사용자 승인 범위로 구현했다. 최신 지시에 따라 brightness breathing, flicker, sync jitter, rolling bar, random static과 motion은 전부 제외하고 정적 surface treatment만 사용했다. `STATUS.md`와 Integration lock은 변경하지 않았다.
- 새 `CrtSurfaceTreatment` 단일 draw node가 Stage, Time, Genealogy, Stage Score, item/status gauge, Pause, Retry의 7개 실제 glass mask를 정수 stepped polygon으로 그린다. backing은 Paper-8 최암색 `#1f244b`, bounded 2px halo/dither는 기존 `StageScoreGauge.CELL_COLOR #60ae7b`와 `CELL_HIGHLIGHT #b6cf8e`, edge는 `#3c6b64`를 사용한다. scanline은 고정 `4px` pitch의 `1px` hard row, alpha `0.24`이며 mask 밖에는 그리지 않는다.
- surface node는 frame CRT shell 위, Main의 HUD/Pause UI 아래에 고정했다. 따라서 Stage/Time/Stage Score/Genealogy Godot Label에는 scanline이 덮이지 않는다. baked Pause/Retry glyph는 surface로 덮은 뒤 `2x2` hard-pixel `PAUSE`/`RETRY`를 scanline 다음에 다시 그려 조작 의미를 유지한다. `_process`, Tween, shader, noise와 random source는 없다.
- HUD root는 nearest filtering을 명시하고 Stage/Time/Stage Score와 genealogy title/slot을 모두 정수 `14px`로 올렸다. label 내용, score/gauge 계산, genealogy reveal과 lifecycle은 변경하지 않았다. Paper-8 밝은 text 대비는 `#f6e79c` on `#1f244b` `11.92:1`, `#b6cf8e` `8.71:1`, `#60ae7b` `5.55:1`로 계산됐다. StageScoreGauge의 유일한 off-palette shadow `#2c6d61`은 승인 `#3c6b64`로 정규화했다.
- 전용 CLI verifier는 `S5_G4_CRT_SURFACE_VERIFIED static=true masks=7 scanlines=1px palette=paper8 text_above=true integer=true labels_unchanged=true`, exit 0. S1-G4 HUD, S3-G6 Stage HUD, S3-G8 gauge, S5-G4 frame/Shift, S1-G5 Pause, Cashout cue, S6-G2 CUT-IN, S8-G5 Black Hole phase/finale 회귀도 모두 exit 0이었다. Main 120-frame headless smoke는 exit 0이며 기존 shutdown-only ObjectDB 3/resource 1 warning만 남았다.
- Godot 4.7.1 editor/headless project load는 exit 0이었다. 첫 direct CLI test는 기존 `user://logs` 접근 실패 뒤 signal 11이었지만 workspace `--log-file` 지정 시 같은 test가 exit 0이어서 tooling path issue로 분리했다. root certificate store와 editor settings 저장 오류도 기존 Windows sandbox tooling issue이며 새 parse/runtime error는 없었다.
- Native OpenGL Compatibility / Intel Arc 130V에서 actual Main 기반 `1600x900` Ground `tmp/s5_g4_crt_surface_ground_1600x900.png`와 wider Galactic L2 `tmp/s5_g4_crt_surface_galactic_l2_1600x900.png`를 저장하고 clipping/readability를 직접 확인했다. 같은 static fixture의 120-frame 비교는 treatment off `31.6 FPS`/max `36.44ms`, on `31.5 FPS`/max `32.85ms`, average frame delta `+0.047ms`였다. 순차 측정 노이즈 범위라 max-frame 개선으로 해석하지 않으며, 이 실행에서는 측정 가능한 평균 추가 frame cost가 드러나지 않았다. exact Goal의 Web Gate가 없어 browser 검증은 실행하지 않았다.

## 2026-08-23 — S2-G5 production Merge FX replacement

Owner: Presentation / S2-G5 maintenance

- 임시 merged-ball name Label과 위로 떠오르는 generic debris를 제거했다. authoritative `ball_merged(result_level, world_position)` 2인자와 S6-G1 admission/budget은 유지하고, 현재 `StageDefinition.local_ball_levels` 또는 simulation의 read-only stage snapshot으로 result local level만 찾는다. score/value/name을 추측하거나 표시하지 않는다.
- 단일 procedural `MergeEffect`가 `INWARD(0.00~0.10s) → CORE(0.10~0.17s) → RESOLVE(0.17~0.32s)`를 그린다. 두 개의 짧은 2px stepped trail은 접점으로 수렴하고, Paper-8 `paper_050 #F4F5E8` core 뒤 승인 `ice #C9F3F5`/`merge_pink #FF5B9F`와 결과 Ball base color를 섞은 계단형 ring 1개·안쪽으로 정리되는 2~6 pixel만 남긴다. camera shake, blur, shader, per-particle child Node는 없다.
- local Lv0~4는 normal lifetime `0.32s`를 공유한다. ring은 결과 공 외곽을 조금 넘는 최대 반경 `14/20/30/48/82px`, resolve pixel은 `2/3/4/5/6`, trail은 항상 2개·각 최대 4 pixel로 제한한다. Reduced Effects는 `0.18s` core flash+ring만 사용하고 trail/secondary pixel/camera shake를 모두 생략한다.
- 기존 S2-G5 fixture 안에 no-text, phase order와 inward distance, current Stage local-level lookup, intensity monotonic/cap, reduced fallback, queued cleanup 뒤 registered Merge child 0개, signal argument 2개와 simulation read-only 검증을 추가했다. 기존 dirty fixture의 Ground `StageDefinition.apply_stage_definition()` 보정은 보존했다.
- Godot 4.7.1 CLI 결과: `S2_G5_VERIFIED merge_fx_once=true no_text=true phases=inward/core/resolve local_intensity=0..4_bounded reduced=core_ring cleanup=true contract_args=2 presentation_readonly=true`; S2-G3, S6-G1 budget, S6-G2 visible CUT-IN, S6-G2I handoff, S1-G4 HUD, S3-G6 Stage HUD, S6-G6 Settlement 회귀가 모두 exit 0이었다. editor/headless project load와 Main 120-frame smoke도 exit 0이었다.
- S6-G1 fixture의 실제 count는 Tier 0 same-frame 20회 중 active `4`/drop `16`, shared active cap `24`, cap 상태의 Tier 3 admission `1`/oldest lower-tier eviction `1`, Tier 4 active slot `1`이다. 이번 Native capture는 동시에 Merge FX `2`개를 사용했다. 기존 fixture가 frame timing을 노출하지 않아 새 FPS 수치는 만들지 않았다.
- Native OpenGL Compatibility / Intel Arc 130V에서 `1600×900` normal local Lv2와 high local Lv3를 같은 field에 둔 3-frame sequence를 저장했다: `tmp/presentation-captures/s2_g5_merge_fx_01_inward.png`, `s2_g5_merge_fx_02_core.png`, `s2_g5_merge_fx_03_resolve.png`; 세 파일 모두 save error 0이다. 직접 확인 결과 hard pixel edge, 새 공 silhouette/outline 유지, compact core, 외곽을 짧게 넘는 single ring, text/occlusion 없음으로 읽혔다.
- `project.godot`, Main, GameManager, StageManager와 Core simulation/scoring/velocity/event order는 수정하지 않았다. FIRST CONTACT CUT-IN asset/controller/timing도 수정하지 않았다. Integration lock과 `STATUS.md`는 건드리지 않았고 기존 S2-G5 `VERIFIED` 상태를 유지한다. exact Goal 상태 변경이 없는 maintenance라 Web/browser를 재실행하지 않았다.
- 알려진 환경 출력은 Windows root certificate store 접근 오류, editor settings 저장 거부, Main 종료 시 기존 ObjectDB 3/resource 1 warning이다. 모두 전용 scene/project load exit 0과 분리됐고 새 parse/runtime error는 없다. commit/push는 수행하지 않았다.

## 2026-08-23 — Active Cashout numeric popup readability maintenance

Owner: delegated Presentation/UI; S4-G4 boundary-adjacent maintenance through the existing S6-G1 FX budget path

- Follow-up 2026-08-23 (supersedes this section's original single-style `18px/#F6E79C/3px/2px` popup spec): ordinary Active Cashout remains decimal digits only, but its Presentation style now resolves the event `global_level` through the current `StageDefinition.local_ball_levels` ordering. Ground, Planetary, and Galactic therefore reuse identical local Lv0..4 styles with fonts `18/19/20/21/22px`, colors `#F4F5E8/#C9F3F5/#F6E79C/#48DDEC/#FFC857`, outlines `3/3/3/4/4px`, and hard shadow offsets `2/2/2/2/3px`. A catalog-valid level missing from the current Stage mapping falls back to local Lv0; the S6-G1 admission tier remains unchanged.
- The follow-up verifier passed exact five-style monotonic sizing/emphasis, all 15 Ground/Planetary/Galactic mappings, identical style reuse, fallback/invalid handling, decimal-only formatting, realistic `1e43` Galactic local Lv3 and local Lv4 edge clamps, Reduced Effects, deterministic cleanup, and the unchanged three-argument event/value. Required project load, S1-G3, S4-G4 renderer, S6-G1, S3-G4, S6-G6, frame/Cashout cue, S3-G5, and Main 120-frame smoke all exited 0. Native OpenGL Compatibility / Intel Arc 130V captures are `tmp/presentation-captures/s4_g4_cashout_popup_local_levels.png` and `s4_g4_cashout_popup_local_lv4_edge.png`, both 1600x900 with save error 0.
- Web verification addendum (supersedes the final bullet's earlier "not run" note): Godot 4.7.1 Web debug export completed and produced `tmp/s4-g4-cashout-web/index.html`, `.js`, `.wasm`, and `.pck`. An actual browser run was not completed because the required gstack browse executable is not installed in this workspace and its setup path is outside the sandbox write boundary. The separate Core S4-G4 browser clipping gate therefore remains unchanged/open.
- 문서상 정확한 `S4-G4`는 Core 소유의 일반 Snowball MultiMesh renderer이며 `IMPLEMENTED`, Integration lock은 released 상태다. 이번 변경은 `cashout_completed(score_amount, global_level, world_position)`를 소비하는 기존 normal Active Cashout Presentation popup만 다뤘고 Goal 상태는 변경하지 않았다.
- 기존 `<BALL NAME> CASHOUT +<compact score>`를 제거하고 숫자만 출력한다. 값은 기존 `ScoreFormatter.format_score_full(score_amount)`의 정수 표현을 그대로 사용하되 표시 구분 쉼표만 제거해 decimal digits만 남긴다. score 계산, 이벤트 값·3인자 signature·발행 순서, Time Bonus와 Stage/Run ledger는 변경하지 않았다.
- 팝업 글자는 pixel guide의 1차 Score 시작값 중 가장 작은 개선값인 정수 `18px`로 올렸다. `Consolas/Courier New/monospace` SystemFont의 antialiasing·hinting·subpixel positioning을 끄고 nearest filtering을 사용한다. 승인 Paper-8 `#F6E79C` 숫자, `#1F244B` 3px outline과 같은 색 2px integer shadow를 사용한다.
- 기존 lifetime `0.38s`와 하강 속도 `18px/s`는 유지하되 루트와 debris를 정수 좌표로 snap한다. 숫자 크기를 실제 측정해 simulation의 기존 read-only `get_active_play_field_rect()` 안쪽 8px에 좌·우·하단 clamp하며, 원본 event world position은 `cashout_effect_spawned` telemetry에 그대로 전달한다. Reduced Effects는 숫자·lifetime·cleanup을 유지하고 장식 debris만 생략한다.
- 새 전용 verifier는 `S4_G4_CASHOUT_PRESENTATION_VERIFIED digits_only=true font=18 color=f6e79c outline=1f244b/3px shadow=2px integer=true edge_clamp=true lifetime=0.38 cleanup=true reduced=true event_args=3 value_unchanged=true active_cashout=1 cleanup_active=0`, exit 0이다. 44자리 `1e43` source도 과학 표기 없이 decimal digits로 확장해 Ground active field의 좌·우 edge 안에 유지됨을 확인했다.
- Godot 4.7.1 CLI/editor project load, S4-G4 renderer, S6-G1 FX budget, S5-G4 frame/Cashout cue, S1-G3 Active Cashout, S3-G4 Settlement, S6-G6 Settlement presentation, S3-G5 Stage flow, S5-G6 Panel/S5-G6I confirmation 회귀가 모두 exit 0이었다. Main 120-frame headless smoke도 exit 0이며 기존 shutdown-only ObjectDB 3/resource 1 warning만 남았다.
- S6-G1 budget은 기존 전체 active cap `24`를 유지하며 전용 event 경로는 Cashout popup `1`개 active 후 cleanup/reset `0`개를 확인했다. 새 frame-time benchmark는 만들지 않았다.
- Native OpenGL Compatibility / Intel Arc 130V에서 `1600x900` 중앙과 긴 우측-edge 숫자를 각각 `tmp/presentation-captures/s4_g4_cashout_popup_center.png`, `s4_g4_cashout_popup_right_edge.png`로 저장했고 save error는 둘 다 `0`이다. 직접 확인 결과 digits-only, hard edge/outline, field 내부 clamp가 유지됐다.
- `project.godot`, `scenes/main/main.tscn`, `scripts/core/game_manager.gd`, `scripts/core/stage_manager.gd`와 Core simulation/scoring, Final Settlement, Stage Clear 파일은 수정하지 않았다. exact Presentation Goal 상태 변경이 없는 maintenance이며 별도 Core S4-G4 Web clip gate를 닫지 않으므로 Web/browser는 실행하지 않았다. commit/push도 수행하지 않았다.

## 2026-08-23 — Presentation ship documentation synchronization

Owner: Presentation

- 최신 구현과 직접 충돌하던 문서만 동기화했다. 당시 S6-G2 CUT-IN hold는 normal `2.00s`/reduced `1.80s`로 정리했으나, 이후 병합한 `8b349cd`의 Play Field-clipped 횡단 배너 계약이 normal `1.10s`/reduced `0.85s`로 이를 supersede한다. S7-G2는 범용 identity-neutral Item Ball과 Blizzard 전용 Orb/CUT-IN/active FX의 분리로 정정했다.
- S5-G4 개선 백로그는 10초 Cashout chevron cue와 정적 CRT phosphor/scanline의 실제 구현 상태를 반영했다. CRT 주요 정보 text의 현재 `14px`는 좁은 승인 mask의 잘림을 피하는 임시 예외이며, 18px 기준 회복은 font 또는 mask/layout 재설계 후속으로 남겼다.
- S2-G5 Status는 제거된 name/value popup 대신 `INWARD→CORE→RESOLVE` no-text Merge FX와 최신 CLI evidence를 기록했다. 기각된 일반 박스와 미채택 Item Ball 후보 문서·목업, `tmp/` 검증 산출물은 ship 대상에서 제외한다.

## 2026-08-23 — Orbital Cargo Item Ball runtime presentation handoff

Owner: Content/Systems-owned S7-G2 visual exception, implemented from the Presentation design branch for owner review

- 승인 reference `docs/design/mockups/item-ball-orbital-cargo-satellite-v3.png`를 기준으로 native `64px` grid의 `item_ball_orbital_cargo_h0_h4.png`와 4-frame `item_ball_neutral_break_fragments_4f.png`를 제작했다. 두 sheet는 binary alpha, hard edge, identity-neutral 외형을 사용한다.
- `scripts/presentation/item_blizzard_visual.gd`는 모든 item type의 Item Ball에 공통 H0~H4를 적용하고 `item_planet_broken` 뒤 neutral fragments를 재생한다. Blizzard Orb/CUT-IN/active snow는 기존 item-specific 표현을 유지한다. collision radius, hit 계산, 이동, pickup, item effect는 변경하지 않았다.
- 현재 권위 규칙대로 producer가 같은 break commit에서 `item_planet_broken` 뒤 `item_orb_spawned`를 즉시 발행하므로 fragments와 별도 Orb가 잠시 겹칠 수 있다. Presentation은 Orb의 이동·획득·miss를 지연시키지 않으며, 별도 handoff 없이 지연 동작을 발명하지 않았다.
- Godot 4.7.1 CLI에서 `S7_G1C_VERIFIED item_ball=once hits=5 orb=collect_or_miss`, `S7_G2_BLIZZARD_VISUAL_IMPLEMENTED item_ball_h0_h4=true break_frames=4 planet=true orb=true cue=true snow=48 cleanup=true`가 exit 0이었다. 관련 Merge/Cashout/cue/CRT/CUT-IN 전용 검증과 Main 120-frame headless smoke도 통과했다.
- 변경 범위에는 Content-owned 예외 파일 `scripts/presentation/item_blizzard_visual.gd`, `tests/content/s7_g1c_item_producer_verification.gd`, `tests/content/s7_g2_blizzard_visual_verification.gd`가 포함되므로 PR에서 Content/Systems owner review를 요청한다. Integration-owned Main/GameManager/StageManager는 수정하지 않았다.

## 2026-08-23 — Latest Main integration before Presentation ship

Owner: Integration merge support / Presentation conflict resolution

- `origin/main cd504b9`를 `fx-design`에 병합했다. 최신 Main의 Play Field-clipped FIRST CONTACT banner, S4-G4 textured clip fix, Paddle/Black Hole contact tuning, Fire Core/Magnet consumers와 terminal cleanup을 보존했다.
- 충돌은 `docs/goals/STATUS.md`, `docs/goals/slices/S6_GAME_FEEL.md`, `scripts/presentation/presentation_manager.gd` 세 파일이었다. S6-G2는 최신 `1.10s/0.85s` banner 계약과 `IMPLEMENTED` 상태를 선택하고, `PresentationManager`에는 최신 field rect configuration과 기존 Cashout cue suppression/resume을 함께 유지했다.
- Godot 4.7.1 CLI에서 Presentation 7개(Merge, Cashout, cue, CRT, FIRST CONTACT, Item producer/visual)와 새 Main의 Core/Integration 5개(Fire, Magnet, wiring, terminal cleanup)가 모두 exit 0이었다. Main 120-frame headless smoke도 exit 0이며 기존 shutdown-only ObjectDB/resource warning만 남았다.
## 2026-08-23 — Stage Clear chamber surface alignment

Owner: Presentation/UI (user-directed visual correction)

- Stage Clear Panel의 별도 초록 CRTGlass·scanline 레이어를 제거하고, 파이프 프레임의 내부 챔버가 Pause 모달과 같은 짙은 남청색(`0.018, 0.035, 0.06`)으로 바로 이어지게 했다.
- 기존 팔각 chamber polygon은 유지해 황동 파이프 모서리를 침범하지 않으며, 프레임과 모달 화면 사이에 보이던 초록색 inset 여백을 없앴다.
- Godot 4.7.1 CLI `S5_G6_VERIFIED open=true scores=true focus=true request_once=true duplicate_hidden_stale=true reset=true exclusions=true reduced=true core_readonly=true`, 최신 Web release export `[ DONE ] savepack`을 확인했다.

## 2026-08-23 — S6-G2 canonical 2.00s timing alignment

Owner: Presentation
Branch: `presentation/s6-g2-cutin-2s-web-acceptance` (후속 작업자가 `main` HEAD `3101dd7`의 미커밋 변경을 보존해 생성)

### 작업

- 기존 Play Field-clipped 횡단 배너의 단계 비율을 보존해 normal을 `enter 0.36s / hold 1.18s / exit 0.46s`, reduced-effects를 `fade-in 0.28s / hold 1.30s / fade-out 0.42s`로 조정했다. 두 profile의 설정 합계는 정확히 `2.00s`다.
- 자동/실제 Browser의 visible 시작부터 hide·matching completion까지 허용오차를 `2.00s ±0.05s`로 고정했다.
- fixture를 먼저 새 상수·합계·observed completion 계약으로 변경한 뒤 controller를 맞췄다. active visual Play Field clip, field-only dim, 승인 6종 layer, reduced no-slide, same-Run Stage reset, duplicate/stale/reset과 exact-once completion은 변경하지 않았다.
- GAME_RULES, TECHNICAL_DESIGN, S6 Slice/task, Quality Gate와 직접 결합된 current/design 문서만 같은 timing/dim 계약으로 정합화했다. 전달용 `ALL_IN_ONE`, 역사적 `INITIAL_PROMPT`와 과거 Worklog 기록은 수정하지 않았다.
- Integration/Core-owned runtime 파일과 Integration test는 수정하지 않았고 Integration lock은 released 상태다.

### 검증

- 정적 timing/canonical scan: `S6_G2_STATIC_TIMING_VERIFIED normal=2.00 reduced=2.00 normal_phases=0.36/1.18/0.46 reduced_phases=0.28/1.30/0.42 tolerance=0.05 canonical_files=10 stale=0`, exit 0.
- `git diff --check`: exit 0.
- Godot baseline은 실행 불가다. PATH, 표준 설치 경로, 사용자 프로필과 `where /R C:\ Godot*.exe` 검색에 executable이 없었고, 직전 Worklog의 `C:\Users\gktjd\AppData\Local\Programs\Godot\Godot_v4.7.1-stable_win64_console.exe --version`도 `CommandNotFoundException`, exit 1이었다.
- 따라서 project parse/load, `s6_g2_first_contact_cutin_verification.tscn`, `s6_g2i_first_contact_handoff_verification.tscn`, Main 120-frame smoke와 fresh Web export는 모두 `UNVERIFIED — Godot CLI tooling unavailable`이다.
- project-local gstack `browse.exe status`는 `server-node.mjs not found`, exit 1로 Chromium daemon 시작 전에 실패했다. 시스템 Chrome `151.0.7922.169`와 Edge `151.0.4129.101`은 존재하지만 fresh export가 없어 direct-browser 우회는 실행하지 않았다.
- Web acceptance a~i는 모두 `UNVERIFIED`이며 S6-G2는 `IMPLEMENTED`를 유지한다. 기존 export와 기존 untracked `tmp/` 증거물은 사용·수정하지 않았고 새 `build/s6-g2-cutin-2s-web-acceptance`도 생성하지 않았다.

### 다음 작업 / blocker 해제 조건

- Godot 4.7.1 executable을 복구한 뒤 CLI baseline 4종을 먼저 실행한다.
- fresh ignored build 경로로 Web Debug/Release를 export하고 local HTTP + actual Chrome/Chromium에서 clip/dim, `2.00s ±0.05s`, gameplay lock/resume, Black Hole direct handoff, Retry/Main stale cleanup, Canvas focus/resize, console error 0을 항목별로 다시 검증한다.
- 위 Gate를 모두 충족하기 전에는 S6-G2를 `VERIFIED`로 올리지 않는다.

## 2026-08-23 — S6-G2 2.00s CLI/Web acceptance follow-up

Owner: Presentation / S6-G2
Branch: `presentation/s6-g2-cutin-2s-web-acceptance`
Base HEAD: `3101dd79207b53a505c6a18aae95394ab05e15c5`
Integration Point: 기존 S6-G2I pause/S8 handoff API를 read-only 검증했으며 Integration lock은 없음

### 변경 검토와 보정

- 이전 작업의 tracked diff 14개 파일은 보고와 일치했다. normal `0.36/1.18/0.46s`, reduced `0.28/1.30/0.42s`, 각 합계 `2.00s`, 관찰 허용오차 `±0.05s`, active visual Play Field-only clip/dim이 current rules, technical design, Slice/task, Quality Gate, Presentation controller와 fixture에 정합하게 반영돼 있었다.
- 추가 runtime 확장이나 Core/Integration-owned 파일 변경은 하지 않았다. 자동 fixture의 실제 측정 근거를 남기기 위해 `tests/presentation/s6_g2_first_contact_cutin_verification.gd`의 성공 marker에 `normal_observed`와 `reduced_observed`만 추가했다.
- 기존 untracked 디자인 문서·mockup과 `tmp/`는 수정·삭제·추적하지 않았다. 검증 산출물은 `.gitignore`의 `build/` 아래 새 전용 경로 `build/s6-g2-cutin-2s-web-acceptance-20260823-followup/`에만 생성했다. export preset의 `all_resources`가 이전 build를 다시 pack하지 않도록 ignored `build/.gdignore`를 사용했다.

### Godot CLI/headless baseline

- 환경: `C:\Users\gktjd\AppData\Local\Programs\Godot\Godot_v4.7.1-stable_win64_console.exe`, `4.7.1.stable.official.a13da4feb`.
- Project parse/load: `--headless --editor --path . --quit`, exit 0 (`01_project_load.log`).
- Presentation: `--headless --path . res://tests/presentation/s6_g2_first_contact_cutin_verification.tscn`, exit 0. Marker: `S6_G2_VERIFIED ... duration=2.00 reduced_duration=2.00 normal_observed=2.000 reduced_observed=2.000 tolerance=0.05 ...` (`06_s6_g2_presentation_measured.log`).
- Integration handoff: `--headless --path . res://tests/integration/s6_g2i_first_contact_handoff_verification.tscn`, exit 0. Marker: `S6_G2I_VERIFIED fifo=true pause=true stale_rejected=true black_hole_gate=true reset=true` (`03_s6_g2i_integration.log`).
- Main smoke: `--headless --path . --quit-after 120`, exit 0 (`04_main_smoke.log`). 종료 시 기존 shutdown-only ObjectDB 3/resource 1 warning만 있었고 parse/runtime error는 없었다.

### Fresh Web export와 실제 Browser

- Release: `--headless --path . --export-release Web build/s6-g2-cutin-2s-web-acceptance-20260823-followup/web-final/index.html`, exit 0 (`07_web_export_final.log`). Final PCK SHA-256는 `1C28B91C5DABFFB6AE369C5F3800B23330FE77A90872B72ABFCF2A7AD294C61E`다.
- Debug: 같은 fresh source에서 `--export-debug Web .../web-debug-final/index.html`, exit 0 (`17_web_export_debug.log`). Release/Debug export log 모두 `res://build` pack 항목이 없음을 확인했다.
- `python -m http.server`로 Release `127.0.0.1:8765`, Debug `127.0.0.1:8766`을 제공하고 설치된 Google Chrome `151.0.7922.169`을 별도 fresh profile과 DevTools Protocol 1.3으로 실행했다. Web 환경은 Godot 4.7.1 single-threaded Emscripten 4.0.20, WebGL 2.0, ANGLE D3D11 Intel Arc 130V다.
- actual Main release에서 HTML/JS/WASM/PCK와 이미지가 모두 HTTP 200이었다. Canvas는 `1600×900`과 resize 후 `1024×768`에서 DOM rect와 backing size가 일치하고 focus를 유지했다. console error, runtime exception, error log, failed network request는 모두 0이다 (`13_browser_acceptance_main.json`, `09_main_1600x900.png`, `10_main_playing_1600x900.png`, `11_main_resized_1024x768.png`).
- actual Main debug를 정상 플레이해 Giant Snowball FIRST CONTACT를 자연 발생시켰다. 전 frame `natural-frames/frame_0096_13272ms.png`, 표시 중 `frame_0101_14226ms.png`, 후 frame `frame_0107_15390ms.png`에서 banner와 dim이 active Play Field 안에만 있고 Stage World/HUD/기계 frame은 영향을 받지 않음을 확인했다. CUT-IN 동안 HUD timer, ball simulation과 Paddle이 정지하고 계속 보낸 A/D 입력도 적용되지 않았으며, 종료 뒤 timer·ball·Paddle gameplay가 정상 재개됐다. 248-frame run의 console/runtime error는 0이다 (`18_natural_browser_capture.json`).
- 정밀 PNG 경계 관찰에서 표시 직전/최초 frame은 `17140.922/17257.401ms`, 최종/표시 직후 frame은 `19128.123/19272.372ms`였다. 두 경계 midpoint 차이는 `2.001s`지만 캡처 간격을 포함한 가능한 실제 범위는 `1.871–2.131s`다 (`19_natural_precision_capture.json`). point estimate는 목표와 일치하지만 `±0.05s`를 엄밀히 증명하지 못하므로 Browser duration은 UNVERIFIED다. 이는 새 FPS benchmark가 아니라 Browser visible-duration 관찰이다.

### Web acceptance 결과

- a active Play Field 내부 clip: PASS — 실제 Main frame에서 banner가 field 내부에만 표시됨.
- b dim 범위 canonical 일치: PASS — dim은 active Play Field-only이고 Stage World/HUD/frame은 비감광.
- c 실제 총 `2.00s ±0.05s`: UNVERIFIED — Chrome midpoint는 `2.001s`이나 sampling bracket이 `1.871–2.131s`; CLI normal/reduced 각 `2.000s`는 PASS.
- d timer/spawn/simulation/Paddle 입력 잠금: PASS — 실제 Web frame sequence와 A/D 입력에서 lock, CLI Presentation/S6-G2I fixture에서 각 subsystem 계약 확인.
- e 일반 종료 뒤 gameplay 정상 복귀: PASS — 실제 Web에서 timer·ball·Paddle 진행 재개.
- f 첫 Black Hole이 중간 gameplay frame 없이 S8 Phase로 handoff: UNVERIFIED — S6-G2I CLI `black_hole_gate=true`는 PASS지만 실제 Web Galactic handoff를 직접 캡처하지 못함.
- g Retry/Main stale tween/completion 제거: UNVERIFIED — CLI Presentation reset/stale와 S6-G2I reset은 PASS지만 실제 Web Retry/Main 경로를 직접 캡처하지 못함.
- h Canvas focus/resize: PASS — `1600×900→1024×768`, Canvas focus 유지.
- i console error 0: PASS — Release Main과 자연 발생 CUT-IN 두 실제 Chrome run 모두 console/runtime/network error 0.
- Web fixture HTML wrapper는 scene argument로 Presentation fixture를 직접 실행한 뒤 `SceneTree.quit()` 이후 generated page에서 `null function`으로 종료돼 marker 수집에 실패했다. 같은 방식의 보정을 3회까지만 시도하고 중단했다. CLI fixture와 actual Main Web은 정상이라 게임 오류가 아니라 fixture-wrapper/tooling 문제로 분리했다. project-local gstack browser도 `server-node.mjs not found`라 수리하지 않고 설치된 Chrome의 DevTools 경로를 사용했다.

### 최종 판정

- c/f/g의 direct Web evidence가 충분하지 않아 S6-G2 Quality Gate 전체는 미충족이다. `docs/goals/STATUS.md`는 `IMPLEMENTED`를 유지하고 a/b/d/e/h/i PASS, c/f/g UNVERIFIED를 기록했다.
- 검증 후 두 HTTP server와 검증용 Chrome process를 종료하고 ports `8765/8766/9223~9229` listener 및 해당 fresh-profile Chrome 잔존이 0임을 확인했다.
- commit, push, PR은 수행하지 않았다. 실제 성능 FPS 수치는 이 acceptance 범위에서 새로 측정하지 않았다.

## 2026-08-23 — S6-G2 MCP timeout recovery audit

Owner: Presentation / S6-G2 recovery audit
Branch: `presentation/s6-g2-cutin-2s-web-acceptance`
Base HEAD: `3101dd79207b53a505c6a18aae95394ab05e15c5`

- 직전 Codex 후속 세션이 1800초 MCP timeout으로 최종 응답 없이 종료된 뒤 별도 작업자로 중간 상태를 read-only 감사했다. 요청 브랜치는 이미 현재 worktree에 checkout되어 있었고 tracked 14개 파일의 미커밋 변경과 기존 untracked 디자인 문서·mockup·`tmp/`가 보존돼 있었다. reset/restore/clean, commit/push/PR은 수행하지 않았다.
- `build/s6-g2-cutin-2s-web-acceptance-20260823-followup/`의 CLI log, Release/Debug export, PCK SHA-256, Chrome JSON/PNG를 대조했다. `--version`은 120초 제한에서 exit 0(`4.7.1.stable.official.a13da4feb`)이었고, 기존 project load, Presentation fixture, S6-G2I handoff fixture, Main 120-frame smoke log는 모두 신뢰 가능한 exit 0 Evidence로 확인했다. export 두 건은 `savepack` 완료, `res://build` pack 0건, final PCK SHA-256 `1C28B91C5DABFFB6AE369C5F3800B23330FE77A90872B72ABFCF2A7AD294C61E`다.
- 실제 Chrome Evidence는 a/b/d/e/h/i PASS를 지지한다. c는 midpoint `2.001s`지만 sampling bracket `1.871–2.131s`라 `±0.05s`를 직접 증명하지 못했고, f/g도 CLI fixture만 PASS이며 직접 Web 경로가 없어 UNVERIFIED다. S6-G2는 `IMPLEMENTED`를 유지한다.
- 이전 후속 세션의 전용 HTTP `8765/8766`, DevTools `9223~9229`, fresh-profile Chrome 잔존은 0이었다. 현재 보이는 다른 Godot/MCP/HTTP 프로세스는 생성 시각·명령이 이번 S6-G2 후속 검증과 일치하지 않아 종료하지 않았다. 사용자의 일반 Chrome 창도 종료하지 않았다.

## 2026-08-23 — S6-G2 deterministic Web acceptance final

Owner: Presentation / S6-G2
Branch: `presentation/s6-g2-cutin-2s-web-acceptance`
Base HEAD: `3101dd79207b53a505c6a18aae95394ab05e15c5`
Owned Files: `scripts/presentation/cutin_controller.gd`, `tests/presentation/s6_g2_web_acceptance.gd`, `tests/presentation/s6_g2_web_acceptance.tscn`
Integration Point: 기존 S6-G2I authoritative FIRST CONTACT completion/S8 handoff API를 실제 Main instance에서 read-only 검증했으며 Integration-owned production file 수정과 lock은 없다.

### 구현과 원인

- Web에서 `SceneTree.quit()`에 의존하지 않는 test-only acceptance scene을 추가했다. 40초 watchdog과 화면/console의 `S6_G2_WEB_ACCEPTANCE_PASS|FAIL` JSON marker로 무한 대기를 막고 browser automation이 결과를 안정적으로 수집한다.
- c는 visible start부터 matching completion까지 `Time.get_ticks_usec()`로 normal/reduced를 각각 3회 측정한다. f는 실제 Main의 authoritative `galactic_black_hole` FIRST CONTACT payload를 주입해 completion과 S8 phase start의 `Engine.get_process_frames()`, event ID, run epoch, 중간 resumed gameplay frame 수를 기록한다. g는 CUT-IN 진행 중 Retry/Main reset 각각에서 stale completion과 다음 epoch의 새 completion을 기록한다.
- 첫 실제 Web run에서 c가 normal `[1.9185, 1.9365, 1.8491]s`, reduced `[1.9023, 1.9217, 1.9351]s`로 실패해 실제 Presentation 결함을 발견했다. Web frame delta로 진행되는 Tween이 monotonic Godot time보다 일찍 완료될 수 있었다. `CutInController`는 visible 시점에 monotonic 2.00초 completion deadline을 잡고 Tween 종료가 이보다 빠르면 process frame을 기다린 뒤에만 matching completion을 emit하도록 최소 수정했다. 시작 frame의 누적 delta도 소비하지 않도록 다음 process frame에서 Tween을 시작하며, reset generation guard와 tween kill은 그대로 유지한다.
- Core/Integration-owned production file은 수정하지 않았다. 기존 untracked 디자인 문서·mockup·`tmp/`도 수정·삭제·추적하지 않았다.

### CLI/headless 결과

- Godot `4.7.1.stable.official.a13da4feb`; project editor load exit 0.
- 기존 Presentation fixture exit 0: `S6_G2_VERIFIED ... normal_observed=2.045 reduced_observed=2.050 tolerance=0.05 ...`.
- 새 acceptance fixture native smoke exit 0: normal `[2.002751, 2.002953, 2.002594]s`, reduced `[2.002303, 2.004680, 2.002546]s`, f same-frame/0 gameplay frame, Retry/Main stale `0`, next completion `1`.
- S6-G2I exit 0: `fifo=true pause=true stale_rejected=true black_hole_gate=true reset=true`.
- Main 120-frame smoke exit 0. 기존 shutdown-only ObjectDB 3/resource 1 warning만 유지되며 parse/runtime error는 없다.
- fresh isolated fixture-project Debug Web export exit 0. 검증 산출물은 gitignored `build/s6-g2-cutin-2s-web-acceptance-20260823-final/`에만 저장했다.

### 실제 Web c/f/g 및 최종 판정

- 환경: Chrome `151.0.7922.169`, DevTools Protocol 1.3, Godot 4.7.1 single-threaded Web, Emscripten 4.0.20, WebGL2/ANGLE D3D11 Intel Arc 130V, Canvas `1600×900` focused.
- c PASS: warmup `2.0063s`; normal `[2.0033, 2.0028, 2.0030]s`, reduced `[2.0019, 2.0043, 2.0066]s`; 6/6이 `[1.95, 2.05]s` 안이다.
- f PASS: `event_id=3001`, `run_epoch=1`, matching completion frame `977`, S8 phase start frame `977`, `gameplay_resumed_frames_between=0`, `BLACK_HOLE_PHASE_LOCKED`, phase start에서 CUT-IN hidden.
- g PASS: Retry old `[4001,2]` stale `0`, new `[4002,3]` completion `1`; Main old `[4003,3]` stale `0`, epoch invalidated, new `[4004,4]` completion `1`; 두 reset 모두 즉시 hidden.
- 최종 marker `S6_G2_WEB_ACCEPTANCE_PASS`, console error `0`, exception `0`, failed network `0`. 기존 actual Main Web의 a/b/d/e/h/i evidence를 유지하므로 a~i 모두 PASS이며 `docs/goals/STATUS.md`를 `VERIFIED`로 갱신했다.
- 검증용 HTTP `8877`, DevTools `9337`, isolated Chrome/profile은 runner `finally`에서 종료·삭제했다. 사용자의 일반 Chrome과 기존 Godot Project Manager는 건드리지 않았다. commit/push/PR은 수행하지 않았다.

## 2026-08-23 — S6-G2 post-merge ship gate refresh

Owner: Presentation / S6-G2
Branch: `presentation/s6-g2-cutin-2s-web-acceptance`
Base/HEAD after fetch and merge: `origin/main` `3a611e5c0548ddcfe8d3bfb8cf89acd5af07ced6` (fast-forward, no merge commit)
Integration Point: 기존 S6-G2I API와 Integration-owned production 파일은 read-only 검증했으며 lock은 없다.

- `origin/main` 합류로 GameManager와 audio/UI base 코드가 바뀌어 이전 Web fixture의 전체 코드 hash가 더 이상 같지 않았다. 현재 tracked worktree와 의도된 Web acceptance 파일 3개만 복사한 fresh fixture-project를 만들고 CLI/Web gate를 다시 실행했다. 보호 대상 untracked 디자인 문서 2개, mockup 2개, `tmp/`는 복사·수정·삭제·stage하지 않았다.
- 첫 post-merge Presentation 실행은 테스트가 `play_first_contact_cutin()` 호출 준비 시간까지 관찰 구간에 포함해 reduced profile을 잘못 실패시켰다. production 코드는 바꾸지 않고 normal/reduced 측정 시작점을 호출 수락 직후 visible-start 경계로 옮겼다. 재실행 결과 `normal_observed=2.003s`, `reduced_observed=2.002s`, 허용오차 `±0.05s`로 exit 0이다.
- Godot 4.7.1에서 project editor load `4.835s`, Presentation `26.154s`, S6-G2I `0.957s`, headless Web acceptance `26.255s`, Main 120-frame smoke `1.713s`로 모두 exit 0이었다. Integration marker는 `fifo=true pause=true stale_rejected=true black_hole_gate=true reset=true`다.
- fresh Debug Web export는 exit 0이고 PCK SHA-256은 `697D3E76C26EBF5897677413D36817C8906B63A8A8EC39C514F99D0A33C2AE4A`다. 격리 Chrome `151.0.7922.169`, WebGL2, focused `1600×900` Canvas에서 normal `[2.0028, 2.0078, 2.0008]s`, reduced `[2.0011, 2.0078, 2.0065]s`, f same-frame `980`/gameplay gap `0`, Retry/Main stale completion `0`과 새 completion `1`을 확인했다. 최종 marker는 `S6_G2_WEB_ACCEPTANCE_PASS`, browser console/exception/log/network error 합계는 `0`이다.
- Evidence는 `build/s6-g2-ship-gate-20260823-fresh-rerun/`에 저장했다. 검증 뒤 HTTP/DevTools listener, fresh-profile process, profile directory가 모두 `0/0/false`임을 확인했다. commit, push, PR, VERSION, CHANGELOG, TODOS 변경은 수행하지 않았다.
