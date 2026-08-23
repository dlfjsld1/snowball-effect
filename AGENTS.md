# AGENTS.md — Snowball Effect

이 저장소의 코딩 에이전트는 작업 전에 다음 문서를 순서대로 확인한다.

1. `docs/README.md`
2. `docs/goals/README.md`
3. `docs/goals/STATUS.md`
4. `docs/team/README.md`, `docs/team/OWNERSHIP.md`, `docs/team/INTEGRATION_CONTRACTS.md`
5. 현재 [`docs/goals/slices/S*.md`](docs/goals/slices/)
6. Slice가 참조하는 [`docs/current/tasks/*.md`](docs/current/tasks/)
7. 필요한 `docs/current/02_GAME_RULES.md`와 `docs/current/03_TECHNICAL_DESIGN.md`

---

## 구현 권한

기획, 문서 정리, 분석, 리뷰, 역할 분담, Goal 작성, Goal 재구성은 **구현 승인으로 간주하지 않는다.**

사용자가 명시적으로 구현, 코드 작성, 수정, 빌드, 버그 수정 등을 요청한 경우에만 게임 소스 구현을 시작한다.

문서 작업만 요청된 경우:

* 문서만 수정한다.
* `project.godot`, Scene, Script, Resource 등 런타임 파일을 만들거나 수정하지 않는다.
* Goal을 `IN PROGRESS` 또는 `IMPLEMENTED`로 임의 진행하지 않는다.
* 다음 Goal을 준비한다는 이유로 placeholder 구현을 만들지 않는다.

다음과 같은 지시는 기본적으로 문서 작업 승인이다.

* 기획에 반영해
* 문서 갱신해
* Goal 정리해
* 역할 분담 반영해
* 분석해
* 검토해

구현 여부가 명확하지 않은 경우 임의로 구현 범위를 확대하지 않는다.

---

## Goal 기반 작업

* `docs/goals/README.md`의 Slice 의존 순서를 따른다.
* Goal 상태와 검증 증거는 `docs/goals/STATUS.md`에서만 관리한다.
* 현재 Slice의 Goal ID 하나를 작업 단위로 사용하고 `Owner`, `Owned Files`, `Integration Point`, `Dependencies`, `Verification`을 먼저 확인한다.
* Core, Presentation, Content/Systems는 lane별로 `IN PROGRESS`를 최대 하나씩 둔다.
* Integration은 별도 lane으로 `IN PROGRESS`를 최대 하나 두며 대상 파일을 `STATUS.md`에서 잠근다.
* `project.godot`, `scenes/main/main.tscn`, `scripts/core/game_manager.gd`, `scripts/core/stage_manager.gd`는 Integration-owned다.
* 다른 Owner의 파일이 필요하면 직접 수정하기보다 Signal/API 요청을 우선한다.
* Retry 초기화, Stage 데이터 연결, Scale Shift wiring처럼 여러 영역이 만나는 작업은 별도 Integration Goal로 처리한다.
* 하나의 관찰 가능한 결과로 독립 검증할 수 없는 Goal은 구현 전에 더 작게 나눈다.
* Goal의 산출물, 검증, 제외 범위를 지키며 다음 Slice를 미리 구현하지 않는다.
* `docs/goals/QUALITY_GATES.md`의 Gate와 Evidence를 충족한 뒤에만 `VERIFIED`로 바꾼다.
* 검증할 수 없는 항목은 완료로 표시하지 않고 원인과 남은 확인 방법을 기록한다.
* Goal 완료 또는 의미 있는 commit/push 전 해당 `worklogs/*/WORKLOG.md`를 append한다.
* 역할과 소유권은 초기안이며 변경할 수 있다. 단, 변경 전 `docs/team/`과 현재 Goal 계약을 함께 갱신한다.

---

## Godot 검증 계약

Godot 도구는 다음 역할로 구분한다.

* Primary MCP: `godot` = `Erodenn/godot-mcp-runtime`
* Fallback MCP: `godot_fallback` = `Coding-Solo/godot-mcp`
* Baseline / source of truth: Godot CLI 또는 native 실행

