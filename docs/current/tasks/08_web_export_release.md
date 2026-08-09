# Task 08 — Web Export and Release Candidate

## 목적

공식 Track 1 필수 조건인 **브라우저 직접 실행 Web Build**를 Release Candidate 수준으로 만든다.

---

## 선행 읽기

- `08_HACKATHON_REQUIREMENTS.md`
- `SUBMISSION/00_OFFICIAL_REQUIREMENTS.md`
- `SUBMISSION/06_RELEASE_CHECKLIST.md`

---

## 정식 게임 흐름

1. Title
2. 즉시 읽히는 조작 안내
3. Start
4. Stage별 제한 시간 기반 플레이
5. Result
6. Retry

로그인, 계정 생성, 별도 승인은 넣지 않는다.

---

## 타이틀 안내

```text
A / D        MOVE
← / →        TILT
MERGE SAME-LEVEL BALLS
DROPPED BALLS BECOME SCORE
```

첫 플레이어가 10초 안에 이해할 수 있어야 한다.

---

## Web Export 필수 확인

Release export 전에 [`../../team/GODOT_MCP_SETUP.md`](../../team/GODOT_MCP_SETUP.md)의 **Web Export Hygiene / Web Export 주의사항** 절차에 따라 MCP bridge를 종료하고 이전 산출물을 clean한다. MCP가 실행 중인 상태에서 생성한 build는 release 기준 build로 사용하지 않는다.

- Godot Web preset
- public static hosting
- 심사기간 유지 가능한 URL
- 별도 설치 없음
- 별도 접근 승인 없음
- 첫 입력 후 오디오 시작
- 키보드 포커스
- 화면 비율 유지
- 브라우저 resize
- 상대 asset 경로
- 브라우저 console fatal error 없음

최소 Chrome/Edge에서 검사한다. 가능하면 Firefox도 검사한다.

---

## 약 3분 Stage 기반 Release Candidate 조건

- 전체 세션 종료 가능
- 최소 두 번의 Scale Shift가 일반 플레이로 보일 수 있게 밸런스 조정
- 고레벨 점수 formatter 정상
- late-game density에서도 플레이 가능
- 결과 화면에 score / highest stage / highest ball 표시
- Retry가 모든 gameplay state를 초기화

---

## Public-link 검증

반드시 개발 환경이 아닌 조건에서 확인한다.

1. 새 시크릿/Incognito 창
2. 링크 직접 입력
3. 캐시 없는 상태로 load
4. Start
5. 실제 키 입력
6. 한 판 완주
7. Retry
8. browser console 확인

가능하면 다른 PC 또는 다른 네트워크에서도 확인한다.

---

## 완료 조건

- 공식 제출 링크로 사용해도 되는 public build
- Stage 기반 한 판 완주
- result + retry
- 치명 console error 없음
- no login / no approval
- controls visible
- late-game performance acceptable
- `SUBMISSION/06_RELEASE_CHECKLIST.md`의 Web 관련 항목 완료

---

## 이번 Task에서 하지 않는 것

- 데모 영상 편집
- 200자 소개 최종 입력
- 썸네일 제작
- Codex 제출 설명 문안 확정

이것들은 `tasks/09_submission_package.md`에서 처리한다.
