# M5-PERFORMANCE-BASELINE-01 — Windowed campaign diagnostic

- State: Measured on one development machine; not accepted
- Milestone: M5 — polish and production
- Tested commit: `7720ea75`
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
- Artifact root: `test-artifacts/20260723-190608-e86cc1bc`.
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
| Title to playable field | 370.366 ms | <= 5 s | Within target on this machine |
| Area activation | 41.276-78.123 ms | <= 2 s | Within target on this machine |
| Battle entry / results / field return | 245.930 / 45.930 / 49.587 ms | <= 2 s each | Within target on this machine |
| Save / load | 5.078 / 21.104 ms | <= 1 s each | Within target on this machine |
| Static memory / peak | 178.6 / 180.2 MB | <= 1 GB | Within target for this short run |
| 120 focused-frame mean / p95 / p99 / max interval | 16.598 / 19.743 / 25.282 / 32.145 ms | p95 <= 16.7 ms; p99 <= 33.3 ms | p99 meets target; p95 does not |

Fresh process startup to the title was 10,338.203 ms. It is retained as a
cold-launch observation, not compared to the warm title-to-field budget.
All 120 sampled frames reported a focused window. The probe now calculates p99
alongside p95, so background-window throttling is not an explanation for the
remaining p95 miss.

## Decision

Rework required before performance acceptance. The diagnostic verifies that
the measurement path works and that short-run transitions, save/load, and
memory and p99 are within provisional targets on the development machine. Its
p95 frame interval is over the provisional target, and the plan still requires
a declared minimum machine plus representative and multi-hour measurements. The
known shutdown-only 61 ObjectDB / 26 resource baseline was reproduced and is
not accepted as a release decision.
