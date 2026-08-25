# Galactic Quasar Redesign v1

Snowball Effect의 Galactic Stage `Quasar` 인게임 공 디자인 후보 3종이다. 사용자의 최신 지시에 따라 기존 pixel design guideline을 의도적으로 적용하지 않았으며, **작아도 멋있고 매력적인 소용돌이치는 퀘이사**를 우선했다. 2026-08-24 사용자 승인으로 **A — POLAR BEACON**의 실제 크기 파일이 Galactic Quasar 런타임 LOD로 선택되었다. B/C와 모든 master/inspection 원본은 비교 후보로 이 폴더에 보존한다.

## 권위 데이터 매핑과 실제 크기

- [`scripts/data/ball_catalog.gd`](../../../../../scripts/data/ball_catalog.gd)는 index `12`에서 [`resources/balls/ball_12_quasar.tres`](../../../../../resources/balls/ball_12_quasar.tres)를 로드한다.
- BallDefinition: `global_level = 12`, `display_name = "Quasar"`, `visual_key = &"quasar"`, `score_value = 1.0e36`, `base_color = #E8E6FF`, `fx_tier = 3`.
- [`resources/stages/stage_02_galactic.tres`](../../../../../resources/stages/stage_02_galactic.tres)의 ordered chain은 `[10, 11, 12, 13, 14]`다. global Lv12의 index는 `2`, 즉 **Galactic local Lv2**다.
- [`scripts/simulation/ball_simulation_manager.gd`](../../../../../scripts/simulation/ball_simulation_manager.gd)의 runtime 공식은 `stage_base_ball_radius * 2^local_level`이며 base radius는 `4`다.
- Quasar runtime radius: `4 * 2^2 = 16`; runtime diameter: **`32 logical pixel`, 실제 출력 `32x32px`**.
- [`scripts/presentation/ball_texture_lod_catalog.gd`](../../../../../scripts/presentation/ball_texture_lod_catalog.gd)도 global Lv12의 exact-size LOD를 `32px`에만 연결한다.
- BallDefinition의 `radius = 8192`는 catalog/fallback seed이며 현재 Galactic runtime 크기의 source of truth가 아니다.

기존 [`ball_lv12_quasar_32.png`](../../../../../assets/sprites/balls/galactic/runtime/ball_lv12_quasar_32.png)는 크기·가독성 비교에만 사용했고 수정하지 않았다.

## 공통 디자인 계약

- 투명 배경의 단일 Quasar 오브젝트
- 밝은 중심핵 + 회전/강착 원반 + 서로 반대 방향의 제트 2개를 모두 유지
- 핵·원반·제트가 하나의 연결된 실루엣으로 읽히며 제트 끝은 캔버스에서 잘리지 않음
- 32px에서 큰 명암 덩어리와 색 분할을 우선하고, master의 미세 입자는 판독의 source로 사용하지 않음
- 원 안에 은하를 넣은 공, Saturn, Supernova, Event Horizon, Black Hole 형태를 피함
- 텍스트, UI, 프레임, 배경판, 별 배경, 워터마크, 드롭섀도 없음
- master는 비픽셀 고해상도 concept art이고, 32px 후보는 master의 alpha subject를 28px 안에 high-quality bicubic으로 맞춘 축소본이다. A의 32px 파일만 사용자 승인 후 런타임에 byte-identical 복사되었고 B/C는 미적용 후보다.

## 후보

### A — POLAR BEACON

백금색으로 폭발하는 핵을 중심으로 청록·보라 강착원반이 대각선으로 기울고, 원반의 극축을 따라 곧은 양방향 제트가 교차한다.

- 팔레트: platinum white, electric cyan, turquoise, deep violet, indigo
- 실루엣: 넓은 타원형 원반 + 명확한 X축 polar beam
- 장점: 중심핵·원반·제트의 분리가 가장 빠르고 32px에서 Quasar 해석이 가장 즉각적이다.
- 단점: 작은 크기에서는 원반과 제트가 중앙에서 조밀하게 겹쳐 세부 와류는 압축된다.
- 실제 32px: **PASS** — 백색 핵, 청보라 대각 원반, 서로 반대인 두 제트를 첫 시선에 분리할 수 있다.

### B — VIOLET MAELSTROM

자홍·보라색의 넓은 정면 와류가 핵으로 말려들고, 청백색 제트가 위아래로 약하게 비틀리며 빠져나간다.

