// Compatibility entry point for the curated asset pipeline.
// Prefer: python tools/build_curated_asset_catalog.py
const path = require("path");
const { spawnSync } = require("child_process");

const root = __dirname;
const python = process.env.PYTHON || "python";
const script = path.join(root, "tools", "build_curated_asset_catalog.py");
const result = spawnSync(python, [script, ...process.argv.slice(2)], {
  cwd: root,
  stdio: "inherit",
});

if (result.error) {
  console.error(`Could not start ${python}: ${result.error.message}`);
  process.exitCode = 1;
} else {
  process.exitCode = result.status ?? 1;
}