평상시 Godot MCP 작업은 Primary인 `godot`을 우선 사용한다. 프로젝트/Scene 정보, 일반 Godot 작업, 게임 실행, Runtime Scene Tree, 입력 시뮬레이션, Screenshot, 실제 플레이 상태 검증이 대상이다.

`godot_fallback`은 Primary가 unavailable이거나 CLI/native 대조로 MCP/tooling 문제임이 확인된 경우에만, fallback이 지원하는 작업 범위에서 사용한다. 역할과 기능 차이를 무시하고 두 MCP를 상호 교환 가능한 것으로 취급하지 않는다.

### 1. Godot CLI / Headless — 기본 검증 경로

Godot CLI/headless를 프로젝트의 **baseline verification path**로 사용한다.

가능한 범위에서 다음을 먼저 확인한다.

* 프로젝트 로드
* Resource / Scene 로드
* GDScript parse 오류
* runtime error
* headless 실행
* 자동 검증 스크립트
* Export 가능 여부

MCP가 설치되어 있거나 정상 동작하더라도 CLI/headless 검증을 불필요하게 생략하지 않는다.

CLI/headless에서 실패한 경우 프로젝트 또는 구현 문제를 우선 조사한다.

### 2. Primary Godot MCP — `godot`

Godot MCP Runtime은 다음과 같이 **실제 런타임 관찰이 가치 있는 경우** 사용한다.

* 실제 게임 실행
* 키보드/마우스 입력 시뮬레이션
* Runtime Scene Tree 확인
* Screenshot 확인
* 화면 상태 확인
* 런타임 상호작용 재현

예:

```text
코드 수정
→ Godot CLI/headless 검증
→ MCP로 실제 게임 실행
→ A/D 또는 방향키 입력
→ 실제 상태/스크린샷 확인
```

MCP는 프로젝트의 필수 런타임 의존성이 아니라 **개발 및 검증 도구**다.

### MCP 오류 처리

**MCP 실패는 게임 코드 실패의 증거가 아니다.**

오류 분류 순서:

```text
Primary Erodenn 실패
→ Godot CLI/native로 프로젝트 자체 문제인지 확인

프로젝트도 실패
→ 프로젝트/게임 코드 문제 조사

프로젝트는 정상
→ MCP/tooling 문제로 분류
→ Coding-Solo fallback 사용 가능
```

Erodenn에서 한 번 실패했다는 이유만으로 즉시 Coding-Solo에서 같은 명령을 반복하지 않는다.

MCP 명령이 예상치 못하게 실패하거나 timeout, 연결 오류, 실행 오류가 발생하면:

1. 같은 프로젝트를 Godot CLI/headless 또는 일반 Native 실행으로 확인한다.
2. 프로젝트 문제와 MCP/tooling 문제를 구분한다.
3. MCP 문제라는 가능성을 배제하지 않은 상태에서 게임 코드를 수정하지 않는다.
4. MCP 오류만 해결하기 위해 게임 구조나 런타임 코드를 우회 수정하지 않는다.
5. 반복 재시도로 루프에 빠지지 않는다.
6. MCP가 계속 실패하면 해당 검증을 `UNVERIFIED — MCP/tooling issue`로 기록하고 다른 검증 경로를 사용한다.

특히 다음과 같은 흐름을 금지한다.

```text
MCP run 실패
→ 근거 없이 게임 코드 수정
→ MCP run 재실패
→ 추가 코드 수정
→ 반복
```

MCP 자체의 환경 문제, Godot 경로 문제, MCP bridge 문제, screenshot 문제 등은 게임 코드와 별개로 취급한다.

금지:

* 두 MCP 사이를 이유 없이 반복 전환
* 두 MCP로 같은 Godot 작업을 동시에 실행
* 중복 Godot 프로세스 실행
* MCP 실패만을 근거로 게임 코드 수정
* fallback MCP를 위해 게임 아키텍처 변경
* MCP 문제 해결을 이유로 현재 Goal 밖 구현 진행

### 2.1 Fallback Godot MCP — `godot_fallback`

