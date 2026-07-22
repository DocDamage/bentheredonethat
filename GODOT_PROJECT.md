# Primary Godot project

`game/project.godot` is the release target. Open it with the project-local
Godot 4.7.1 executable, or run `game/run_godot_4_7_1.cmd`. All campaign,
release, smoke-test, export, and save-safety work belongs in `game/`, which is
based on GDQuest OpenRPG.

The repository-root browser app is a maintained prototype and asset-validation
surface. It is not a second release target: do not duplicate new campaign
systems there unless the work is intentionally a browser-demo feature.

The earlier `godot/` directory is retained only as a map-and-asset prototype.

The workspace-local `godot-mcp-x` server is configured in `.mcp.json`; its
source and built Node server live under `.tools/godot-mcp-x/`. It is a local
development integration, not a required exported-game dependency. The release
project currently enables only the Dialogic editor plugin in `project.godot`.

## Native-scale visual capture

The universe visual-capture scenes require Godot's rendered viewport and must
use the isolated runner's `-Windowed` mode; headless smoke runs intentionally
fail a capture rather than reporting a false success. For example:

```powershell
.\tools\run_godot_isolated.ps1 -Scene validation/helios_visual_capture.tscn -Windowed -TimeoutSeconds 120
```

Inspect the resulting `game/validation/*.png` files at native scale after a
successful windowed capture.

## Performance baseline diagnostic

The rendered, machine-specific campaign timing probe records title-to-field,
current-area activation, battle entry/results/return, save/load, memory
snapshots, and 120 frame intervals. Run it windowed and retain the emitted JSON
line with the hardware specification; headless timings are not release evidence.

```powershell
.\tools\run_godot_isolated.ps1 -Scene validation/campaign_performance_baseline.tscn -Windowed -TimeoutSeconds 120
```

This is a reproducible diagnostic only. It does not replace the plan's required
minimum-hardware declaration, long-session memory measurement, or per-area
frame-pacing review.
