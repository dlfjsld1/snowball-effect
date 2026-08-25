# File Ownership

> **STATUS: INITIAL / DRAFT**

아래 경로는 계획된 소유권이다. 실제 파일이 아직 없어도 Goal의 `Owned Files` 판단 기준으로 사용한다.

## Integration-owned

직접 변경은 활성 Integration Goal과 Integration 담당 승인 아래에서만 한다.

```text
project.godot
scenes/main/main.tscn
scripts/core/game_manager.gd
scripts/core/stage_manager.gd
scripts/core/item_effect_gateway.gd
tests/integration/**
```

필요한 변경은 먼저 Signal/API, 노드 계약, 설정 key로 요청한다. Main 씬은 수정 금지가 아니라 Integration 담당이 변경을 모아 병합하는 파일이다.

## Core-owned

```text
scripts/simulation/**
scripts/gameplay/paddle.gd
scenes/gameplay/paddle.tscn
scripts/core/game_state.gd
scripts/core/stage_runtime.gd
scripts/core/score_ledger.gd
scripts/core/settlement_service.gd
tests/core/**
tests/simulation/**
```

S3-G9는 이 경계 안에서 `stage_runtime.gd`, `ball_simulation_manager.gd`, 전용 Core/Simulation verification만 소유한다. Run-scoped FIRST_CONTACT identity/seen set, versioned discovery payload와 Core lifecycle API가 범위이며 `GameManager`, `StageManager`, Main, CUT-IN controller와 S8 presentation은 수정하지 않는다.

## Presentation-owned

```text
scripts/presentation/**
scripts/ui/hud.gd
scenes/ui/hud.tscn
scenes/effects/**
scenes/backgrounds/**
assets/sprites/**
assets/backgrounds/**
assets/particles/**
assets/shaders/**
tests/presentation/**
```

예외: S6-G1은 Content/Systems가 `scripts/presentation/effect_manager.gd`, `scenes/effects/**`, `assets/particles/**`, `tests/content/s6_g1_**`를 소유해 시각 FX event tier와 budget을 확정한다. S7-G2 Blizzard는 사용자 지정에 따라 Content/Systems/Release 담당이 `scripts/presentation/item_blizzard_visual.gd`, `scenes/effects/item_blizzard_visual.tscn`, `assets/particles/items/blizzard/**`, `tests/content/s7_g2_**`를 소유한다. 단, 사용자 지시 S7-G1V 동안 Integration이 `scripts/presentation/item_blizzard_visual.gd`와 지정된 세-Orb 검증 파일만 잠가 Blizzard/Fire/Magnet 공통 표시 연결을 복구한다. `scripts/presentation/audio_manager.gd`는 S6-G4/G5에 한해 Content/Systems-owned다. S6-G2의 `cutin_controller.gd`, FIRST_CONTACT layer 조립, visual reset과 `tests/presentation/s6_g2_**` 소유권은 Presentation에 유지한다. S6-G2는 Core discovery나 gameplay pause/resume, S8 Phase를 구현하지 않는다.

### 사용자 지정 Paddle visual binding

사용자 지정에 따라 `assets/sprites/paddle/paddle_pneumatic_ram_70.png`와 해당 `scenes/gameplay/paddle.tscn`의 `Paddle/Visual` Sprite2D 연결은 Core가 직접 유지한다. `Paddle/DashGaugeBackdrop`·`Paddle/DashGaugeFill`의 중앙 바 cooldown overlay도 S1-G2A Core-owned 시각 보조 예외다. 이 예외는 패들 본체 이미지와 대쉬 순간 animation의 선택·교체·표시에만 적용하며, 다른 `assets/sprites/**`와 Presentation 범위는 바꾸지 않는다. 패들 물리 OBB·입력·반사 규칙은 `scripts/gameplay/paddle.gd`의 Core 소유권을 유지한다.

## Content/Systems-owned

