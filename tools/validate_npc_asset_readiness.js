#!/usr/bin/env node
/* Validate that every runtime NPC has a deterministic, editor-ready visual. */

"use strict";

const fs = require("fs");
const path = require("path");
const vm = require("vm");

function parseArgs(argv) {
  const args = { root: path.resolve(__dirname, ".."), json: false };
  for (let index = 0; index < argv.length; index += 1) {
    const value = argv[index];
    if (value === "--json") args.json = true;
    else if (["--root", "--catalog", "--game"].includes(value)) {
      if (!argv[index + 1]) throw new Error(`${value} requires a path`);
      args[value.slice(2)] = argv[++index];
    } else if (value === "--help" || value === "-h") {
      console.log("Usage: node tools/validate_npc_asset_readiness.js [--root DIR] [--catalog FILE] [--game FILE] [--json]");
      process.exit(0);
    } else throw new Error(`unknown option: ${value}`);
  }
  args.root = path.resolve(args.root);
  args.catalog = path.resolve(args.root, args.catalog || "curated-asset-catalog.js");
  args.game = path.resolve(args.root, args.game || "game.js");
  return args;
}

function objectLiteralAfter(source, marker) {
  const markerAt = source.indexOf(marker);
  if (markerAt < 0) throw new Error(`could not find ${marker}`);
  const start = source.indexOf("{", markerAt + marker.length);
  if (start < 0) throw new Error(`could not find object after ${marker}`);
  let depth = 0;
  let quote = null;
  let escaped = false;
  let lineComment = false;
  let blockComment = false;
  for (let index = start; index < source.length; index += 1) {
    const char = source[index];
    const next = source[index + 1];
    if (lineComment) {
      if (char === "\n") lineComment = false;
      continue;
    }
    if (blockComment) {
      if (char === "*" && next === "/") { blockComment = false; index += 1; }
      continue;
    }
    if (quote) {
      if (escaped) escaped = false;
      else if (char === "\\") escaped = true;
      else if (char === quote) quote = null;
      continue;
    }
    if (char === "/" && next === "/") { lineComment = true; index += 1; continue; }
    if (char === "/" && next === "*") { blockComment = true; index += 1; continue; }
    if (char === "\"" || char === "'" || char === "`") { quote = char; continue; }
    if (char === "{") depth += 1;
    else if (char === "}") {
      depth -= 1;
      if (depth === 0) return source.slice(start, index + 1);
    }
  }
  throw new Error(`unterminated object after ${marker}`);
}

function loadNpcs(gamePath) {
  const source = fs.readFileSync(gamePath, "utf8");
  const literal = objectLiteralAfter(source, "const NPCS =");
  const npcs = vm.runInNewContext(`(${literal})`, Object.create(null), { timeout: 1000 });
  if (!npcs || typeof npcs !== "object" || Array.isArray(npcs)) throw new Error("NPCS is not an object");
  return npcs;
}

function loadCatalog(catalogPath) {
  const sandbox = { window: {} };
  vm.runInNewContext(fs.readFileSync(catalogPath, "utf8"), sandbox, { timeout: 5000 });
  const catalog = sandbox.window.CURATED_ART_ASSET_CATALOG;
  if (!catalog || !Array.isArray(catalog.sources)) throw new Error("catalog has no sources array");
  return catalog;
}

function rectOf(value) {
  if (!value || typeof value !== "object") return null;
  const values = [value.x, value.y, value.w, value.h].map(Number);
  return values.every(Number.isFinite) ? values : null;
}

function sameRect(left, right) {
  return left && right && left.length === 4 && left.every((value, index) => value === right[index]);
}

function sourceReady(source) {
  return Boolean(source && source.usable !== false && !source.review && !source.preview
    && Array.isArray(source.variants) && source.variants.some(variant => variant && variant.usable !== false));
}

