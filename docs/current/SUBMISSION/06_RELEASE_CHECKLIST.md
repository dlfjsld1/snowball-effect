# Release & Submission Checklist

## A. Core game

- [ ] A/D movement works.
- [ ] Arrow-key tilt works.
- [ ] Simultaneous movement + tilt works.
- [ ] Reflection is predictable.
- [ ] Same-level merge works.
- [ ] Different levels do not merge.
- [ ] Bottom cash-out awards correct data-defined score.
- [ ] Score formatter survives late values.
- [ ] Scale Shift cannot trigger twice for the same stage.
- [ ] Previous top ball becomes next base ball.
- [ ] Spawn rate changes by stage.
- [ ] At least two Scale Shifts are naturally reachable in a normal approximately three-minute run.
- [ ] Timer ends game cleanly.
- [ ] Results screen works.
- [ ] Retry fully resets state.

## B. Performance

- [ ] No N² merge loop remains in release path.
- [ ] 1,000 logical-ball stress test recorded.
- [ ] Late-stage real gameplay tested.
- [ ] FX throttling works during burst events.
- [ ] Browser frame rate is acceptable.
- [ ] No repeated large allocation spikes discovered in normal play.

## C. Web build

- [ ] Godot Web Export succeeds.
- [ ] Hosted URL uses the final build.
- [ ] Tested from incognito / logged-out browser.
- [ ] No installation required.
- [ ] No access approval required.
- [ ] No login required.
- [ ] First click/input activates audio correctly.
- [ ] Keyboard focus works after loading.
- [ ] Browser resize keeps playable layout.
- [ ] Chrome tested.
- [ ] Edge tested.
- [ ] Firefox tested if time permits.
- [ ] Browser console has no fatal error.
- [ ] URL will remain online throughout judging.

## D. Presentation surface

- [ ] Title screen is readable in a screenshot.
- [ ] Controls are visible.
- [ ] 16:9 thumbnail prepared.
- [ ] Thumbnail exported JPG/PNG <= 10 MB.
- [ ] Thumbnail does not look like a generic snow wallpaper.
- [ ] Strong late-game screenshot captured.
- [ ] Result screen looks shareable.

## E. Submission form

- [ ] Final game title confirmed.
- [ ] Korean intro <= 200 chars verified in actual form.
- [ ] Playable URL pasted and tested.
- [ ] Thumbnail uploaded.
- [ ] Demo video URL added if submitted.
- [ ] Codex collaboration explanation written from real logs.
- [ ] Existing-project disclosure handled if relevant.

## F. Codex evidence

- [ ] `02_CODEX_COLLAB_LOG.md` contains actual sessions.
- [ ] At least one implementation example.
- [ ] At least one debugging/problem-solving example.
- [ ] At least one verification or performance result.
- [ ] Human gameplay decisions are explicitly separated.
- [ ] No fabricated metrics or claimed work.

## G. Final-event readiness

Only needed if selected.

- [ ] Build opened before pitch.
- [ ] Offline/local fallback build available on laptop.
- [ ] Demo save/debug path can quickly reach Scale Shift if live run RNG is slow.
- [ ] Debug controls hidden from public UI.
- [ ] Pitch is under 3 minutes in rehearsal.
- [ ] One representative can explain every major system.
- [ ] Strongest visual is used as the final ten seconds.
