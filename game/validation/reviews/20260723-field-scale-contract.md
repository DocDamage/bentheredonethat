# Field-scale contract — 2026-07-23

## Decision

The campaign field uses one 48-world-pixel movement cell. The logical field
viewport is 1920×1080 and the default 960×540 window displays it at an exact
2× scale. This keeps a 48px step legible at the default window while preserving
an integer world coordinate system for transitions and camera following.

`CampaignFieldScale` is the authoritative contract for these values. It also
records the 42–72px visible field-character height range and review ranges for
doorways, facades, trees, counters, beds, chairs, treasures, and bosses.

## Rendering and placement rules

- New field profiles may render only at 0.5×, 1×, 2×, or 3× nearest-neighbor
  scale. Odd source dimensions are rounded once to a final integer world pixel.
- Final field positions, foot anchors, doorway anchors, and camera positions are
  integer world pixels. Foot anchors and collision-footprint identifiers remain
  separate metadata.
- Battle, portrait, and UI profiles declare separate `surface` values; their
  crops and scale are not treated as field-actor approval.
- A profile cannot receive `final_approved` visual status while it carries a
  legacy scale exception.

The manifest builder emits a resolved `renderScale`, `surface`, and
`fieldScaleStatus`. Only approved field scales can receive final visual
acceptance. Existing prototype profiles that need recapture are reported as
`prototype_review_required`; a named `legacyScaleException` is reserved for a
capture-sensitive compatibility asset. The runtime registry exposes scaled world
anchors so renderers do not need to repeat source-to-world math.

## Known migration exception

`mansion_foyer_passage_door` remains at a legacy 0.75× draw size to retain the
current Mansion capture while its crop is reviewed. It is explicitly marked
prototype-only and cannot be promoted to final visual acceptance. Replacing it
requires a 0.5× or 1× crop plus capture-parity review; this exception is not a
precedent for new profiles.

## Verification scope

The `campaign_field_scale_smoke` checks the movement/grid, semantic-range,
scale, pixel-snap, and 1080p/1440p/4K/16:10 camera math. The
`visual_profile_registry_smoke` checks every manifest profile has an auditable
field-scale status, preserves the single named compatibility exception, and
does not treat it as final-approved. Capture-based shimmer, composition, and
the remaining prototype-scale review remain release gates.
