# Galactic Black Hole Redesign v1

Snowball Effect의 Galactic Stage 최종공 `Black Hole` 인게임 외형 후보 3종이다. 사용자의 최신 지시에 따라 pixel design guideline은 의도적으로 적용하지 않았고, 얇은 edge-on accretion disk, 위·아래로 휘어 보이는 gravitational lensing, 완전히 비어 있는 검정 shadow라는 물리 시각 언어를 프로젝트 고유 팔레트로 재해석했다.

사용자가 **C — VOID CATHEDRAL**을 최종 선택하고 `C로 적용하자`고 명시적으로 승인했다. A/B와 원본 master/inspection은 비교 기록으로 보존하며, C의 실제 `128×128` 파일만 global Lv14 initial in-game visual LOD에 적용했다.

## 권위 매핑과 실제 크기

- [`scripts/data/ball_catalog.gd`](../../../../../scripts/data/ball_catalog.gd)는 index `14`에서 [`resources/balls/ball_14_black_hole.tres`](../../../../../resources/balls/ball_14_black_hole.tres)를 로드한다.
- BallDefinition은 `global_level = 14`, `display_name = "Black Hole"`, `visual_key = &"black_hole"`, `score_value = 1.0e50`, `base_color = #10091F`, `fx_tier = 4`다.
- [`resources/stages/stage_02_galactic.tres`](../../../../../resources/stages/stage_02_galactic.tres)의 ordered chain은 `[10, 11, 12, 13, 14]`다. global Lv14의 index는 `4`, 즉 **Galactic local Lv4**다.
- [`scripts/simulation/ball_simulation_manager.gd`](../../../../../scripts/simulation/ball_simulation_manager.gd)의 `stage_base_ball_radius = 4.0`과 `stage_base_ball_radius * 2^local_level` 공식에 따라 runtime radius는 `4 × 2^4 = 64`, authoritative diameter는 **`128 logical pixel`, 실제 출력 `128×128px`**다.
- Presentation exact-size LOD는 [`scripts/presentation/ball_texture_lod_catalog.gd`](../../../../../scripts/presentation/ball_texture_lod_catalog.gd)에서 global Lv14 / `128px`를 선택된 [`ball_galactic_local_lv04_black_hole_void_cathedral_128.tres`](../../../../../assets/sprites/balls/galactic/runtime/ball_galactic_local_lv04_black_hole_void_cathedral_128.tres)에 매핑한다. 이 CanvasTexture는 [`black-hole-C-void-cathedral-128.png`](black-hole-C-void-cathedral-128.png)와 byte-identical한 runtime PNG를 nearest filtering/repeat disabled로 바인딩한다.
- BallDefinition의 `radius = 32768`은 catalog/fallback seed다. 현재 Stage runtime 크기의 source of truth가 아니다.

### 최종 국면 기믹 계약

[`docs/current/02_GAME_RULES.md`](../../../../../docs/current/02_GAME_RULES.md), [`docs/current/tasks/07_black_hole.md`](../../../../../docs/current/tasks/07_black_hole.md), [`docs/goals/slices/S8_BLACK_HOLE.md`](../../../../../docs/goals/slices/S8_BLACK_HOLE.md)는 다음을 일관되게 규정한다.

- Black Hole은 별도 Stage나 새 BallDefinition이 아니다.
- 첫 Galactic Lv14 생성은 즉시 Stage Clear/Result가 아니다. committed Merge와 FIRST CONTACT CUT-IN 뒤 첫 이동 Black Hole entity 및 같은 Galactic 안의 최종 국면으로 handoff한다.
- 두 번째 Black Hole을 만들고 두 entity가 실제 접촉해야 terminal finale와 Run End가 잠긴다.
- 전환된 이동 Black Hole의 gameplay footprint는 Galactic local Lv2인 Quasar 크기를 기준으로 한다. 이번 `128px` 검토는 **Lv14 공의 생성·FIRST CONTACT·전용 외형 handoff에 쓰이는 authored visual** 후보이며 force, contact radius, 전용 phase renderer를 변경하지 않는다.

