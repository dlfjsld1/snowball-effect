# Snowball Effect — 팀 구현 및 역할 분담 v0.2 반영안

> **STATUS: INITIAL / DRAFT**
>
> 역할을 고정하는 조직도가 아니다. 프로토타입 속도, Godot 적응도, 병목, 선호에 따라 재배치한다.

## 현재 3인 배정

| 담당자 | Lane |
|---|---|
| 본인 / 팀 리드 | Core Gameplay + Integration |
| 팀원 A | Presentation / UI |
| 팀원 B | Content / Systems / Release |

Integration은 네 번째 팀원이 아니라 본인/팀 리드가 Core와 함께 맡는 별도 작업 lane이다. Goal의 `Owner`는 사람 이름이 아니라 이 lane을 뜻한다.

## 1. Core Gameplay

책임:

- 중앙 배열 기반 Ball Simulation
- Paddle 이동·반사
- Merge commit
- Cashout 계산
- Stage runtime, tick 종료 중재, Settlement 계산
- Spatial Grid와 대량 공 성능
- Black Hole 논리 force

Core는 실제 게임 규칙을 소유하지만 Integration-owned coordinator를 직접 수정하지 않는다. 필요한 변경은 Signal/API 요청으로 제출한다.

## 2. Presentation / UI

책임:

- HUD: Stage Time, Stage Score, Run Score, Clear Target, Stage 이름
- Stage World, Machine Frame, 배경
- Merge/Cashout popup과 FX
- Final Settlement, Stage Clear, Scale Shift, CUT-IN 연출
- 게임플레이 신호를 화면 표현으로 변환

Presentation은 점수, 타이머, Merge, Stage 판정을 직접 수행하지 않는다.
S6에서는 시각 FX event tier를 확정하지만, 음원 asset/catalog·AudioManager·재생 우선순위·Web audio 활성화는 Content/Systems가 담당한다.

## 3. Content / Systems / Release

책임:

- BallDefinition, StageDefinition, ItemDefinition과 튜닝 seed
- Title, Pause, Result 화면의 자체 UI
- S6 audio asset/catalog, AudioManager, 재생 우선순위·polyphony, Web 첫 입력 audio 활성화
- Web Export, 브라우저 QA, 성능 기록, 공개 빌드 검증
- Core 안정화 뒤 Optional Item 구현

Content는 데이터 값을 소유하고 Core는 그 데이터를 소비한다. Retry가 실제 게임 상태를 초기화하는 연결은 Integration Point다.

## 4. Integration — 팀 리드

Core와 별도의 동시 작업 lane이다. 책임:

- Integration-owned 파일 잠금과 병합 승인
- Main 씬 조립
- GameManager/StageManager의 얇은 coordinator와 Signal 계약
- 프로젝트 Input/Autoload/전역 설정
- Retry, Stage 데이터 연결, Scale Shift 등 여러 영역을 가로지르는 wiring
- 통합 후 Desktop/Web 회귀 확인

Integration은 다른 트랙의 내부 구현을 대신 소유하지 않는다. 각 트랙의 공개 API를 조립하고 충돌 지점을 한 곳에서 합친다.

## 5. 병렬 실행

Shared Skeleton이 `VERIFIED`된 뒤 Core, Presentation, Content/Systems를 병렬화한다. 각 lane은 동시에 Goal 하나만 `IN PROGRESS`로 둔다. Integration lane은 준비된 API를 합칠 때 별도로 하나를 진행한다.

```text
Core ───────────────┐
Presentation ───────┼─→ Integration Goal → playable main
Content/Systems ────┘
```

## 6. 우선순위

- P0: 생성/이동, Paddle, Merge, Cashout, Time Bonus, Timer, Clear, Settlement, Shift, Result/Retry, Web
- P1: HUD, Stage World, 기본 FX, popup, Scale Shift presentation, sound
- P2: 고급 CUT-IN, Blizzard, Fire Core, Magnet, 고급 shader/왜곡/배경 animation

## 7. 재배치 조건

- 특정 lane이 병목 또는 유휴 상태가 됨
- Core 통합 대기가 길어짐
- Web/Release 문제가 예상보다 커짐
- 팀원이 더 적합한 영역을 빠르게 습득함
- 일정상 선택 기능을 잘라야 함

역할 변경 시 과거 Worklog는 수정하지 않고, 새 Owner와 효력 시작 Goal을 문서에 기록한다.
