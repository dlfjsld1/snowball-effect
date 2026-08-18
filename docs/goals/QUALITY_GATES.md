# Quality Gates

## Goal 공통 Gate

- G0-A: 변경 파일이 Goal 산출물과 직접 연결된다.
- G0-B: 파싱 오류와 치명 런타임 오류가 없다.
- G0-C: 기존 `VERIFIED` Goal의 핵심 시나리오가 회귀하지 않는다.
- G0-D: 실행 명령, 환경, 실제 결과를 `STATUS.md`에 기록한다.
- G0-E: Goal의 Owner와 실제 변경 파일이 `Owned Files` 계약에 맞는다.
- G0-F: 교차 영역 연결은 선언된 `Integration Point`만 사용한다.
- G0-G: Goal 완료/commit/push 전 해당 lane Worklog를 append한다.
- G0-H: Verification은 특정 MCP 제품명이 아니라 관찰된 동작과 결과를 기준으로 한다. 특정 실행 환경 자체가 계약인 Web Goal 등은 실제 해당 환경에서 검증한다.

## Integration Gate

- I-A: 활성 Integration Goal, 담당자, 잠긴 파일을 `STATUS.md`에 기록한다.
- I-B: Producer/Consumer Signal 또는 API signature와 호출 순서를 기록한다.
- I-C: 다른 Owner의 내부 파일을 Integration 편의 때문에 직접 수정하지 않는다.
- I-D: 통합 후 관련 Owner의 Verification과 기존 회귀 시나리오를 다시 실행한다.
- I-E: 완료 후 lock을 해제하고 Integration Worklog에 결과를 append한다.

## Slice 종료 Gate

- Desktop smoke: 메인 씬 실행, 목표 시나리오, 종료 또는 재시작이 정상이다.
- Web smoke: Export 성공, 브라우저 로드, 입력 포커스, console fatal error 없음.
- State reset: Retry 또는 재진입 후 이전 배열·점수·잠금이 남지 않는다.
- Evidence honesty: 측정하지 않은 FPS, 시간, 브라우저 결과를 추정해 적지 않는다.

## 기능별 Gate

| Gate | 필수 확인 |
|---|---|
| Q-S0 | Godot 4에서 Main 씬이 1600×900 기준으로 열림; Web smoke |
| Q-S1 | 100개 활성 공, gravity 0과 무상호작용 velocity 유지, 좌·우·상단 반사/열린 하단, Mouse logical-X 직접 반영 및 키보드 fallback, 이동+무제한 회전 동시 입력, previous/current transform 기반 continuous 양면 Paddle collision, center+angular contact velocity 후 impact cap, 중심/끝·회전 방향별 반사, penetration/contact lock, Cashout 1회 반영 |
| Q-S2 | 동일 레벨만 Merge, 입력 둘 제거·출력 하나 생성, 한 쌍 한 번 처리 |
| Q-S3 | Cashout 시간 구조, local Lv4 비종료, 중복 Settlement, score source-of-truth와 gauge 회귀 테스트 |
| Q-S4 | release path에 전수 O(N²) 없음, 실제 Web 동시 활성 500개에서 최저 30 FPS 이상, 1,000개 stretch FPS·allocation·병목 관찰 기록 |
| Q-S5 | ordered Stage chain(`6→8→10`)과 5종 세로 progressive HUD, Stage별 reset/preserve, Score Clear 축하 확인 뒤 shift, Galactic alpha 배경, 세 Stage 연속 완주 |
| Q-S6 | burst에서도 패들·공 가독성, FX budget 작동, 중요한 이벤트 우선 |
| Q-S7 | Stage당 Item Ball 1회, local Lv3+ 공의 유효 5-hit 파괴, 파괴 후 item별 Orb 생성, Paddle 획득 뒤 CUT-IN·1회 activation, 하단 miss 시 미적용·소멸, 아이템 비활성화 시 Core 결과 동일, Fire modifier가 Settlement에 침투하지 않음 |
| Q-S8 | 첫 Lv14→이동 Black Hole 전환, L2→L3 Frame/Play Field 동기 확장 후 gameplay 재개, 저등급 흡수의 Cashout `12.5%`/phase-entry Run Score `25%` 상한 패널티·단일 저등급 흡수 즉사 방지·반복 손실의 run score 0 Game Over·다중 pull vector 합산/cap·Black Hole 상호 인력·하단 반사·비성장 안정성, 두 번째 Black Hole과 접촉 시 1회 finale→UI 제거→타이틀/Clear Score/Main Menu, Retry 완전 초기화 |
| Q-S9 | 공개 URL incognito 완주, Chrome/Edge, console, resize, 오디오 활성화 확인 |

## S3 필수 회귀 시나리오

1. `stage_time=0.03`인 tick에서 시간 차감 후 Cashout `+1.0` → `PLAYING` 유지.
2. 같은 tick에 local Lv4와 `stage_time<=0` → Merge/Cashout commit 뒤 `TIME_UP_LOCKED`; local Lv4만 생성하면 `PLAYING` 유지.
3. Settlement 완료 신호 두 번 → 점수 한 번만 증가.
4. Cashout amount 10 → stage/run 각각 10 증가, Stage 종료 시 run 추가 증가 없음.
5. Settlement 대상에 cashout-only modifier가 있어도 base `score_value`만 반영.
6. non-final Score Clear 뒤 `Next Stage` 전에는 Shift 없음; matching 요청 뒤 한 번만 Shift.
