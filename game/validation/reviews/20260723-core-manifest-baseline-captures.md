# Core manifest baseline-capture generation

- State: Verified automated capture generation; visual/product acceptance pending
- Milestone: Campaign manifest baseline evidence
- Commit SHA: `e0729f27`
- Build version: Godot project `0.3.0`
- Implementer: Codex
- Required reviewers: product/visual reviewer (user); licensing reviewer (unassigned)

## Scope

`validation/core_manifest_baseline_capture.tscn` activates every production
room registered by `CampaignRoomRegistry` through the manifest runtime. For each
of the 102 currently registered rooms, it captures the rendered viewport in the
declared `fresh` and `stabilized` story states after placing the player at that
room's declared safe arrival and allowing the runtime to settle.

The runner writes only into the isolated `user://` artifact directory. It does
not add runtime assets, approve any source material, or assert that a still
frame proves traversal or interaction behavior.

## Automated evidence

```powershell
$env:FFVI_CAPTURE_TAG = 'e0729f27'
.\tools\run_godot_isolated.ps1 -Scene \
  'validation/core_manifest_baseline_capture.tscn' -Windowed -KeepArtifacts \
  -TimeoutSeconds 600
```

- Artifact root: `test-artifacts/20260723-151109-dcf8afad`.
- Capture root:
  `appdata/Godot/app_userdata/Ben There, Done That/core-manifest-baseline-captures/`.
- PNGs: 204 non-empty files (102 rooms × `fresh` and `stabilized`).
- Resolution: 960×540 for an inspected native viewport frame; capture metadata
  records the source viewport as 1920×1080.
- Manifest: `capture-manifest-e0729f27.json`, with 204 records, the matching
  capture tag, `fresh`/`stabilized` state labels, and
  `visual_review_only` input mode.
- Artifact audit: zero capture-failure, assertion, parse-error, or script-error
  markers. The production-save sentinel state was unchanged by the isolated run.
- The expected shutdown-only 61 ObjectDB / 26 resource warnings remain a known
  baseline and are not release evidence.

## Decision and remaining gates

These are technical, visual-review inputs only. They do **not** complete the
plan's 192-location / 384-capture matrix, cover the additional boss, gate,
restoration, or postgame states, or grant art-direction, source/distribution,
crop/palette/scale, controller, keyboard/mouse, save/reload, performance,
licensing, product, or release acceptance. The separate Mansion state run
provides extra Mansion review states, but neither run is a campaign-wide final
acceptance record.
