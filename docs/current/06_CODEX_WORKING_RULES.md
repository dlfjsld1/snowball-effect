# Snowball Effect — Codex Working Rules

## 1. 작업 시작 전

반드시:

1. `AGENTS.md` 읽기
2. `00_READ_FIRST.md` 읽기
3. 관련 게임 규칙과 기술 설계 읽기
4. 현재 작업 문서 읽기
5. 기존 파일 구조와 코딩 스타일 확인
6. 변경 범위를 짧게 정리한 뒤 구현

이미 답이 문서에 있는 질문을 사용자에게 다시 묻지 않는다.

---

## 2. 작업 단위

한 번에 하나의 Phase 또는 하나의 명확한 하위 기능만 구현한다.

좋은 예:

- 패들 반사만 구현
- 합체 중복 방지만 수정
- Spatial Grid를 추가하고 수치 비교
- Blizzard만 추가

나쁜 예:

- 시뮬레이션부터 아트, 아이템, UI까지 한 번에 구현
- 전체 구조를 임의로 ECS로 교체
- 요청 없이 C#으로 전환

---

## 3. 코드 변경 원칙

- Godot 4.x API만 사용
- 문법과 API를 추측하지 않음
- deprecated API 사용 금지
- 타입 힌트를 가능한 범위에서 사용
- 함수는 한 책임
- 매직 넘버는 설정 또는 상수
- 게임 규칙과 표현 코드 분리
- 기존 파일 이름과 책임을 존중
- 요청 없는 대규모 리팩터링 금지
- 복잡한 추상화보다 읽기 쉬운 직접 구현 우선

---

## 4. 성능 원칙

절대 하지 않음:

- 수천 개 `RigidBody2D`
- 공마다 개별 `_physics_process`
- N² 전수 충돌
- 매 프레임 대량 `instantiate()`/`queue_free()`
- 저레벨 공마다 개별 타이머와 Tween
- 파티클을 게임 상태로 사용

최적화는 측정 후 수행한다.  
성능 문제를 해결하기 위해 게임 규칙을 몰래 변경하지 않는다.

---

## 5. 씬 파일

- `.tscn`을 직접 수정할 때 기존 형식을 보존
- 한 번에 큰 씬 전체를 재생성하지 않음
- 연결 대상 NodePath 확인
- 없는 리소스 경로를 만들지 않음
- 에디터에서 열 수 있는지 검증
- 가능하면 기능별 작은 씬 사용

---

## 6. 오류 처리

변경 후 최소한 확인:

- GDScript 파싱 오류
- 누락된 NodePath
- 누락된 Resource
- 런타임 null 접근
- 배열 인덱스 오류
- 중복 합체
- 점수 NaN/Infinity
- 웹 콘솔 오류

실행할 수 없는 환경이면 실행하지 못했다고 명시하고, 정적 확인 범위를 적는다.

---

## 7. 가정

작은 구현 세부를 스스로 결정할 수 있다.

예:

- 변수 이름
- 내부 helper 함수
- 디버그 HUD 배치
- 임시 색상

다음은 임의 변경 금지:

- 조작 키
- 점수 철학
- 스테이지 기본 단위 승격
- 바닥 도달의 의미
- Stage 구조
- 마지막 Galactic Stage의 Black Hole 맵 기믹 전역 인력
- 저레벨 공의 데이터 중심 처리

---

## 8. 임시 구현

임시 도형과 placeholder는 허용한다.

조건:

- 파일과 코드에 `TODO` 또는 명확한 이름 사용
- 최종 에셋처럼 속이지 않음
- 핵심 게임 루프는 실제로 작동
- placeholder가 성능 측정을 왜곡하지 않음

---

## 9. 테스트

각 작업에서 다음 중 관련 항목을 검증한다.

- 정상 시나리오
- 경계 시나리오
- 빠른 연속 입력
- 공 수 증가
- 스테이지 전환
- 일시정지
- 재시작
- 웹 크기 변경

테스트용 치트키는 개발 빌드에서 허용한다.

예:

- 공 100개 생성
- 특정 레벨 공 2개 생성
- 다음 Stage 강제 이동
- 시간 10초 남기기

