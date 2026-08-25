# Galactic Event Horizon Redesign v1

Snowball Effect의 Galactic Stage `Event Horizon` 인게임 공 후보 3종이다. 세 후보는 빛과 공간이 끝나는 경계 너머의 **절대적 부재**를 표현한다. 2026-08-24 사용자 승인으로 **C — LAST LIGHT**의 실제 64px 파일이 runtime 적용안으로 확정되었고, A/B와 모든 master/inspection은 비교 후보로 보존한다.

## 권위 매핑과 실제 크기

- `resources/balls/ball_13_event_horizon.tres`: `global_level = 13`, `display_name = "Event Horizon"`, `visual_key = &"event_horizon"`.
- `resources/stages/stage_02_galactic.tres`: Galactic ordered chain은 `[10, 11, 12, 13, 14]`이고 global Lv13의 index는 `3`, 즉 **Galactic local Lv3**다.
- `scripts/simulation/ball_simulation_manager.gd`: `stage_base_ball_radius = 4.0`, runtime 공식은 `stage_base_ball_radius * 2^local_level`이다.
- 따라서 runtime radius는 `4 × 2^3 = 32`, authoritative diameter는 **`64 logical pixel`, 실제 출력 `64×64px`**다.
- `scripts/presentation/ball_texture_lod_catalog.gd`는 global Lv13의 exact-size `64px` LOD를 승인된 `ball_galactic_local_lv03_event_horizon_last_light_64.tres`에 매핑한다. 기존 `ball_lv13_event_horizon_64.png`는 fallback/reference asset으로 삭제하지 않았다.
- BallDefinition의 `radius = 16384`는 catalog/fallback seed이며 Galactic runtime 크기의 source of truth가 아니다.

## 기존 Galactic 체인 조사와 중복 회피

현재 실제 체인은 다음과 같이 읽힌다.

| Global / local | 현재 런타임 에셋 | 핵심 silhouette | 이번 후보가 피한 요소 |
|---|---|---|---|
| Galaxy `10 / 0` | `ball_galactic_local_lv00_galaxy_user_authored_8.png` | 따뜻한 핵을 감싼 작은 청보라 나선 | 별이 있는 나선, 밝은 중심핵 |
| Galaxy Cluster `11 / 1` | `ball_lv11_galaxy_cluster_16.png` | 여러 밝은 핵이 흩어진 군집 | 다중 핵, 작은 은하 군집 |
| Quasar `12 / 2` | 방금 적용된 A `ball_galactic_local_lv02_quasar_polar_beacon_32.png` | 기울어진 원반과 강한 양극 제트 | 제트, 십자형 에너지, 밝은 핵 |
| Event Horizon `13 / 3` | C `ball_galactic_local_lv03_event_horizon_last_light_64.tres` | 한쪽 금백 crescent와 희미한 반대편 echo | 기존의 두꺼운 shell/구체 표면 표현 |
| Black Hole `14 / 4` | `ball_lv14_black_hole_128.png` | 거대한 검은 중심, 완성형 분절 링, cardinal burst | 두꺼운 거대 링, 기계적 분절, 네 방향 flare |

최근 Galaxy, Galaxy Cluster, Quasar 비교 목업과 FIRST CONTACT Event Horizon/Black Hole portrait도 함께 확인했다. 이번 세 후보는 공허 내부에 은하·별·균열·밝은 핵을 넣지 않고, Black Hole의 완성형 128px 링과 분절 구조를 선점하지 않는다.

## 후보

### A — VOID APERTURE

완전한 무광 검정 원형 공허를 면도날처럼 얇은 청백색 photon ring이 감싸며, 바깥의 푸른 빛이 경계 직전에서 끊긴다.

- 색: absolute black, ice white, pale cyan, cold cobalt
- 실루엣: 가장 정확하고 대칭적인 원형 aperture
- 장점: 세 후보 중 64px 위치·충돌 범위가 가장 즉시 읽히고, 중심 16×16은 완전한 `0` luminance다.
- 단점: 완전한 원형 링이라 단독으로 보면 축소된 Black Hole처럼 읽힐 위험이 있으나, 실제 Black Hole의 두꺼운 분절 링·cardinal burst와는 위계가 분리된다.
- 실제 크기: **PASS** — 2px 여백, 얇은 백색 경계와 푸른 외곽 band가 유지되고 공허는 캔버스의 `43.58%`를 차지한다.

### B — GRAVITY WOUND

기울어진 타원형 공허 주위에서 보라·청록 렌즈광이 안쪽으로 휘다가 갑자기 소실되어 현실이 찢긴 듯한 중력 상처를 만든다.

