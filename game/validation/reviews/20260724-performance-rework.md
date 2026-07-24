# M5-PERFORMANCE-REWORK-01 — Steady-state field and battle update reduction

- State: measured improvement; performance acceptance remains open
- Milestone: M5 — polish and production
- Implementer: Codex
- Required reviewer: product/performance reviewer (user)

## Change

`CampaignBootstrap` now reclassifies camera/area state only when the player's
cell or the streamed room changes. The explicit force path remains available
for restores, tests, and lifecycle transitions. `CampaignBattle` now updates
HP, MP, status, ready state, death modulation, and the 110-pixel ATB gauge
only when their visible value changes; the gauge rounds to its one-percent
display precision.

## Validation

- Broad browser/tool check: `npm run check` passed (16 Node and 26 Python/tool
  tests).
- Focused Godot field/battle batch passed (6/6) at
  `test-artifacts/20260724-014309-25602088`, with the production-save sentinel
  unchanged.
- The transition handoff still covered the same-cell streamed-room case
  (`HM-01 -> HM-02`), which is included in the camera cache key.

## Rendered measurement

Run on the established i5-14600K / RTX 3060 development machine, windowed
960×540 Compatibility renderer:

```powershell
.\tools\run_godot_isolated.ps1 `
  -Scene 'validation/campaign_performance_baseline.tscn' `
  -Windowed -TimeoutSeconds 240
```

- Artifact: `test-artifacts/20260724-014408-5cdf1789`
- Production-save sentinel: unchanged (`sentinel=True`)
- Town p99: `18.169 ms` (previously `39.598 ms`)
- Battle p99: `17.641 ms` (previously `42.618 ms`)
- Post-battle field p99: `17.282 ms` (previously `75.994 ms`)
- Transition, save/load, and short-run memory measurements remain within their
  provisional budgets.

## Decision

The large p99 spikes are removed in this focused run. The strict provisional
`p95 <= 16.7 ms` criterion is still narrowly missed: sampled area p95 values
are `16.893–17.505 ms`, battle is `16.991 ms`, and post-battle field is
`16.935 ms`. This evidence does not accept performance or alter the target;
it leaves the performance gate open pending a minimum-machine decision and
additional representative/multi-hour measurements.
