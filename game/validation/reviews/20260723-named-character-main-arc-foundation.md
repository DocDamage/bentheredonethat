# Named-character main-arc foundation — 2026-07-23

## Delivered scope

- Added the three locked named-character main-campaign contracts: the
  Mansion-to-Ashfall horror route (Dracula and Frankenstein's Monster), the
  Pelagic-depths route (Cthulhu), and the Ashfall-to-Empyreal conflict (Dark
  Mage).
- Made the Mansion stage live: after the required Clock Mirror victory,
  Dracula and Frankenstein's Monster appear in the authored `HM-09` ballroom.
  Speaking to both records the mandatory Ashfall follow-through and activates
  `The Ashes Remember` in the quest journal.
- The witnesses are story actors, not recruit records. This deliberately does
  not reuse the untracked optional trial prototype or mark the future Ashfall,
  Pelagic, or Empyreal address stages as implemented.

## Verification

- Focused live smoke passed at
  `test-artifacts/20260723-221825-ee3db954`:
  `named_character_main_arcs_smoke` verifies the contracts, post-boss witness
  spawning in the live campaign scene, dialogue flags, and the main quest.
- The combined integration logs at
  `test-artifacts/20260723-221703-656d2a29` show successful boot-flow and
  manifest-input handoff checks alongside the same named-character smoke.
- Additional focused progression slice passed at
  `test-artifacts/20260723-221602-e044e080`: quest progression, core trio, and
  field followers. (The only failed command entry requested a nonexistent
  `campaign_boot_flow_smoke` path; the real `boot_flow_smoke` passed in the
  subsequent integration run.)
- `npm run check` passed. After regenerating the required runtime visual
  inventory, `npm run validate:runtime-assets` passed.
