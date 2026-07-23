# Field scale bible

Status: proposed implementation standard; visual sign-off remains required.

The campaign uses a 48-by-48 world-pixel movement cell. `CampaignFieldScale`
is the executable authority for the cell size, source-density conversions, room
camera bounds, and pixel alignment. The logical viewport is 1920 by 1080;
the default desktop window is a 960 by 540 presentation of that canvas.

## Source conversion

| Source tile density | World scale | Result |
| --- | ---: | --- |
| 16 px | 3x | 48 px movement cell |
| 24 px | 2x | 48 px movement cell |
| 48 px | 1x | native movement cell |
| 96 px | 0.5x | 48 px movement cell |

Only these integer or exact reciprocal conversions are admissible for field
tiles. Nearest-neighbor filtering is required. A compatible mathematical
conversion is not an art-direction approval.

## Field silhouettes and anchors

- Normal field characters: 42–72 visible pixels from feet to crown at their
  normalized field scale.
- Door opening: 36–56 px high; a single-story facade: 96–160 px high;
  multi-story facade: 160–288 px high.
- Counters: 28–52 px; beds: 36–72 px; chairs: 28–52 px; treasure props:
  24–48 px; ordinary trees: 120–216 px; boss field silhouettes: 96–192 px.
- The foot anchor is on the ground-contact point, independent of transparent
  padding. Collision uses the footprint/base, never the whole visible sprite.
- Battle scale and portrait crops are independent contracts. A field crop must
  not be reused as a battle silhouette or portrait simply because it is
  available.

## Pixel stability and camera

- Final world and camera positions are snapped to integer world pixels.
- Room camera bounds derive from `room cells × 48`, not hand-entered pixels.
- Camera zoom may frame a room but must not change source asset scale or create
  fractional final placement. Capture review at 1080p, 1440p, 2160p, and a
  16:10 viewport remains a visual acceptance requirement.
