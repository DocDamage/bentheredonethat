# M5-PERFORMANCE-BASELINE-01 — Windowed campaign diagnostic

- State: Measured on one development machine; not accepted
- Milestone: M5 — polish and production
- Tested commit: `ee96f6ed`
- Build version: Godot `4.7.1-stable (official)`
- Implementer: Codex
- Required reviewer: product/performance reviewer (user)

## Run contract

```powershell
.\tools\run_godot_isolated.ps1 `
  -Scene 'validation/campaign_performance_baseline.tscn' `
  -Windowed -KeepArtifacts -TimeoutSeconds 180
```

- Scene/save: `validation/campaign_performance_baseline.tscn` with isolated
  `user://campaign_performance_baseline.json`; the runner preserved the normal
  production-save sentinel (`sentinel=True`).
- Artifact root: `test-artifacts/20260723-190352-4e9483e1`.
- Render mode/resolution: windowed 960×540, Compatibility renderer, NVIDIA
  OpenGL 3.3 driver 596.49.
- Development machine: Intel Core i5-14600K (14 cores / 20 logical processors),
  NVIDIA GeForce RTX 3060, and 47.8 GiB installed memory. This is not yet the
  approved minimum specification.
- Keyboard/mouse, controller, native capture, and human visual review are not
  exercised by this timing diagnostic.

## Measured result

| Metric | Result | Provisional target | Status |
| --- | ---: | ---: | --- |
| Title to playable field | 663.137 ms | <= 5 s | Within target on this machine |
| Area activation | 35.140-174.872 ms | <= 2 s | Within target on this machine |
| Battle entry / results / field return | 511.162 / 388.663 / 256.113 ms | <= 2 s each | Within target on this machine |
| Save / load | 4.625 / 18.706 ms | <= 1 s each | Within target on this machine |
| Static memory / peak | 178.6 / 180.2 MB | <= 1 GB | Within target for this short run |
| 120-frame mean / p95 / max interval | 20.502 / 41.968 / 106.534 ms | p95 <= 16.7 ms; p99 <= 33.3 ms | Does not meet p95 target |

Fresh process startup to the title was 11,014.653 ms. It is retained as a
cold-launch observation, not compared to the warm title-to-field budget.
The probe does not calculate p99, so it cannot establish that portion of the
frame-pacing target.

## Decision

Rework required before performance acceptance. The diagnostic verifies that
the measurement path works and that short-run transitions, save/load, and
memory are within provisional targets on the development machine. Its p95 frame
interval is over the provisional target, the sample does not provide p99, and
the plan still requires a declared minimum machine plus representative and
multi-hour measurements. The known shutdown-only 61 ObjectDB / 26 resource
baseline was reproduced and is not accepted as a release decision.
