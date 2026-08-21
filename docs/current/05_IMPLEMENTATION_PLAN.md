# Snowball Effect — Implementation Plan

## 공식 제출 게이트

- 공식 Track 1 접수 마감: **2026-08-26**
- 내부 기능 동결 목표: **2026-08-25**
- 브라우저 직접 실행 Web Build는 필수다.
- 선택 기능보다 Playability, public URL, 결과/Retry, 실제 플레이 영상 준비를 우선한다.
- 실제 Codex 작업은 `SUBMISSION/02_CODEX_COLLAB_LOG.md`에 개발 중 기록한다.

---

# 전체 원칙

- 한 단계씩 구현한다.
- 각 단계 종료 시 플레이 가능해야 한다.
- 아트보다 회색 원과 막대로 전체 루프를 먼저 완성한다.
- 성능은 수치로 확인한다.
- 일정이 부족하면 아래 컷라인을 따른다.

---

# Phase 0 — 프로젝트 부트스트랩

## 목표

Godot 프로젝트가 열리고 빈 Main 씬이 실행된다.

## 작업

- Godot 4 프로젝트 생성
- 기준 해상도와 Stretch 설정
- Input Map 등록
- 폴더 기본 구조
- Main 씬
- 디버그 출력
- Web Export preset 준비 가능 여부 확인

## 완료 조건

- 에디터 실행 성공
- 브라우저 테스트 또는 최소 Export preset 생성 가능
- 파싱 오류 없음

---


# Phase 0.5 — 화면 골격 / 디자인 계약

상세:

- `DESIGN/00_VISUAL_IDENTITY.md`
- `DESIGN/01_SCREEN_COMPOSITION.md`

## 목표

최종 아트를 만들지 않고도 화면의 구조가 Snowball Effect답게 보이게 한다.

## 작업

- 16:9 Viewport
- 중앙 세로 Play Field Rect
- 좌우 Stage World 영역
- 단순 픽셀 기계 프레임 placeholder
- UI가 Play Field를 과도하게 가리지 않는 기본 배치
- Play Field Rect를 시뮬레이션 상수/설정으로 노출

## 완료 조건

- 전체 16:9와 실제 물리 영역이 분리됨
- 공과 패들은 중앙 영역을 벗어나지 않음
- 좌우에 Stage 배경을 표현할 실제 공간이 남음
- 브라우저 resize 시 구도가 유지됨


# Phase 1 — 최소 플레이 루프

상세: `tasks/01_minimum_loop.md`

## 구현

- 상단에서 기본 공 생성
- 아래쪽 반구 초기 velocity로 지속 이동 — 기본 gravity 0
- 좌우·상단 벽 반사와 열린 하단 Cashout
- `A/D` 패들 이동
- `←/→` 패들 회전
- 패들 반사
- 바닥 점수 회수
- 점수 UI
- 개발용 Stage 타이머
- 단순 원 렌더링

## 완료 조건

- 공 100개가 안정적으로 움직임
- 이동과 각도를 동시에 조작 가능
- 반사 방향이 눈으로 학습 가능
- Paddle hit으로 runtime speed가 변할 수 있고 cap으로 폭주하지 않음
- 놓친 공은 점수로 바뀜
- 재시작 가능

---

# Phase 2 — 합체 시스템

상세: `tasks/02_merge_system.md`

## 구현

- 공 `global_level`
- 공 정의 데이터
- 같은 레벨 근접 판정
- 합체 큐
- 상위 공 생성
- 크기·색·점수 변화
- 기본 합체 이펙트
- 최고 생성 레벨 기록

## 완료 조건

- 같은 레벨 두 공만 합체
- 한 공이 같은 프레임에 두 번 합체하지 않음
- 연쇄 합체가 다음 프레임부터 정상 동작
- 다른 레벨 공은 합체하지 않음
- 점수표가 데이터로 관리됨

---

# Phase 2.5 — Cashout / Stage Time Economy

상세: `tasks/02_5_cashout_time_stage_clear.md`

## 구현

