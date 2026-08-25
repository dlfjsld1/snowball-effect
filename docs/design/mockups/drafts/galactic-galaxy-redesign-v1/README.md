# Galactic Galaxy Redesign v1

Snowball Effect의 Galactic Stage 기본 공 `Galaxy`를 위한 디자인 후보 3종이다. 이 폴더는 concept-only draft이며 런타임, Resource, Goal/STATUS, worklog를 변경하지 않는다.

## 확정 런타임 계약

- Galactic ordered chain: `[10, 11, 12, 13, 14]`
- Galaxy: global Lv10 / Galactic local Lv0
- Authoritative runtime radius: `4 * 2^0 = 4`
- Authoritative runtime diameter: `8 logical pixel`, 즉 실제 출력 `8x8px`
- 크기 source of truth: 현재 `StageDefinition.local_ball_levels`의 local index. `BallDefinition.radius`와 master source 크기는 런타임 크기의 source of truth가 아니다.
- 같은 global Lv10 Galaxy라도 Planetary에서는 local Lv4 / radius 64 / diameter 128이다.
- 기존 사용자 에셋 `assets/sprites/balls/planetary/runtime/ball_planetary_local_lv04_galaxy_user_authored_128.png`은 참조만 했고 수정하지 않았다.
- 사용자의 명시적 지시에 따라 pixel design guideline은 적용하지 않았다. 단, 실제 8x8 판독을 위한 최소 픽셀 정리만 수행했다.

## 공통 디자인 계약

- 투명 배경의 단일 중심 Galaxy 오브젝트
- 나선팔과 별무리 자체가 외곽 실루엣을 형성
- 둥근 공, 유리 구슬, 원형 컨테이너, 배경판 없음
- Black Hole, Supernova, 행성, 한 점짜리 빛, 마법 구슬로 읽히지 않음
- 텍스트, 프레임, 체커보드, 드롭섀도, 보조 오브젝트 없음
- 모든 8x8은 1px 투명 외곽 여백, 투명 모서리, edge alpha 0, 8-neighbor 기준 단일 connected component를 가짐

## 후보

### A - Golden-Core Mini Spiral

금빛 2px 핵과 청색·보라 2-arm S형 나선이다. Planetary 128px 사용자 Galaxy의 따뜻한 핵, 차가운 팔, 회전 방향을 가장 충실하게 압축했다.

- 색상: ivory, gold, violet, cyan, cobalt
- 형태: 열린 2-arm mini spiral, 18 non-transparent pixels
- 장점: 기존 Galaxy identity와 가장 일관되고 금빛 핵과 팔 구분이 가장 빠름
- 단점: B보다 회전량이 작고 가장 정석적이라 새로움은 낮음
- 8px 판독: `PASS`, 중립 배경과 Galactic dark `#02040C` 모두 핵과 두 팔이 분리됨

### B - Sapphire Pinwheel

백색 2x2 핵에서 시안·사파이어 4개 팔이 네 사분면으로 굽는다. 가장 강한 고대비 회전 실루엣이다.

- 색상: white, cyan, electric sapphire, deep cobalt
- 형태: 4-arm pinwheel, 22 non-transparent pixels
- 장점: 세 후보 중 실제 8px에서 회전과 방향성이 가장 강함
- 단점: 너무 기호화하면 pinwheel/rotor처럼 읽힐 위험이 있어 Galaxy star-arm 문맥이 필요함
- 8px 판독: `PASS`, 밝은 핵과 네 팔이 양쪽 배경에서 유지됨

### C - Violet Twin Tail

밝은 중심에서 보라·남색 쌍꼬리가 비대칭으로 뻗고 우측 cobalt dust arc가 감싼다. 가장 움직임과 개성이 강한 후보다.

- 색상: ivory, pale violet, purple, midnight navy, cobalt, cyan
- 형태: asymmetric twin tail + reconnected dust arc, 18 non-transparent pixels
- 장점: 작은 크기에서도 방향성과 개성이 강하고 A/B와 실루엣이 확실히 다름
- 단점: 비대칭이 강해 정면 나선은 A보다 늦게 읽힘
- 8px 판독: `PASS`, 쌍꼬리와 우측 dust arc가 Galactic dark에서도 분리됨

## 추천

첫 런타임 trial에는 **A - Golden-Core Mini Spiral**을 추천한다. 기존 Planetary 128px 사용자 Galaxy와의 identity continuity가 가장 높고, 8px에서 금빛 핵과 청보라 두 팔이 최소 정보만으로 Galaxy를 즉시 설명한다. 순수한 8px 회전 대비가 우선이면 B가 두 번째 선택이다.

## 파일

