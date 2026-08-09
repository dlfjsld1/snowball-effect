# S9 — Web Release

원문: [`../../current/tasks/08_web_export_release.md`](../../current/tasks/08_web_export_release.md), [`../../current/tasks/09_submission_package.md`](../../current/tasks/09_submission_package.md)

## 결과

설치·로그인 없이 공개 URL에서 Stage 기반 한 판과 Retry가 가능한 제출 빌드를 만든다.

## Goals

### S9-G1 Release tuning과 telemetry

- Owner: Content/Systems
- Owned Files: `resources/stages/**`, `tests/release/**`, release 측정 문서.
- Integration Point: Core의 read-only Stage 체류/Cashout/local level metric을 소비; data reload 요청은 Integration 계약 사용.
- Dependencies: S6, S8 완료; S7은 선택.
- Verification: 실제 Stage 체류, Cashout 총/초당 획득 시간, local level별 횟수 기록; 근거가 있을 때만 time cap 별도 제안.
- Do Not Modify: Stage runtime와 telemetry 계산 내부.

### S9-G2 Web export와 browser QA

- Owner: Content/Systems
- Owned Files: `export_presets.cfg`, `tests/release/**`, 로컬 `build/` 산출물.
- Integration Point: `project.godot` 또는 Main wiring 변경은 lock된 Integration Goal로 요청.
- Dependencies: S9-G1과 release candidate 통합 build.
- Verification: Chrome/Edge incognito 완주; focus, resize, audio, console, Retry, late-game FPS 기록.
- Do Not Modify: `project.godot`, Main scene, gameplay/presentation 내부.

### S9-G3 Public link와 submission

- Owner: Content/Systems
- Owned Files: `docs/current/SUBMISSION/**`, 제출용 media/copy 산출물, release 기록.
- Integration Point: 실제 Git/Worklog Evidence와 public build URL을 소비.
- Dependencies: S9-G2 `VERIFIED`와 외부 hosting.
- Verification: public URL을 새 세션/가능하면 다른 장치에서 검사; thumbnail/video/200자 소개/실제 Codex evidence 준비; 미측정 주장 없음.
- Do Not Modify: gameplay code와 다른 Owner의 과거 Worklog.

## Exit Gate

Q-S9와 Release Checklist 완료.
