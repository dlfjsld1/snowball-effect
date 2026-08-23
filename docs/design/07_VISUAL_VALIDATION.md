# 07. Visual Validation

Status: APPROVED PLAN — future runtime evidence remains unverified  
Owner: Presentation with Goal-specific QA partners  
Purpose: “예뻐 보인다”를 반복 가능한 evidence로 바꾼다.

## 1. Validation Layers

| Layer | 질문 | Evidence |
|---|---|---|
| Structure | Frame, Field, Stage World, HUD의 순서가 읽히는가? | grayscale comparison |
| Readability | Ball/Paddle/boundary/text가 구분되는가? | contrast + 5-second test |
| State | Merge/Clear/Failure/Shift가 혼동되지 않는가? | state sheet/storyboard |
| Motion | event 원인과 결과가 시간 순서로 읽히는가? | capture/animatic |
| Density | 많은 공과 FX에서도 핵심이 남는가? | 100/500/1000 stress capture |
| Web | resize/focus/audio/Canvas가 실제 브라우저에서 정상인가? | browser screenshots/log |
| Performance | presentation budget이 gameplay를 해치지 않는가? | frame-time, effect counts |

## 2. Required Review Boards

1. **Frame comparison:** V5 fixed-width bezel과 Initial/L1/L2/Black Hole Phase L3를 같은 scale로 배치.
2. **HUD movement:** Stage 이름·Time·Stage Score/Target·세로 5칸 progressive Ball Progression·Run Score와 active effect 0/1/3개를 같은 폭의 side panel에서 검증.
3. **Ball hierarchy:** 15개 global concept comparison과 Plan 1 Stage별 5종 grouping.
4. **Event tiers:** T0~T4 representative frame과 duration.
5. **Scale Shift:** 7-beat storyboard 또는 3초 이내 후보 animatic.
6. **Responsive Web:** 720p/768p/900p/1080p key screenshots.
7. **Late-density:** normal FX와 throttled FX 비교.
8. **Item Box:** 3 rarity, intact/crack/break/reveal/miss/paused states와 Merge/Cashout shape comparison.
9. **UI flow:** Main/Pause/confirm/Settings/Result focus and return-state board.
10. **V4 gameplay FX:** Compression Bloom, Salvage Burst, Cabinet Score Lock의 keyframe과 reduced recipe 비교.

현재 승인된 팀 공유 mockup은 [WIREFRAME_DYNAMIC_PLAYFIELD.html](WIREFRAME_DYNAMIC_PLAYFIELD.html)과 [WIREFRAME_DYNAMIC_PLAYFIELD.png](WIREFRAME_DYNAMIC_PLAYFIELD.png)이고, 제작 기준은 [10_APPROVED_VISUAL_DIRECTION_V5.md](10_APPROVED_VISUAL_DIRECTION_V5.md)다.

## 3. Five-second Comprehension Test

디자인 작업에 직접 참여하지 않은 관찰자 최소 5명에게 label 없는 정지 화면을 5초 보여준 뒤 묻는다.

1. 조작하는 오브젝트는 무엇인가?
2. 공이 빠져나가는 방향은 어디인가?
3. 가장 중요한 공/사건은 무엇인가?
4. 현재 Stage가 이전보다 넓어졌는가?
5. 장식과 gameplay object를 구분할 수 있는가?

관찰자 5명 중 최소 4명이 질문 1(Paddle), 2(Cashout 방향), 4(폭 확장)를 모두 맞히고, 전체 응답 정확도가 80% 이상이어야 hierarchy를 승인한다. 오답은 색을 더하기 전에 size, position, silhouette, spacing으로 먼저 수정한다.

Ball ordering test는 15개 silhouette을 무작위 배열한 뒤 성장 순서와 Stage grouping을 맞히게 한다. 참가자의 80% 이상이 전체 성장 방향을 맞히고, 각 Stage에서 인접 등급 혼동 쌍이 2개 이하여야 한다. 기본 Run의 3×5 chain과 Lv7 Red Giant/Lv9 Nebula를 포함한 catalog sandbox를 별도 sheet로 테스트한다. 참가자가 Lv14 Black Hole Ball과 이동 Black Hole 맵 기믹을 같은 runtime entity로 오인하면 실패다.

