# NP-01 Franklin Laboratory initial visual evidence — 2026-07-24

- State: scene/collision implemented; runtime, population, interaction, and
  district traversal remain gated.
- Scope: the first New Philadelphia laboratory foundation, using only existing
  final-approved laboratory profiles.

## Evidence

- `game/validation/np01-franklin-laboratory-scene-first-visit.png` is the
  deterministic windowed first-visit capture.
- The H1 room retains both `Ne` and `Se` safe-arrival routes and reserves five
  collision cells for the central workbench and four laboratory stations.
- Its floor/wall, storage, calibrator, analysis, and fabricator art resolve
  entirely through approved laboratory visual profiles. The workbench marker
  is intentionally visible only as a gated contract; it does not grant access
  to any legacy invention, construction, or save state.
- Focused content/catalog/scene/annex checks passed at
  `test-artifacts/20260724-023029-844a131a`; the separate windowed capture
  passed at `test-artifacts/20260724-023049-3088aa17`. Both retained the
  production-save sentinel unchanged.

## Remaining decision

This is not approval to stream NP-01 or to change the existing founding
workflow. Product review can approve the baseline or request rework before
population schedules, workbench interaction, in-hub transitions, or any
legacy ownership change is admitted.
