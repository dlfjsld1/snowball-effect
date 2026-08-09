# Task 05 — Effects, Game Feel, and High-Grade CUT-IN

## 목적

일반 머지의 지속적인 포화감과
고등급 이벤트의 짧고 강한 보상을 계층화한다.

반드시 읽기:

- `DESIGN/03_GAMEPLAY_EFFECTS.md`
- `DESIGN/04_CUTIN_SYSTEM.md`

---

## 일반 이벤트 계층

### Tier 0
- 기본 머지
- 작은 눈가루
- 작은 플래시
- 짧은 효과음

### Tier 1
- 중간 머지
- 얼음 파편
- 얇은 링
- 작은 숫자
- 아주 약한 카메라 반응

### Tier 2
- 높은 머지
- 큰 파티클
- 강한 링
- 큰 숫자
- 화면 흔들림
- 저음

### Tier 3
- 중요 고등급 공 / 기록
- 짧은 히트스톱
- CUT-IN 후보
- 특별 사운드

### Tier 4
- SCALE SHIFT
- 일반 CUT-IN과 별도
- Stage 세계/기본 단위/생성량이 실제 변경

---

## 뱀서식 포화 원칙

- 낮은 이벤트는 많이 발생
- 높은 이벤트는 적지만 강함
- 낮은 효과가 높은 효과를 가리지 않음
- 낮은 점수 팝업은 과밀 시 생략 가능
- 사운드 동시 재생 제한
- 실제 공의 외곽선/실루엣은 항상 읽힘

---

## CUT-IN 구현

필수:

- 현재 장면을 그대로 사용
- 전체 16:9 freeze
- 중앙 Play Field + 좌우 Stage World 함께 dim
- 픽셀 기계 패널 진입/체류/퇴장
- 공 이름 / 공 이미지 / VALUE
- 별도 화면 전환 금지

초기 타이밍:

```text
enter 0.10~0.15s
hold  0.20~0.30s
exit  0.10~0.15s
total 0.45~0.70s
```

기본적으로 1초 초과 금지.

---

## 남발 방지

- cooldown
- 한 판에 이미 보여준 공 레벨 추적
- 이벤트 priority
- 낮은 이벤트 큐 누적 금지
- Scale Shift 우선

---

## CUT-IN 시각

사용:

- chunky pixel frame
- beige / gray / metal
- bolts
- retro numbers
- ball sprite

금지:

- 현대 검정/빨강 액션 배너
- 고해상도 캐릭터 일러스트
- 긴 설명문

---

## 완료 조건

- 일반 머지가 계속 터져도 공 식별 가능
- 고등급 이벤트가 명확히 더 강함
- CUT-IN이 현재 게임 화면 위에서 동작
- CUT-IN 길이가 목표 범위
- 연속 이벤트에서 CUT-IN 폭주 없음
- CUT-IN 종료 후 입력/시뮬레이션 정상
- Scale Shift와 충돌 시 Scale Shift 우선
- 웹 빌드에서 Tween/Animation 정상
- 연출 후에도 성능 게이트 유지


---

## Cashout / Settlement 연출

일반 고등급 Cashout:

- Score popup
- `TIME +Xs`
- 필요 시 Tier 3 반응

Time Up 또는 Stage Clear Settlement:

- 활성 공들이 점수판/중앙으로 빠르게 수렴하는 표현
- Stage Score 카운트업
- Time Bonus popup 금지
- 공 수가 많으면 개별 Tween 대신 배치/샘플링 연출

Stage 최고 공은 일반 CUT-IN보다 Stage Clear / Scale Shift 연출을 우선한다.
