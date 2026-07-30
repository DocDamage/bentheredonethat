# Phase 2 — Mansion vertical slice verification

- State: Verified automated; human acceptance pending
- Implementation commit: `c4e97fa2`
- Engine: Godot 4.7.1 stable
- Platform: Windows, NVIDIA GeForce RTX 3060
- Scope: opening/laboratory handoff and `HM-01` through `HM-16`

## Implemented result

The production facility portal now hands Ben, Lincoln, and Gandhi into a fully
scene-backed sixteen-room Mansion graph. Room manifests own the foyer encounter,
03:13/04:44 clock and ledger sequence, Gallery and Nursery ambushes, both clock
hands, Archive and antechamber saves, Ballroom boss, optional Conservatory,
Chapel, Undercroft, Attic, Kitchen Lift, rewards, shortcuts, restoration, and
postgame state. Battle victory persistence is applied at the shared lifecycle
boundary, so manifest encounters cannot bypass chapter flags.

The room streamer now inherits the field canvas transform. This fixes the defect
that placed authored room art half-scale and off-camera. Mansion interiors use
checksum-validated Haunted Mansion wall, plank, stone, nursery, furnishing, and
grandfather-clock profiles; the incompatible clock photograph and flat prototype
surfaces no longer appear in the Phase 2 field presentation.

## Automated evidence

- `npm run check`: 16 JavaScript tests and 26 visual-tool tests passed.
- `npm run validate:runtime-assets`: current inventory, provenance, manifest,
  contact sheet, population registry, derivatives, and release references.
- Full Godot smoke suite: 161/161 passed at
  `test-artifacts/20260730-000444-8c8b78f8`, sentinel unchanged.
- Phase 2 focused suite: 4/4 passed at
  `test-artifacts/20260730-002345-4bd01aea`, including room-owned state,
  save/reload, bestiary/profile, and live handoff coverage.
- Final capture matrix: 288 captures (16 rooms × 6 states × 3 requested window
  sizes) at `test-artifacts/20260730-002708-52a035f5`; the harness fails on an
  inactive navigation cell or incorrect party placement instead of capturing
  the laboratory fallback.
- Performance: all 16 rooms passed at
  `test-artifacts/20260730-000348-24dfc77e`. Worst measured transition was
  249.962 ms; focused frame interval was p95 16.866 ms, p99 16.984 ms, max
  17.169 ms; peak static memory was 181,249,669 bytes at 960×540.
- Pacing contract: 90-minute minimum, 117-minute target, 150-minute maximum.

Shutdown retains the existing 61 ObjectDB / 26 resource diagnostic signature;
the full run passed and did not classify that pre-existing shutdown-only output
as a Phase 2 runtime failure.

## Gates that cannot be self-certified

The implementation is complete and automated verification is green. The phase
must remain `Verified`, not `Accepted`, until a human records:

- complete keyboard/mouse and controller playthroughs;
- blind-player route and 4:44 comprehension;
- balance/timing confirmation of an actual 90–150 minute playthrough;
- accessibility and final native-scale visual/product approval.
