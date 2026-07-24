# M5-PERFORMANCE-BASELINE-01 — Windowed campaign diagnostic

- State: Measured on one development machine; not accepted
- Milestone: M5 — polish and production
- Tested commit: `bda88513`
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
- Artifact root: `test-artifacts/20260723-204223-3fbca075`.
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
| Title to playable field | 370.037 ms | <= 5 s | Within target on this machine |
| Area activation | 40.990-69.261 ms | <= 2 s | Within target on this machine |
| Battle entry / results / field return | 301.915 / 110.355 / 137.779 ms | <= 2 s each | Within target on this machine |
| Save / load | 5.089 / 17.302 ms | <= 1 s each | Within target on this machine |
| Static memory / peak | 180.1 / 180.5 MB | <= 1 GB | Within target for this short run |
| Area 120-frame p95 / p99 interval | 16.938-17.642 / 17.106-39.598 ms | p95 <= 16.7 ms; p99 <= 33.3 ms | Town exceeds both budgets; other areas narrowly miss p95 |
| Battle 120-frame p95 / p99 interval | 17.007 / 42.618 ms | p95 <= 16.7 ms; p99 <= 33.3 ms | Both budgets missed |
| Post-battle field 120-frame p95 / p99 interval | 38.628 / 75.994 ms | p95 <= 16.7 ms; p99 <= 33.3 ms | Both budgets missed |

Fresh process startup to the title was 9,424.973 ms. It is retained as a
cold-launch observation, not compared to the warm title-to-field budget. All
samples reported a focused window. The probe now captures each sampled area,
an active battle, and the field immediately after the battle returns; a single
final field sample is no longer treated as representative of the whole path.

## Decision

Rework required before performance acceptance. The diagnostic verifies that
the measurement path works and that short-run transitions, save/load, and
memory remain within provisional targets on the development machine. It also
shows p95 and p99 misses in the town, active battle, and post-battle field;
the plan still requires a declared minimum machine plus representative and
multi-hour measurements. The known shutdown-only 61 ObjectDB / 26 resource
baseline was reproduced and is not accepted as a release decision.
