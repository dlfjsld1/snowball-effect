# Galactic Galaxy Cluster Redesign v1

Snowball Effect의 Galactic Stage `Galaxy Cluster`를 위한 인게임 공 디자인 후보 3종이다. 이 폴더는 **concept-only draft**이며 런타임, Script, Resource, Scene, Goal/STATUS, worklog를 변경하지 않는다.

## 확정 런타임 계약

- Galactic ordered chain: `[10, 11, 12, 13, 14]`
- Galaxy Cluster: **global Lv11 / Galactic local Lv1**
- Authoritative `StageDefinition`: `resources/stages/stage_02_galactic.tres`
  - `local_ball_levels = PackedInt32Array(10, 11, 12, 13, 14)`
  - global Lv11의 local index는 `1`
- Authoritative `BallDefinition`: `resources/balls/ball_11_supercluster.tres`
  - `global_level = 11`
  - `display_name = "Galaxy Cluster"`
  - `visual_key = &"galaxy_cluster"`
  - `score_value = 1.0e30`
  - `base_color = #805CFF`
- Runtime radius: `4 * 2^local_level = 4 * 2^1 = 8`
- Runtime diameter: `16 logical pixel`, 즉 실제 출력 **`16x16px`**
- `BallDefinition.radius = 4096`은 catalog/fallback seed이며 Stage runtime 크기의 source of truth가 아니다. renderer와 collision은 local index에서 계산한 radius `8`을 함께 사용한다.

수정 금지 대상으로 지정된 아래 사용자 에셋은 참조만 했고 바꾸지 않았다.

- `assets/sprites/balls/galactic/runtime/ball_galactic_local_lv00_galaxy_user_authored_8.png`
- `assets/sprites/balls/planetary/runtime/ball_planetary_local_lv04_galaxy_user_authored_128.png`

## 공통 디자인 계약

- 투명 배경의 단일 중심 Galaxy Cluster 오브젝트
- Galaxy 다음 단계임이 보이도록 8px Galaxy보다 큰 16px 면적과 여러 핵을 사용
- 최소 3개의 분리된 은하 핵과 mini spiral cue를 실제 16x16에서 유지
- 개별 은하는 dark gap으로 구분하되 shared arm, gas, star bridge로 한 cluster 실루엣을 형성
- 원형 공 안에 그림을 넣지 않고 은하·팔·가스 자체가 외곽선을 형성
- 단일 Galaxy, Supernova, Black Hole, 단순 별무리, 마법 구슬, 행성으로 보이는 형태를 배제
- 텍스트, 프레임, 체커보드, 배경판, 드롭섀도, 분리된 보조 오브젝트 없음
- 사용자의 최신 지시에 따라 저장소의 pixel design guideline은 적용하지 않음. 단, 실제 16px 판독을 위한 native-grid 최소 보정만 수행

## 후보

### A — Triad Cluster

금빛/백색 핵을 가진 청보라 mini spiral 3개가 안정적인 삼각형을 만들고, 옅은 별다리와 공유 가스가 세 은하를 하나의 3엽 silhouette로 묶는다.

- 팔레트: `#101536`, `#2947B8`, `#8157E6`, `#61DDF5`, `#B98BEA`, `#F1C45F`, `#FFF6D2`
- 형태: 3개의 비슷한 무게 중심, triangular gravity bridge, 열린 삼엽 외곽선
- 장점: “여러 은하가 모인 은하단”을 가장 직접적으로 설명하며 단일 Galaxy·구슬 오인 위험이 가장 낮음
- 단점: 개체 수와 과밀한 규모감은 B/C보다 절제됨
- 실제 16px: **PASS** — 분리 핵/mini spiral `3`, warm core와 cool arm이 중립 배경과 `#02040C` 양쪽에서 구분됨

### B — Spiral Swarm Crown

큰 시안 중심 은하 1개 주위에 보라/백색 위성 은하 4개가 밀집하고, 겹친 팔과 냉색 haze가 하나의 globular crown을 만든다.

