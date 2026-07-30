# Phase 5 — Mandatory address production verification

- State: Verified automated; human acceptance pending
- Implementation commit: `2365185e`
- Engine: Godot 4.7.1 stable
- Scope: Ashfall `AF-01`–`AF-12`, Pelagic `PL-01`–`PL-12`, Steamforge
  `SF-01`–`SF-12`, Frontier `FT-01`–`FT-10`, Warfront `WF-01`–`WF-10`, and
  Liminal `LM-01`–`LM-08`

## Implemented result

All 64 locked address rooms are admitted through the production annex registry.
Each record owns its blueprint-sized layout, complete navigation/collision
partition, safe arrivals and follower cells, reciprocal internal graph, named
New Philadelphia return, chapter visual profiles, population phases, room
classification, feature marker, and encounter ownership. The approved AF-01
Cinder Gate scene and field population remain intact; the remaining rooms use
the shared data-authored address scene rather than bootstrap branches.

The address combat catalog contains 41 executable formations, including every
critical encounter, declared optional encounter, and exactly one boss per
chapter. Generic room interactions launch those formations through the normal
ATB runtime and apply victory through one save-backed progression service.
Only critical encounters participate in chapter completion, so optional and
connective rooms cannot block the main route.

Each chapter resolution flag and its reward-claimed marker commit together.
Repeated completion cannot duplicate Duckets or items, and all state survives
save/reload. Ashfall, Pelagic, Steamforge, Frontier, Warfront, and Liminal must
all be resolved before Empyreal can commit the ending result.

## Automated evidence

- `npm run check`: 16 JavaScript tests and 26 visual-tool tests passed.
- `npm run validate:runtime-assets`: inventory, provenance, manifest, contact
  sheet, population registry, derivatives, and release references are current.
- Focused Phase 5 gate passed at
  `test-artifacts/20260730-045019-a1cea040`; it verifies 64 streamed rooms,
  41 executable encounter models, six bosses, optional-path independence,
  idempotent rewards, six named returns, save/reload, and ending gating.
- Full isolated Godot suite: 164/164 logs passed at
  `test-artifacts/20260730-045032-38880262`; the production-save sentinel was
  unchanged and all logs contain zero failure signatures.
- `git diff --check` and the staged diff check passed before the implementation
  commit.

## Gates that cannot be self-certified

Phase 5 implementation and automated verification are complete. Per the
project acceptance policy, the phase remains `Verified`, not `Accepted`, until
a human records keyboard/mouse and controller traversal, native-scale first
visit/restored/special-state visual review, chapter balance and accessibility
review, minimum-hardware performance review, and product-owner approval for all
64 address rooms.

## Post-verification correction

- Correction commit: `ae18cf9e`.
- Review found that defeating a chapter boss before the other critical
  encounters could leave the boss cleared without ever retrying chapter
  resolution. Resolution is now retried after every first-time encounter clear,
  so the final outstanding critical victory completes the chapter regardless of
  encounter order while retaining the one-time reward guard.
- The focused Phase 5 gate passed with boss-first ordering for all six chapters
  at `test-artifacts/20260730-052727-c9bb0cc1`.
- All 164 discovered isolated Godot smoke scenes passed across the retained
  artifact batches `test-artifacts/20260730-053016-b16901e5` (107 scenes) and
  `test-artifacts/20260730-054041-44029890` (57 scenes), with zero failure
  signatures. The completed second batch and focused run both reported the
  production-save sentinel unchanged.
- `npm run check`, `npm run validate:runtime-assets`, and `git diff --check`
  passed after the correction.
