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

Stage local 5종 중 마지막 두 단계(`local_level = 3`, `local_level = 4`)의 Run 내 첫 생성은 `FIRST CONTACT` 고등급 CUT-IN 대상이다. 대상은 Ground `Giant Snowball`·`Moon`, Planetary `Supernova`·`Galaxy`, Galactic `Event Horizon`·`Black Hole`로 정확히 6종이다.

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

## BGM 상태 전환

배경음은 효과음 pool과 분리된 music channel에서 한 번에 하나만 재생한다. 확정 key는 `bgm_title`, `bgm_ground`, `bgm_planetary`, `bgm_galactic`, `bgm_pause`, `bgm_result`다.

| 상태 | 재생 | 전환 |
|---|---|---|
| Title | `bgm_title` | Main Title 표시 |
| Ground / Planetary / Galactic | 각 Stage BGM | `stage_changed`에 맞춰 교체 |
| Pause | `bgm_pause` | Stage BGM을 정지하고 track key·재생 위치 저장 |
| Resume | 저장한 Stage BGM | 저장 위치에서 재개 |
| Black Hole Phase | `black_hole_loop` | `bgm_galactic`을 정지하고 단독 재생 |
| Final Result | `bgm_result` | `black_hole_loop`을 정지한 뒤 재생 |

Retry, Main Menu, terminal lock은 남은 BGM/loop를 정리한다. Web 첫 사용자 입력 전에는 어떤 BGM도 자동 재생하지 않으며, unlock 뒤 현재 상태에 맞는 track만 시작한다.

---

## CUT-IN 구현

필수:

- 현재 장면을 그대로 사용하고 gameplay만 pause
- 현재 Stage의 active visual Play Field 내부만 약하게 dim하며, 좌우 Stage World·HUD·기계 UI는 덮거나 dim하지 않음
- Play Field 가로폭을 채우는 pixel 기계 배너가 오른쪽에서 진입해 중앙에서 체류한 뒤 왼쪽으로 퇴장
- 배너와 dim은 active visual Play Field rect에 clip되어 UI/배경 밖으로 새지 않음
- 공 이름 / 공 이미지 / VALUE
- 별도 화면 전환 금지
- 공 CUT-IN의 이미지는 실제 Merge 결과 gameplay 공의 형태와 일치
- 아이템 CUT-IN은 Item Ball 파괴가 아니라 Paddle의 Item Orb 획득 뒤 시작

초기 타이밍:

```text
enter 0.20s
hold  0.65s
exit  0.25s
total 1.10s
```

이는 첫 플레이테스트 tuning 값이다. reduced-effects는 이동 없이 같은 Play Field 내부에서 짧게 fade하며, identity와 completion semantics는 유지한다.

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
- CUT-IN이 현재 active Play Field 안에서만 동작하고 HUD/기계 UI를 가리지 않음
- CUT-IN이 오른쪽 진입·중앙 hold·왼쪽 퇴장과 목표 길이를 만족
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

Moon과 Galaxy는 CUT-IN 뒤 gameplay를 재개한다. 첫 Black Hole은 CUT-IN을 마친 뒤 Black Hole Phase 전환을 이어간다.
