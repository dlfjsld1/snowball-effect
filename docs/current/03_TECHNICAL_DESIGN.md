# Snowball Effect — Technical Design

## 1. 기술 목표

- Godot 4.x Stable
- 브라우저 Web Export
- 1600×900 기준, 비율 유지
- 데스크톱 브라우저 60 FPS 목표
- 최소 성능 목표: 30 FPS 이상
- Web 동시 활성 논리 공 500개 필수 stress와 1,000개 stretch/torture 측정
- 장식 파티클은 논리 공과 분리
- 긴 프레임 스파이크를 최소화

---

## 2. 핵심 결정

### 사용

- 중앙 `BallSimulationManager`
- 구조화된 배열 기반 공 데이터
- Uniform Grid / Spatial Hash
- 비활성 인덱스 재사용
- 단일 또는 소수 렌더러
- GPUParticles2D는 장식
- 데이터 중심 Stage/Ball/Item 정의
- 수동 원형 충돌과 반사

### 사용하지 않음

- 공마다 `RigidBody2D`
- 공마다 개별 `_physics_process`
- 모든 공 쌍 전수 비교
- 게임 규칙을 GPU 파티클에 위임
- 프레임마다 공 객체 생성·삭제
- 실제 질량·마찰·회전 물리

---

## 3. 전체 아키텍처

```text
GameManager
 ├─ 입력/게임 상태 조율
 ├─ 전체 누적 점수/결과
 ├─ Run 종료
 └─ 시스템 신호 연결

StageManager
 ├─ 현재 Stage
 ├─ Stage timer / base_time
 ├─ Stage score / clear_score
 ├─ 기본/최고 global_level
 ├─ 생성량
 ├─ Top Ball Clear
 ├─ Time Up / Final Settlement / Score Clear
 ├─ Scale Shift
 └─ 블랙홀 설정

BallSimulationManager
 ├─ 공 데이터 저장
 ├─ 이동 적분
 ├─ 벽/패들/점수 구역 판정
 ├─ 공간 그리드 재구축
 ├─ 합체 후보 탐색
 ├─ 합체 실행
 └─ 블랙홀/아이템 힘 적용

BallRenderer
 ├─ 저레벨 일괄 렌더
 ├─ 고레벨 시각 표현
 └─ 레벨/특수 타입별 외형

Paddle
 ├─ 입력
 ├─ 위치/회전
 └─ 반사 계산용 데이터 노출

ItemManager
 ├─ 아이템 생성
 ├─ Ball 충돌·내구도 기반 획득 판정
 └─ 활성 효과/지속시간

EffectManager
 ├─ 파티클
 ├─ 점수 팝업
 ├─ 카메라 흔들림
 ├─ 히트스톱
 └─ 발표 UI

BackgroundManager
 ├─ 스테이지 배경
 └─ 블랙홀 시각/위치

AudioManager
 ├─ 합체음
 ├─ 회수음
 ├─ 아이템음
 └─ 스테이지 전환음
```

---


## 3.1 전체 화면과 논리 Play Field 분리

`Viewport` 전체와 공 시뮬레이션 Rect를 동일하게 취급하지 않는다.

```text
Viewport 1600×900
 ├─ Stage World / Machine Frame
 └─ PlayFieldRect
      ├─ balls
      ├─ paddle
      ├─ items
      └─ score zone
```

`BallSimulationManager`는 명시적인 `Rect2 play_field_rect`를 사용한다.

벽 반사, 스폰 X 범위, 패들 이동 제한, 점수 구역은 모두 이 Rect 기준이다.

Stage World 배경과 기계 프레임은 논리 충돌 범위를 넓히지 않는다.

---

## 3.2 Presentation 계층

추가 책임:

```text
PresentationManager
 ├─ global dim
 ├─ short simulation presentation pause
 ├─ event priority
 ├─ CUT-IN cooldown
 └─ Scale Shift presentation coordination

CutInController
 ├─ enter / hold / exit animation
 ├─ title / sprite / value binding
 └─ completion signal
```

일반 파티클은 `EffectManager`가 담당한다.

`EffectManager`가 스스로 게임을 멈추거나 Stage를 바꾸지 않는다.

`StageManager`는 Scale Shift의 게임 상태 변경을 결정하고,
Presentation 계층은 이를 화면에 표현한다.


## 4. 공 데이터

Godot의 PackedArray는 구조체 배열을 직접 제공하지 않으므로, MVP에서는 SoA(Structure of Arrays) 형태를 권장한다.

```gdscript
var positions: PackedVector2Array
var velocities: PackedVector2Array
var radii: PackedFloat32Array
var global_levels: PackedInt32Array
var score_values: PackedFloat64Array
var active_flags: PackedByteArray
var special_types: PackedByteArray
var merge_locks: PackedByteArray
```

보조 인덱스:

```gdscript
var active_indices: Array[int]
var free_indices: Array[int]
var indices_by_level: Dictionary
```

### 특수 타입 예시

```gdscript
enum BallSpecial {
    NORMAL,
    FIRE
}
```

### 공 슬롯 생성

1. `free_indices`가 있으면 재사용
2. 없으면 모든 배열 뒤에 슬롯 추가
3. 값을 초기화
4. 활성 인덱스에 추가

### 공 제거

- `active_flags[index] = 0`
- `free_indices.push_back(index)`
- 활성 인덱스는 swap-remove 또는 다음 정리 주기에 압축