- 팔레트: `#111638`, `#29399A`, `#7248C8`, `#BC83F1`, `#24D2ED`, `#BDF9FF`, `#F9FFFF`
- 형태: central spiral 1 + satellite spiral 4, dense crown/rosette
- 장점: 5개 핵으로 가장 많은 개체감과 Galactic 규모 상승을 보여 줌
- 단점: 실제 16px에서 가장 조밀해 긴 팔 세부는 짧은 mini arc로 압축됨
- 실제 16px: **PASS** — 분리 핵/mini spiral `5`, 중앙 시안 핵과 네 외곽 핵이 두 검사 배경에서 유지됨

### C — Colliding Web

역회전하는 청록/자홍 주 은하 2개와 위성 은하 3개가 교차 tidal bridge와 갈라지는 filament로 연결된 비대칭 웹이다.

- 팔레트: `#10152F`, `#1D4B91`, `#1598A9`, `#42E2E5`, `#8349C8`, `#ED4DB5`, `#FFC1E8`, `#FFF7E3`
- 형태: opposing main spirals 2 + hooked satellites 3, diagonal teal/magenta web
- 장점: 색 분할과 운동감이 가장 강해 정적인 단일 Galaxy와 확실히 다름
- 단점: 두 주 은하가 강해 첫눈에는 galaxy collision으로 보일 수 있으나 위성 3핵과 연결 web이 cluster 해석을 보강함
- 실제 16px: **PASS** — 분리 핵/mini spiral `5`, 두 주 회전축과 세 위성 핵이 양쪽 배경에서 남음

## 추천

첫 런타임 trial에는 **A — Triad Cluster**를 추천한다. 16px에서 정확히 세 개의 warm nucleus와 세 개의 cool spiral lobe가 가장 빨리 분리되고, 별다리가 한 오브젝트로 묶어 주어 Galaxy Cluster 요구를 설명 없이 전달한다. B는 규모감을 최대화할 때 좋은 2순위이고, C는 가장 멋진 운동감을 주지만 “충돌 중인 두 은하”가 먼저 읽힐 가능성이 있다.

## master 생성

- Built-in image generation을 A/B/C마다 독립 호출했다. 정확한 prompt는 [`prompts.md`](prompts.md)에 기록했다.
- 세 호출 모두 첫 시도에 형태와 genuine RGBA alpha를 생성했다.
- image-generation 실패: `0`
- image-generation 수정/재호출: A `0`, B `0`, C `0`
- 모든 최종 master는 `1254x1254`, `Format32bppArgb` PNG다.
- 생성 도구가 canvas edge에 남긴 alpha `1` 잔여를 결정적 후처리로 alpha `0`으로 정리했다. alpha `<=1`을 제거하고 가장 큰 8-neighbor subject만 유지했으며, visible RGB·핵·팔·배치·silhouette는 변경하지 않았다.

## 16x16 제작

master를 단순 축소하면 여러 핵과 arm cue가 합쳐지므로 자동 축소본을 최종 후보로 사용하지 않았다. 대신 master의 핵 수, 핵 배치, 회전 방향, 주 팔레트와 연결 bridge를 [`build-runtime-candidates.ps1`](build-runtime-candidates.ps1)의 native 16x16 grid로 결정적으로 옮겼다.

- A: master의 삼각형 3핵과 각 lobe의 짧은 회전 arm을 3개의 gold/white core로 보존
- B: master의 중앙 1핵+주변 4핵 crown을 5개의 white core와 cyan/violet arc로 보존
- C: master의 teal/magenta 주 회전 2개+위성 3개를 5개의 white core와 교차 bridge로 보존
- alpha는 실제 16px에서 `0/255`만 사용
- 모든 opaque pixel은 더 엄격한 4-neighbor와 8-neighbor 양쪽에서 정확히 하나의 connected cluster를 형성

