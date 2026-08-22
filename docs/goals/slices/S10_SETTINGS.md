# S10 — Settings v1

원문: [`../../design/04_UI_FLOWS.md`](../../design/04_UI_FLOWS.md) §6, [`../../current/02_GAME_RULES.md`](../../current/02_GAME_RULES.md) Pause 메뉴 계약

> Slice Owner: **Content/Systems/Release 담당**
>
> Content/Systems/Release 담당이 S10의 범위·계약·수락 기준·릴리스 결정을 소유한다. S10-G1의 Integration-owned 구현은 완료된 handoff로 수락하며, 이후 `GameManager`·`main.tscn` 변경이 필요하면 동일 Goal의 범위를 넓히지 않고 별도 Integration 요청으로 처리한다.

## 결과

Title과 이미 구현된 Pause 모달의 Settings 버튼이 같은 Settings v1 panel을 열고, Master Volume·BGM Volume·SFX Volume과 Value Popups를 Web에서 안전하게 적용·저장·복원한다. 조작 중에는 즉시 미리 반영하고, Apply는 저장·종료, Close는 마지막 Apply 값 복원·종료를 수행한다. Settings를 닫아도 gameplay는 자동으로 재개되지 않는다.

## 범위

- 포함: 공유 Settings panel, Master/BGM/SFX Volume(각 0~10, 기본 5=authored baseline), Value Popups on/off, local persistence/default fallback, Title/Pause return view, keyboard/controller focus, Web 수락 검증.
- 제외: Pause 모달의 Resume/Retry/Main 동작 재구현, Stage Restart snapshot, Reduced Effects, gameplay rule·score·timer·SceneTree 직접 변경.

## Goals

### S10-G1 Settings adapter·state contract

- Owner: Content/Systems/Release 담당
- Owned Files: Content-owned S10 contract·acceptance evidence. 완료된 Integration handoff 산출물은 `scripts/core/settings_adapter.gd`, `scripts/core/game_manager.gd`, `scenes/main/main.tscn`, `tests/integration/s10_g1_**`다.
- Integration Point: Content가 panel의 `settings_open_requested(return_view)`, `settings_preview_requested(session_id, draft)`, `settings_apply_requested(session_id, draft)`, `settings_close_requested(session_id)`와 `settings_snapshot_changed(snapshot)`, `settings_closed(session_id, return_view)`의 계약을 소유한다. Integration handoff가 adapter와 Main wiring을 구현했다.
- Dependencies: S1-G5/S1-G6 Pause contract, S6-G4 AudioManager request mapping, S9-G2 Web baseline.
- Verification: Title/Pause origin과 session ID가 정확히 보존되고 stale/duplicate 요청이 state를 바꾸지 않는다. Master/BGM/SFX Volume은 preview에서 즉시 apply하고, Apply에서만 persist하며 Close는 마지막 Apply snapshot을 복원한다. Apply는 matching modal을 닫고 AudioManager의 music/effect channel 적용을 검증한다.
- Do Not Modify: Pause panel visual/layout, gameplay score/timer/simulation, 완료된 Integration-owned source의 직접 수정.

### S10-G2 Settings v1 panel

- Owner: Content/Systems/Release 담당
- Owned Files: `scripts/ui/settings*.gd`, `scenes/ui/settings*.tscn`, `tests/content/s10_g2_**`.
- Integration Point: S10-G1 Settings adapter의 session/snapshot signal만 사용한다. Content panel은 request signal만 내고 system API를 직접 호출하지 않는다.
- Dependencies: S10-G1 adapter contract와 기존 Title/Pause request signal.
- Verification: Main과 Pause가 하나의 panel instance/동일 setting model을 사용한다. Master/BGM/SFX Volume 0~10 설정을 즉시 preview하고 Apply/Close를 정확히 한 번 요청한다. 기본 level 5는 기존 authored 음량을 보존한다. Apply는 저장 후 original trigger로 돌아가며, Close는 uncommitted preview를 버리고 Main 또는 frozen Pause로 돌아간다. Settings open/close가 Resume을 유발하지 않는다.
- Do Not Modify: 기존 Pause Resume/Retry/Main semantics, AudioServer/DisplayServer/local storage, GameManager/StageManager.

### S10-G2I Settings panel wiring

- Owner: Integration
- Owned Files: `scripts/core/game_manager.gd`, `scenes/main/main.tscn`, `tests/integration/s10_g2i_**`.
- Integration Point: Title/Pause request → Settings adapter session → shared Content panel open, panel Apply/Close request → adapter, matching snapshot/close relay.
- Dependencies: S10-G1 VERIFIED, S10-G2 IMPLEMENTED.
- Verification: Main의 단일 panel이 Title/Pause 양쪽에서 같은 session model로 열리고, matching Apply/Close만 adapter와 panel을 갱신한다. Pause-origin close는 SceneTree paused 상태를 바꾸지 않는다.
- Do Not Modify: Content panel internals, Pause Resume/Retry/Main semantics, AudioServer/DisplayServer/local storage.

### S10-G3 Settings visual·focus

- Owner: Presentation
- Owned Files: `assets/sprites/ui/settings/**`, `docs/design/**`, `tests/presentation/s10_g3_**`.
- Integration Point: S10-G2 panel의 read-only state와 focus hooks를 소비한다.
- Dependencies: S10-G2 panel hierarchy/API.
- Verification: Title/Pause의 현행 시각 언어와 일치하고, 1280×720 및 720p에서 잘리지 않는다. keyboard/controller focus가 panel 안에 머물고 close 뒤 original trigger로 돌아간다.
- Do Not Modify: setting persistence, audio/fullscreen system calls, gameplay state.

### S10-G4 Settings Web acceptance·update

- Owner: Content/Systems/Release 담당
- Owned Files: `tests/release/s10_g4_**`, `docs/current/SUBMISSION/**`, release evidence.
- Integration Point: S10-G1~G3의 verified build를 read-only로 소비한다.
- Dependencies: S10-G1, S10-G2, S10-G3 IMPLEMENTED 및 통합 Web build.
- Verification: 실제 Chrome 또는 Edge 새 세션에서 Master/BGM/SFX volume·local persistence와 Title/Pause 각각의 close return을 확인한다. Console error 0, Retry/Main regression, Web export/itch.io update evidence를 기록한다.
- Do Not Modify: gameplay code, settings 구현 내부, 다른 Owner의 Worklog.

## Exit Gate

Q-S10: 실제 Web browser에서 새 세션 저장·복원, Pause 복귀 시 gameplay freeze 유지, user-gesture fullscreen fallback, Console error 0을 확인한다.