Item Box test는 label 없이 Common/Rare/Epic의 상대 희귀도, 손상 진행, 파괴/놓침 결과를 묻는다. 색을 제거해도 border notch, core shape, crack 수로 세 rarity의 순서가 읽혀야 한다.

## 4. Contrast Checks

- gameplay Ball과 바로 인접한 background의 비텍스트 대비 3:1 목표.
- Paddle과 모든 Stage field background 대비 3:1 목표.
- 일반 텍스트 4.5:1, 큰 텍스트 3:1 목표.
- focus outline 3:1 목표.
- grayscale에서도 T3/T4 state와 기본 gameplay가 구분되어야 한다.
- glow/flash를 끈 capture를 항상 함께 저장한다.

자동 contrast 계산은 보조 evidence이며 pixel outline, 움직임, 주변 pattern을 실제 capture로 함께 판단한다.

## 5. Responsive Matrix

| Viewport | Scale risk | Required capture |
|---|---|---|
| 1280×720 | 1px detail, compact text | Playing L2, Black Hole Phase L3, Pause/Settings, Result |
| 1366×768 | fractional scale | Playing L0/L2, Black Hole Phase L3, HUD/effect stress |
| 1600×900 | authoring source | all keyframes |
| 1920×1080 | fractional logical scale | Shift, Title, Result |
| 2560×1440 | excess void/upscale | Playing L2, Black Hole Phase L3/Result |
| non-16:9 | letterbox/input mapping | left/right or top/bottom bars |

Frame profile은 viewport 크기 때문에 바뀌지 않아야 한다. Stage profile과 viewport scale을 독립 변수로 테스트한다.

Design support floor는 desktop landscape `1280×720`이다. `1024×768`은 browser/engine smoke evidence로만 기록하고 gameplay readability pass를 주장하지 않는다. portrait/mobile과 1280×720 미만은 이번 release 범위에서 제외한다.

## 6. Dynamic Play Field Verification

### Static

- target visual field width와 data profile width 비교.
- center x가 모든 단계에서 동일.
- 좌우 frame thickness와 safe inset 대칭.
- Cashout edge가 새 field width 전체를 반영.

### Runtime — implementation Goal 이후

- current/target profile debug overlay를 capture.
- Shift 중 simulation/timer/spawn 정지 확인.
- Presentation finish signal once-only 확인.
- Shift 각 beat의 Restart에서 이전 `run_epoch` finish가 무시되는지 확인.
- 다음 Stage 첫 tick의 collision/spawn/paddle bounds 확인.
- resize 뒤 mouse mapping과 visual cursor/target alignment 확인.

## 7. HUD Validation

다음 authoritative field와 stress payload를 사용한다.

- Stage 이름, Time, Stage Score/Target, current Stage Ball Progression 세로 5칸의 reveal 1/2/5, Run Score, Pause.
- active effect 0개/1개 expanded/3개 compact.
- shortest/longest item name.
- score `0`, `999`, suffix 전환 직전/직후, 최대 suffix, scientific notation 전환, NaN/Infinity fallback.
- time `0`, `9`, `999`, `1000`, `9999`와 overflow fallback. 현재 time cap이 없으므로 3자리만 가정하지 않는다.
- localization expansion 1.5×.
- effect hidden/appearing/refresh/independent expiry.
- discrete snapshot 즉시 갱신, timer/effect countdown 최대 10Hz, 같은 값 Control rewrite 없음.

Stage name은 persistent HUD 필수다. Ball Count와 highest Ball은 persistent HUD에 임의로 추가하지 않는다. 4개 이상 effect가 동시에 활성 가능해지면 별도 capacity review 없이 release scope에 넣지 않는다.

## 8. Motion Review

