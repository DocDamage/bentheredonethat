(function (root, factory) {
  const api = factory();
  if (typeof module === "object" && module.exports) module.exports = api;
  if (root) root.BenGameCore = api;
})(typeof globalThis !== "undefined" ? globalThis : this, function () {
  "use strict";

  const SECONDARY_ACTIONS = {
    arcade: [
      { id: "repair-cabinets", title: "Rewire the cabinet row", desc: "Trace a noisy circuit and return three beloved machines to public service.", cost: "−2 energy · +cash/parts", energy: 2, virtue: "industry" },
      { id: "token-coop", title: "Found a neighborhood token co-op", desc: "Turn impossible prize math into a fair, collectively run exchange.", cost: "−1 energy · +friendship/reputation", energy: 1, virtue: "justice" },
      { id: "prize-salvage", title: "Salvage the prize counter", desc: "Recover useful gears without claiming the inflatable crown as an expense.", cost: "−1 energy · +parts", energy: 1, virtue: "frugality" }
    ],
    conservatory: [
      { id: "tend-glasshouse", title: "Tend the public glasshouse", desc: "Clear irrigation grates and bring the medicinal beds back into balance.", cost: "−2 energy · +produce", energy: 2, virtue: "cleanliness" },
      { id: "catalog-remedies", title: "Catalog improbable remedies", desc: "Print useful labels for plants that object to ordinary taxonomy.", cost: "−1 energy · +cash/reputation", energy: 1, virtue: "order" },
      { id: "quiet-study", title: "Conduct a quiet canopy study", desc: "Listen long enough for the useful observation to arrive last.", cost: "−1 energy · +energy/friendship", energy: 1, virtue: "silence" }
    ],
    skyhouse: [
      { id: "sort-aerial-mail", title: "Sort the aerial mail", desc: "Give every windblown route a hook, a label, and a defensible order.", cost: "−2 energy · +cash/reputation", energy: 2, virtue: "order" },
      { id: "anchor-weather-lines", title: "Anchor the weather lines", desc: "Secure the cloud instruments before the forecast leaves town without notice.", cost: "−2 energy · +parts/sparks", energy: 2, virtue: "resolution" },
      { id: "deliver-cloud-route", title: "Run the cloud route", desc: "Complete the inconvenient high-altitude deliveries instead of optimizing them away.", cost: "−1 energy · +friendship", energy: 1, virtue: "justice" }
    ],
    guildhall: [
      { id: "audit-charter", title: "Audit the monster charter", desc: "Add practical representation clauses for nocturnal, spectral, and enormous residents.", cost: "−1 energy · +friendship/reputation", energy: 1, virtue: "justice" },
      { id: "repair-guild-ramp", title: "Repair the guild ramp", desc: "Spend the emergency fund on access before commissioning decorative lightning vanes.", cost: "−2 energy · +cash/parts", energy: 2, virtue: "frugality" },
      { id: "mutual-aid-supper", title: "Host a mutual-aid supper", desc: "Serve portions by need and keep every faction at the same very large table.", cost: "$6 · +energy/friendship", energy: 0, requiresCash: 6, virtue: "moderation" }
    ],
    market: [
      { id: "standardize-scales", title: "Standardize the public scales", desc: "Test every merchant weight and publish the honest results beside the mushroom riddles.", cost: "−1 energy · +cash/reputation", energy: 1, virtue: "sincerity" },
      { id: "merchant-supper", title: "Negotiate a merchant supper", desc: "Settle three stall disputes over shared bread, separate sauces, and exact receipts.", cost: "$6 · +energy/friendship", energy: 0, requiresCash: 6, virtue: "moderation" },
      { id: "repair-treadle", title: "Repair the cloth-loft treadle", desc: "Accept a simpler mechanical answer and return the motor sketch to Ben’s pocket.", cost: "−2 energy · +cash/parts", energy: 2, virtue: "humility" }
    ],
    elementalbaths: [
      { id: "balance-valves", title: "Balance the thermal valves", desc: "Route ember and frost through the main line without boiling the municipal towels.", cost: "−2 energy · +cash/parts", energy: 2, virtue: "temperance" },
      { id: "clean-pressure-lines", title: "Clean the pressure lines", desc: "Remove scale before proposing an exciting and unnecessary replacement boiler.", cost: "−1 energy · +friendship/reputation", energy: 1, virtue: "cleanliness" },
      { id: "cold-pool-rest", title: "Take the constitutional cold pool", desc: "Pay for a quiet interval in which Ben fixes absolutely nothing.", cost: "$4 · +energy", energy: 0, requiresCash: 4, virtue: "tranquillity" }
    ],
    clockstation: [
      { id: "sort-postal-bags", title: "Sort the postal bags", desc: "Separate actual departures from aspirational ones and rescue the local route.", cost: "−2 energy · +cash/reputation", energy: 2, virtue: "order" },
      { id: "ground-signal-tower", title: "Ground the signal tower", desc: "Protect the speaking tubes from atmospheric electricity and theatrical sparks.", cost: "−2 energy · +parts/sparks", energy: 2, virtue: "resolution" },
      { id: "inspect-express-route", title: "Inspect the express route", desc: "Remove a seven-minute parcel loop without claiming to have invented logistics.", cost: "−1 energy · +cash/friendship", energy: 1, virtue: "industry" }
    ]
  };

  const SECONDARY_OUTCOMES = {
    arcade: {
      "repair-cabinets": { stamp: "CURRENT RESTORED", title: "Three More Continues", copy: "Ben traces the bad ground, labels the breaker, and returns three cabinets to service. The high-score initials remain constitutionally dubious.", effects: { cash: 11, parts: 1, friendship: 1 } },
      "token-coop": { stamp: "TOKENS RATIFIED", title: "A Fair Exchange Rate", copy: "Players approve transparent prize prices and a community repair fund. Countess BPM attempts a filibuster using a rhythm game.", effects: { reputation: 2, friendship: 3 } },
      "prize-salvage": { stamp: "USEFUL PRIZES", title: "The Gear Behind the Glitter", copy: "Ben recovers two sound gears and leaves the inflatable crown for someone with a more urgent claim.", effects: { parts: 2, cash: 4, friendship: 1 } }
    },
    conservatory: {
      "tend-glasshouse": { stamp: "WATER MOVING", title: "A Cleaner Glasshouse", copy: "The cleared grate revives the public beds. Briar sends Ben home with produce that is only mildly bioluminescent.", effects: { produce: 2, friendship: 2 } },
      "catalog-remedies": { stamp: "SPECIMENS FILED", title: "Labels Before Legends", copy: "Ben prints plain-language labels for every useful plant. One fern files a correction in excellent copperplate.", effects: { cash: 8, reputation: 1, friendship: 1 } },
      "quiet-study": { stamp: "OBSERVATION RECORDED", title: "The Detail Arrives Last", copy: "After a full quiet minute, Ben notices the pollinators avoiding one overheated pane. The repair can wait until after tea.", effects: { energy: 2, friendship: 2 } }
    },
    skyhouse: {
      "sort-aerial-mail": { stamp: "ROUTES IN ORDER", title: "Neither Rain Nor Low Cloud", copy: "Every mailbag receives a hook and every hook a route. The clouds remain proudly unsorted.", effects: { cash: 12, reputation: 1, friendship: 1 } },
      "anchor-weather-lines": { stamp: "LINES SECURED", title: "A Forecast That Stays Put", copy: "Ben grounds the instruments and pockets a reusable brass fitting. A passing thunderhead contributes one unsolicited spark.", effects: { parts: 1, sparks: 1, weatherSpark: true, friendship: 1 } },
      "deliver-cloud-route": { stamp: "HIGH POST DELIVERED", title: "The Inconvenient Address", copy: "Ben reaches the far platform instead of deleting it from the route. Aero marks the delivery ‘late, fair, and impressively windswept.’", effects: { reputation: 1, friendship: 3 } }
    },
    guildhall: {
      "audit-charter": { stamp: "CHARTER AMENDED", title: "A Vote for Every Shape", copy: "The hall adopts moonlight attendance, witnessed voice votes, and a chair reinforced for civic-minded ogres.", effects: { reputation: 2, friendship: 3 } },
      "repair-guild-ramp": { stamp: "ACCESS RESTORED", title: "The Treasury Does Its Job", copy: "Ben funds and repairs the broken ramp before anyone can order a ceremonial lightning vane. Bronzewick approves the receipt.", effects: { cash: 8, parts: 1, friendship: 2 } },
      "mutual-aid-supper": { stamp: "EVERY BOWL FILLED", title: "Portions by Need", copy: "Mosswell serves the assembly by appetite rather than rank. The ogre ladle remains, correctly, nonnegotiable.", effects: { cash: -6, energy: 3, friendship: 3 } }
    },
    market: {
      "standardize-scales": { stamp: "HONEST WEIGHTS", title: "Commerce, Accurately Measured", copy: "Ben certifies the public scales and publishes every conversion. The mushroom stall keeps its riddles but fixes its ounces.", effects: { cash: 10, reputation: 2, friendship: 1 } },
      "merchant-supper": { stamp: "TERMS SERVED", title: "A Receipt for Peace", copy: "Three stall disputes end over shared bread, separate sauces, and a surprisingly binding dessert clause.", effects: { cash: -6, energy: 3, friendship: 2, reputation: 1 } },
      "repair-treadle": { stamp: "TREADLE TURNING", title: "The Simpler Machine Wins", copy: "Madame Magenta demonstrates a repair faster than Ben’s proposed motor. He takes notes and accepts payment without revising history.", effects: { cash: 13, parts: 1, friendship: 1 } }
    },
    elementalbaths: {
      "balance-valves": { stamp: "TEMPERATURE RATIFIED", title: "Ember Meets Frost", copy: "Ben balances the main line at a temperature acceptable to dragons, elementals, and the insurance form.", effects: { cash: 11, parts: 1, friendship: 1 } },
      "clean-pressure-lines": { stamp: "PRESSURE NORMAL", title: "Cleaning Wins Again", copy: "Scale—not sabotage—caused the boiler’s dramatic shriek. Rusty quietly retires the emergency wrench.", effects: { reputation: 1, friendship: 3 } },
      "cold-pool-rest": { stamp: "NOTHING FIXED", title: "A Constitutionally Cold Pause", copy: "Ben sits with the cold, improves no systems, and emerges with the radical resource known as remaining energy.", effects: { cash: -4, energy: 4, friendship: 1 } }
    },
    clockstation: {
      "sort-postal-bags": { stamp: "POST IN ORDER", title: "Actual Departures First", copy: "Ben separates today’s trains from the station’s aspirational schedule. Twelve parcels immediately become punctual.", effects: { cash: 12, reputation: 1, friendship: 1 } },
      "ground-signal-tower": { stamp: "SIGNAL GROUNDED", title: "The Third Bell Rings Clear", copy: "A proper ground quiets the speaking tubes. Sally hears the faint third bell and Ben salvages a brass connector.", effects: { parts: 1, sparks: 1, weatherSpark: true, friendship: 2 } },
      "inspect-express-route": { stamp: "LOOP REMOVED", title: "Seven Minutes Returned", copy: "Ben removes a parcel loop and declines to rename the timetable after himself. Copper Quickstep considers this growth.", effects: { cash: 9, friendship: 2, reputation: 1 } }
    }
  };

  const SECONDARY_CHALLENGES = {
    arcade: { type: "sequence", action: "Restore the cabinet circuit", description: "Repeat the safe breaker route across the cabinet row.", title: "Restore the Cabinet Circuit", instructions: "Memorize the breaker route, then repeat it with arrows or the four buttons.", length: 5, animationAction: "tinker", virtue: "industry", baseReward: 8 },
    conservatory: { type: "hunt", action: "Balance the glasshouse beds", description: "Collect six ready seedlings before the irrigation cycle turns.", title: "Balance the Glasshouse Beds", instructions: "Gather six ready seedlings before the irrigation window closes.", targetCount: 6, duration: 11, targetAsset: "assets/More Tilesets/cursed land/PNG/Objects_separately/Mushrooms_shadow2_3.png", animationAction: "garden", virtue: "cleanliness", baseReward: 7 },
    skyhouse: { type: "hunt", action: "Sort the aerial post", description: "Catch six windblown parcels before they leave the route.", title: "Sort the Aerial Post", instructions: "Catch six parcels before the wind carries them beyond the platform.", targetCount: 6, duration: 10, targetAsset: "assets/More Tilesets/Fantasy Structures & Props - Pixel Art Asset Pack/fsp_pirate-crates.png", animationAction: "trailride", virtue: "resolution", baseReward: 8 },
    guildhall: { type: "hunt", action: "File the unusual citizens’ charter", description: "Find six missing seals before the assembly begins.", title: "File the Unusual Citizens’ Charter", instructions: "Collect six charter seals before the assembly is called to order.", targetCount: 6, duration: 11, targetAsset: "assets/More Tilesets/Fantasy Structures & Props - Pixel Art Asset Pack/fsp_prop-chest-overgrown.png", animationAction: "inspect", virtue: "justice", baseReward: 8 },
    market: { type: "sequence", action: "Balance the public scales", description: "Repeat the honest-weight sequence across the market floors.", title: "Balance the Market Scales", instructions: "Memorize the standard weights, then repeat them in order.", length: 5, animationAction: "serve", virtue: "sincerity", baseReward: 8 },
    elementalbaths: { type: "timing", action: "Tune the thermal valves", description: "Stop each valve inside the safe ember-and-frost range.", title: "Balance Ember and Frost", instructions: "Stop the valve marker inside the golden temperature zone.", rounds: 4, animationAction: "tinker", virtue: "temperance", baseReward: 8 },
    clockstation: { type: "hunt", action: "Catch the Parcel Express", description: "Collect six wayward parcels before the station clock strikes.", title: "Catch the Parcel Express", instructions: "Collect six parcels before the departure bell rings.", targetCount: 6, duration: 10, targetAsset: "assets/More Tilesets/Fantasy Structures & Props - Pixel Art Asset Pack/fsp_pirate-crates.png", animationAction: "trailride", virtue: "order", baseReward: 8 }
  };

  function actionOutcome(locationId, actionId, context) {
    const source = SECONDARY_OUTCOMES[locationId] && SECONDARY_OUTCOMES[locationId][actionId];
    if (!source) return null;
    const effects = Object.assign({}, source.effects);
    if (effects.weatherSpark) {
      delete effects.weatherSpark;
      if (context && context.weatherId === "thunderstorm") effects.sparks = (effects.sparks || 0) + 1;
    }
    return { stamp: source.stamp, title: source.title, copy: source.copy, effects: effects };
  }

  function advanceConversation(progress, day, stepCount) {
    const current = Object.assign({ progress: 0, lastDay: 0, complete: false }, progress || {});
    const spokenIndex = Math.min(current.progress, Math.max(0, stepCount));
    const next = Object.assign({}, current);
    let advanced = false;
    if (next.lastDay !== day && !next.complete) {
      next.lastDay = day;
      next.progress += 1;
      next.complete = next.progress >= stepCount;
      advanced = true;
    }
    const completedStep = Math.min(Math.max(next.progress, 1), Math.max(stepCount, 1));
    return { next: next, spokenIndex: spokenIndex, completedStep: completedStep, advanced: advanced };
  }

  function objectiveTarget(errand, waypointLocationId) {
    if (waypointLocationId) return waypointLocationId;
    if (!errand || errand.status === "done") return null;
    return errand.status === "carrying" ? errand.to : errand.from;
  }

  function gamepadButtonPressed(pad, index) {
    const button = pad && pad.buttons ? pad.buttons[index] : null;
    if (typeof button === "number") return button > 0.5;
    return Boolean(button && (button.pressed || Number(button.value) > 0.5));
  }

  function normalizeStick(x, y, deadzone) {
    const safeX = Number.isFinite(Number(x)) ? Number(x) : 0;
    const safeY = Number.isFinite(Number(y)) ? Number(y) : 0;
    const magnitude = Math.min(1, Math.hypot(safeX, safeY));
    if (magnitude <= deadzone) return { x: 0, y: 0, magnitude: 0 };
    const scaled = Math.min(1, (magnitude - deadzone) / (1 - deadzone));
    return { x: safeX / magnitude * scaled, y: safeY / magnitude * scaled, magnitude: scaled };
  }

  function genericHatDirection(value) {
    const hat = Number(value);
    if (!Number.isFinite(hat) || hat < -1.05 || hat > 1.05) return { x: 0, y: 0 };
    const hatValues = [-1, -0.714, -0.428, -0.142, 0.142, 0.428, 0.714, 1];
    let index = 0;
    for (let cursor = 1; cursor < hatValues.length; cursor += 1) {
      if (Math.abs(hatValues[cursor] - hat) < Math.abs(hatValues[index] - hat)) index = cursor;
    }
    if (Math.abs(hatValues[index] - hat) > 0.08) return { x: 0, y: 0 };
    const directions = [
      { x: 0, y: -1 }, { x: 1, y: -1 }, { x: 1, y: 0 }, { x: 1, y: 1 },
      { x: 0, y: 1 }, { x: -1, y: 1 }, { x: -1, y: 0 }, { x: -1, y: -1 }
    ];
    return directions[index];
  }

  function normalizeGamepad(pad, deadzone) {
    const zone = Math.max(0.05, Math.min(0.5, Number(deadzone) || 0.18));
    const axes = Array.from(pad && pad.axes ? pad.axes : [], value => Number(value) || 0);
    let stick = normalizeStick(axes[0], axes[1], zone);
    if (!stick.magnitude && pad && pad.mapping !== "standard" && axes.length >= 4) stick = normalizeStick(axes[2], axes[3], zone);
    let dpadX = Number(gamepadButtonPressed(pad, 15)) - Number(gamepadButtonPressed(pad, 14));
    let dpadY = Number(gamepadButtonPressed(pad, 13)) - Number(gamepadButtonPressed(pad, 12));
    if (!dpadX && !dpadY && pad && pad.mapping !== "standard" && axes.length > 9) {
      const hat = genericHatDirection(axes[9]);
      dpadX = hat.x;
      dpadY = hat.y;
    }
    const dpadLength = Math.hypot(dpadX, dpadY) || 1;
    const move = dpadX || dpadY
      ? { x: dpadX / dpadLength, y: dpadY / dpadLength, magnitude: 1 }
      : stick;
    const pressed = Array.from({ length: Math.max(18, pad && pad.buttons ? pad.buttons.length : 0) }, (_, index) => gamepadButtonPressed(pad, index));
    return {
      move,
      pressed,
      confirm: pressed[0],
      cancel: pressed[1],
      secondary: pressed[2],
      previous: pressed[4],
      next: pressed[5],
      menu: pressed[9]
    };
  }

  return {
    SECONDARY_ACTIONS,
    SECONDARY_OUTCOMES,
    SECONDARY_CHALLENGES,
    actionOutcome,
    advanceConversation,
    objectiveTarget,
    normalizeGamepad
  };
});
