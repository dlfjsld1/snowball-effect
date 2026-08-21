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
- 현재 `stage_score / clear_score` 진행을 보여주는 점수 게이지

점수 영역 안에서 Stage Score와 Run Score를 어떻게 병기할지는 UI 튜닝 대상으로 두되, HUD의 최상위 정보 종류를 불필요하게 늘리지 않는다. 점수 게이지는 authoritative `stage_score`와 현재 Stage의 `clear_score`만 읽고 진행률을 표시하며 Clear를 직접 판정하지 않는다. 활성 아이템이 없을 때는 빈 슬롯 또는 비활성 상태로 표시한다.

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

일반 Snowball pair는 Merge 또는 물리 contact 중 하나로 처리한다.

- 현재 Stage chain에서 다음 공이 있는 같은 `global_level` 두 공은 Merge한다.
- 서로 다른 `global_level` pair는 원형 collision radius와 현재 velocity/mass를 사용해 물리적으로 반사·분리한다.
- 현재 Stage 최고공 두 개는 더 Merge하지 않고 같은 물리 contact 규칙으로 반사·분리한다.
- Merge하지 않는 contact pair는 접근 중일 때만 반사하고 penetration correction 뒤 분리해 붙음·반복 반사를 막는다.
- Item Ball과 이동 Black Hole runtime entity는 각자의 전용 충돌 계약을 유지하며 이 최고공 예외 규칙에 자동 포함하지 않는다.

합체 결과:

- 두 입력 공 제거
- 중간 위치에 상위 공 생성
- 결과 velocity는 두 입력의 mass-weighted average를 계승하고, 최종 runtime speed cap을 적용한다. 즉 무거운 입력 공의 기존 움직임을 조금 더 많이 반영하되, Merge가 공 속도를 무한히 키우지 않는다.
- 다음 물리 프레임부터 재머지 가능
- 점수 가치와 비주얼 레벨 상승
- Stage local Lv3·Lv4 최초 생성 CUT-IN 대상 여부 확인. Ground/Planetary local Lv4 생성은 즉시 Clear를 요청하지 않는다.

일반 Snowball 본체는 활성 Play Field 내부에서만 표시한다. 열린 하단을 통과해 Cashout되는 동안 simulation 공의 일부 또는 전체가 Play Field 밖 Stage World/기계 배경 위로 새어 보이지 않도록 렌더 경계에서 clip한다. Cashout popup·pixel debris 같은 별도 FX는 Presentation 계약에 따라 경계 근처에 표시할 수 있지만, 논리 공 본체와 같은 것으로 취급하지 않는다.

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

`base_color`는 BallDefinition의 기본 식별색 seed다. 다중 색상 텍스처·후광·파티클은 Presentation이 이 값을 보조 팔레트와 함께 해석해 표현한다. 실제 gameplay 공의 visual/collision 반지름은 현재 Stage의 local level로 계산한다. 각 Stage의 기본공은 반지름 `4`(지름 8 logical pixel)로 다시 시작하고, 같은 Stage 안에서 `4 → 8 → 16 → 32 → 64`로 2배씩 성장한다. 따라서 Ground의 최고공 Moon은 Ground에서 반지름 `64`지만 Planetary의 기본공으로 다시 등장할 때는 반지름 `4`이며, Planetary 최고공 Galaxy도 Galactic 진입 시 같은 방식으로 초기화된다. 화면과 충돌 반지름은 항상 같은 값을 사용한다. BallDefinition의 기존 `radius`는 catalog/fallback seed이며 Stage runtime 크기의 source of truth가 아니다. 질량은 전역 BallDefinition 데이터를 유지한다.

`fx_tier`는 일반 Merge/Cashout의 기본 연출 우선순위이며 전역 `BallDefinition`이 소유한다. Snowflake(Lv0)는 0, Snowball(Lv1)부터 Giant Snowball(Lv3)은 1, Moon(Lv4)부터 Supernova(Lv8)는 2, Nebula(Lv9)부터 Event Horizon(Lv13)은 3, Black Hole(Lv14)은 4를 사용한다. Moon과 Galaxy가 다음 Stage의 기본 공으로 재사용되어도 같은 전역 tier를 유지한다. 각 Stage의 local Lv3·Lv4 첫 생성은 Run당 한 번 `FIRST CONTACT` CUT-IN 대상이다.

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