- event 발생 frame, recognition frame, 완료 frame을 표시한다.
- 같은 tick 우선순위가 있는 Clear/Time Up/Cashout scenario를 각각 capture한다.
- repeated Merge burst에서 popup/particle/audio가 무한 중첩되지 않는다.
- Shift animation이 Frame만 키우고 Field를 뒤늦게 따라오게 하지 않는다.
- control return 전에 HUD reflow와 logical profile activation이 완료된다.
- secondary shake/flash/particle를 제거한 reference capture에서도 state transition을 읽을 수 있다.
- Merge의 수렴, Cashout의 하강, Item Box break의 방사형 개방이 grayscale에서도 구분된다.

## 9. UI State Verification

- Main Screen의 Start/Settings focus와 Settings close return을 확인한다.
- Pause에서 Resume 기본 focus, Esc Resume, focus trap, Settings round trip을 확인한다.
- Restart Stage/Main Screen confirmation의 기본 focus가 Cancel이고 request가 한 번만 발생한다.
- focus loss는 자동 Pause하지만 focus return은 자동 Resume하지 않는다.
- Stage Restart 뒤 Stage Score 0, Run Score/통계/effect가 entry snapshot과 일치하고 stale Box/FX/event가 없다.
- Result의 Retry Run은 전체 state를 초기화하고 Pause의 Restart Stage와 signal/API가 다르다.
- local settings를 새 session에서 복원하고 storage 실패 시 safe fallback을 확인한다.

## 10. Performance Evidence Plan

구현 뒤 실제 수치를 기록하며 현재 문서에서 측정 결과를 주장하지 않는다.

### Reproduction contract

- build: release candidate, debug-only drawing과 profiler overlay는 측정 capture를 방해하지 않는 read-only counter만 사용.
- viewport: 1600×900을 기본으로 하고 1280×720 late-density browser pass를 추가.
- runtime: scenario 진입 후 10초 warm-up, 이어서 최소 30초 측정.
- determinism: fixed seed가 있으면 seed를 고정하고, 없으면 spawn rate·Stage profile·active ball setup과 build hash를 기록.
- environment: OS, CPU, GPU, RAM, browser 이름/정확한 버전, native 또는 Web 여부를 기록.
- repetitions: 각 scenario 3회, average/min FPS와 p95/worst frame time을 모두 보존.
- reference: 첫 승인 S4 Core-only evidence의 장비, 정확한 browser version, viewport, release preset, fixed seed를 canonical reference로 기록한다. Presentation-on 측정은 같은 session 또는 같은 환경에서 연속 실행한다.

수집 항목:

- active ball count.
- event 발생 수/초.
- active effect instance count by tier.
- effect pool size와 drop/throttle count.
- average/worst frame time during normal and burst.
- Web browser, viewport, device/GPU, build hash.

측정 scenario:

1. 100 balls, normal Merge cadence.
2. 500 balls, sustained collision/Merge.
3. 1000 balls, T0/T1 throttled.
4. T3 Clear during dense field.
5. Scale Shift and HUD reflow.
6. Item Box simultaneous impact/break burst during 500-ball play.
7. Pause/Settings open-close와 Stage Restart cleanup.

### Quantitative pass criteria

- repository baseline gate: 1,000 logical balls에서 **최저 30 FPS 이상**. 60 FPS는 desktop browser target이다.
- v1 normal 100/500-ball Web scenario: team reference machine에서 median 60 FPS, 1% low 50 FPS 이상. 미달 시 실제 수치와 병목을 기록하고 관련 Goal을 완료로 표시하지 않는다.
- Presentation regression: canonical S4 Core-only baseline과 같은 환경에서 FX 적용 후 p95 frame time 증가가 10% 이내이고, 어떤 경우에도 1,000-ball 30 FPS floor를 깨지 않는다. 절대 FPS와 상대 regression 중 하나라도 실패하면 FAIL이다.
- T3/T4 event drop: 0. 동일 event의 duplicate critical presentation: 0.
- T0/T1 drop/throttle은 허용하지만 발생 수, 표시 수, drop 수를 기록하고 active effect count가 S6-G1에서 승인한 cap을 넘지 않는다.
- popup/particle/tween/node count가 event 수에 따라 무제한 증가하면 FAIL.