따라서 비교판의 문구도 `Stage 4`나 `Stage Clear`가 아니라 **Galactic final-phase handoff**로 표기했다.

## 확인한 현재 시각 계보

| 대상 | 확인 파일 | 현재 핵심 형태 | 이번 후보의 연결 / 구분 |
|---|---|---|---|
| 승인 Black Hole FIRST CONTACT CUT-IN | [`black-hole-portrait-v1.png`](../../../../../assets/sprites/cutins/first_contact/black-hole-portrait-v1.png) | 완전한 검정 void, 금백 inner rim, 보라 torus, cyan orbit dash, cardinal flare | 금백·보라의 위계와 빈 중심을 연결하되 cardinal flare와 분절 기계 링은 복제하지 않음. CUT-IN은 수정하지 않음 |
| 이전 Black Hole runtime fallback | [`ball_lv14_black_hole_128.png`](../../../../../assets/sprites/balls/galactic/runtime/ball_lv14_black_hole_128.png) | 큰 검정 중심, 분절 violet/cyan ring, 사방 flare | 삭제하지 않고 fallback으로 보존. active global14/128 LOD만 C의 연속적인 중력렌즈 현상으로 전환 |
| 승인·적용 Quasar A | [`ball_galactic_local_lv02_quasar_polar_beacon_32.png`](../../../../../assets/sprites/balls/galactic/runtime/ball_galactic_local_lv02_quasar_polar_beacon_32.png) | 청보라 기울어진 원반과 강한 양극 제트 | 후보 모두 jet/polar beam을 금지하고 검정 shadow와 lensing을 정체성으로 사용 |
| 승인·적용 Event Horizon C | [`ball_galactic_local_lv03_event_horizon_last_light_64.png`](../../../../../assets/sprites/balls/galactic/runtime/ball_galactic_local_lv03_event_horizon_last_light_64.png) | 한쪽 금백 crescent와 희미한 냉색 반대편 echo | 후보 모두 완성된 수평 accretion disk와 상·하 lens image를 추가해 크기뿐 아니라 구조적으로 다음 단계가 됨 |

현재 Galactic progression은 `Galaxy 8 → Galaxy Cluster 16 → Quasar A 32 → Event Horizon C 64 → Black Hole 128`이다.

## 공통 디자인 계약

- 실제 투명 RGBA 배경의 단일 우주 현상. 텍스트, UI, 프레임, 워터마크, 별도 우주 배경, 별 무리 없음.
- 중심 shadow는 순수/준순수 검정이며 실제 128px에서 불투명·무상세다. 내부에 별, 은하, 눈, 얼굴, 표면, 밝은 핵이 없다.
- 원형 행성 표면이 아니라 수평 강착원반과 휘어진 빛이 형태를 만든다.
- 128px alpha bbox는 최대 `120px` subject box에 맞춰 모든 방향의 canvas edge와 최소 `4px` 이상 분리했다.
- 실제 크기 파일은 master alpha bbox를 비율 유지 Lanczos 축소했다. 축소 뒤 충분히 어두운 중심 shadow만 순수 검정/불투명으로 정규화해 작은 크기의 뭉개짐을 방지했다.
- inspection은 대응 `128×128`을 nearest-neighbor로 정확히 `2×` 확대한 `256×256`다.
- 영화의 특정 프레임, 로고, 텍스트, 정확한 구도는 사용하지 않았다.

## 후보

### A — GARGANTUA CLASSIC

가장 정통적인 금백색 edge-on 원반과 위·아래 lens image를 차분한 대칭 구도로 정리했다.

- 색: absolute black, white-gold, ivory, restrained amber
- 실루엣: 넓은 수평 원반 + 대칭 상·하 아치 + 두 개의 큰 검정 shadow lobe
- 감정: 사실적, 차분함, 장엄함
- 장점: 물리적 블랙홀 판독이 가장 빠르고 원반 각도 `+0.11°`, 좌우 RGBA 차이 `0.0140`으로 가장 안정적이다.
- 단점: 밝은 영역의 `95.15%`가 warm 계열이라 Galactic 보라색 및 CUT-IN 계보와의 직접 연결은 C보다 약하다.
- 실제 128px: **PASS** — shadow `1,752px`(`10.69%`), alpha bbox `4,20–124,108`, 여백 `4/20/4/20`, 상·하 bright lensing `1,192/1,087px`, 수평 disk span `111px`가 유지된다.

