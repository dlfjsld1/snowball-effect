# Snowball Effect — Godot MCP Setup for Codex

이 문서는 **Snowball Effect 저장소를 사용하는 각 팀원의 Codex에 한 번 전달하는 개발환경 설정 지시서**다.

## 언제 실행하는가

다음 시점에 Codex에 이 문서를 전달하고 실행시킨다.

1. Snowball Effect 저장소를 clone 또는 pull한 뒤
2. Godot 4.7.1 stable을 로컬 PC에 준비한 뒤
3. 실제 게임 Goal 구현을 시작하기 전에
4. 팀원 PC마다 최초 1회

이미 두 Godot MCP가 정상 등록·검증된 PC에서는 다시 실행할 필요 없다.

Codex에는 다음처럼 지시하면 된다.

> 이 문서를 읽고 Snowball Effect용 Godot MCP 개발환경 설정만 수행해. 게임 구현은 시작하지 마.

---

# Codex 작업 지시

Snowball Effect 개발을 위한 Godot MCP 환경을 설정해라.

## 팀 공통 환경

- Windows
- Godot **4.7.1 stable**
- Godot Standard + GDScript
- Node.js **20 이상**
- Codex 사용

설치할 MCP는 다음 두 개다.

---

## 1. Primary MCP

`Erodenn/godot-mcp-runtime`

- MCP 이름: `godot`
- 기본 Godot MCP로 우선 사용한다.
- 공식 최신 README를 확인하고 현재 권장 방식으로 설치/등록한다.
- Codex에서는 elicitation 비지원에 맞춰 `GODOT_MCP_DISABLE_ELICITATION=true`를 사용한다.

주요 용도:

- Godot 프로젝트/Scene 조회
- 일반 Godot 작업
- 게임 실행
- Runtime Scene Tree
- 입력 시뮬레이션
- Screenshot
- 실제 플레이 상태 검증

### Codex용 Primary 설정

```toml
[mcp_servers.godot]
command = "npx"
args = ["-y", "godot-mcp-runtime"]

[mcp_servers.godot.env]
GODOT_PATH = "<정확한 Godot 4.7.1 executable 경로>"
GODOT_MCP_DISABLE_ELICITATION = "true"
```

Codex MCP client가 Erodenn의 elicitation 확인 창을 표시하지 못하므로 팀 기본 설정에서는 `GODOT_MCP_STRICT=true`를 사용하지 않는다. `GODOT_MCP_DISABLE_ELICITATION=true`는 확인 요청을 생략하고 경고를 남기지만, Erodenn의 Tier 1 security hard block은 계속 적용된다. 두 변수를 함께 설정하면 `GODOT_MCP_STRICT`가 우선하므로 동시에 설정하지 않는다.