- StageDefinition `base_time`, `clear_score`, `time_bonus_by_local_level`
- Stage별 타이머
- 일반 Cashout = Score + Time Bonus
- Ground/Planetary local Lv4 비종료와 Galactic Black Hole Phase handoff
- Time Up 처리
- Final Settlement = Score Only
- Settlement snapshot / 중복 잠금
- `stage_score` / `run_score` 점수 source of truth
- 동일 tick Cashout 회복과 local Lv4 비종료 중재
- Score Clear / Fail
- 마지막 Stage 예외 흐름

## 완료 조건

- 고등급 공을 Cashout하면 Score와 시간이 함께 증가
- Final Settlement에서는 시간이 증가하지 않음
- Final Settlement에서는 Active Cashout 전용 modifier가 적용되지 않음
- Settlement 재호출 시 점수가 중복되지 않음
- Ground/Planetary 최고 공 제작 뒤 PLAYING 유지와 FIRST CONTACT discovery
- Time Up 후 점수컷 판정
- 실패 시 Run End
- 성공 시 다음 Stage 준비

# Phase 3 — 대량 시뮬레이션

상세: `tasks/03_mass_simulation.md`

## 구현

- 배열 기반 공 데이터 정리
- 비활성 슬롯 재사용
- Uniform Grid / Spatial Hash
- 후보 검사 수 디버그
- 스트레스 테스트 씬
- Item Ball·Black Hole을 제외한 일반 Snowball의 레벨별 `MultiMeshInstance2D` 일괄 렌더 follow-up

## 성능 게이트

- 실제 Web build의 동시 활성 논리 공 500개에서 최저 30 FPS 이상
- 1,000개는 stretch/torture 결과와 병목을 기록하되 필수 통과 기준으로 사용하지 않음
- 일반 플레이 peak 약 300개는 후반 콘텐츠 통합 뒤 telemetry로 재확인
- 전수 비교가 없음
- 활성 수 증가 시 프레임 시간이 완만하게 증가

성능이 이미 충분하면 과도한 저수준 최적화를 하지 않는다.

MultiMesh follow-up은 simulation 구조를 바꾸지 않고 render snapshot consumer만 교체한다. 최종 Ball 이미지가 없어도 procedural placeholder 또는 임시 Texture2D로 구현할 수 있고, Presentation asset은 global level별 binding으로 나중에 교체한다. Merge/Cashout particle, Item Ball, Black Hole 본체는 이 batch에 포함하지 않는다.

---

# Phase 4 — Stage와 Scale Shift

상세: `tasks/04_stage_shift.md`

## 구현

- StageDefinition
- Ground / Planetary / Galactic
- Stage별 base_time / clear_score 밸런스 데이터
- 이전 최고 공 = 다음 기본 공
- 생성량 증가
- 크기 정규화
- 낮은 레벨 공 정리
- Stage별 좌우 World 배경 전환
- 아케이드 기계의 Stage 상태 변화
- `SCALE SHIFT`
- visual radius 재정규화
- 개발용 강제 스테이지 전환 키

## 완료 조건

- Ground/Planetary 최고 공 생성 뒤 gameplay 유지와 FIRST CONTACT 1회
- clear score 도달 직후 자동 Scale Shift로 다음 Stage 진입
- 점수컷 미달 시 Run End
- 새 기본 공이 정상 생성
- 이전 저레벨 공 정리
- 스테이지 전환 중 점수·시뮬레이션이 깨지지 않음

---

# Phase 5 — 보상 연출

상세: `tasks/05_effects.md`

## 구현

- 합체 단계별 파티클
- 회수 단계별 점수 팝업
- 카메라 흔들림
- 고레벨 히트스톱
- Scale Shift 줌
- 사운드 위계
- FX 예산과 동시 재생 제한
- 고등급 공 CUT-IN
- 전체 장면 freeze + dim
- CUT-IN 우선순위/cooldown
- 일반 CUT-IN과 Scale Shift 분리

## 완료 조건

- 낮은 이벤트와 높은 이벤트의 차이가 명확
- 고레벨 회수가 강한 보상으로 느껴짐
- 이펙트가 공과 UI를 완전히 가리지 않음
- 연출 때문에 FPS가 지속적으로 무너지지 않음

---

# Phase 6 — 아이템

상세: `tasks/06_items.md`

## 우선순위

1. Blizzard
2. Fire Core
3. Magnet

## 완료 조건

