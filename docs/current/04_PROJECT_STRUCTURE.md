# Snowball Effect — Project Structure

## 1. 권장 디렉터리

```text
res://
├─ project.godot
├─ scenes/
│  ├─ main/
│  │  └─ main.tscn
│  ├─ gameplay/
│  │  ├─ paddle.tscn
│  │  └─ item_pickup.tscn
│  ├─ backgrounds/
│  │  ├─ ground_background.tscn
│  │  ├─ planetary_background.tscn
│  │  ├─ galactic_background.tscn
│  │  └─ black_hole_background.tscn
│  ├─ effects/
│  │  ├─ merge_effect.tscn
│  │  ├─ cashout_effect.tscn
│  │  ├─ score_popup.tscn
│  │  └─ high_grade_cutin.tscn
│  └─ ui/
│     ├─ hud.tscn
│     ├─ pause_menu.tscn
│     └─ result_panel.tscn
├─ scripts/
│  ├─ core/
│  │  ├─ game_manager.gd
│  │  ├─ stage_manager.gd
│  │  └─ game_state.gd
│  ├─ simulation/
│  │  ├─ ball_simulation_manager.gd
│  │  ├─ spatial_grid.gd
│  │  └─ ball_renderer.gd
│  ├─ gameplay/
│  │  ├─ paddle.gd
│  │  ├─ item_manager.gd
│  │  └─ item_pickup.gd
│  ├─ presentation/
│  │  ├─ effect_manager.gd
│  │  ├─ presentation_manager.gd
│  │  ├─ cutin_controller.gd
│  │  ├─ audio_manager.gd
│  │  ├─ background_manager.gd
│  │  └─ camera_controller.gd
│  ├─ ui/
│  │  ├─ hud.gd
│  │  └─ result_panel.gd
│  └─ utils/
│     ├─ score_formatter.gd
│     └─ math_utils.gd
├─ resources/
│  ├─ balls/
│  ├─ stages/
│  └─ items/
├─ assets/
│  ├─ sprites/
│  ├─ backgrounds/
│  ├─ particles/
│  ├─ audio/
│  ├─ fonts/
│  └─ shaders/
├─ tests/
│  ├─ reflection_test_scene.tscn
│  ├─ merge_test_scene.tscn
│  └─ stress_test_scene.tscn
└─ docs/
   └─ 이 문서 세트
```

처음부터 빈 폴더를 과도하게 만들 필요는 없다.  
단계별로 필요한 파일만 만들되 책임 경계를 유지한다.

---

## 2. Main 씬

권장 씬 트리:

```text
Main (Node)
├─ GameManager
├─ StageManager
├─ BallSimulationManager
├─ BallRenderer
├─ ItemManager
├─ EffectManager
├─ AudioManager
├─ BackgroundManager
├─ Camera2D
├─ StageWorld (Node2D)
├─ MachineFrame (Node2D)
├─ PlayField (Node2D)
│  ├─ Paddle
│  ├─ LeftBoundary
│  ├─ RightBoundary
│  ├─ TopBoundary
│  └─ ScoreZone
└─ UI (CanvasLayer)
   ├─ HUD
   ├─ AnnouncementLayer
   ├─ PauseMenu
   ├─ DebugHUD
   ├─ GlobalDimmer
   ├─ CutInLayer
   └─ ResultPanel
```

경계는 반드시 물리 노드일 필요가 없다.  
BallSimulationManager가 플레이 필드 Rect를 받아 직접 처리해도 된다.

---

## 3. 클래스 책임

### GameManager

책임:

- 게임 상태 (`READY`, `PLAYING`, `PAUSED`, `FINISHED`)
- 전체 누적 점수
- 기록 통계
- Run 상태
- 시작·일시정지·종료·재시작
- 시스템 신호 연결

하지 않는 일:

- 공 이동 계산
- 파티클 직접 생성
- 배경 직접 변경

### StageManager

책임:

- StageDefinition 로드
- 현재 Stage
- Stage 제한 시간 / 남은 시간
- Stage 점수 / clear_score
- 기본/최고 global_level
- 현재 생성량
- Cashout Time Bonus 반영
- Ground/Planetary local Lv4 비종료와 Galactic Black Hole Phase handoff
- Time Up
- Final Settlement
- Score Clear / Fail 판정
- Scale Shift 순서
- 블랙홀 활성 여부와 파라미터

### BallSimulationManager

책임:

- 모든 논리 공
- 생성·제거·재사용
- 이동
- 충돌
- 합체
- 회수
- 전역 힘
- 성능 지표

### BallRenderer

책임:

- 논리 데이터를 화면에 그림
- 레벨·특수 타입에 따른 표현
- 시뮬레이션 규칙을 변경하지 않음

