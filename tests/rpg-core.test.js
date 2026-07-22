const test = require("node:test");
const assert = require("node:assert/strict");
const RPG = require("../rpg-core.js");

test("campaign begins with Ben in the five-person party and the raptor outside it", () => {
  const game = RPG.createNewGame("campaign");
  assert.deepEqual(game.party, ["ben"]);
  assert.equal(game.activeCompanion, "tiny-velociraptor");
  assert.equal(RPG.activeParty(game).length, 1);
  assert.equal(game.roster[game.activeCompanion].kind, "companion");
  assert.equal(game.recruitPacks.find(pack => pack.name === "Fighter").specialty, "Fighter");
});

test("the Haunted Mansion cannot be anchored until the three civic facilities exist", () => {
  const game = RPG.createNewGame("campaign");
  assert.equal(RPG.buildFacility(game, "mansion").ok, false);
  assert.equal(RPG.buildFacility(game, "cafe").ok, true);
  assert.equal(RPG.buildFacility(game, "library").ok, true);
  assert.equal(RPG.buildFacility(game, "clinic").ok, true);
  const result = RPG.buildFacility(game, "mansion");
  assert.equal(result.ok, true);
  assert.equal(game.universes["haunted-mansion"].anchored, true);
  assert.equal(game.materials.anchorGlass, 0);
});

test("the autonomous raptor joins battle without consuming a hero slot", () => {
  const game = RPG.createNewGame("campaign");
  const battle = RPG.createBattle(game, ["denture"]);
  assert.equal(battle.heroes.length, 1);
  assert.equal(battle.companions.length, 1);
  assert.equal(battle.companions[0].name, "Tiny Velociraptor");
  const startingHp = battle.enemies[0].hp;
  battle.companions[0].atb = 99;
  RPG.tickBattle(battle, 100, false);
  assert.ok(battle.enemies[0].hp < startingHp);
});

test("a ready hero can issue an ATB command and reset their gauge", () => {
  const game = RPG.createNewGame("campaign");
  const battle = RPG.createBattle(game, ["portrait"]);
  battle.heroes[0].atb = 100;
  battle.ready.push("ben");
  const result = RPG.heroCommand(battle, "ben", "attack", battle.enemies[0].id);
  assert.equal(result.ok, true);
  assert.equal(battle.heroes[0].atb, 0);
  assert.equal(battle.ready.includes("ben"), false);
});

test("campaign and sandbox saves use separate storage keys", () => {
  const values = new Map();
  const storage = { setItem: (key, value) => values.set(key, value), getItem: key => values.get(key) || null };
  const campaign = RPG.createNewGame("campaign");
  const sandbox = RPG.createNewGame("sandbox");
  RPG.saveGame(campaign, storage);
  RPG.saveGame(sandbox, storage);
  assert.notEqual(RPG.CAMPAIGN_KEY, RPG.SANDBOX_KEY);
  assert.equal(RPG.loadGame("campaign", storage).mode, "campaign");
  assert.equal(RPG.loadGame("sandbox", storage).mode, "sandbox");
});