Primary의 문제가 MCP/tooling 문제로 분류된 뒤에만 사용한다. Coding-Solo가 제공하는 프로젝트 정보, editor/project 실행, debug output, scene 관리 등 지원 범위 안에서만 호출한다. fallback 결과도 CLI/native baseline보다 높은 권한의 source of truth로 취급하지 않는다.

### 3. Web Browser — 최종 Web 검증

Snowball Effect의 제출 대상은 Web Build이므로 Native/MCP 실행 성공만으로 Web 동작을 보장하지 않는다.

Web 관련 Goal 또는 Release Gate에서는:

```text
Godot Web Export
→ Local HTTP Server
→ 실제 Browser
→ 입력
→ Canvas/화면 확인
→ Console Error 확인
```

과정을 검증한다.

가능하면 Playwright 등 브라우저 자동화를 활용할 수 있다.

브라우저 검증에서 확인할 항목:

* 페이지 정상 로드
* Godot Web Build 시작
* Canvas 표시
* 키 입력
* 주요 플레이 루프
* 브라우저 Console error
* 화면 크기 / 비율
* Web 환경 성능
* Retry
* Stage 전환
* Result

Native 또는 MCP에서만 성공하고 Browser에서 확인하지 못한 Web 관련 Goal은 `VERIFIED`로 올리지 않는다.

단, 해당 Goal의 계약 자체가 Web 검증 이전 단계라면 `QUALITY_GATES.md`에 정의된 범위에 따른다.

---

## 확정 게임 계약

* 기본 공 물리에는 지속적인 아래 방향 중력이 없으며 `gravity = 0`이다.
* Spawn 시 아래쪽 반구를 향하는 초기 velocity를 부여하고, 충돌이나 명시적 gameplay effect가 없으면 runtime velocity와 speed를 유지한다.
* Play Field의 좌·우·상단은 반사 경계이고 하단은 열린 Cashout 경계다.
* 성장 가능한 같은 level 일반 Snowball은 Merge한다. Merge하지 않는 서로 다른 level pair와 더 성장할 수 없는 현재 Stage 최고공 pair는 모두 mass/current velocity 기반 물리 collision으로 반사·분리한다.
* 일반 Snowball 본체 렌더는 active logical Play Field에서 clip하며 Cashout 중 Stage World나 기계 배경 위로 새지 않는다.
* `base_speed` 또는 Spawn speed는 초기 velocity를 만드는 기준값이지 runtime speed 고정값이 아니다.
* 현재 버전은 등급별 base speed 차이를 사용하지 않는다. 향후 도입할 수 있지만 runtime speed를 고정해서는 안 된다.
* Paddle 각도·접촉 위치·이동 속도는 반사 방향과 runtime speed를 바꿀 수 있으며, 폭주 방지 cap의 정확한 값은 tuning 대상이다.
* Merge 결과 velocity의 계승·방향·speed 계산은 S2의 별도 계약 전까지 확정하거나 구현하지 않는다.
* Stage 진입 시 `stage_score = 0`, `stage_time = StageDefinition.base_time`으로 초기화한다.
* `run_score`, 통계, 최고 기록은 Stage 사이에 유지한다.
* 모든 점수 이벤트는 `stage_score`와 `run_score`에 같은 amount를 한 번씩 더한다.
* Stage 종료 시 `run_score += stage_score`를 하지 않는다.
* Time Bonus는 `StageDefinition.time_bonus_by_local_level`에서 현재 Stage의 local level로 구한다.
* 한 physics tick은 tick 시작 남은 시간 안의 **유효 gameplay 구간**과 정확한 제한시간 이후 구간을 구분한다. 이동/충돌/Merge/Active Cashout은 제한시간 전 유효 구간에서 발생한 이벤트만 commit한다.
* 제한시간 전에 하단을 통과한 Active Cashout은 점수와 Time Bonus를 정상 적용하며, 보너스로 시간이 양수가 되면 `PLAYING`을 유지한다. 이는 제한시간 후 부활이 아니라 막판 Cashout 성공이다.
* 제한시간 전에 시간을 연장한 유효 Cashout이 없으면 정확한 0초에 `TIME_UP_LOCKED`로 전환한다. 이후 하단 통과는 Active Cashout으로 인정하지 않고, 남은 공은 Time Bonus 없는 Final Settlement로 처리한다.
* 유효 gameplay 구간 안에서 local Lv4가 생성되어도 local Lv4 자체는 종료 사유가 아니다. Merge/discovery와 제한시간 전 Cashout을 commit한 뒤 남은 시간이 없으면 Time Up 경로를 사용한다.
* Ground/Planetary의 local Lv4 Top Ball 생성은 즉시 Clear 조건이 아니다. non-final Stage는 유효 Cashout 반영 후 `stage_score >= clear_score`면 즉시 Score Clear하고, 그전에 Time Up이 잠기면 Final Settlement 후 `clear_score` 성공/실패를 판정한다.
* 마지막 Galactic의 첫 Lv14 Black Hole은 Run 내 최초 CUT-IN 뒤 이동 Black Hole 기믹으로 전환하고 L3 국면을 활성화하며, 두 번째 Black Hole과 충돌할 때 최종 Run End를 잠근다.
* 이동 Black Hole은 하단에서 반사하고 성장·일반 Merge하지 않는다. 모든 일반 Snowball은 실제 Black Hole contact에서 흡수되며, 흡수 패널티는 해당 공의 Cashout 가치 `12.5%`와 첫 Black Hole 등장 시점 Run Score의 `25%` 중 작은 값이다. 이를 Stage Score와 Run Score에서 각각 차감하고, `run_score`가 0이 되면 즉시 Run End다.
* Final Settlement는 active ball snapshot의 base `score_value`만 한 번 반영하고 Time Bonus, Cashout 전용 modifier, 추가 Merge를 적용하지 않는다.
* Settlement는 중복 호출에 안전해야 한다.
* Core와 Optional Item Layer를 분리하며 Fire가 없어져도 코어 규칙이 바뀌지 않게 한다.