각 inspection PNG는 대응 16x16의 한 픽셀을 정확히 `16x16` block으로 복제한 **정확한 nearest-neighbor 256x256**다. [`validation.json`](validation.json)의 `nearest_16x_check`는 세 후보 모두 `true`다.

## 기술 검사

### master

| 후보 | 규격 | Alpha | Nonzero bounds | 투명 여백 L/T/R/B | Edge max alpha | Transparent RGB | Components |
|---|---|---|---|---|---:|---:|---:|
| A | `1254x1254 RGBA` | `0..255` smooth | `40,39-1227,1215` | `40/39/26/38` | `0` | `0` | `1` |
| B | `1254x1254 RGBA` | `0..254` smooth | `97,59-1173,1191` | `97/59/80/62` | `0` | `0` | `1` |
| C | `1254x1254 RGBA` | `0..255` smooth | `27,48-1224,1205` | `27/48/29/48` | `0` | `0` | `1` |

세 master 모두 네 모서리와 모든 canvas edge의 alpha가 `0`이며, visible subject는 8-neighbor 기준 한 component다. nonzero bounds가 canvas 안에 있어 clipping이 없다.

### 실제 16x16 후보

| 후보 | Alpha | Bounds / margin L/T/R/B | Opaque pixels | Colors | 분리 핵/mini spiral | Components 4/8 | Edge | 256 nearest |
|---|---|---|---:|---:|---:|---:|---:|---|
| A | `0/255` | `2,1-14,14` / `2/1/1/1` | `96` | `7` | `3` | `1/1` | `0` | `true` |
| B | `0/255` | `2,2-14,14` / `2/2/1/1` | `96` | `7` | `5` | `1/1` | `0` | `true` |
| C | `0/255` | `2,2-14,14` / `2/2/1/1` | `101` | `8` | `5` | `1/1` | `0` | `true` |

각 후보는 실제 `16x16` 1:1 크기를 투명 중립 surface와 Galactic dark `#02040C` 위에서 검사했다. 세 후보 모두 핵 수, multi-galaxy cue, connectedness를 유지하고 single Galaxy, Supernova, Black Hole, 단순 별무리, 마법 구슬 형태를 피한다.

## 비교판

- [`comparison.html`](comparison.html): master, actual 16px 중립/`#02040C` 검사, inspection 256, 팔레트, 형태, 장단점, 판독 결과
- [`comparison-render-1440x900.png`](comparison-render-1440x900.png): local Chrome headless `1440x900`, device scale `1` 렌더. 세 카드와 actual 16px 두 배경이 스크롤 없이 한 화면에 표시됨

## 파일

| 구분 | 파일 |
|---|---|
| A master | `master-a-triad-cluster.png` |
| A actual 16 | `candidate-a-triad-cluster-16.png` |
| A inspection 256 | `inspection-a-triad-cluster-256.png` |
| B master | `master-b-spiral-swarm-crown.png` |
| B actual 16 | `candidate-b-spiral-swarm-crown-16.png` |
| B inspection 256 | `inspection-b-spiral-swarm-crown-256.png` |
| C master | `master-c-colliding-web.png` |
| C actual 16 | `candidate-c-colliding-web-16.png` |
| C inspection 256 | `inspection-c-colliding-web-256.png` |
| 비교 HTML | `comparison.html` |
| 비교 렌더 | `comparison-render-1440x900.png` |
| prompt 기록 | `prompts.md` |
| 16px deterministic builder | `build-runtime-candidates.ps1` |
| alpha/edge/component validator | `validate-assets.ps1` |
| machine-readable 검사 결과 | `validation.json` |

## 비적용·보존 범위

- Galactic Galaxy global Lv10/local Lv0 8px 수정 없음
- Planetary Galaxy global Lv10/local Lv4 128px 수정 없음
- 기존 Galactic Galaxy Cluster runtime texture 교체 없음
- 기존 mockup과 dirty worktree 파일 변경 없음
- Script, Resource, Scene, `project.godot` 변경 없음
- Goal/STATUS/worklog 변경 없음
- runtime 적용 없음
- commit, push, stage 없음