- 팔레트: blue-white, hot magenta, fuchsia, saturated violet, ultraviolet blue
- 실루엣: 둥글고 넓은 whirlpool + 세로 S형 twin jet
- 장점: 세 후보 중 회전·소용돌이 운동감이 가장 강하고 A/C와 구도가 확실히 다르다.
- 단점: 32px에서 원반이 넓게 퍼져 제트의 직선성은 A보다 늦게 읽힌다.
- 실제 32px: **PASS** — 핵과 안쪽으로 감기는 와류, 위·아래 반대 제트가 유지된다. 세 요소의 즉시성은 A보다 한 단계 낮다.

### C — SOLAR LANCE

금백색 고온 핵 주위에 적색·코발트 난류 원반이 교차하고, 금빛과 청백색의 서로 다른 두 제트가 창처럼 반대 방향으로 뻗는다.

- 팔레트: gold-white, amber, scarlet, crimson, cobalt, blue-white
- 실루엣: 두꺼운 불규칙 원반 + 색이 갈리는 대각선 twin lance
- 장점: 열기와 에너지 압도가 가장 강하며 적/청 분할로 A/B와 확실히 구분된다.
- 단점: Galactic 계보 밖에서 단독으로 보면 에너지 창이나 압축된 폭발로 먼저 읽힐 가능성이 있어 원반 cue가 중요하다.
- 실제 32px: **PASS** — 금백 핵, 적/청 공전 띠, 금빛/청백 반대 제트가 남고 방사형 Supernova 실루엣은 피한다.

## 추천

사용자는 **A — POLAR BEACON**을 런타임 적용안으로 확정했다. 실제 32px에서 밝은 핵, 기울어진 강착원반, 곧은 양극 제트가 가장 짧은 시간에 분리되어 Quasar를 설명 없이 전달한다. B는 와류 운동감을 최우선할 때, C는 Galactic 후반의 에너지 압도를 최우선할 때 보존한 대안이다.

## Galactic 계보와의 구분

| 공 | 현재 실제 크기 | 기존 silhouette | Quasar 후보가 피한 요소 |
|---|---:|---|---|
| Galaxy | `8x8` | 따뜻한 단일 핵과 차가운 mini spiral | 제트가 없는 단일 나선 |
| Galaxy Cluster | `16x16` | 여러 핵과 분리된 compact galaxy 군집 | multi-core cluster, 작은 별무리 |
| Quasar | `32x32` | 밝은 핵 + 원반 + polar jet | 이 세 cue를 후보의 source of identity로 강화 |
| Event Horizon | `64x64` | 어두운 중심과 끊긴 보라 shell/ring | 검은 void, 감싸는 단일 암흑 링 |
| Black Hole | `128x128` | 큰 검은 중심과 segmented ring/cardinal burst | 지배적인 암흑 중심, 기계적 분절 링 |

Galaxy Cluster의 기존 runtime asset과 redesign draft는 모두 그대로 유지했다. Quasar는 여러 은하를 모은 cluster가 아니라 **하나의 극단적으로 밝은 활동은하핵**으로 읽히도록 단일 핵과 두 제트를 사용한다.

## 생성 및 축소

- Built-in image generation을 A/B/C마다 **독립 호출 1회** 사용했다. contact sheet를 생성하거나 잘라 쓰지 않았다.
- image-generation 재시도: A `0`, B `0`, C `0`.
- 세 master는 모두 `1254x1254`, `Format32bppArgb` PNG이며 genuine smooth alpha를 가진다.
- 생성기가 캔버스 edge에 남긴 alpha `1/255` 잔여만 alpha `0`/clear RGB로 정리했다. visible subject, 색, 핵, 원반, 제트, 구도는 변경하지 않았다.
- 각 32px는 alpha bbox의 종횡비를 보존해 최대 `28x28` 안에 high-quality bicubic으로 배치했다. 따라서 실제 검토 크기에서 최소 2px 투명 여백을 유지한다.
- 각 inspection은 대응 32px의 픽셀 하나를 정확히 `8x8` block으로 복제한 exact nearest-neighbor `256x256`다.

## 기술 검사

### Master

| 후보 | 규격 / Alpha | Nonzero alpha bbox | 투명 여백 L/T/R/B | Edge max alpha |
|---|---|---|---|---:|
| A | `1254x1254 RGBA`, `0..254` smooth | `108,33-1201,1219` | `108/33/52/34` | `0` |
| B | `1254x1254 RGBA`, `0..255` smooth | `186,26-1071,1236` | `186/26/182/17` | `0` |
| C | `1254x1254 RGBA`, `0..255` smooth | `63,49-1193,1207` | `63/49/60/46` | `0` |

세 master 모두 alpha bbox가 canvas 내부에 있고 네 edge alpha가 `0`이라 제트가 잘리지 않는다.

### 실제 32x32와 inspection