function validateNpc(npcId, npc, indexes) {
  const errors = [];
  const sprite = npc && npc.sprite;
  const fail = message => errors.push(message);
  if (!sprite || typeof sprite !== "object") {
    fail("missing sprite definition");
    return { id: npcId, name: npc?.name || npcId, model: "missing", ready: false, errors };
  }

  const resolve = rawSource => {
    let source = indexes.byPath.get(rawSource);
    const visited = new Set();
    while (source && !sourceReady(source) && !visited.has(source.id)) {
      visited.add(source.id);
      const target = source.canonicalId || source.coveredBy;
      if (!target || Array.isArray(target)) break;
      source = indexes.byId.get(target) || source;
    }
    return source;
  };
  const ready = rawSource => {
    const source = resolve(rawSource);
    if (!source) fail(`catalog source missing: ${rawSource}`);
    else if (!sourceReady(source)) fail(`catalog source is not Ready: ${rawSource} (${source.reason || "no usable variant"})`);
    return source;
  };

  let model = "sheet";
  if (typeof sprite.directions === "string") {
    model = "direction-files";
    for (const direction of ["south", "west", "east", "north"]) {
      const rawSource = `${sprite.directions}${direction}.png`;
      const source = ready(rawSource);
      if (!sourceReady(source)) continue;
      const fullCanvas = source.variants.some(variant => sameRect(rectOf(variant), [0, 0, source.width, source.height]));
      if (!fullCanvas) fail(`${direction} has no exact full-canvas variant: ${rawSource}`);
    }
  } else if (typeof sprite.walkFrames === "string") {
    model = "direction-sequences";
    for (const direction of ["Back", "Front", "Right", "Left"]) {
      const rawSource = `${sprite.walkFrames}/${direction}/Standing/${direction}_Standing_Walk_1.png`;
      const source = ready(rawSource);
      const animation = source && (source.animation || source.variants?.find(variant => variant.animation)?.animation);
      if (!animation || !Array.isArray(animation.frames) || animation.frames.length < 3) {
        fail(`${direction} walk sequence needs at least three frames: ${rawSource}`);
      } else {
        for (const frame of animation.frames) {
          const frameSource = indexes.byPath.get(frame.src || rawSource);
          if (!frameSource || !sameRect(rectOf(frame), [0, 0, frameSource.width, frameSource.height])) {
            fail(`${direction} walk sequence contains a cropped or missing frame`);
            break;
          }
        }
      }
    }
  } else if (typeof sprite.sheet === "string") {
    const source = ready(sprite.sheet);
    if (sourceReady(source)) {
      const grid = source.grid;
      const frameWidth = Number(sprite.w || 0);
      const frameHeight = Number(sprite.h || 0);
      const originX = Number(sprite.x || 0);
      const originY = Number(sprite.y || 0);
      if (sprite.layout === "rpg") {
        model = "rpg-grid";
        if (!grid || grid.cellWidth !== frameWidth || grid.cellHeight !== frameHeight) {
          fail(`RPG grid must use exact ${frameWidth}x${frameHeight} cells`);
        } else if (originX % frameWidth || originY % frameHeight
          || originX + frameWidth * 3 > source.width || originY + frameHeight * 4 > source.height) {
          fail("RPG character origin is not aligned to a complete 3x4 block");
        } else {
          const sequences = Array.isArray(source.animations) ? source.animations : [];
          for (let direction = 0; direction < 4; direction += 1) {
            const expectedY = originY + direction * frameHeight;
            const validX = new Set([originX, originX + frameWidth, originX + frameWidth * 2]);
            const sequence = sequences.find(animation => Array.isArray(animation.frames)
              && animation.frames.length > 0
              && animation.frames.every(frame => frame.y === expectedY && validX.has(frame.x)
                && frame.w === frameWidth && frame.h === frameHeight));
            if (!sequence) fail(`RPG direction ${direction} has no exact animation sequence`);
          }
        }
      } else if (sprite.layout === "actionRows") {
        model = "action-rows";
        if (!grid || grid.cellWidth !== frameWidth || grid.cellHeight !== frameHeight
          || grid.columns < Number(sprite.walkFrames || 1) || grid.rows < 2) {
          fail(`action-row grid does not provide the required ${frameWidth}x${frameHeight} idle/walk rows`);
        }
        const sequences = Array.isArray(source.animations) ? source.animations : [];
        if (![0, 1].every(row => sequences.some(animation => animation.sequence === row && animation.frames?.length))) {
          fail("action-row source needs populated idle and walk sequences");
        }
      } else if (sprite.layout === "strip") {
        model = "strip";
        const frameCount = Number(sprite.frameCount || 1);
        if (!grid || grid.cellWidth !== frameWidth || grid.cellHeight !== frameHeight || grid.count < frameCount) {
          fail(`strip grid must provide ${frameCount} exact ${frameWidth}x${frameHeight} frames`);
        }
        const animation = source.variants.find(variant => variant.animation
          && variant.animation.frames?.length >= frameCount)?.animation;
        if (!animation) fail(`strip needs a usable ${frameCount}-frame animation variant`);
      } else if (sprite.layout === "directionRects") {
        model = "direction-rects";
        for (const direction of ["south", "west", "east", "north"]) {
          const expected = sprite.directionRects && sprite.directionRects[direction];
          if (!Array.isArray(expected) || !source.variants.some(variant => variant.usable !== false
            && sameRect(rectOf(variant), expected.map(Number)))) {
            fail(`${direction} direction rectangle is not an exact usable variant`);
          }
        }
      } else {
        model = grid ? "grid" : "standalone";
        if (grid && frameWidth && frameHeight
          && (grid.cellWidth !== frameWidth || grid.cellHeight !== frameHeight)) {
          fail(`grid cells do not match runtime frame ${frameWidth}x${frameHeight}`);
        }
      }
    }
  } else fail("sprite has no sheet, directions, or frame directory");

  return { id: npcId, name: npc.name || npcId, model, ready: errors.length === 0, errors };
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  const npcs = loadNpcs(args.game);
  const catalog = loadCatalog(args.catalog);
  const indexes = {
    byPath: new Map(catalog.sources.map(source => [source.src, source])),
    byId: new Map(catalog.sources.map(source => [source.id, source])),
  };
  const results = Object.entries(npcs).map(([npcId, npc]) => validateNpc(npcId, npc, indexes));
  const ready = results.filter(result => result.ready).length;
  const failed = results.length - ready;
  const summary = { ok: failed === 0 && results.length === 51, ready, total: results.length, failed, results };
  if (results.length !== 51) summary.rosterError = `expected 51 NPC definitions, found ${results.length}`;
  if (args.json) console.log(JSON.stringify(summary, null, 2));
  else {
    for (const result of results.filter(item => !item.ready)) {
      for (const error of result.errors) console.error(`ERROR [${result.id}] ${error}`);
    }
    if (summary.rosterError) console.error(`ERROR [roster] ${summary.rosterError}`);
    console.log(`${summary.ok ? "PASS" : "FAIL"}: ${ready}/${results.length} NPC visuals are editor-ready.`);
  }
  process.exitCode = summary.ok ? 0 : 1;
}

try { main(); }
catch (error) {
  console.error(`ERROR: ${error.message}`);
  process.exitCode = 2;
}
