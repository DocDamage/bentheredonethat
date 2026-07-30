# Core manifest controller arrivals and placed-capture evidence

- State: Automated runtime evidence verified; visual/product acceptance pending
- Milestone: Manifest staging bounds, controller-arrival sweep, and placed capture matrix
- Working-tree capture tag: `controller-staging-fix`
- Build version: Godot project `0.3.0`
- Implementer: Codex
- Required reviewers: product/visual reviewer (user); licensing reviewer (unassigned)

## Scope

`tests/campaign_manifest_controller_arrivals_smoke.tscn` activates each
production route destination through `CampaignRoomRuntime`, places Ben at the
route's declared safe arrival, and sends one real D-pad move to a neighboring
non-port cell. It avoids triggering a second port while it verifies that the
arrival is live, unoccupied, controller-reachable, and returns input to the
player.

`validation/core_manifest_baseline_capture.tscn` now additionally verifies that
the activated room's capture cell is live and that Ben remains at that exact
cell after placement before saving a viewport frame. It captures only Ben so
followers cannot occupy a staging cell during visual review generation.

## Automated evidence

```powershell
.\tools\run_godot_isolated.ps1 -Scene \
  'tests/campaign_manifest_controller_arrivals_smoke.tscn' -KeepArtifacts \
  -TimeoutSeconds 420

$env:FFVI_CAPTURE_TAG = 'controller-staging-fix'
.\tools\run_godot_isolated.ps1 -Scene \
  'validation/core_manifest_baseline_capture.tscn' -Windowed -KeepArtifacts \
  -TimeoutSeconds 600
```

- Controller artifact: `test-artifacts/20260723-155513-c88e4756`.
  The isolated live-runtime sweep passed all 264 internal manifest-port
  arrivals across 102 rooms.
- Capture artifact: `test-artifacts/20260723-155851-9601f05e`.
  It contains 238 non-empty 960x540 PNGs and 238 matching manifest records:
  204 first-visit/stabilized baselines, 24 gate reasons, six restoration
  reasons, six boss-result reasons, and one postgame reason.
- The capture manifest is `capture-manifest-controller-staging-fix.json` with
  `visual_review_only` status. Audit found zero capture-failure, assertion,
  parse-error, or script-error markers; the isolated runner preserved the
  production-save sentinel.
- The expected shutdown-only 61 ObjectDB / 26 resource warnings remain a known
  baseline and are not release evidence.

## Decision and remaining gates

This is technical evidence that declared safe arrivals accept one controller
move in the live runtime and that the reviewed images were captured from their
declared live cells. It is not end-to-end controller traversal of every port,
interaction, treasure, facility, puzzle, boss return, shortcut, or recall path.
It also does not establish visual quality, source/distribution approval,
licensing, performance, save/reload, product, or release acceptance, and does
not satisfy the later 192-location / 384-baseline-capture target.
