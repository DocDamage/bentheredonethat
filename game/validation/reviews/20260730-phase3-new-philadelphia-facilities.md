# Phase 3 — New Philadelphia and facilities verification

- State: Verified automated; human acceptance pending
- Implementation commit: `73a347c1`
- Engine: Godot 4.7.1 stable
- Scope: `NP-01`–`NP-15`, `FI-01`–`FI-11`, stable lots, population phases,
  campaign-menu context, and sandbox-editor history ownership

## Implemented result

New Philadelphia now uses the production annex streamer for all fifteen hub
rooms and eleven stable facility interiors. The shared room runtime owns
navigation, camera bounds, reciprocal ports, lot entrances, facility returns,
and core-universe handoffs. The legacy founding state migrates into stable
`LOT-01`–`LOT-11` to `FI-01`–`FI-11` identities without discarding facility
assignments, active jobs, quest flags, or portal state; relocation preserves
the same facility identity and interior.

District population contracts now resolve bounded cohorts for founding,
construction, connected, and stabilized phases, including universe imports and
post-stabilization activity. Population anchors and routes remain capped at six
and are validated against ports and interaction cells. Facility interiors own
their service/job contracts, population anchors, portal selection, and lot
return. `NP-15` retains the gated `AF-01` runtime route and the gated `WF-01`
production contract.

The campaign menu delegates location/facility context and the sandbox editor
delegates undo/redo history while preserving their compatibility surfaces.
Phase 3 streaming also fixes two traversal defects found during regression:
the staging region is inside the gameboard path graph, and annex transition
triggers use cell-center coordinates.

## Automated evidence

- `npm run check`: 16 JavaScript tests and 26 visual-tool tests passed.
- `npm run validate:runtime-assets`: inventory, provenance, manifest, contact
  sheet, population registry, derivatives, and release references are current.
- Full Godot smoke suite: 162/162 passed at
  `test-artifacts/20260730-014325-608801c9`, production-save sentinel unchanged.
- Final Phase 3 contract/runtime retest: 2/2 passed at
  `test-artifacts/20260730-015903-6b91bb8a`.
- Placement/save/runtime smoke: all 121 facility/lot combinations entered the
  stable mapping; save/reload, active jobs, assignments, relocation, streamed
  scene placement, and bounded district population contracts passed.
- Mansion compatibility traversal: `HM-01 → FI-05 → LOT-05/NP-07` passed at
  `test-artifacts/20260730-014209-539e2764`.
- `git diff --check` passed before the implementation commit.

The suite retains the established shutdown-only 61 ObjectDB / 26 resource
diagnostic signature; all fixtures passed and the runner did not classify it as
a runtime failure.

## Gates that cannot be self-certified

The Phase 3 implementation is complete and automated verification is green.
Per the project acceptance policy, the phase remains `Verified`, not
`Accepted`, until a human records complete keyboard/mouse and controller
traversal, resident-schedule observation, accessibility, native-scale visual
and product approval, and the required manual save/recall/service/objective
playthroughs.