매 제거마다 큰 배열 전체를 재구성하지 않는다.

---

## 4.1 Arcade velocity 계약

기본 공 적분에는 지속적인 아래 방향 acceleration을 더하지 않는다.

```text
default gravity = 0
position += velocity * delta
```

Spawn은 아래쪽 반구 안의 방향과 공통 Spawn speed tuning을 결합해 초기 velocity를 만든다. 각도 범위, 분포, 초기 speed의 최소·최대값은 플레이테스트 대상이다.

현재 Lv1의 physical/design reference는 일반적인 눈송이 낙하속도 약 `1.0 m/s`다. 이는 현실의 움직임 인상을 위한 reference이며 Godot world unit과 직접 변환하지 않는다. 공간은 `1 world unit = 1 logical pixel`, 시간은 second, runtime velocity는 world units/s로 관리한다. `GameManager`의 `lv1_spawn_speed_world_units_per_second`는 한 곳에서 조정하는 게임-space tuning 값이고, 현재 첫 플레이테스트 값은 `160 world units/s`다. 현재 구현 전 component range `x = -50~50`, `y = 40~100 world units/s`의 speed magnitude는 약 `40~112 world units/s`였으므로 새 Lv1 Spawn은 이를 낮추지 않는다.

Lv1 radius는 visual과 collision이 같은 `4 world units`(diameter 8)를 사용한다. 이는 현재 Shared Skeleton의 승인된 기본 크기다. `160 world units/s` Spawn speed와 Paddle max speed cap은 별도 플레이테스트 tuning으로 유지한다.

`base_speed` 또는 Spawn speed는 초기 velocity의 기준이다. runtime velocity를 매 tick 해당 값으로 정규화하거나 덮어쓰지 않는다. Paddle, 명시적인 벽 규칙, Merge, Stage effect, Item, 특수 상태는 runtime direction과 speed를 바꿀 수 있다.

현재 버전은 `global_level`별 base speed 차이를 사용하지 않는다. 향후 `BallDefinition`에 등급별 base speed를 도입할 수 있지만, 그 값도 Spawn 기준이며 runtime speed 고정값이 아니다.

---

## 5. 시뮬레이션 순서

권장 `_physics_process(delta)` 순서:

1. 게임 상태 확인
2. 명시적으로 활성화된 스테이지/아이템 전역 힘 계산 — 기본 공에는 지속 중력 없음
3. 공 이동 적분
4. 좌·우·상단 반사 경계 처리
5. 패들 후보 공 판정 및 반사
6. 점수 구역 처리
7. 공간 그리드 재구축
8. 같은 레벨 합체 후보 검사
9. 합체 명령 큐 실행
10. 활성 인덱스 정리
11. 렌더러에 최신 데이터 전달
12. 디버그 지표 갱신

합체 탐색 중 배열을 즉시 크게 변경하지 않는다.  
합체 요청을 큐에 모은 뒤 검사 종료 후 적용한다.

하단에는 반사 벽을 만들지 않는다. 아래 방향으로 열린 경계를 통과한 공만 Active Cashout command에 넣는다.

---

## 6. 공간 그리드

### 목적

공 N개를 모든 쌍으로 비교하면 O(N²)이다.  
화면을 고정 크기 셀로 나누어 주변 후보만 검사한다.

### 자료구조

플레이 영역이 고정이므로 Dictionary 기반 해시보다 1차원 배열 그리드가 더 단순할 수 있다.

```text
cell_x = floor(position.x / cell_size)
cell_y = floor(position.y / cell_size)
cell_index = cell_y * columns + cell_x
```

각 셀은 공 인덱스 목록을 가진다.

### 레벨 분리

같은 레벨끼리만 합체하므로 다음 중 하나를 사용한다.

```text
grid[cell][level] -> indices
```

또는

```text
grids_by_level[level][cell] -> indices
```

실제 구현은 메모리 할당을 줄이는 형태를 선택한다.

### 셀 크기

- 현재 스테이지 기본~중간 공의 지름 기준
- 지나치게 작으면 셀 수와 등록 비용 증가
- 지나치게 크면 후보 수 증가

고레벨 공은 개수가 적으므로 더 넓은 이웃 범위를 검사하거나 별도 목록으로 처리 가능하다.

### 중복 쌍 방지

- `b_index > a_index` 조건
- 각 공은 한 프레임에 한 번만 합체
- `merge_locks`로 예약

---

## 7. 패들 충돌

### 조작 입력

Mouse 입력은 Viewport의 raw pixel을 world X로 그대로 사용하지 않는다. 가장 최근 Mouse position을 Canvas/world 좌표로 변환한 뒤 Play Field 기준 logical X를 구하고, physics tick 시작 시 현재 Paddle center X에 직접 반영한 다음 회전된 Paddle extent를 고려해 field clamp한다. Mouse target 추적 speed cap은 폐기한다.

Paddle simulation은 매 physics tick에 다음 두 transform을 가진다.

```text
previous_transform = 직전 physics tick에서 확정된 Paddle transform
current_transform  = 이번 tick의 Mouse/Keyboard/rotation 입력을 적용해 확정한 transform
```

Mouse는 `current_transform.position.x`를 직접 정한다. Keyboard fallback은 기존 속도 적분으로 current transform을 정해도 된다. 이후 collision system은 입력 source가 아니라 동일한 previous/current transform만 소비한다.