Ground의 Moon과 Planetary의 Galaxy를 포함한 local Lv4도 일반 Active Cashout 대상이 될 수 있다. 생성 즉시 Stage Clear를 잠그지 않는다. Galactic의 Lv14 Black Hole은 아래 Black Hole 최종 국면 계약에 따라 이동 기믹으로 전환된다.

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

## 10. 최고 공 발견과 Stage Clear

현재 Stage의 local Lv3·Lv4 중 승인된 여섯 공을 만들면 committed Merge 결과를 기준으로 해당 `FIRST_CONTACT` identity의 Run 내 최초 생성 여부를 기록한다. 대상은 Ground의 Giant Snowball·Moon, Planetary의 Supernova·Galaxy, Galactic의 Event Horizon·Black Hole뿐이다. Moon과 Galaxy가 다음 Stage local Lv0로 재등장하는 경우는 새 발견이 아니다. Ground의 Moon과 Planetary의 Galaxy는 생성만으로 Stage Clear를 잠그지 않으며 일반 gameplay와 Active Cashout 대상에 남는다.

non-final Stage의 Clear는 tick의 Merge와 Active Cashout을 반영한 `stage_score >= clear_score` 순간 확정한다. 남은 시간과 local Lv4 생성 여부는 이 판정을 막지 않는다. 확정 뒤 `CLEAR_LOCKED → SETTLING`과 Final Settlement를 즉시 한 번 처리하고 `CLEARED`에 머문다. 축하 UI의 matching `NEXT STAGE(clear_id)` 요청이 도착한 뒤에만 Scale Shift를 시작한다. Galactic의 첫 Black Hole은 FIRST CONTACT 연출 뒤 별도 Black Hole 최종 국면 계약으로 전환한다.

---

## 11. Stage Clear — Score Clear

최고 공 생성은 Clear 조건이 아니다. non-final Stage는 `stage_score >= clear_score`가 되면 시간과 무관하게 `CLEAR_LOCKED` 후 `FINAL SETTLEMENT`로 이동한다. 정산을 기다리는 사용자 입력은 없으며, 정산 완료 뒤 `CLEARED` 축하 UI에서 matching `NEXT STAGE(clear_id)`를 받을 때까지 `SCALE SHIFT`만 보류한다.

```text
SCORE_CLEAR
→ CLEAR_LOCKED
→ SETTLING
→ CLEARED (matching NEXT STAGE 대기)
→ SHIFTING
```

`CLEAR_LOCKED`부터 `SHIFTING`이 끝날 때까지 timer, spawn, Paddle과 gameplay input은 잠긴다. `CLEARED` 대기는 플레이 시간을 소비하거나 Settlement를 늦추지 않는다.

### Clear 확인 snapshot과 ID

축하 UI는 Core나 `StageDefinition`을 직접 읽지 않고 Integration이 복사해 준 read-only Clear snapshot만 표시한다.

```text
stage_index
stage_display_name
stage_score
run_score
outcome = CLEARED
is_final_stage = false
```

- `clear_id`는 Final Settlement를 끝내고 `CLEARED`에서 확인을 기다리는 한 번의 성공을 식별한다.
- `shift_id`는 matching `NEXT STAGE(clear_id)`가 수락되어 `SHIFTING`에 들어간 뒤 Scale Shift 연출 완료를 식별한다.
- 두 ID는 별도 namespace다. 값을 비교하거나 한 ID를 다른 완료 callback에 사용하지 않는다.
- wrong/stale/duplicate `NEXT STAGE(clear_id)`는 아무 상태도 바꾸지 않는다.
- Retry, Main Screen, fresh Run은 열린 축하 UI와 pending Clear를 즉시 무효화한다. ID sequence는 같은 process lifetime에서 재사용하지 않아 이전 Run callback이 새 Run과 일치하지 않게 한다.
- Galactic, 실패, Time Up Result, Black Hole finale/Result에는 이 축하 UI를 열지 않는다.
- reduced-effects에서는 위치 이동·점멸을 생략하되 같은 정보와 실제 `NEXT STAGE` Button, focus, 1회 request 계약을 유지한다.