### B — DOPPLER MAW

접근면의 청백색과 후퇴면의 적금색을 강하게 갈라 빠른 회전과 위험을 표현했다. 원반과 렌즈상은 약 `−6.30°` 기울었다.

- 색: absolute black, electric cyan, blue-white, ember orange, red-gold, crimson
- 실루엣: 기울어진 비대칭 원반 + 왼쪽 압축된 청백 흐름 + 오른쪽 늘어난 적금 흐름
- 감정: 포식적, 동적, 위험함
- 장점: 좌우 RGBA 차이 `0.1060`, cool/warm 비율 `57.52% / 33.57%`로 A/C와 가장 즉시 구분되고 Doppler 운동감이 가장 강하다.
- 단점: 빛의 밀도가 높아 검정 shadow 면적 `6.88%`가 세 후보 중 가장 작고 A보다 한 박자 복잡하게 읽힌다.
- 실제 128px: **PASS** — shadow `1,127px`, alpha bbox `4,24–124,103`, 여백 `4/24/4/25`, 상·하 lensing `649/643px`, disk span `108px`가 남는다.

### C — VOID CATHEDRAL

넓은 무광 shadow와 금백·Galactic violet의 다층 lens arch를 수평으로 쌓아 최종기믹다운 압도를 만든다. 기계 링이나 literal architecture는 사용하지 않았다.

- 색: absolute black, antique gold, ivory, ultraviolet, Galactic violet, small cyan accents
- 실루엣: 세 후보 중 가장 큰 shadow + 수평 원반 + 넓은 상·하 lens echo + 얇은 photon ring layer
- 감정: 성스럽고 압도적, 최종보스적
- 장점: shadow `12.84%`로 가장 크고, bright palette의 violet 비율 `48.20%`가 승인 CUT-IN의 보라·금백 계보를 가장 자연스럽게 잇는다.
- 단점: A보다 lens layer가 많아 전용 runtime phase FX와 함께 쓸 경우 외곽 광량 중복을 조정해야 한다.
- 실제 128px: **PASS** — shadow `2,104px`, alpha bbox `4,14–124,114`, 여백 `4/14/4/14`, 상·하 lensing `1,255/1,247px`, disk span `120px`가 유지된다.

## 추천

사용자가 **C — VOID CATHEDRAL**을 최종 확정했다. 실제 128px에서 가장 넓고 완전히 비어 있는 shadow를 유지하면서 승인 Black Hole CUT-IN의 금백·보라 계보를 물리적인 lensing layer로 변환한다. Event Horizon C의 단일 crescent에서 구조적 위계를 가장 크게 올리고, Quasar A의 양극 제트와도 겹치지 않아 Galactic 최종기믹의 고유성이 가장 강하다.

- 승인 source/runtime SHA-256: `6EFA4CE42876759EEA3FA4539B1D46E2ACC89867654D2071BE88C5A8243EF465`
- runtime PNG: [`ball_galactic_local_lv04_black_hole_void_cathedral_128.png`](../../../../../assets/sprites/balls/galactic/runtime/ball_galactic_local_lv04_black_hole_void_cathedral_128.png)
- runtime resource: [`ball_galactic_local_lv04_black_hole_void_cathedral_128.tres`](../../../../../assets/sprites/balls/galactic/runtime/ball_galactic_local_lv04_black_hole_void_cathedral_128.tres)

A는 사실성과 즉시성을 최우선할 때, B는 위험과 회전 운동감을 최우선할 때의 대안이다.

## 생성 및 축소