Paddle 중심 선형속도는 `(current_position - previous_position) / physics_delta`로 계산한다. 각속도는 이번 tick에 실제 적용된 signed angle displacement를 `physics_delta`로 나눈다. angle을 `-PI..PI` 등가 범위로 정규화하더라도 ±PI 경계를 넘은 정규화 결과만 빼서 각속도를 계산하지 않는다. 정규화 전 signed displacement 또는 동등한 unwrapped angle을 사용한다.

Mouse Wheel은 tuning 가능한 `mouse_wheel_step_degrees`만큼 기존 Paddle angle state를 변경한다. `←/→`도 같은 angle state를 변경하며 angle min/max clamp는 두지 않는다. 구현은 표현상 동일한 범위로 angle을 정규화할 수 있지만 연속 회전 입력을 멈추지 않는다. `A/D`와 `←/→` 키보드 조작은 A/B 비교용 fallback으로 유지한다. 별도의 마우스 반사 경로나 별도의 rotation state를 만들지 않는다.

공이 수천 개일 수 있으므로 모든 공에 Node/PhysicsBody를 만들지 않고 중앙 `BallSimulationManager` 배열에서 Paddle 하나와 각 활성 공의 후보를 검사한다. Paddle 대 공 검사는 O(N)이며 공 쌍 O(N²) 구조를 만들지 않는다.

### Broad Phase

- previous/current Paddle transform 사이의 보수적인 swept bound를 만든다.
- 공의 이번 tick trajectory가 ball radius만큼 확장한 swept bound와 겹치는 경우만 narrow phase 후보로 둔다.

### Narrow Phase

패들은 양면 회전 OBB다. 권장 최소 continuous collision 방식은 **translation relative sweep + rotation adaptive substep**의 혼합이다.

1. 공의 tick 시작 위치와 velocity로 ball trajectory를 만든다.
2. Paddle previous/current transform을 준비한다.
3. Paddle 회전량을 signed/unwrapped angle로 보간한다. 회전 substep 수는 Paddle 끝점의 회전 이동량이 collision tolerance를 넘지 않도록 정한다.
4. 각 회전 구간 안에서는 Paddle translation과 ball trajectory의 상대운동을 연속 sweep으로 계산한다. circle을 ball radius만큼 확장한 OBB에 대한 segment/TOI query와 동등한 방법을 사용한다.
5. 모든 구간에서 가장 이른 유효 TOI를 선택하고 그 시점의 interpolated Paddle transform, contact point, 양면 outward normal을 사용한다.
6. 시작/끝 overlap과 Paddle 내부에서 시작한 공도 fallback contact로 처리해 penetration 상태를 탈출시킨다.
7. TOI까지 이동한 뒤 반사하고 남은 tick 시간을 새 velocity로 진행한다.

translation 거리를 작은 고정 step으로만 나누는 방식은 Mouse 직접 매핑 시 지나치게 많은 substep을 요구하므로 기본안으로 사용하지 않는다. 반대로 current-frame OBB overlap만 사용하는 방식도 작은 Lv1 공에서 translation/rotation tunneling을 놓치므로 폐기한다. 회전만 adaptive substep하고 각 구간의 translation은 sweep으로 처리하면 현재 해커톤 규모에서 정확도와 Web 비용을 함께 통제할 수 있다.

같은 Paddle sweep에서 한 공의 가장 이른 접촉을 한 번만 commit한다. 반사 후 contact normal 방향으로 separation epsilon을 적용하고, 공이 해당 면에서 분리되기 전에는 같은 접촉을 다시 반사하지 않는다. 이는 양면에 동일하게 적용한다.

direct Mouse sweep 또는 Merge 직후 큰 공 때문에 tick 시작 시 이미 Paddle과 겹친 경우에도, 단순히 공 중심 근처의 면을 고르지 않는다. Paddle의 실제 sweep 방향에서 얻은 entry normal을 유지하고 **현재 tick의 최종 Paddle transform** 기준으로 공을 surface 바깥으로 보정한다. 따라서 Paddle이 큰 공을 가로질러 이동해도 공이 반대/내부 면으로 튀거나 다음 tick까지 Paddle 내부에 남지 않는다.

### 회전 접촉점 속도

TOI 시점의 Paddle center에서 contact point까지의 world-space 벡터를 `r`이라 하고, signed angular velocity를 `omega`라 한다.

```text
linear_velocity = (current_center - previous_center) / physics_delta
angular_velocity = signed_angle_displacement / physics_delta
angular_contact_velocity = omega * Vector2(-r.y, r.x)
raw_contact_velocity = linear_velocity + angular_contact_velocity
impact_velocity = clamp_length(raw_contact_velocity, maximum_impact_velocity)
```

Godot 2D의 회전 부호와 화면 좌표계에 맞춰 동일한 cross-product 결과를 사용한다. Paddle 끝은 중심보다 `|r|`가 크므로 같은 angular velocity에서도 더 큰 표면속도를 갖고, 회전 방향이 바뀌면 angular contribution 방향도 바뀐다. Wheel event delta 자체를 impact로 사용하지 않고 physics tick에 실제 적용된 angle displacement로만 계산한다.

impact cap은 linear/angular contribution을 각각 자른 뒤 더하는 방식이 아니라 **합산한 raw contact velocity에 한 번** 적용한다. 이후 순서는 다음과 같다.

1. capped `impact_velocity`로 ball relative velocity 계산
2. TOI contact normal을 향해 접근 중인지 판정
3. relative velocity 반사
4. capped impact velocity와 contact-position shaping을 기존 반사 계약에 따라 반영
5. 마지막에 ball runtime speed cap 적용