- 색: absolute black, ultraviolet violet, spectral teal, restrained blue-white
- 실루엣: 비대칭 tilted ellipse + irregular wound envelope
- 장점: 가장 불길하고 초현실적이며 A/C, Quasar의 직선 제트, Black Hole의 대칭 기계 링과 확실히 다르다.
- 단점: 외곽 왜곡이 가장 풍부해 64px에서 portal/maelstrom으로 먼저 읽힐 수 있고, 세 후보 중 공허 면적이 가장 작다.
- 실제 크기: **PASS** — 공허 `756px`(`18.46%`)를 유지하고 중앙 16×16 luminance는 최대 `8.653/255`, 표준편차 `1.145`로 시각적 내부 detail이 없다. 보라/청록 경계 cue도 분리된다.

### C — LAST LIGHT

화면 대부분을 차지하는 무광 공허의 오른쪽에만 금백색 마지막 crescent가 남고, 반대편에는 극히 희미한 청색 lensing echo만 존재한다.

- 색: absolute black, midnight navy, ivory gold, faint steel blue
- 실루엣: 비대칭 단일 crescent + 불완전한 반대편 echo
- 장점: “빛이 사라지는 마지막 순간”과 절대적 부재를 가장 절제되고 압도적으로 전달하며 Black Hole의 완성형 링을 선점하지 않는다.
- 단점: 매우 어두운 화면에서는 왼쪽 echo가 가장 먼저 사라질 수 있으나, 오른쪽 crescent가 64px collision-readable envelope를 유지한다.
- 실제 크기: **PASS** — 공허 `1920px`(`46.88%`)로 가장 넓고 중심 16×16은 완전한 `0` luminance다. 금백 crescent와 냉색 echo가 모두 남는다.

## 추천

사용자는 **C — LAST LIGHT**를 최종 선택해 런타임 적용을 승인했다. 세 후보 중 “저 너머에는 정말 아무것도 없다”는 목표를 가장 직접적으로 전달하고, Quasar의 양극 에너지와 Black Hole의 완성형 거대 링 양쪽에서 가장 멀리 떨어져 있다. A/B는 미적용 비교안으로 남긴다.

## 런타임 적용

- 승인 source: `event-horizon-C-last-light-64.png`
- runtime PNG: `assets/sprites/balls/galactic/runtime/ball_galactic_local_lv03_event_horizon_last_light_64.png`
- runtime resource: `assets/sprites/balls/galactic/runtime/ball_galactic_local_lv03_event_horizon_last_light_64.tres`
- source/runtime SHA-256: `A44FE630208D653AAF53BB4346896B5C325E09BBAA6AD9FC5FFA052E535793CD`
- 두 PNG는 byte-identical이며 디코딩·재인코딩·리사이즈·보정 없이 복사했다.
- dedicated `CanvasTexture`는 nearest filtering과 repeat disabled를 사용한다. authoritative gameplay radius/diameter `32/64`와 collision은 바꾸지 않는다.
- 기존 `ball_lv13_event_horizon_64.png`와 FIRST CONTACT portrait는 보존하며, 비교판은 선택 전 세 후보 비교 증거로 유지한다.
- `event-horizon-C-last-light-runtime-capture-1600x900.png`는 Godot native renderer가 Galactic의 실제 `8/16/32/64/128px` 체인에서 C를 global Lv13 `64px`로 그린 적용 후 증거다. 검은 중심, 우측 금백 crescent, 좌측 청남색 echo가 실제 크기에서 분리되어 보인다.

## 생성·축소 방식

- Built-in image generation을 A/B/C에 각각 **독립 호출 1회** 사용했다. contact sheet를 만들거나 잘라 쓰지 않았고 재시도는 A/B/C 모두 `0`회다.
- 세 master는 `1254×1254 RGBA`이며 genuine smooth alpha를 가진다.
- 생성기가 A/B edge에 남긴 `alpha = 1/255` 잔여와 1~25px 규모의 분리 speck만 결정적으로 투명 처리했다. 중심 공허, 경계 빛, 구도, 색, 실루엣은 변경하지 않았다.
- 각 master의 정리된 alpha bbox 전체를 비율 유지 Lanczos로 `60×60` 안에 맞추고 `64×64` 투명 캔버스 중앙에 배치했다. 따라서 모든 실제 후보는 최소 2px 여백과 `edge alpha = 0`을 가진다.
- 각 inspection은 대응 `64×64` 파일을 nearest-neighbor로 정확히 4배 확대한 `256×256`이다.
- 사용자의 지시에 따라 pixel design guideline은 의도적으로 적용하지 않았다. 실제 64px 판독성과 alpha 안전성만 검증했다.

