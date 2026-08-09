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