어떤 반사 항에서도 uncapped linear/angular velocity를 다시 더하지 않는다. Mouse 직접 위치 반영으로 center velocity가 커져도 impact와 최종 ball speed는 별도 tuning으로 제한된다. `base_speed`로 되돌리지는 않는다.

---

## 8. 공 합체

### 판정

```gdscript
var min_distance := radii[a] + radii[b]
if positions[a].distance_squared_to(positions[b]) <= min_distance * min_distance:
    request_merge(a, b)
```

Merge commit은 현재 `StageDefinition.local_ball_levels`에서 입력 `global_level`의 index를 찾고 다음 항목을 결과 level로 사용한다. 기본 Run은 Planetary `[4, 5, 6, 8, 10]`처럼 비연속 사슬을 허용하므로 `global_level + 1`을 결과로 계산하지 않는다. 입력 level이 현재 Stage 목록에 없거나 마지막 항목이면 요청을 거부한다.

### 속도

Merge 결과 velocity는 두 입력의 mass-weighted average를 사용한다.

```text
result_velocity = (mass_a * velocity_a + mass_b * velocity_b) / (mass_a + mass_b)
result_velocity = clamp_length(result_velocity, maximum_ball_runtime_speed)
```

`mass_a + mass_b`가 유효하지 않은 데이터인 경우에만 단순 평균을 fallback으로 사용한다. 현재 initial catalog에서는 같은 level 두 공의 mass가 같으므로 결과는 두 velocity의 평균과 같다. 다만 데이터가 바뀌어도 공식 자체는 그대로 유지된다.

`maximum_ball_runtime_speed`의 첫 tuning 값은 기존 Paddle final reflection cap과 동일한 `900 world units/s`다. 이는 Spawn/base speed로 결과 속도를 덮어쓰는 규칙이 아니며, Merge 후 폭주만 막는다.

### 연쇄 합체

새로 생성된 공은 같은 프레임에 다시 합체시키지 않는다.  
다음 물리 프레임부터 합체 가능하게 하여 중복과 무한 연쇄를 피한다.

화면상 연쇄감은 파티클과 짧은 간격으로 충분히 느껴진다.

---

## 9. 점수 표현

MVP에서는 `float`/64비트 실수로 점수를 관리한다.

필요 기능:

```gdscript
func format_score(value: float) -> String
```

- 1,000 미만: 정수
- 이후 3자리 단위 접미사
- 접미사 범위 초과 시 과학적 표기
- 소수점 0~2자리
- NaN/Infinity 방어

점수는 데이터 정의에서 읽는다.  
합체 과정의 보존 법칙을 계산하지 않는다.

---

## 10. 렌더링 전략

### 10.1 현재 기준선

하나의 `Node2D`가 `_draw()`로 활성 공을 그린다.

- 저레벨: 원 또는 작은 텍스처
- 높은 레벨: 색상, 외곽선, 내부 무늬를 레벨 데이터로 구분
- 매 프레임 `queue_redraw()`

이 방식으로 S4 Web 기준선을 측정했다. 현재 경로는 동작 기준선과 A/B fallback으로 유지하되, 일반 Snowball의 production 목표 렌더러로는 사용하지 않는다.

### 10.2 승인된 일반 Snowball MultiMesh 계획

일반 Snowball 본체는 `MultiMeshInstance2D` 기반의 레벨별 batch로 전환한다. 이 결정은 렌더링 전용이며 중앙 SoA simulation, collision radius, Merge, Cashout과 slot reuse 계약을 변경하지 않는다.

- 현재 Stage에서 활성인 일반 `global_level`마다 재사용 가능한 MultiMesh batch 하나를 둔다. 서로 다른 텍스처/머티리얼을 한 batch에 억지로 섞지 않는다.
- 위치, 회전, runtime radius 기반 scale, tint/alpha와 필요한 최소 presentation custom data만 instance 데이터로 갱신한다.
- Stage 전환에서는 현재 Stage의 ordered level과 텍스처 binding을 교체하고 batch/buffer를 재사용한다.
- 공 이미지가 완성되기 전에는 중앙이 정렬된 procedural placeholder 또는 임시 투명 Texture2D로 구현·검증할 수 있다. 최종 Texture2D의 source pixel 크기는 gameplay radius의 source of truth가 아니다.
- 일반 Snowball의 후광·Merge burst·Cashout debris 같은 일시적 효과는 공 본체 batch에 합치지 않고 기존 FX/pool 계층에서 처리한다.

적용 대상은 Item Ball과 Lv14 Black Hole Ball/전환된 Black Hole runtime entity를 제외한 일반 Snowball이다. Item Ball은 균열·파괴 상태를, Black Hole은 고유 ring/왜곡/흡수 표현을 가지므로 전용 렌더러를 유지한다. Galactic에서는 일반 Lv10~13 batch와 Black Hole 전용 렌더러가 함께 존재한다.

Core는 render snapshot을 읽어 batch를 구성하고 gameplay state를 변경하지 않는다. Presentation은 level별 Texture2D와 머티리얼 표현을 제공할 수 있지만 simulation 내부 배열을 직접 읽거나 수정하지 않는다. 최종 asset atlas는 필수 선행 조건이 아니며 별도 텍스처 방식으로 먼저 연결할 수 있다.

### 10.3 구현·검증 경계

