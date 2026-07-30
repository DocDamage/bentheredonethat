# M1-NAV-CONTRACT-06 and M0-ASSET-VALIDATION-03

- State: Verified automated contract; visual, collision, input, population, and licensing acceptance remain pending
- Milestones: M0 — trustworthy verification baseline; M1 — shared manifest room platform
- Commits: `178afd07`, `20ef6db3`, `c42c308d`
- Build version: Godot project `0.3.0`
- Implementer: Codex
- Required reviewers: product/visual reviewer (user); collision/navigation reviewer (unassigned)

## Intended result

Replace the remaining generated navigation baselines for Frosthold, Moonpetal,
and Empyreal with room-owned authored navigation/collision contracts. Verify
the separate clean-checkout-safe and local source-library asset contracts, and
prove that browser path aliases resolve to the reorganized runtime paths.

## Automated evidence

```powershell
.\tools\run_godot_isolated.ps1 -Scene @(
  'tests/frosthold_layout_smoke.tscn',
  'tests/frosthold_scenario_smoke.tscn',
  'tests/moonpetal_layout_smoke.tscn',
  'tests/moonpetal_scenario_smoke.tscn',
  'tests/empyreal_layout_smoke.tscn',
  'tests/empyreal_scenario_smoke.tscn',
  'tests/campaign_room_registry_smoke.tscn'
) -TimeoutSeconds 120
```

- Focused Frosthold, Moonpetal, and Empyreal runs all passed with their
  production-save sentinel unchanged (`sentinel=True`). Artifact roots:
  `test-artifacts/20260723-102755-d12eb653`,
  `test-artifacts/20260723-103058-c1bf2079`, and
  `test-artifacts/20260723-103319-ad8408df`.
- The subsequent all-smoke artifact root contains 121 scene logs and no
  `FAILED`, `SCRIPT ERROR`, assertion, parse, or error markers:
  `test-artifacts/20260723-103431-8debd6d2`. The interrupted terminal session
  did not preserve the runner's final exit/sentinel line, so this is supporting
  evidence rather than a replacement for a future completed full-suite gate.
- `npm run check`, `npm run validate:runtime-assets`,
  `npm run validate:source-library`, and `npm run validate:assets` passed.
  The source contract reports 51/51 editor-ready NPC visuals and 0 catalog
  errors/warnings.
- A browser session at `http://localhost:8080` returned HTTP 200 for all 42
  observed requests, including reorganized `assets/characters/NPCs/...` paths,
  and reported zero console warnings or errors.

## Decision

Rework remains required before visual acceptance. The new navigation records
are explicit room-owned contracts, but they have not yet been reviewed against
final visible terrain, foreground overlap, controller traversal, population
routes, or asset licensing decisions. The known shutdown-only 61 ObjectDB / 26
resource signature also remains open and is not accepted by this work package.
