# M2-HM-CAPTURE-01 — Mansion manifest state-capture generation

- State: Verified automated capture generation; visual/product acceptance pending
- Milestone: M2 — Mansion quality vertical slice
- Commit SHA: `5df50932`
- Build version: Godot project `0.3.0`
- Implementer: Codex
- Required reviewers: product/visual reviewer (user); licensing reviewer (unassigned)

## Scope

`validation/mansion_manifest_state_capture.tscn` activates every authored
`HM-01` through `HM-16` room through the production manifest runtime and
captures the rendered viewport at three declared review states:

- `first_visit`;
- `stabilized` (all Mansion gate flags open and Clock Mirror defeated);
- `postgame` (stabilized state plus `postgame_unlocked`).

Each capture is created after activating the room, placing the player at a
declared safe arrival, allowing the camera/streamer to settle, and asking
`VisualCaptureGuard` to save the rendered viewport. The runner writes only to
the isolated `user://` artifact directory; it does not add images to runtime
assets or treat screenshots as approved derivatives.

## Automated evidence

```powershell
$env:FFVI_CAPTURE_TAG = '5df50932'
.\tools\run_godot_isolated.ps1 -Scene \
  'validation/mansion_manifest_state_capture.tscn' -Windowed -KeepArtifacts \
  -TimeoutSeconds 240
```

- Artifact root: `test-artifacts/20260723-150617-e7dd86a0`.
- Capture root: `appdata/Godot/app_userdata/Ben There, Done That/m2-mansion-manifest-captures/`.
- PNGs: 48 non-empty files (16 rooms × 3 states).
- Resolution: 960×540 for the inspected native viewport frame.
- Manifest: `capture-manifest-5df50932.json`, with 48 records and the three
  declared state labels.
- Artifact audit: zero capture-failure, assertion, parse-error, or script-error
  markers; isolated production-save sentinel remained unchanged.
- The expected shutdown-only 61 ObjectDB / 26 resource warnings remain a known
  baseline and are not accepted as release evidence.

## Decision and remaining gates

These are technical, visual-review inputs only. They do **not** establish
art-direction approval, source/distribution eligibility, crop/palette/scale
acceptance, controller traversal, keyboard/mouse traversal, save/reload
acceptance, performance acceptance, or a complete campaign capture matrix.
The records intentionally label their input mode `visual_review_only`; no
controller or keyboard/mouse sign-off is inferred from a rendered frame.
