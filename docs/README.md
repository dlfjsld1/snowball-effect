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

  Local Lv4 first creation
    FIRST CONTACT CUT-IN → PLAYING

  Time Up
    TIME_UP_LOCKED → SETTLING
      stage_score >= clear_score → CLEARED → SHIFTING
      otherwise                  → FAILED → RUN END
```

마지막 Galactic은 예외다. 첫 Lv14 Black Hole은 `CLEARED`가 아니라 이동 Black Hole 최종 국면을 활성화하고, 두 번째 Black Hole과 충돌해야 타이틀 연출 뒤 Run이 끝난다. Time Up 종료는 기존 Final Settlement 경로를 유지한다.

### 한 physics tick의 판정 순서

1. `stage_time -= delta`
2. 이동 / 충돌 / Merge 처리
3. Merge 확정 및 새 local 공 발견 확인
4. 같은 tick의 Active Cashout 점수와 Time Bonus 반영
5. `stage_time <= 0`이면 종료 판정

시간이 0 이하가 된 tick에서도 Cashout 보너스로 시간이 양수가 되면 플레이를 계속한다. Ground/Planetary의 local Lv4가 생성돼도 Stage를 즉시 끝내지 않는다.

### 점수와 Settlement

- 모든 점수 이벤트는 같은 `amount`를 `stage_score`와 `run_score`에 한 번씩 더한다.
- Stage 종료 시 `run_score += stage_score`를 절대 수행하지 않는다.
- Final Settlement는 active ball snapshot의 base `score_value`만 한 번 반영한다.
- Settlement에는 Time Bonus, Active Cashout 전용 modifier, 추가 Merge가 없다.
- `settlement_applied` 같은 잠금으로 중복 정산을 막는다.

### 데이터와 레이어 경계

- `base_time`, `clear_score`, `time_bonus_by_local_level`은 `StageDefinition` 데이터다.
- Time Bonus 초기값은 Stage별 5종의 Local Lv0~4 순서로 `0s`, `0.25s`, `0.5s`, `1s`, `2s`다. local Lv4도 일반 플레이와 Active Cashout 대상이 될 수 있다.
- 기본 Stage chain은 Ground `[0,1,2,3,4]`, Planetary `[4,5,6,8,10]`, Galactic `[10,11,12,13,14]`다. Lv7·Lv9는 catalog에는 있지만 기본 Run에서 비활성이고, Lv14 최종 공은 `Black Hole`이다. 첫 Lv14 Ball은 Galactic 내부의 이동 Black Hole runtime 기믹으로 전환된다.
- `clear_score` 초기값은 Ground `4e8`, Planetary `4e25`다. 두 값 모두 해당 Stage 최고 공 Active Cashout 점수의 4배(Moon `1e8`, Galaxy `1e25`)다. Cashout commit 뒤 목표에 도달하면 즉시 Clear와 Scale Shift를 확정하며, local Lv4 생성 자체는 이 판정을 대신하지 않는다. 마지막 Galactic Stage는 이 판정을 사용하지 않는다.
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
- Web release 필수 기준은 동시 활성 논리 공 500개에서 최저 30 FPS 이상이다.
- 1,000개는 필수 플레이 규모가 아닌 stretch/torture stress로 계속 측정하고 병목을 기록한다.
- 예상 일반 플레이 peak는 약 300개로 시작하며, 후반 Stage·FX 통합 뒤 실제 telemetry로 다시 조정한다.

## 문서 우선순위

1. 사용자의 최신 명시적 지시
2. [`current/02_GAME_RULES.md`](current/02_GAME_RULES.md)
3. [`current/03_TECHNICAL_DESIGN.md`](current/03_TECHNICAL_DESIGN.md)
4. 현재 Slice 문서
5. Slice가 참조하는 `current/tasks/*.md`
6. [`current/05_IMPLEMENTATION_PLAN.md`](current/05_IMPLEMENTATION_PLAN.md)
7. 기존 코드 관례