Time Up은 physics callback 단위가 아니라 정확한 Stage 제한시간 경계로 판정한다. tick이 남은 시간을 넘는다면 제한시간 전의 유효 gameplay 구간과 그 이후를 구분한다.

제한시간 전 유효 구간에서 발생한 Merge, discovery, 하단 통과만 commit한다. 해당 구간에서 성공한 Active Cashout은 정상적으로 Score와 Time Bonus를 주며, 보너스 후 시간이 양수면 `PLAYING`을 계속한다. 이는 제한시간 후 Cashout이 시간을 되살리는 것이 아니라 제한시간 직전의 유효한 성공이다.

유효 Cashout으로 시간이 연장되지 않으면 정확한 0초에 `TIME_UP_LOCKED`를 적용한다. 그 뒤의 하단 통과는 Active Cashout으로 인정하지 않고, 남은 공은 Time Bonus 없는 Final Settlement로 보낸다.

유효 구간의 local Lv4 생성은 종료 사유가 아니다. 유효 Merge와 Active Cashout을 반영한 뒤 clear score를 채우면 Score Clear가 Time Up보다 우선하고, clear score 미달이며 남은 시간이 없으면 Time Up을 확정한다.

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

non-final Stage가 clear score에 도달하면 Settlement를 한 번 처리하고 `CLEARED` 축하 UI를 연다. matching `NEXT STAGE(clear_id)` 요청을 한 번 수락한 뒤에만 별도 `shift_id`를 발급하고 Scale Shift를 시작한다. 확인 UI는 Clear 판정과 Settlement를 지연시키지 않으며 `CLEARED → SHIFTING` 경계만 연다.

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

초기 `clear_score`: `4e8` (Moon 4개 Cashout 상당)

### Planetary

```text
Moon → Earth → Sun → Supernova → Galaxy
```

초기 Spawn: 약 `15/s`

초기 `clear_score`: `4e25` (Galaxy 4개 Cashout 상당)

### Galactic

```text
Galaxy → Galaxy Cluster → Quasar → Event Horizon → Black Hole
```

초기 Spawn: 약 `35/s`

마지막 Stage이므로 `clear_score` 판정을 사용하지 않는다. 데이터 기본값은 `0`이다.

정확한 Stage 제한 시간과 `clear_score`는 밸런스 데이터에서 정한다.

---

## 15. Galactic 최종 Black Hole 국면

### 첫 번째 Black Hole

Galactic에서 첫 Lv14 `Black Hole` Ball을 만들면 FIRST CONTACT CUT-IN 뒤 Black Hole Phase 전환을 시작한다.

1. Merge 결과를 commit하고 생성된 Lv14 Ball을 첫 이동 Black Hole entity로 전환한다.
2. Run-scoped `galactic_black_hole` discovery를 확정하되, CUT-IN 완료 전에는 Black Hole Phase와 `phase_id`를 시작하지 않는다.
3. 같은 physics tick의 Cashout/종료 중재를 마친 뒤 FIRST_CONTACT pause lock을 먼저 수락하고 CUT-IN을 표시한다.
4. matching `(run_epoch, event_id)` CUT-IN 완료 뒤에만 기존 `Black Hole Phase Transition`을 시작해 Frame과 실제 Play Field를 L2 `880`에서 L3 `1040`으로 함께 확장한다.
5. CUT-IN부터 Phase 완료까지 spawn·timer·simulation·Paddle gameplay input을 잠그고, matching Phase 완료 후 같은 Galactic gameplay를 재개한다. CUT-IN과 Phase 사이에 gameplay를 한 frame 재개하지 않는다.

