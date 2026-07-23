# Runtime Visual Gap Classification

- **Status:** implementation-audit evidence; not visual or distribution approval
- **Inventory:** `game/ben_rpg/visual_assets/generated/runtime_visual_inventory.json`
- **Provenance ledger:** `game/ben_rpg/visual_assets/generated/runtime_asset_provenance.json`

## Current denominator

The static runtime inventory contains 183 sources: 162 have one or more visual
profiles and 21 have not yet been migrated. Every unprofiled source now carries
an explicit `unprofiledClassification`; no unclassified gap is permitted.

Of those sources, 172 are campaign-owned or compatibility visuals that require
profile coverage. The 11 Dialogic module visuals are retained as explicit
third-party dependency records, not quietly removed from the provenance audit.
Thus the actionable campaign profile denominator is 162 of 172, with 10
compatibility migrations outstanding.

| Classification | Sources | Owner and next action |
| --- | ---: | --- |
| `third_party_addon_ui` | 11 | Dialogic module and default-layout SVGs. Track them as a bundled dependency and retain their upstream license evidence; do not create campaign-content profiles for plugin internals. |
| `legacy_compatibility_visual` | 10 | The legacy combat arena, four legacy battlers plus action icon, two overworld character sheets, and two cutscene/main tilemaps. Replace these compatibility scenes with campaign-owned profile consumers, then remove their raw references. |
| `dynamic_template_visual` | 0 | Completed: the two `%s` south/west character-path fallbacks now resolve through registered company profile IDs, so no raw template remains in the release inventory. |

All three classes remain `review_required` for distribution. This record is a
migration routing decision only: it does not grant final crop approval, final
visual acceptance, or a license admission.

## Dynamic-template migration verification

Company battle and portrait fallbacks now read `battle_profile` and
`portrait_profile` from the recruit catalog. The old `%s` south/west path
templates are absent from the runtime inventory, and the resulting static
denominator is 183 sources with 162 profiled.

The affected isolated Godot checks passed: menu, roster, battle UI, and state
contract logs are retained in `test-artifacts/20260723-131027-0767dbd7`; the
corrected profile-registry log is retained in
`test-artifacts/20260723-131340-71eef8dc`. The successful profile run preserved
the production-save sentinel. The complete asset-tool test suite also passed
22 tests, and the inventory, provenance, and runtime visual manifest are
current.
