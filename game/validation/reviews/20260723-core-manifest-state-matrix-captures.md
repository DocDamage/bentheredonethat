# Core manifest state-matrix capture generation

- State: Verified automated capture generation; visual/product acceptance pending
- Milestone: Campaign manifest capture matrix
- Commit SHA: `08293307`
- Build version: Godot project `0.3.0`
- Implementer: Codex
- Required reviewers: product/visual reviewer (user); licensing reviewer (unassigned)

## Scope

`validation/core_manifest_baseline_capture.tscn` renders the 102 production
rooms registered by `CampaignRoomRegistry` through the production manifest
runtime. It records the 204 first-visit/stabilized baselines, then obtains the
non-baseline matrix from the same manifest data:

- 24 gate reasons;
- 6 restoration reasons;
- 6 boss-result reasons; and
- 1 postgame reason.

Three boss reasons share a room and state flag with a gate reason, so the
matrix produces 34 distinct supplemental frames rather than 37 duplicate
images. Each frame activates its room, places the player at a declared safe
arrival, waits for the runtime to settle, and saves the rendered viewport to
the isolated `user://` artifact directory.

## Automated evidence

```powershell
$env:FFVI_CAPTURE_TAG = '08293307'
.\tools\run_godot_isolated.ps1 -Scene \
  'validation/core_manifest_baseline_capture.tscn' -Windowed -KeepArtifacts \
  -TimeoutSeconds 600
```

- Artifact root: `test-artifacts/20260723-151756-494dfc85`.
- Capture root:
  `appdata/Godot/app_userdata/Ben There, Done That/core-manifest-baseline-captures/`.
- PNGs and manifest records: 238 non-empty files (204 baseline + 34 declared
  supplemental variants).
- Resolution: 960×540 for an inspected native viewport frame; the capture
  metadata reports its source viewport as 1920×1080.
- Manifest: `capture-manifest-08293307.json`, with the matching capture tag,
  `visual_review_only` input mode, source state, state flag, and capture reason
  for every record.
- Artifact audit: zero capture-failure, assertion, parse-error, or script-error
  markers. The isolated runner reported an unchanged production-save sentinel.
- The expected shutdown-only 61 ObjectDB / 26 resource warnings remain a known
  baseline and are not release evidence.

## Decision and remaining gates

This confirms that the automated matrix can generate technical visual-review
inputs for every state currently declared by the 102-room registry. It does
**not** prove visual differences or their quality, nor does it satisfy the
plan's later 192-location / 384-baseline-capture target. It also does not grant
art-direction, source/distribution, crop/palette/scale, controller,
keyboard/mouse, save/reload, performance, licensing, product, or release
acceptance. The images remain review inputs until the required human and
runtime evidence is recorded.