정식 구현은 별도 활성 Goal에서 수행한다. 기존 `_draw()/draw_circle` 경로와 동일한 위치·크기·가시 개수를 먼저 비교하고, 실제 Web에서 500개 Merge ON 필수 부하와 1,000개 stretch를 측정한다. HUD·Stage World·대표 FX를 켠 통합 측정 전에는 저사양 Web 보장을 선언하지 않는다.

2026-08-12 local-only Web prototype에서는 실제 Stage 피라미드 분포(`80/12/5/2/1%`)와 Merge ON 조건에서 500개는 기존 draw와 MultiMesh 모두 평균/최저 60 FPS였고, 1,000개는 기존 draw 평균 `54.9`/최저 `36.9 FPS`, MultiMesh 평균/최저 `60 FPS`였다. 이는 방향 선택 근거이며 공용 Quality Gate Evidence나 구현 완료 증거가 아니다.

### 10.4 고레벨 표현

고레벨 공은 크기만 무한히 키우지 않는다.

- 후광
- 회전 내부 텍스처
- 꼬리
- 외곽 링
- 화면 왜곡
- 색 대비

로 위계를 만든다.

일반 고레벨 Snowball도 본체는 MultiMesh에 남길 수 있으며, 특별한 후광·링·꼬리는 별도 overlay/FX로 결합한다. 일반 본체 전체를 개별 Sprite/Node로 되돌리는 방식은 기본안으로 사용하지 않는다.

게임play 공의 runtime 반지름은 `StageDefinition.local_ball_levels`에서 global level의 local index를 찾아 `4 * 2 ^ local_level`로 계산한다. 이 값은 renderer와 collision이 함께 사용한다. 따라서 Stage가 바뀌면 새 Stage의 local Lv0는 다시 반지름 `4`가 되고, 이전 Stage top과 같은 global 공이라도 새 Stage에서는 기본 크기로 시작한다. `visual_radius_scale`는 이후 Scale Shift 화면 연출용 예약값이며 visual/collision 불일치를 만드는 용도로 사용하지 않는다.

---

## 11. 이펙트 예산

장식 파티클은 논리 객체가 아니다.

### 이벤트 등급

| 등급 | 예 |
|---|---|
| 0 | 기본 공 합체 |
| 1 | 중간 공 합체 |
| 2 | 스테이지 상위 공 합체 |
| 3 | 최고 공 생성 / 고레벨 회수 |
| 4 | Scale Shift |

낮은 등급 이벤트가 한 프레임에 너무 많이 발생하면:

- 파티클 수 축소
- 사운드 통합
- 팝업 생략
- 같은 위치 이벤트 합산

높은 등급은 반드시 보이게 한다.

### 히트스톱

전체 트리를 매번 멈추지 말고, `GameManager` 또는 시뮬레이션 시간 스케일을 짧게 제어한다.

- 중간: 사용하지 않음 또는 0.02초
- 높은 합체: 0.05초
- Scale Shift: 0.1~0.2초

연속 이벤트가 시간을 과도하게 멈추지 않도록 쿨다운 또는 최대 누적을 둔다.

---


## 11.1 CUT-IN 기술 규칙

CUT-IN은 별도 게임 씬 전환이 아니다.

현재 장면 위의 최상단 CanvasLayer에서 처리한다.

권장 순서:

```text
game event committed
→ request_cut_in(event)
→ presentation priority check
→ simulation presentation pause
→ dim overlay fade
→ panel enter
→ hold
→ panel exit
→ dim restore
→ simulation resume
```

중요:

- 실제 게임 이벤트는 CUT-IN 시작 전에 이미 확정
- CUT-IN 애니메이션 실패가 게임 상태를 되돌리지 않음
- 연속 이벤트를 무한 큐잉하지 않음
- Scale Shift가 일반 CUT-IN보다 높은 우선순위
- 입력 눌림 상태가 pause/resume 후 꼬이지 않는지 검증
- Tween/AnimationPlayer는 Web Export에서 검증

시간 목표:

```text
normal cut-in: 0.45~0.70s
scale shift: up to about 0.8~1.0s
```


## 12. 아이템 기술

아이템 행성 수는 적으므로 개별 `Area2D` 또는 단순 Node2D 사용 가능하다. 논리 공 배열에 섞지 않는다.

### 획득

- Stage 진입마다 Item Ball 등장 가능 횟수를 1회로 초기화하고, 정해진 tuning 범위 안에서 임의의 등장 시점을 하나 선택한다. 등장·파괴·실패 뒤 같은 Stage에서 재스폰하지 않는다.
- Item Ball과 logical Snowball의 원 충돌 후보를 중앙 simulation 위치 snapshot으로 검사
- `local_level = current_stage.local_ball_levels.find(ball.global_level)`로 계산하며 `-1`은 Stage data/runtime 오류로 처리
- `local_level >= 2`인 접촉만 유효 damage; 더 높은 단계도 같은 규칙으로 damage 가능
- 한 contact pair는 분리되기 전까지 damage 한 번만 commit
- 유효 hit마다 damage count를 올리고 Presentation에 균열 단계 이벤트 전달
- `required_break_hits = 5`에 도달하면 broken lock을 한 번만 확정하고 Item Ball을 제거한 뒤 해당 `item_type`의 Item Orb를 하나 생성
- 파괴와 획득을 별도 상태로 관리하며, Item Ball 파괴 시에는 pending activation을 만들지 않음
- Item Orb의 visual/collision radius와 초기 speed는 현재 Stage `local_level = 2` 공의 runtime 기준값을 사용하고, 초기 velocity는 수직 아래 방향으로 설정
- Paddle과 Item Orb의 접촉을 한 번 commit하면 collected lock과 pending activation을 확정하고 CUT-IN을 요청
- Item Orb가 열린 하단을 통과하면 missed 상태로 제거하며 activation을 만들지 않음
- CUT-IN activation cue에서 ItemManager가 효과를 시작하며, cue가 실패하거나 skip되면 안전한 fallback으로 한 번 적용
- 획득·재획득·만료·Retry 때 read-only active item snapshot을 HUD에 전달

