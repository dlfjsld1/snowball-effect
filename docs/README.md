# Snowball Effect 문서 안내

이 폴더는 Godot 4 기반 웹 게임 **Snowball Effect**의 현재 기획 계약과 Goal 기반 실행 계획을 관리한다.

## 기준선

- 현재 구현 기준은 2026-08-09에 정리한 [`current/`](current/) 문서다.
- 과거 컨텍스트 팩을 저장소 안에 함께 두지 않는다. 과거 상태는 Git 이력과 원본 ZIP으로 보존한다.
- [`current/ALL_IN_ONE.md`](current/ALL_IN_ONE.md)는 전달용 산출물이며, 구현 판단에는 분리 문서를 우선한다.
- 실제 작업 순서와 검증 상태는 [`goals/`](goals/)에서만 관리한다.
- 초기 역할, 파일 소유권, Signal/API 통합 규칙은 [`team/`](team/)에서 관리한다.

## 읽기 순서

1. [`current/01_PRODUCT_BRIEF.md`](current/01_PRODUCT_BRIEF.md)
2. [`current/02_GAME_RULES.md`](current/02_GAME_RULES.md)
3. [`current/03_TECHNICAL_DESIGN.md`](current/03_TECHNICAL_DESIGN.md)
4. [`goals/README.md`](goals/README.md)
5. [`team/README.md`](team/README.md)와 [`team/OWNERSHIP.md`](team/OWNERSHIP.md)
6. [`goals/STATUS.md`](goals/STATUS.md)
7. 현재 [`goals/slices/S*.md`](goals/slices/)
8. Slice가 참조하는 [`current/tasks/*.md`](current/tasks/)

전체 원문 순서는 [`current/00_READ_FIRST.md`](current/00_READ_FIRST.md)에 있다.

## 확정 게임 흐름

각 Stage는 독립적인 제한 시간 라운드다.

```text
STAGE START
  stage_score = 0
  stage_time = StageDefinition.base_time

PLAYING
  Active Cashout
    stage_score += cashout_score
    run_score += cashout_score
    stage_time += local_time_bonus

  Top Ball
    CLEAR_LOCKED → SETTLING → CLEARED → SHIFTING

  Time Up
    TIME_UP_LOCKED → SETTLING
      stage_score >= clear_score → CLEARED → SHIFTING
      otherwise                  → FAILED → RUN END
```

마지막 Stage의 `CLEARED`는 `SHIFTING` 대신 Final Result로 간다.

### 한 physics tick의 판정 순서

1. `stage_time -= delta`
2. 이동 / 충돌 / Merge 처리
3. Merge 확정 및 Top Ball 확인
4. 같은 tick의 Active Cashout 점수와 Time Bonus 반영
5. Top Ball 우선, 그다음 `stage_time <= 0` 순서로 종료 판정

시간이 0 이하가 된 tick에서도 Cashout 보너스로 시간이 양수가 되면 플레이를 계속한다. 같은 tick에 Top Ball이 생성되면 남은 시간과 관계없이 Stage 성공이다.

### 점수와 Settlement

- 모든 점수 이벤트는 같은 `amount`를 `stage_score`와 `run_score`에 한 번씩 더한다.
- Stage 종료 시 `run_score += stage_score`를 절대 수행하지 않는다.
- Final Settlement는 active ball snapshot의 base `score_value`만 한 번 반영한다.
- Settlement에는 Time Bonus, Active Cashout 전용 modifier, 추가 Merge가 없다.
- `settlement_applied` 같은 잠금으로 중복 정산을 막는다.

### 데이터와 레이어 경계

- `base_time`, `clear_score`, `time_bonus_by_local_level`은 `StageDefinition` 데이터다.
- Time Bonus 초기값은 Local Lv0~5 순서로 `0s`, `0.25s`, `0.5s`, `1s`, `2s`, `4s`다. 최고 local 공은 즉시 Clear되므로 일반 Active Cashout 보너스를 실제로 받지 않는다.
- `clear_score` 초기값은 Ground `4e6`, Planetary `2e18`이다. 각각 최고 공보다 한 단계 낮은 Cashout 가능 공인 Giant Snowball 및 Supernova 점수의 4배이며, 마지막 Galactic Stage는 이 판정을 사용하지 않는다. 이는 런타임 공식이 아닌 플레이테스트 기준값이다.
- 초기 시간 cap은 두지 않고 실제 획득 시간과 Stage 체류 시간을 먼저 측정한다.
- Core는 Merge, Cashout, Time Bonus, Stage Timer, Settlement, Scale Shift다.
- Blizzard, Fire Core, Magnet은 Optional Item Layer다. Fire ×10은 Active Cashout 전용이며 Settlement에는 적용하지 않는다.

## 기술 제약

- Godot 4.x와 Web Export를 기준으로 한다.
- 기본 공은 지속 중력 없이 Spawn velocity로 이동하며 좌·우·상단에서 반사하고 열린 하단을 통과하면 Cashout한다.
- Spawn/base speed는 초기 기준일 뿐 runtime speed를 고정하지 않으며 Paddle과 명시적 gameplay interaction이 runtime velocity를 변경할 수 있다.
- 저레벨 공을 개별 `RigidBody2D`, 개별 씬, 개별 `_physics_process`로 만들지 않는다.
- 중앙 배열 기반 시뮬레이션과 비활성 슬롯 재사용을 유지한다.
- 모든 공 쌍의 O(N²) 전수 비교를 최종 구조에 남기지 않는다.
- 게임 규칙용 공과 장식용 파티클을 분리한다.
- 논리 공 1,000개에서 최소 30 FPS, 데스크톱 브라우저 60 FPS를 지향하되 측정 전 수치를 주장하지 않는다.

## 문서 우선순위

1. 사용자의 최신 명시적 지시
2. [`current/02_GAME_RULES.md`](current/02_GAME_RULES.md)
3. [`current/03_TECHNICAL_DESIGN.md`](current/03_TECHNICAL_DESIGN.md)
4. 현재 Slice 문서
5. Slice가 참조하는 `current/tasks/*.md`
6. [`current/05_IMPLEMENTATION_PLAN.md`](current/05_IMPLEMENTATION_PLAN.md)
7. 기존 코드 관례
