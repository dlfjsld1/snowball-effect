# Snowball Effect — 확정 게임 규칙

이 문서는 게임 규칙의 최우선 기준이다.

---

## 1. 화면

16:9 전체가 실제 플레이 영역이 아니다.

```text
[ STAGE WORLD ] | [ CENTRAL PLAY FIELD ] | [ STAGE WORLD ]
```

중앙 Play Field에서만:

- 공 생성
- 공 이동
- 머지
- 패들
- 아이템
- Cashout

이 발생한다.

좌우/후방은 Stage World + Retro Pixel Arcade Machine 프레임/계기판 공간이다.

기준 해상도:

```text
1600 × 900
```

중앙 Play Field 폭은 플레이테스트로 결정한다.

---

## 2. 조작

| 키 | 기능 |
|---|---|
| `A` | 패들 왼쪽 이동 |
| `D` | 패들 오른쪽 이동 |
| `←` | 패들 반시계 방향 회전 |
| `→` | 패들 시계 방향 회전 |
| `Esc` | 일시정지 |

마우스 A/B 플레이테스트에서는 가장 최근 Mouse X를 Viewport/Canvas transform을 통해 Play Field의 logical X로 변환하고, physics tick의 현재 Paddle X에 즉시 반영한 뒤 field clamp한다. Mouse 조작에는 target 추적 speed cap을 두지 않는다. Keyboard fallback은 기존 속도 기반 이동을 유지할 수 있으며, 입력 source와 Paddle simulation transform 계약을 분리한다.

Mouse 직접 위치 반영은 무제한 타격 강도를 뜻하지 않는다. 반사에는 Mouse delta가 아니라 이전 physics tick의 Paddle transform과 이번 tick에 확정한 transform의 실제 변화로 계산한 simulation velocity를 사용하고, contact impact에는 별도 cap/tuning을 적용한다. 따라서 control responsiveness와 impact strength는 독립적이다.

Mouse Wheel Up/Down은 각각 shared Paddle angle을 증가/감소시킨다. Wheel과 `←/→`는 같은 angle state를 변경하며, 회전 각도에는 최소/최대 clamp가 없다. 표현상 동등한 각도로 정규화할 수 있으나 플레이어는 양방향으로 계속 회전할 수 있다.

`A/D`와 `←/→`는 비교용 fallback으로 유지한다. 키보드 이동과 회전은 동시에 사용할 수 있고, 마우스 이동과 Wheel 회전도 동시에 사용할 수 있다. 이 A/B 테스트는 최종 조작 체계를 확정하지 않는다.

플레이어는 공을 받지 않고 일부러 지나가게 만들어 Cashout할 수도 있다.

---

## 3. 공 이동 / 반사

- 현재 Stage의 기본 공이 Play Field 상단에서 생성된다.
- 기본 공에는 지속적인 아래 방향 중력이 없으며 `gravity = 0`이다.
- Spawn 시 아래쪽 반구를 향하는 초기 velocity를 받는다. 완전한 수직 하강일 필요는 없으며 좌우 성분의 범위와 분포는 tuning 대상이다.
- 충돌이나 명시적인 gameplay effect가 없으면 현재 velocity의 방향과 speed를 유지한다.
- 좌측·우측·상단 벽은 닫힌 반사 경계다. 해당 충돌 규칙이 별도로 speed를 바꾸지 않으면 충돌 전 speed를 유지한다.
- 하단은 벽이 없는 열린 경계다. 아래 방향으로 통과한 공은 Active Cashout/제거 경로로 들어간다.
- 공이 아래로 빠지는 이유는 중력이 아니라 Spawn 방향과 열린 하단 경계 때문이다.
- Paddle은 양면 모두 유효한 충돌면이다. 어느 면이든 실제 접촉 normal과 상대속도를 기준으로 접근 중일 때만 반사한다.
- 충돌은 현재 OBB 한 장의 overlap만 보지 않고, 한 physics tick의 이전/현재 Paddle transform과 공 trajectory 사이에서 가장 이른 연속 접촉을 찾는다.
- 패들에 닿으면 패들 각도, 충돌 위치, Paddle 중심 이동속도와 회전에 따른 접촉점 표면속도의 영향을 받아 새로운 방향과 runtime speed를 얻을 수 있다.
- Paddle hit은 공을 가속할 수 있지만 반복 타격의 무한 가속은 speed cap 또는 동등한 안전장치로 막는다. boost, min/max speed와 계산식은 tuning 대상이다.
- 반사 결과는 현실 물리보다 예측 가능성을 우선한다.

