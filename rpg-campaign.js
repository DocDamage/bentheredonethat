(function () {
  "use strict";

  const RPG = window.BenRPG;
  if (!RPG) return;

  const ui = {
    shell: document.getElementById("rpg-shell"),
    main: document.getElementById("rpg-main"),
    nav: document.getElementById("rpg-navigation"),
    partyList: document.getElementById("rpg-party-list"),
    companion: document.getElementById("rpg-companion-card"),
    chapter: document.getElementById("rpg-chapter"),
    location: document.getElementById("rpg-location"),
    duckets: document.getElementById("rpg-duckets"),
    partyCount: document.getElementById("rpg-party-count"),
    saveState: document.getElementById("rpg-autosave-state"),
    battle: document.getElementById("rpg-battle"),
    enemyLine: document.getElementById("rpg-enemy-line"),
    heroLine: document.getElementById("rpg-hero-line"),
    battleLog: document.getElementById("rpg-battle-log"),
    battleParty: document.getElementById("rpg-battle-party"),
    commandMenu: document.getElementById("rpg-command-menu"),
    battleBanner: document.getElementById("rpg-battle-banner"),
    battleBackground: document.getElementById("rpg-battle-background"),
    toast: document.getElementById("rpg-toast"),
    music: document.getElementById("music-player")
  };

  let game = null;
  let view = "world";
  let introStep = 0;
  let battle = null;
  let battleFrame = 0;
  let lastBattleAt = 0;
  let toastTimer = 0;
  let lastGamepadState = {};
  const sceneImageCache = new Map();

  const escapeHtml = value => String(value).replace(/[&<>"]/g, char => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[char]));
  const titleCase = value => String(value).replace(/([A-Z])/g, " $1").replace(/^./, char => char.toUpperCase());
  const costText = cost => Object.entries(cost || {}).map(([key, amount]) => `${amount} ${titleCase(key)}`).join(" · ") || "Built";

  function toast(message) {
    ui.toast.textContent = message;
    ui.toast.classList.remove("hidden");
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => ui.toast.classList.add("hidden"), 3200);
  }

  function intercept(button, handler) {
    if (!button) return;
    button.addEventListener("click", event => {
      event.preventDefault();
      event.stopImmediatePropagation();
      handler();
    }, true);
  }

  function begin(mode, shouldContinue) {
    game = shouldContinue ? RPG.loadGame(mode) : null;
    if (!game) game = RPG.createNewGame(mode);
    document.getElementById("start-screen").classList.add("hidden");
    document.getElementById("game-shell").classList.add("hidden");
    ui.shell.classList.remove("hidden");
    view = "world";
    introStep = 0;
    render();
    autosave("Campaign ready");
  }

  function returnToTitle() {
    if (game) RPG.saveGame(game);
    window.JRPGWorld?.stop();
    stopBattle();
    ui.shell.classList.add("hidden");
    document.getElementById("game-shell").classList.remove("hidden");
    document.getElementById("start-screen").classList.remove("hidden");
    updateContinueButton();
  }

  function updateContinueButton() {
    const button = document.getElementById("continue-button");
    const save = RPG.loadGame("campaign");
    if (!button) return;
    button.disabled = !save;
    button.hidden = false;
    button.classList.remove("hidden");
    button.textContent = save ? `Continue · ${save.chapter}` : "Continue Campaign";
  }

  function autosave(label) {
    if (!game) return;
    RPG.saveGame(game);
    ui.saveState.textContent = `${label || "Autosaved"} · ${new Date().toLocaleTimeString([], { hour: "numeric", minute: "2-digit" })}`;
  }

  function setView(nextView) {
    view = nextView;
    ui.shell.classList.toggle("world-active", view === "world");
    ui.nav.querySelectorAll("[data-rpg-view]").forEach(button => button.classList.toggle("active", button.dataset.rpgView === view));
    renderMain();
    ui.main.focus({ preventScroll: true });
  }

  function render() {
    ui.shell.classList.toggle("world-active", view === "world");
    ui.chapter.textContent = game.chapter;
    ui.location.textContent = game.location === "town" ? "New Philadelphia" : titleCase(game.location);
    ui.duckets.textContent = Number(game.duckets).toLocaleString();
    ui.partyCount.textContent = `${game.party.length}/${RPG.PARTY_LIMIT}`;
    renderPartyRail();
    renderMain();
  }

  function renderPartyRail() {
    const party = RPG.activeParty(game);
    ui.partyList.innerHTML = party.map(character => `
      <article class="rpg-party-member">
        <img src="${escapeHtml(character.assets.portrait)}" alt="">
        <div><b>${escapeHtml(character.name)}</b><small>Lv ${character.level} · ${escapeHtml(character.specialty)}<br>${character.hp}/${character.stats.hp} HP</small><div class="rpg-hpbar"><span style="width:${Math.round(character.hp / character.stats.hp * 100)}%"></span></div></div>
      </article>`).join("") + Array.from({ length: Math.max(0, RPG.PARTY_LIMIT - party.length) }, () => `
      <article class="rpg-party-member"><div style="width:44px;height:44px;display:grid;place-items:center;border:1px dashed #555;color:#777">+</div><div><b>Open hire slot</b><small>Recruit through a character mission</small></div></article>`).join("");
    const pet = game.roster[game.activeCompanion];
    ui.companion.innerHTML = pet ? `<span class="rpg-eyebrow">Autonomous companion</span><img src="${escapeHtml(pet.assets.portrait)}" alt=""><h3>${escapeHtml(pet.name)}</h3><p>Travels outside the five-person party. Frequently bites, counters, and intercepts attacks without waiting for a command.</p>` : "";
  }

  function heading(kicker, title, description, extra) {
    return `<header class="rpg-view-heading"><div><span>${escapeHtml(kicker)}</span><h1>${escapeHtml(title)}</h1></div><p>${escapeHtml(description)}</p>${extra || ""}</header>`;
  }

  function renderMain() {
    if (!game) return;
    if (view !== "world") window.JRPGWorld?.stop();
    const renderers = { world: renderWorld, town: renderTown, party: renderParty, facilities: renderFacilities, assignments: renderAssignments, inventory: renderInventory, quests: renderQuests, laboratory: renderLaboratory };
    ui.main.innerHTML = (renderers[view] || renderTown)();
    if (view === "world") requestAnimationFrame(startWorld);
    else requestAnimationFrame(composeVisibleScenes);
  }

  function renderWorld() {
    const intro = [
      { kicker: "Prologue", title: "A Fault in the Foundation", copy: "New Philadelphia was inexpensive for three reasons: no roads, no residents, and a geological report that used the phrase ‘probably local reality.’ Benjamin Franklin bought it anyway." },
      { kicker: "Franklin Laboratory · 6:44 AM", title: "The Anchor Moves", copy: "Ben’s laboratory appears exactly the same in every universe. This morning, an instrument that has never moved is pointing toward a building that does not exist yet." },
      { kicker: "Companion acquired · previously", title: "Tiny Velociraptor", copy: "The velociraptor is already Ben’s pet. It follows him freely, assists without consuming a party slot, and has interpreted the dimensional alarm as an invitation to bite something." },
      { kicker: "Main objective", title: "Build Somewhere Worth Returning To", copy: "Exit the laboratory. Survey the empty town plot. Build a café, library, and clinic; recruit four permanent hires; then anchor the mandatory first universe: the Haunted Mansion known as the House at 4:44." }
    ];
    const scene = intro[Math.min(introStep, intro.length - 1)];
    return `<section class="jrpg-playfield">
      <canvas id="jrpg-world-canvas" tabindex="0" aria-label="Top-down JRPG world. Move with WASD, arrows, click-to-move, or a controller."></canvas>
      <div class="jrpg-world-controls"><button type="button" data-world-menu>Menu</button><span>Move · <b>WASD / Stick / Click</b></span><span>Interact · <b>E / A</b></span></div>
      ${!game.introComplete ? `<div class="jrpg-intro" role="dialog" aria-modal="true"><div class="jrpg-intro-copy"><span>${escapeHtml(scene.kicker)}</span><h1>${escapeHtml(scene.title)}</h1><p>${escapeHtml(scene.copy)}</p><button class="rpg-button primary" data-intro-next>${introStep === intro.length - 1 ? "Take Control" : "Continue"}</button><small>${introStep + 1} / ${intro.length}</small></div></div>` : ""}
    </section>`;
  }

  function startWorld() {
    const canvas = document.getElementById("jrpg-world-canvas");
    if (!canvas || !window.JRPGWorld) return;
    window.JRPGWorld.start(canvas, {
      game,
      isPaused: () => !game.introComplete,
      onMenu: () => setView("party"),
      onTransition: location => { game.location = location; autosave("Map transition saved"); ui.location.textContent = location === "town" ? "New Philadelphia" : "Franklin Laboratory"; }
    });
  }

  function sceneImage(src) {
    const resolved = window.resolveAssetPath ? window.resolveAssetPath(src) : src;
    if (!sceneImageCache.has(resolved)) {
      const image = new Image();
      image.src = resolved;
      sceneImageCache.set(resolved, image);
    }
    return sceneImageCache.get(resolved);
  }

  function waitForImage(image) {
    if (image.complete && image.naturalWidth) return Promise.resolve(image);
    return new Promise((resolve, reject) => {
      image.addEventListener("load", () => resolve(image), { once: true });
      image.addEventListener("error", reject, { once: true });
    });
  }

  function drawCrop(ctx, image, crop, destination) {
    ctx.drawImage(image, crop[0], crop[1], crop[2], crop[3], destination[0], destination[1], destination[2], destination[3]);
  }

  async function composeVisibleScenes() {
    const canvases = [...ui.main.querySelectorAll("canvas[data-rpg-scene]")];
    for (const canvas of canvases) {
      if (canvas.dataset.rpgScene === "haunted-mansion-exterior") {
        await composeMansionExterior(canvas);
        continue;
      }
      const wallAtlas = sceneImage("assets/Tilesets/Modern Laboratory Pixel Art Tileset Pack/1.png");
      const utilityAtlas = sceneImage("assets/Tilesets/Modern Laboratory Pixel Art Tileset Pack/2.png");
      const propAtlas = sceneImage("assets/Tilesets/Modern Laboratory Pixel Art Tileset Pack/3.png");
      const ben = sceneImage(RPG.ASSETS.ben.portrait);
      const pet = sceneImage(RPG.ASSETS.raptor.portrait);
      try { await Promise.all([wallAtlas, utilityAtlas, propAtlas, ben, pet].map(waitForImage)); } catch (_) { continue; }
      if (!canvas.isConnected) continue;
      const ctx = canvas.getContext("2d");
      const width = canvas.width = 960;
      const height = canvas.height = 540;
      ctx.imageSmoothingEnabled = false;
      ctx.fillStyle = "#161d2a";
      ctx.fillRect(0, 0, width, height);

      // A composed room: repeated floor/wall tiles first, then individually cropped fixtures.
      for (let y = 144; y < height; y += 48) for (let x = 0; x < width; x += 48) {
        drawCrop(ctx, wallAtlas, [0, 0, 48, 48], [x, y, 48, 48]);
      }
      for (let y = 0; y < 144; y += 48) for (let x = 0; x < width; x += 96) {
        drawCrop(ctx, wallAtlas, [192, 0, 96, 96], [x, y, 96, 96]);
      }
      ctx.fillStyle = "rgba(12,19,30,.27)";
      ctx.fillRect(0, 0, width, 144);
      ctx.fillStyle = "#344557";
      ctx.fillRect(0, 138, width, 8);

      drawCrop(ctx, utilityAtlas, [192, 0, 192, 96], [38, 30, 192, 96]);
      drawCrop(ctx, utilityAtlas, [384, 0, 384, 192], [565, 7, 360, 180]);
      drawCrop(ctx, propAtlas, [144, 192, 240, 96], [42, 175, 300, 120]);
      drawCrop(ctx, propAtlas, [144, 288, 432, 96], [342, 176, 540, 120]);
      drawCrop(ctx, propAtlas, [0, 384, 144, 96], [40, 322, 180, 120]);
      drawCrop(ctx, propAtlas, [144, 384, 240, 96], [248, 322, 300, 120]);
      drawCrop(ctx, propAtlas, [384, 384, 192, 96], [566, 322, 240, 120]);
      drawCrop(ctx, propAtlas, [0, 528, 192, 96], [23, 423, 192, 96]);
      drawCrop(ctx, propAtlas, [384, 576, 384, 144], [490, 405, 384, 144]);

      ctx.fillStyle = "rgba(7,12,20,.5)";
      ctx.fillRect(0, height - 28, width, 28);
      ctx.fillStyle = "#e9bb58";
      ctx.font = "bold 13px system-ui";
      ctx.fillText("FRANKLIN LABORATORY · STABLE ANCHOR", 18, height - 10);

      drawCrop(ctx, ben, [0, 0, ben.naturalWidth, ben.naturalHeight], [824, 370, 88, 88]);
      drawCrop(ctx, pet, [0, 0, pet.naturalWidth, pet.naturalHeight], [775, 430, 68, 68]);
    }
  }

  async function composeMansionExterior(canvas) {
    const atlas = sceneImage("assets/Tilesets/Haunted Mansion Pixel Art Tileset Pack/1.png");
    try { await waitForImage(atlas); } catch (_) { return; }
    if (!canvas.isConnected) return;
    const ctx = canvas.getContext("2d");
    canvas.width = 960; canvas.height = 540; ctx.imageSmoothingEnabled = false;
    const sky = ctx.createLinearGradient(0, 0, 0, 540);
    sky.addColorStop(0, "#0a1024"); sky.addColorStop(.62, "#20233b"); sky.addColorStop(1, "#151a1f");
    ctx.fillStyle = sky; ctx.fillRect(0, 0, 960, 540);
    ctx.fillStyle = "rgba(224,230,210,.75)"; ctx.beginPath(); ctx.arc(800, 64, 38, 0, Math.PI * 2); ctx.fill();
    ctx.fillStyle = "rgba(18,21,30,.65)"; ctx.beginPath(); ctx.arc(815, 55, 38, 0, Math.PI * 2); ctx.fill();

    // Three facade crops, assembled into one house rather than displaying the atlas.
    drawCrop(ctx, atlas, [0, 0, 192, 160], [92, 88, 230, 192]);
    drawCrop(ctx, atlas, [192, 0, 192, 160], [322, 88, 230, 192]);
    drawCrop(ctx, atlas, [384, 0, 240, 160], [552, 88, 288, 192]);
    for (let x = 0; x < 960; x += 192) drawCrop(ctx, atlas, [192, 160, 192, 128], [x, 280, 192, 128]);
    drawCrop(ctx, atlas, [0, 288, 192, 96], [0, 376, 230, 115]);
    drawCrop(ctx, atlas, [192, 288, 192, 96], [230, 376, 230, 115]);
    drawCrop(ctx, atlas, [384, 288, 192, 96], [460, 376, 230, 115]);
    drawCrop(ctx, atlas, [576, 288, 192, 96], [690, 376, 230, 115]);
    drawCrop(ctx, atlas, [528, 384, 240, 192], [735, 250, 225, 180]);
    drawCrop(ctx, atlas, [0, 480, 192, 96], [35, 420, 230, 115]);
    drawCrop(ctx, atlas, [192, 576, 192, 144], [640, 398, 170, 128]);
    drawCrop(ctx, atlas, [384, 576, 192, 144], [780, 405, 170, 128]);
    ctx.fillStyle = "rgba(3,5,12,.45)"; ctx.fillRect(0, 0, 960, 540);
  }

  async function composeMansionInterior(canvas) {
    const atlas = sceneImage("assets/Tilesets/Haunted Mansion Pixel Art Tileset Pack/2.png");
    try { await waitForImage(atlas); } catch (_) { return; }
    if (!canvas.isConnected) return;
    const ctx = canvas.getContext("2d");
    canvas.width = 960; canvas.height = 540; ctx.imageSmoothingEnabled = false;
    ctx.fillStyle = "#19151a"; ctx.fillRect(0, 0, 960, 540);
    // Small texture crops are tiled into walls and floor; props are then placed separately.
    for (let y = 0; y < 190; y += 64) for (let x = 0; x < 960; x += 96) drawCrop(ctx, atlas, [250, 8, 96, 64], [x, y, 96, 64]);
    for (let y = 190; y < 540; y += 80) for (let x = 0; x < 960; x += 96) drawCrop(ctx, atlas, [210, 112, 96, 80], [x, y, 96, 80]);
    ctx.fillStyle = "#32252a"; ctx.fillRect(0, 180, 960, 12);
    drawCrop(ctx, atlas, [384, 112, 192, 96], [62, 92, 250, 125]);
    drawCrop(ctx, atlas, [576, 0, 96, 96], [440, 18, 115, 115]);
    drawCrop(ctx, atlas, [384, 256, 192, 160], [690, 118, 250, 208]);
    drawCrop(ctx, atlas, [576, 320, 96, 96], [575, 190, 105, 105]);
    drawCrop(ctx, atlas, [480, 416, 96, 96], [330, 310, 116, 116]);
    drawCrop(ctx, atlas, [424, 680, 208, 88], [345, 425, 300, 100]);
    drawCrop(ctx, atlas, [0, 480, 192, 96], [40, 350, 220, 110]);
    ctx.fillStyle = "rgba(8,5,12,.48)"; ctx.fillRect(0, 0, 960, 540);
  }

  function renderTown() {
    const mansionBuilt = Boolean(game.facilities.mansion);
    const ordinaryBuilt = ["cafe", "library", "clinic"].filter(id => game.facilities[id]).length;
    const partyReady = game.party.length >= RPG.PARTY_LIMIT;
    return `<section class="rpg-view">
      ${heading("Hub world · no hostile encounters", "A Town on the Fault Line", "New Philadelphia begins empty except for Ben's laboratory. Facilities duplicate safely; only a building deliberately anchored by Ben becomes a door to another universe.")}
      <div class="rpg-town-hero rpg-composed-scene">
        ${mansionBuilt ? `<canvas data-rpg-scene="haunted-mansion-exterior" aria-label="A mansion exterior composed from individual tiles and props"></canvas>` : `<canvas data-rpg-scene="laboratory" aria-label="A laboratory room composed from individual tiles and props"></canvas>`}
        <div class="rpg-town-copy">
          <span class="rpg-eyebrow">${mansionBuilt ? "First anchor established" : `${ordinaryBuilt}/3 civic facilities built`}</span>
          <h2>${mansionBuilt ? "The House at 4:44 is waiting." : "First, build somewhere worth coming home to."}</h2>
          <p>${mansionBuilt ? (partyReady ? "Ben's five-person party is ready to cross the threshold." : `Recruit ${RPG.PARTY_LIMIT - game.party.length} more permanent hires before the chapter's dangerous encounters begin.`) : "The Haunted Mansion is the mandatory first universe, but Ben will establish essential services and recruit a full party before anyone faces real danger."}</p>
          <div class="rpg-town-actions">
            <button class="rpg-button primary" data-rpg-action="${mansionBuilt ? "enter-mansion" : "open-facilities"}">${mansionBuilt ? "Approach the Mansion" : "Open Construction Catalog"}</button>
            <button class="rpg-button" data-rpg-view-jump="laboratory">Enter Laboratory</button>
          </div>
        </div>
      </div>
      <div class="rpg-card-grid" style="margin-top:12px">
        <article class="rpg-card"><span class="rpg-card-icon">⚗</span><span class="rpg-eyebrow">Persistent anchor</span><h3>Franklin Laboratory</h3><p>The lab follows Ben into every universe and handles inventions, skill-tree resets, saves, and combat simulations.</p></article>
        <article class="rpg-card"><span class="rpg-card-icon">♜</span><span class="rpg-eyebrow">Chapter one</span><h3>The House at 4:44</h3><p>A foyer, forbidden library, cellar, courtyard, persistent shortcuts, scripted boss, and the first fault-line clues.</p></article>
      </div>
    </section>`;
  }

  function renderFacilities() {
    const order = ["laboratory", "cafe", "library", "clinic", "mansion"];
    return `<section class="rpg-view">
      ${heading("Construction catalog", "Facilities & Universe Anchors", "Each blueprint is a building first. Ben chooses whether it remains a town facility or anchors a universe; duplicates can only operate as normal facilities.", `<div class="rpg-materials">${Object.entries(game.materials).map(([key,value]) => `<span>${titleCase(key)} ${value}</span>`).join("")}</div>`)}
      <div class="rpg-card-grid">${order.map(id => {
        const def = RPG.FACILITIES[id];
        const built = Boolean(game.facilities[id]);
        const locked = id === "mansion" && !["cafe","library","clinic"].every(key => game.facilities[key]);
        return `<article class="rpg-card ${built ? "is-built" : ""} ${locked ? "is-locked" : ""}"><span class="rpg-card-icon">${def.icon}</span><span class="rpg-eyebrow">${def.townOnly ? "Town facility" : "Universe anchor"}</span><h2>${escapeHtml(def.name)}</h2><p>${escapeHtml(def.description)}</p><span class="rpg-cost">${built ? `Level ${game.facilities[id].level} · constructed` : costText(def.cost)}</span>${built ? `<button class="rpg-button" disabled>Built</button>` : `<button class="rpg-button ${locked ? "" : "primary"}" data-build-facility="${id}" ${locked ? "disabled" : ""}>${locked ? "Requires civic facilities" : "Construct"}</button>`}</article>`;
      }).join("")}</div>
    </section>`;
  }

  function renderParty() {
    const roster = Object.values(game.roster).filter(character => character.kind !== "companion");
    return `<section class="rpg-view">
      ${heading("Ben + four hires", "Party & Recruit Roster", "Permanent and temporary characters have fixed specialties, can train adjacent skills, and must choose between adventuring and staffing a facility.")}
      <div class="rpg-list">${roster.map(character => `<article class="rpg-list-row"><div><span class="rpg-tag">${escapeHtml(character.specialty)}</span><h3>${escapeHtml(character.name)}</h3></div><p>Level ${character.level} · ${character.stats.hp} HP · ${character.learnedAbilities.join(", ")}</p><b>${game.party.includes(character.id) ? "Active" : "Reserve"}</b></article>`).join("")}</div>
      <h2 style="margin-top:24px">Recruitable asset packs</h2>
      <p style="color:var(--rpg-muted);font:13px/1.5 system-ui,sans-serif">Artwork is discovered only from <code>assets/characters/Recruitable Characters</code>. Packs remain unintroduced until their story role is defined.</p>
      <div class="rpg-card-grid">${game.recruitPacks.map(pack => `<article class="rpg-card"><span class="rpg-tag">${escapeHtml(pack.status)}</span><h3>${escapeHtml(pack.name)}</h3><p>${pack.specialty ? `Validated specialty: ${pack.specialty}. Full eight-direction and combat animations detected.` : "Visual pack registered. Identity, specialty, and recruitment mission intentionally unassigned."}</p></article>`).join("")}</div>
    </section>`;
  }

  function renderAssignments() {
    const openHires = Object.values(game.roster).filter(character => !["protagonist", "companion"].includes(character.kind) && !character.assignedTo);
    return `<section class="rpg-view">
      ${heading("Offline progress · 36 hour cap", "Assignments", "Send a hire to run a facility, farm, investigate, craft, or perform a chore. Specialties improve completion speed and reward quality; assignments never fail.")}
      ${openHires.length ? `<div class="rpg-list">${openHires.map(character => `<article class="rpg-list-row"><h3>${escapeHtml(character.name)}</h3><p>Available for a facility task.</p><button class="rpg-button">Assign</button></article>`).join("")}</div>` : `<div class="rpg-empty"><div><h2>No hire is available yet.</h2><p>Ben and the velociraptor cannot fill ordinary staffing slots.<br>Recruitable characters will unlock through their own missions.</p></div></div>`}
    </section>`;
  }

  function renderInventory() {
    return `<section class="rpg-view">
      ${heading("Unlimited capacity", "Inventory & Equipment", "Loot supports rarity tiers, visible randomized modifiers, fixed legendary items, and equipment abilities that can be learned permanently through proficiency.")}
      <div class="rpg-card-grid">
        <article class="rpg-card"><span class="rpg-eyebrow">Consumables</span><h2>${Object.values(game.inventory).reduce((a,b)=>a+b,0)} items</h2>${Object.entries(game.inventory).map(([id,count]) => `<p><b>${titleCase(id)}</b> × ${count}</p>`).join("") || "<p>Empty</p>"}</article>
        <article class="rpg-card"><span class="rpg-eyebrow">Equipment</span><h2>${game.equipmentInventory.length} pieces</h2><p>Slots: weapon, armor, headgear, and two accessories. Weapons are specialty-locked, while equipment abilities allow unusual cross-role builds.</p></article>
        <article class="rpg-card"><span class="rpg-eyebrow">Universal currency</span><h2>${game.duckets.toLocaleString()} Duckets</h2><p>A stable denomination minted from harmless slivers of dimensional anchor glass. Enemies drop it directly.</p></article>
      </div>
    </section>`;
  }

  function renderQuests() {
    return `<section class="rpg-view">
      ${heading("Information reveals opportunity", "Quest Journal", "Jobs and hidden quests become visible after Ben finds the relevant loot, defeats an enemy, or discovers a place containing the needed information.")}
      <div class="rpg-list">${game.quests.filter(quest => quest.state !== "hidden").map(quest => `<article class="rpg-list-row"><div><span class="rpg-tag">${escapeHtml(quest.type)}</span><h3>${escapeHtml(quest.title)}</h3></div><p>${escapeHtml(quest.description)}</p><b>${titleCase(quest.state)}</b></article>`).join("")}</div>
    </section>`;
  }

  function renderLaboratory() {
    return `<section class="rpg-view">
      ${heading("The same room in every universe", "Franklin Laboratory", "Reset skill trees freely, invent traversal tools, manage saves, and test active-time combat without risking campaign progress.")}
      <div class="rpg-town-hero rpg-composed-scene"><canvas data-rpg-scene="laboratory" aria-label="A laboratory room composed from individual tiles and props"></canvas><div class="rpg-town-copy"><span class="rpg-eyebrow">Combat simulator</span><h2>Calibrate the Autonomous Raptor Protocol</h2><p>The velociraptor acts independently outside the five-person party: a faster assist gauge, frequent bites, a chance to intercept attacks, and protective counterattacks.</p><div class="rpg-town-actions"><button class="rpg-button primary" data-rpg-action="training-battle">Run ATB Simulation</button><button class="rpg-button" data-rpg-action="reset-skills">Reset Skill Trees</button></div></div></div>
      <div class="rpg-card-grid" style="margin-top:12px"><article class="rpg-card"><span class="rpg-eyebrow">Known invention</span><h3>Portable Laboratory Anchor</h3><p>Explains why the lab occupies the same stable room in every universe.</p></article><article class="rpg-card"><span class="rpg-eyebrow">Future invention</span><h3>Return Beacon</h3><p>Return to town at any time unless a scenario deliberately disrupts the signal.</p></article></div>
    </section>`;
  }

  function buildFacility(id) {
    const result = RPG.buildFacility(game, id);
    toast(result.ok ? `${result.facility.name} constructed.` : result.reason);
    if (result.ok) autosave("Construction autosaved");
    render();
  }

  function enterMansion() {
    if (!game.facilities.mansion) return toast("The Haunted Mansion anchor has not been constructed.");
    if (game.party.length < RPG.PARTY_LIMIT && game.mode !== "sandbox") return toast(`Ben needs ${RPG.PARTY_LIMIT - game.party.length} more permanent hires before dangerous encounters begin.`);
    game.location = "haunted-mansion";
    game.chapter = "Chapter I: The House at 4:44";
    startBattle(["denture", "portrait"]);
  }

  function startBattle(enemyIds) {
    battle = RPG.createBattle(game, enemyIds);
    ui.battle.classList.remove("hidden");
    requestAnimationFrame(() => composeMansionInterior(ui.battleBackground));
    ui.battleBanner.textContent = enemyIds.includes("grudge") ? "BOSS" : "ENCOUNTER";
    playMusic(enemyIds.includes("grudge") ? RPG.ASSETS.music.boss : RPG.ASSETS.music.battle);
    renderBattle();
    lastBattleAt = performance.now();
    cancelAnimationFrame(battleFrame);
    battleFrame = requestAnimationFrame(battleLoop);
  }

  function playMusic(src) {
    if (!ui.music || !src) return;
    const source = ui.music.querySelector("source");
    if (source && !source.src.endsWith(encodeURI(src))) {
      source.src = src;
      ui.music.load();
    }
    ui.music.play().catch(() => {});
  }

  function battleLoop(timestamp) {
    if (!battle || battle.state !== "running") return renderBattle();
    const delta = timestamp - lastBattleAt;
    lastBattleAt = timestamp;
    RPG.tickBattle(battle, delta * game.settings.battleSpeed, game.settings.activeWait === "wait");
    renderBattle();
    if (game.settings.activeWait === "wait" && battle.ready.some(id => battle.heroes.some(hero => hero.id === id))) {
      battleFrame = 0;
      return;
    }
    battleFrame = requestAnimationFrame(battleLoop);
  }

  function renderBattle() {
    if (!battle) return;
    ui.enemyLine.innerHTML = battle.enemies.map(enemy => `<article class="rpg-battler enemy ${enemy.hp <= 0 ? "ko" : ""}"><img src="${escapeHtml(enemy.sprite)}" alt=""><span class="rpg-battler-label">${escapeHtml(enemy.name)} · ${enemy.hp}/${enemy.maxHp}</span></article>`).join("");
    ui.heroLine.innerHTML = battle.heroes.map(hero => `<article class="rpg-battler hero ${hero.hp <= 0 ? "ko" : ""}"><img src="${escapeHtml(hero.assets.battleIdle)}" alt=""><span class="rpg-battler-label">${escapeHtml(hero.name)}</span></article>`).join("") + (battle.companions || []).map(pet => `<article class="rpg-battler companion"><img src="${escapeHtml(pet.assets.battleIdle)}" alt=""><span class="rpg-battler-label">AUTO</span></article>`).join("");
    ui.battleLog.innerHTML = battle.log.map(line => `<p>${escapeHtml(line)}</p>`).join("");
    ui.battleParty.innerHTML = battle.heroes.map(hero => `<div class="rpg-battle-member"><b>${escapeHtml(hero.name)}</b><span>${hero.hp}/${hero.stats.hp} HP</span><div class="rpg-atb"><span style="width:${hero.atb}%"></span></div></div>`).join("") + (battle.companions || []).map(pet => `<div class="rpg-battle-member"><b>${escapeHtml(pet.name)} <small>AUTO</small></b><span>Assist</span><div class="rpg-atb"><span style="width:${pet.atb}%"></span></div></div>`).join("");
    const readyHero = battle.heroes.find(hero => battle.ready.includes(hero.id));
    if (battle.state === "running" && readyHero) {
      ui.commandMenu.innerHTML = `<b class="rpg-command-title">${escapeHtml(readyHero.name)} is ready</b>${["attack","skill","item","defend","equipment","escape"].map(command => `<button data-battle-command="${command}" data-hero="${readyHero.id}">${titleCase(command)}</button>`).join("")}`;
    } else if (battle.state === "victory") {
      ui.commandMenu.innerHTML = `<b class="rpg-command-title">Victory</b><button class="rpg-button primary" data-battle-finish="victory">Take rewards</button>`;
    } else if (battle.state === "defeat") {
      ui.commandMenu.innerHTML = `<b class="rpg-command-title">Game over</b><button data-battle-finish="town">Return to town</button><button data-battle-finish="save">Last save point</button>`;
    } else if (battle.state === "escaped") {
      ui.commandMenu.innerHTML = `<b class="rpg-command-title">Escaped</b><button data-battle-finish="escaped">Return</button>`;
    } else {
      ui.commandMenu.innerHTML = `<b class="rpg-command-title">Active Time Battle</b><span style="grid-column:1/-1;color:#aeb7ca;font:12px/1.4 system-ui,sans-serif">Gauges fill according to Speed. The velociraptor acts independently.</span>`;
    }
  }

  function battleCommand(button) {
    const command = button.dataset.battleCommand;
    if (command === "equipment") return toast("Equipment can be changed without consuming this turn.");
    if (command === "item") return toast("Item targeting is reserved for the inventory implementation; the turn is preserved.");
    const target = battle.enemies.find(enemy => enemy.hp > 0);
    const result = RPG.heroCommand(battle, button.dataset.hero, command, target && target.id);
    if (!result.ok && result.reason) toast(result.reason);
    renderBattle();
    if (result.ok && battle.state === "running" && !battleFrame) {
      lastBattleAt = performance.now();
      battleFrame = requestAnimationFrame(battleLoop);
    }
  }

  function finishBattle(outcome) {
    if (outcome === "victory") {
      RPG.grantBattleRewards(game, battle);
      toast(`Recovered ${battle.rewards.exp} EXP and ${battle.rewards.duckets} Duckets.`);
    } else if (outcome === "town" || outcome === "save") {
      for (const character of Object.values(game.roster)) character.hp = Math.max(1, character.hp);
      game.location = outcome === "town" ? "town" : game.autosave.location;
    }
    stopBattle();
    game.location = "town";
    playMusic("");
    autosave("Battle result autosaved");
    render();
  }

  function stopBattle() {
    cancelAnimationFrame(battleFrame);
    battleFrame = 0;
    battle = null;
    ui.battle.classList.add("hidden");
  }

  function resetSkills() {
    for (const character of Object.values(game.roster)) character.abilityProficiency = {};
    toast("Skill trees reset. Learned equipment abilities remain available.");
    autosave("Skill reset saved");
  }

  ui.nav.addEventListener("click", event => {
    const button = event.target.closest("[data-rpg-view]");
    if (button) setView(button.dataset.rpgView);
  });

  ui.main.addEventListener("click", event => {
    const intro = event.target.closest("[data-intro-next]");
    if (intro) {
      if (introStep < 3) { introStep += 1; renderMain(); }
      else { game.introComplete = true; autosave("Prologue complete"); renderMain(); toast("Use WASD, the left stick, or click the floor to move. Walk to the south door and press E or A."); }
      return;
    }
    if (event.target.closest("[data-world-menu]")) return setView("party");
    const build = event.target.closest("[data-build-facility]");
    if (build) return buildFacility(build.dataset.buildFacility);
    const jump = event.target.closest("[data-rpg-view-jump]");
    if (jump) return setView(jump.dataset.rpgViewJump);
    const action = event.target.closest("[data-rpg-action]");
    if (!action) return;
    if (action.dataset.rpgAction === "open-facilities") setView("facilities");
    if (action.dataset.rpgAction === "enter-mansion") enterMansion();
    if (action.dataset.rpgAction === "training-battle") startBattle(["denture"]);
    if (action.dataset.rpgAction === "reset-skills") resetSkills();
  });

  ui.commandMenu.addEventListener("click", event => {
    const command = event.target.closest("[data-battle-command]");
    if (command) return battleCommand(command);
    const finish = event.target.closest("[data-battle-finish]");
    if (finish) finishBattle(finish.dataset.battleFinish);
  });

  document.getElementById("rpg-save-button").addEventListener("click", () => { autosave("Manual save"); toast("Campaign saved."); });
  document.getElementById("rpg-title-button").addEventListener("click", returnToTitle);
  intercept(document.getElementById("new-game-button"), () => begin("campaign", false));
  intercept(document.getElementById("continue-button"), () => begin("campaign", true));
  intercept(document.getElementById("rpg-sandbox-button"), () => begin("sandbox", Boolean(RPG.loadGame("sandbox"))));

  document.addEventListener("keydown", event => {
    if (!game) return;
    if (event.key === "Escape" && battle && battle.state !== "running") finishBattle(battle.state);
  });

  function gamepadPressed(gamepad, index) {
    const key = `${gamepad.index}:${index}`;
    const pressed = Boolean(gamepad.buttons[index] && gamepad.buttons[index].pressed);
    const edge = pressed && !lastGamepadState[key];
    lastGamepadState[key] = pressed;
    return edge;
  }

  function pollGamepads() {
    if (game && view !== "world" && navigator.getGamepads) {
      for (const pad of navigator.getGamepads()) {
        if (!pad) continue;
        const focusables = [...document.querySelectorAll(`${battle ? "#rpg-battle" : "#rpg-shell"} button:not(:disabled)`)].filter(node => node.offsetParent !== null);
        const current = Math.max(0, focusables.indexOf(document.activeElement));
        const vertical = gamepadPressed(pad, 12) || gamepadPressed(pad, 14) || (pad.axes[1] < -.65 && !lastGamepadState[`${pad.index}:axis-y`]);
        const forward = gamepadPressed(pad, 13) || gamepadPressed(pad, 15) || (pad.axes[1] > .65 && !lastGamepadState[`${pad.index}:axis+y`]);
        lastGamepadState[`${pad.index}:axis-y`] = pad.axes[1] < -.65;
        lastGamepadState[`${pad.index}:axis+y`] = pad.axes[1] > .65;
        if (vertical && focusables.length) focusables[(current - 1 + focusables.length) % focusables.length].focus();
        if (forward && focusables.length) focusables[(current + 1) % focusables.length].focus();
        if (gamepadPressed(pad, 0) && focusables.length) focusables[current].click();
        if (gamepadPressed(pad, 1) && battle && battle.state !== "running") finishBattle(battle.state);
      }
    }
    requestAnimationFrame(pollGamepads);
  }

  updateContinueButton();
  requestAnimationFrame(pollGamepads);
})();
