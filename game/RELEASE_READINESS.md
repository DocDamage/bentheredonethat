# Release readiness

Status: **not ready to ship**. This file separates verified automated evidence
from the human, platform, licensing, and performance sign-offs that remain.

## Locked completion scope

- The release target is a 192-location mandatory main campaign, including the
  six Ashfall, Pelagic, Steamforge, Frontier, Warfront, and Liminal address
  campaigns. A release candidate cannot omit or relabel those stage families as
  optional content.
- Benjamin Franklin, Abraham Lincoln, and Mahatma Gandhi are required core
  protagonists from the opening through the ending. Field, battle, menu,
  progression, dialogue, save, and ending coverage for all three is a release
  gate.
- The SakPix population target is exactly 258 source identities with complete
  eight-direction art and theme-matched homes. Incomplete source directories
  are not planned characters and do not receive runtime or future-work entries.

## Verified locally

- The project has a numeric `0.3.0` technical build version with matching Windows
  file metadata, and runs without the development-only MCP runtime bridge or
  editor plugin enabled in `project.godot`.
- `tools/run_godot_isolated.ps1 -AllSmoke -TimeoutSeconds 360` passed all 84
  smoke scenes on July 22, 2026 using Godot 4.7.1. The reproducible artifact
  root is `test-artifacts/20260722-122356-0b17205d`; the runner used isolated
  user data and reported `sentinel=True`, so it did not alter the production
  save sentinel.
- A later progress-audit run against the 1:31 PM worktree passed 83/84 scenes
  and exposed a timing flake in `opening_presentation_smoke`: the test counted
  fast headless frames while the velociraptor patrol sampled wall-clock time.
  The animation now uses accumulated frame delta and the test advances a fixed
  0.8 simulated seconds; three consecutive targeted isolated reruns passed with
  `sentinel=True`. A new clean 84/84 aggregate run is still required before the
  current worktree supersedes the earlier artifact. The failed-run evidence is
  retained at `test-artifacts/20260722-133147-e2949947`.
- The July 23 population-scope update passes the full 134-scene isolated smoke
  matrix with the production-save sentinel intact. The host command limit split
  the evidence into 87 scenes at `test-artifacts/20260723-180041-0cc1f390` and
  the remaining 47 at `test-artifacts/20260723-182138-547178c9`; both batches
  contain no functional test failure and the second reports
  `ISOLATED_RUN_OK scenes=47 sentinel=True`.
- `release_resource_load_smoke` loaded all 557 runtime resources represented by
  the Windows preset (335 scripts, 117 scenes, 80 serialized resources, and 25
  Dialogic resources) with no missing imports or compile errors.
- The curated source-art catalog validates 21,018/21,018 approved rasters with
  no schema, path, crop, or animation errors and reports all 51 NPC visuals
  editor-ready. Newly staged Gandhi source art is explicitly quarantined pending
  license evidence, so it cannot silently expand the curated denominator or
  enter a release profile. The generator still limits itself to the canonical
  `assets/` library so mirrored runtime copies cannot produce duplicate catalog
  IDs. A green catalog proves structure, not license terms or distribution
  permission.
- `npm run validate:runtime-assets` now contains the tracked runtime manifest,
  inventory, contact-sheet, and provenance checks and is the clean-checkout CI
  gate. `npm run validate:source-library` makes the ignored local `assets/`
  requirement explicit; `npm run validate:assets` aggregates both workstation
  contracts. The current aggregate gate passes after rebuilding the derived
  inventory and ledgers; remote evidence remains pending.
- `npm run validate:source-inventory` rehashed the ignored source libraries on
  July 23, 2026. Its checked inventory matches the complete 149-pack Tilesets
  disposition register and records 156 source packs / 69,116 files, including
  5,568 exact duplicate families. This is curation evidence only: the 155
  Tilesets/EXPANSION plan packs and the staged Gandhi source folder still
  require distribution review and none is admitted by the inventory itself.
