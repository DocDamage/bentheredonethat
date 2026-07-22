# Primary Godot project

Open [`game/project.godot`](game/project.godot) with the project-local Godot
4.7.1 executable, or run [`game/run_godot_4_7_1.cmd`](game/run_godot_4_7_1.cmd).

The earlier `godot/` directory is a retained map-and-asset prototype. New game
work belongs in `game/`, which is based on GDQuest OpenRPG.

The workspace-local `godot-mcp-x` server is configured in `.mcp.json`. Its
source and built Node server live under `.tools/godot-mcp-x/`; the matching
Godot 4.7 addon and runtime bridge are enabled in `game/project.godot`.
