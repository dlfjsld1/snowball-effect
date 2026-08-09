# Snowball Effect — Codex Context 시작 안내

이 문서 묶음은 **Snowball Effect**를 Godot 4 기반 웹 게임으로 구현하기 위한 기준 컨텍스트다.  
기획, 게임 규칙, 기술 설계, 구현 단계가 서로 분리되어 있으므로 임의로 한 문서만 읽고 구현하지 않는다.

---

## 1. 권장 읽기 순서

| 순서 | 문서 | 목적 |
|---:|---|---|
| 1 | `01_PRODUCT_BRIEF.md` | 게임이 왜 재미있어야 하는지 이해 |
| 2 | `02_GAME_RULES.md` | 확정된 조작과 규칙 확인 |
| 3 | `09_GAMEPLAY_LOOP_V2.md` | Cashout·시간·Stage Clear 최신 루프 확인 |
| 4 | `DESIGN/00_VISUAL_IDENTITY.md` | 픽셀 아케이드 기계 정체성 확인 |
| 5 | `DESIGN/01_SCREEN_COMPOSITION.md` | 중앙 Play Field + 좌우 Stage World 화면 계약 확인 |
| 6 | `DESIGN/02_STAGE_ART_DIRECTION.md` | Stage별 배경/기계 변화 확인 |
| 7 | `DESIGN/03_GAMEPLAY_EFFECTS.md` | 뱀서식 포화와 가독성 위계 확인 |
| 8 | `DESIGN/04_CUTIN_SYSTEM.md` | 고등급 CUT-IN 규칙 확인 |
| 9 | `03_TECHNICAL_DESIGN.md` | 대량 공 시뮬레이션과 프레젠테이션 구조 확인 |
| 10 | `04_PROJECT_STRUCTURE.md` | 씬·스크립트·데이터 책임 확인 |
| 11 | `05_IMPLEMENTATION_PLAN.md` | 구현 순서와 컷라인 확인 |
| 12 | `06_CODEX_WORKING_RULES.md` | 에이전트 작업 규칙 확인 |
| 13 | `08_HACKATHON_REQUIREMENTS.md` | 공식 Track 1 제출·심사 제약 확인 |
| 14 | `07_INITIAL_PROMPT.md` | 새 프로젝트의 최초 작업 지시 확인 |
| 15 | `tasks/*.md` | 현재 구현할 한 단계의 상세 명세 확인 |
| 16 | `SUBMISSION/*.md` | 제출 자료와 Codex 협업 증거 관리 |

---

## 2. 문서 권한

서로 다른 문서에 표현 차이가 있으면 다음 우선순위를 따른다.

1. 사용자의 최신 지시
2. `02_GAME_RULES.md`
3. `03_TECHNICAL_DESIGN.md`
4. `08_HACKATHON_REQUIREMENTS.md`의 공식 제출 제약
5. 현재 작업 문서
6. `05_IMPLEMENTATION_PLAN.md`
7. 기존 코드

저장소에서 작업할 때는 루트 `docs/goals/`의 현재 Goal과 검증 상태를 함께 따른다. 추측으로 규칙을 바꾸지 않는다. 사소한 구현 세부는 합리적으로 정하되 작업 보고에서 가정을 밝힌다.

---

## 3. 현재 확정된 핵심

