# Team Collaboration

> **STATUS: INITIAL / DRAFT — 병목과 팀 숙련도에 따라 변경 가능**

이 폴더는 3인 병렬 개발의 임시 역할, 파일 소유권, Integration 접점을 정의한다. 역할은 고정 직책이 아니며 현재 가장 큰 병목을 줄이기 위한 작업 경계다.

## 문서

- [`TEAM_IMPLEMENTATION_ROLES.md`](TEAM_IMPLEMENTATION_ROLES.md): 세 트랙과 Integration 역할
- [`OWNERSHIP.md`](OWNERSHIP.md): 파일 소유권과 교차 수정 절차
- [`INTEGRATION_CONTRACTS.md`](INTEGRATION_CONTRACTS.md): Signal/API와 통합 잠금 규칙
- 새 개발환경에서는 실제 Goal 작업 전에 [`GODOT_MCP_SETUP.md`](GODOT_MCP_SETUP.md)를 실행한다.

## 핵심 규칙

- `IN PROGRESS`는 Core, Presentation, Content/Systems 각 최대 1개다.
- Integration은 별도 lane으로 최대 1개를 진행한다.
- 다른 Owner의 파일을 직접 고치기 전에 Signal/API 요청을 우선한다.
- Integration-owned 파일은 Integration Goal에서만 수정·병합한다.
- Goal 완료 또는 의미 있는 commit/push 전에 해당 lane의 `worklogs/*/WORKLOG.md`를 append한다.
- 역할, 경로, 담당자는 초기안이다. 변경은 `STATUS.md`와 이 문서를 함께 갱신해 명시적으로 수행한다.
