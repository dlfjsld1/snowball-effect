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

