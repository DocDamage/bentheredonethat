# OWNER-ADMISSION-01 — Licence and visual-review decision

- State: Owner-approved for the current recorded inventory
- Decision date: 2026-07-23
- Decision maker: product owner (user)
- Scope: current runtime visual inventory, Mansion/Asterion/Primeval contact
  sheets, and the 258-identity SakPix source registry

## Owner direction

The owner confirmed that the supplied current licences cover all relevant
distribution rights and asked that the visual review be treated as approved.
This decision promotes the 182 currently tracked runtime visual sources to
`distribution_confirmed`, promotes 356 technically valid visual profiles to
`final_approved`, and confirms provenance for all 258 planned SakPix
identities.

## Retained technical limits

This decision does not bypass implementation contracts. The 21 profiles named
in `visual_assets/profile_review_decisions.json` remain `prototype_only`
because they have nonstandard or legacy field-scale contracts. SakPix
identities remain inactive until their runtime profiles, schedules, and
occupancy-safe placements are implemented. New sources remain outside this
decision until their inventory and evidence are updated.

## Performance direction

The owner requested broad modern-PC support and identified an RTX 3060 as the
development GPU. The project retains its 60 FPS target and current p95 budget;
the existing focused p95 measurement therefore remains a performance rework
item rather than an approved budget revision.