Frame의 바닥 장식과 Paddle/공의 실제 충돌 영역을 분리한다. 모든 Frame profile의 logical Play Field는 시각적 개구부보다 하단 `32 logical units` 위에서 끝나며, 남은 strip은 Cashout/프레임 안전 여백이다. Paddle은 회전한 전체 외곽이 이 logical 경계를 넘지 않도록 X·Y 모두 clamp한다.

전환된 Black Hole은 별도 Stage나 새 BallDefinition이 아니다. Lv14 Ball에서 유래했지만 일반 Snowball Merge/Cashout 대상에서 빠져 Black Hole 전용 runtime entity가 된다. Black Hole 외형을 유지하되 gameplay footprint는 사람 기준 Galactic 3단계 공인 Quasar, 즉 `local_level = 2`에 해당하는 크기를 기준으로 한다.

### 이동·흡수·인력

- Black Hole은 Play Field 안을 공처럼 이동한다.
- 주변 공이 가까워지면 제한된 인력으로 궤도를 휘게 한다.
- Galactic의 모든 일반 Snowball은 Black Hole 접촉 시 흡수된다. 이미 전환된 Black Hole runtime entity는 이 대상이 아니다.
- Black Hole은 다른 Black Hole을 제외한 어떤 공과도 Merge하지 않고 성장하지 않는다.
- 인력과 흡수는 패들 조작의 의미를 없애거나 공 속도를 폭주시켜서는 안 된다.
- Black Hole은 하단 Cashout 대상이 아니며, 다른 공과 달리 Play Field 하단에서 반사한다.

인력의 첫 플레이테스트 seed:

```text
influence_radius = 480 world units
maximum_pull_acceleration = 1200 world units/s²
pull_falloff = (1 - distance / influence_radius)²
```

영향 반경 밖에서는 인력을 적용하지 않는다. 안쪽에서는 중심에 가까울수록 강해지되 최대 가속도를 넘지 않으며, 최종 Ball runtime speed cap도 유지한다. 이 값들은 확정 밸런스가 아니라 S8 첫 플레이테스트용 데이터다.

두 Black Hole이 존재하면 일반 공은 각 Black Hole이 만드는 pull vector를 합산해서 받는다. 따라서 항상 정확히 2배가 되는 것은 아니다. 두 힘이 같은 방향이면 강해지고, 두 Black Hole 사이에서는 일부 상쇄될 수 있다. 합산 결과에는 별도 cap을 한 번 적용한다.

```text
ordinary_ball_pull_per_black_hole_max = 1200 world units/s²
ordinary_ball_total_pull_cap = 1500 world units/s²
black_hole_mutual_repulsion_max = 450 world units/s²
```

Black Hole끼리는 일반 Snowball 흡수 규칙을 적용하지 않고, 접촉 전에는 전용 척력으로 서로 멀어진다. 따라서 두 번째 Black Hole 생성만으로 자동 finale가 되지 않으며, 패들이 만든 충분한 상대속도로 실제 접촉해야 terminal이 시작된다. 접촉이 확정되면 일반 force simulation을 중단하고 terminal lock 뒤 연출용 회전·폭발로 전환한다. 세 수치 모두 초기 플레이테스트 seed다.

첫 Black Hole이 등장하는 순간의 `run_score`를 `black_hole_phase_score_baseline`으로 한 번 저장한다. 공을 흡수할 때는 해당 공의 Active Cashout 가치 전액을 직접 빼지 않고 다음 값을 `absorption_penalty`로 사용한다.

```text
raw_penalty = calculate_cashout_score(ball) × 0.125
phase_cap = black_hole_phase_score_baseline × 0.25
absorption_penalty = min(raw_penalty, phase_cap)

next_stage_score = stage_score - absorption_penalty
next_run_score = run_score - absorption_penalty

next_run_score <= 0
→ stage_score = max(0, next_stage_score)
→ run_score = 0
→ immediate FAILED / RUN END

otherwise
→ stage_score = max(0, next_stage_score)
→ run_score = next_run_score
```

