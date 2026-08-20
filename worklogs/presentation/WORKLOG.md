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