- A verbose isolated shutdown baseline on Godot 4.7.1 exits successfully but
  reports 61 ObjectDB instances (24 `GDScript`, 21 `Node`, five `RegEx`, four
  `Timer`, two each of `PackedScene` and `SceneState`, plus single audio/native
  class entries), 26 resources, and 470 `StringName`s at exit. The release
  launch shows the same 61/26 signature; this is a bounded baseline, not proof
  of no growth during a multi-hour session. The empty-scene
  `project_startup_baseline_smoke` reproduces the exact signature after only
  the 12 configured autoloads initialize, before the test instantiates campaign
  or visual-renderer content. The manifest-only
  `visual_profile_registry_smoke` also reproduces the same counts and 26
  shutdown-time `get_path`-outside-tree diagnostics without instantiating the
  campaign field. The signature is therefore not attributable to field or
  foreground construction; the specific engine, addon, or autoload ownership
  still needs confirmation before it can be accepted for release.
- `field_transition_soak_smoke` performs 12 repeated passes through all eight
  current field areas with four isolated save/load checkpoints. It verifies
  that area activation remains correct and that CampaignWorld and its
  ForegroundLayer do not accumulate duplicate children. This is a bounded
  regression test, not the required multi-hour memory/frame-pacing soak.
- `validation/campaign_performance_baseline.tscn` provides a windowed,
  machine-specific diagnostic for title-to-field, current-area activation,
  battle entry/results/return, save/load, memory snapshots, and 120-frame
  interval samples in each sampled area, active battle, and the post-battle
  field. Its July 23 RTX 3060 run remains `rework required`: town and battle
  p99, plus post-battle p95/p99, miss the declared frame-pacing budgets. It is
  diagnostic evidence, not proof that release performance targets have passed.
- The Options screen persists battle timing/mode, fullscreen, controller,
  Master/Music/SFX audio, and accessibility preferences. Master/Music/SFX now
  apply to their real buses at startup and on change; reduced motion removes
  battle lunges, shakes, and popup movement, while reduced flashes suppresses
  battle action-VFX overlays without removing text/status/audio feedback. The
  text-speed preference now applies to Dialogic's live reveal multiplier, and
  the Company menu, title, battle, and dialogue text-scale preference resizes
  their rendered controls. Field weather now consumes the persisted density
  preference and freezes snow, petals, motes, and mansion dust when reduced
  motion is enabled. Environmental-motion coverage still requires release
  review.
- The sandbox regression covers 100-command undo/redo, clipboard duplication,
  box/Ctrl-click multiselect, batch move undo/redo, pack search, validated slot
  round-trips, route preservation, and malformed-slot rejection.
- A clean Windows x86_64 `Windows Desktop` release export completed on July 22,
  2026. `output/windows/BenThereDoneThat.exe` was 322,605,456 bytes with SHA-256
  `1602F2A82FEBB91056D71C78AECE862D9CDFD96F914A3BDDB3FA49A20CD21D34`.
  Its Windows file/product versions are `0.3.0.0` / `0.3.0`. It launched
  headlessly for 20 frames with isolated user data, exited 0, and its startup
  log contained neither an MCP bridge nor an engine/script error.
- `tools/build_windows_release.ps1` reproduces the local Windows export and
  fails clearly when its preset or matching export templates are absent.
- `.github/workflows/godot-smoke.yml` pins Godot 4.7.1 on a Windows runner and
  runs the isolated smoke suite from a clean checkout, retaining test artifacts.
  The first clean remote pass was run `30003047658` on July 23, 2026 at commit
  `396571db`: `npm run check` passed 16 tests, `npm run validate:runtime-assets`
  passed, and all 114 discovered isolated Godot smoke scenes passed. The
  retained artifact is `godot-smoke-30003047658` (ID `8562299582`). The remote
  runner's `sentinel=False` is expected because it has no normal production
  save directory; local isolated validation remains the save-safety authority.
- The Windows preset excludes the inactive MCP addon, Dialogic editor-only
  resources, smoke tests, and visual captures; the export log confirms those
  paths are absent. Runtime Dialogic code reads the required character
  prefix/suffix values directly rather than statically depending on editor-only
  classes.
- `CREDITS.md`, the base `LICENSE`, and several supplied asset-pack license files
  are tracked in the repository.