---

## 문서 우선순위

내용이 충돌하면 다음 순서를 따른다.

1. 사용자의 최신 명시적 지시
2. `docs/current/02_GAME_RULES.md`
3. `docs/current/03_TECHNICAL_DESIGN.md`
4. 현재 `docs/goals/slices/S*.md`
5. Slice가 참조하는 `docs/current/tasks/*.md`
6. `docs/current/05_IMPLEMENTATION_PLAN.md`
7. 기존 코드의 관례

---

## 절대 규칙

* Godot 4.x 문법과 API만 사용한다.
* 저레벨 공을 개별 `RigidBody2D`, 개별 씬 인스턴스, 개별 `_physics_process`로 만들지 않는다.
* 중앙 배열 기반 시뮬레이션과 비활성 슬롯 재사용 방식을 유지한다.
* 모든 공 쌍의 O(N²) 전수 비교를 최종 구조에 남기지 않는다.
* 게임 규칙용 공과 장식용 파티클을 분리한다.
* 요청하지 않은 대규모 리팩터링을 하지 않는다.
* 각 Goal과 Slice가 끝날 때 프로젝트를 실행 가능한 상태로 유지한다.
* MCP 전용 편의를 위해 게임 코드나 아키텍처를 종속시키지 않는다.
* MCP가 없어도 Godot CLI/native 실행을 통해 프로젝트를 개발·검증할 수 있어야 한다.
* 테스트 도구의 오류와 게임 자체의 오류를 구분한다.

---

## 작업 보고

* 작업한 Slice와 Goal ID
* Owner lane과 변경한 Owned Files
* 사용하거나 변경한 Integration Point와 lock 상태
* 구현한 내용과 의도적으로 제외한 내용
* 변경 파일
* 실행 및 검증 방법
* Godot CLI/headless 검증 결과
* MCP를 사용했다면 MCP 검증 결과와 확인한 항목
* MCP 오류가 있었다면 프로젝트 오류와 도구 오류를 어떻게 구분했는지
* Web Goal이라면 실제 Browser/Web 검증 결과와 환경
* 실제 성능 수치
* 갱신한 Worklog 경로
* 알려진 문제와 다음 권장 Goal
