# Judging Strategy — Snowball Effect

This file translates each official judging criterion into a concrete feature and evidence plan.

---

## 1. Playability

### What judges should feel

Within 10 seconds:

> I understand how to move, tilt, bounce, merge, and score.

Within 60 seconds:

> I can intentionally aim toward another same-level ball.

Within one run:

> The game visibly escalates and ends cleanly.

### Must-have evidence

- one-click public web link;
- no login;
- concise control overlay;
- predictable reflection;
- merge correctness;
- no deadlock / softlock;
- complete stage-based run;
- result + retry;
- browser performance metrics.

### Kill conditions

Do not ship if:

- the paddle sometimes misses obvious contacts;
- the ball gets trapped indefinitely;
- Scale Shift can fail due to duplicate state;
- the browser build crashes late game;
- restart leaves old state behind.

---

## 2. Originality

Do not pitch the game as merely:

> Breakout + Suika.

Pitch the signature loop:

> Every time you reach the top of a scale, yesterday's ultimate object becomes today's basic falling particle. The playfield, spawn density, score, background, and eventually physics all snowball together.

### Originality proof sequence

Show this in the demo video:

```text
Snowflake
  ↓ merge
Giant Snowball
  ↓ SCALE SHIFT
Giant Snowballs now fall as the basic unit
  ↓
Earth / Solar
  ↓ SCALE SHIFT
Solar units rain across a galactic background
  ↓
Black Hole gravity bends the whole field
```

The important reveal is the **unit re-baselining**, not just bigger sprites.

---

## 3. Codex Collaboration

The strongest evidence is a before → Codex task → verified result chain.

Good entries:

- initial Godot scene bootstrap;
- custom paddle reflection debugging;
- merge duplicate bug;
- N² merge prototype → Spatial Grid optimization;
- Web Export bug and fix;
- performance profiling;
- scene integration issue;
- test/debug tooling.

Each log entry should capture:

1. problem or goal;
2. prompt / task document;
3. Codex contribution;
4. human decision;
5. verification;
6. result / metric.

A long prompt history without verification is weak evidence.

---

## 4. Release Potential

The prototype should already contain the seeds of a releasable arcade loop:

- 3-minute session;
- score;
- highest stage;
- highest generated / cashed-out ball;
- Retry;
- visually shareable result.

Future release path, only as a pitch:

```text
Web prototype
→ daily challenge / fixed seed
→ leaderboard and achievements
→ account / cross-device progression
→ seasonal modifiers
→ Hive-backed release services if appropriate
```

Do not implement speculative backend work before the browser game is stable.

---

## 5. Presentation

Three presentation surfaces should tell the same story.

### Thumbnail

Show:

- paddle at bottom;
- dense falling snowballs;
- one obviously huge celestial snowball;
- cosmic background / scale contrast;
- readable `SNOWBALL EFFECT` title.

Avoid a thumbnail that looks like a generic snow scene.

### 3-minute demo video

Show actual play first. Explain later.

### Final 3-minute pitch

Structure:

1. What is it? — 20 sec
2. What is the mechanic? — 40 sec
3. What is the Snowball Effect twist? — 60 sec
4. How Codex helped build it — 30 sec
5. Why it can grow beyond the prototype — 20 sec
6. Finish on the strongest live visual — 10 sec

---

# One-line judging strategy

**Protect playability first, make the Scale Shift impossible to miss, and document real Codex problem-solving as carefully as the code itself.**


---

## Presentation / Visual Identity

발표와 영상에서는 초반 Ground와, Lv14 Black Hole Snowball 및 이동 블랙홀 맵 기믹이 있는 후반 Galactic을 반드시 대비시킨다.

시각 한 줄:

> Retro Pixel Arcade Machine × Cosmic Escalation

보여줄 핵심:

- 중앙 세로 Play Field와 좌우 Stage World
- 이전 최고 공이 다음 Stage의 기본 공이 되는 Scale Shift
- 점점 과부하되는 픽셀 아케이드 기계
- 일반 머지는 포화형 FX, 중요 이벤트는 1초 미만 CUT-IN
- 후반에도 실제 공과 패들 조작이 읽히는 Readable Chaos


---

## Updated Core Loop — Greed vs Cashout

Snowball Effect의 플레이어 선택은 단순 머지가 아니다.

- 높은 공을 계속 살리면 다음 머지로 점수가 폭발할 수 있다.
- 지금 Cashout하면 현재 점수와 추가 시간을 얻는다.
- Stage 최고 공은 즉시 Clear.
- 시간이 끝나면 화면 공까지 Score-only Final Settlement.
- 목표 점수를 넘기면 Score Clear.

이 구조를 Originality / Playability 설명의 핵심으로 사용한다.
