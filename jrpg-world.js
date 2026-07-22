(function () {
  "use strict";

  const TILE = 48;
  const VIEW_W = 960;
  const VIEW_H = 576;
  const keys = new Set();
  const images = new Map();
  let canvas = null;
  let ctx = null;
  let running = false;
  let frameHandle = 0;
  let lastTime = 0;
  let mapId = "town";
  let game = null;
  let callbacks = {};
  let path = [];
  let prompt = "";
  let playerHistory = [];
  let walkFrame = 0;
  let walkClock = 0;
  let facing = "south";
  const player = { x: 14 * TILE + TILE / 2, y: 11 * TILE + TILE / 2, radius: 14 };
  const pet = { x: player.x - 36, y: player.y + 28 };

  const MAPS = {
    town: { width: 32, height: 22, spawn: [14, 11], door: [14, 8], title: "New Philadelphia · Empty Town Plot" },
    laboratory: { width: 20, height: 12, spawn: [10, 9], door: [10, 10], title: "Franklin Laboratory" }
  };

  function asset(src) {
    const resolved = window.resolveAssetPath ? window.resolveAssetPath(src) : src;
    if (!images.has(resolved)) {
      const image = new Image();
      image.src = resolved;
      images.set(resolved, image);
    }
    return images.get(resolved);
  }

  function drawCrop(image, crop, destination) {
    if (!image.complete || !image.naturalWidth) return;
    ctx.drawImage(image, crop[0], crop[1], crop[2], crop[3], destination[0], destination[1], destination[2], destination[3]);
  }

  function collisionSet(id) {
    const blocked = new Set();
    const map = MAPS[id];
    const add = (x, y) => blocked.add(`${x},${y}`);
    for (let x = 0; x < map.width; x += 1) { add(x, 0); add(x, map.height - 1); }
    for (let y = 0; y < map.height; y += 1) { add(0, y); add(map.width - 1, y); }
    if (id === "laboratory") {
      for (let x = 0; x < map.width; x += 1) { add(x, 1); add(x, 2); }
      for (let x = 1; x <= 7; x += 1) { add(x, 4); add(x, 5); }
      for (let x = 11; x <= 18; x += 1) { add(x, 4); add(x, 5); }
      for (let x = 1; x <= 5; x += 1) add(x, 8);
      for (let x = 14; x <= 18; x += 1) add(x, 8);
      blocked.delete("10,10");
    } else {
      // The laboratory occupies a real 8x5 footprint in the otherwise empty hub.
      for (let y = 3; y <= 8; y += 1) for (let x = 10; x <= 18; x += 1) add(x, y);
      blocked.delete("14,8");
      for (const [x, y] of [[4,4],[5,4],[26,5],[27,5],[4,17],[25,16],[26,16]]) add(x, y);
    }
    return blocked;
  }

  function blockedAt(x, y) {
    const map = MAPS[mapId];
    const tx = Math.floor(x / TILE), ty = Math.floor(y / TILE);
    return tx < 0 || ty < 0 || tx >= map.width || ty >= map.height || collisionSet(mapId).has(`${tx},${ty}`);
  }

  function canStand(x, y) {
    const r = player.radius;
    return !blockedAt(x - r, y - r) && !blockedAt(x + r, y - r) && !blockedAt(x - r, y + r) && !blockedAt(x + r, y + r);
  }

  function tilePath(start, goal) {
    const map = MAPS[mapId];
    const blocked = collisionSet(mapId);
    const key = node => `${node[0]},${node[1]}`;
    if (blocked.has(key(goal))) return [];
    const queue = [start], came = new Map([[key(start), null]]);
    while (queue.length) {
      const current = queue.shift();
      if (key(current) === key(goal)) break;
      for (const next of [[current[0]+1,current[1]],[current[0]-1,current[1]],[current[0],current[1]+1],[current[0],current[1]-1]]) {
        const nextKey = key(next);
        if (next[0] < 0 || next[1] < 0 || next[0] >= map.width || next[1] >= map.height || blocked.has(nextKey) || came.has(nextKey)) continue;
        came.set(nextKey, current); queue.push(next);
      }
    }
    if (!came.has(key(goal))) return [];
    const result = [];
    for (let node = goal; node; node = came.get(key(node))) result.push({ x: node[0] * TILE + TILE / 2, y: node[1] * TILE + TILE / 2 });
    result.reverse(); result.shift(); return result;
  }

  function camera() {
    const map = MAPS[mapId];
    return {
      x: Math.max(0, Math.min(map.width * TILE - VIEW_W, player.x - VIEW_W / 2)),
      y: Math.max(0, Math.min(map.height * TILE - VIEW_H, player.y - VIEW_H / 2))
    };
  }

  function controllerVector() {
    let x = 0, y = 0;
    if (keys.has("arrowleft") || keys.has("a")) x -= 1;
    if (keys.has("arrowright") || keys.has("d")) x += 1;
    if (keys.has("arrowup") || keys.has("w")) y -= 1;
    if (keys.has("arrowdown") || keys.has("s")) y += 1;
    if (navigator.getGamepads) {
      for (const pad of navigator.getGamepads()) {
        if (!pad) continue;
        const ax = Math.abs(pad.axes[0] || 0) > .2 ? pad.axes[0] : 0;
        const ay = Math.abs(pad.axes[1] || 0) > .2 ? pad.axes[1] : 0;
        x += ax + (pad.buttons[15]?.pressed ? 1 : 0) - (pad.buttons[14]?.pressed ? 1 : 0);
        y += ay + (pad.buttons[13]?.pressed ? 1 : 0) - (pad.buttons[12]?.pressed ? 1 : 0);
      }
    }
    const length = Math.hypot(x, y);
    return length > 1 ? [x / length, y / length] : [x, y];
  }

  function update(delta) {
    if (callbacks.isPaused?.()) return;
    let [dx, dy] = controllerVector();
    if (dx || dy) path = [];
    if (!dx && !dy && path.length) {
      const target = path[0], vx = target.x - player.x, vy = target.y - player.y, distance = Math.hypot(vx, vy);
      if (distance < 5) { path.shift(); }
      else { dx = vx / distance; dy = vy / distance; }
    }
    const speed = 168;
    const nx = player.x + dx * speed * delta, ny = player.y + dy * speed * delta;
    if (canStand(nx, player.y)) player.x = nx;
    if (canStand(player.x, ny)) player.y = ny;
    if (dx || dy) {
      facing = Math.abs(dx) > Math.abs(dy) ? (dx > 0 ? "east" : "west") : (dy > 0 ? "south" : "north");
      walkClock += delta;
      walkFrame = Math.floor(walkClock * 10) % 6;
      playerHistory.unshift({ x: player.x, y: player.y, facing });
      playerHistory = playerHistory.slice(0, 90);
    }
    const follow = playerHistory[Math.min(30, playerHistory.length - 1)];
    if (follow) { pet.x += (follow.x - pet.x) * Math.min(1, delta * 8); pet.y += (follow.y - pet.y) * Math.min(1, delta * 8); }
    const door = MAPS[mapId].door;
    const nearDoor = Math.hypot(player.x - (door[0] * TILE + TILE / 2), player.y - (door[1] * TILE + TILE / 2)) < 70;
    prompt = nearDoor ? (mapId === "town" ? "E / A: Enter Franklin Laboratory" : "E / A: Exit to New Philadelphia") : "";
  }

  function drawGround(cameraPos) {
    const map = MAPS[mapId];
    if (mapId === "town") {
      const ground = asset("assets/Tilesets/Ranch Stuff/assets/tiles/ground_01_16x16.png");
      ctx.fillStyle = "#6d9c49"; ctx.fillRect(0, 0, VIEW_W, VIEW_H);
      for (let y = 0; y < map.height; y += 1) for (let x = 0; x < map.width; x += 1) {
        const road = (x >= 13 && x <= 15) || (y >= 9 && y <= 11);
        const crop = road ? [0, 192, 16, 16] : [0, 64, 16, 16];
        drawCrop(ground, crop, [x * TILE - cameraPos.x, y * TILE - cameraPos.y, TILE, TILE]);
      }
    } else {
      const atlas = asset("assets/Tilesets/Modern Laboratory Pixel Art Tileset Pack/1.png");
      for (let y = 0; y < map.height; y += 1) for (let x = 0; x < map.width; x += 1) {
        const crop = y <= 2 ? [192, 0, 48, 48] : [0, 0, 48, 48];
        drawCrop(atlas, crop, [x * TILE - cameraPos.x, y * TILE - cameraPos.y, TILE, TILE]);
      }
    }
  }

  function drawMapObjects(cameraPos) {
    if (mapId === "laboratory") {
      const utilities = asset("assets/Tilesets/Modern Laboratory Pixel Art Tileset Pack/2.png");
      const props = asset("assets/Tilesets/Modern Laboratory Pixel Art Tileset Pack/3.png");
      // Every object stays on the native 48 px grid and is never stretched.
      drawCrop(utilities, [192, 0, 192, 96], [TILE, TILE, 192, 96]);
      drawCrop(utilities, [384, 0, 384, 192], [11*TILE, 0, 384, 192]);
      drawCrop(props, [0, 192, 336, 96], [TILE, 4*TILE, 336, 96]);
      drawCrop(props, [384, 192, 384, 96], [11*TILE, 4*TILE, 384, 96]);
      drawCrop(props, [0, 384, 240, 96], [TILE, 8*TILE, 240, 96]);
      drawCrop(props, [528, 384, 240, 96], [14*TILE, 8*TILE, 240, 96]);
    } else {
      const lab = asset("assets/Tilesets/Modern Laboratory Pixel Art Tileset Pack/1.png");
      // Modular laboratory facade on its exact grid footprint.
      for (let y = 3; y <= 7; y += 1) for (let x = 10; x <= 18; x += 1) {
        const edge = y === 3 ? [192, 0, 48, 48] : [0, 0, 48, 48];
        drawCrop(lab, edge, [x*TILE-cameraPos.x,y*TILE-cameraPos.y,TILE,TILE]);
      }
      drawCrop(lab, [432, 288, 48, 96], [14*TILE-cameraPos.x,7*TILE-cameraPos.y,48,96]);
      const trees = asset("assets/Tilesets/Ranch Stuff/assets/tiles/tree_01_16x16.png");
      for (const [x,y,large] of [[4,4,false],[26,5,true],[4,17,true],[25,16,false]]) {
        const crop = large ? [32,0,48,64] : [0,0,32,48];
        drawCrop(trees,crop,[x*TILE-cameraPos.x-(large?24:0),y*TILE-cameraPos.y-(large?32:16),large?144:96,large?192:144]);
      }
    }
  }

  function drawActor(src, x, y, size, cameraPos) {
    const image = asset(src);
    if (!image.complete || !image.naturalWidth) return;
    ctx.drawImage(image, x - size/2 - cameraPos.x, y - size*.76 - cameraPos.y, size, size);
  }

  function render() {
    if (!ctx) return;
    const cam = camera();
    ctx.clearRect(0,0,VIEW_W,VIEW_H);
    ctx.imageSmoothingEnabled = false;
    drawGround(cam);
    drawMapObjects(cam);
    const petDirection = playerHistory[Math.min(30, playerHistory.length - 1)]?.facing || facing;
    drawActor(`assets/characters/Velociraptor/Tiny_Velociraptor/rotations/${petDirection}.png`, pet.x, pet.y, 58, cam);
    const moving = controllerVector().some(Boolean) || path.length;
    const playerSrc = moving
      ? `assets/characters/Main Character/Ben_Franklin/animations/Running/${facing}/frame_${String(walkFrame).padStart(3,"0")}.png`
      : `assets/characters/Main Character/Ben_Franklin/rotations/${facing}.png`;
    drawActor(playerSrc, player.x, player.y, 78, cam);
    ctx.fillStyle = "rgba(7,11,20,.82)"; ctx.fillRect(12,12,390,44);
    ctx.fillStyle = "#e9bb58"; ctx.font = "bold 14px system-ui"; ctx.fillText(MAPS[mapId].title,26,39);
    if (prompt) {
      ctx.font = "bold 14px system-ui";
      const width = ctx.measureText(prompt).width + 34;
      ctx.fillStyle = "rgba(7,11,20,.9)"; ctx.fillRect((VIEW_W-width)/2,VIEW_H-58,width,38);
      ctx.strokeStyle = "#e9bb58"; ctx.strokeRect((VIEW_W-width)/2,VIEW_H-58,width,38);
      ctx.fillStyle = "#fff"; ctx.fillText(prompt,(VIEW_W-width)/2+17,VIEW_H-34);
    }
  }

  function interact() {
    if (!prompt) return;
    mapId = mapId === "town" ? "laboratory" : "town";
    const spawn = MAPS[mapId].spawn;
    player.x = spawn[0]*TILE+TILE/2; player.y = spawn[1]*TILE+TILE/2;
    pet.x = player.x-36; pet.y=player.y+30; playerHistory=[]; path=[];
    if (game) game.location = mapId;
    callbacks.onTransition?.(mapId);
  }

  function loop(time) {
    if (!running) return;
    const delta = Math.min(.05, (time - lastTime) / 1000 || 0);
    lastTime = time;
    update(delta); render();
    frameHandle = requestAnimationFrame(loop);
  }

  function onPointer(event) {
    if (callbacks.isPaused?.()) return;
    const rect = canvas.getBoundingClientRect(), cam = camera();
    const x = (event.clientX-rect.left)/rect.width*VIEW_W+cam.x;
    const y = (event.clientY-rect.top)/rect.height*VIEW_H+cam.y;
    path = tilePath([Math.floor(player.x/TILE),Math.floor(player.y/TILE)],[Math.floor(x/TILE),Math.floor(y/TILE)]);
  }

  function start(target, options) {
    stop();
    canvas = target; ctx = canvas.getContext("2d"); canvas.width=VIEW_W; canvas.height=VIEW_H;
    game = options.game; callbacks = options;
    mapId = game.location === "laboratory" ? "laboratory" : "town";
    const spawn = MAPS[mapId].spawn;
    player.x=spawn[0]*TILE+TILE/2; player.y=spawn[1]*TILE+TILE/2; pet.x=player.x-36; pet.y=player.y+30;
    canvas.addEventListener("pointerdown",onPointer);
    running=true; lastTime=performance.now(); frameHandle=requestAnimationFrame(loop); canvas.focus();
  }

  function stop() {
    running=false; cancelAnimationFrame(frameHandle);
    if(canvas) canvas.removeEventListener("pointerdown",onPointer);
    canvas=null;ctx=null;
  }

  document.addEventListener("keydown", event => {
    if (!running) return;
    if (callbacks.isPaused?.()) return;
    keys.add(event.key.toLowerCase());
    if (["arrowup","arrowdown","arrowleft","arrowright"," "].includes(event.key.toLowerCase())) event.preventDefault();
    if (["e","enter"].includes(event.key.toLowerCase())) interact();
    if (["m","escape"].includes(event.key.toLowerCase())) callbacks.onMenu?.();
  });
  document.addEventListener("keyup", event => keys.delete(event.key.toLowerCase()));

  window.JRPGWorld = { start, stop, interact };
})();