### Blizzard

`StageManager.current_spawn_rate * multiplier`

### Magnet

공간 그리드에서 같은 레벨 이웃 한두 개만 선택해 약한 힘 적용.  
모든 동일 레벨 쌍에 힘을 계산하지 않는다.

### Fire

공의 `special_type` 플래그 변경.  
렌더러와 점수 계산이 이 플래그를 참조한다.

---

## 13. 블랙홀 기술

첫 Lv14 Black Hole Ball 생성은 일반 Top Ball Clear를 요청하지 않는다. Core simulation은 해당 Ball slot을 일반 Merge/Cashout 집합에서 제거하고, 그 위치와 운동 상태를 이어받는 Black Hole runtime entity로 전환한다. 두 번째 Lv14도 같은 방식으로 두 번째 Black Hole entity가 되며, 둘의 접촉은 일반 Merge보다 우선하는 terminal event다.

Black Hole gameplay state와 force/absorption 계산은 Core가 소유하고, BackgroundManager는 read-only 위치 snapshot을 받아 시각 중심을 맞춘다. 활성화는 Stage 변경이 아니라 같은 Galactic Stage 안의 `Black Hole Phase Transition`이다.

```gdscript
func get_black_hole_position() -> Vector2
func get_black_hole_pull(position: Vector2) -> Vector2
```

논리 인력과 `local_level <= 2` 공 흡수는 BallSimulationManager에서 적용한다. Black Hole 자체는 일반 Merge와 하단 Cashout scan에서 제외하고, Play Field 하단을 전용 반사 경계로 사용한다. Black Hole은 흡수로 radius·mass·force를 키우지 않는다.
배경 셰이더와 논리 좌표가 크게 어긋나지 않아야 한다.

성능상 공마다 `sqrt`를 줄이고 싶다면 거리 제곱 기반 완만한 함수 사용 가능하다.  
다만 조작감이 우선이며 실제 측정 후 최적화한다.

초기 force seed는 영향 반경 `240 world units`, 최대 가속도 `300 world units/s²`다. 반경 안의 normalized distance `t = clamp(distance / 240, 0, 1)`에 대해 `(1 - t)²` falloff를 사용하고 반경 밖은 0으로 둔다. delta를 곱해 velocity에 적용한 뒤 기존 final Ball speed cap을 유지한다. 중심 거리 `epsilon` 이하에서는 영벡터를 normalize하지 않아 NaN을 막는다. 수치는 Stage tuning data로 교체 가능해야 한다.

일반 공에 대한 다중 Black Hole force는 각 source의 vector를 먼저 합한 뒤 `600 world units/s²`로 한 번 제한한다. 같은 방향의 힘은 더해지고 반대 방향은 자연스럽게 상쇄되므로 Black Hole 수를 단순 scalar 배수로 적용하지 않는다. 그 뒤 delta를 곱하고 기존 Ball runtime speed cap을 적용한다.

Black Hole entity끼리는 일반 공용 force/absorption loop와 분리해 상대 Black Hole 방향으로 최대 `450 world units/s²`의 mutual acceleration을 적용한다. 이 값은 접근을 유도하는 gameplay seed이며, 접촉 확정 이후에는 force 적분을 멈추고 terminal presentation이 회전·폭발 transform을 소유한다.

향후 Presentation 후보인 Black Hole 주변 일반 공의 tidal deformation은 일반 Snowball MultiMesh와 양립한다. Core가 제공하는 read-only Black Hole 위치/영향 snapshot과 공의 nominal transform을 바탕으로 instance의 비균일 scale·회전 또는 shared shader custom data만 바꿀 수 있다. 이 시각 변형이 도입되더라도 Core의 공 중심, nominal radius, 원형 Merge/Paddle/벽 충돌은 그대로 유지하고 궤도 변화는 기존 force 계산만이 소유한다. 정확한 변형 강도·falloff·최대 비율은 아직 구현 계약이 아니다.

흡수 contact가 확정되면 일반 Cashout commit 전에 해당 공을 한 번 소비한다. `calculate_cashout_score(ball)`을 read-only로 계산한 값을 stage/run score에서 각각 차감한다. `stage_score`는 0에서 clamp하고, 계산 결과 `run_score <= 0`이면 `run_score = 0`으로 고정한 뒤 즉시 failure lock과 Run End를 요청한다. Time Bonus, Cashout 전용 popup, Merge, Settlement 중복 반영은 없다.

두 Black Hole의 earliest contact가 확정되면 terminal lock을 한 번만 세우고 이후 공 simulation 결과를 더 commit하지 않는다. Presentation은 두 중심의 상호 인력·회전·폭발을 재생하며 gameplay HUD를 숨기고 `SNOWBALL EFFECT` 타이틀, 그 아래 `CLEAR SCORE` 최종 run score와 `MAIN MENU` 버튼을 표시한다.

