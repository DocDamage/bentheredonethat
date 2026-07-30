# Field scale and camera standard

The field grid is **48 world pixels per cell** and the default gameplay window is
**960 × 540** (with a 1920 × 1080 logical viewport). All field art uses nearest-neighbor
filtering, integer final coordinates, and either integral or exact reciprocal scale.

| Semantic object | Target visible size | Foot/collision rule |
| --- | ---: | --- |
| Field character | 36–48 px tall | Feet are the anchor; collision is a 24–32 px base. |
| Doorway | 36–48 px wide | Interaction cell is centered on the visible threshold. |
| Single-story facade | 144–192 px wide | Doorway and collision base are independently anchored. |
| Multi-story / landmark facade | 192–288 px wide | Upper facade may be a foreground layer. |
| Tree | 48–144 px tall | Trunk base is Y-sorted; canopy is foreground. |
| Counter / bed / chair | 24–96 px | Use a visible blocking base, never the full sprite rectangle. |
| Treasure / small prop | 24–48 px | Anchor at the lowest opaque pixel. |
| Boss field marker | 96–192 px | Battle scale is authored separately from field scale. |

Source-density conversions are 16 px → 3×, 24 px → 2×, 48 px → 1×, and 96 px →
0.5×. The renderer must not use arbitrary fractional scales or final fractional placement.
Portrait crops and battle frames are separate visual profiles; neither inherits a field crop.

Every area owns its visible ground, collision/navigation, interaction anchors, actor/prop
Y-sort layer, foreground occluders, and camera metadata. A scene is not approved until
its native-scale capture verifies those relationships.