- Stage마다 임의의 시점에 Item Ball 1회 등장
- 현재 Stage의 3단계 이상 Snowball(`local_level >= 2`)이 Item Ball에 유효 hit 5회를 주면 파괴
- 파괴 시 해당 종류의 Item Orb 생성; Orb 크기·반지름·초기 speed는 현재 Stage 3단계 공과 동일
- Item Orb를 Paddle로 받으면 CUT-IN 뒤 1회 activation, 열린 하단으로 놓치면 효과 없이 소멸
- 지속 시간이 HUD에 표시
- 같은 아이템 재획득 시 갱신
- Fire 공의 합체·점수 배수 정상
- Magnet이 전수 비교를 만들지 않음

---

# Phase 7 — Galactic Black Hole 국면

상세: `tasks/07_black_hole.md`

## 구현

- 첫 Lv14 Ball을 이동 Black Hole runtime entity로 전환하며 L2→L3 확장
- Black Hole 이동, 저등급 공 흡수와 주변 궤도 인력
- Black Hole 하단 반사, 비성장·일반 Merge 제외
- 흡수 공 Cashout 가치 `12.5%`/phase-entry Run Score `25%` 상한 차감과 run score 0 Game Over
- 궤도 잔상
- 두 번째 Black Hole 생성 후 두 Black Hole 충돌로 최종 회전·폭발·타이틀 Run End 연결
- 타이틀 아래 Clear Score와 Main Menu 표시
- 후반 생성량
- 왜곡 또는 대체 연출

## 완료 조건

- 블랙홀 위치에 따라 궤도가 확실히 달라짐
- 플레이가 어려워지지만 불가능하지 않음
- Black Hole이 하단 Cashout되지 않음
- 두 Black Hole terminal sequence가 한 번만 발생
- 후반 물량과 연출을 켠 웹 빌드가 실행됨

---

# Phase 8 — 웹 배포와 제출

상세: `tasks/08_web_export_release.md`

## 구현

- Stage별 정식 제한 시간 / clear_score
- 시작 화면
- 조작 안내
- 결과 화면
- Web Export
- 정적 호스팅
- 브라우저별 확인
- 3분 플레이 영상
- Codex 활용 기록 정리

---

# MVP 컷라인

## 반드시 남김

공식 심사와 제출 관점에서 P0다.


- 패들 이동·회전
- 반사
- 합체
- 점수 회수
- 점수 폭증
- Stage local level별 Time Bonus
- Stage별 제한 시간
- Ground/Planetary Time Up Score Clear; Galactic은 Black Hole finale
- Time Up Final Settlement
- Score Clear / Run Fail
- Ground → Planetary → Galactic
- 스테이지 기본 단위 승격
- 생성량 증가
- 고레벨 이펙트
- Stage 기반 한 Run 결과 화면
- 웹 실행

## 일정 부족 시 순서대로 제거

1. Magnet
2. Fire의 복잡한 전파 규칙
3. Black Hole 왜곡 셰이더
4. Lv14 Black Hole 이후의 확장 공 콘텐츠
5. 개별 고급 공 텍스처
6. 추가 사운드 레이어

## 제거하지 않음

- Scale Shift
- 이전 최고 공이 다음 기본 공이 되는 규칙
- 스테이지별 생성량 증가
- 점수 뇌절
- 이동 + 각도 조작

이 네 가지가 게임 정체성이다.

---

# 추천 3인 역할

## A — 시뮬레이션/코어

- 공 데이터
- 패들 반사
- 합체
- Spatial Grid
- 성능

## B — 연출/아트

- 배경
- 공 외형
- 파티클
- 카메라
- 사운드

## C — 통합/제품

- Stage
- Item
- UI
- Web Export
- 테스트
- 발표와 영상

모두 기능 통합과 플레이 테스트에 참여한다.

---

# 제출용 Phase 9 — Submission Package

상세: `tasks/09_submission_package.md`

## 구현/작성

- 200자 소개 최종 검증
- 16:9 썸네일
- 실제 플레이가 포함된 3분 이하 데모 영상
- 실제 Codex 협업 로그 기반 설명
- public URL 시크릿 창 테스트
- 본선용 3분 피치 초안 준비

## 완료 조건

- `SUBMISSION/06_RELEASE_CHECKLIST.md`의 제출 필수 항목 통과
- 제출 당일 새 기능을 만들지 않아도 되는 상태