| 후보 | 32px bbox | 여백 L/T/R/B | Nonzero / opaque / partial alpha pixel | Edge | 256 nearest |
|---|---|---|---:|---:|---|
| A | `3,2-28,29` | `3/2/3/2` | `358 / 78 / 280` | `0` | `true` |
| B | `6,2-25,29` | `6/2/6/2` | `321 / 66 / 255` | `0` | `true` |
| C | `2,2-28,29` | `2/2/3/2` | `355 / 78 / 277` | `0` | `true` |

모든 master/32px/inspection은 유효한 32-bit RGBA PNG이고 실제 투명 pixel과 opaque/partial-alpha subject pixel을 함께 가진다. 정적 비교판은 검토용 dark UI가 의도된 opaque PNG다.

## 파일

| 구분 | A | B | C |
|---|---|---|---|
| master | `quasar-A-polar-beacon-master.png` | `quasar-B-violet-maelstrom-master.png` | `quasar-C-solar-lance-master.png` |
| actual `32x32` | `quasar-A-polar-beacon-32.png` | `quasar-B-violet-maelstrom-32.png` | `quasar-C-solar-lance-32.png` |
| inspection `256x256` | `quasar-A-polar-beacon-inspection-256.png` | `quasar-B-violet-maelstrom-inspection-256.png` | `quasar-C-solar-lance-inspection-256.png` |

- `comparison.html`: A/B/C의 master, actual 32px 중립/검은 배경, 256px nearest inspection 비교
- `comparison-render-1440x900.png`: local headless Chrome의 정적 비교판

## 적용 및 유지 범위

- A의 `quasar-A-polar-beacon-32.png`를 새 Galactic runtime PNG에 byte-identical 복사하고 nearest/repeat-disabled `CanvasTexture`로 감쌌다.
- Presentation LOD catalog의 `global Lv12 @ 32px`만 A resource로 전환했다.
- 기존 Galaxy Cluster, 기존 Quasar fallback PNG, Event Horizon, Black Hole runtime texture와 Galaxy Cluster redesign draft는 수정하지 않았다.
- Ball catalog, StageDefinition, simulation, 방향 보정 shader, Scene, `project.godot`는 수정하지 않았다.
- Goal/STATUS는 수정하지 않고 Presentation worklog에 실제 적용 및 검증 결과만 append한다.
- git add/commit/push는 수행하지 않는다.

## 최종 image-generation prompt set

세 prompt 모두 `stylized-concept`, transparent 32px gameplay master, no text/UI/background/watermark, bright nucleus + accretion disk + exactly two opposite jets, generous padding, no sphere/Saturn/Supernova/Event Horizon/Black Hole을 공통으로 사용했다.

<details>
<summary>A — POLAR BEACON prompt</summary>

```text
One isolated, instantly recognizable swirling quasar on a genuinely transparent square canvas: an explosively bright platinum-white compact nucleus; a clearly tilted, foreshortened cyan-and-violet accretion disk; and two straight razor-clear opposing relativistic polar jets. Polished high-resolution luminous cosmic plasma, deliberately not pixel art, with bold value masses that survive reduction to 32x32. Centered diagonal composition, generous transparent padding, both jet tips fully visible. No text, UI, frame, scenery, stars, watermark, sphere, Saturn, planet, supernova, Event Horizon, Black Hole, black void, checkerboard, cropped jets, or detached objects.
```

</details>

<details>
<summary>B — VIOLET MAELSTROM prompt</summary>

```text
One isolated quasar on a genuinely transparent square canvas: a brilliant blue-white compact nucleus; a face-forward, slightly tilted magenta-and-violet accretion vortex curling inward in broad hooked spiral bands; and two opposing blue-white polar jets with a subtle mirrored corkscrew. Polished high-resolution luminous cosmic plasma, deliberately not pixel art, with a hypnotic clockwise whirlpool and large readable value groups for 32x32 reduction. Generous transparent padding and fully visible tips. No text, UI, frame, scenery, stars, watermark, sphere, Saturn, planet, supernova, Event Horizon, Black Hole, black void, checkerboard, cropped jets, simple pinwheel, or detached objects.
```

</details>

<details>
<summary>C — SOLAR LANCE prompt</summary>

```text
One isolated high-temperature quasar on a genuinely transparent square canvas: a searing gold-white compact nucleus; a turbulent broken-edged accretion disk with interleaved scarlet-red and deep cobalt streams; and two exceptionally strong opposite polar jets, one golden-white and one blue-white, like tapered lances. Polished high-resolution luminous cosmic plasma, deliberately not pixel art, with bold compact shapes for 32x32 reduction. Generous transparent padding and fully visible tips. No text, UI, frame, scenery, stars, watermark, sphere, Saturn, round sun, radial supernova, Event Horizon, Black Hole, black void, checkerboard, cropped jets, or detached objects.
```

</details>
