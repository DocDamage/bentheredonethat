(function (root, factory) {
  const api = factory();
  if (typeof module === "object" && module.exports) module.exports = api;
  root.BenRPG = api;
})(typeof globalThis !== "undefined" ? globalThis : window, function () {
  "use strict";

  const SAVE_VERSION = 1;
  const CAMPAIGN_KEY = "ben-there-rpg-campaign-v1";
  const SANDBOX_KEY = "ben-there-rpg-sandbox-v1";
  const MAX_LEVEL = 50;
  const PARTY_LIMIT = 5;
  const OFFLINE_CAP_MS = 36 * 60 * 60 * 1000;

  const SPECIALTIES = ["Fighter", "Medic", "Arcanist", "Rogue", "Engineer", "Support"];
  const ELEMENTS = ["Fire", "Ice", "Lightning", "Water", "Earth", "Wind", "Light", "Dark"];
  const STATUSES = ["poison", "burn", "freeze", "shock", "sleep", "silence", "blind", "confusion", "slow", "haste", "stun", "regeneration"];

  const ASSETS = Object.freeze({
    ben: {
      portrait: "assets/characters/Main Character/Ben_Franklin/rotations/south.png",
      battleIdle: "assets/characters/Main Character/Ben_Franklin/animations/Fight_Stance_Idle/west/frame_000.png",
      attack: "assets/characters/Main Character/Ben_Franklin/animations/Lead_Jab/west/frame_000.png"
    },
    raptor: {
      portrait: "assets/characters/Velociraptor/Tiny_Velociraptor/rotations/west.png",
      battleIdle: "assets/characters/Velociraptor/Tiny_Velociraptor/animations/Breathing_Idle/west/frame_000.png",
      attack: "assets/characters/Velociraptor/Tiny_Velociraptor/animations/Bite_Attack/west/frame_006.png"
    },
    laboratory: "assets/Tilesets/Modern Laboratory Pixel Art Tileset Pack/3.png",
    mansion: "assets/Tilesets/Haunted Mansion Pixel Art Tileset Pack/2.png",
    mansionExterior: "assets/Tilesets/Haunted Mansion Pixel Art Tileset Pack/1.png",
    music: {
      mansion: "assets/Music/Crimson Nocturne — Vampire Gothic Fantasy Soundtrack Pack/5. HAUNTED HALLWAY — “Whispers in Velvet”.mp3",
      battle: "assets/Music/Crimson Nocturne — Vampire Gothic Fantasy Soundtrack Pack/11. BATTLE THEME — “Dance of the Crimson Blades”.mp3",
      boss: "assets/Music/Crimson Nocturne — Vampire Gothic Fantasy Soundtrack Pack/15. FINAL BOSS — “The Eternal Queen”.mp3"
    }
  });

  const RECRUIT_PACKS = Object.freeze([
    "💀 The Frost Lich King Emperor",
    "Archangel Commander — Legendary Celestial Warrior Hero",
    "astronaut",
    "caveman",
    "crimson oni samurai",
    "kitsune empress",
    "neon viper - cyberpunk female",
    "Fighter"
  ]);

  const FACILITIES = Object.freeze({
    laboratory: { id: "laboratory", name: "Franklin Laboratory", icon: "⚗", built: true, townOnly: true, description: "Ben's trans-universal workshop, identical wherever it appears." },
    cafe: { id: "cafe", name: "Civic Café", icon: "☕", cost: { timber: 8, stone: 4 }, townOnly: true, description: "Restores the party and produces provisions when staffed." },
    library: { id: "library", name: "Public Library", icon: "▤", cost: { timber: 6, stone: 6 }, townOnly: true, description: "Reveals jobs and puzzle information gathered across universes." },
    clinic: { id: "clinic", name: "Field Clinic", icon: "✚", cost: { timber: 4, metal: 4 }, townOnly: true, description: "Treats status effects and produces recovery items." },
    mansion: { id: "mansion", name: "Haunted Mansion Anchor", icon: "♜", cost: { timber: 10, stone: 10, anchorGlass: 1 }, townOnly: false, universe: "haunted-mansion", description: "A building-sized door into the universe of the House at 4:44." }
  });

  const ENEMIES = Object.freeze({
    denture: { id: "denture", name: "Denture Monster", level: 2, hp: 72, speed: 34, strength: 13, defense: 7, exp: 18, duckets: 7, weakness: "Lightning", sprite: "assets/monsters/cp45-f91_horror_and_nightmares/CP_F120_DentureMonster.png" },
    portrait: { id: "portrait", name: "Haunted Composer Portrait", level: 3, hp: 96, speed: 28, strength: 15, defense: 9, exp: 25, duckets: 10, weakness: "Light", sprite: "assets/monsters/cp45-f91_horror_and_nightmares/CP_F095_HauntedComposerPortrait.png" },
    warbook: { id: "warbook", name: "War Book Ghost", level: 3, hp: 88, speed: 42, strength: 14, defense: 8, exp: 24, duckets: 9, weakness: "Fire", sprite: "assets/monsters/cp45-f91_horror_and_nightmares/CP_F098_WarBookGhost.png" },
    grudge: { id: "grudge", name: "The Grudge Woman", level: 7, hp: 620, speed: 48, strength: 24, defense: 14, exp: 240, duckets: 75, weakness: "Light", boss: true, sprite: "assets/monsters/cp45-f91_horror_and_nightmares/CP_F106_GrudgeWoman.png" }
  });

  function clone(value) { return JSON.parse(JSON.stringify(value)); }
  function clamp(value, min, max) { return Math.max(min, Math.min(max, value)); }
  function xpForLevel(level) { return Math.floor(40 * Math.pow(Math.max(1, level), 1.65)); }
  function now() { return Date.now(); }

  function makeCharacter(def) {
    return {
      id: def.id,
      name: def.name,
      kind: def.kind || "recruit",
      specialty: def.specialty,
      adjacentSkills: def.adjacentSkills || [],
      level: def.level || 1,
      exp: def.exp || 0,
      hp: def.stats.hp,
      mp: def.stats.mp,
      stats: clone(def.stats),
      equipment: { weapon: null, armor: null, headgear: null, accessory1: null, accessory2: null },
      learnedAbilities: def.learnedAbilities || [],
      abilityProficiency: {},
      statuses: [],
      limit: 0,
      atb: 0,
      assets: clone(def.assets),
      assignedTo: null,
      permanent: def.permanent !== false
    };
  }

  function makeBen() {
    return makeCharacter({
      id: "ben", name: "Benjamin Franklin", kind: "protagonist", specialty: "Support",
      adjacentSkills: ["Engineer"], learnedAbilities: ["Static Advice", "Field Experiment"],
      stats: { hp: 125, mp: 52, strength: 12, defense: 11, magic: 16, resistance: 15, speed: 12, accuracy: 94, evasion: 5, luck: 16 },
      assets: ASSETS.ben
    });
  }

  function makeRaptor() {
    return makeCharacter({
      id: "tiny-velociraptor", name: "Tiny Velociraptor", kind: "companion", specialty: "Fighter",
      adjacentSkills: ["Rogue"], learnedAbilities: ["Bite", "Scratch", "Clever Girl"],
      stats: { hp: 108, mp: 18, strength: 17, defense: 9, magic: 5, resistance: 8, speed: 18, accuracy: 96, evasion: 12, luck: 11 },
      assets: ASSETS.raptor
    });
  }

  function createNewGame(mode) {
    const sandbox = mode === "sandbox";
    const game = {
      version: SAVE_VERSION,
      mode: sandbox ? "sandbox" : "campaign",
      createdAt: now(),
      savedAt: now(),
      lastOnlineAt: now(),
      playTimeMs: 0,
      chapter: sandbox ? "Sandbox" : "Prologue: A Fault in the Foundation",
      phase: sandbox ? "free" : "build-town",
      location: sandbox ? "town" : "laboratory",
      introComplete: sandbox,
      duckets: sandbox ? 999999 : 50,
      materials: sandbox ? { timber: 999, stone: 999, metal: 999, anchorGlass: 99 } : { timber: 28, stone: 24, metal: 12, anchorGlass: 1 },
      facilities: { laboratory: { level: 1, staff: [], queue: [], builtAt: now() } },
      universes: { "haunted-mansion": { anchored: sandbox, discovered: sandbox, progress: sandbox ? 100 : 0, chests: [], bosses: [], shortcuts: [], savePoints: [] } },
      party: ["ben"],
      activeCompanion: "tiny-velociraptor",
      roster: { ben: makeBen(), "tiny-velociraptor": makeRaptor() },
      recruitPacks: RECRUIT_PACKS.map(name => ({
        name,
        status: name === "Fighter" ? "defined" : (sandbox ? "available" : "unintroduced"),
        specialty: name === "Fighter" ? "Fighter" : null,
        source: `assets/characters/Recruitable Characters/${name}`
      })),
      inventory: sandbox ? { potion: 99, ether: 99, phoenixPin: 99 } : { potion: 4, ether: 1 },
      equipmentInventory: [],
      quests: [
        { id: "first-town", type: "Main", title: "A Town Worth Returning To", description: "Build the café, library, and clinic before anchoring a dangerous universe.", state: sandbox ? "complete" : "active", objectives: ["cafe", "library", "clinic"] },
        { id: "mansion", type: "Multiverse Mystery", title: "The House at 4:44", description: "Anchor and investigate the Haunted Mansion universe.", state: sandbox ? "active" : "hidden", objectives: ["anchor", "foyer", "library", "cellar", "boss"] }
      ],
      assignments: [],
      inventions: sandbox ? ["return-beacon", "encounter-dial"] : [],
      settings: { battleSpeed: 1, activeWait: "wait", invincible: sandbox, encounters: sandbox ? "player" : "normal" },
      autosave: { location: "town", at: now() }
    };
    if (sandbox) {
      for (const id of Object.keys(FACILITIES)) game.facilities[id] = { level: 3, staff: [], queue: [], builtAt: now() };
    }
    return game;
  }

  function storageKey(mode) { return mode === "sandbox" ? SANDBOX_KEY : CAMPAIGN_KEY; }
  function saveGame(game, storage) {
    const target = storage || (typeof localStorage !== "undefined" ? localStorage : null);
    if (!target) return game;
    game.savedAt = now();
    game.lastOnlineAt = game.savedAt;
    target.setItem(storageKey(game.mode), JSON.stringify(game));
    return game;
  }

  function loadGame(mode, storage) {
    const target = storage || (typeof localStorage !== "undefined" ? localStorage : null);
    if (!target) return null;
    const raw = target.getItem(storageKey(mode));
    if (!raw) return null;
    try {
      const game = JSON.parse(raw);
      if (game.version !== SAVE_VERSION || game.mode !== mode) return null;
      applyOfflineProgress(game, now());
      return game;
    } catch (_) { return null; }
  }

  function canAfford(game, cost) {
    return Object.entries(cost || {}).every(([key, amount]) => (game.materials[key] || 0) >= amount);
  }

  function buildFacility(game, facilityId) {
    const def = FACILITIES[facilityId];
    if (!def) return { ok: false, reason: "Unknown blueprint." };
    if (game.facilities[facilityId]) return { ok: false, reason: `${def.name} is already built.` };
    if (facilityId === "mansion" && !["cafe", "library", "clinic"].every(id => game.facilities[id])) {
      return { ok: false, reason: "Build the café, library, and clinic before opening the fault line." };
    }
    if (!canAfford(game, def.cost)) return { ok: false, reason: "Not enough construction materials." };
    for (const [key, amount] of Object.entries(def.cost || {})) game.materials[key] -= amount;
    game.facilities[facilityId] = { level: 1, staff: [], queue: [], builtAt: now() };
    if (facilityId === "mansion") {
      game.universes["haunted-mansion"].anchored = true;
      game.universes["haunted-mansion"].discovered = true;
      game.phase = "recruit-party";
      const mystery = game.quests.find(q => q.id === "mansion");
      if (mystery) mystery.state = "visible";
    }
    if (["cafe", "library", "clinic"].every(id => game.facilities[id])) {
      const quest = game.quests.find(q => q.id === "first-town");
      if (quest) quest.state = "complete";
    }
    return { ok: true, facility: def };
  }

  function activeParty(game) {
    return game.party.slice(0, PARTY_LIMIT).map(id => game.roster[id]).filter(character => character && !character.assignedTo);
  }

  function addToParty(game, characterId) {
    const character = game.roster[characterId];
    if (!character) return { ok: false, reason: "That character has not been recruited." };
    if (character.assignedTo) return { ok: false, reason: `${character.name} is currently assigned to a facility.` };
    if (game.party.includes(characterId)) return { ok: true };
    if (game.party.length >= PARTY_LIMIT) return { ok: false, reason: "The active party is full." };
    game.party.push(characterId);
    return { ok: true };
  }

  function assignCharacter(game, characterId, facilityId, taskId, durationMs) {
    const character = game.roster[characterId];
    if (!character || character.kind === "protagonist" || character.kind === "companion") return { ok: false, reason: "Choose an available hire." };
    if (!game.facilities[facilityId]) return { ok: false, reason: "Build that facility first." };
    if (character.assignedTo) return { ok: false, reason: "That character already has an assignment." };
    game.party = game.party.filter(id => id !== characterId);
    const assignment = { id: `assignment-${now()}-${characterId}`, characterId, facilityId, taskId, startedAt: now(), endsAt: now() + durationMs, claimed: false };
    character.assignedTo = assignment.id;
    game.assignments.push(assignment);
    return { ok: true, assignment };
  }

  function applyOfflineProgress(game, timestamp) {
    const elapsed = clamp(timestamp - (game.lastOnlineAt || timestamp), 0, OFFLINE_CAP_MS);
    const effectiveNow = (game.lastOnlineAt || timestamp) + elapsed;
    for (const assignment of game.assignments || []) {
      if (!assignment.claimed && assignment.endsAt <= effectiveNow) assignment.complete = true;
    }
    game.lastOnlineAt = timestamp;
    return elapsed;
  }

  function claimAssignment(game, assignmentId) {
    const assignment = game.assignments.find(item => item.id === assignmentId);
    if (!assignment || !assignment.complete || assignment.claimed) return { ok: false, reason: "That assignment is not ready." };
    const character = game.roster[assignment.characterId];
    const specialtyBonus = character && ["Engineer", "Support"].includes(character.specialty) ? 1.2 : 1;
    const reward = Math.round(20 * specialtyBonus);
    game.duckets += reward;
    assignment.claimed = true;
    if (character) character.assignedTo = null;
    return { ok: true, reward };
  }

  function createBattle(game, enemyIds) {
    const heroes = activeParty(game).map(character => ({ ...clone(character), side: "hero", sourceId: character.id, atb: 0, defending: false }));
    const companionSource = game.roster[game.activeCompanion];
    const companions = companionSource ? [{ ...clone(companionSource), side: "companion", sourceId: companionSource.id, atb: 55 }] : [];
    const enemies = enemyIds.map((id, index) => {
      const def = ENEMIES[id];
      if (!def) return null;
      return { ...clone(def), id: `${def.id}-${index}`, sourceId: def.id, side: "enemy", maxHp: def.hp, mp: 0, atb: Math.random() * 20, statuses: [], limit: 0, defending: false };
    }).filter(Boolean);
    return { id: `battle-${now()}`, state: "running", elapsed: 0, heroes, companions, enemies, queue: [], ready: [], log: ["The air folds like a badly stored map."], rewards: null };
  }

  function living(units) { return units.filter(unit => unit.hp > 0); }
  function unitSpeed(unit) { return unit.stats ? unit.stats.speed : unit.speed; }
  function unitDefense(unit) { return unit.stats ? unit.stats.defense : unit.defense; }
  function unitStrength(unit) { return unit.stats ? unit.stats.strength : unit.strength; }

  function tickBattle(battle, deltaMs, waitForMenus) {
    if (!battle || battle.state !== "running") return battle;
    if (waitForMenus && battle.ready.some(id => battle.heroes.some(hero => hero.id === id))) return battle;
    const delta = clamp(deltaMs, 0, 100) / 1000;
    battle.elapsed += delta;
    for (const unit of [...living(battle.heroes), ...living(battle.enemies)]) {
      if (unit.atb >= 100 || battle.ready.includes(unit.id)) continue;
      const haste = unit.statuses.includes("haste") ? 1.35 : 1;
      const slow = unit.statuses.includes("slow") ? 0.65 : 1;
      unit.atb = clamp(unit.atb + unitSpeed(unit) * 2.35 * haste * slow * delta, 0, 100);
      if (unit.atb >= 100) battle.ready.push(unit.id);
    }
    for (const companion of battle.companions || []) {
      companion.atb = clamp(companion.atb + companion.stats.speed * 3.1 * delta, 0, 100);
      if (companion.atb >= 100 && living(battle.enemies).length) {
        const target = living(battle.enemies)[Math.floor(Math.random() * living(battle.enemies).length)];
        resolveAttack(battle, companion, target, Math.random() < 0.35 ? "Scratch" : "Bite", 0.82);
        companion.atb = 18;
      }
    }
    const enemyId = battle.ready.find(id => battle.enemies.some(enemy => enemy.id === id));
    if (enemyId) {
      const enemy = battle.enemies.find(unit => unit.id === enemyId);
      const targets = living(battle.heroes);
      if (enemy && targets.length) {
        const target = targets[Math.floor(Math.random() * targets.length)];
        const companion = (battle.companions || [])[0];
        if (companion && Math.random() < 0.24) {
          battle.ready = battle.ready.filter(id => id !== enemy.id);
          enemy.atb = 0;
          battle.log.unshift(`${companion.name} intercepts ${enemy.name} and protects ${target.name}!`);
          if (Math.random() < 0.7) resolveAttack(battle, companion, enemy, "Protective Counter", 0.65);
        } else {
          resolveAttack(battle, enemy, target, "Attack");
        }
      }
    }
    updateBattleState(battle);
    return battle;
  }

  function resolveAttack(battle, actor, target, label, multiplier) {
    if (!actor || !target || actor.hp <= 0 || target.hp <= 0) return { ok: false };
    const variance = 0.9 + Math.random() * 0.2;
    const defendScale = target.defending ? 0.52 : 1;
    const raw = (unitStrength(actor) * (multiplier || 1) * 2.1 - unitDefense(target)) * variance * defendScale;
    const damage = Math.max(1, Math.round(raw));
    target.hp = Math.max(0, target.hp - damage);
    target.defending = false;
    actor.atb = 0;
    battle.ready = battle.ready.filter(id => id !== actor.id);
    if (actor.side === "hero") actor.limit = clamp((actor.limit || 0) + 6, 0, 100);
    if (target.side === "hero") target.limit = clamp((target.limit || 0) + Math.max(5, Math.round(damage / 4)), 0, 100);
    battle.log.unshift(`${actor.name} uses ${label}. ${target.name} takes ${damage} damage${target.hp <= 0 ? " and is knocked out!" : "."}`);
    battle.log = battle.log.slice(0, 8);
    updateBattleState(battle);
    return { ok: true, damage };
  }

  function heroCommand(battle, heroId, command, targetId) {
    if (!battle || battle.state !== "running" || !battle.ready.includes(heroId)) return { ok: false, reason: "That character is not ready." };
    const hero = battle.heroes.find(unit => unit.id === heroId);
    if (!hero) return { ok: false, reason: "Unknown combatant." };
    if (command === "defend") {
      hero.defending = true; hero.atb = 0; battle.ready = battle.ready.filter(id => id !== hero.id);
      battle.log.unshift(`${hero.name} braces for the next attack.`); return { ok: true };
    }
    if (command === "escape") {
      if (battle.enemies.some(enemy => enemy.boss)) return { ok: false, reason: "There is nowhere to run from this boss." };
      battle.state = "escaped"; battle.log.unshift("Ben activates a prudent tactical withdrawal."); return { ok: true };
    }
    const target = battle.enemies.find(unit => unit.id === targetId && unit.hp > 0) || living(battle.enemies)[0];
    const label = hero.kind === "pet" ? "Bite" : command === "skill" ? "Static Advice" : "Attack";
    return resolveAttack(battle, hero, target, label, command === "skill" ? 1.35 : 1);
  }

  function updateBattleState(battle) {
    if (!living(battle.enemies).length && battle.state === "running") {
      battle.state = "victory";
      battle.rewards = battle.enemies.reduce((sum, enemy) => ({ exp: sum.exp + enemy.exp, duckets: sum.duckets + enemy.duckets }), { exp: 0, duckets: 0 });
      battle.log.unshift(`Victory! ${battle.rewards.exp} EXP and ${battle.rewards.duckets} Duckets recovered.`);
    } else if (!living(battle.heroes).length && battle.state === "running") {
      battle.state = "defeat";
      battle.log.unshift("The whole party has been knocked out.");
    }
  }

  function grantBattleRewards(game, battle) {
    if (!battle || battle.state !== "victory" || battle.rewardsClaimed) return { ok: false };
    game.duckets += battle.rewards.duckets;
    const activeIds = new Set([...game.party, game.activeCompanion]);
    for (const character of Object.values(game.roster)) {
      const share = activeIds.has(character.id) ? battle.rewards.exp : Math.floor(battle.rewards.exp * 0.5);
      character.exp += share;
      while (character.level < MAX_LEVEL && character.exp >= xpForLevel(character.level + 1)) {
        character.level += 1;
        character.stats.hp += character.kind === "companion" ? 13 : 10;
        character.stats.mp += character.kind === "companion" ? 2 : 5;
        character.stats.strength += 2;
        character.stats.defense += 1;
      }
      character.hp = Math.max(1, character.hp);
    }
    battle.rewardsClaimed = true;
    return { ok: true, rewards: battle.rewards };
  }

  return {
    SAVE_VERSION, CAMPAIGN_KEY, SANDBOX_KEY, MAX_LEVEL, PARTY_LIMIT, OFFLINE_CAP_MS,
    SPECIALTIES, ELEMENTS, STATUSES, ASSETS, RECRUIT_PACKS, FACILITIES, ENEMIES,
    createNewGame, saveGame, loadGame, storageKey, buildFacility, canAfford,
    activeParty, addToParty, assignCharacter, claimAssignment, applyOfflineProgress,
    createBattle, tickBattle, heroCommand, grantBattleRewards, xpForLevel
  };
});
