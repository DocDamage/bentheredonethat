# Runtime Visual Gap Classification

- **Status:** implementation-audit evidence; not visual or distribution approval
- **Inventory:** `game/ben_rpg/visual_assets/generated/runtime_visual_inventory.json`
- **Provenance ledger:** `game/ben_rpg/visual_assets/generated/runtime_asset_provenance.json`

## Current denominator

The static runtime inventory contains 185 sources: 162 have one or more visual
profiles and 23 have not yet been migrated. Every unprofiled source now carries
an explicit `unprofiledClassification`; no unclassified gap is permitted.

| Classification | Sources | Owner and next action |
| --- | ---: | --- |
| `third_party_addon_ui` | 11 | Dialogic module and default-layout SVGs. Track them as a bundled dependency and retain their upstream license evidence; do not create campaign-content profiles for plugin internals. |
| `legacy_compatibility_visual` | 10 | The legacy combat arena, four legacy battlers plus action icon, two overworld character sheets, and two cutscene/main tilemaps. Replace these compatibility scenes with campaign-owned profile consumers, then remove their raw references. |
| `dynamic_template_visual` | 2 | The `%s` south/west character paths in the campaign menu and combat database. Resolve these through data-owned visual profile IDs rather than a format-string fallback. |

All three classes remain `review_required` for distribution. This record is a
migration routing decision only: it does not grant final crop approval, final
visual acceptance, or a license admission.
