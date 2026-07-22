# Release readiness

Status: **not ready to ship**. This file separates verified automated evidence
from the human, platform, licensing, and performance sign-offs that remain.

## Verified locally

- The project has a numeric `0.3.0` technical build version with matching Windows
  file metadata, and runs without the development-only MCP runtime bridge or
  editor plugin enabled in `project.godot`.
- `tools/run_godot_isolated.ps1 -AllSmoke -TimeoutSeconds 180` passed all 67
  smoke scenes on July 22, 2026. The runner used isolated user data and reported
  `sentinel=True`, so it did not alter the production save sentinel.
- The sandbox regression covers 100-command undo/redo, clipboard duplication,
  box/Ctrl-click multiselect, batch move undo/redo, pack search, validated slot
  round-trips, route preservation, and malformed-slot rejection.
- A clean Windows x86_64 `Windows Desktop` release export completed on July 22,
  2026. `output/windows/BenThereDoneThat.exe` was 324,150,520 bytes with SHA-256
  `BE218AD917E85423AC4881AEB49961D6C2AD2DFC1AD54675213A46DFD50A069D`.
  Its Windows file/product versions are `0.3.0.0` / `0.3.0`. It launched
  headlessly for 20 frames with isolated user data, exited 0, and its startup
  log contained neither an MCP bridge nor an engine/script error.
- `tools/build_windows_release.ps1` reproduces the local Windows export and
  fails clearly when its preset or matching export templates are absent.
- The Windows preset excludes the inactive MCP addon, smoke tests, and visual
  capture resources; the export log confirms those paths are absent. Dialogic's
  current runtime scripts still statically depend on classes in its `Editor`
  folder, so that third-party folder remains packaged.
- `CREDITS.md`, the base `LICENSE`, and several supplied asset-pack license files
  are tracked in the repository.

## Release blockers

- [ ] Choose supported export platforms, storefronts, minimum hardware, and
  signing/notarization requirements. The tracked Windows x86_64 desktop preset
  is an initial local baseline, not a declaration of the final platform list.
- [ ] Install the matching Godot 4.7.1 export templates in CI/release machines,
  then reproduce the clean Windows release export and launch it outside the
  editor. The local 4.7.1 x86_64 templates and baseline export are verified.
- [ ] Set the approved shipping version and final Windows publisher/signing metadata.
- [ ] Complete a license/provenance inventory for every distributed art, audio,
  font, addon, and source-derived runtime asset; consolidate required notices
  into the shipped credits.
- [ ] Remove or update Dialogic's export-time dependency on its editor classes
  before claiming a release with no editor-content dependency.
- [ ] Archive two fresh-save end-to-end playthroughs and one migrated-save run,
  including recall, defeat/retry, partial-puzzle reload, and backup recovery.
- [ ] Perform complete keyboard/mouse and modern-controller playthroughs at all
  supported resolutions, and inspect native-scale captures for every room.
- [ ] Measure campaign duration, load/save time, frame rate, and memory on the
  declared minimum hardware.
- [ ] Investigate or explicitly baseline the current shutdown-only
  ObjectDB/resource warnings over a multi-hour session.

Do not mark a release complete until every blocker has recorded evidence.
