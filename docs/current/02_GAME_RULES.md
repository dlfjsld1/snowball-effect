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

## 1.1 HUD와 일시정지

플레이 중 HUD의 기본 정보는 다음과 같다.

- 점수
- 남은 시간
- 현재 활성 아이템
- 일시정지 진입 버튼
- 현재 Stage 이름 (`Ground` / `Planetary` / `Galactic`)
- 현재 Stage 공 족보

점수 영역 안에서 Stage Score와 Run Score를 어떻게 병기할지는 UI 튜닝 대상으로 두되, HUD의 최상위 정보 종류를 불필요하게 늘리지 않는다. 활성 아이템이 없을 때는 빈 슬롯 또는 비활성 상태로 표시한다.

공 족보는 수박게임의 진화표처럼 현재 Stage의 local 공 5종을 낮은 단계부터 최고 단계까지 **세로 방향**으로 보여준다. 플레이어가 같은 공 두 개를 합치면 다음에 어떤 공이 되는지 화면을 떠나지 않고 확인할 수 있어야 한다.

- `local Lv0 → Lv1 → Lv2 → ... → Stage Top` 순서를 아이콘으로 표시한다.
- 현재 Stage에 포함된 공만 표시하고 Scale Shift 시 다음 Stage 족보로 교체한다.
- Stage 진입 시 첫 공만 표시하고, 해당 Stage에서 새 local 공을 처음 만들 때 대응 아이콘과 이름을 아래쪽 슬롯에 한 번씩 공개한다.
- 레이아웃 이동을 막기 위해 5칸 세로 housing은 고정하되, 미발견 공의 아이콘·이름은 출력하지 않는다.
- 정상적인 Scale Shift에서는 새 Stage의 첫 공만 공개된 상태로 시작한다.
- 족보는 Ball/Stage 데이터의 read-only 표현이며 Merge 결과를 직접 계산하거나 변경하지 않는다.

일시정지는 게임 화면 위에 modal로 열리며 다음 행동을 제공한다.

- 재개
- 다시 시작
- 설정
- 메인 화면

메인 화면은 기존 Title 화면 계획과 같은 진입 화면으로 취급한다. 정확한 Settings 항목과 Main 이동 시 Run 폐기 확인 방식은 해당 UI 구현 전에 확정한다. 현재 S1의 최소 Pause/Retry 구현이 이 확장 메뉴까지 완료된 것으로 간주하지 않는다.

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
- 현재 Lv1 Shared Skeleton의 승인된 기본 크기는 약 8 logical pixel 직경이며, visual/collision 크기는 같은 값으로 유지한다. 이후 크기 변경은 별도 플레이테스트 결정으로만 수행한다.
- 초반 압박은 거대한 Lv1 몇 개가 아니라 작은 공의 물량과 Paddle 이후 생길 수 있는 runtime speed 변화에서 온다.

---

## 4. 머지

같은 `global_level`의 활성 공 두 개가 접촉하면 현재 Stage의 ordered chain에서 다음 공으로 합쳐진다.

```text
current_stage.local_ball_levels[i] + same
→ current_stage.local_ball_levels[i + 1]
```

따라서 기본 Run의 Planetary에서는 Lv6 두 개가 Lv8로, Lv8 두 개가 Lv10으로 합쳐진다. 전역 ID가 연속이라는 가정으로 `global_level + 1`을 사용하지 않는다. 현재 Stage chain에 다음 항목이 없으면 더 합체하지 않는다.

MVP에서 다른 레벨 공은 서로 통과 가능하다.

합체 결과:

- 두 입력 공 제거
- 중간 위치에 상위 공 생성
- 결과 velocity는 두 입력의 mass-weighted average를 계승하고, 최종 runtime speed cap을 적용한다. 즉 무거운 입력 공의 기존 움직임을 조금 더 많이 반영하되, Merge가 공 속도를 무한히 키우지 않는다.
- 다음 물리 프레임부터 재머지 가능
- 점수 가치와 비주얼 레벨 상승
- Stage 최고 공 여부 확인

---

## 5. 점수

점수는 보존하지 않는다.

상위 공의 `score_value`는 직접 데이터로 정의하며
머지할수록 실질적으로 지수함수 수준으로 폭증한다.

초기 예:

| global_level | 이름 | score_value | `base_color` seed | `fx_tier` |
|---:|---|---:|---|---:|
| 0 | Snowflake | 1 | `#F4FCFF` | 0 |
| 1 | Snowball | 100 | `#EAF8FF` | 1 |
| 2 | Big Snowball | 10,000 | `#72D8FF` | 1 |
| 3 | Giant Snowball | 1,000,000 | `#3A8DFF` | 1 |
| 4 | Moon | 100,000,000 | `#C8C9D8` | 2 |
| 5 | Earth | 50,000,000,000 | `#2878D4` | 2 |
| 6 | Sun | 10,000,000,000,000 | `#FFC247` | 2 |
| 7 | Red Giant | 1.0e15 | `#D94B36` | 2 |
| 8 | Supernova | 5.0e17 | `#FF6B35` | 2 |
| 9 | Nebula | 1.0e21 | `#B464C8` | 3 |
| 10 | Galaxy | 1.0e25 | `#4D42B8` | 3 |
| 11 | Galaxy Cluster | 1.0e30 | `#805CFF` | 3 |
| 12 | Quasar | 1.0e36 | `#E8E6FF` | 3 |
| 13 | Event Horizon | 1.0e43 | `#3A1A61` | 3 |
| 14 | Black Hole | 1.0e50 | `#10091F` | 4 |

`base_color`는 BallDefinition의 기본 식별색 seed다. 다중 색상 텍스처·후광·파티클은 Presentation이 이 값을 보조 팔레트와 함께 해석해 표현한다. Lv0 반지름 `2`를 기준으로 레벨마다 반지름을 2배(`radius = 2 ^ (global_level + 1)`)로 사용한다. 이에 맞춰 질량은 Lv0의 `1`을 기준으로 레벨마다 4배(`mass = 4 ^ global_level`)를 사용한다. 화면상 크기 보정은 BallDefinition이 아니라 StageDefinition의 `visual_radius_scale`이 소유하며, 물리 `radius`와 충돌 반지름을 바꾸지 않는다. 나머지 수치는 플레이테스트용이며 데이터에서 수정한다.

`fx_tier`는 일반 Merge/Cashout의 기본 연출 우선순위이며 전역 `BallDefinition`이 소유한다. Snowflake(Lv0)는 0, Snowball(Lv1)부터 Giant Snowball(Lv3)은 1, Moon(Lv4)부터 Supernova(Lv8)는 2, Nebula(Lv9)부터 Event Horizon(Lv13)은 3, Black Hole(Lv14)은 4를 사용한다. Moon과 Galaxy가 다음 Stage의 기본 공으로 재사용되어도 같은 전역 tier를 유지한다. 현재 Stage의 최고 공 생성은 `fx_tier`와 관계없이 Stage Clear 연출을 우선한다.

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

초기값:

| Stage 내 상대 등급 | time_bonus |
|---|---:|
| Base / Local Lv0 | 0s |
| Local Lv1 | +0.25s |
| Local Lv2 | +0.5s |
| Local Lv3 | +1s |
| Local Lv4 | +2s |

최고 local 공은 생성 즉시 Stage Clear가 잠기므로 일반 Active Cashout 보너스를 실제로 받지 않는다. 세 Stage가 모두 5종이므로 Ground의 Moon, Planetary의 Galaxy, Galactic의 Lv14 Black Hole은 모두 Local Lv4이며 일반 Cashout 대상이 아니다.

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

---

## 10. Stage Clear — Top Ball Clear

현재 Stage 최고 공을 만들면 즉시 Stage 성공 판정.

예:

```text
Ground
Snowflake → Snowball → Big Snowball → Giant Snowball → Moon

Moon Created
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

각 Stage는 해당 세계관에 맞는 local 공 5종을 사용한다. 전체 visual catalog는 global 공 15종이며, 기본 Run에서는 Stage 경계 공을 공유하고 Lv7·Lv9를 건너뛰므로 13종이 활성된다.

기본 Run의 ordered `local_ball_levels`는 다음과 같다.

| Stage | Global level chain |
| --- | --- |
| Ground | `[0, 1, 2, 3, 4]` |
| Planetary | `[4, 5, 6, 8, 10]` |
| Galactic | `[10, 11, 12, 13, 14]` |

Lv7과 Lv9는 15종 visual catalog에는 남지만 기본 Run의 Stage chain에서는 사용하지 않는다.

아래 이름은 현재 테마와 Scale Shift 연결을 보여주는 seed다. 최종 15종의 정확한 Stage 배분, 명칭, 반지름과 점수는 `BallDefinition`/`StageDefinition` 데이터로 확정하며 플레이테스트에서 종류가 과도하다는 피드백이 나오면 축소할 수 있다.

### Ground

```text
Snowflake → Snowball → Big Snowball → Giant Snowball → Moon
```

초기 Spawn: 약 `6/s`

초기 `clear_score`: `4e6` (Giant Snowball 4개 Cashout 상당)

### Planetary

```text
Moon → Earth → Sun → Supernova → Galaxy
```

초기 Spawn: 약 `15/s`

초기 `clear_score`: `2e18` (Supernova 4개 Cashout 상당)

### Galactic

```text
Galaxy → Galaxy Cluster → Quasar → Event Horizon → Black Hole
```

초기 Spawn: 약 `35/s`

마지막 Stage이므로 `clear_score` 판정을 사용하지 않는다. 데이터 기본값은 `0`이다.

정확한 Stage 제한 시간과 `clear_score`는 밸런스 데이터에서 정한다.

---

## 15. Galactic 최종 Black Hole 국면

- 거대한 블랙홀이 좌우로 움직임
- 모든 공에 약한 인력을 적용
- 인력은 최대치를 제한
- 패들 조작의 의미를 없애지 않음
- 공을 모아 연쇄 머지를 유도할 수도 있음

이 절의 이동 Black Hole 맵 기믹은 별도 Stage나 BallDefinition이 아니라 Galactic 안에서 발동하는 Stage effect다. 발동 조건은 S8 Core/Content 계약에서 데이터 기반으로 확정한다. 발동 시 `Black Hole Phase Transition`으로 Frame과 실제 Play Field가 L2 `920`에서 L3 `1080`으로 함께 확장되고, 전환 중에만 spawn·timer·input을 잠근 뒤 같은 Galactic Stage gameplay를 재개한다.

Lv14 `Black Hole` Ball과 이동 Black Hole 맵 기믹은 이름과 motif를 공유하지만 서로 다른 gameplay entity다. Ball은 `BallDefinition(global_level=14)`과 일반 Merge/Clear 규칙을 따르고, 맵 기믹은 global level이 없는 Stage effect다. Lv14 Black Hole Ball을 만들면 다음 Stage 없이 Final Settlement와 Result로 진행한다.

### 최종 공 생성
`MAX SCALE / PERFECT CLEAR → Final Settlement → Result`

### Time Up
`Final Settlement → Result`

다음 Stage 점수컷 판정은 없다.

---

## 16. 아이템

아이템은 아이템을 품은 행성형 `Item Ball`로 Play Field에 등장하며, 현재 Stage의 **3단계 이상 Snowball**이 충돌할 때마다 점차 깨진다.

- 사람 기준 3단계 이상은 데이터의 0-based 표기로 `local_level >= 2`다.
- Stage의 local 5종 중 3단계, 4단계, 5단계 공은 모두 유효 damage를 줄 수 있다.
- 유효 충돌 한 번당 파괴 hit를 한 번만 반영하고, 같은 접촉의 frame 중복 damage를 막는다.
- hit가 누적될수록 균열·픽셀 파편 등 단계적인 damage 표현을 보여준다.
- 필요한 hit 수는 `ItemDefinition`의 플레이테스트 tuning 값이다.
- 마지막 hit에서 Item Ball 파괴와 아이템 획득을 한 번만 확정하고 CUT-IN을 요청한다.
- CUT-IN의 activation cue에 맞춰 효과를 시작하되, 연출 실패가 아이템 유실이나 중복 적용을 만들지 않게 한다.
- 1~2단계 공과 Paddle은 Item Ball을 즉시 획득하거나 파괴하지 않는다.
- Item Ball은 일반 Snowball Merge 대상이 아니다.
- Item Ball을 놓치면 효과 없이 제거한다.
- 아이템 효과는 Optional Item Layer에 남으며 Core Merge/Settlement 계약을 바꾸지 않는다.

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