```text
resources/**
scripts/data/**
scripts/utils/score_formatter.gd
scripts/gameplay/item_*.gd
scripts/ui/title*.gd
scripts/ui/pause*.gd
scripts/ui/result*.gd
scenes/ui/title*.tscn
scenes/ui/pause*.tscn
scenes/ui/result*.tscn
assets/audio/**
resources/audio/**
scripts/presentation/effect_manager.gd  # S6-G1 FX budget ownership exception
scenes/effects/**                       # S6-G1 ownership exception; S6-G2 CUT-IN은 Presentation-owned
assets/particles/**                     # S6-G1 FX budget ownership exception
scripts/presentation/audio_manager.gd  # S6-G4 SFX / S6-G5 BGM ownership exception
export_presets.cfg
tests/content/**
tests/release/**
docs/current/SUBMISSION/**
```

## 교차 수정 절차

1. 현재 Goal의 `Integration Point`에 필요한 Signal/API를 적는다.
2. 상대 Owner에게 계약 추가를 요청한다.
3. 상대 Owner가 자신의 Owned Files에서 구현·검증한다.
4. Integration-owned wiring이 필요하면 별도 Integration Goal에서 병합한다.
5. 긴급 직접 수정은 Integration 담당 승인과 Worklog 근거가 있을 때만 허용한다.

`Owned Files`가 겹치거나 새 경로의 Owner가 불분명하면 구현 전에 이 문서를 먼저 갱신한다.

## FIRST_CONTACT Goal 경계

| Goal | Lane | 소유 경계 |
|---|---|---|
| S3-G9 | Core | six-identity discovery, Run seen set, `event_id`/payload v1, begin/invalidate API |
| S6-G2I | Integration | `run_epoch`, end-of-tick arbitration, gameplay pause lock, Main wiring, matching finish와 기존 S8-G4 handoff |
| S6-G2 | Presentation | 공통 배경+identity별 title/portrait 조립, visible CUT-IN lifecycle, matching completion/reset |
| S10-G1 | Content/Systems/Release | Settings session/return-view 계약과 adapter handoff 수락·검증을 소유한다. `GameManager`/Main의 완료된 구현은 Integration handoff이며 향후 변경은 별도 Integration 요청으로 제한한다. |

S6-G2I가 `IN PROGRESS`가 될 때만 기존 Integration-owned `scripts/core/game_manager.gd`, `scripts/core/stage_manager.gd`, `scenes/main/main.tscn`, `tests/integration/**`를 `STATUS.md`에 잠근다. 현재 세 Goal은 모두 구현 lock을 잡지 않으며, S6-G2는 S3-G9/S6-G2I의 실제 Evidence 전에는 runtime 파일을 만들거나 수정하지 않는다.

## Result 최고치 summary 경계

S8-G3B는 사용자 결정에 따라 **Content/Systems/Release 단독 Goal**이다. 이 Goal이 `IN PROGRESS`인 동안 해당 담당자는 아래 경로를 직접 변경·검증할 수 있으며, 별도 Core/Integration handoff나 lock을 요구하지 않는다.

```text
scripts/core/stage_runtime.gd
scripts/simulation/ball_simulation_manager.gd
scripts/core/stage_manager.gd
scripts/core/game_manager.gd
scripts/ui/result_panel.gd
scenes/ui/result_panel.tscn
tests/core/**
tests/simulation/**
tests/integration/**
tests/content/**
```

범위는 Run 최고 `highest_ball_global_level` 기록·reset, terminal snapshot value-copy, Result의 Stage/Ball catalog 텍스트·이미지 표시와 Desktop/Web 검증으로 제한한다. Score/Settlement 계산, 실패·Clear 판정, Black Hole phase/finale 규칙, Stage Shift 순서, Result reveal timing은 변경하지 않는다. 이 예외는 S8-G3B 완료 또는 취소 시 종료되며, 이후 위 Core/Integration 경로는 기본 소유권으로 돌아간다.
