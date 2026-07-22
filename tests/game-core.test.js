"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");
const core = require("../game-core.js");

test("every secondary destination has three unique actions and an outcome for each", () => {
  for (const [locationId, actions] of Object.entries(core.SECONDARY_ACTIONS)) {
    assert.equal(actions.length, 3, locationId);
    assert.equal(new Set(actions.map(action => action.id)).size, actions.length, locationId);
    for (const action of actions) assert.ok(core.actionOutcome(locationId, action.id, { weatherId: "clear" }), `${locationId}:${action.id}`);
  }
});

test("secondary action ids never leak across destinations", () => {
  assert.equal(core.actionOutcome("guildhall", "standardize-scales", { weatherId: "clear" }), null);
  assert.equal(core.actionOutcome("market", "audit-charter", { weatherId: "clear" }), null);
});

test("thunderstorms add a spark only to weather-sensitive outcomes", () => {
  const clear = core.actionOutcome("skyhouse", "anchor-weather-lines", { weatherId: "clear" });
  const storm = core.actionOutcome("skyhouse", "anchor-weather-lines", { weatherId: "thunderstorm" });
  assert.equal(storm.effects.sparks, clear.effects.sparks + 1);
  assert.equal(core.actionOutcome("arcade", "repair-cabinets", { weatherId: "thunderstorm" }).effects.sparks, undefined);
});

test("conversation status reports the step just completed", () => {
  const first = core.advanceConversation(null, 1, 3);
  assert.equal(first.spokenIndex, 0);
  assert.equal(first.completedStep, 1);
  assert.equal(first.next.progress, 1);
  const repeat = core.advanceConversation(first.next, 1, 3);
  assert.equal(repeat.advanced, false);
  assert.equal(repeat.completedStep, 1);
});

test("personal stories advance once per day and complete on the third visit", () => {
  const first = core.advanceConversation(null, 4, 3);
  const sameDay = core.advanceConversation(first.next, 4, 3);
  const second = core.advanceConversation(sameDay.next, 5, 3);
  const third = core.advanceConversation(second.next, 6, 3);
  assert.equal(sameDay.next.progress, 1);
  assert.equal(second.next.progress, 2);
  assert.equal(third.next.progress, 3);
  assert.equal(third.next.complete, true);
});

test("every upgraded destination has a playable challenge configuration", () => {
  const validTypes = new Set(["hunt", "sequence", "timing"]);
  for (const [locationId, challenge] of Object.entries(core.SECONDARY_CHALLENGES)) {
    assert.ok(validTypes.has(challenge.type), locationId);
    assert.ok(challenge.title && challenge.instructions && challenge.virtue, locationId);
    if (challenge.type === "hunt") assert.ok(challenge.targetAsset && challenge.targetCount > 0, locationId);
  }
});

test("objective target follows pickup, carrying, and explicit waypoints", () => {
  const errand = { from: "cafe", to: "lab", status: "pickup" };
  assert.equal(core.objectiveTarget(errand, null), "cafe");
  assert.equal(core.objectiveTarget({ ...errand, status: "carrying" }, null), "lab");
  assert.equal(core.objectiveTarget({ ...errand, status: "done" }, null), null);
  assert.equal(core.objectiveTarget(errand, "market"), "market");
});

test("standard modern controllers normalize sticks, d-pads, and face buttons", () => {
  const buttons = Array.from({ length: 18 }, () => ({ pressed: false, value: 0 }));
  buttons[0] = { pressed: true, value: 1 };
  buttons[14] = { pressed: true, value: 1 };
  const input = core.normalizeGamepad({ mapping: "standard", axes: [0.8, 0.1, 0, 0], buttons });
  assert.equal(input.confirm, true);
  assert.equal(input.move.x, -1);
  assert.equal(input.move.y, 0);
});

test("generic controllers can fall back to their alternate movement axes", () => {
  const input = core.normalizeGamepad({ mapping: "", axes: [0, 0, -0.75, 0.25], buttons: [] });
  assert.ok(input.move.x < -0.65);
  assert.ok(input.move.y > 0.2);
  assert.ok(input.move.magnitude > 0.5);
});