### Spawn speed와 runtime speed

- `base_speed` 또는 Spawn speed는 생성 시 초기 speed를 정해 초기 방향과 velocity를 만드는 기준값이다.
- 현재 Lv1 Shared Skeleton의 Spawn/base speed는 플레이테스트에서 너무 느린 것으로 확인되어 조정 대상이다. 일반적인 눈송이 낙하속도 약 `1.0 m/s`는 움직임의 현실 design reference일 뿐 Godot world unit과 직접 환산하지 않는다.
- 공간은 `1 world unit = 1 logical pixel`, 시간은 second, 게임 속도는 world units/s로 다룬다. Lv1의 `spawn_speed_world_units_per_second`는 한 곳에서 조정하는 게임-space tuning 값이며, 현재 첫 플레이테스트 값은 `160 world units/s`다. 이 값은 viewport 높이·화면 통과시간·전역 meter scale에서 계산하지 않는다.
- runtime velocity와 speed는 Paddle, 접촉 위치, 벽 규칙, Merge, Stage effect, Item, 특수 상태에 의해 달라질 수 있다.
- 같은 등급의 공도 플레이 과정에 따라 서로 다른 runtime speed를 가질 수 있다.
- 현재 버전은 `global_level`별 base speed 차이를 사용하지 않고 공통 Spawn tuning을 사용한다.
- 향후 등급별 `base_speed`를 도입할 수 있지만 이는 생성 기준일 뿐 runtime speed 고정값이 아니다.

### Lv1 크기와 초반 압박

- Lv1은 거의 `.`처럼 읽히는 매우 작은 저해상도 픽셀 눈알갱이다. visual diameter와 simulation/collision diameter는 같은 값으로 시작한다.
- 현재 Lv1 prototype의 시작 tuning은 약 4 logical pixel 직경이며, 정확한 정수값은 플레이테스트로 조정한다.
- 초반 압박은 거대한 Lv1 몇 개가 아니라 작은 공의 물량과 Paddle 이후 생길 수 있는 runtime speed 변화에서 온다.

---

## 4. 머지

같은 `global_level`의 활성 공 두 개가 접촉하면:

```text
Level N + Level N → Level N+1
```

MVP에서 다른 레벨 공은 서로 통과 가능하다.

합체 결과:

- 두 입력 공 제거
- 중간 위치에 상위 공 생성
- 결과 velocity의 방향·speed·계승 방식은 S2 Merge velocity 계약에서 별도로 확정
- 다음 물리 프레임부터 재머지 가능
- 점수 가치와 비주얼 레벨 상승
- Stage 최고 공 여부 확인

---

## 5. 점수

점수는 보존하지 않는다.

상위 공의 `score_value`는 직접 데이터로 정의하며
머지할수록 실질적으로 지수함수 수준으로 폭증한다.

초기 예:

| global_level | 이름 | score_value |
|---:|---|---:|
| 0 | Snowflake | 1 |
| 1 | Snowball | 100 |
| 2 | Big Snowball | 10,000 |
| 3 | Giant Snowball | 1,000,000 |
| 4 | Lunar Snowball | 100,000,000 |
| 5 | Earth Snowball | 50,000,000,000 |
| 6 | Solar Snowball | 10,000,000,000,000 |
| 7 | Nebula Snowball | 1.0e15 |
| 8 | Galaxy Snowball | 5.0e17 |
| 9 | Black Hole Snowball | 1.0e21 |
| 10 | Big Bang Snowball | 1.0e25 |
| 11 | Universe Snowball | 1.0e30 |
| 12 | Multiverse Snowball | 1.0e36 |

수치는 플레이테스트용이며 데이터에서 수정한다.

---

## 6. Cashout

