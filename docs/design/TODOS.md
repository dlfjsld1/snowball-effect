# Design Follow-up TODOs

이 문서는 승인된 v1 범위 밖이지만 설계 맥락을 잃으면 안 되는 후속 작업을 기록한다. 실제 Goal 상태는 `docs/goals/STATUS.md`에서만 관리한다.

## Reduced Effects

Status: DEFERRED — not in v1  
Candidate owner: Presentation + Content/Systems  
Depends on: S6-G1 event tier/cap approval, shared Settings adapter

### What

플레이어용 `Reduced Effects` 설정과 T0~T4별 축소 동작을 정의한다.

### Why

flash, shake, glow, particle가 불편한 사용자와 저사양 Web 환경에 안전한 표시 경로를 제공한다. 낮은 장식을 제거해도 gameplay state와 중요 event를 이해할 수 있어야 한다.

### Context

- 현재 v1 Settings는 Master Volume, Mute, Fullscreen만 포함한다.
- 설계 검증은 glow/flash를 끈 reference capture를 요구하지만 runtime toggle, 저장, owner/API는 없다.
- T3/T4의 의미 전달을 삭제해서는 안 되며 outline, text, silhouette 같은 비동작 표현으로 대체해야 한다.

### Candidate acceptance

- Settings 값이 local persistence에 저장되고 Main/Pause 양쪽에서 같은 값을 사용한다.
- T0/T1은 secondary particle/trail 제거, T2는 수량/flash 감소, T3/T4는 state identity를 유지한다.
- camera shake와 hit-stop을 독립적으로 제한한다.
- 1280×720 Web에서 normal/reduced 비교 capture와 성능 수치를 기록한다.
- setting 변경 뒤 stale pool/Tween이 남지 않는다.

### Not now

S6-G1에서 실제 tier와 cap을 정하기 전에는 구체 수치나 runtime 파일을 만들지 않는다.

## Cashout Direction Readability

Status: DEFERRED — preserve S5-G4 progress
Candidate owner: Presentation
Depends on: completed S5 Stage World/Shift baseline and gameplay observation

### Problem

현재 프레임만으로는 플레이어가 “공을 하단으로 통과시키면 점수를 얻는다”는 규칙을 즉시 받아들이기 어렵다. 하단은 실패 구역이 아니라 열린 Active Cashout 경계라는 사실을 플레이 도중 설명 없이 읽을 수 있어야 한다.

### Candidate solutions

1. 중앙 베젤의 하단 프레임을 제거하거나 끊어 실제로 열린 출구처럼 보이게 한다.
2. 우주선 외벽 파손처럼 공기와 입자가 하단 바깥으로 빨려 나가는 흡입 흐름을 추가한다.
3. 하단 프레임 바로 위에 여러 개의 아래 방향 화살표를 두고 위→아래로 반복 슬라이드한다.

세 안은 배타적이지 않지만 한 번에 모두 적용하지 않는다. 먼저 프레임 개구부만으로 충분한지 확인하고, 부족하면 흡입 흐름 또는 화살표 중 하나를 추가한다. 어떤 안도 실제 Cashout Rect, 점수 계산, 공 속도에 영향을 주지 않는 read-only Presentation이어야 한다.

### Candidate acceptance

- 첫 플레이어가 별도 설명 없이 하단 통과를 보상 경로로 예측한다.
- 실패·낙사·위험 경고의 색과 motion으로 오인되지 않는다.
- 공과 Paddle silhouette을 가리지 않는다.
- 500-ball Web gate에서 장식 효과를 줄이거나 끌 수 있다.

### Not now

S5-G4의 Stage 배경과 Shift를 먼저 완료한다. 이번 작업에서는 하단 프레임 제거, 흡입 FX, 화살표를 구현하지 않는다.

## CRT Emission and Static

Status: DEFERRED — visual polish after S5-G4
Candidate owner: Presentation
Depends on: final HUD information density and S6 visual FX budget

### Problem

현재 CRT 모듈은 형태와 프레임은 구분되지만 phosphor 발광, 주사선 변화, 미세한 동기 불안정이 없어 정적인 그림처럼 보인다.

### Candidate treatment

- CRT glass 안쪽에만 제한된 약한 phosphor bloom을 사용한다.
- 저주파 밝기 호흡과 드문 수평 sync jitter를 적용한다.
- 1px scanline 두께를 유지하며 굵은 검은 띠가 생기지 않게 tile한다.
- 텍스트와 기능 경계는 흔들지 않고 glass/noise layer만 움직인다.

### Candidate acceptance

- 정지 화면에서도 CRT가 켜진 장치로 읽힌다.
- Stage/Time/Score 텍스트의 위치와 대비는 안정적으로 유지된다.
- reduced-effects에서는 bloom과 jitter를 줄이고 정보는 그대로 남긴다.
- Web에서 CRT별 개별 고비용 shader를 남발하지 않는다.

### Not now

S5-G4 배경과 Shift 완료 전에는 CRT shader 또는 noise animation을 추가하지 않는다.