릴리스 UI에는 노출하지 않는다.

---

## 10. 완료 보고

반드시 포함:

- 구현한 것
- 구현하지 않은 것
- 변경 파일
- 실행/검증 방법
- 측정값
- 알려진 문제
- 다음 작업

“완료”라는 말은 완료 조건을 실제로 만족할 때만 쓴다.

---

## 11. Git 작업

사용자가 명시적으로 요청하지 않으면:

- commit 하지 않음
- push 하지 않음
- PR 만들지 않음

변경을 만들 때는 독립적으로 리뷰 가능한 범위를 유지한다.

---

## 12. 금지된 과잉 설계

MVP에서 다음을 새로 도입하지 않는다.

- 자체 DI 컨테이너
- 네트워크 계층
- 데이터베이스
- 복잡한 ECS 프레임워크
- 멀티스레드 작업 시스템
- 별도 빌드 도구
- 대규모 플러그인 의존성

필요성이 측정되기 전에는 단순한 Godot 구조를 사용한다.

---

## 13. Hackathon Evidence Rule

의미 있는 Codex 작업이 끝난 뒤 `SUBMISSION/02_CODEX_COLLAB_LOG.md`에 기록할 수 있도록 아래 사실을 작업 보고에 남긴다.

- 해결하려던 실제 문제
- Codex가 변경한 파일/기능
- 사람이 선택한 설계 판단
- 실행하거나 측정한 검증 결과
- before/after 수치가 있다면 실제 측정값

측정하지 않은 FPS, 성능 향상률, 버그 해결 결과를 만들어내지 않는다.

## 14. Submission Stability Rule

공식 제출 제약과 충돌하면 다음 순서를 따른다.

1. public Web Build 실행 가능성
2. 코어 플레이 안정성
3. Scale Shift 가시성
4. 성능
5. 결과/Retry 및 안내 UI
6. 제출 증거와 영상
7. 선택 아이템 / 고급 셰이더 / 추가 콘텐츠

선택 기능을 유지하기 위해 제출 가능한 빌드를 망가뜨리지 않는다.

---

## 15. Hackathon Collaboration Log — REQUIRED

의미 있는 Codex 개발 작업을 마칠 때마다 `SUBMISSION/02_CODEX_COLLAB_LOG.md`에 새 항목을 append한다.

로그 작성은 Definition of Done의 일부이며, 로그가 없으면 해당 작업은 완료로 간주하지 않는다.

반드시 실제로 확인된 내용만 기록한다. 테스트하지 않은 것은 `Not verified`, 커밋하지 않은 것은 `Not committed`로 명시한다. 이전 로그를 요약하거나 덮어쓰지 않는다.

기록 항목:
- 날짜/시간
- 작업 또는 문제
- 사람이 결정한 사항
- Codex가 구현·조사·디버깅한 내용
- Codex 제안 중 수용/변경/거절된 중요한 사항
- 변경 파일
- 발생한 오류/문제
- 실제 검증 결과
- 관련 성능 측정값
- 실제 커밋이 존재할 때만 커밋 해시



---

## Stage / Time Economy rules

다음 규칙은 임의 변경 금지:

- Stage별 제한 시간
- 일반 Cashout = Score + Time Bonus
- Final Settlement = Score only
- Ground/Planetary 최고 공 생성 = 즉시 Stage Clear. Galactic 첫 Lv14는 Black Hole 국면 전환 예외
- Time Up 후 clear_score 판정
- 성공한 Stage의 Settlement 후 Scale Shift
- Time Up은 같은 physics tick의 Merge와 Active Cashout 반영 후 판정
- 같은 tick에서는 Top Ball Clear가 Time Up보다 우선
- Settlement는 base score만 한 번 반영하고 Active Cashout 전용 modifier를 적용하지 않음
- 점수 이벤트마다 `stage_score`와 `run_score`를 함께 증가시키며 Stage 종료 시 재합산 금지

밸런스 수치(`base_time`, `clear_score`, `time_bonus_by_local_level`)는 플레이테스트로 조정할 수 있지만
규칙 자체를 단순화하거나 제거하지 않는다.
