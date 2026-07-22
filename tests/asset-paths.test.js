"use strict";

const fs = require("fs");
const os = require("os");
const path = require("path");
const { execFileSync } = require("child_process");
const test = require("node:test");
const assert = require("node:assert/strict");
const { ASSET_PATH_PREFIXES, resolveAssetPath } = require("../asset-paths.js");

test("every declared legacy root resolves to its curated runtime root", () => {
  for (const [legacyRoot, runtimeRoot] of ASSET_PATH_PREFIXES) {
    const legacy = `${legacyRoot}fixture.png`;
    assert.equal(resolveAssetPath(legacy), `${runtimeRoot}fixture.png`, legacyRoot);
  }
  assert.equal(resolveAssetPath("assets/not-in-the-catalog/fixture.png"), "assets/not-in-the-catalog/fixture.png");
  assert.equal(resolveAssetPath(null), null);
});

test("NPC readiness validates aliases but still rejects genuinely missing assets", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "ben-npc-assets-"));
  const catalogPath = path.join(root, "catalog.js");
  const gamePath = path.join(root, "game.js");
  const alias = "assets/NPCs/example.png";
  const canonical = resolveAssetPath(alias);
  const npcEntries = Array.from({ length: 51 }, (_, index) => `npc${index}: { name: "NPC ${index}", sprite: { sheet: "${alias}", w: 16, h: 16 } }`);
  fs.writeFileSync(gamePath, `const NPCS = { ${npcEntries.join(",")} };`, "utf8");
  const writeCatalog = src => fs.writeFileSync(catalogPath, `window.CURATED_ART_ASSET_CATALOG = { sources: [{ id: "example", src: "${src}", variants: [{}] }] };`, "utf8");
  try {
    writeCatalog(canonical);
    const valid = execFileSync(process.execPath, ["tools/validate_npc_asset_readiness.js", "--root", root, "--catalog", "catalog.js", "--game", "game.js", "--json"], { cwd: path.resolve(__dirname, ".."), encoding: "utf8" });
    assert.equal(JSON.parse(valid).ok, true);

    writeCatalog("assets/characters/NPCs/missing.png");
    const invalid = execFileSync(process.execPath, ["tools/validate_npc_asset_readiness.js", "--root", root, "--catalog", "catalog.js", "--game", "game.js", "--json"], { cwd: path.resolve(__dirname, ".."), encoding: "utf8", stdio: ["ignore", "pipe", "ignore"] });
    assert.fail(`expected missing catalog source to fail, received: ${invalid}`);
  } catch (error) {
    if (error.status === 1 && error.stdout) {
      const result = JSON.parse(error.stdout);
      assert.equal(result.ok, false);
      assert.match(result.results[0].errors[0], /catalog source missing/);
    } else throw error;
  } finally {
    fs.rmSync(root, { recursive: true, force: true });
  }
});