이 비율은 첫 플레이테스트 seed다. 기존 전액 차감은 Galactic 기본공 Galaxy 하나의 `1e25` 가치가 직전 Planetary 최고공 정산으로 확보한 최소 Run Score와 같은 규모여서, 첫 Black Hole이 기본공 하나를 흡수하는 즉시 Run을 끝낼 수 있었다. `12.5%`는 최소 자금 기준으로 같은 기본공 약 8회의 손실 여지를 만들고, phase baseline의 `25%` 상한은 Galaxy Cluster·Quasar처럼 지수적으로 큰 공 한 개가 즉사 패널티가 되는 것을 막는다. 반대로 고가 공을 반복해서 잃으면 4회 안팎으로 Run을 끝낼 수 있어 위험은 유지한다. Time Bonus와 Cashout popup은 발생시키지 않는다.

Game Over 기준은 Stage마다 0으로 초기화되는 `stage_score`가 아니라 Run 전체 누적인 `run_score`다. 흡수 판정은 Black Hole과 공의 실제 접촉을 사용하며 별도 원거리 즉시 흡수 반경을 추가하지 않는다. 정확한 Black Hole 이동 속도는 tuning 대상으로 남긴다.

### 두 번째 Black Hole과 Run 종료

Black Hole Phase 중 두 번째 Lv14 Black Hole을 만들면 두 Black Hole이 같은 Play Field에 존재한다. 둘이 충돌하면 일반 Merge를 수행하지 않고 최종 시퀀스를 한 번만 잠근다.

```text
Two Black Holes Contact
→ spawn / timer / input lock
→ 서로를 끌어당기며 회전
→ Black Hole finale FX와 함께 폭발
→ gameplay HUD / UI 제거
→ SNOWBALL EFFECT 타이틀 표시
→ 타이틀 아래 CLEAR SCORE로 최종 run_score 표시
→ MAIN MENU 버튼 표시
→ RUN END
```

이 경로가 최종 성공 조건이며, 첫 Lv14 생성 즉시 Result로 가던 이전 계약을 대체한다. `MAIN MENU`는 메인 화면 복귀를 요청할 뿐 runtime state를 직접 초기화하지 않는다. 두 Black Hole 충돌과 타이틀 연출 사이에 추가 Stage Shift는 없다.

### Time Up
`Final Settlement → Result`

다음 Stage 점수컷 판정은 없다.

---

## 16. 아이템

아이템은 아이템을 품은 행성형 `Item Ball`로 Play Field에 등장한다. Item Ball은 각 Stage에서 임의의 시점에 한 번만 등장하며, 현재 Stage의 **3단계 이상 Snowball**이 충돌할 때마다 점차 깨진다. 정확한 등장 시간 범위는 플레이테스트 tuning 값이다.

- 사람 기준 3단계 이상은 데이터의 0-based 표기로 `local_level >= 2`다.
- Stage의 local 5종 중 3단계, 4단계, 5단계 공은 모두 유효 damage를 줄 수 있다.
- 유효 충돌 한 번당 파괴 hit를 한 번만 반영하고, 같은 접촉의 frame 중복 damage를 막는다.
- hit가 누적될수록 균열·픽셀 파편 등 단계적인 damage 표현을 보여준다.
- Item Ball은 유효 hit 5회에 파괴된다.
- 마지막 hit에서는 Item Ball 파괴를 한 번만 확정하고, 품고 있던 아이템 종류에 대응하는 `Item Orb`를 하나 생성한다. 이 시점에는 아직 아이템을 획득하거나 발동하지 않는다.
- Item Orb는 아이템별로 외형과 식별 정보를 구분한다.
- Item Orb의 visual radius, collision radius와 초기 speed는 현재 Stage의 3단계 Snowball(`local_level = 2`)과 같으며, 초기 velocity는 수직 아래 방향이다.
- Paddle이 Item Orb를 받으면 획득을 한 번 확정하고 CUT-IN을 요청한다. CUT-IN의 activation cue 뒤 해당 효과를 한 번 적용한다.
- Item Orb가 Paddle에 닿지 않고 열린 하단으로 빠지면 효과 없이 소멸한다. 해당 Stage에는 Item Ball이 다시 등장하지 않는다.
- CUT-IN이 실패하거나 skip되어도 이미 획득된 아이템은 안전한 fallback으로 한 번만 적용한다.
- 1~2단계 공과 Paddle은 Item Ball을 즉시 획득하거나 파괴하지 않는다.
- Item Ball은 일반 Snowball Merge 대상이 아니다.
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

