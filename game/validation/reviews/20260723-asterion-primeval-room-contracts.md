# M4-AS-PV-CONTRACT-01 — Asterion and Primeval authored-room contracts

- State: Implemented contracts; acceptance blocked by preproduction gates
- Milestone: M4 — Universe migration
- Base commit: `5ff1aae9`
- Build version: Godot project `0.3.0`
- Implementer: Codex
- Required reviewers: product/visual reviewer (user); licensing reviewer (unassigned)

## Intended result

Preserve the locked `AS-01`–`AS-14` and `PV-01`–`PV-14` graph contracts while
the complete art-admission, provenance, contact-sheet, and population work
packages are completed. These scenes must stay manifest-owned and may not add
new bootstrap geometry or raw source-library paths.

## Data contract

- Stable room ID, blueprint/dimensions, reciprocal ports, gate predicates,
  encounter policy, anchors, feature IDs, and profile IDs are supplied by
  `CampaignRoomRegistry`.
- Asterion medical (`AS-04`) and Primeval relay nest (`PV-07`) own their
  save-point interactions and register their stable save IDs while streamed.
- Active room runtime owns navigation and port installation; the facility
  portal is the only town-facing transition supplied by bootstrap.
- Non-goals: bulk runtime admission of ignored Tilesets/EXPANSION/SakPix
  source libraries, final art approval, roster activation, and release status.

## Required evidence before acceptance

- One work package per world with exact room graph, useful-cell totals,
  traversal targets, state capture matrix, cohort roster, performance budget,
  and approved asset/profile list.
- Deterministic source inventory and per-pack provenance decision for the
  selected first-pass sources.
- Native-scale contact sheets and visual sign-off for density, palette,
  perspective, headings, crops, and foot anchors.
- Keyboard/mouse, controller, save/reload, navigation-safe-arrival, and
  population-cohort evidence for every admitted active room.

## Decision

Rework required before acceptance: no distribution eligibility, contact-sheet
approval, or user visual/input sign-off is recorded for either world. The
manifest contracts are implementation evidence only.