이 모드는 확인 단계를 생략하는 보안 절충이다. 신뢰하는 프로젝트와 에이전트에서만 사용하며, 향후 Codex MCP client가 elicitation을 정상 지원하면 팀 정책을 재검토한다. 기준은 Erodenn의 [공식 README](https://github.com/Erodenn/godot-mcp-runtime)와 [Security Model](https://github.com/Erodenn/godot-mcp-runtime/blob/main/docs/security.md)이다.

---

## 2. Fallback MCP

`Coding-Solo/godot-mcp`

- MCP 이름: `godot_fallback`
- Primary MCP 자체에 문제가 있을 때 fallback으로 사용한다.
- 공식 최신 README를 확인하고 현재 권장 방식으로 설치/등록한다.

---

## 로컬 환경 확인

현재 PC에서 다음을 확인한다.

- Node.js 20 이상인지
- Godot 4.7.1 stable이 설치되어 있는지
- 실제 Godot executable 경로
- 기존 Codex `config.toml`
- 기존 MCP 설정

Godot 설치 위치는 팀원마다 달라도 된다.

일반적인 위치와 현재 환경에서 합리적인 범위까지만 검색한다.

**Godot 4.7.1 executable의 정확한 위치를 신뢰성 있게 찾을 수 없다면 추측하거나 임의 경로를 사용하지 말고 사용자에게 Godot exe 경로를 물어봐라.**

Godot가 설치되어 있지 않은 것으로 보이면 임의로 다른 버전을 설치하지 말고 사용자에게 알려라.

기존 Codex 설정과 다른 MCP 설정은 보존하고, 필요한 Godot MCP 설정만 최소 변경한다.

Primary 설정에 기존 `GODOT_MCP_STRICT=true`가 있다면 제거하고 `GODOT_MCP_DISABLE_ELICITATION=true`로 교체한다. `godot_fallback`과 다른 MCP 설정은 건드리지 않는다.

---

## MCP 사용 우선순위

기본 우선순위:

1. `godot` — `Erodenn/godot-mcp-runtime`
2. `godot_fallback` — `Coding-Solo/godot-mcp`
3. Godot CLI/native — MCP와 독립적인 baseline/source of truth

평상시에는 Primary인 `godot`을 사용한다.

Erodenn에서 문제가 발생했다고 바로 fallback MCP에서 같은 작업을 반복 실행하지 않는다.

오류가 발생하면 가능한 경우 다음 순서를 따른다.

```text
Erodenn 실패
→ Godot CLI/native로 프로젝트 자체 문제인지 확인
→ 프로젝트도 실패
   → 프로젝트/게임 코드 문제 조사
→ 프로젝트는 정상
   → MCP/tooling 문제로 분류
   → godot_fallback 사용 가능
```

다음 행동을 피한다.

- 두 MCP를 같은 작업에 동시에 사용
- 두 MCP 사이를 이유 없이 반복 전환
- 여러 MCP를 통해 중복 Godot 프로세스 실행
- MCP 실패만을 근거로 게임 코드 수정
- fallback MCP 사용을 위해 게임 구조 변경

---

## 설정 검증

설정 후 다음을 확인한다.

- 두 MCP가 Codex 설정에 정상 등록됐는지
- 가능한 경우 MCP 서버가 정상 기동되는지
- 기존 Codex/MCP 설정이 손상되지 않았는지

새 MCP tool 노출에 Codex 재시작이 필요하다면 우회 검증을 계속하지 않는다.

**사용자에게 Codex 재시작이 필요하다고 알리고 해당 단계에서 중단한다.**

재시작 후 새 Codex 세션에서 실제 MCP tool 호출로 프로젝트 인식을 별도로 확인한다.

권장 읽기 전용 확인:

### Primary `godot`

- Godot 버전
- 현재 Snowball Effect 프로젝트 인식
- project info
- scene tree

### Fallback `godot_fallback`

- MCP tool 노출 여부
- 서버 연결 여부
- 가능한 읽기 전용 project info 또는 Godot 정보 조회

Primary가 정상이라면 fallback으로 동일 검증을 불필요하게 반복할 필요는 없다.

---

## Web Export Hygiene / Web Export 주의사항

개발과 일반 검증 중에는 Godot MCP를 정상적으로 사용할 수 있다. 다만 **최종 Web release export는 실행 중인 Godot MCP bridge 세션과 분리된 clean 상태에서 만든다.**

Shared Skeleton Web 검증에서 다음 현상이 관찰됐다.

- Godot MCP가 실행 중인 상태에서 기존 `all_resources` Web export를 수행했을 때 MCP bridge 관련 리소스가 build에 포함될 수 있었다.
- 해당 build는 브라우저에서 MCP bridge 포트 연결을 시도하며 console error를 발생시켰다.
- MCP를 종료하고 이전 Web export 산출물을 clean한 뒤 release export를 다시 수행했을 때는 문제가 재현되지 않았고 browser console warning/error가 0이었다.

현재 확인 범위만으로 이를 게임 로직 버그, MCP 자체 고장, 영구 해결된 문제 중 하나로 단정하지 않는다. 기존 `all_resources` export 설정이 관련되었을 가능성은 있지만 원인은 아직 확정되지 않았으며, 이 문서는 export preset 변경을 지시하지 않는다.

### Release 전 필수 절차

1. 실행 중인 Primary/Fallback MCP runtime과 Godot MCP bridge 세션을 종료한다.
2. 대상 경로가 생성된 Web build 산출물인지 확인한 뒤 이전 산출물을 제거하거나 비어 있는 새 output directory를 사용한다.
3. Godot Web release export를 수행한다.
4. 실제 브라우저에서 다음을 확인한다.
   - Canvas가 정상 렌더되는가
   - 키보드 입력과 포커스가 정상인가
   - browser console에 MCP bridge 또는 port 관련 warning/error가 없는가
5. MCP가 실행 중인 상태에서 생성한 Web build는 release 기준 build로 간주하지 않는다.

Web build에서 bridge/port 관련 오류가 보이면 게임 코드를 먼저 수정하지 않는다. MCP와 bridge 세션을 종료한 뒤 clean export로 재현 여부를 확인하고, 그 결과로 게임 문제와 개발 도구/export 오염 가능성을 구분한다.

Release Candidate 전체 검증 기준은 [`../current/tasks/08_web_export_release.md`](../current/tasks/08_web_export_release.md)를 따른다.

---

## 중요 — 이번 작업의 범위

이번 요청은 **개발환경 설정만 승인한다.**

게임 구현이나 프로젝트 변경을 시작하지 않는다.

금지:

- `.gd` 수정/생성
- `.tscn` 수정/생성
- Resource 수정/생성
- `project.godot` 수정
- Goal 상태 변경
- Goal을 `IN PROGRESS`로 변경
- 다음 Slice 구현
- MCP 검증용 임시 게임 코드 생성
- MCP 문제를 이유로 게임 코드 수정
- 요청하지 않은 리팩터링

프로젝트 파일은 읽기 전용으로만 확인한다.

---

## 완료 보고

설정 작업이 끝나면 다음만 간단히 보고한다.

- Node 버전 조건 충족 여부
- 확인된 Godot 버전
- 실제 사용한 Godot executable 경로
- `godot` 등록/기동 결과
- `godot_fallback` 등록/기동 결과
- 기존 설정 보존 여부
- Codex 재시작 필요 여부
- 프로젝트 파일 변경 여부

게임 구현은 사용자의 별도 명시적 지시가 있을 때만 시작한다.
