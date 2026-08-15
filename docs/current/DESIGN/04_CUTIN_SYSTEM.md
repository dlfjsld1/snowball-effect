# Snowball Effect — High-Grade CUT-IN System

## 1. 역할

CUT-IN은 일반 머지 파티클보다 한 단계 높은 **짧은 보상 연출**이다.

중요:

> 별도 화면으로 이동하지 않는다.

현재 플레이 중인 16:9 장면을 그대로 멈추고 어둡게 만든 뒤,
Snowball Effect의 픽셀 기계 패널이 빠르게 화면을 가로질러 지나간다.

CUT-IN의 주인공은 캐릭터가 아니라 **공 또는 특수 효과 자체**다.

---

## 2. 기본 동작

예: Galaxy Snowball 생성

1. 머지 판정 완료
2. 새 공 생성 완료
3. 게임 시뮬레이션 매우 짧게 freeze
4. 현재 Play Field + 좌우 Stage World 전체를 함께 dim
5. CUT-IN 패널이 화면 바깥에서 빠르게 진입
6. 중앙을 가로지르며 짧게 체류
7. 공 이름 / 공 이미지 / 가치 표시
8. 반대쪽으로 빠르게 퇴장
9. dim 해제
10. 즉시 시뮬레이션 재개

CUT-IN 중 게임 상태를 되돌리거나 머지를 지연시키지 않는다.
게임 이벤트는 이미 확정된 후 프레젠테이션만 잠깐 멈춘다.

---

## 3. 시간

초기 테스트:

```text
enter   0.10 ~ 0.15 s
hold    0.20 ~ 0.30 s
exit    0.10 ~ 0.15 s
----------------------
total   0.45 ~ 0.70 s
```

일반 CUT-IN은 기본적으로 1초를 넘기지 않는다.

원칙:

> 강하게 보여주고 빨리 사라져라.

SCALE SHIFT는 별도 시스템이며 0.8~1.0초까지 허용 가능하다.

---

## 4. 디자인

사용:

- 픽셀 테두리
- 기계식 패널
- 베이지/회색/금속 프레임
- 볼트
- 거친 픽셀 질감
- 레트로 숫자
- 현재 공의 픽셀 스프라이트
- 해당 속성 파티클

피함:

- 현대적인 검정/빨강 액션 배너
- 고해상도 캐릭터 일러스트
- 모바일 게임 카드 UI
- 긴 설명문

개념:

```text
╔══════════════════════════════════════╗
║ GALAXY SNOWBALL                     ║
║                                      ║
║        [ PIXEL BALL SPRITE ]         ║
║                              500Qi   ║
╚══════════════════════════════════════╝
```

실제 패널은 정적 중앙 박스가 아니라 수평/사선으로 통과한다.

---

## 5. 정보 우선순위

공 CUT-IN:

1. 이름
2. 공 이미지
3. VALUE / SCORE

예:

```text
GALAXY SNOWBALL
[ sprite ]
VALUE 500Qi
```

아이템/특수 상태:

1. 효과 이름
2. 실제 획득한 Item Orb와 대응 효과 이미지
3. 핵심 효과 한 줄

예:

```text
FIRE SNOWBALL
[ burning pixel snowball ]
CASHOUT ×10
```

Magnet:

```text
MAGNETIZED
[ magnetic field ]
MERGE ATTRACTION
```

---

## 6. 언제 보여주는가

모든 머지에 사용하지 않는다.

CUT-IN 후보:

- 각 Stage에서 처음 만든 4단계 공(`local_level = 3`)
- 5단계 최고 공은 별도 일반 CUT-IN 대신 실제 결과 공을 사용하는 Stage Clear / Scale Shift 또는 Black Hole Phase 연출로 강조
- 매우 높은 Tier 머지
- 기록 갱신급 공
- Paddle이 Item Orb를 획득해 아이템 효과 적용이 확정된 순간
- 게임적으로 큰 상태 변화

일반 머지는 즉시 파티클로 끝낸다.
Item Ball 파괴는 Item Orb 생성 이벤트이며 CUT-IN 시작 조건이 아니다.

---

## 7. 남발 방지

필요 상태:

```text
cutin_cooldown
shown_ball_levels
shown_special_events
pending_priority_event
```

규칙:

- 연속 머지가 발생해도 CUT-IN을 큐로 끝없이 쌓지 않는다.
- 낮은 우선순위 이벤트는 버릴 수 있다.
- 높은 우선순위 이벤트가 기존 낮은 이벤트를 대체할 수 있다.
- 일반 CUT-IN 직후 Scale Shift가 발생하면 Scale Shift를 우선한다.
- 동일 공의 첫 발견 CUT-IN은 한 판에 한 번을 기본으로 한다.

---

## 8. SCALE SHIFT와의 차이

### 일반 CUT-IN

- 현재 Stage 유지
- 0.45~0.7초
- 공/아이템 강조
- 플레이 즉시 재개

### SCALE SHIFT

- Stage 자체 변경
- 이전 최고 공 → 다음 기본 공
- 배경 교체
- 생성량 증가
- visual scale 재정규화
- 더 강한 프레젠테이션
- 약 0.8~1.0초 허용

둘을 같은 이벤트로 구현하지 않는다.

---

## 9. 기술 책임

추천:

`PresentationManager`

- 글로벌 dim
- simulation presentation pause 요청
- 우선순위 관리
- CUT-IN cooldown
- Scale Shift와 충돌 조정

`CutInController`

- 패널 enter / hold / exit
- 텍스트와 스프라이트 바인딩
- 이벤트별 테마
- 완료 신호

`EffectManager`

- 일반 머지/회수 파티클
- CUT-IN 여부를 자체 결정하지 않음

`StageManager`

- Scale Shift 발생 여부 결정
- CUT-IN과 별개로 Stage 전환 이벤트 발행

---

## 10. 검증

- CUT-IN 중 실제 시뮬레이션이 움직이지 않음
- 현재 화면 전체가 같이 어두워짐
- 별도 화면으로 전환되지 않음
- 총 길이가 목표 범위
- 연속 이벤트에서 CUT-IN 폭주 없음
- 종료 후 입력 상태가 꼬이지 않음
- Scale Shift와 동시 발생 시 Scale Shift가 우선
- 웹에서 Tween/animation이 정상
