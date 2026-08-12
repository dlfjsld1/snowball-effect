# Snowball Effect Execution Goals

이 문서는 기획 Phase를 구현 가능한 Vertical Slice와 독립 검증 가능한 Goal로 재구성한 실행 지도다. 상세 상태와 Evidence는 [`STATUS.md`](STATUS.md) 한 곳에서만 갱신한다.

## 상태 정의

- `PENDING`: 선행 조건이 끝나지 않았거나 아직 시작하지 않음
- `IN PROGRESS`: 해당 Owner lane에서 현재 작업 중인 Goal
- `IMPLEMENTED`: 산출물은 있으나 필수 검증이 남음
- `VERIFIED`: Gate와 Evidence를 모두 충족
- `BLOCKED`: 외부 조건 때문에 검증 또는 구현을 진행할 수 없음

## Slice 순서

| Slice | 관찰 가능한 결과 | 필수 선행 | 원문 |
|---|---|---|---|
| S0 | Godot 프로젝트가 데스크톱과 Web에서 빈 Main을 연다 | 없음 | Phase 0 |
| S1 | 생성→낙하→패들 반사→Active Cashout이 플레이 가능하다 | S0 | Task 01 |
| S2 | 같은 레벨 공이 결정적으로 합체하고 데이터 점수가 반영된다 | S1 | Task 02 |
| S3 | Stage Timer, Time Bonus, Clear, Settlement 계약이 동작한다 | S2 | Task 02.5 |
| S4 | Spatial Grid 기반으로 논리 공 1,000개를 감당한다 | S2 | Task 03 |
| S5 | Ground→Planetary→Galactic Scale Shift가 완주 가능하다 | S3, S4 | Task 04 |
| S6 | 이벤트 중요도에 맞는 읽기 쉬운 효과와 사운드가 적용된다 | S5 | Task 05 |
| S7 | Optional Item Layer가 코어 계약을 바꾸지 않고 동작한다 | S5 | Task 06 |
| S8 | Galactic 내부 Black Hole 최종 국면과 Final Result가 동작한다 | S5 | Task 07 |
| S9 | Stage 기반 한 판을 Public Web Build로 제출할 수 있다 | S6, S8; S7 선택 | Task 08/09 |

## Owner lanes

| Lane | 동시 `IN PROGRESS` 상한 | 주 책임 |
|---|---:|---|
| Core | 1 | gameplay rule, simulation, physics, runtime 계산 |
| Presentation | 1 | HUD, 배경, FX, CUT-IN, 화면 표현 |
| Content/Systems | 1 | data, 화면 시스템, audio, release |
| Integration | 1 | 공동 접점 파일, Signal wiring, 상태 흐름 통합 |

Core/Presentation/Content의 세 Goal은 선행 조건과 Integration 계약이 충족되면 병렬로 진행할 수 있다. Integration은 별도 lane이며 준비된 결과를 공동 접점에 합칠 때 사용한다.

## 모든 Goal의 필수 계약

각 Goal은 구현 전에 아래 다섯 필드를 가져야 한다.

- `Owner`: 작업 lane
- `Owned Files`: 직접 변경 가능한 경로
- `Integration Point`: 다른 Owner와 주고받을 Signal/API 또는 `None`
- `Dependencies`: 시작 전 필요한 Goal/계약
- `Verification`: 독립적으로 관찰할 완료 조건

`Owned Files` 밖의 변경이 필요하면 직접 수정하기보다 Signal/API 요청을 먼저 한다. `project.godot`, `Main.tscn`, `GameManager`, `StageManager`는 [`../team/OWNERSHIP.md`](../team/OWNERSHIP.md)의 Integration-owned 규칙을 따른다.

## 실행 규칙

1. Goal의 Dependencies와 Owner 계약을 확인한다.
2. 해당 Owner lane에 다른 `IN PROGRESS`가 없을 때만 상태를 변경한다.
3. Integration-owned 파일 변경은 별도 Integration Goal과 lock을 `STATUS.md`에 등록한다.
4. Goal의 `Owned Files`만 직접 수정한다.
5. Verification과 해당 Quality Gate를 실행하고 실제 Evidence를 기록한다.
6. Goal 완료 또는 의미 있는 commit/push 전에 해당 `worklogs/*/WORKLOG.md`를 append한다.
7. Desktop과 Web smoke를 모두 통과해야 Slice를 완료한다.

Optional Item인 S7은 S9의 필수 선행이 아니다. 일정이 부족하면 S7을 잘라도 Core 흐름과 문서는 바뀌지 않는다.

역할, 파일 소유권, Goal 분해는 모두 초기안이다. 병목에 따라 바꿀 수 있지만 변경 시 [`../team/`](../team/)과 `STATUS.md`를 함께 갱신한다.

## Slice 문서

- [`S0_BOOTSTRAP.md`](slices/S0_BOOTSTRAP.md)
- [`S1_MINIMUM_LOOP.md`](slices/S1_MINIMUM_LOOP.md)
- [`S2_MERGE_SCORE.md`](slices/S2_MERGE_SCORE.md)
- [`S3_STAGE_CONTRACT.md`](slices/S3_STAGE_CONTRACT.md)
- [`S4_MASS_SIMULATION.md`](slices/S4_MASS_SIMULATION.md)
- [`S5_SCALE_SHIFT.md`](slices/S5_SCALE_SHIFT.md)
- [`S6_GAME_FEEL.md`](slices/S6_GAME_FEEL.md)
- [`S7_OPTIONAL_ITEMS.md`](slices/S7_OPTIONAL_ITEMS.md)
- [`S8_BLACK_HOLE.md`](slices/S8_BLACK_HOLE.md)
- [`S9_WEB_RELEASE.md`](slices/S9_WEB_RELEASE.md)