## 검증 결과

### Master

| 후보 | 규격 | alpha bbox | 여백 L/T/R/B | edge alpha | alpha>8 components |
|---|---|---|---|---:|---:|
| A | `1254×1254 RGBA` | `126,109–1130,1119` | `126/109/124/135` | `0` | `1` |
| B | `1254×1254 RGBA` | `66,71–1192,1181` | `66/71/62/73` | `0` | `1` |
| C | `1254×1254 RGBA` | `201,178–1055,1046` | `201/178/199/208` | `0` | `1` |

### Actual 64×64 / inspection 256×256

| 후보 | actual bbox | 여백 L/T/R/B | 투명 pixel | 공허 pixel / 비율 | 밝은 경계 pixel | 4× nearest | edge alpha |
|---|---|---|---:|---:|---:|---|---:|
| A | `2,2–62,62` | `2/2/2/2` | `1305` | `1785 / 43.58%` | `334` | `PASS` | `0` |
| B | `2,2–62,61` | `2/2/2/3` | `1533` | `756 / 18.46%` | `484` | `PASS` | `0` |
| C | `2,2–61,62` | `2/2/3/2` | `1176` | `1920 / 46.88%` | `247` | `PASS` | `0` |

모든 master/actual/inspection은 유효 PNG, `RGBA`, 실제 투명 pixel 포함, canvas edge alpha `0`이다. 실제 후보는 모두 alpha>8 기준 단일 connected component이며 중심 공허 면적·내부 무상세·외곽 cue 자동 검사를 통과했다. 상세 수치는 `validation.json`에 있다. `comparison-render-1440x900.png`는 검토 UI를 렌더한 의도적 opaque 비교판이다.

## 파일

| 구분 | A | B | C |
|---|---|---|---|
| master | `event-horizon-A-void-aperture-master.png` | `event-horizon-B-gravity-wound-master.png` | `event-horizon-C-last-light-master.png` |
| actual `64×64` | `event-horizon-A-void-aperture-64.png` | `event-horizon-B-gravity-wound-64.png` | `event-horizon-C-last-light-64.png` |
| inspection `256×256` | `event-horizon-A-void-aperture-inspection-256.png` | `event-horizon-B-gravity-wound-inspection-256.png` | `event-horizon-C-last-light-inspection-256.png` |

- `comparison.html`: master, actual 밝은/어두운 중립 배경, 4× inspection, 기존 Galactic 진행 체인 참고 실루엣.
- `comparison-render-1440x900.png`: local headless Chrome의 정적 비교판.
- `event-horizon-C-last-light-runtime-capture-1600x900.png`: Godot native renderer의 적용 후 Galactic 체인 캡처.
- `build_and_validate.py`, `validation.json`: 결정적 축소·검증 도구와 결과.

## 의도적 제외 범위

- A/B 후보의 runtime 적용 없음; 기존 Event Horizon fallback asset 삭제 없음
- Ball catalog, BallDefinition, StageDefinition, Scene, shader, `project.godot` 변경 없음; Presentation LOD Script와 C 전용 CanvasTexture Resource만 runtime 연결에 사용
- Goal/STATUS 수정 없음; Presentation worklog만 적용 증거를 append
- 기존 Galaxy, Galaxy Cluster, Quasar A, Event Horizon fallback, Black Hole 에셋과 최근 mockup 수정 없음
- 기존 Godot DEBUG 프로세스는 없었으며 Project Manager는 종료하지 않음; 검증용 headless/native Godot 프로세스만 실행 후 정상 종료
- git add/commit/push 없음

## 최종 image-generation prompt 요약

- A: absolute-black circular void + razor-thin exact icy photon ring; cold, minimal, no interior detail, no jets, no final Black Hole segmentation.
- B: tilted asymmetric gravity wound + violet/teal lensing that bends inward then vanishes; featureless void, no complete ring, no portal background.
- C: dominant absolute-black void + one gold-white last-light crescent + faint cool opposite echo; incomplete ring, no nucleus, no multiple flares.

세 prompt 모두 `stylized-concept`, genuinely transparent square canvas, one isolated object, generous padding, 64px reduction intent, no text/UI/frame/watermark/background/checkerboard, no stars/galaxies/eyes/face/core texture, no Quasar jets, no Supernova explosion을 명시했다.
