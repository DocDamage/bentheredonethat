# Curated asset pipeline

`tools/build_curated_asset_catalog.py` inventories the supplied art and writes
`curated-asset-catalog.js`. It never duplicates cropped images: every editor item is a
source-coordinate crop pointing at an original raster.

Catalog display names are generated separately from source paths. The name pass removes
dimensions and export noise, expands common art abbreviations, adds action/direction
context to numbered animation frames, and gives numeric sheets a collection-aware label.
Stable source IDs and original paths never depend on these display names. Sources also
receive build-catalog categories, which can be overridden per source when needed.

## Run it

```powershell
python tools\build_curated_asset_catalog.py
```

Useful options:

```powershell
# Inspect the CLI and all safety limits
python tools\build_curated_asset_catalog.py --help

# Fast, deterministic smoke build
python tools\build_curated_asset_catalog.py --limit 25 --output smoke-catalog.js

# Inventory and safely extract ZIP/RAR/7z packs into sibling _extracted folders
python tools\build_curated_asset_catalog.py --extract-archives

# Also emit plain JSON for non-browser tooling
python tools\build_curated_asset_catalog.py --json-output curated-asset-catalog.json

# Verify paths, dimensions, IDs, coverage, crops, grids, and animations
python tools\validate_curated_asset_catalog.py

# Additionally decode every placeable crop and reject transparent placeholders
python tools\validate_curated_asset_catalog.py --deep

# Verify every runtime NPC has an exact Ready visual, directional set, or animation
node tools\validate_npc_asset_readiness.js
```

Archive extraction is opt-in. Member paths, drive paths, `..` traversal, alternate
streams, and link entries are checked before extraction. A blocked archive remains in
the inventory with its reason.

## Browser schema

The output assigns one deterministic object:

```js
window.CURATED_ART_ASSET_CATALOG = {
  schemaVersion: 1,
  pipelineVersion: "1.0.0",
  stats: {},
  sources: [],
  excluded: [],
  unsupported: [],
  archives: [],
  ignored: []
};
```

Each source includes `id`, `src`, `name`, `pack`, `kind`, `usable`, `reason`,
`width`, `height`, `format`, `sha1`, `alpha`, `bounds`, `preview`, and `variants`.
Optional fields include:

- `grid`: exact/inferred cell size, rows, columns, spacing, margin, provenance, and confidence.
- `regions`: compact `[x,y,w,h]` alpha-island crops. All regions are retained (up to
  the configured safety cap); only a few are repeated as initial browser cards.
- `regionsConfidence` and `regionsReason`: why compact regions were accepted.
- `animation`/`animations`: frame sources/crops, per-frame durations, total duration,
  FPS where known, and independent direction-row sequences.
- `aliases`: identical raster paths suppressed by SHA-1 content deduplication.
- `contentBounds`: visible pixels inside a deliberately preserved animation canvas.

Each variant has `id`, `name`, `src`, `x`, `y`, `w`, `h`, `kind`, and `usable`.
An animated variant additionally carries `animation.frames`; frames may reference
different source files. Regular grids are intentionally compact because the editor
can address every cell from the complete grid descriptor.

## Detection priority

The pipeline favors evidence in this order:

1. Explicit fixes and profiles in `asset-pipeline-overrides.json`.
2. Tiled TSX/TMX tile dimensions and animation records.
3. Supplied JSON sprite manifests with exact bounding boxes.
4. Filename frame dimensions and audited pack conventions.
5. Animated-image metadata, filename sequences, and bounded alpha-island analysis.
6. A trimmed standalone crop when no reliable subdivision exists.

Audited RPG Maker layouts include single- and multi-character sheets, faces,
side-view actors, and B–E tilesheets. Roster sheets also record south/west/east/north
walk cycles, middle-frame standing poses, and the RPG `0,1,2,1` playback order.
The NPC readiness gate checks all 51 runtime definitions, including separate
direction PNGs and multi-file robot animations. A-series autotiles stay in review because they
need compositor rules. Generic alpha-island crops carry lower confidence and enter
the editor's manual-review queue instead of appearing Ready by default.

Preview/reference art, root QA contact sheets, output folders, empty rasters,
unsafe autotiles, duplicate content, and covered sequence frames do not become
placeable cards. They remain explicitly accounted for in `excluded`, `ignored`,
aliases, archive inventory, or editable-source inventory.

## Overrides and editable sources

Add exact crops or grid profiles to `asset-pipeline-overrides.json`; crops are always
validated against source dimensions. Aero is the reference example: its fully opaque
standing crop is paired with a three-frame, full-canvas balloon-flight animation so
the rope and balloon silhouette cannot be clipped.

`asset-source-aliases.json` maps PSD/Aseprite sources to supplied PNG/GIF exports:

```json
{
  "version": 1,
  "sources": {
    "pack/source.psd": { "representedBy": ["pack/export.png"] }
  }
}
```

Mapped files report `represented_by_raster`; an unmapped editable source reports that
an export is still required. Output is stable: it contains no timestamps, inputs are
sorted, and IDs derive from normalized source coordinates rather than scan order.