각 Stage의 local 5종 중 마지막 두 단계가 고등급 공 강조 대상이다.

- local Lv3와 local Lv4를 해당 Run에서 처음 만들면 `FIRST CONTACT` 고등급 CUT-IN을 사용한다.
- 대상은 Ground의 `Giant Snowball`·`Moon`, Planetary의 `Supernova`·`Galaxy`, Galactic의 `Event Horizon`·`Black Hole`로 정확히 6종이다.
- CUT-IN에 표시되는 공은 실제 Merge 결과로 생성된 gameplay 공의 형태와 일치해야 한다.
- identity는 `ground_giant_snowball`, `ground_moon`, `planetary_supernova`, `planetary_galaxy`, `galactic_event_horizon`, `galactic_black_hole`로 고정한다.
- 한 identity는 한 Run에서 discovery를 정확히 한 번만 발행한다. Stage Shift는 기록을 유지하고 Retry/fresh Run은 새 `run_epoch`에서 다시 발견할 수 있다. Main 이동은 이전 Run을 무효화한다.
- discovery `event_id`는 process lifetime에서 증가하며 Retry/Main에서 재사용하지 않는다. `run_epoch`, `event_id`, Stage/global/local level, world position과 identity를 묶은 versioned payload가 유일한 CUT-IN 입력이다.

- 현재 physics tick의 Merge/Cashout/종료 판정을 먼저 확정
- Integration이 current Run과 `PLAYING`을 다시 확인하고 pause lock 수락
- pause 수락 뒤에만 현재 장면 전체 freeze와 visible CUT-IN
- Play Field와 Stage World 전체 dim
- Pixel Machine 패널 진입
- 공 이름 / 이미지 / VALUE 또는 효과
- 빠르게 퇴장
- matching `event_id`와 `run_epoch` 완료만 수락
- 일반 5종은 즉시 같은 gameplay 재개, 첫 Black Hole은 gameplay 재개 없이 기존 S8 Phase로 handoff

pause lock은 SceneTree 전체 pause가 아니다. CUT-IN Tween과 Retry/Main cleanup은 계속 동작하되 timer, spawn, simulation commit, Paddle physics와 gameplay input을 잠근다. 같은 tick의 중재 결과가 `CLEAR_LOCKED`, `TIME_UP_LOCKED`, `FAILED`, `RUN_ENDED`, Result 또는 Shift면 해당 discovery를 화면에 열지 않고 authoritative 결과를 우선한다. wrong/stale/duplicate 완료는 gameplay resume이나 Black Hole Phase를 만들지 않는다. Retry/Main/fresh Run은 열린 Panel과 queue를 숨기고 이전 callback을 무효화한다.

초기 총 길이:

```text
0.45 ~ 0.70초
```

Giant Snowball, Moon, Supernova, Galaxy, Event Horizon의 CUT-IN 종료 뒤에는 gameplay를 재개한다. 첫 Black Hole은 matching CUT-IN 종료 뒤에만 같은 Galactic 안의 Black Hole Phase 전환을 이어서 실행한다. Presentation은 resume이나 Phase를 직접 실행하지 않고 `(event_id, run_epoch)` 완료만 반환한다.

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

### Known balancing observation — Controllable Merge and Stage Shift pacing

> **이 관찰에서 local Lv4 즉시 Clear 제거는 유지한다. 2026-08-20의 자동 Scale Shift 방향은 이후 최신 사용자 지시로 대체됐다. 현재는 non-final clear score 도달 시 Clear와 Settlement를 즉시 확정하고 `NEXT STAGE` 확인 뒤 Shift한다.**

