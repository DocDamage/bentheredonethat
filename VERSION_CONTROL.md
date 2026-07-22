# Version-control policy

The `DocDamage/bentheredonethat` repository stores the runnable Godot project,
tests, manifests, documentation, and generated runtime assets. Runtime binary art
and audio under `game/game_assets/` use Git LFS.

The original supplied source-art library remains in the workspace-root `assets/`
directory and is deliberately ignored. It is large vendor/source material rather
than a runtime copy; `curated-asset-catalog.js`, `asset-manifest.js`, and the
pipeline configuration preserve its paths, hashes, crops, and provenance. A clean
checkout that needs to rebuild the catalog must provision that source library
separately.

Local machine configuration is not committed. Copy `.mcp.example.json` to
`.mcp.json` and replace `<workspace>` with the local workspace path.

Test and capture runs must use `tools/run_godot_isolated.ps1`; it places all
Godot user data and logs below the ignored `test-artifacts/` directory.
