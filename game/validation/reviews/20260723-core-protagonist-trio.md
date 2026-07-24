# CP-01 — Opening protagonist trio

- State: Implemented; automated verification complete.
- Commits: `685b9980` (`feat: establish Franklin Lincoln Gandhi opening trio`),
  `3a82b0c6`, `b94ffcde`, `8f11a457`, and `23a5e7d5` (trio contract and
  compatibility-fixture coverage).
- Build: Godot 4.7.1 stable; save schema v21.
- Scope: Benjamin Franklin, Abraham Lincoln (`lincoln`), and Mahatma Gandhi
  (`gandhi`) begin a new campaign as the active three-person company. Lincoln
  and Gandhi have follower scenes, distinct battle/portrait profiles, roles,
  and v20-save availability migration.
- Non-goals: This package does not grant visual acceptance, chapter dialogue,
  ending cutscene participation, or the required main-story arcs for the other
  supplied named characters.

## Automated evidence

- Focused isolated smoke: `test-artifacts/20260723-205656-6ffd1404`;
  `core_protagonist_trio_smoke.tscn` passed with `sentinel=True`.
- Browser/unit and clean runtime-asset gate: `npm run check` and
  `npm run validate:runtime-assets` passed after the inventory denominator was
  updated from 171 to 175 profiled campaign sources.
- Full isolated matrix: `test-artifacts/20260723-213112-2547e56d` executed all
  134 scenes with the production-save sentinel unchanged. 131 scenes passed;
  its only three failures were legacy test fixtures that assumed Ben began
  alone. Their exact isolated replacement run at
  `test-artifacts/20260723-215554-297c44a0` passed all three with the sentinel
  unchanged. No production code changed between those artifacts.

## Required review evidence

- Native resolution: not captured in this package.
- Keyboard/mouse and controller: not yet completed.
- Save/reload: covered by the focused v20-to-v21 migration smoke; manual
  migrated-save review remains required.
- Performance and licensing: no new performance measurement; the new profiles
  are explicitly pending visual review and are not final visual acceptance.

## Decision

**Rework required / not accepted.** The user is the visual/product reviewer.
Automated contracts establish implementation safety only; native captures,
input traversal, story participation, and visual approval are still required
before Section 9.0 can be accepted.