- Built-in `image_gen`을 A/B/C에 각각 독립 호출 `1회` 사용했다. contact sheet를 생성하거나 잘라 쓰지 않았다.
- 재시도는 A `1회`, B/C `0회`다. A 최초 출력의 낮은 alpha가 수평 edge에 닿아 framing 재시도를 사용했으나 재시도 결과가 투명 배경 대신 checkerboard를 그려 심각한 위반으로 폐기했다. 최종 A master는 독립 최초 출력이며 visible subject를 재생성하지 않았다.
- 세 master는 모두 `1254×1254 RGBA`다. 생성기가 edge에 남긴 `alpha <= 5/255` 잔여만 투명/clear RGB로 정리했다. master의 색, 구조, shadow, 원반, lensing은 바꾸지 않았다.
- 실제 `128×128`은 정리된 alpha bbox를 `120×120` 안에 Lanczos로 맞춰 중앙 배치했다. 축소 뒤 `alpha <= 2` residue를 정리하고, `alpha >= 192`이면서 luminance `<= 14`인 shadow 내부를 `RGBA(0,0,0,255)`로 정규화했다.
- `256×256` inspection은 대응 128px의 각 픽셀을 정확히 `2×2` block으로 복제한다.

## 검증 결과

### Master

| 후보 | 규격 | alpha bbox | 여백 L/T/R/B | edge alpha | alpha>8 component |
|---|---|---|---|---:|---:|
| A | `1254×1254 RGBA` | `3,146–1253,1059` | `3/146/1/195` | `0` | `2` |
| B | `1254×1254 RGBA` | `18,218–1234,1017` | `18/218/20/237` | `0` | `2` |
| C | `1254×1254 RGBA` | `12,115–1242,1139` | `12/115/12/115` | `0` | `1` |

A/B master의 두 component는 high-resolution lensing arc의 부분 분리다. 실제 128px에서는 세 후보 모두 alpha>8 기준 단일 connected silhouette다. 분리광을 지우는 미관 보정은 하지 않았다.

### 실제 128px / inspection 256px

| 후보 | actual bbox | 여백 L/T/R/B | edge alpha | shadow pixel / canvas | center sample alpha / luma | 상·하 lensing | disk span / angle | 2× nearest |
|---|---|---:|---:|---:|---|---:|---|---|
| A | `4,20–124,108` | `4/20/4/20` | `0` | `1,752 / 10.69%` | `255 / max 0.0` | `1,192 / 1,087` | `111px / +0.11°` | PASS |
| B | `4,24–124,103` | `4/24/4/25` | `0` | `1,127 / 6.88%` | `255 / max 0.0` | `649 / 643` | `108px / −6.30°` | PASS |
| C | `4,14–124,114` | `4/14/4/14` | `0` | `2,104 / 12.84%` | `255 / max 0.0` | `1,255 / 1,247` | `120px / −0.09°` | PASS |

세 후보의 master/actual/inspection은 모두 유효 PNG, 디코드 후 `RGBA`, 실제 투명 pixel 포함, `edge alpha = 0`이다. actual은 정확히 `128×128`, inspection은 정확히 `256×256`이며 nearest pixel equality를 통과했다. 중심 shadow sample `110px`는 모두 alpha `255`, luminance max/stddev `0.0/0.0`으로 불투명·무상세다.

### 128px 판독성·구조 상승

- A/B/C 모두 equatorial bright disk span이 `108–120px`이고 upper/lower lensing bright pixels가 양쪽 모두 존재해 수평 원반과 상·하 lens image가 실제 크기에서 분리된다.
- Event Horizon C의 구조는 `64px` 단일 우측 crescent + 희미한 반대 echo다. 세 Black Hole 후보는 `128px`에서 완전한 equatorial disk, 상·하 lensing, 두 개의 opaque shadow lobe를 추가한다. 따라서 단순 확대가 아니라 구조적 최종 단계 상승이다.
- Quasar A의 정체성인 밝은 핵과 polar jet은 세 후보 모두 없다. Black Hole의 검정 shadow가 면적과 대비의 주인공이다.
- 밝은 중립 배경과 실제 Play Field 계열 `#050816` 양쪽에서 actual 128px의 중심·직경·원반을 확인했다.

### Anti-convergence