- 프로젝트명: **Snowball Effect**
- 엔진: **Godot 4.x**
- 플랫폼: 브라우저 Web Export
- 장르: 2D 액션 머지
- `A / D`: 패들 좌우 이동
- `← / →`: 패들 각도 변경
- 같은 `global_level`의 공끼리 합체
- 바닥 도달은 실패가 아니라 점수 획득
- 점수는 단계마다 100배, 1,000배 등 의도적으로 폭증
- 이전 스테이지 최고 공은 다음 스테이지 기본 공
- 스테이지가 오를수록 기본 공 생성량 증가
- 블랙홀 스테이지에서는 이동하는 블랙홀이 공의 궤도를 휨
- 이펙트는 뱀파이어 서바이버처럼 포화되되, 중요한 이벤트가 묻히지 않게 계층화
- 게임 규칙 공은 CPU 데이터, 장식 파티클은 GPU 파티클
- 화면은 중앙의 세로 Play Field + 좌우 Stage World/기계 프레임 구조
- 전체 아트 방향은 Retro Pixel Arcade Machine × Cosmic Escalation
- 일반 머지는 뱀서식 포화 연출, 고등급 이벤트는 짧은 Pixel CUT-IN
- CUT-IN은 현재 장면 전체를 freeze/dim하고 약 0.45~0.7초 안에 지나감
- SCALE SHIFT는 일반 CUT-IN과 별도이며 더 높은 우선순위
- Track 1 제출물은 브라우저에서 별도 설치 없이 실행되는 공개 Web Build여야 함
- 제출 소개는 200자 제한, 썸네일은 16:9 JPG/PNG 권장
- 3분 이하 실제 플레이 영상과 Codex 활용 설명은 선택 제출이지만 가산점
- 본선 Track 1 엘리베이터 피치는 최대 3분

---

## 4. 구현 철학

이 게임은 정밀한 물리 시뮬레이터가 아니다. 다음을 우선한다.

1. 조작이 예측 가능할 것
2. 합체가 자주 보일 것
3. 높은 단계가 명확히 특별할 것
4. 스테이지가 오를수록 화면 밀도와 규모가 폭증할 것
5. 웹 브라우저에서 안정적으로 실행될 것

현실적인 질량·마찰·천체 물리보다 게임 감각이 우선이다.

---

## 5. 작업 보고 형식

Codex는 작업을 마치고 아래 형식으로 보고한다.

```text
## 변경 요약
- ...

## 변경 파일
- path/to/file.gd
- path/to/file.tscn

## 검증
- 실행 명령 또는 에디터 실행 방법
- 확인한 시나리오
- FPS / 활성 공 수 등 측정값

## 남은 문제
- ...

## 다음 권장 작업
- ...
```

완료하지 못한 항목을 완료한 것처럼 쓰지 않는다.

---

## 6. 해커톤 기준으로 생긴 추가 원칙

- `Playability`가 무너지면 선택 기능을 즉시 자른다.
- `Originality`는 Scale Shift와 기본 단위 승격으로 증명한다.
- `Codex Collaboration`은 실제 작업 로그와 검증 결과로 증명한다.
- `Release Potential` 때문에 지금 Hive를 억지로 붙이지 않는다. 웹 아케이드의 반복 구조와 향후 확장 경로를 설계한다.
- `Presentation`을 위해 첫 화면, 결과 화면, 16:9 썸네일 구도를 개발 중부터 고려한다.

---

## 7. Codex 협업 로그는 완료 조건이다

의미 있는 개발 작업은 구현·검증 후 `SUBMISSION/02_CODEX_COLLAB_LOG.md`에 append-only 로그를 남겨야 끝난다. 상세 규칙과 템플릿은 루트 `AGENTS.md`를 따른다.



---

## 최신 게임 루프 계약

- Stage마다 제한 시간이 있다.
- 플레이 중 공을 바닥으로 보내는 것은 `Cashout`.
- 일반 Cashout = `Score + Time Bonus`.
- 고등급 공을 더 머지할지 Cashout해 시간을 확보할지 선택한다.
- Stage 최고 공 제작 = 즉시 Stage Clear.
- Time Up = 화면 공 `Final Settlement`.
- Final Settlement = `Score only`; Time Bonus 없음.
- Time Up 후 Final Stage Score가 `clear_score` 이상이면 Stage Clear.
- 부족하면 Run End.
- 성공한 Stage는 Settlement 후 `SCALE SHIFT`.
- Time Up 판정은 해당 physics tick의 Merge와 Active Cashout을 모두 반영한 뒤 수행한다.
- 같은 tick에서는 Top Ball Clear가 Time Up보다 우선한다.
- `stage_score`와 `run_score`는 점수 이벤트 때 함께 증가하며 Stage 종료 시 다시 합산하지 않는다.
