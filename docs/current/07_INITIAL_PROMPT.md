# Codex 최초 실행 프롬프트

아래 내용을 새 Codex 세션의 첫 지시로 사용한다.

---

`AGENTS.md`와 `00_READ_FIRST.md`부터 읽고, `DESIGN/` 문서를 포함한 연결된 기획 및 기술 문서와 `08_HACKATHON_REQUIREMENTS.md`를 순서대로 확인해라.

Godot 4.x로 브라우저에서 실행 가능한 2D 액션 머지 게임 **Snowball Effect**를 구현한다.

핵심 규칙은 다음과 같다.

1. 화면 상단에서 현재 스테이지의 기본 공이 지속적으로 떨어진다.
2. 플레이어는 `A/D`로 하단 패들을 좌우 이동한다.
3. 플레이어는 좌우 방향키로 패들의 각도를 변경한다.
4. 이동과 회전은 동시에 가능하다.
5. 공은 좌우 벽과 패들에 반사된다.
6. 같은 `global_level`의 공 두 개가 접촉하면 현재 Stage의 ordered `local_ball_levels`에서 다음 공 하나로 합쳐진다.
7. 다른 레벨 공은 MVP에서 서로 물리 충돌하지 않는다.
8. 공이 패들 아래 점수 구역으로 떨어지면 실패가 아니라 Cashout이며, 활성 Stage에서는 해당 공의 점수와 Time Bonus를 획득한다.
9. 점수는 2배 보존 방식이 아니라 레벨마다 100배, 1,000배 등 의도적으로 폭증하며 데이터에 직접 정의한다.
10. 각 스테이지는 5개의 로컬 공을 가진다.
11. 현재 스테이지 최고 공을 처음 만들면 `SCALE SHIFT`가 발생한다.
12. 이전 스테이지의 최고 공은 다음 스테이지의 기본 공이 된다.
13. 스테이지가 오를수록 기본 공 생성량이 증가한다.
14. Ground, Planetary, Galactic의 3개 스테이지를 목표로 한다.
15. 마지막 Galactic 스테이지의 최고 공은 Lv14 `Black Hole`이며, 첫 Lv14는 이동 Black Hole 최종 국면 기믹으로 전환되어 공에 약한 인력을 가한다.
16. 고레벨 합체와 회수는 강한 파티클, 점수 팝업, 화면 흔들림과 짧은 히트스톱으로 강조한다.
17. Blizzard, Fire Core, Magnet 아이템은 이후 단계에서 추가한다.
18. 16:9 전체가 플레이 영역이 아니다. 실제 공 시뮬레이션은 중앙의 세로형 Play Field에서만 일어난다.
19. 좌우 여백은 Stage World와 Retro Pixel Arcade Machine 프레임/계기판 공간이다.
20. 전체 비주얼 정체성은 Retro Pixel Arcade Machine × Cosmic Escalation이다.
21. 일반 머지는 빠른 포화형 이펙트로 처리하고, 중요한 고등급 이벤트만 짧은 CUT-IN을 사용한다.
22. 일반 CUT-IN은 현재 장면 전체를 freeze + dim한 뒤 픽셀 기계 패널이 약 0.45~0.7초 안에 지나가며, 별도 화면을 띄우지 않는다.
23. SCALE SHIFT는 일반 CUT-IN과 별도이며 Stage 세계, 생성량, 기본 공, visual scale이 실제로 변경되는 더 높은 우선순위 이벤트다.
24. 각 Stage는 독립적인 제한 시간 라운드다. 하나의 전역 180초 타이머로 구현하지 않는다.
25. 일반 Cashout은 Score + 현재 Stage local level의 time_bonus다. Local Lv0는 0초에서 시작한다.
26. Ground/Planetary 최고 공 생성은 즉시 Stage Clear다. Galactic 첫 Lv14는 이동 Black Hole 국면으로 전환한다.
27. Time Up 시 활성 공을 Final Settlement하며 Score만 더하고 Time Bonus는 주지 않는다.
28. Time Up 후 final Stage score가 clear_score 이상이면 다음 Stage, 미달이면 Run End다.
29. 성공한 Stage는 Settlement 이후 Scale Shift로 다음 Stage에 진입한다.
30. 마지막 Galactic Stage는 Time Up 또는 두 Black Hole의 충돌로 종료한다. 첫 Lv14 Black Hole Ball은 이동 기믹으로 전환하며 같은 Galactic gameplay의 L3 국면을 활성화한다.
31. Time Up은 같은 physics tick의 Merge와 Active Cashout을 먼저 반영한 뒤 판정한다. Cashout으로 시간이 양수가 되면 플레이를 계속한다.
32. 같은 tick에서는 Top Ball Clear가 Time Up보다 우선한다.
33. 모든 점수 이벤트는 `stage_score`와 `run_score`에 같은 amount를 한 번씩 더하며 Stage 종료 시 `run_score += stage_score`를 하지 않는다.
34. Final Settlement는 active ball snapshot의 기본 score_value만 한 번 합산하며 Time Bonus, Active Cashout 전용 modifier, 추가 Merge를 적용하지 않는다.

기술 제한:

- 공 수천 개를 개별 `RigidBody2D`나 개별 씬 인스턴스로 만들지 마라.
- 중앙 `BallSimulationManager`가 배열 기반으로 공을 관리해야 한다.
- 모든 공 쌍을 전수 비교하지 마라.
- 합체 후보는 Uniform Grid 또는 Spatial Hash로 줄여라.
- 생성과 제거는 비활성 슬롯 재사용 방식으로 처리해라.
- 게임 규칙 공과 GPU 장식 파티클을 분리해라.
- Godot 4.x API만 사용하고 deprecated API를 사용하지 마라.
- 기능을 한꺼번에 구현하지 말고 항상 실행 가능한 상태를 유지해라.
- 요청하지 않은 대규모 리팩터링을 하지 마라.
- 웹 빌드는 최종 필수 제출 형식이므로 초기 Phase부터 실제 Web Export 가능성을 고려해라.
- 실제 Codex 작업 결과는 나중에 제출 증거가 될 수 있도록 문제/변경/사람의 판단/검증을 작업 보고에 구분해라.

이번 작업에서는 `tasks/01_minimum_loop.md`만 구현해라.

구현 전에:
1. 현재 저장소를 검사한다.
2. 필요한 파일과 변경 계획을 짧게 정리한다.
3. 기존 프로젝트가 있으면 구조를 유지한다.

구현 후:
1. 파싱 오류와 런타임 오류를 확인한다.
2. 최소 플레이 시나리오를 검증한다.
3. 변경 파일, 실행 방법, 검증 결과, 알려진 문제를 보고한다.
4. 합체, Stage Shift, 아이템, 고급 파티클은 아직 구현하지 않는다.


작업 완료 후 `AGENTS.md` 규칙에 따라 `SUBMISSION/02_CODEX_COLLAB_LOG.md`에 실제 작업·의사결정·검증 결과를 append해라. 이 로그까지 작성해야 이번 작업을 완료로 간주한다.


이후 머지 시스템이 완성되면 `tasks/02_5_cashout_time_stage_clear.md`를 반드시 구현해
Cashout Time Bonus와 Stage 판정 루프를 확정한 뒤 Scale Shift 작업으로 진행한다.