### Paddle

책임:

- 입력
- 위치·회전
- 충돌 계산에 필요한 변환과 속도 제공
- Fire 상태 시각 표현

### ItemManager

책임:

- Stage당 Item Ball 1회의 랜덤 등장 예약
- local Lv3 이상 Snowball hit와 5-hit 파괴 lock
- 파괴 뒤 item별 Item Orb 생성
- Item Orb의 Paddle 획득·하단 miss 판정
- 활성 효과
- 지속시간
- 아이템 획득 신호
- 효과 종료

### EffectManager

책임:

- 합체·회수·아이템·Scale Shift 연출
- 이벤트 등급별 FX 예산
- 히트스톱 요청
- 점수 팝업 풀


### PresentationManager

책임:

- 고등급 CUT-IN 우선순위
- CUT-IN cooldown
- GlobalDimmer
- 짧은 프레젠테이션 pause
- Scale Shift와 일반 CUT-IN 충돌 조정

### CutInController

책임:

- 패널 진입/체류/퇴장
- 공/아이템 이름과 스프라이트 바인딩
- VALUE/효과 텍스트
- 완료 신호

하지 않는 일:

- 머지 판정
- 점수 변경
- Stage 변경

### BackgroundManager

책임:

- 현재 배경 씬 전환
- 블랙홀 위치와 시각
- 배경 파티클
- 논리 시뮬레이션을 직접 수정하지 않음

### AudioManager

책임:

- 효과음 채널
- 합체 레벨별 피치/저음
- 사운드 동시 재생 제한
- 첫 입력 후 오디오 활성화

---

## 4. 데이터 흐름

```text
Input
 → Paddle

StageManager
 → BallSimulationManager: base_level, spawn_rate, global effects

BallSimulationManager
 → signals: merge, cashout, highest_level

GameManager
 ← cashout: score/statistics
 ← timer: finish

EffectManager
 ← merge/cashout/stage/item signals

BackgroundManager
 ← stage changed

HUD
 ← GameManager and StageManager state
```

시스템 간 직접 노드 탐색을 최소화하고, 명확한 참조 또는 신호를 사용한다.

---

## 5. Resource 정의

### BallDefinition

파일 예:

```text
resources/balls/ball_00_snowflake.tres
```

필드:

```text
global_level
display_name
score_value
base_color
texture
fx_tier
base_speed_override  # future/optional; current version uses shared Spawn tuning
```

현재 등급별 base speed 차이는 사용하지 않는다. 향후 override를 도입해도 생성 시 초기 기준일 뿐 runtime speed를 고정하지 않는다. 공통 Spawn speed 범위와 runtime cap은 simulation physics tuning에서 관리한다.

### StageDefinition

```text
stage_index
display_name
base_global_level
top_global_level
base_time
clear_score
time_bonus_by_local_level
spawn_rate
visual_radius_scale  # 향후 Scale Shift 화면 연출용 예약값; gameplay 크기는 local level 기준
background_scene
black_hole_enabled
black_hole_strength
```

### ItemDefinition

```text
item_type
display_name
duration
magnitude
spawn_weight
icon
```

---

## 6. 파일 명명

- 파일: `snake_case`
- 클래스: `PascalCase`
- 변수/함수: `snake_case`
- 상수: `UPPER_SNAKE_CASE`
- 신호: 과거형 또는 사건형 (`ball_merged`, `score_added`)
- private helper는 `_` 접두사 허용

---

## 7. 씬 협업 규칙

- 한 사람이 하나의 큰 `.tscn`을 독점적으로 담당
- 공 시뮬레이션은 코드 중심으로 유지
- 배경과 효과는 별도 씬
- UI는 별도 씬
- Main 씬의 잦은 동시 편집 방지
- 씬 연결은 명시적인 exported NodePath 또는 코드 조립 사용

---

## 8. 의존 방향

권장:

```text
presentation → core state를 읽음
simulation → data와 core interface에 의존
core → presentation 세부를 모름
```

금지:

- BallRenderer가 점수를 변경
- UI가 직접 공 배열을 수정
- BackgroundManager가 공을 제거
- EffectManager가 Stage를 임의로 올림

---

## 9. 최소 초기 파일

Phase 1에서는 아래만 있으면 된다.

```text
project.godot
scenes/main/main.tscn
scenes/gameplay/paddle.tscn
scripts/core/game_manager.gd
scripts/simulation/ball_simulation_manager.gd
scripts/simulation/ball_renderer.gd
scripts/gameplay/paddle.gd
scripts/ui/hud.gd
scripts/utils/score_formatter.gd
```

복잡한 폴더와 클래스를 선행 생성하지 않는다.