---

## 14. 데이터 정의

권장 Resource:

```text
BallDefinition
- global_level
- display_name
- score_value
- color
- texture
- fx_tier
- base_speed_override (future/optional; current version does not use per-level differences)

StageDefinition
- stage_index
- display_name
- base_global_level
- top_global_level
- local_ball_levels (Stage별 정확히 5종의 ordered global ID; 이전 Stage top과 다음 Stage base 중복, 비연속 ID 허용)
- base_time
- clear_score
- time_bonus_by_local_level
- spawn_rate
- visual_radius_scale (향후 Scale Shift 화면 연출용 예약값; gameplay visual/collision radius는 local level 계산값을 함께 사용)
- background_id
- global_force_scale (explicit Stage effect only; not default downward gravity)
- black_hole_enabled
- black_hole_influence_radius (initial seed: 240 world units)
- black_hole_max_pull_acceleration (initial seed: 300 world units/s²)
- black_hole_total_pull_cap (initial seed: 600 world units/s²)
- black_hole_mutual_pull_acceleration (initial seed: 450 world units/s²)

ItemDefinition
- item_type
- spawn_weight
- duration
- magnitude
- required_break_hits (current contract: 5)
```

초기에는 `.tres` 또는 GDScript Resource를 사용한다.  
밸런스 값이 여러 코드에 중복되지 않게 한다.

초기 BallCatalog는 global 0~14의 15종을 유지한다. 기본 Run의 Stage chain은 Ground `[0,1,2,3,4]`, Planetary `[4,5,6,8,10]`, Galactic `[10,11,12,13,14]`이며 Lv7·Lv9는 catalog에는 있으나 비활성이다. 15는 밸런스 공식이 아니라 첫 콘텐츠 제작 범위이며, 플레이테스트 결과에 따라 데이터 수를 줄일 수 있다. Stage별 구성과 global catalog의 연결은 `StageDefinition.local_ball_levels`에서 관리한다.

HUD 공 족보는 현재 `StageDefinition.local_ball_levels` 순서대로 `BallCatalog`의 visual key와 display name을 읽어 세로 5칸에 표시한다. Stage 진입 시 `revealed_count = 1`이고, 새 local 공이 처음 생성될 때 Core가 `stage_ball_progression_changed(stage_id, ordered_global_levels, revealed_count)`를 보낸다. Presentation은 앞에서부터 `revealed_count`개만 출력하고 나머지 슬롯의 아이콘·이름은 숨긴다. 별도의 Merge progression 사본이나 `NEXT` Spawn queue를 만들지 않으며 HUD가 Merge 결과나 Stage 데이터를 수정하지 않는다.

현재 S1의 Lv1 Spawn speed와 runtime speed cap은 공통 physics tuning이다. Mouse position은 직접 매핑하므로 movement speed cap을 사용하지 않는다. Paddle contact impact cap, ball reflection speed cap, rotation collision tolerance와 최대 rotation substep 수는 서로 다른 tuning이며 확정 디자인값이 아니다. 향후 BallDefinition override를 추가하더라도 runtime velocity를 지속적으로 고정하는 용도로 사용하지 않는다.

---

## 15. 신호

권장 신호:

```gdscript
signal cashout_completed(score_amount: float, global_level: int, world_position: Vector2)
signal ball_merged(result_level: int, world_position: Vector2)
signal highest_level_changed(new_level: int)
signal stage_timer_changed(time_left: float)
signal stage_time_up(stage: int)
signal final_settlement_started(amount: float)
signal final_settlement_finished(amount: float)
signal stage_clear_decided(stage: int, reason: StringName)
signal stage_clear_completed(stage: int, reason: StringName)
signal stage_failed(stage: int)
signal stage_shift_started(from_stage: int, to_stage: int)
signal stage_shift_completed(stage: int)
signal stage_ball_progression_changed(stage_id: int, ordered_global_levels: PackedInt32Array, revealed_count: int)
signal black_hole_phase_started(phase_id: int, from_rect: Rect2, to_rect: Rect2)
signal black_hole_phase_presentation_finished(phase_id: int)
signal black_hole_finale_locked(result_snapshot: Dictionary)
signal item_planet_damaged(item_type: int, current_hits: int, required_hits: int, world_position: Vector2)
signal item_planet_broken(item_type: int, world_position: Vector2)
signal item_orb_spawned(item_type: int, world_position: Vector2)
signal item_collected(item_type: int, world_position: Vector2)
signal item_orb_missed(item_type: int, world_position: Vector2)
signal active_items_changed(items: Array)
signal resume_requested()
signal settings_requested()
signal main_menu_requested()
signal game_finished(result: Dictionary)
```

EffectManager와 UI는 이 신호를 구독한다.  
시뮬레이션 코드가 UI 노드를 직접 찾아 수정하지 않는다.

---

## 16. 디버그 HUD

개발 빌드에서 토글 가능한 HUD:

- FPS
- 물리 프레임 시간
- 활성 공 수
- 최대 활성 공 수
- 생성량/초
- 합체/초
- 충돌 후보 검사 수
- 실제 합체 수
- 현재 스테이지
- 현재 기본 global_level
- 장식 파티클 수 또는 emitter 상태

웹 빌드 성능을 반드시 측정한다.

---

## 17. 성능 게이트

### Phase 1

- 100개 공
- 60 FPS 목표

### Phase 3