- `runtime_asset_provenance.json` is generated from the static runtime visual
  inventory and checked by `npm run validate:assets`. Its companion
  `distribution_eligibility.json` assigns every tracked runtime source one of
  `distribution_confirmed`, `review_required`, or `rejected`; the product owner
  confirmed distribution rights for all 182 current runtime sources against the
  supplied licences on July 23, 2026. The visual-manifest generator rejects a
  profile sourced from a rejected asset. This is a current-inventory decision;
  newly introduced assets require their own evidence update.
- The runtime visual registry contains 356 final-approved profiles and 21
  explicitly pending scale-contract profiles. All 171 profile-required static
  source textures are covered. The remaining 11 static sources are Dialogic
  bundled addon UI SVGs, which remain visible as third-party dependencies rather
  than campaign-profile gaps. The coverage includes the active Town, Primeval,
  Frosthold, Moonpetal, Empyreal, Mansion, and Asterion battle materials. The
  battle profile smoke verifies all 53 catalog entries have approved backdrop
  profiles and renders 24 representative texture/region pairs; `CampaignBattle`
  rejects any encounter without an approved backdrop profile. All 38 catalog
  enemy actors, including the challenger sprites, Primeval dinosaurs, and the
  standard Mansion, Asterion, Helios, Frosthold, Moonpetal, and Empyreal
  enemies, resolve through approved profiles. All 13 catalog party characters
  and the Velociraptor companion also resolve through approved battle
  profiles; dynamically added editor/test recruits use registered profile
  fallbacks. The Armory's 20 purchasable equipment entries declare approved,
  checksum-validated icon profiles which the company menu resolves through the
  registry. The supplied battle command/HUD skins and the title/Company
  portraits for Ben, Fighter, and Astronaut also resolve through approved
  profiles. Interaction emotes, the universe treasure marker, all 20 sandbox
  terrain brushes, and the live Ranch/Modern/Haunted/Laboratory sandbox props
  resolve through approved profiles in the live map and editor previews as
  well. Final approval is intentionally withheld from the 21 named profiles
  with nonstandard field-scale or legacy-scale contracts.

## Release blockers

## Provisional supported-machine baseline

The product owner’s direction is broad modern-PC support, with an RTX 3060
development GPU. Until lower-spec measurements are captured, the provisional
minimum support profile is Windows 10/11 x64, a four-core CPU, 8 GB system
memory, a DirectX 11-capable GPU with 2 GB VRAM, 2 GB free storage, and a
1280×720 display. This is a declared planning baseline, not a claim that the
current RTX 3060 measurement proves performance on every machine in that range.
The 60 FPS and frame-pacing targets remain unchanged.

- [ ] Choose supported export platforms, storefronts, minimum hardware, and
  signing/notarization requirements. The tracked Windows x86_64 desktop preset
  is an initial local baseline, not a declaration of the final platform list.
- [ ] Install the matching Godot 4.7.1 export templates in CI/release machines,
  then reproduce the clean Windows release export and launch it outside the
  editor. Push the prepared smoke workflow and record its first clean remote
  pass. The local 4.7.1 x86_64 templates and baseline export are verified.
- [ ] Set the approved shipping version and final Windows publisher/signing metadata.
- [x] Record product-owner distribution approval for the current 182 static
  runtime visual sources and their supplied licence evidence.
- [ ] Extend the provenance ledger to audio, fonts, addons, dynamically
  resolved assets, and newly introduced runtime sources; consolidate required
  notices into shipped credits.
- [ ] Archive two fresh-save end-to-end playthroughs and one migrated-save run,
  including recall, defeat/retry, partial-puzzle reload, and backup recovery.
- [ ] Perform complete keyboard/mouse and modern-controller playthroughs at all
  supported resolutions, and inspect native-scale captures for every room.
- [ ] Measure campaign duration, load/save time, frame rate, and memory on the
  declared minimum hardware.
- [ ] Investigate or explicitly baseline the current shutdown-only
  ObjectDB/resource warnings over a multi-hour session.

Do not mark a release complete until every blocker has recorded evidence.