현재 플레이에서 같은 등급 공의 자동 Merge가 연쇄적으로 일어나고 최고공 또는 clear score에 너무 빨리 도달하면, 플레이어는 패들로 합체를 만들었다기보다 게임이 스스로 Phase Shift했다고 느낄 수 있다. 이는 Snowball Effect가 지향하는 `통제 가능한 폭주`와 어긋날 위험이 있다.

`최고 공 생성 → Clear Lock → Settlement → Clear 확인 → Scale Shift`는 최고 공 생성 자체에는 적용하지 않는다. Ground/Planetary의 local Lv4는 FIRST CONTACT 뒤 gameplay를 계속하며, clear score가 도달했을 때만 Clear를 잠그고 Settlement 뒤 확인 UI를 연다.

향후 검토의 기준 루프는 다음과 같다.

```text
패들 조작으로 궤도를 만든다
→ 합칠 두 공을 예측한다
→ 의도한 Merge가 성공한다
→ 성장·점수·밀도가 커진다
→ KEEP 또는 Cashout을 선택한다
→ 충분히 축적된 성공 뒤 Stage Shift가 온다
```

검토할 후보는 가벼운 스침의 즉시 Merge를 줄이고, 최근 Paddle 타격·충돌 강도·짧은 접촉 유지 같은 조건으로 플레이어가 만든 충돌이 더 명확하게 Merge로 이어지게 하는 방식이다. 단, 어느 한 조건도 아직 채택하지 않는다. Merge가 너무 어려워져 공 튕기기만 남는 결과도 피해야 한다.

동시에 Stage Shift는 일반 Merge보다 훨씬 큰 성취로 읽혀야 한다. 이후 밸런스 플레이테스트에서 Stage별 clear score, Spawn density, time economy, 고레벨 Merge 빈도를 함께 조정해 `너무 빠른 자동 Shift`와 `첫 Shift가 지나치게 늦는 문제` 사이를 확인한다. Clear/Score Clear의 명확한 UI·FX 피드백은 S6 Presentation 후보로 별도 검토한다.

플레이테스트에서는 단순 Merge 수뿐 아니라 다음을 기록한다.

- 플레이어가 "저 둘을 합치려 했다"고 설명하는지
- 첫 의도적 Merge와 첫 Stage Shift까지 걸린 시간
- Shift가 자신의 성공인지 자동 진행인지 느낀 이유
- 다음 판에서 개선하려는 조작 목표가 있는지

**상태: Known balancing observation / revisit after current planned gameplay and presentation work.**

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

### Future Presentation candidate — Black Hole tidal Snowball deformation

> **향후 시각 후보 메모이며 현재 S8 구현 계약, 충돌 규칙 또는 shader 구현 승인이 아니다.**

Black Hole의 인력 범위 안에서 궤도가 휘는 일반 Snowball을 Black Hole 방향으로 늘이거나 반대 축으로 눌러, tidal force를 시각적으로 강조하는 표현을 후보로 둔다. 일반 Snowball 본체가 MultiMesh로 렌더되더라도 instance별 비균일 scale/회전 또는 shared shader custom data로 표현할 수 있다.

이 후보가 채택되어도 gameplay 판정은 nominal 원형을 유지한다.

- Core 위치와 velocity가 실제 궤도를 결정한다.
- Merge, Paddle, 벽, Black Hole contact는 공 중심과 기존 nominal collision radius를 사용한다.
- Presentation deformation은 collision shape, mass, score, 흡수 조건을 변경하지 않는다.
- 흡수 commit 뒤의 과장된 늘어남·축소는 logical ball과 분리된 terminal FX로만 검토한다.

정확한 stretch ratio, 면적 보존 여부, 영향 falloff, 두 Black Hole 사이의 합성 방식과 reduced-effects 표현은 아직 결정하지 않는다. 시각과 원형 collision이 지나치게 어긋나지 않는 범위에서 S8/S6 통합 플레이테스트 후 채택 여부를 판단한다.

**상태: Future Presentation candidate. 구현 승인 아님.**