- A는 warm `95.15%`, 좌우 차이 `0.0140`, disk `+0.11°`로 따뜻하고 정적인 대칭형이다.
- B는 cool `57.52%` / warm `33.57%`, 좌우 차이 `0.1060`, disk `−6.30°`로 냉·온 비대칭과 기울기가 지배한다.
- C는 violet `48.20%`, 가장 큰 shadow, 다층 lens arch와 거의 수평인 `−0.09°`로 프로젝트 고유 final-boss형이다.
- pairwise actual RGBA 평균 차이는 A/B `0.1090`, A/C `0.1136`, B/C `0.1618`; 최소 `0.1090 >= 0.08`로 anti-convergence 자동 Gate를 통과했다.

상세 수치는 [`validation.json`](validation.json)에 기록했다.

## 파일

| 구분 | A | B | C |
|---|---|---|---|
| master | `black-hole-A-gargantua-classic-master.png` | `black-hole-B-doppler-maw-master.png` | `black-hole-C-void-cathedral-master.png` |
| actual `128×128` | `black-hole-A-gargantua-classic-128.png` | `black-hole-B-doppler-maw-128.png` | `black-hole-C-void-cathedral-128.png` |
| inspection `256×256` | `black-hole-A-gargantua-classic-inspection-256.png` | `black-hole-B-doppler-maw-inspection-256.png` | `black-hole-C-void-cathedral-inspection-256.png` |

- `comparison.html`: master, actual 128px의 중립/Play Field 계열 배경, 2× inspection, 최신 Galactic progression과 final-phase handoff 표기.
- `comparison-render-1440x900.png`: 비교 HTML의 정적 렌더.
- `build_and_validate.py`, `validation.json`: 결정적 축소·검증과 결과.
- `black-hole-C-void-cathedral-runtime-capture-1600x900.png`: native OpenGL Compatibility에서 실제 Stage-local `8/16/32/64/128px` progression과 선택 C의 global14/128 표시를 확인한 runtime evidence.

## 최종 image-generation prompt 핵심

- A: warm gold-white, calm and near-symmetric edge-on disk; large empty black shadow; explicit upper/lower far-side lens images; physically grounded; no jets, stars, background, mechanical rings, or copied film composition.
- B: tilted Doppler-asymmetric disk; blue-white approaching left and dim red-gold receding right; empty black shadow; warped upper/lower lens echoes; no jets, nucleus, background, or decoration.
- C: enormous matte black shadow; horizontal disk; pale-gold and Galactic-violet wide lens arches; a few hairline photon layers; no literal cathedral, machinery, jets, stars, or one-sided crescent-only silhouette.

세 prompt 모두 `stylized-concept`, 실제 투명 square canvas, single isolated phenomenon, 128px reduction intent, pure/near-pure opaque featureless shadow, no text/UI/frame/watermark/logo를 명시했다.

## 의도적 제외 범위와 작업 경계

- A/B runtime 적용 없음. C의 actual `128px`만 global Lv14 initial visual/LOD에 적용했으며 master는 손실 없이 보존했다.
- 기존 Black Hole fallback, Quasar A, Event Horizon C, Galaxy/Cluster, FIRST CONTACT CUT-IN 이미지 수정·삭제 없음.
- `project.godot`, Ball/Stage catalog data, Scene, shader, Core/physics, 이동 Black Hole footprint, `STATUS.md` 수정 없음. Presentation LOD catalog·focused verifier·Presentation worklog만 승인 적용 범위로 갱신했다.
- 현재 branch `design/ground-snowflake-redesign`의 기존 dirty worktree를 정리하거나 덮어쓰지 않음. 작업 전 lane/Integration lock은 모두 없음이며 S8-G1~G5는 이미 `VERIFIED`; 상태는 갱신하지 않음.
- 기존 Godot Project Manager PID `64532`는 종료·조작하지 않았다. 실행 중인 게임이 없는 것을 확인한 뒤 검증용 CLI와 native capture를 한 번에 하나씩 실행했고 모두 정상 종료했다.
- git add/commit/push 없음.
- runtime 적용 변경은 선택된 C PNG/CanvasTexture, global14 exact-size LOD 참조, focused Presentation verifier, 이 README와 Presentation worklog에 한정한다.
