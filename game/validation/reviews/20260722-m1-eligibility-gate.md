# M1 visual-asset eligibility gate

- Work-package ID: `M1-eligibility-gate`
- Milestone/state: M1 — Implemented; legal and product review pending
- Commit SHA: pending checkpoint commit
- Build version: 0.3.0
- Scope: static runtime textures referenced by the visual-profile registry.

## Contract

`distribution_eligibility.json` records a default status and optional per-asset
overrides. The generated runtime provenance ledger copies the state to every
static raster source. Valid states are `distribution_confirmed`,
`review_required`, and `rejected`.

The visual-manifest generator reads that ledger and fails a build if any profile
uses a rejected source. This prevents rejected material from entering runtime
visual manifests or profile-derived contact sheets.

Each profile also has a generated `releaseVisualAcceptance` state. It defaults
to `prototype_only`; a profile may be marked `final_approved` only when its
source is `distribution_confirmed`. Crop approval remains a prototype-quality
decision and is deliberately not treated as distribution clearance.

## Current evidence

- 159 static runtime sources are represented; all are explicitly
  `review_required` rather than being implicitly approved.
- 193 profiles validate against the ledger.
- `npm run check`: pass, including the rejection regression test.
- `visual_profile_registry_smoke`: pass, 193 profiles.

## Review decision

Rework required before acceptance: confirm the source terms, authors,
modification status, redistribution permission, and required attribution for the
laboratory, town, and Mansion sources. Only then may their ledger entries be
changed to `distribution_confirmed`. Product/visual reviewer: user; licensing
reviewer: unassigned.