| 후보 | RGBA master | 실제 runtime candidate | 32x nearest inspection |
|---|---|---|---|
| A | `master-a-golden-core-mini-spiral.png` | `candidate-a-golden-core-mini-spiral-8.png` | `inspection-a-golden-core-mini-spiral-256.png` |
| B | `master-b-sapphire-pinwheel.png` | `candidate-b-sapphire-pinwheel-8.png` | `inspection-b-sapphire-pinwheel-256.png` |
| C | `master-c-violet-twin-tail.png` | `candidate-c-violet-twin-tail-8.png` | `inspection-c-violet-twin-tail-256.png` |

한 화면 비교: `comparison.html`

1440x900 실제 Chromium 렌더 증거: `comparison-render-1440x900.png`

## 생성 결과

- Built-in image generation을 A/B/C 각각 독립 호출했다. 세 호출 모두 Planetary 128px 사용자 Galaxy를 identity reference로만 사용했고, 후보끼리는 서로를 참조하지 않았다.
- A: 최초 master 생성 성공. 원본부터 genuine RGBA alpha였고 image-generation 수정 호출은 없었다. 최초 14픽셀 runtime draft는 너무 가늘어 판독 검사 뒤 8px grid 수정 1회를 사용했다.
- B: 형태 생성 성공. 최초 결과가 opaque checkerboard였고 후보별 허용된 1회 background-extraction 수정도 alpha 생성에 실패했다.
- C: 형태 생성 성공. 최초 결과가 opaque checkerboard였고 후보별 허용된 1회 background-extraction 수정도 alpha 생성에 실패했다.
- B/C는 디자인을 다시 생성하지 않고 edge-connected neutral checkerboard만 deterministic flood-fill로 제거했다. 주제의 색, 형태, 배치, 회전 방향은 유지했다.
- 세 master 모두 작은 detached alpha speck만 제거해 최종 alpha subject를 정확히 한 connected component로 정리했다.
- 8x8은 master의 핵, 팔 수, 팔레트, 회전 방향을 직접 native grid에 옮겼다. 자동 축소 결과는 사용하지 않았다.

## 기술 검사

### Master

| 후보 | 규격 | Alpha | Nonzero bounds | 투명 여백 L/T/R/B | Edge max alpha | Components |
|---|---|---|---|---|---:|---:|
| A | `1254x1254`, `Format32bppArgb` | `0..254` smooth | `128,14-1157,1171` | `128/14/96/82` | `0` | `1` |
| B | `1254x1254`, `Format32bppArgb` | `0/255` binary | `80,70-1172,1189` | `80/70/81/64` | `0` | `1` |
| C | `1254x1254`, `Format32bppArgb` | `0/255` binary | `124,78-1159,1188` | `124/78/94/65` | `0` | `1` |

모든 master의 네 모서리와 canvas edge는 alpha 0이며, 완전 투명 픽셀의 RGB는 `0,0,0`이다. 따라서 matte fringe와 edge clipping이 없다.

### 8x8 runtime candidates

| 후보 | 규격 | Alpha | Bounds / margin | Opaque pixels | Opaque colors | Components | Edge |
|---|---|---|---:|---:|---:|---:|
| A | `8x8 RGBA` | `0/255` | `1,1-6,6` / `1px` | `18` | `5` | `1` | `0` |
| B | `8x8 RGBA` | `0/255` | `1,1-6,6` / `1px` | `22` | `4` | `1` | `0` |
| C | `8x8 RGBA` | `0/255` | `1,1-6,6` / `1px` | `18` | `7` | `1` | `0` |

각 256px inspection은 대응 8x8의 각 픽셀을 정확히 `32x32` block으로 복제했다. 세 파일 모두 nearest-neighbor equality 검사 `true`, 32px 투명 여백, edge alpha 0, connected component 1이다.

## 판독 검사

`comparison.html`은 각 실제 8x8을 1:1 크기로 중립 surface와 Galactic dark `#02040C` 위에 각각 표시하고, 같은 카드에서 256px nearest inspection과 master를 함께 보여준다.

모든 `src` 경로의 실제 파일 존재를 검사했고, local Chrome headless `1440x900`에서 스크롤 없이 세 카드가 한 화면에 표시되는 것을 `comparison-render-1440x900.png`로 확인했다.

- A: 첫 14픽셀 버전은 팔이 너무 가늘어 8px correction을 한 번 사용했다. 최종 18픽셀 버전에서 warm core와 cool 2-arm separation을 확인했고 Galaxy identity가 가장 빠르다.
- B: white core와 네 quadrant arm 확인. 회전 실루엣이 가장 강함.
- C: bright center, unequal twin tail, right dust arc 확인. 가장 개성 있지만 A보다 해석 시간이 조금 김.
- 세 후보 모두 transparent corner, no edge contact, no enclosing circle, no isolated one-dot subject, no planet/supernova/black-hole silhouette를 확인했다.

## 비적용 범위

- Galactic runtime texture 교체 없음
- Planetary 128px 사용자 Galaxy 수정 없음
- Script, Resource, Scene, `project.godot` 수정 없음
- Goal/STATUS/worklog 수정 없음
- commit, push, stage 없음
