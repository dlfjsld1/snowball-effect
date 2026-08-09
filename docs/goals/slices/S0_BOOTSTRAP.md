# S0 — Bootstrap

## 결과

Godot 4 프로젝트가 1600×900 기준의 최소 Main 씬을 데스크톱과 Web에서 연다.

## Goals

### S0-G1 프로젝트 부트

- Owner: Integration
- Owned Files: `.gitignore`, `project.godot`, `scenes/main/main.tscn`
- Integration Point: 프로젝트 entry point와 Main scene root. 이후 모든 lane이 이 계약을 소비한다.
- Dependencies: 없음.
- Verification: Godot 4 headless parse/run, editor에서 Main 실행, 1600×900 확인.
- Do Not Modify: 입력, gameplay node, Web preset, asset.

### S0-G2 입력과 공유 씬 골격

- Owner: Integration
- Owned Files: `project.godot`, `scenes/main/main.tscn`
- Integration Point: Input action 이름과 `PlayField`, `StageWorld`, `UI/HUD` mount node를 각 Owner에게 제공.
- Dependencies: S0-G1 `VERIFIED`; Core/Presentation이 필요한 action과 mount 계약 제시.
- Verification: Input Map action 정의, 공유 scene mount tree, Godot 프로젝트 load/Main run 성공.
- Do Not Modify: Paddle physics, Ball simulation, HUD 내부 scene.

### S0-G3 Web smoke

- Owner: Content/Systems
- Owned Files: `export_presets.cfg`, `tests/release/**`, 로컬 `build/` 산출물.
- Integration Point: `project.godot` 변경이 필요하면 Integration에 설정 key 요청.
- Dependencies: S0-G2 `VERIFIED`와 Web export template.
- Verification: 새 브라우저 세션에서 load, resize, keyboard focus, fatal console error 없음.
- Do Not Modify: `project.godot`, Main scene, gameplay logic.

## Exit Gate

Q-S0, Integration Gate, Desktop/Web smoke 통과 및 세 Goal `VERIFIED`.
