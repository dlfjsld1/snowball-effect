# Task 01 — Minimum Play Loop

## 목적

회색 원과 단순 패들만으로 게임의 가장 작은 플레이 루프를 완성한다.

```text
공 생성 → 아래쪽 초기 velocity → 벽/패들 반사 → 열린 하단 Cashout → 점수
```

합체와 Stage는 아직 구현하지 않는다.

---

## 범위

### 포함

- Main 씬
- 중앙 Play Field Rect + 좌우 Stage World placeholder
- GameManager
- Paddle
- BallSimulationManager
- BallRenderer
- HUD
- 기본 공 생성
- 지속 중력 없는 velocity 이동
- 좌우·상단 벽 반사
- 열린 하단 경계
- 패들 충돌과 반사
- 점수 구역
- 점수 증가
- 개발용 Stage 타이머
- 재시작
- 디버그 활성 공 수

### 제외

- 공끼리 충돌
- 합체
- Stage
- Item
- 파티클
- 블랙홀
- 고급 에셋
- 정식 Stage별 시간 / Clear / Settlement 흐름

---

## 입력

- `A/D`: 패들 이동
- `←/→`: 패들 회전
- `Mouse X`: Play Field logical X로 변환 후 Paddle X에 직접 반영하고 field clamp
- `Mouse Wheel`: 패들 회전 (한 칸당 `mouse_wheel_step_degrees` tuning)
- `R`: 개발용 즉시 재시작
- `Esc`: 일시정지

Input Map에 의미 있는 액션 이름을 사용한다.

```text
paddle_move_left
paddle_move_right
paddle_rotate_left
paddle_rotate_right
pause_game
restart_game
```

---

## 초기 수치

```text
viewport: 1600×900
play_field_width: 전체 폭의 약 40~50%에서 프로토타입 시작(확정값 아님)
spawn_rate: 6/s
gravity: 0
spawn_direction: 아래쪽 반구 안에서 tuning
lv1_physical_design_reference: 일반 눈발 약 1.0 m/s (runtime 환산 없음)
lv1_spawn_speed: 160 world units/s (첫 플레이테스트 tuning)
runtime_speed_min/max: Paddle 반복 타격 폭주 방지용 tuning
paddle_keyboard_speed: 460 px/s
paddle_mouse_position: direct logical-X mapping (no tracking speed cap)
paddle_contact_impact_velocity_cap: separate playtest tuning
paddle_ball_runtime_speed_cap: separate playtest tuning
paddle_rotation_speed: 150 deg/s
paddle_angle: unlimited rotation (equivalent-angle normalization allowed)
mouse_wheel_step_degrees: 5°/step
paddle_width: 240 px
lv1_ball_radius: 4 world units (visual/collision diameter 8; approved Shared Skeleton base size)
```

수치는 한 파일 또는 export 변수에서 쉽게 수정 가능해야 한다.

공간은 `1 world unit = 1 logical pixel`, 시간은 second, 속도는 world units/s다. Lv1 `1.0 m/s`는 physical/design reference이며 runtime value로 직접 환산하지 않는다. 화면 높이 또는 통과시간으로 physical speed를 정의하지 않는다. Spawn/base speed는 초기 velocity를 만드는 기준이며 runtime speed 고정값이 아니다. 현재는 등급별 base speed 차이를 사용하지 않지만 향후 도입은 허용한다.

---

## 패들 반사 완료 조건

- Paddle 앞면과 뒷면 모두에서 실제 접촉 normal을 기준으로 반사
- 공을 패들 표면 밖으로 보정
- 패들 각도에 따라 반사 방향이 명확히 달라짐
- 충돌 위치에 따라 약간의 좌우 편차
- 패들 이동 방향이 소량 반영
- Mouse 직접 위치 반영과 contact impact velocity cap이 분리됨
- 이전/현재 Paddle transform과 ball trajectory의 continuous contact로 translation/rotation tunneling을 방지
- 접촉점 속도에 Paddle 중심 선형속도와 angular contribution이 함께 반영됨
- Paddle hit으로 runtime speed가 변할 수 있음
- tuning 가능한 speed cap으로 반복 타격의 무한 가속 방지
- 반사 후 중력이 상승 속도를 감소시키지 않음
- 같은 공이 패들 안에서 연속 반사되지 않음

---

## 점수

Task 01에서는 모든 기본 공 점수를 1로 사용해도 된다.
Time Bonus와 Stage Clear 판정은 Task 02.5에서 구현한다.

바닥 ScoreZone 통과 시:

- 점수 +1
- 공 비활성화
- 슬롯 재사용
- HUD 갱신

---

## 데이터 구조

처음부터 공마다 Node를 만들지 않는다.

최소 배열:

```gdscript
positions
velocities
radii
active_flags
free_indices
```

Task 01에서는 Spatial Grid가 필요하지 않다.

---

## 완료 조건

- 프로젝트 실행 성공
- 전체 Viewport와 중앙 Play Field가 분리되어 있음
- 공/패들/ScoreZone은 중앙 Play Field 기준으로 동작
- 60초 동안 공이 계속 생성
- 100개 이상 활성 공에서 정상 실행
- A/D 이동 정상
- 방향키 회전 정상
- 동시 입력 정상
- Mouse X가 지연 없이 logical Paddle X에 반영되고, Wheel 회전과 동시에 사용 가능
- 실제 previous/current transform에서 계산한 center/angular velocity가 contact point impact에 반영됨
- 반사 예측 가능
- 바닥 도달 시 점수 증가
- Pause/Restart 정상
- 파싱 및 런타임 오류 없음

---

## 검증 시나리오

1. 패들을 수평으로 두고 공이 거의 위로 반사되는지 확인
2. 왼쪽으로 기울여 왼쪽 궤도가 증가하는지 확인
3. 오른쪽으로 기울여 오른쪽 궤도가 증가하는지 확인
4. 이동 중 공을 맞혀 미세한 이동 보너스 확인
5. 상호작용이 없는 공의 velocity/speed가 지속 중력 없이 유지되는지 확인
6. 상단 벽에서 speed를 유지하며 반사되는지 확인
7. Paddle hit이 runtime speed를 바꿀 수 있고 cap을 넘지 않는지 확인
8. 빠른 Mouse translation과 360° 연속 회전 sweep에서 Lv1 공이 Paddle을 통과하지 않는지 확인
9. Paddle 중심/끝 접촉에서 angular contribution 방향과 크기 차이를 확인
10. 패들을 공 아래에서 치워 열린 하단 Cashout으로 점수가 증가하는지 확인
11. 100개 이상 공에서 FPS 확인
12. 일시정지 중 타이머와 공이 정지하는지 확인
13. 재시작 시 previous/current transform, 접촉 잠금, 배열, 점수, 타이머가 초기화되는지 확인

---

## 작업 보고에 포함

- 실제 생성한 씬 트리
- 반사 계산 설명
- 활성 공 100개 시 FPS
- 변경 파일
- 실행 방법
- 남은 문제