공이 패들 아래 Score Zone을 통과하면
플레이 중 `Cashout`으로 처리한다.

```text
Cashout Reward
=
score_value
+
time_bonus
```

정확히는 `calculate_cashout_score()`로 Active Cashout 점수를 계산한 뒤:

- `stage_score`에 Cashout 점수 추가
- `run_score`에 같은 Cashout 점수 추가
- Stage 남은 시간에 현재 local level의 `time_bonus` 추가
- 공 제거
- Score / Time popup
- 고등급 Cashout일수록 강한 연출

`stage_score`는 현재 Stage의 부분합이고 `run_score`는 Run 전체 누적 합이다.
모든 점수 이벤트에서 두 값에 같은 amount를 한 번씩 더한다.
Stage 종료 시 `run_score += stage_score`를 다시 수행하지 않는다.

바닥은 실패가 아니다.

---

## 7. Time Bonus

각 StageDefinition은 `time_bonus_by_local_level`을 가진다.

같은 global ball이 이전 Stage의 최고 공에서 다음 Stage의 기본 공으로 바뀌므로
Time Bonus를 BallDefinition의 고정값으로 저장하지 않는다.

점수와 달리 시간은 완만하게 증가한다.

초기 방향:

| Stage 내 상대 등급 | time_bonus |
|---|---:|
| Base / Local Lv0 | 0s |
| Local Lv1 | 소량 |
| Local Lv2 | 의미 있는 시간 |
| Local Lv3 | Stage Clear |

정확한 값은 플레이테스트한다.

목표:

- 고등급 Cashout을 의미 있게 함
- 더 높은 머지와 시간 확보 사이 선택을 만듦
- 무한 플레이가 되지 않게 함

초기 구현에는 Stage 시간 상한을 강제하지 않는다.
실제 획득 시간과 local level별 Cashout 횟수를 측정한 뒤 시간 인플레가 확인될 때만 상한을 검토한다.

---

## 8. KEEP vs CASHOUT

고등급 공을 계속 살리면:

- 더 높은 공으로 머지 가능
- 점수 가치가 폭발적으로 증가할 수 있음

지금 떨어뜨리면:

- 현재 점수 확정
- Time Bonus 확보
- 새로운 머지를 위한 플레이 시간을 얻음

따라서 플레이어는 공을 단순히 오래 유지하는 것이 아니라
언제 Cashout할지 판단한다.

---

## 9. Stage

각 Stage는 독립적인 제한 시간 라운드다.

Stage 데이터:

```text
stage_index
base_global_level
top_global_level
base_time
clear_score
spawn_rate
```

현재:

1. Ground
2. Planetary
3. Galactic
4. Black Hole

---

## 10. Stage Clear — Top Ball Clear

현재 Stage 최고 공을 만들면 즉시 Stage 성공 판정.

예:

```text
Ground
Snowflake → Snowball → Big → Giant

Giant Snowball Created
→ STAGE CLEAR
```

점수컷은 보지 않는다.

최고 공 자체는 먼저 정상적으로 생성된 뒤 성공 이벤트를 발생시킨다.
성공 판정은 `CLEAR_LOCKED`로 즉시 잠그지만, Scale Shift는 Final Settlement 완료 후 실행한다.

---

## 11. Stage Clear — Score Clear

최고 공을 만들기 전에 Stage 시간이 `0` 이하로 확정되면
`TIME_UP_LOCKED` 후 `FINAL SETTLEMENT`로 이동한다.

Time Up은 physics tick 시작 시각만으로 판정하지 않는다.
해당 tick의 Merge와 Active Cashout을 먼저 확정해 Time Bonus까지 반영한 뒤 종료 여부를 판단한다.
따라서 시간이 잠시 0 이하가 되어도 같은 tick의 Cashout으로 양수가 되면 플레이를 계속한다.
같은 tick에 Top Ball이 생성되면 Top Ball Clear가 Time Up보다 우선한다.

Final Stage Score:

```text
이미 Cashout한 Stage Score
+
현재 화면 모든 활성 공의 score_value
```

판정:

```text
Final Stage Score >= clear_score
→ Stage Clear

Final Stage Score < clear_score
→ Run End
```