- 실제 Web build의 동시 활성 논리 공 500개에서 최저 30 FPS 이상
- 1,000개는 stretch/torture로 FPS·allocation·병목을 기록하되 필수 통과 기준으로 사용하지 않음
- 일반 플레이 peak는 약 300개를 초기 가정으로 두고 후반 콘텐츠 통합 뒤 telemetry로 재산정
- 전수 비교 없음
- 프레임 스파이크가 반복되지 않음

### 후반 연출

- 논리 공 + 파티클 + 배경을 함께 켠 웹 빌드에서 플레이 가능
- 성능이 떨어지면 먼저 장식 파티클과 팝업을 줄임
- 게임 규칙을 임의로 제거하지 않음

---

## 18. 웹 Export 주의

- 브라우저 콘솔 오류 확인
- 오디오 자동재생 제한 대응: 첫 입력 후 오디오 시작
- 캔버스 리사이즈와 비율 유지
- 입력 포커스 확인
- 지나치게 큰 초기 에셋 방지
- 스레드가 필요한 기능에 의존하지 않음
- 정적 호스팅에서 상대 경로 검증
- itch.io 또는 Cloudflare Pages 배포를 고려

---

## 19. 테스트 가능성

순수 계산은 가능한 한 함수로 분리한다.

예:

```gdscript
calculate_paddle_reflection(...)
format_score(...)
calculate_black_hole_pull(...)
get_merge_result(...)
```

Godot 테스트 프레임워크를 강제하지 않더라도 디버그 씬 또는 자동 검증 함수로 확인 가능하게 한다.


---

## Stage Timer / Cashout / Settlement 기술 규칙

### Stage clock

한 개의 전역 180초 타이머를 사용하지 않는다.

`StageManager`가 현재 Stage의 남은 시간을 관리한다.

```text
stage_time_left = stage_definition.base_time
```

Stage 진입:

```text
stage_score = 0
stage_time_left = stage_definition.base_time
```

활성 플레이 중 Cashout 발생:

```text
cashout_score = calculate_cashout_score(ball)
effective_time_bonus = get_local_time_bonus(current_stage, ball.global_level)
stage_score += cashout_score
run_score += cashout_score
stage_time_left += effective_time_bonus
```

`time_bonus_by_local_level[0]`은 0으로 시작한다.
시간 보너스는 점수나 Active Cashout 전용 modifier와 별도로 계산한다.
Stage 종료 시 `run_score`에 `stage_score`를 다시 더하지 않는다.

초기 구현에는 Stage 시간 상한을 넣지 않는다.
실제 Stage 플레이 시간, Cashout 총 획득 시간, 초당 평균 획득 시간,
local level별 Cashout 수를 측정하고 인플레가 확인될 때만 상한을 검토한다.

### Physics tick ordering

Stage 종료 판정은 다음 순서를 따른다.

```text
1. stage_time_left -= delta
2. 이동 / 충돌 / Merge 처리
3. Merge 확정 및 Top Ball 여부 기록
4. Active Cashout 점수와 Time Bonus 반영
5. 종료 판정
   - Top Ball 생성 → TOP_BALL_CLEAR
   - 아니고 stage_time_left <= 0 → TIME_UP
   - 그 외 → PLAYING 유지
```

같은 tick의 Cashout으로 시간이 다시 양수가 되면 Time Up을 취소한다.
같은 tick에 Top Ball과 Time Up 조건이 모두 있으면 Top Ball Clear가 우선한다.

### Top Ball Clear

현재 Stage `top_global_level` 공이 생성되면:

1. Stage 성공 상태 잠금
2. 추가 Stage 타이머 감소 정지
3. 일반 CUT-IN보다 Stage Clear 우선
4. `stage_clear_decided(reason = TOP_BALL)` 확정
5. Final Settlement 실행
6. `stage_clear_completed` 후 다음 Stage면 Scale Shift

### Time Up

tick의 Cashout 반영 후에도 시간이 0 이하이면:

1. 새 공 Spawn 정지
2. 플레이 입력/물리 진행 정지 또는 짧게 감속
3. Final Settlement
4. 마지막 Stage가 아니면 `final_stage_score >= clear_score` 판정
5. 성공 → Scale Shift
6. 실패 → Run End

### Final Settlement

Settlement는 게임플레이 머지가 아니다.

SETTLING 진입 시 활성 공 인덱스를 snapshot하고 Settlement 전용 경로로 처리한다.

각 snapshot 공에 대해:

```text
settlement_score += ball.score_value
```

- Time Bonus 없음
- Active Cashout 전용 modifier 없음
- 추가 머지 없음
- `stage_score += settlement_score`와 `run_score += settlement_score`를 한 번만 실행
- 일반 Cashout 함수를 호출하지 않음
- snapshot 공을 settlement reserved/deactivated 처리한 뒤 제거
- `settlement_applied`로 중복 호출 방지
- 공은 연출 큐를 통해 제거
- score 누적 연출은 배치 처리 가능
- 수천 공이 있을 때 각 공마다 무거운 Tween/Node를 만들지 않음

Final Settlement 도중 새로운 Cashout 신호가 중복 발생하지 않게 한다.

### Stage state 예시

```text
READY
PLAYING
CLEAR_LOCKED
TIME_UP_LOCKED
SETTLING
CLEARED
SHIFTING
FAILED
FINISHED
```

Stage 전환과 Settlement는 중복 실행되지 않도록 상태로 보호한다.
