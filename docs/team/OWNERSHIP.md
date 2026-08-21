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

예외: S6-G1은 Content/Systems가 `scripts/presentation/effect_manager.gd`, `scenes/effects/**`, `assets/particles/**`, `tests/content/s6_g1_**`를 소유해 시각 FX event tier와 budget을 확정한다. `scripts/presentation/audio_manager.gd`는 S6-G4/G5에 한해 Content/Systems-owned다. S6-G2의 `cutin_controller.gd`, FIRST_CONTACT layer 조립, visual reset과 `tests/presentation/s6_g2_**` 소유권은 Presentation에 유지한다. S6-G2는 Core discovery나 gameplay pause/resume, S8 Phase를 구현하지 않는다.

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

S6-G2I가 `IN PROGRESS`가 될 때만 기존 Integration-owned `scripts/core/game_manager.gd`, `scripts/core/stage_manager.gd`, `scenes/main/main.tscn`, `tests/integration/**`를 `STATUS.md`에 잠근다. 현재 세 Goal은 모두 구현 lock을 잡지 않으며, S6-G2는 S3-G9/S6-G2I의 실제 Evidence 전에는 runtime 파일을 만들거나 수정하지 않는다.