---

## 12. Final Settlement

Stage 종료 시 남은 활성 공을 빠르게 정산한다.

중요:

```text
Final Settlement = Score Only
```

**Time Bonus를 절대 주지 않는다.**

화면 공끼리 실제 추가 머지를 계산하지 않는다.
현재 각 공의 기본 `score_value`만 더한다.
Active Cashout 전용 modifier는 적용하지 않는다.

Settlement는 활성 공 snapshot을 한 번 만들고 점수를 일괄 계산한다.
계산된 `settlement_score`는 `stage_score`와 `run_score`에 각각 한 번만 더한다.
일반 Cashout 함수를 호출하지 않으며 `settlement_applied` 잠금으로 중복 실행을 막는다.

연출:

- 공들이 점수판/중앙으로 빨려 들어감
- 숫자가 빠르게 누적
- Stage Score 확정

---

## 13. SCALE SHIFT

Stage 성공 후 Settlement가 끝나면 Scale Shift.

다음 Stage 진입 시:

- `stage_score = 0`
- `stage_time = next_stage.base_time`
- `run_score`, 통계, 최고 기록은 유지

핵심:

> 이전 Stage 최고 공 = 다음 Stage 기본 공

동시에:

- Stage World 변경
- 새 기본 `global_level`
- Spawn Rate 증가
- 공 visual radius 재정규화
- 파티클 밀도 변화
- 사운드 변화
- 기계 상태 변화
- 필요 시 Stage별 물리 변화

---

## 14. Stage 구성

### Ground

```text
Snowflake
→ Snowball
→ Big Snowball
→ Giant Snowball
```

초기 Spawn: 약 `6/s`

### Planetary

```text
Giant
→ Lunar
→ Earth
→ Solar
```

초기 Spawn: 약 `15/s`

### Galactic

```text
Solar
→ Nebula
→ Galaxy
→ Black Hole
```

초기 Spawn: 약 `35/s`

### Black Hole

```text
Black Hole
→ Big Bang
→ Universe
→ Multiverse
```

초기 Spawn: 약 `80/s`

정확한 Stage 제한 시간과 `clear_score`는 밸런스 데이터에서 정한다.

---

## 15. Black Hole Stage

- 거대한 블랙홀이 좌우로 움직임
- 모든 공에 약한 인력을 적용
- 인력은 최대치를 제한
- 패들 조작의 의미를 없애지 않음
- 공을 모아 연쇄 머지를 유도할 수도 있음

마지막 Stage이므로:

### Multiverse 생성
`MAX SCALE / PERFECT CLEAR → Final Settlement → Result`

### Time Up
`Final Settlement → Result`

다음 Stage 점수컷 판정은 없다.

---

## 16. 아이템

아이템은 상단에서 떨어지고 패들이 직접 획득한다.

### Blizzard
일정 시간 Spawn Rate 증가.

### Magnet
같은 레벨 근처 공을 약하게 끌어당김.

### Fire Core
패들이 일정 시간 Fire 상태가 되고,
맞은 공이 Fire Snowball이 된다.

Fire 공:

- 같은 레벨 Normal과 머지 가능
- 머지 후 Fire 유지
- Cashout 점수 배수 가능
- 눈 + 불꽃 연출

---

## 17. 고등급 CUT-IN

일반 머지 파티클보다 중요한 이벤트에만 사용한다.

- 현재 게임 이벤트 먼저 확정
- 현재 장면 전체 freeze
- Play Field와 Stage World 전체 dim
- Pixel Machine 패널 진입
- 공 이름 / 이미지 / VALUE 또는 효과
- 빠르게 퇴장
- 즉시 플레이 재개

초기 총 길이:

```text
0.45 ~ 0.70초
```

Stage 최고 공은 곧 Stage Clear / Scale Shift로 이어지므로
일반 CUT-IN과 중복하지 않는다.

---

## 18. 종료 / 결과

Run 종료 시 결과:

- 최종 누적 점수
- 최고 도달 Stage
- 최고 생성 공
- 최고 Cashout 공
- 총 머지 수
- Cashout으로 획득한 총 추가 시간
- 아이템 획득 수
- 최대 동시 활성 공 수

