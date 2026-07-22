# Release readiness

Status: **not ready to ship**. This file separates verified automated evidence
from the human, platform, licensing, and performance sign-offs that remain.

## Verified locally

- The project is versioned at `0.3.0-dev` and runs without the development-only
  MCP runtime bridge or editor plugin enabled in `project.godot`.
- `tools/run_godot_isolated.ps1 -AllSmoke -TimeoutSeconds 180` passed all 67
  smoke scenes on July 22, 2026. The runner used isolated user data and reported
  `sentinel=True`, so it did not alter the production save sentinel.
- The sandbox regression covers 100-command undo/redo, clipboard duplication,
  box/Ctrl-click multiselect, batch move undo/redo, pack search, validated slot
  round-trips, route preservation, and malformed-slot rejection.
- `CREDITS.md`, the base `LICENSE`, and several supplied asset-pack license files
  are tracked in the repository.

## Release blockers

- [ ] Choose supported export platforms, storefronts, minimum hardware, and
  signing/notarization requirements. There is no tracked `export_presets.cfg`.
- [ ] Create export presets, install matching Godot export templates, make a
  clean release export, and launch it outside the editor.
- [ ] Replace the `0.3.0-dev` version with the approved release version.
- [ ] Complete a license/provenance inventory for every distributed art, audio,
  font, addon, and source-derived runtime asset; consolidate required notices
  into the shipped credits.
- [ ] Archive two fresh-save end-to-end playthroughs and one migrated-save run,
  including recall, defeat/retry, partial-puzzle reload, and backup recovery.
- [ ] Perform complete keyboard/mouse and modern-controller playthroughs at all
  supported resolutions, and inspect native-scale captures for every room.
- [ ] Measure campaign duration, load/save time, frame rate, and memory on the
  declared minimum hardware.
- [ ] Investigate or explicitly baseline the current shutdown-only
  ObjectDB/resource warnings over a multi-hour session.

Do not mark a release complete until every blocker has recorded evidence.