S6-G1 Entry Gate에서 tier별 cap이 아직 비어 있으면 performance implementation을 시작하지 않는다. 이 수치들은 S4 baseline과 실제 Web measurement를 보고 확정한다.

## 10.1 Hybrid Screenshot Regression

- fixed seed/debug fixture로 HUD, Frame, Black Hole Phase L3 gameplay, Pause, Result key state를 재현한다.
- HUD housing, Frame edge, focus outline, safe inset 같은 안정 영역은 screenshot diff threshold로 자동 비교한다.
- particle, glow, Tween 중간 frame, GPU 노이즈 영역은 mask하고 motion/state sheet를 사람이 승인한다.
- baseline 갱신은 해당 Goal의 visual change 설명과 before/after evidence가 있을 때만 허용한다.

## 11. Approval Gates

### Design Gate

- foundation, Frame comparison, HUD status, Goal roadmap가 팀에 승인됨.

### Goal Entry Gate

- dependencies verified.
- event/API/data contract fixed.
- Owned Files와 Integration lock 확인.
- required state sheet 준비.

### Presentation Goal Exit Gate

- Goal verification 통과.
- Godot CLI/headless baseline 성공.
- runtime 관찰이 필요한 경우 Primary Godot MCP로 capture.
- Web 관련 Goal이면 실제 export + local HTTP + browser input/console/resize 확인.
- Worklog에 evidence와 실제 성능 수치 append.

MCP 실패만으로 게임 코드를 수정하지 않으며 CLI/native로 프로젝트 문제와 tooling 문제를 구분한다.

## 12. Evidence Naming

```text
{slice}-{goal}_{viewport}_{state}_{date}.{png|webm|md}
```

예시:

- `S5-G4_1600x900_shift-l2_2026-08-10.png`
- `S6-G1_1280x720_1000balls-throttled_2026-08-10.webm`
- `S9-G2_1366x768_browser-resize_2026-08-10.md`

## 13. Current Verification Result

- Documentation/link review: 2026-08-11 local relative links and Markdown fence/heading structure passed.
- Design plan review: 7개 pass와 independent design voice, blocking issue 0, final quality score 9/10.
- Wireframe render: 2026-08-12 system Chrome headless로 V5 Frames/Main/Ground/Planetary/Galactic/Black Hole Phase/Pause/FX를 1600×900에, Black Hole Phase를 1280×720에 렌더했다. PNG 9개가 생성됐고, 1600 화면의 HUD/field/controls와 1280 화면의 수평 layout 및 최소 text size를 육안 확인했다.
- 첫 Chrome 실행은 Windows GPU process 문제로 실패했으나, 별도 임시 profile + software rendering으로 같은 HTML을 성공 렌더해 목업 오류가 아닌 도구 환경 문제로 분류했다. Chrome의 Google Update registry warning은 screenshot 결과에 영향을 주지 않았다.
- `browse` binary는 unavailable이어서 새 dependency를 설치하지 않고 system Chrome으로 대조했다.
- Godot CLI/headless: not run — documents and design artifacts only.
- Godot MCP: not used.
- Web game build/browser QA: not run — no runtime implementation or release Goal change.
- Performance: not measured; collection plan only.
- Contract sync: 3-Stage route, non-contiguous Stage Merge lookup, 2인자 `ball_merged`, Stage 이름/세로 progressive HUD, Galactic Black Hole Phase를 rules/technical/slice에 반영했다. runtime Resource/code는 아직 최신 catalog/phase 계약을 구현하지 않았다.
- Eng review implementation: typed HUD/Result proposal, progressive Ball Progression, `run_epoch + correlation_id`, tier pool, Black Hole Phase L3 fixture, hybrid screenshot, absolute+relative performance gate를 문서에 반영했다. 실제 runtime evidence는 여전히 없음.
- V5 mockup adoption: 2026-08-12 Frozen Enamel Main/Playing/Pause, slim fixed-width bezel, Merge/Item/Milestone FX와 Black Hole Phase 방향을 사용자 결정에 맞춰 갱신했다. 이는 visual evidence이며 Godot runtime evidence가 아니다.