Retry 가능.

---

## 19. 밸런스 핵심

플레이테스트에서 반드시 확인:

### Time Economy
Cashout으로 얻는 평균 추가 시간이 소비 시간보다 너무 커서 무한 루프가 되지 않는가?

### Score Clear
기본 공만 무작정 Cashout해서 `clear_score`를 쉽게 넘기지 않는가?

### Merge Reward
높은 단계까지 머지하는 것이 압도적으로 유리한가?

### Player Agency
초반에는 조작을 잘한 플레이어가 더 빠르게 성장하는가?

### Endgame Chaos
후반 자동 연쇄가 늘어도 실제 공과 패들이 읽히는가?

### Known balancing observation — Vertical Paddle Keep strategy

> **향후 플레이테스트 관찰용 메모이며 확정 게임 계약 또는 구현 지시가 아니다. Merge와 높은 Spawn density가 들어온 뒤 재검토한다.**

현재 `gravity = 0`, 자유회전, 양면 Paddle 물리에서 다음 emergent play가 관찰됐다.

```text
Paddle을 거의 세로로 세움
+
Mouse X로 좌우로 빠르게 흔듦
→ Snowball들이 거의 수평으로 반사
→ 일부는 조금씩 위로 이동
→ Bottom Cashout을 상당히 오래 방지 가능
```

현재는 버그로 확정하지 않는다. Merge와 높은 Spawn density가 들어오면 공을 유지해 Merge를 노리는 숙련 KEEP 전략인지, KEEP vs CASHOUT 선택에 의미를 주는지, 또는 공 축적 위험이라는 trade-off가 생기는지를 먼저 플레이테스트한다.

이후 `Vertical Paddle + 좌우 흔들기`가 대부분 상황에서 거의 무위험 최적해가 되면 dominant strategy / balancing issue로 재검토한다. 그 전에는 이를 막기 위해 gravity, minimum Y velocity, 수평 반사 금지, 세로 Paddle 페널티, 인위적인 downward bias를 추가하지 않는다.

**상태: Known balancing observation / revisit after Merge + higher density.**

### Future Stage Modifier candidate — Snowstorm / Wind Stage

> **향후 후보 메모이며 확정 게임 계약, Stage Task, 구현 승인이 아니다.**

후보 개념은 공통 Stage wind state가 Ball의 X축 운동에 영향을 주고, 바람 방향과 세기가 시간에 따라 변하는 Snowstorm / Blizzard Stage다. normal gravity는 계속 `0`으로 둔다. 바람은 주로 수평 운동에 영향을 주는 Stage effect로만 검토한다.

매 physics frame마다 완전 랜덤한 값을 생성하지 않고, 몇 초 동안 유지·전환되는 gust interval을 후보로 둔다.

```text
calm
→ weak right
→ strong right
→ fade
→ left
→ strong gust
```

향후 Presentation은 snow particle 방향, Stage World 효과, 배경/환경 움직임을 같은 wind state에 맞출 수 있다.

Ball 크기/레벨별 영향 차이, 정확한 wind acceleration, gust 지속시간, Stage 번호·등장 위치, 난이도 보정, Merge와의 상호작용은 아직 결정하지 않는다.

**상태: Future Stage Modifier candidate. 구현 승인 아님.**

### Future Core Mechanic candidate — Paddle Charge / Spring Launch

> **향후 후보 메모이며 확정 게임 계약, Task, 구현 승인이 아니다. Merge 및 Vertical Paddle Keep의 밸런스를 본 뒤 구현 여부를 결정한다.**

후보 조작은 Paddle을 아래로 당겼다가 놓아 기준 Y로 실제 spring-back시키는 Charge / Spring Launch다.

```text
Mouse: paddle click + downward drag + release
Keyboard: ↓ hold + release
release → Paddle이 기준 Y로 실제 spring-back
```

강타는 기존 Paddle의 실제 transform 변화에서 나온 contact velocity와 continuous collision으로만 발생시킨다. 공에 별도의 직접 가속 보너스를 부여하지 않는다.

**상태: Future Core Mechanic candidate. 구현 승인 아님.**
