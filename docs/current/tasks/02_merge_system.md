# Task 02 — Merge System

## 선행 조건

Task 01이 실행 가능해야 한다.

---

## 목적

같은 레벨 공끼리 접촉하면 상위 공으로 합쳐지는 핵심 규칙을 추가한다.

---

## 포함

- BallDefinition 데이터
- global_level
- 레벨별 반지름·색·점수
- 같은 레벨 근접 판정
- merge lock
- 합체 요청 큐
- 상위 공 생성
- 최고 레벨 기록
- 간단한 합체 플래시 또는 원형 파편
- 점수 formatter의 초기 구조

---

## 제외

- Spatial Grid 최적화 완성
- Stage Shift
- 아이템
- 고급 파티클
- 블랙홀

Task 02에서는 공 수를 제한하고 단순 후보 검사로 기능을 먼저 검증할 수 있다.  
다만 전수 비교 코드는 임시임을 명확히 표시하고 Task 03에서 제거한다.

---

## 초기 공 카탈로그

초기 visual catalog는 `global_level 0~14`의 총 15종이다. 각 Stage는 5종을 사용하고 이전 Stage의 최고 공을 다음 Stage의 기본 공으로 공유한다. 기본 Run은 Ground `[0,1,2,3,4]`, Planetary `[4,5,6,8,10]`, Galactic `[10,11,12,13,14]`를 사용한다. Lv7 `Red Giant`와 Lv9 `Nebula`는 catalog에는 남지만 기본 Run에서 비활성이다. Lv14는 최종 Clear 공이지만 Black Hole이 아니며 정식 명칭 전까지 `Final Snowball (working title)`로 둔다.

아래 값은 구현과 첫 플레이테스트를 위한 데이터 seed다. 이름, 점수, 반지름, mass, visual key와 Stage별 배분은 Content/Systems가 플레이테스트에 따라 교체하거나 축소할 수 있다.

```text
0 Snowflake       1
1 Snowball        100
2 Big Snowball    10,000
3 Giant Snowball  1,000,000
4 Moon            100,000,000
5 Earth           50,000,000,000
6 Sun             10,000,000,000,000
7 Red Giant       1.0e15
8 Supernova       5.0e17
9 Nebula          1.0e21
10 Galaxy         1.0e25
11 Galaxy Cluster 1.0e30
12 Quasar         1.0e36
13 Event Horizon  1.0e43
14 Final Snowball 1.0e50 (working title)
```

나머지 global level도 Ground / Planetary / Galactic 콘셉트가 읽히도록 이름, visual key, 반지름과 점수를 데이터로 정의한다. 값은 코드에 하드코딩하지 않는다.

일반 Merge/Cashout 연출용 `fx_tier`는 전역 BallDefinition 값이다. Lv0 = 0, Lv1~3 = 1, Lv4~8 = 2, Lv9~13 = 3, Lv14 = 4를 사용한다. Moon(Lv4)과 Galaxy(Lv10)가 다음 Stage의 기본 공으로 재사용되어도 전역 tier는 변하지 않는다. Stage 최고 공 생성은 기본 `fx_tier`와 별도로 Stage Clear 연출을 우선한다.

---

## 합체 규칙

- 같은 global_level만 합체
- 결과 level은 현재 `StageDefinition.local_ball_levels`에서 입력 level의 다음 항목으로 정함; `global_level + 1`을 가정하지 않음
- 다른 special_type은 Task 02에서 NORMAL뿐
- 같은 프레임에 한 공이 두 합체에 참여 금지
- 결과 레벨 정의가 없으면 더 합체하지 않음
- 새 공은 다음 물리 프레임부터 합체 가능

합체 위치:

```text
(position_a + position_b) / 2
```

합체 결과 velocity는 입력 질량으로 가중한 평균을 계승한다.

```text
result_velocity = (mass_a * velocity_a + mass_b * velocity_b) / (mass_a + mass_b)
result_velocity = clamp_length(result_velocity, maximum_ball_runtime_speed)
```

현재 `maximum_ball_runtime_speed` 첫 tuning 값은 `900 world units/s`다. Merge 결과는 base/spawn speed로 재설정하지 않는다.

---

## 완료 조건

- 같은 레벨 두 공이 하나의 상위 공으로 합쳐짐
- 공 수가 2 감소 후 1 증가
- 중복 합체 없음
- 다른 레벨은 통과
- 합체 후 렌더 외형과 점수가 바뀜
- 바닥 회수 시 정의된 점수 사용
- 최고 생성 레벨 HUD 표시
- 재시작 시 기록 초기화

---

## 개발 치트

디버그 키 또는 함수:

- 특정 global_level 공 두 개를 가까이 생성
- 활성 공 모두 제거
- 생성 레벨 변경

릴리스 입력에는 노출하지 않는다.

---

## 검증

- Lv0 두 개 → Lv1
- Lv1 두 개 → Lv2
- Planetary에서 Lv6 두 개 → Lv8, Lv8 두 개 → Lv10
- 기본 Stage chain에서 Lv7·Lv9가 Merge 결과로 생성되지 않음
- Lv0 + Lv1 → 합체 안 함
- 세 개가 동시에 겹쳐도 하나의 합체만 발생
- 새 공이 즉시 같은 프레임 재합체하지 않음
- 고레벨 점수 표시가 K/M/B/T로 정상
