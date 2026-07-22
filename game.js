(() => {
  "use strict";

  const CORE = window.BenGameCore;
  if (!CORE) throw new Error("BenGameCore failed to load.");
  const LEGACY_SAVE_KEY = "ben-there-done-that-save-v1";
  const SAVE_SLOT_PREFIX = "ben-there-done-that-save-v2-slot-";
  const ACTIVE_SAVE_SLOT_KEY = "ben-there-done-that-active-slot";
  let activeSaveSlot = clampSaveSlot(localStorage.getItem(ACTIVE_SAVE_SLOT_KEY));
  function clampSaveSlot(value) { return Math.min(3, Math.max(1, Math.floor(Number(value) || 1))); }
  function saveKey(slot = activeSaveSlot) { return `${SAVE_SLOT_PREFIX}${clampSaveSlot(slot)}`; }
  const MAX_ENERGY = 7;
  const TIME_SLOTS = ["Morning", "Afternoon", "Evening"];

  const ASSETS = {
    benIdle: "assets/characters/Main Character/Ben_Franklin/rotations/south.png",
    benDirections: "assets/characters/Main Character/Ben_Franklin/rotations/",
    benRunning: "assets/characters/Main Character/Ben_Franklin/animations/Running/",
    click: "assets/SFX/FREE Retro Action Platformer Sound Effects/click_1.ogg",
    success: "assets/SFX/FREE Retro Action Platformer Sound Effects/sucess1.mp3",
    transition: "assets/SFX/FREE Retro Action Platformer Sound Effects/Transition.ogg",
    eat: "assets/SFX/FREE Retro Action Platformer Sound Effects/textoreating.mp3"
  };

  const BEN_ANIMATIONS = {
    breathing: { folder: "Breathing_Idle", frames: 4, label: "Breathing Idle" },
    crouchWalk: { folder: "Crouched_Walking", frames: 6, label: "Crouched Walking" },
    takingPunch: { folder: "Taking_Punch", frames: 6, label: "Taking Punch" },
    fightStance: { folder: "Fight_Stance_Idle", frames: 8, label: "Fight Stance" },
    flyingKick: { folder: "Flying_Kick", frames: 6, label: "Flying Kick" },
    leadJab: { folder: "Lead_Jab", frames: 3, label: "Lead Jab" },
    angryStomp: { folder: "Angry_Stomp", frames: 9, label: "Angry Stomp" },
    running: { folder: "Running", frames: 6, label: "Running" },
    falling: { folder: "Falling_Back_Death", frames: 7, label: "Dramatic Fall" },
    gettingUp: { folder: "Getting_Up", frames: 5, label: "Getting Up" },
    pickingUp: { folder: "Picking_Up", frames: 5, label: "Picking Up" },
    crossPunch: { folder: "Cross_Punch", frames: 6, label: "Cross Punch" },
    throwObject: { folder: "Throw_Object", frames: 7, label: "Throw Object" },
    kiteFlash: { folder: "Ben_Franklin_flashes_blue_and_white_over_and_over", frames: 17, label: "Electric Kite Flash", kite: true },
    kiteSwing: { folder: "Swinging_Kite", frames: 9, label: "Swinging Kite", kite: true },
    kiteThrow: { folder: "Throwing_spinning_flag_attack._Throw_the_flag_and", frames: 9, label: "Spinning Kite Throw", kite: true },
    kiteLight: { folder: "Light_Flag_Attack", frames: 9, label: "Light Kite Attack", kite: true }
  };

  const ACTION_ANIMATIONS = {
    pickup: ["pickingUp"], deliver: ["throwObject"], barista: ["throwObject"], counsel: ["breathing"], pastry: ["pickingUp"],
    tinker: ["kiteFlash", "kiteSwing", "kiteThrow", "kiteLight"], intern: ["pickingUp"], hexchat: ["fightStance"],
    serve: ["running"], meal: ["breathing"], kitchen: ["crossPunch"], garden: ["angryStomp", "pickingUp"],
    pigchat: ["angryStomp"], forage: ["crouchWalk"], inspect: ["crouchWalk"], seance: ["fightStance"], dust: ["leadJab"],
    openmic: ["kiteLight"], dance: ["fightStance", "leadJab", "crossPunch", "flyingKick", "takingPunch", "falling", "gettingUp"],
    bartend: ["throwObject"], groom: ["breathing", "pickingUp"], irrigate: ["crouchWalk", "throwObject"], trailride: ["running"],
    nap: ["falling", "gettingUp"]
  };

  const LOCATIONS = {
    cafe: {
      id: "cafe",
      name: "The Daily Grind",
      short: "Café",
      subtitle: "Coffee, pastries, bones",
      x: 16,
      y: 25,
      color: "#d99262",
      art: "assets/Cafe Assets/Patch 1/Coffee, bakery and flowers.png",
      artPosition: "42% 35%",
      npc: "Juniper Bones",
      role: "Barista · amateur anatomist",
      line: "Decaf is just bean tea, Ben.",
      avatar: "💀",
      sprite: {
        sheet: "assets/NPCs/day_of_the_dead/dotd_skeletonsheet_1.png",
        x: 0, y: 0, w: 26, h: 36, scale: 3, layout:"rpg"
      }
    },
    lab: {
      id: "lab",
      name: "The Tomorrow Lab",
      short: "Laboratory",
      subtitle: "Science, legally adjacent",
      x: 49,
      y: 15,
      color: "#77a9c8",
      art: "assets/Modern Laboratory Assets/1.png",
      artPosition: "74% 42%",
      npc: "Dr. Mara Hex",
      role: "Municipal scientist · witch",
      line: "The ethics board said ‘be reasonable.’ Very vague.",
      avatar: "🧙",
      sprite: {
        sheet: "assets/NPCs/witch/1x/witch1_1.png",
        x: 0, y: 0, w: 26, h: 36, scale: 2, layout:"rpg"
      }
    },
    restaurant: {
      id: "restaurant",
      name: "The Federalist Table",
      short: "Restaurant",
      subtitle: "Brunch without representation",
      x: 81,
      y: 29,
      color: "#b8875e",
      art: "assets/Modern Restaurant/1.png",
      artPosition: "48% 27%",
      npc: "Chef Howl",
      role: "Chef · full-moon caterer",
      line: "The prix fixe menu has one amendment: more butter.",
      avatar: "🐺",
      sprite: {
        sheet: "assets/NPCs/RMMV/beast_hero_2.png",
        x: 0, y: 0, w: 78, h: 108, scale: 1, layout:"rpg"
      }
    },
    farm: {
      id: "farm",
      name: "Common Ground Farm",
      short: "Farm",
      subtitle: "Local produce, feral optimism",
      x: 17,
      y: 78,
      color: "#719c62",
      art: "assets/Farm Assets/farm/1.png",
      artPosition: "30% 18%",
      npc: "Alistair Pigford",
      role: "Farmer · zoning activist",
      line: "The tomatoes have unionized. Frankly, I respect it.",
      avatar: "🐷",
      sprite: {
        sheet: "assets/Ranch Stuff/assets/animals/pigs/pig_01/purple/idle/pig_01_purple_idle_down_32x32.png",
        x: 0, y: 0, w: 32, h: 32, scale: 3
      }
    },
    ranch: {
      id: "ranch",
      name: "Pigford Moonlight Ranch",
      short: "Ranch",
      subtitle: "Animals, trails, tiny hats",
      x: 30,
      y: 62,
      color: "#a87654",
      art: "assets/Ranch Stuff/Super_retro_world_water_animation/SuperRetro_Banner_Tileset.png",
      artPosition: "86% 84%",
      npc: "Petunia Pigford",
      role: "Rancher · seed librarian",
      line: "Please return the radish seeds alphabetized.",
      avatar: "🐷",
      sprite: {
        sheet: "assets/Ranch Stuff/assets/animals/pigs/pig_01/black/idle/pig_01_black_idle_down_32x32.png",
        x: 0, y: 0, w: 32, h: 32, scale: 3
      }
    },
    mansion: {
      id: "mansion",
      name: "The Slightly Haunted House",
      short: "Mansion",
      subtitle: "Affordable rent, audible walls",
      x: 49,
      y: 83,
      color: "#71658f",
      art: "assets/Haunted Mansion/2.png",
      artPosition: "16% 44%",
      npc: "Gus",
      role: "Ghost · tenant association president",
      line: "I’m not haunting the place. I’m working from home.",
      avatar: "👻",
      sprite: {
        sheet: "assets/NPCs/ghost1.png",
        x: 0, y: 0, w: 26, h: 36, scale: 2, layout:"rpg"
      }
    },
    club: {
      id: "club",
      name: "The Electric Current",
      short: "Nightclub",
      subtitle: "Open late, technically grounded",
      x: 81,
      y: 76,
      color: "#bd5870",
      art: "assets/Modern Bar & Nightclub/2.png",
      artPosition: "22% 38%",
      npc: "DJ Nocturne",
      role: "DJ · night-shift vampire",
      line: "Your playlist needs less harpsichord and more pulse.",
      avatar: "🧛",
      sprite: {
        sheet: "assets/NPCs/vampire_1.png",
        x: 0, y: 0, w: 26, h: 36, scale: 3, layout:"rpg"
      }
    },
    arcade: {
      id:"arcade", name:"Franklin Electric Arcade", short:"Arcade", subtitle:"Three floors, questionable tokens", x:14, y:15, color:"#55c7c0",
      art:"assets/More Tilesets/XModern Arcade/master.png", artPosition:"48% 48%", npc:"DJ Nocturne", role:"Acting manager · night-shift vampire", line:"The rooftop cabinet is absolutely not wired to the weather vane.", avatar:"🕹", sprite:{sheet:"assets/NPCs/vampire_1.png",x:0,y:0,w:26,h:36,scale:3,layout:"rpg"}
    },
    conservatory: {
      id:"conservatory", name:"The Junto Conservatory", short:"Conservatory", subtitle:"Glass rooms, improbable botany", x:55, y:9, color:"#65a66d",
      art:"assets/More Tilesets/fairy forest/tf_fairyforest_12.28.20/ff_master_tiles.png", artPosition:"62% 40%", npc:"Prof. Briar Hex", role:"Curator · practical magician", line:"Floor three is blooming sideways again.", avatar:"❀", sprite:{sheet:"assets/NPCs/witch/1x/witch2_1.png",x:0,y:0,w:26,h:36,scale:2,layout:"rpg"}
    },
    skyhouse: {
      id:"skyhouse", name:"The Aerial Post House", short:"Sky House", subtitle:"Mail, clouds, several staircases", x:88, y:58, color:"#7baac7",
      art:"assets/More Tilesets/Flying Islands/Tiled_files/Objects.png", artPosition:"50% 38%", npc:"Aero Naught", role:"Balloon pilot · weather courier", line:"The wind filed a change of address.", avatar:"🎈", sprite:{sheet:"assets/quirky npcs/fullcolor/aeronaut.png",x:0,y:0,w:46,h:66,sheetWidth:138,displayHeight:82,layout:"strip",frameCount:3,contentBounds:[7,6,27,59]}
    },
    guildhall: {
      id:"guildhall", name:"The Unusual Citizens’ Hall", short:"Guild Hall", subtitle:"Monsters, minutes, mutual aid", x:31, y:38, color:"#687f74",
      art:"assets/More Tilesets/Fantasy Structures & Props - Pixel Art Asset Pack/fsp_structure-stone-temple1.png", artPosition:"50% 42%", npc:"Wolfgang Gearfang", role:"Guild clerk · werewolf", line:"Please initial the moonlight accommodation form.", avatar:"🐺", sprite:{sheet:"assets/Topdown Monsters Part 1/00.png",x:0,y:0,w:80,h:80,sheetWidth:640,displayHeight:88,layout:"actionRows",idleFrames:6,walkFrames:8}
    },
    market: {
      id:"market", name:"Lantern Market", short:"Market", subtitle:"Odd wares, honest weights", x:56, y:38, color:"#c78952",
      art:"assets/More Tilesets/Medieval Fantasy Town Pixel Art Tileset Pack/7.png", artPosition:"46% 48%", npc:"Thimblewick", role:"Market steward · goblin", line:"The scale is honest. The mushrooms are evasive.", avatar:"🏮", sprite:{sheet:"assets/Topdown Monsters Part 1/03.png",x:0,y:0,w:80,h:80,sheetWidth:640,displayHeight:88,layout:"actionRows",idleFrames:6,walkFrames:8}
    },
    elementalbaths: {
      id:"elementalbaths", name:"Ember & Frost Bathhouse", short:"Bathhouse", subtitle:"Hot springs, cold contracts", x:77, y:63, color:"#bc6754",
      art:"assets/More Tilesets/Volcanic/13. Decorations.png", artPosition:"54% 44%", npc:"Azul Frost", role:"Cold-pool attendant · elemental", line:"Hot side to the left. Existential mist straight ahead.", avatar:"♨", sprite:{sheet:"assets/Topdown Monsters Part 1/07.png",x:0,y:0,w:80,h:80,sheetWidth:640,displayHeight:88,layout:"actionRows",idleFrames:6,walkFrames:8}
    },
    clockstation: {
      id:"clockstation", name:"Poor Richard Station", short:"Clock Station", subtitle:"Trains, parcels, punctuality", x:55, y:70, color:"#9b704b",
      art:"assets/More Tilesets/Steampunk Pixel Art Tileset/7.png", artPosition:"50% 52%", npc:"Sir Sprocket", role:"Station marshal · automaton", line:"The 4:15 is on time in at least one timeline.", avatar:"⚙", sprite:{sheet:"assets/Topdown Monsters Part 1/10.png",x:0,y:0,w:80,h:80,sheetWidth:640,displayHeight:88,layout:"actionRows",idleFrames:6,walkFrames:8}
    }
  };

  const LOCATION_ORDER = ["cafe", "arcade", "guildhall", "lab", "conservatory", "market", "restaurant", "elementalbaths", "skyhouse", "club", "clockstation", "mansion", "farm", "ranch"];

  const NPCS = {
    juniper: { id: "juniper", name: "Juniper Bones", role: "Barista · amateur anatomist", line: "Decaf is just bean tea, Ben.", avatar: "💀", sprite: { sheet: "assets/NPCs/day_of_the_dead/dotd_skeletonsheet_1.png", x: 0, y: 0, w: 26, h: 36, scale: 3, layout:"rpg" } },
    lola: { id: "lola", name: "Lola Calavera", role: "Pastry chef · dance captain", line: "Every croissant deserves a dramatic entrance.", avatar: "🌺", sprite: { sheet: "assets/NPCs/day_of_the_dead/dotd_skeletonsheet_2.png", x: 156, y: 0, w: 52, h: 72, scale: 1.5, layout:"rpg" } },
    rowan: { id: "rowan", name: "Rowan Fang", role: "Poet · oat-milk enthusiast", line: "I ordered a cortado and received personal growth.", avatar: "🐺", sprite: { sheet: "assets/NPCs/RMMV/beast_hero_5.png", x: 0, y: 0, w: 78, h: 108, scale: 1, layout:"rpg" } },
    mara: { id: "mara", name: "Dr. Mara Hex", role: "Municipal scientist · witch", line: "The ethics board said ‘be reasonable.’ Very vague.", avatar: "🧙", sprite: { sheet: "assets/NPCs/witch/1x/witch1_1.png", x: 0, y: 0, w: 26, h: 36, scale: 2, layout:"rpg" } },
    briar: { id: "briar", name: "Prof. Briar Hex", role: "Botanist · practical magician", line: "The fern is sentient, but only during office hours.", avatar: "🪄", sprite: { sheet: "assets/NPCs/witch/1x/witch2_1.png", x: 0, y: 0, w: 26, h: 36, scale: 2, layout:"rpg" } },
    mort: { id: "mort", name: "Mort Voltage", role: "Safety inspector · reaper", line: "I’m not here for you. I’m here for the extension cord.", avatar: "☠", sprite: { sheet: "assets/NPCs/reaper/reaper_1.png", x: 0, y: 0, w: 26, h: 36, scale: 2, layout:"rpg" } },
    chef: { id: "chef", name: "Chef Howl", role: "Chef · full-moon caterer", line: "The prix fixe menu has one amendment: more butter.", avatar: "🐺", sprite: { sheet: "assets/NPCs/RMMV/beast_hero_1.png", x: 0, y: 0, w: 78, h: 108, scale: 1, layout:"rpg" } },
    claudia: { id: "claudia", name: "Clawdia", role: "Sous chef · knife avoider", line: "I plate with my heart and occasionally my tail.", avatar: "🐾", sprite: { sheet: "assets/NPCs/RMMV/beast_hero_2.png", x: 0, y: 0, w: 78, h: 108, scale: 1, layout:"rpg" } },
    basil: { id: "basil", name: "Basil Moon", role: "Host · reservation oracle", line: "Your table is ready in this timeline.", avatar: "🌙", sprite: { sheet: "assets/NPCs/RMMV/beast_hero_4.png", x: 0, y: 0, w: 78, h: 108, scale: 1, layout:"rpg" } },
    nocturne: { id: "nocturne", name: "DJ Nocturne", role: "DJ · night-shift vampire", line: "Your playlist needs less harpsichord and more pulse.", avatar: "🧛", sprite: { sheet: "assets/NPCs/vampire_1.png", x: 0, y: 0, w: 26, h: 36, scale: 3, layout:"rpg" } },
    countess: { id: "countess", name: "Countess BPM", role: "Promoter · eternal hype", line: "I haven’t seen daylight or an empty dance floor in centuries.", avatar: "🎧", sprite: { sheet: "assets/NPCs/vampire_2.png", x: 0, y: 0, w: 52, h: 72, scale: 1.5, layout:"rpg" } },
    vee: { id: "vee", name: "Vee Shivers", role: "Bartender · synth collector", line: "The mocktail is called Positive Charge. Sign here.", avatar: "🍷", sprite: { sheet: "assets/NPCs/vampire_3.png", x: 0, y: 0, w: 78, h: 108, scale: 1, layout:"rpg" } },
    gus: { id: "gus", name: "Gus", role: "Ghost · tenant association president", line: "I’m not haunting the place. I’m working from home.", avatar: "👻", sprite: { sheet: "assets/NPCs/ghost1.png", x: 0, y: 0, w: 26, h: 36, scale: 2, layout:"rpg" } },
    ladyboo: { id: "ladyboo", name: "Lady Boo", role: "Archivist · former socialite", line: "I died before streaming. Explain it slowly.", avatar: "🕯", sprite: { sheet: "assets/NPCs/ghost2.png", x: 0, y: 0, w: 52, h: 72, scale: 1, layout:"rpg" } },
    pip: { id: "pip", name: "Pip Polter", role: "Handyperson · wall resident", line: "The pipes only scream when they feel ignored.", avatar: "🔧", sprite: { sheet: "assets/NPCs/ghost3.png", x: 0, y: 0, w: 78, h: 108, scale: 1, layout:"rpg" } },
    pigford: { id: "pigford", name: "Alistair Pigford", role: "Farmer · zoning activist", line: "The tomatoes have unionized. Frankly, I respect it.", avatar: "🐷", sprite: { sheet: "assets/Ranch Stuff/assets/animals/pigs/pig_01/purple/idle/pig_01_purple_idle_down_32x32.png", x: 0, y: 0, w: 32, h: 32, scale: 3 } },
    petunia: { id: "petunia", name: "Petunia Pigford", role: "Seed librarian · pig", line: "Please return the radish seeds alphabetized.", avatar: "🌱", sprite: { sheet: "assets/Ranch Stuff/assets/animals/pigs/pig_01/black/idle/pig_01_black_idle_down_32x32.png", x: 0, y: 0, w: 32, h: 32, scale: 3 } },
    bramble: { id: "bramble", name: "Ranger Bramble", role: "Farmhand · weather skeptic", line: "Rain is just sky irrigation with branding.", avatar: "🌾", sprite: { sheet: "assets/NPCs/RMMV/beast_hero_3.png", x: 0, y: 0, w: 78, h: 108, scale: 1, layout:"rpg" } },
    maize: { id: "maize", name: "Maize Calavera", role: "Crop artist · skeleton", line: "The corn maze is conceptual this year.", avatar: "🌽", sprite: { sheet: "assets/NPCs/day_of_the_dead/dotd_skeletonsheet_3.png", x: 234, y: 0, w: 78, h: 108, scale: 1, layout:"rpg" } },
    toma: { id: "toma", name: "Toma Verde", role: "Market gardener · optimist", line: "That tomato is not ripe. It is emotionally available.", avatar: "🍅", sprite: { sheet: "assets/NPCs/day_of_the_dead/dotd_skeletonsheet_2.png", x: 468, y: 0, w: 52, h: 72, scale: 1.5, layout:"rpg" } },
    jacko: { id: "jacko", name: "Jack O’Lantern", role: "Trail guide · seasonal employee", line: "Every trail is scenic if your head produces light.", avatar: "🎃", sprite: { sheet: "assets/NPCs/horseman/jacko_a_1.png", x: 0, y: 0, w: 26, h: 36, scale: 2, layout:"rpg" } }
    ,wolfgang:{id:"wolfgang",name:"Wolfgang Gearfang",role:"Guild clerk · werewolf",line:"Please initial the moonlight accommodation form.",avatar:"🐺",sprite:{sheet:"assets/Topdown Monsters Part 1/00.png",x:0,y:0,w:80,h:80,sheetWidth:640,displayHeight:88,layout:"actionRows",idleFrames:6,walkFrames:8}}
    ,bronzewick:{id:"bronzewick",name:"Bronzewick",role:"Treasurer · stone golem",line:"The budget is balanced. I am also balanced.",avatar:"🗿",sprite:{sheet:"assets/Topdown Monsters Part 1/01.png",x:0,y:0,w:80,h:80,sheetWidth:640,displayHeight:88,layout:"actionRows",idleFrames:6,walkFrames:8}}
    ,mosswell:{id:"mosswell",name:"Mosswell",role:"Mutual-aid cook · ogre",line:"Soup portions are equal. Bowls are not.",avatar:"🥣",sprite:{sheet:"assets/Topdown Monsters Part 1/02.png",x:0,y:0,w:80,h:80,sheetWidth:640,displayHeight:88,layout:"actionRows",idleFrames:6,walkFrames:8}}
    ,thimblewick:{id:"thimblewick",name:"Thimblewick",role:"Market steward · goblin",line:"The scale is honest. The mushrooms are evasive.",avatar:"🏮",sprite:{sheet:"assets/Topdown Monsters Part 1/03.png",x:0,y:0,w:80,h:80,sheetWidth:640,displayHeight:88,layout:"actionRows",idleFrames:6,walkFrames:8}}
    ,magenta:{id:"magenta",name:"Madame Magenta",role:"Cloth merchant · horned tailor",line:"Revolutionary blue is out. Civic plum is in.",avatar:"🧵",sprite:{sheet:"assets/Topdown Monsters Part 1/04.png",x:0,y:0,w:80,h:80,sheetWidth:640,displayHeight:88,layout:"actionRows",idleFrames:6,walkFrames:8}}
    ,pipkin:{id:"pipkin",name:"Pipkin Coil",role:"Produce seller · pumpkinkin",line:"No, I am not seasonal inventory.",avatar:"🎃",sprite:{sheet:"assets/Topdown Monsters Part 1/05.png",x:0,y:0,w:80,h:80,sheetWidth:640,displayHeight:88,layout:"actionRows",idleFrames:6,walkFrames:8}}
    ,rusty:{id:"rusty",name:"Rusty Quill",role:"Bathhouse engineer · emberling",line:"The boiler is meant to whistle. Usually.",avatar:"🔧",sprite:{sheet:"assets/Topdown Monsters Part 1/06.png",x:0,y:0,w:80,h:80,sheetWidth:640,displayHeight:88,layout:"actionRows",idleFrames:6,walkFrames:8}}
    ,azul:{id:"azul",name:"Azul Frost",role:"Cold-pool attendant · elemental",line:"Hot side to the left. Existential mist straight ahead.",avatar:"❄",sprite:{sheet:"assets/Topdown Monsters Part 1/07.png",x:0,y:0,w:80,h:80,sheetWidth:640,displayHeight:88,layout:"actionRows",idleFrames:6,walkFrames:8}}
    ,rook:{id:"rook",name:"Rook Cinder",role:"Steam-room host · firebird",line:"Hydrate before philosophizing in the steam.",avatar:"♨",sprite:{sheet:"assets/Topdown Monsters Part 1/09.png",x:0,y:0,w:80,h:80,sheetWidth:640,displayHeight:88,layout:"actionRows",idleFrames:6,walkFrames:8}}
    ,copper:{id:"copper",name:"Copper Quickstep",role:"Platform runner · courier",line:"I can deliver it yesterday for an extra stamp.",avatar:"✉",sprite:{sheet:"assets/Topdown Monsters Part 1/08.png",x:0,y:0,w:80,h:80,sheetWidth:640,displayHeight:88,layout:"actionRows",idleFrames:6,walkFrames:8}}
    ,sprocket:{id:"sprocket",name:"Sir Sprocket",role:"Station marshal · automaton",line:"The 4:15 is on time in at least one timeline.",avatar:"⚙",sprite:{sheet:"assets/Topdown Monsters Part 1/10.png",x:0,y:0,w:80,h:80,sheetWidth:640,displayHeight:88,layout:"actionRows",idleFrames:6,walkFrames:8}}
    ,switchboard:{id:"switchboard",name:"Sally Switchboard",role:"Signal operator · ghost",line:"I only pass through walls when the stairs are busy.",avatar:"☎",sprite:{sheet:"assets/NPCs/ghost3.png",x:0,y:0,w:78,h:108,scale:1,layout:"rpg"}}
    ,milo:{id:"milo",name:"Milo Puddlejump",role:"Village student · bug collector",line:"I found a beetle with excellent civic instincts.",avatar:"🪲",sprite:{directions:"assets/NPCs/Cozy Village NPC Collection Vol.1/1._Village_Kid_FREE/rotations/"}}
    ,agnes:{id:"agnes",name:"Agnes Almanac",role:"Village elder · oral historian",line:"I remember three versions of that story. Yours is the loudest.",avatar:"📜",sprite:{directions:"assets/NPCs/Cozy Village NPC Collection Vol.1/10._Village_Elder/rotations/"}}
    ,nell:{id:"nell",name:"Nell Woolward",role:"Shepherd · amateur astronomer",line:"The sheep prefer the evening star. I have data.",avatar:"🐑",sprite:{directions:"assets/NPCs/Cozy Village NPC Collection Vol.1/11._Shepherd_Girl/rotations/"}}
    ,amos:{id:"amos",name:"Amos Turnrow",role:"Farmer · soil correspondent",line:"The west field sends its regards and requests compost.",avatar:"🌱",sprite:{directions:"assets/NPCs/Cozy Village NPC Collection Vol.1/2._Village_Farmer/rotations/"}}
    ,mabel:{id:"mabel",name:"Mabel Grounds",role:"Café owner · neighborhood anchor",line:"Sit first. Solve the republic after breakfast.",avatar:"☕",sprite:{directions:"assets/NPCs/Cozy Village NPC Collection Vol.1/3._Caf_Owner/rotations/"}}
    ,florian:{id:"florian",name:"Florian Crumb",role:"Village baker · dawn worker",line:"The starter keeps earlier hours than Congress.",avatar:"🥖",sprite:{directions:"assets/NPCs/Cozy Village NPC Collection Vol.1/4._Village_Baker/rotations/"}}
    ,posey:{id:"posey",name:"Posey Bell",role:"Flower gardener · bee mediator",line:"The bees accepted the zoning change conditionally.",avatar:"🌼",sprite:{directions:"assets/NPCs/Cozy Village NPC Collection Vol.1/5._Flower_Gardener/rotations/"}}
    ,finn:{id:"finn",name:"Finn Ripple",role:"Fisher · river steward",line:"The river is running bright. The trout remain noncommittal.",avatar:"🎣",sprite:{directions:"assets/NPCs/Cozy Village NPC Collection Vol.1/6._Fisherman/rotations/"}}
    ,ada:{id:"ada",name:"Ada Anvil",role:"Blacksmith · repair co-op lead",line:"If it sparks before I hit it, that costs extra.",avatar:"🔨",sprite:{directions:"assets/NPCs/Cozy Village NPC Collection Vol.1/7._Village_Blacksmith/rotations/"}}
    ,mercer:{id:"mercer",name:"Mercer Roam",role:"Traveling merchant · route gossip",line:"I sell necessities and one deeply unnecessary hat.",avatar:"🎒",sprite:{directions:"assets/NPCs/Cozy Village NPC Collection Vol.1/8._Traveling_Merchant/rotations/"}}
    ,elodie:{id:"elodie",name:"Elodie Quire",role:"Librarian · quiet revolutionary",line:"The overdue fee may be paid in useful marginalia.",avatar:"📚",sprite:{directions:"assets/NPCs/Cozy Village NPC Collection Vol.1/9._Librarian/rotations/"}}
    ,aero:{id:"aero",name:"Aero Naught",role:"Balloon pilot · weather courier",line:"The wind filed a change of address.",avatar:"🎈",sprite:{sheet:"assets/quirky npcs/fullcolor/aeronaut.png",x:0,y:0,w:46,h:66,sheetWidth:138,displayHeight:82,layout:"strip",frameCount:3,contentBounds:[7,6,27,59]}}
    ,conductor:{id:"conductor",name:"Connie Ductor",role:"Rail conductor · baton enthusiast",line:"All aboard means everyone, Mr. Franklin.",avatar:"🚂",sprite:{sheet:"assets/quirky npcs/fullcolor/conductor.png",x:0,y:0,w:46,h:48,sheetWidth:138,displayHeight:70,layout:"directionRects",directionRects:{south:[46,0,46,48],west:[0,0,46,48],east:[92,0,46,48],north:[46,96,46,48]}}}
    ,emberwing:{id:"emberwing",name:"Emberwing",role:"Bathhouse dragon · towel warmer",line:"Small flame. Responsible flame. Mostly.",avatar:"🐉",sprite:{sheet:"assets/Baby Dragon/Sprites/outline/MOVE.png",x:0,y:0,w:158,h:125,sheetWidth:632,displayHeight:72,layout:"strip",frameCount:4}}
    ,scraps:{id:"scraps",name:"Scraps",role:"Station rat · lost-property finder",line:"Squeak. That is legally a receipt.",avatar:"🐀",sprite:{sheet:"assets/haydeos/Ferrum Junkyard Heroes/Junkyard Heroes/characters/$TrashRat.png",x:0,y:0,w:48,h:48,sheetWidth:144,displayHeight:58,layout:"rpg"}}
    ,clank:{id:"clank",name:"Clank",role:"Town repair robot · learning jokes",line:"Knock knock. Maintenance request detected.",avatar:"🤖",sprite:{walkFrames:"assets/Bots and Bolts 2D robot/Character",displayHeight:62}}
    ,whistle:{id:"whistle",name:"Whistle",role:"Ranger's wolf · trail finder",line:"A soft huff, followed by a very official tail wag.",avatar:"🐺",sprite:{sheet:"assets/haydeos/High Fantasy Heroes/High Fantasy Heroes/characters/$Wolf.png",x:0,y:0,w:48,h:48,sheetWidth:144,displayHeight:52,layout:"rpg"}}
    ,marmalade:{id:"marmalade",name:"Marmalade",role:"Market cat · quality inspector",line:"Mrrp. The fish stall has passed inspection again.",avatar:"🐈",sprite:{sheet:"assets/quirky npcs/fullcolor/coolcat.png",x:0,y:0,w:46,h:48,sheetWidth:138,displayHeight:54}}
  };

  const ROSTERS = {
    cafe: ["juniper", "lola", "rowan"],
    lab: ["mara", "briar", "mort"],
    restaurant: ["chef", "claudia", "basil"],
    club: ["nocturne", "countess", "vee"],
    mansion: ["gus", "ladyboo", "pip"],
    farm: ["maize", "toma", "bramble"],
    ranch: ["pigford", "petunia", "jacko"]
    ,arcade: ["nocturne", "vee", "countess"]
    ,conservatory: ["briar", "toma", "mara"]
    ,skyhouse: ["aero", "bramble", "pip"]
    ,guildhall:["wolfgang","bronzewick","mosswell"]
    ,market:["thimblewick","magenta","pipkin"]
    ,elementalbaths:["azul","rusty","rook"]
    ,clockstation:["sprocket","copper","switchboard"]
  };

  const NPC_LIFE = {
    milo:{home:"farm",job:"guildhall",leisure:"market"},agnes:{home:"mansion",job:"guildhall",leisure:"cafe"},nell:{home:"ranch",job:"ranch",leisure:"conservatory"},
    amos:{home:"farm",job:"farm",leisure:"market"},mabel:{home:"cafe",job:"cafe",leisure:"guildhall"},florian:{home:"cafe",job:"restaurant",leisure:"market"},
    posey:{home:"farm",job:"conservatory",leisure:"cafe"},finn:{home:"ranch",job:"ranch",leisure:"market"},ada:{home:"clockstation",job:"clockstation",leisure:"guildhall"},
    mercer:{home:"market",job:"market",leisure:"cafe"},elodie:{home:"guildhall",job:"guildhall",leisure:"conservatory"},aero:{home:"skyhouse",job:"skyhouse",leisure:"club"},
    conductor:{home:"clockstation",job:"clockstation",leisure:"restaurant"},emberwing:{home:"elementalbaths",job:"elementalbaths",leisure:"ranch"},scraps:{home:"clockstation",job:"clockstation",leisure:"market"},
    clank:{home:"lab",job:"clockstation",leisure:"arcade"},whistle:{home:"ranch",job:"conservatory",leisure:"farm"},marmalade:{home:"market",job:"market",leisure:"cafe"}
  };

  const SOCIAL_TIES = [
    ["juniper","lola","best friends"],["mara","briar","siblings"],["pigford","petunia","family"],["nocturne","countess","creative partners"],["gus","pip","housemates"],
    ["wolfgang","bronzewick","guild partners"],["bronzewick","mosswell","old friends"],["thimblewick","magenta","market neighbors"],["pipkin","milo","foraging friends"],
    ["azul","rusty","work partners"],["rusty","rook","friendly rivals"],["sprocket","conductor","rail colleagues"],["copper","aero","courier friends"],["switchboard","elodie","book-club friends"],
    ["mabel","florian","breakfast partners"],["amos","nell","neighbors"],["posey","briar","garden colleagues"],["finn","bramble","weather friends"],["ada","clank","repair partners"],
    ["mercer","thimblewick","trade partners"],["emberwing","rook","found family"],["scraps","clank","workshop companions"],["agnes","milo","mentor and student"],
    ["whistle","bramble","ranger and companion"],["marmalade","mercer","market companions"],["whistle","marmalade","cautious friends"]
  ].map(([a,b,type])=>({a,b,type}));

  const LEVEL_THEMES = {
    cafe: {
      floor: ["assets/Cafe Assets/Floor, walls-Photoroom.png", 46, 64, 72, 72], tint: "#9a653d",
      props: [
        ["assets/Cafe Assets/Counters, bar pieces and service stations-Photoroom.png", 70, 45, 210, 150, 45, 92, 235, 168],
        ["assets/Cafe Assets/Counters, bar pieces and service stations-Photoroom.png", 80, 260, 195, 130, 270, 108, 220, 146],
        ["assets/Cafe Assets/Counters, bar pieces and service stations-Photoroom.png", 65, 630, 165, 185, 810, 72, 145, 165],
        ["assets/Cafe Assets/Tables, chairs and sitting-Photoroom.png", 75, 380, 180, 155, 105, 360, 175, 150],
        ["assets/Cafe Assets/Tables, chairs and sitting-Photoroom.png", 745, 65, 200, 145, 410, 370, 190, 138],
        ["assets/Cafe Assets/Tables, chairs and sitting-Photoroom.png", 1190, 65, 150, 145, 690, 380, 145, 138],
        ["assets/Cafe Assets/Counters, bar pieces and service stations-Photoroom.png", 1240, 630, 210, 175, 883, 305, 180, 150]
      ]
    },
    lab: {
      floor: ["assets/Modern Laboratory Assets/1.png", 0, 0, 48, 48], tint: "#dce4e8",
      props: [
        ["assets/Modern Laboratory Assets/2.png", 0, 0, 192, 190, 69, 80, 192, 190],
        ["assets/Modern Laboratory Assets/2.png", 385, 190, 285, 105, 390, 95, 310, 115],
        ["assets/Modern Laboratory Assets/2.png", 480, 575, 285, 190, 755, 65, 290, 195],
        ["assets/Modern Laboratory Assets/2.png", 385, 385, 285, 95, 405, 430, 300, 100]
      ]
    },
    restaurant: {
      floor: ["assets/Modern Restaurant/2.png", 288, 96, 96, 96], tint: "#c99d70",
      props: [
        ["assets/Modern Restaurant/2.png", 0, 0, 285, 190, 45, 85, 285, 190],
        ["assets/Cafe Assets/Tables, chairs and sitting-Photoroom.png", 326, 421, 197, 100, 336, 340, 394, 200],
        ["assets/Modern Restaurant/2.png", 385, 190, 380, 285, 700, 70, 360, 270],
        ["assets/Modern Restaurant/2.png", 0, 95, 285, 95, 60, 430, 270, 90]
      ]
    },
    club: {
      floor: null, tint: "#5b355c",
      props: [
        ["assets/Modern Bar & Nightclub/2.png", 0, 190, 385, 195, 40, 75, 350, 180],
        ["assets/Modern Bar & Nightclub/2.png", 195, 0, 190, 190, 430, 70, 210, 210],
        ["assets/Modern Bar & Nightclub/2.png", 480, 385, 285, 95, 730, 80, 320, 105],
        ["assets/Modern Bar & Nightclub/2.png", 195, 480, 285, 190, 743, 340, 264, 176]
      ]
    },
    mansion: {
      floor: null, tint: "#554b55",
      props: [
        ["assets/Haunted Mansion/2.png", 388, 0, 90, 100, 55, 82, 135, 150],
        ["assets/Haunted Mansion/2.png", 575, 7, 193, 92, 185, 102, 245, 117],
        ["assets/Haunted Mansion/2.png", 386, 108, 188, 88, 442, 106, 245, 115],
        ["assets/Haunted Mansion/2.png", 584, 189, 184, 198, 820, 64, 220, 237],
        ["assets/Haunted Mansion/2.png", 421, 677, 214, 86, 420, 420, 278, 112, 0, false],
        ["assets/Haunted Mansion/2.png", 393, 389, 76, 78, 480, 276, 152, 156, 2, false]
      ]
    },
    farm: {
      floor: null, tint: "#75a75c", outdoor: true,
      props: [
        ["assets/Farm Assets/farm/2.png", 2, 0, 189, 144, 30, 30, 378, 288],
        ["assets/Farm Assets/farm/4.png", 4, 3, 89, 93, 455, 80, 178, 186],
        ["assets/Farm Assets/farm/6.png", 1, 2, 148, 142, 760, 40, 296, 284],
        ["assets/Farm Assets/farm/5.png", 2, 385, 141, 140, 409, 450, 282, 280]
      ]
    },
    ranch: {
      floor: null, tint: "#6f9857", outdoor: true,
      props: [
        ["assets/Farm Assets/farm/2.png", 385, 0, 190, 145, 30, 35, 380, 290],
        ["assets/Ranch Stuff/assets/animals/cows/cow_01/brown_pink/idle/cow_01_brown_pink_idle_down_32x32.png", 0, 0, 32, 32, 510, 150, 128, 128],
        ["assets/Farm Assets/farm/2.png", 577, 395, 45, 52, 820, 100, 135, 156],
        ["assets/Ranch Stuff/assets/animals/pigs/pig_01/purple/idle/pig_01_purple_idle_down_32x32.png", 0, 0, 32, 32, 520, 390, 72, 72],
        ["assets/Ranch Stuff/assets/animals/pigs/pig_01/black/idle/pig_01_black_idle_down_32x32.png", 0, 0, 32, 32, 850, 390, 72, 72]
      ]
    },
    arcade: {
      floor:null, tint:"#26374c",
      props:[
        ["assets/More Tilesets/XModern Arcade/master.png",160,48,128,64,38,76,320,160],
        ["assets/More Tilesets/XModern Arcade/master.png",303,111,50,75,473,64,150,225],
        ["assets/More Tilesets/XModern Arcade/master.png",515,195,41,30,770,74,287,210],
        ["assets/More Tilesets/XModern Arcade/master.png",304,196,48,66,478,402,144,198]
      ]
    },
    conservatory: {
      floor:null, tint:"#739a62",
      props:[
        ["assets/More Tilesets/Flying Islands/PNG/Objects_separately/Tree1_1.png",17,12,94,104,60,64,235,260],
        ["assets/More Tilesets/Fantasy Structures & Props - Pixel Art Asset Pack/fsp_prop-mushroom-crate.png",0,0,112,96,412,80,252,216],
        ["assets/More Tilesets/Flying Islands/PNG/Objects_separately/Tree2_1.png",33,13,62,102,850,64,155,255],
        ["assets/More Tilesets/Flying Islands/PNG/Objects_separately/Plant2_1.png",11,1,42,61,487,390,126,183]
      ]
    },
    skyhouse: {
      floor:null, tint:"#8dc6c8", outdoor:true,
      props:[
        ["assets/More Tilesets/Flying Islands/PNG/Objects_separately/Cloud_color1_1.png",11,86,233,84,44,502,330,119,0,false],
        ["assets/More Tilesets/Flying Islands/PNG/Objects_separately/Ruins_grass_shadow1.png",22,16,83,96,116,96,158,183],
        ["assets/More Tilesets/Flying Islands/PNG/Objects_separately/Plant1_1.png",24,21,79,86,470,102,150,163],
        ["assets/More Tilesets/Flying Islands/PNG/Objects_separately/Crystael1.png",13,4,38,55,888,128,84,122],
        ["assets/More Tilesets/Flying Islands/PNG/Objects_separately/Dragon_small.png",45,70,165,115,410,350,280,195,2,false]
      ]
    },
    guildhall:{
      floor:null,tint:"#344b51",
      props:[
        ["assets/More Tilesets/Fantasy Structures & Props - Pixel Art Asset Pack/fsp_prop-bookshelf.png",0,0,96,96,52,76,170,170],
        ["assets/More Tilesets/Fantasy Structures & Props - Pixel Art Asset Pack/fsp_prop-rune-table.png",0,0,192,112,398,92,270,158],
        ["assets/More Tilesets/Fantasy Structures & Props - Pixel Art Asset Pack/fsp_prop-wardrobe.png",0,0,80,96,880,74,140,168],
        ["assets/More Tilesets/Fantasy Structures & Props - Pixel Art Asset Pack/fsp_prop-alchemy-table.png",0,0,160,96,400,418,280,168],
        ["assets/More Tilesets/Fantasy Structures & Props - Pixel Art Asset Pack/fsp_prop-bear-rug.png",0,0,128,128,756,388,220,220,0,false],
        ["assets/More Tilesets/Fantasy Structures & Props - Pixel Art Asset Pack/fsp_prop-antler-chandelier.png",0,0,112,112,462,32,180,180,2,false]
      ]
    },
    market:{
      floor:null,tint:"#9f704c",outdoor:true,
      props:[
        ["assets/More Tilesets/Medieval Fantasy Town Pixel Art Tileset Pack/11.png",0,0,96,96,42,76,216,216],
        ["assets/More Tilesets/Medieval Fantasy Town Pixel Art Tileset Pack/11.png",192,96,96,96,432,74,216,216],
        ["assets/More Tilesets/Medieval Fantasy Town Pixel Art Tileset Pack/11.png",0,288,96,96,828,76,216,216],
        ["assets/More Tilesets/Medieval Fantasy Town Pixel Art Tileset Pack/11.png",0,192,384,96,334,420,432,108]
      ]
    },
    elementalbaths:{
      floor:null,tint:"#704b49",
      props:[
        ["assets/More Tilesets/ICE CAVERN/Dungeon_B ICE CAVERN.png",427,516,58,63,70,80,174,189],
        ["assets/More Tilesets/ICE CAVERN/!Animated CRYSTALs.png",0,48,48,48,106,400,144,144],
        ["assets/More Tilesets/Volcanic/13. Decorations.png",926,190,132,174,820,56,198,261],
        ["assets/More Tilesets/Volcanic/17. Bridges and walkways.png",689,167,152,156,398,295,304,312,0,false]
      ]
    },
    clockstation:{
      floor:null,tint:"#5e4938",
      props:[
        ["assets/More Tilesets/Steampunk Pixel Art Tileset/7.png",0,390,384,186,30,100,384,186],
        ["assets/More Tilesets/Steampunk Pixel Art Tileset/8.png",384,680,180,88,408,110,315,154],
        ["assets/More Tilesets/Steampunk Pixel Art Tileset/9.png",0,0,96,192,868,58,120,240],
        ["assets/More Tilesets/Steampunk Pixel Art Tileset/10.png",528,7,240,185,696,398,288,222,2,false]
      ]
    }
  };

  const VIRTUES = [
    { id: "temperance", name: "Temperance", icon: "◒", maxim: "Fuel the work; leave room for tomorrow." },
    { id: "silence", name: "Silence", icon: "◌", maxim: "Say only what helps; listen past the punchline." },
    { id: "order", name: "Order", icon: "▦", maxim: "Give every tool, promise, and pig route a place." },
    { id: "resolution", name: "Resolution", icon: "◆", maxim: "Do what you said you would do." },
    { id: "frugality", name: "Frugality", icon: "¢", maxim: "Waste nothing that can serve the public good." },
    { id: "industry", name: "Industry", icon: "⚙", maxim: "Lose no time; make the hour useful." },
    { id: "sincerity", name: "Sincerity", icon: "◇", maxim: "Speak plainly, kindly, and without schemes." },
    { id: "justice", name: "Justice", icon: "⚖", maxim: "Help fairly; harm no one for convenience." },
    { id: "moderation", name: "Moderation", icon: "↔", maxim: "Avoid extremes—even historically accurate ones." },
    { id: "cleanliness", name: "Cleanliness", icon: "✦", maxim: "Keep body, tools, and lightning rods in order." },
    { id: "tranquillity", name: "Tranquillity", icon: "≈", maxim: "Do not be rattled by trifles or ghosts." },
    { id: "chastity", name: "Chastity", icon: "○", maxim: "Respect intimacy, privacy, and every boundary." },
    { id: "humility", name: "Humility", icon: "↓", maxim: "Learn from everyone; save room to be wrong." }
  ];

  const ACTION_VIRTUES = {
    pickup: "resolution", deliver: "resolution", nap: "temperance",
    barista: "industry", counsel: "silence", pastry: "temperance",
    tinker: "industry", intern: "order", hexchat: "sincerity",
    serve: "frugality", meal: "moderation", kitchen: "justice",
    garden: "industry", pigchat: "tranquillity", forage: "frugality",
    inspect: "cleanliness", seance: "justice", dust: "order",
    openmic: "silence", dance: "humility", bartend: "chastity",
    groom: "tranquillity", irrigate: "resolution", trailride: "resolution"
  };

  const EXPLORATION_SCENES = {
    cafe: [
      { id: "press-counter", name: "Press Counter", npcId: "juniper", art: "assets/Cafe Assets/Patch 1/Demo elements.png", artPosition: "48% 50%", virtue: "industry", description: "Juniper cleared the breakfast rush just enough for Ben’s compact printing press.", discovery: "Ben spots a movable-type drawer beneath the espresso machine: perfect for a daily civic broadsheet, provided nobody sets a latte on the vowels." },
      { id: "pastry-alcove", name: "Pastry Alcove", npcId: "lola", art: "assets/Cafe Assets/Patch 1/Coffee, bakery and flowers.png", artPosition: "52% 43%", virtue: "temperance", description: "Lola tests pastries beside Ben’s suspiciously scientific insulated mug.", discovery: "The display case holds one cracked Liberty Bell tart. Ben records that restraint is easier before the second pastry." },
      { id: "reading-corner", name: "Reading Corner", npcId: "rowan", art: "assets/Cafe Assets/Masive Update 2.0 (+1000 assets)/Books and magazines update 2.png", artPosition: "55% 47%", virtue: "silence", description: "Rowan’s poetry table doubles as the modern Junto’s listening corner.", discovery: "A community suggestion box contains twelve good ideas and one request for louder blenders. Ben reads before replying." }
    ],
    lab: [
      { id: "conductivity-bench", name: "Conductivity Bench", npcId: "mara", art: "assets/Modern Laboratory Assets/1.png", artPosition: "74% 42%", virtue: "order", description: "Dr. Hex has labeled every conductor except the one currently humming.", discovery: "Ben redraws the bench as a clean circuit: source, conductor, load, ground. The humming wire finally receives a label." },
      { id: "greenhouse-annex", name: "Greenhouse Annex", npcId: "briar", art: "assets/Modern Laboratory Assets/4.png", artPosition: "42% 55%", virtue: "cleanliness", description: "Briar grows storm-resistant plants around a very washable work surface.", discovery: "Sap on the contacts explains the erratic sensor. Ben cleans the instrument before blaming atmospheric electricity." },
      { id: "safety-office", name: "Safety Office", npcId: "mort", art: "assets/Modern Laboratory Assets/7.png", artPosition: "58% 36%", virtue: "resolution", description: "Mort keeps the inspection forms, grounding clamps, and emergency tea.", discovery: "An unsigned lightning-rod audit waits on the desk. Ben signs his name and schedules the repair instead of admiring the problem." }
    ],
    restaurant: [
      { id: "stove-line", name: "Stove Line", npcId: "chef", art: "assets/Modern Restaurant/1.png", artPosition: "48% 27%", virtue: "frugality", description: "Chef Howl wants more heat, less fuel, and no lecture longer than soup service.", discovery: "The flue wastes enough heat to warm the alley. Ben sketches a baffle inspired by his Franklin stove." },
      { id: "community-table", name: "Community Table", npcId: "claudia", art: "assets/Modern Restaurant/4.png", artPosition: "50% 48%", virtue: "moderation", description: "Clawdia is seating rival committees at one long, diplomatically neutral table.", discovery: "Two factions want opposite menus. Ben proposes shared bread, separate sauces, and no speeches until dessert." },
      { id: "host-stand", name: "Host Stand", npcId: "basil", art: "assets/Modern Restaurant/5.png", artPosition: "48% 38%", virtue: "sincerity", description: "Basil’s reservation book predicts conflict with unsettling accuracy.", discovery: "A VIP demands a table promised to a family. Ben advises the radical policy of saying exactly what happened and honoring the first promise." }
    ],
    club: [
      { id: "armonica-stage", name: "Armonica Stage", npcId: "nocturne", art: "assets/Modern Bar & Nightclub/1.png", artPosition: "52% 38%", virtue: "silence", description: "DJ Nocturne has left a quiet frequency in the set for Ben’s glass armonica.", discovery: "Ben listens to the room’s pulse before touching the glasses. The best note turns out to begin with silence." },
      { id: "reenactment-floor", name: "Reenactment Floor", npcId: "countess", art: "assets/Modern Bar & Nightclub/4.png", artPosition: "46% 54%", virtue: "humility", description: "Countess BPM has costumes for an entire Revolution and a cast of exactly one founder.", discovery: "The least glamorous role is ‘muddy road.’ Ben accepts it, then adds a historically questionable flying kick." },
      { id: "mocktail-bar", name: "Mocktail Bar", npcId: "vee", art: "assets/Modern Bar & Nightclub/6.png", artPosition: "55% 43%", virtue: "chastity", description: "Vee runs a civic salon where introductions require consent and drinks remain nonpartisan.", discovery: "A guest declines an introduction. Ben respects the boundary, redirects the conversation, and saves everyone an awkward committee meeting." }
    ],
    mansion: [
      { id: "fuse-hall", name: "Fuse Hall", npcId: "gus", art: "assets/Haunted Mansion/1.png", artPosition: "48% 42%", virtue: "cleanliness", description: "Gus reports spectral flickering; Ben reports sixty years of dust in the fuse box.", discovery: "Once the contacts are cleaned, half the haunting disappears. Gus calls this invalidating but appreciates the safer wiring." },
      { id: "archive-gallery", name: "Archive Gallery", npcId: "ladyboo", art: "assets/Haunted Mansion/3.png", artPosition: "45% 44%", virtue: "order", description: "Lady Boo guards a century of letters filed under ‘dramatic’ and ‘more dramatic.’",
        discovery: "Ben sorts the papers by date, author, and civic usefulness. One love letter is respectfully returned to the private drawer." },
      { id: "tenant-parlor", name: "Tenant Parlor", npcId: "pip", art: "assets/Haunted Mansion/5.png", artPosition: "52% 48%", virtue: "justice", description: "Pip has assembled living and spectral tenants for a maintenance compact.", discovery: "The ghosts cannot sign the repair petition, so Ben adds a witnessed voice-vote clause. Representation improves immediately." }
    ],
    farm: [
      { id: "almanac-rows", name: "Almanac Rows", npcId: "maize", art: "assets/Farm Assets/farm/1.png", artPosition: "30% 18%", virtue: "industry", description: "Maize has turned Ben’s planting notes into rows, charts, and one conceptual corn spiral.", discovery: "The soil is ready two days earlier than the old almanac predicts. Ben updates the notes instead of arguing with the radishes." },
      { id: "market-beds", name: "Market Beds", npcId: "toma", art: "assets/Farm Assets/farm/4.png", artPosition: "52% 46%", virtue: "frugality", description: "Toma saves every usable seed and every tomato with public-relations potential.", discovery: "Bent stakes from last season can support this year’s beans. Ben marks them ‘proven technology’ and spends nothing." },
      { id: "weather-shed", name: "Weather Shed", npcId: "bramble", art: "assets/Farm Assets/farm/7.png", artPosition: "56% 38%", virtue: "tranquillity", description: "Bramble compares Ben’s barometer with the pigs’ considerably louder forecast.", discovery: "The pressure falls, the pigs complain, and nobody panics. Ben records rain and secures the loose tools." }
    ],
    ranch: [
      { id: "kite-paddock", name: "Kite Paddock", npcId: "pigford", art: "assets/Ranch Stuff/Super_retro_world_water_animation/SuperRetro_Banner_Tileset.png", artPosition: "18% 26%", backgroundSize: "720px", virtue: "moderation", description: "Pigford’s enrichment paddock has low kites, short strings, and very firm altitude rules.", discovery: "Ben shortens the kite line after a pig attempts aviation. Useful amusement, he notes, still needs limits." },
      { id: "seed-library", name: "Seed Library", npcId: "petunia", art: "assets/Ranch Stuff/Super_retro_world_water_animation/SuperRetro_Banner_Tileset.png", artPosition: "72% 42%", backgroundSize: "760px", virtue: "resolution", description: "Petunia tracks seeds and postal satchels with equal seriousness.", discovery: "A promised radish packet is still on Ben’s route card. He moves it to the top rather than inventing a more exciting delivery." },
      { id: "postal-trail", name: "Postal Trail", npcId: "jacko", art: "assets/Ranch Stuff/Super_retro_world_water_animation/SuperRetro_Banner_Tileset.png", artPosition: "86% 84%", backgroundSize: "680px", virtue: "justice", description: "Jack O’Lantern lights the rural route while Ben checks access to every outlying home.", discovery: "The shortest route skips the smallest farm. Ben chooses the fair route and adds one pig-accessible mailbox." }
    ],
    arcade: [
      { id:"arcade-ground", name:"Cabinet Hall", npcId:"nocturne", art:"assets/More Tilesets/XModern Arcade/master.png", artPosition:"18% 22%", backgroundSize:"850px", virtue:"industry", description:"Rows of restored cabinets hum beneath a hand-lettered electrical code.", discovery:"Ben replaces a fistful of copper pennies with insulated tokens and stops three cabinets from shocking the public." },
      { id:"arcade-mezzanine", name:"Prize Mezzanine", npcId:"vee", art:"assets/More Tilesets/XModern Arcade/fullcolor/xmodern_B2.png", artPosition:"55% 45%", backgroundSize:"780px", virtue:"frugality", description:"The prize counter turns spare parts and impossible tickets into civic rewards.", discovery:"A broken dispenser contains a perfectly useful gear. Ben files it under parts rather than prizes." },
      { id:"arcade-roof", name:"Rooftop Court", npcId:"countess", art:"assets/More Tilesets/XModern Arcade/fullcolor/xmodern_B3.png", artPosition:"78% 30%", backgroundSize:"820px", virtue:"moderation", description:"A rooftop game court shares one lightning rod with an extremely confident neon sign.", discovery:"Ben separates the sign circuit from the grounding line. The high score survives; so does everyone else." }
    ],
    conservatory: [
      { id:"glass-floor", name:"Glasshouse", npcId:"briar", art:"assets/More Tilesets/fairy forest/tf_fairyforest_12.28.20/ff_master_tiles.png", artPosition:"18% 48%", backgroundSize:"900px", virtue:"cleanliness", description:"Warm glass rooms hold medicinal herbs, public seedlings, and one fern on probation.", discovery:"Ben clears the irrigation grate before redesigning it. Water begins moving again without an invention." },
      { id:"mushroom-loft", name:"Mushroom Loft", npcId:"toma", art:"assets/More Tilesets/fairy forest/tf_fairyforest_12.28.20/ff_master_tiles.png", artPosition:"58% 35%", backgroundSize:"920px", virtue:"temperance", description:"Soft lantern mushrooms line a timber loft above the humid beds.", discovery:"One glowing cap is enough to light the stair. Ben leaves the rest growing." },
      { id:"canopy-study", name:"Canopy Study", npcId:"mara", art:"assets/More Tilesets/fairy forest/tf_fairyforest_12.28.20/ff_master_tiles.png", artPosition:"82% 62%", backgroundSize:"920px", virtue:"silence", description:"The upper study opens into a canopy alive with tiny wings and quieter research.", discovery:"Ben waits through a full minute of birdsong before recording the observation. The useful detail arrives last." }
    ],
    skyhouse: [
      { id:"sorting-deck", name:"Sorting Deck", npcId:"aero", art:"assets/More Tilesets/Flying Islands/Tiled_files/Objects.png", artPosition:"22% 24%", backgroundSize:"720px", virtue:"order", description:"Mailbags, cloud charts, and anchor ropes share a windy ground deck.", discovery:"Ben gives every route a hook and every hook a label. Only the clouds remain unsorted." },
      { id:"cloud-office", name:"Cloud Office", npcId:"bramble", art:"assets/More Tilesets/Flying Islands/Tiled_files/Clouds.png", artPosition:"50% 50%", backgroundSize:"760px", virtue:"tranquillity", description:"The middle office studies wind without pretending it can schedule it.", discovery:"A sudden gust scatters the forecast forms. Ben retrieves them in pressure order and declines to take it personally." },
      { id:"aerial-route", name:"Aerial Route", npcId:"pip", art:"assets/More Tilesets/Flying Islands/Tiled_files/Flying_rocks_animation.png", artPosition:"72% 38%", backgroundSize:"780px", virtue:"resolution", description:"A suspended postal platform marks the highest delivery stop in town.", discovery:"The far mailbox is inconvenient, not optional. Ben secures the line and completes the route." }
    ],
    guildhall:[
      {id:"guild-chamber",name:"Assembly Chamber",npcId:"wolfgang",art:"assets/More Tilesets/Fantasy Structures & Props - Pixel Art Asset Pack/fsp_structure-stone-temple1.png",artPosition:"50% 40%",backgroundSize:"620px",virtue:"justice",description:"The town’s unusual citizens hold meetings beneath an extremely literal stone charter.",discovery:"Ben adds a moonlight attendance clause so night-bound residents receive an equal vote."},
      {id:"guild-treasury",name:"Community Treasury",npcId:"bronzewick",art:"assets/More Tilesets/Fantasy Structures & Props - Pixel Art Asset Pack/fsp_prop-chest-overgrown.png",artPosition:"50% 50%",backgroundSize:"430px",virtue:"frugality",description:"Bronzewick keeps the mutual-aid ledger, emergency coins, and load-bearing abacus.",discovery:"Every coin has a purpose. Ben funds the broken ramp before proposing a decorative lightning vane."},
      {id:"guild-kitchen",name:"Mutual-Aid Kitchen",npcId:"mosswell",art:"assets/More Tilesets/Fantasy Structures & Props - Pixel Art Asset Pack/fsp_prop-flame-table.png",artPosition:"50% 45%",backgroundSize:"460px",virtue:"moderation",description:"Mosswell’s cauldron serves every body shape and appetite in the district.",discovery:"Ben redraws the serving chart by need rather than bowl size. The ogre-sized ladle remains nonnegotiable."}
    ],
    market:[
      {id:"market-square",name:"Lantern Square",npcId:"thimblewick",art:"assets/More Tilesets/Medieval Fantasy Town Pixel Art Tileset Pack/7.png",artPosition:"25% 35%",backgroundSize:"760px",virtue:"sincerity",description:"Stalls advertise exactly what they sell, except the mushroom stall, which speaks in riddles.",discovery:"Ben standardizes the weights and leaves the sales patter alone. Honest commerce can still have personality."},
      {id:"cloth-loft",name:"Cloth Loft",npcId:"magenta",art:"assets/More Tilesets/Medieval Fantasy Town Pixel Art Tileset Pack/8.png",artPosition:"55% 45%",backgroundSize:"760px",virtue:"industry",description:"Bolts of civic plum and revolutionary blue climb a narrow merchant loft.",discovery:"Madame Magenta shows Ben a treadle repair faster than his proposed motor. He takes notes."},
      {id:"seed-roof",name:"Rooftop Seed Exchange",npcId:"pipkin",art:"assets/More Tilesets/Medieval Fantasy Town Pixel Art Tileset Pack/9.png",artPosition:"72% 48%",backgroundSize:"760px",virtue:"resolution",description:"Dry rooftop racks hold seeds, herbs, and produce that objects to being called seasonal.",discovery:"Ben returns a promised squash packet before reorganizing the labels. Commitment precedes improvement."}
    ],
    elementalbaths:[
      {id:"frost-pool",name:"Frost Pool",npcId:"azul",art:"assets/More Tilesets/ICE CAVERN/Dungeon_B ICE CAVERN.png",artPosition:"30% 38%",backgroundSize:"760px",virtue:"tranquillity",description:"A cold mineral pool quiets overheated inventions and louder inventors.",discovery:"Ben sits with the cold instead of fixing it. Nothing explodes during this interval."},
      {id:"boiler-gallery",name:"Boiler Gallery",npcId:"rusty",art:"assets/More Tilesets/Volcanic/13. Decorations.png",artPosition:"48% 44%",backgroundSize:"820px",virtue:"cleanliness",description:"Copper pipes route spring water around a boiler with dramatic opinions.",discovery:"Scale in the pressure valve caused the shrieking. Cleaning wins again."},
      {id:"ember-deck",name:"Ember Deck",npcId:"rook",art:"assets/More Tilesets/Volcanic/17. Bridges and walkways.png",artPosition:"65% 42%",backgroundSize:"820px",virtue:"temperance",description:"The upper steam deck is warm enough to soften sealing wax and firm opinions.",discovery:"Rook closes half the vents. More heat was not more hospitality."}
    ],
    clockstation:[
      {id:"ticket-hall",name:"Ticket Hall",npcId:"sprocket",art:"assets/More Tilesets/Steampunk Pixel Art Tileset/7.png",artPosition:"28% 38%",backgroundSize:"760px",virtue:"order",description:"A brass departure board tracks trains, timelines, and one ambitious luggage cart.",discovery:"Ben separates actual departures from aspirational ones. The board becomes less exciting and more useful."},
      {id:"parcel-platform",name:"Parcel Platform",npcId:"copper",art:"assets/More Tilesets/Steampunk Pixel Art Tileset/8.png",artPosition:"52% 42%",backgroundSize:"760px",virtue:"industry",description:"Copper Quickstep sorts local parcels while the pneumatic tubes cough politely.",discovery:"A route loop wastes seven minutes. Ben removes it without claiming to have invented logistics."},
      {id:"signal-tower",name:"Signal Tower",npcId:"switchboard",art:"assets/More Tilesets/Steampunk Pixel Art Tileset/9.png",artPosition:"75% 40%",backgroundSize:"760px",virtue:"silence",description:"Sally listens for distant bells through a wall of switches and speaking tubes.",discovery:"The faint third bell matters most. Ben waits for it before clearing the line."}
    ]
  };

  const ERRANDS = [
    { item: "experimental oat latte", from: "cafe", to: "lab", reward: 14, title: "A Latte for Science", copy: "Juniper made a coffee that can remember passwords. Dr. Hex needs to test it." },
    { item: "haunted sourdough starter", from: "mansion", to: "restaurant", reward: 17, title: "Starter Problems", copy: "Gus found a sourdough starter older than indoor plumbing. Chef Howl wants it." },
    { item: "municipal glow sticks", from: "lab", to: "club", reward: 15, title: "Applied Nightlife", copy: "Dr. Hex has glow sticks with a suspicious half-life. DJ Nocturne signed the waiver." },
    { item: "celebrity tomatoes", from: "farm", to: "cafe", reward: 12, title: "Influencer Produce", copy: "Pigford's tomatoes need a publicist. Juniper has counter space and no standards." },
    { item: "midnight catering tray", from: "restaurant", to: "mansion", reward: 18, title: "Room Service Séance", copy: "The mansion residents have ordered dinner, despite several lacking digestive systems." },
    { item: "signed disco kite", from: "club", to: "ranch", reward: 16, title: "A Kite for the Pigs", copy: "DJ Nocturne autographed a disco kite. Pigford insists this is essential enrichment." },
    { item: "miniature ranch hat", from: "ranch", to: "mansion", reward: 13, title: "A Hat Without a Head", copy: "Jack found a tiny ranch hat. Gus knows a tenant with the correct lack of dimensions." },
    { item: "moon-water canteen", from: "lab", to: "ranch", reward: 19, title: "Hydration by Moonlight", copy: "Dr. Hex bottled moonlight for the ranch animals. Petunia requested extra electrolytes." }
  ];

  const HEADLINES = [
    "Local Founding Father Seeks Work-Life Balance",
    "Town Council Approves ‘Vibes-Based’ Zoning",
    "Kite Seen Circling Lab; Scientist Says ‘Normal’",
    "Farm-to-Table Debate Ends in Snack Break",
    "Ghost Files Noise Complaint Against Himself",
    "Ben Franklin Discovers Group Chat, Regrets Everything",
    "Weather App Predicts ‘Historically Interesting’",
    "Restaurant Adds Brunch Clause to Constitution",
    "Nightclub Installs Lightning Rod, Doubles Attendance",
    "Civic Showcase Now Only 73% Behind Schedule"
  ];

  const SEASONS = [
    { id:"spring", label:"Spring", icon:"❀", start:1, end:8, grass:"#73ad48", grassDetail:"#3f8c42", path:"#d3ad72", bank:"#477b3f", treeFilter:"hue-rotate(4deg) saturate(1.05)" },
    { id:"summer", label:"Summer", icon:"☀", start:9, end:15, grass:"#62a03d", grassDetail:"#327b39", path:"#d7ae69", bank:"#3d7339", treeFilter:"saturate(1.18) brightness(.95)" },
    { id:"autumn", label:"Autumn", icon:"❧", start:16, end:23, grass:"#8f9c45", grassDetail:"#697b39", path:"#c99d65", bank:"#61743b", treeFilter:"hue-rotate(300deg) saturate(1.35) brightness(.98)" },
    { id:"winter", label:"Winter", icon:"❄", start:24, end:30, grass:"#d9e5df", grassDetail:"#a9c3b8", path:"#c3ad8b", bank:"#8ba69b", treeFilter:"grayscale(.62) brightness(1.18)" }
  ];

  const WEATHER = [
    { id:"clear", label:"Clear Skies", icon:"☀", category:"sunny", intensity:1, weights:{spring:4,summer:6,autumn:3,winter:2}, effect:"A bright, ordinary day." },
    { id:"soft-sun", label:"Soft Sunshine", icon:"◉", category:"sunny", intensity:1, weights:{spring:4,summer:2,autumn:3,winter:2}, effect:"Gentle light and long shadows." },
    { id:"breezy", label:"Sunny & Breezy", icon:"≋", category:"sunny", intensity:2, weights:{spring:3,summer:3,autumn:4,winter:1}, effect:"Wind moves through the trees." },
    { id:"heatwave", label:"High Summer Sun", icon:"☼", category:"sunny", intensity:3, weights:{spring:0,summer:3,autumn:0,winter:0}, effect:"The afternoon heat drains energy quickly." },
    { id:"drizzle", label:"Light Drizzle", icon:"☂", category:"rain", intensity:1, weights:{spring:4,summer:1,autumn:3,winter:1}, effect:"A soft rain waters planted crops." },
    { id:"steady-rain", label:"Steady Rain", icon:"☔", category:"rain", intensity:2, weights:{spring:3,summer:2,autumn:3,winter:0}, effect:"Rain darkens the paths and fills puddles." },
    { id:"thunderstorm", label:"Thunderstorm", icon:"ϟ", category:"rain", intensity:3, weights:{spring:1,summer:3,autumn:1,winter:0}, effect:"Lightning may inspire an extra spark." },
    { id:"flurries", label:"Snow Flurries", icon:"✦", category:"snow", intensity:1, weights:{spring:1,summer:0,autumn:1,winter:4}, effect:"Loose flakes drift across town." },
    { id:"snowfall", label:"Steady Snow", icon:"❄", category:"snow", intensity:2, weights:{spring:0,summer:0,autumn:0,winter:4}, effect:"Snow gathers along roofs and paths." },
    { id:"blizzard", label:"Heavy Snow", icon:"❅", category:"snow", intensity:3, weights:{spring:0,summer:0,autumn:0,winter:2}, effect:"Visibility is low and the wind bites." }
  ];

  const INVENTIONS = [
    { threshold: 5, name: "Self-Chilling Bifocals", icon: "👓" },
    { threshold: 12, name: "Emotional Support Kite", icon: "🪁" },
    { threshold: 22, name: "Lightning-Powered Latte Cart", icon: "☕" }
  ];

  const NIGHT_EVENTS = {
    3: "At 2:13 AM, the municipal grid briefly spells ‘BEN’ in cursive. No one takes responsibility.",
    5: "The town issues Ben a kite permit. It is laminated and emotionally devastating.",
    8: "Gus hosts a séance for living people who feel ignored. Attendance is excellent.",
    10: "Juniper unveils a pastry shaped like the Liberty Bell. It cracks exactly where expected.",
    13: "A pig wins a local election as a write-in candidate. Pigford demands a recount on principle.",
    15: "Dr. Hex confirms the moon is not haunted, merely ‘going through something.’",
    18: "Chef Howl earns a star. It is unclear which rating system—or galaxy—it came from.",
    20: "DJ Nocturne remixes a thunderstorm. The storm requests royalties.",
    23: "Ben’s kite gets verified on social media before Ben does.",
    25: "The Civic Spark hums overnight. Three nearby phones charge and one becomes self-aware.",
    28: "The showcase committee asks for a safety plan. Ben submits a drawing of a thumbs-up.",
    29: "Tomorrow is the Civic Showcase. The town practices looking impressed.",
    30: "Showcase day arrives. Somewhere, an insurance adjuster wakes with a feeling of dread."
  };

  const ACTIONS = {
    cafe: [
      { id: "barista", title: "Publish the morning broadsheet", desc: "Print local news, practical advice, and one excellent aphorism.", cost: "−2 energy · +cash", energy: 2 },
      { id: "counsel", title: "Host Junto office hours", desc: "Turn the café into a modern civic-improvement club.", cost: "−1 energy · +friendship", energy: 1 },
      { id: "pastry", title: "Test a heat-retaining mug", desc: "Apply Franklin-stove thinking to coffee, then drink the evidence.", cost: "$5 · +energy", energy: 0, requires: s => s.stats.cash >= 5 }
    ],
    lab: [
      { id: "tinker", title: "Tinker on the Civic Spark", desc: "Turn loose parts and confidence into invention progress.", cost: "1 part · −2 energy", energy: 2, requires: s => s.inventory.parts >= 1 },
      { id: "intern", title: "Audit the town’s lightning rods", desc: "Inspect grounding, document hazards, salvage obsolete fittings.", cost: "−2 energy · +cash/parts", energy: 2 },
      { id: "hexchat", title: "Debate useful invention", desc: "Apply Ben’s civic-minded science rules to modern technology.", cost: "−1 energy · +friendship", energy: 1 }
    ],
    restaurant: [
      { id: "serve", title: "Consult on the kitchen stove", desc: "Improve heat flow using lessons from Ben’s Franklin stove.", cost: "−2 energy · +cash", energy: 2 },
      { id: "meal", title: "Host a diplomatic supper", desc: "Settle neighborhood disputes over three strategic courses.", cost: "$8 · +energy", energy: 0, requires: s => s.stats.cash >= 8 },
      { id: "kitchen", title: "Draft a community menu", desc: "Help the chef turn local produce into accessible civic dining.", cost: "−1 energy · +friendship", energy: 1 }
    ],
    farm: [
      { id: "garden", title: "Work the almanac garden", desc: "Test Poor Richard’s planting notes against modern conditions.", cost: "−2 energy · crops", energy: 2 },
      { id: "pigchat", title: "Issue an almanac forecast", desc: "Compare cloud signs, instruments, and farmers’ hard-earned sense.", cost: "−1 energy · +friendship", energy: 1 },
      { id: "forage", title: "Salvage workshop materials", desc: "Collect practical parts for the town’s next useful invention.", cost: "−1 energy · +parts", energy: 1 }
    ],
    mansion: [
      { id: "inspect", title: "Trace the electrical disturbances", desc: "Separate bad wiring, atmospheric charge, and actual haunting.", cost: "−2 energy · +parts", energy: 2 },
      { id: "seance", title: "Chair the tenant compact", desc: "Use civic-organizing skills to give every resident a voice.", cost: "−1 energy · +friendship", energy: 1 },
      { id: "dust", title: "Archive the historic papers", desc: "Sort documents like a printer, publisher, and compulsive founder.", cost: "−2 energy · +cash", energy: 2 }
    ],
    club: [
      { id: "openmic", title: "Perform the glass armonica", desc: "Bring Ben’s real musical invention to a modern electronic set.", cost: "−2 energy · +reputation", energy: 2 },
      { id: "dance", title: "Stage a Revolutionary reenactment", desc: "Play every role in an intentionally excessive history show.", cost: "−1 energy · +friendship", energy: 1 },
      { id: "bartend", title: "Host a civic salon", desc: "Moderate ideas, introductions, and nonpartisan mocktails.", cost: "−2 energy · +cash", energy: 2 }
    ],
    ranch: [
      { id: "groom", title: "Design kite-based animal enrichment", desc: "Test whether fresh air, string, and spectacle improve pig morale.", cost: "−1 energy · +friendship", energy: 1 },
      { id: "irrigate", title: "Ground the irrigation system", desc: "Protect pumps and livestock with practical lightning-rod design.", cost: "−2 energy · +cash/parts", energy: 2 },
      { id: "trailride", title: "Inspect the old postal trail", desc: "Use Ben’s postmaster experience to restore a rural delivery route.", cost: "−2 energy · +reputation", energy: 2 }
    ]
  };

  const CHALLENGES = {
    cafe: {
      type: "timing",
      action: "Register the printing press",
      description: "Time three clean impressions for the morning broadsheet.",
      title: "Print the Morning Edition",
      instructions: "Stop the press marker inside the golden registration zone.",
      rounds: 3,
      animationAction: "barista",
      virtue: "industry",
      baseReward: 7
    },
    lab: {
      type: "sequence",
      action: "Wire a lightning-battery test",
      description: "Repeat the safe conductor sequence without crossing the circuit.",
      title: "Wire the Lightning Battery",
      instructions: "Memorize the conductor route, then repeat it with arrows or the four buttons.",
      length: 5,
      animationAction: "tinker",
      virtue: "order",
      baseReward: 8
    },
    restaurant: {
      type: "sequence",
      action: "Route the diplomatic supper",
      description: "Remember where each course goes before the kitchen bell rings.",
      title: "Route a Diplomatic Supper",
      instructions: "Memorize the serving route, then repeat it in order.",
      length: 4,
      animationAction: "serve",
      virtue: "moderation",
      baseReward: 9
    },
    farm: {
      type: "hunt",
      action: "Harvest by the almanac",
      description: "Gather the ripe crop before the forecast changes.",
      title: "Harvest by the Almanac",
      instructions: "Collect six ripe crops before the weather window closes.",
      targetCount: 6,
      duration: 10,
      targetAsset: "assets/Ranch Stuff/assets/crops/potato/icon/potato_icon_16x16.png",
      animationAction: "garden",
      virtue: "industry",
      baseReward: 6
    },
    ranch: {
      type: "hunt",
      action: "Round up the carrier pigs",
      description: "Gather Ben’s experimental rural postal team for inspection.",
      title: "Round Up the Carrier Pigs",
      instructions: "Find six postal pigs before they miss the route briefing.",
      targetCount: 6,
      duration: 10,
      targetAsset: "assets/Ranch Stuff/assets/animals/pigs/pig_01/purple/idle/pig_01_purple_idle_down_32x32.png",
      animationAction: "trailride",
      virtue: "resolution",
      baseReward: 7
    },
    mansion: {
      type: "hunt",
      action: "Ground the restless spirits",
      description: "Locate each charged apparition before testing the lightning rod.",
      title: "Ground the Restless Spirits",
      instructions: "Find six electrically charged spirits before the meter expires.",
      targetCount: 6,
      duration: 10,
      targetAsset: "assets/NPCs/ghost1.png",
      targetClass: "ghost-target",
      animationAction: "inspect",
      virtue: "cleanliness",
      baseReward: 8
    },
    club: {
      type: "timing",
      action: "Tune the glass armonica",
      description: "Match the instrument’s glass tones to the electronic pulse.",
      title: "Tune the Glass Armonica",
      instructions: "Stop the tone marker inside the golden resonance zone.",
      rounds: 4,
      animationAction: "openmic",
      virtue: "silence",
      baseReward: 8
    }
  };

  Object.entries(CORE.SECONDARY_ACTIONS).forEach(([locationId, actions]) => {
    ACTIONS[locationId] = actions.map(action => ({ ...action }));
  });
  Object.entries(CORE.SECONDARY_CHALLENGES).forEach(([locationId, challenge]) => {
    CHALLENGES[locationId] = { ...challenge };
  });

  const $ = selector => document.querySelector(selector);
  const $$ = (selector,root=document) => [...root.querySelectorAll(selector)];

  let state = null;
  let selectedIndex = 0;
  let actionFocus = 0;
  let pendingDayEnd = false;
  let moveTimer = null;
  let gamepadNavAt = 0;
  let gamepadButtons = [];
  let currentNpcId = "juniper";
  let benAnimationToken = 0;
  let miniGame = null;
  let miniAnimationFrame = 0;
  let miniInterval = 0;
  let miniTimeouts = [];
  let currentSceneIndex = 0;
  let sceneMoving = false;
  let sceneMoveInterval = 0;
  let sceneMoveTimeout = 0;
  let sceneToastTimeout = 0;
  const TOWN_SIZE = { width: 3648, height: 2432 };
  const LEVEL_HEIGHT = 900;
  const DEFAULT_TOWN_LOCATION_POINTS = {
    arcade:{x:420,y:390}, lab:{x:960,y:400}, conservatory:{x:1580,y:400}, skyhouse:{x:2920,y:420},
    cafe:{x:420,y:990}, guildhall:{x:1060,y:980}, market:{x:1760,y:980}, restaurant:{x:2860,y:990},
    farm:{x:380,y:1740}, ranch:{x:900,y:1740}, mansion:{x:1480,y:1740}, club:{x:1980,y:1740},
    clockstation:{x:2760,y:1740}, elementalbaths:{x:3260,y:1740}
  };
  const TOWN_BUILDING_ART = {
    cafe:{atlas:"fantasyHouses",crop:[63,314,210,246],height:332,door:.50},
    arcade:{atlas:"greatWarHouses",crop:[271,29,206,211],height:315,door:.41},
    guildhall:{atlas:"fantasyHouses",crop:[534,30,228,244],height:340,door:.50},
    lab:{atlas:"fantasyHouses",crop:[293,14,226,246],height:335,door:.50},
    conservatory:{atlas:"fantasyHouses",crop:[48,20,240,249],height:344,door:.50},
    market:{atlas:"fantasyHouses",crop:[303,314,210,246],height:330,door:.50},
    restaurant:{atlas:"fantasyHouses",crop:[543,314,210,246],height:332,door:.50},
    elementalbaths:{atlas:"greatWarHouses",crop:[489,243,216,213],height:310,door:.84},
    skyhouse:{atlas:"greatWarHouses",crop:[488,522,217,198],height:300,door:.31},
    club:{atlas:"greatWarHouses",crop:[257,512,206,208],height:312,door:.50},
    clockstation:{atlas:"greatWarHouses",crop:[510,15,180,225],height:330,door:.51},
    mansion:{atlas:"greatWarHouses",crop:[251,250,220,230],height:330,door:.50},
    farm:{atlas:"greatWarHouses",crop:[7,275,184,205],height:300,door:.43},
    ranch:{atlas:"greatWarHouses",crop:[7,511,185,209],height:305,door:.43}
  };
  const TOWN_DECOR_BUILDING_ART = {
    cottage:{crop:[159,584,109,136],width:220,height:275},
    shop:{crop:[293,591,111,129],width:250,height:291},
    barn:{crop:[63,314,210,246],width:320,height:375}
  };
  const DEFAULT_TOWN_TREE_POINTS = [[80,80],[250,160],[620,100],[1180,180],[1840,100],[2050,330],[2500,120],[2740,210],[3350,120],[3460,520],[90,820],[760,820],[1280,760],[1880,780],[2550,820],[3380,820],[120,1430],[680,1450],[1200,1400],[1740,1450],[2540,1440],[3440,1420],[80,2160],[520,2250],[1080,2160],[1660,2210],[2050,2140],[2520,2220],[3040,2160],[3460,2240]];
  // Elevation now comes only from connected editor cells. The old oversized,
  // fixed atlas slices looked like unrelated monoliths and could not be edited.
  const DEFAULT_TOWN_NATURE_POINTS = [
    ["bushA",350,120,68],["plantA",700,300,82],["mushroom",1120,250,54],["rock",1490,180,68],["bushB",1760,260,62],["plantB",2050,470,64],
    ["rock",2520,480,70],["bushA",2780,120,68],["plantA",3200,180,84],["smallRock",3480,420,42],["grass",760,470,52],["grass",1810,460,52],
    ["bushB",140,800,66],["rock",740,800,70],["plantB",1320,800,64],["mushroom",1940,820,56],["bushA",2520,830,70],["plantA",3380,820,82],
    ["smallRock",210,1080,44],["grass",820,1080,52],["bushA",1370,1060,68],["rock",2050,1040,70],["plantB",2630,1060,64],["mushroom",3420,1080,54],
    ["plantA",360,1460,82],["bushB",760,1480,64],["rock",1260,1470,70],["grass",1770,1510,52],["smallRock",2570,1450,44],["bushA",3060,1460,70],
    ["rock",180,2150,72],["plantB",680,2180,66],["mushroom",1160,2140,56],["bushA",1580,2180,70],["rock",2040,2160,72],["plantA",2570,2140,84],
    ["bushB",3040,2180,66],["smallRock",3420,2110,44],["grass",460,2090,52],["grass",1420,2100,52],["grass",2860,2100,52]
  ];
  const TOWN_NATURE_DISPLAY = {bushA:64,bushB:64,plantA:64,plantB:64,mushroom:64,rock:64,smallRock:32,grass:48};
  const TOWN_MATURE_GRASS_FRAME_X = 64; // frame 5 at x=80 is the harvested/short state
  const TOWN_ROADS = [
    {x:0,y:576,w:2176,h:128},{x:2432,y:576,w:1216,h:128},
    {x:0,y:1152,w:3648,h:192},{x:0,y:1920,w:3648,h:192},
    {x:576,y:576,w:128,h:1536},{x:1472,y:576,w:128,h:1536},{x:2944,y:576,w:128,h:1536}
  ];
  const TOWN_RIVER = {x:2176,width:256};
  const TOWN_BRIDGES = [{y:1152,height:192},{y:1920,height:192}];
  const TOWN_RIVER_BLOCK = {left:TOWN_RIVER.x+12,right:TOWN_RIVER.x+TOWN_RIVER.width+20};
  function isTownBridgeY(y){return TOWN_BRIDGES.some(bridge=>y>=bridge.y&&y<bridge.y+bridge.height);}
  function townUsesAuthoredBase(){return townFoundationMode!=="founded";}
  function townLocationActive(id){return TOWN_LOCATION_POINTS[id]?.active!==false;}
  const TERRAIN_CELL = 64;
  const TERRAIN_SURFACES = new Set(["grass","dirt","road","water"]);
  const BUILDING_GROUND_OFFSET = 86;
  const TOWN_DEPTH_BASE = 1000;
  const TOWN_LAYOUT_PREFIX = "ben-there-town-layout-v3-slot-";
  const TOWN_PREVIOUS_LAYOUT_KEY = "ben-there-town-layout-v2";
  const TOWN_LEGACY_LAYOUT_KEY = "ben-there-town-layout-v1";
  const ASSET_LIBRARY_PREFS_KEY = "ben-there-asset-library-v1";
  const NPC_ENTITY_BEHAVIORS = new Set(["static","face-player","wander"]);
  const NPC_ENTITY_FACINGS = new Set(["south","west","east","north"]);
  let townEditorLayout = loadTownEditorLayout();
  let townFoundationMode = townEditorLayout.mode||"authored";
  let townGenerationSettings = townEditorLayout.generation||null;
  let TOWN_LOCATION_POINTS = townEditorLayout.houses;
  let TOWN_TREE_POINTS = townEditorLayout.trees;
  let townNaturePoints = townEditorLayout.nature;
  let townPlacedDecor = townEditorLayout.decor;
  let townPlacedNpcs = townEditorLayout.npcs;
  let townTerrain = townEditorLayout.terrain;
  let townEditMode = false;
  let townEditorToolsCollapsed = true;
  let townEditorSelection = null;
  let townEditorDrag = null;
  let townTerrainTool = null;
  let townTerrainPainting = false;
  let townTerrainStrokeCells = new Set();
  let townTerrainStrokeSnapshot = null;
  let townTerrainLastPoint = null;
  let townTerrainHoverPoint = null;
  let townTerrainRenderFrame = 0;
  let townEditorUndo = [];
  let townEditorRedo = [];
  const INTERIOR_LAYOUT_PREFIX = "ben-there-interior-layout-v2-slot-";
  let interiorEditorLayout = loadInteriorEditorLayout();
  let currentInteriorProps = [];
  let currentInteriorNpcs = [];
  let roomEditMode = false;
  let roomEditorSelection = null;
  let roomEditorDrag = null;
  let roomEditorUndo = [];
  let roomEditorRedo = [];
  let roomEditorSnap = 8;
  let roomEditorShowGrid = true;
  let roomEditorInspectorSnapshot = null;
  let assetBrowserContext = "town";
  let assetBrowserPage = 0;
  let assetBrowserSelected = null;
  let assetBrowserSelectedImage = null;
  let assetBrowserFiltered = [];
  let assetBrowserCatalog = [];
  let assetBrowserCategory = "all";
  let assetFavoriteKeys = new Set();
  let assetRecentKeys = [];
  let assetDockCollapsed = false;
  let assetCatalogLoadPromise = null;
  let assetBrowserReady = false;
  let waypointLocationId = null;
  let activeNotebookTab = "people";
  let lastFocusedBeforeDialogue = null;
  const animatedEditorCanvases = new Set();
  const townResidents = new Map();
  const townCustomNpcSims = new Map();
  const interiorCustomNpcSims = new Map();
  const MAX_TOWN_RESIDENTS = 9;
  const TOWN_NAV_GRID = 32;
  const residentSpriteBounds = new Map();
  let residentScheduleKey = "";
  let lastTownVfxAt = 0;
  const heldKeys = new Set();
  let gamepadMove = { x: 0, y: 0, magnitude: 0 };
  let activeGamepadIndex = null;
  let townMoveRoute = [];
  let interiorMoveRoute = [];
  let townRouteBlockedFor = 0;
  let interiorRouteBlockedFor = 0;
  let townPosition = { x: 620, y: 1080 };
  let townFacing = "south";
  let townWalkFrame = 0;
  let townLastFrame = 0;
  let townSaveAt = 0;
  let townWaterFrame = -1;
  let townWaterWaiting = false;
  let nearbyLocationId = null;
  let nearbyResidentId = null;
  let nearbyResidentSim = null;
  let townPromptHoldUntil = 0;
  let interiorPosition = { x: 250, y: 790 };
  let interiorFacing = "north";
  let interiorWalkFrame = 0;
  const levelImageCache = new Map();
  let currentLevelWidth = 1500;
  let currentLevelHeight = LEVEL_HEIGHT;

  function normalizeTerrainCell(value={}) {
    const legacySurface=value.water?"water":value.road?"road":value.dirt?"dirt":"grass";
    const surface=TERRAIN_SURFACES.has(value.surface)?value.surface:legacySurface;
    const elevation=clamp(Math.round(Number(value.elevation ?? value.h) || 0),-2,5);
    return {surface,elevation};
  }

  function normalizeNpcEntity(value={},index=0,width=TOWN_SIZE.width,height=TOWN_SIZE.height,prefix="npc") {
    const npcId=NPCS[value.npcId]?String(value.npcId):Object.keys(NPCS)[0];
    return {
      id:String(value.id||`${prefix}-${index}`),npcId,
      x:clamp(Math.round(Number(value.x)||0),36,Math.max(36,width-36)),
      y:clamp(Math.round(Number(value.y)||0),80,Math.max(80,height-24)),
      behavior:NPC_ENTITY_BEHAVIORS.has(value.behavior)?value.behavior:"static",
      facing:NPC_ENTITY_FACINGS.has(value.facing)?value.facing:"south",
      collision:value.collision!==false,visible:value.visible!==false,locked:Boolean(value.locked)
    };
  }

  function uniqueNpcEntityId(prefix,entities) {
    const used=new Set(entities.map(entity=>entity.id));let id=`${prefix}-${Date.now()}-${Math.random().toString(16).slice(2)}`,suffix=2;
    while(used.has(id))id=`${prefix}-${Date.now()}-${suffix++}`;
    return id;
  }

  function terrainCellIsDefault(cell) {
    const normalized=normalizeTerrainCell(cell);
    return normalized.surface==="grass"&&normalized.elevation===0;
  }

  function loadTownEditorLayout() {
    const fallback = {
      mode:"authored",
      generation:null,
      houses: Object.fromEntries(Object.entries(DEFAULT_TOWN_LOCATION_POINTS).map(([id,p]) => [id,{...p}])),
      trees: DEFAULT_TOWN_TREE_POINTS.map(point => [...point]),
      nature: DEFAULT_TOWN_NATURE_POINTS.map(point => [...point]),
      decor: [],
      npcs: [],
      terrain:{cells:{}}
    };
    try {
      const targetKey=`${TOWN_LAYOUT_PREFIX}${activeSaveSlot}`,currentRaw=localStorage.getItem(targetKey),previousRaw=!currentRaw&&activeSaveSlot===1?localStorage.getItem(TOWN_PREVIOUS_LAYOUT_KEY):null,legacyRaw=!currentRaw&&!previousRaw&&activeSaveSlot===1?localStorage.getItem(TOWN_LEGACY_LAYOUT_KEY):null,migratingLayout=Boolean(previousRaw||legacyRaw),migratingLegacy=Boolean(legacyRaw);
      const saved = JSON.parse(currentRaw||previousRaw||legacyRaw||"null");
      if (!saved) return fallback;
      fallback.mode=saved.mode==="founded"?"founded":"authored";
      fallback.generation=saved.generation&&typeof saved.generation==="object"?{...saved.generation}:null;
      const legacy=!saved.worldWidth,scaleX=legacy?TOWN_SIZE.width/2400:1,scaleY=legacy?TOWN_SIZE.height/1600:1;
      if(!legacy)Object.keys(fallback.houses).forEach(id => {
        const point=saved.houses?.[id];
        if(point) fallback.houses[id]={x:clamp(Math.round(Number(point.x)/16)*16,144,TOWN_SIZE.width-144),y:clamp(Math.round(Number(point.y)/16)*16,112,TOWN_SIZE.height-128),active:point.active!==false};else if(fallback.mode==="founded")fallback.houses[id].active=false;
      });
      if(Array.isArray(saved.trees)&&!legacy) fallback.trees=saved.trees.slice(0,120).filter(p=>Array.isArray(p)&&p.length===2).map(([x,y])=>[clamp((Number(x)||0)*scaleX,0,TOWN_SIZE.width-96),clamp((Number(y)||0)*scaleY,0,TOWN_SIZE.height-96)]);
      if(Array.isArray(saved.nature)&&!legacy){const allowedNature=new Set(Object.keys(TOWN_NATURE_DISPLAY));fallback.nature=saved.nature.slice(0,240).filter(point=>Array.isArray(point)&&point.length>=3&&allowedNature.has(point[0])).map(([kind,x,y])=>[kind,clamp((Number(x)||0)*scaleX,0,TOWN_SIZE.width-(TOWN_NATURE_DISPLAY[kind]||64)),clamp((Number(y)||0)*scaleY,0,TOWN_SIZE.height-(kind==="grass"?(TOWN_NATURE_DISPLAY[kind]||64)*2:(TOWN_NATURE_DISPLAY[kind]||64)))]);}
      if(Array.isArray(saved.decor)) fallback.decor=saved.decor.slice(0,400).filter(item=>["cottage","shop","barn","tree","flower","bench","pond","path","asset"].includes(item.type)).map((item,index)=>{
        const restored={...item,id:String(item.id||`decor-${index}`),type:item.type,x:clamp((Number(item.x)||0)*scaleX,0,TOWN_SIZE.width-8),y:clamp((Number(item.y)||0)*scaleY,0,TOWN_SIZE.height-8)};
        if(item.type==="asset") {
          restored.src=String(item.src||"");restored.sx=Math.max(0,Number(item.sx)||0);restored.sy=Math.max(0,Number(item.sy)||0);restored.sw=Math.max(1,Number(item.sw)||48);restored.sh=Math.max(1,Number(item.sh)||48);restored.width=clamp(Number(item.width)||96,8,640);restored.height=clamp(Number(item.height)||96,8,640);
          restored.animation=normalizeAssetAnimation(item.animation);restored.assetId=String(item.assetId||"");restored.variantId=String(item.variantId||"");restored.assetKind=String(item.assetKind||"");
        }
        return restored;
      });
      if(Array.isArray(saved.npcs)){const usedNpcIds=new Set();fallback.npcs=saved.npcs.slice(0,200).filter(item=>item&&NPCS[item.npcId]).map((item,index)=>{const entity=normalizeNpcEntity(item,index,TOWN_SIZE.width,TOWN_SIZE.height,"town-npc"),base=entity.id;let id=base,suffix=2;while(usedNpcIds.has(id))id=`${base}-${suffix++}`;usedNpcIds.add(id);entity.id=id;return entity;});}
      if(saved.terrain?.cells&&typeof saved.terrain.cells==="object")Object.entries(saved.terrain.cells).slice(0,4000).forEach(([key,value])=>{
        if(!/^\d+,\d+$/.test(key)||!value||typeof value!=="object")return;
        const cell=normalizeTerrainCell(value),explicitSurface=Object.prototype.hasOwnProperty.call(value,"surface");
        if(migratingLegacy)cell.elevation=0;
        if(migratingLegacy){const [gx,gy]=key.split(",").map(Number);if(cell.surface==="grass"||cell.surface===defaultTerrainSurface(gx,gy))return;}
        if(explicitSurface||!terrainCellIsDefault(cell))fallback.terrain.cells[key]=cell;
      });
      if(migratingLayout)localStorage.setItem(targetKey,JSON.stringify({layoutVersion:4,worldWidth:TOWN_SIZE.width,worldHeight:TOWN_SIZE.height,...fallback}));
      return fallback;
    } catch { return fallback; }
  }

  function saveTownEditorLayout() {
    try { localStorage.setItem(`${TOWN_LAYOUT_PREFIX}${activeSaveSlot}`,JSON.stringify(captureTownEditorLayout())); } catch { /* optional local layout */ }
  }

  function captureTownEditorLayout(){return {layoutVersion:5,worldWidth:TOWN_SIZE.width,worldHeight:TOWN_SIZE.height,mode:townFoundationMode,generation:townGenerationSettings,houses:TOWN_LOCATION_POINTS,trees:TOWN_TREE_POINTS,nature:townNaturePoints,decor:townPlacedDecor,npcs:townPlacedNpcs,terrain:townTerrain};}

  function loadInteriorEditorLayout() {
    try { return JSON.parse(localStorage.getItem(`${INTERIOR_LAYOUT_PREFIX}${activeSaveSlot}`) || (activeSaveSlot===1?localStorage.getItem("ben-there-interior-layout-v1"):null) || "{}") || {}; }
    catch { return {}; }
  }

  function saveInteriorEditorLayout() {
    try { localStorage.setItem(`${INTERIOR_LAYOUT_PREFIX}${activeSaveSlot}`,JSON.stringify(interiorEditorLayout)); } catch { /* optional local layout */ }
  }

  function defaultState() {
    const relationships = {};
    Object.keys(NPCS).forEach(id => { relationships[id] = 0; });
    return {
      version: 1,
      day: 1,
      cycle: 1,
      slot: 0,
      stats: { cash: 24, energy: MAX_ENERGY, reputation: 0 },
      inventory: { parts: 1, produce: 0, keepsakes: 0 },
      relationships,
      communityBonds: Object.fromEntries(SOCIAL_TIES.map(tie=>[[tie.a,tie.b].sort().join(":"),5])),
      npcStories: {},
      virtues: Object.fromEntries(VIRTUES.map(virtue => [virtue.id, 0])),
      virtuesToday: [],
      focusCompleted: false,
      focusStreak: 0,
      focusDays: 0,
      discoveries: [],
      sparks: 0,
      inventions: [],
      garden: { crop: null, age: 0, tended: 0 },
      activeErrand: null,
      currentLocation: "cafe",
      townMode: "authored",
      townPosition: { x: 620, y: 1080 },
      visitedToday: [],
      schedule: [],
      notes: ["The Civic Showcase is on Day 30.", "All 17 of Ben’s action sets appear during jobs, travel, rest, or special routines.", "Fifty-one residents live across fourteen destinations.", "Friendship survives across timelines."],
      encounteredNpcs: [],
      tutorialStep: 0,
      tutorialDismissed: false,
      weather: "clear",
      forecast: ["clear", "soft-sun", "drizzle", "breezy"],
      sound: true,
      actionsTaken: 0,
      errandsDone: 0,
      cropsHarvested: 0
    };
  }

  function sanitizeSave(candidate) {
    const fresh = defaultState();
    if (!candidate || typeof candidate !== "object" || candidate.version !== 1) return fresh;
    const safe = { ...fresh, ...candidate };
    safe.stats = { ...fresh.stats, ...(candidate.stats || {}) };
    safe.inventory = { ...fresh.inventory, ...(candidate.inventory || {}) };
    safe.relationships = { ...fresh.relationships };
    safe.communityBonds = { ...fresh.communityBonds, ...(candidate.communityBonds || {}) };
    Object.keys(NPCS).forEach(id => {
      const value = Number(candidate.relationships?.[id]);
      if (Number.isFinite(value)) safe.relationships[id] = clamp(value, 0, 25);
    });
    Object.keys(ROSTERS).forEach(locationId => {
      const legacyValue = Number(candidate.relationships?.[locationId]);
      if (Number.isFinite(legacyValue) && legacyValue > 0) {
        const primaryNpc = ROSTERS[locationId][0];
        safe.relationships[primaryNpc] = clamp(safe.relationships[primaryNpc] + legacyValue, 0, 25);
      }
    });
    safe.virtues = { ...fresh.virtues };
    VIRTUES.forEach(virtue => {
      const value = Number(candidate.virtues?.[virtue.id]);
      if (Number.isFinite(value)) safe.virtues[virtue.id] = clamp(value, 0, 99);
    });
    safe.virtuesToday = Array.isArray(candidate.virtuesToday)
      ? [...new Set(candidate.virtuesToday.filter(id => VIRTUES.some(virtue => virtue.id === id)))]
      : [];
    safe.focusCompleted = Boolean(candidate.focusCompleted);
    safe.focusStreak = Math.max(0, Number(candidate.focusStreak) || 0);
    safe.focusDays = Math.max(0, Number(candidate.focusDays) || 0);
    const validDiscoveries = new Set(Object.entries(EXPLORATION_SCENES).flatMap(([locationId, scenes]) => scenes.map(scene => `${locationId}:${scene.id}`)));
    safe.discoveries = Array.isArray(candidate.discoveries)
      ? [...new Set(candidate.discoveries.filter(key => validDiscoveries.has(key)))]
      : [];
    safe.garden = { ...fresh.garden, ...(candidate.garden || {}) };
    safe.townMode=candidate.townMode==="founded"?"founded":"authored";
    safe.day = clamp(Number(safe.day) || 1, 1, 30);
    safe.cycle = Math.max(1, Number(safe.cycle) || 1);
    safe.slot = clamp(Number(safe.slot) || 0, 0, 3);
    safe.stats.cash = Math.max(0, Number(safe.stats.cash) || 0);
    safe.stats.energy = clamp(Number(safe.stats.energy) || 0, 0, MAX_ENERGY);
    safe.stats.reputation = Math.max(0, Number(safe.stats.reputation) || 0);
    const legacyWeather = {sunny:"clear",rain:"drizzle",snow:"flurries",electric:"thunderstorm"};
    safe.weather = legacyWeather[safe.weather] || safe.weather;
    if (!WEATHER.some(item => item.id === safe.weather)) safe.weather = rollWeather(safe.day, safe.cycle);
    const savedForecast = Array.isArray(candidate.forecast) ? candidate.forecast.map(id => legacyWeather[id] || id).filter(id => WEATHER.some(item => item.id === id)) : [];
    safe.forecast = [safe.weather, ...savedForecast.filter((id,index) => index > 0)].slice(0,4);
    while (safe.forecast.length < 4) safe.forecast.push(rollWeather(safe.day + safe.forecast.length, safe.cycle));
    safe.sparks = Math.max(0, Number(safe.sparks) || 0);
    safe.currentLocation = LOCATIONS[safe.currentLocation] ? safe.currentLocation : "cafe";
    safe.townPosition = {
      x: clamp(Number(candidate.townPosition?.x) || fresh.townPosition.x, 45, TOWN_SIZE.width - 45),
      y: clamp(Number(candidate.townPosition?.y) || fresh.townPosition.y, 70, TOWN_SIZE.height - 45)
    };
    if (isTownRiverBlocked(safe.townPosition.x, safe.townPosition.y)) safe.townPosition.x = 2100;
    safe.inventions = Array.isArray(safe.inventions) ? safe.inventions.slice(0, INVENTIONS.length) : [];
    safe.visitedToday = Array.isArray(safe.visitedToday) ? safe.visitedToday.filter(id => LOCATIONS[id]) : [];
    safe.schedule = Array.isArray(safe.schedule) ? safe.schedule.slice(0, 3) : [];
    safe.npcStories = safe.npcStories && typeof safe.npcStories === "object" ? safe.npcStories : {};
    safe.notes = Array.isArray(safe.notes) ? safe.notes.slice(0, 8) : fresh.notes;
    safe.encounteredNpcs = Array.isArray(candidate.encounteredNpcs) ? [...new Set(candidate.encounteredNpcs.filter(id => NPCS[id]))].slice(0, Object.keys(NPCS).length) : [];
    safe.tutorialStep = clamp(Number(candidate.tutorialStep) || 0, 0, 3);
    safe.tutorialDismissed = Boolean(candidate.tutorialDismissed);
    return safe;
  }

  function loadState(slot = activeSaveSlot) {
    try {
      const key=saveKey(slot),raw = localStorage.getItem(key) || (clampSaveSlot(slot)===1?localStorage.getItem(LEGACY_SAVE_KEY):null);
      const loaded=raw ? sanitizeSave(JSON.parse(raw)) : defaultState();
      if(raw&&!localStorage.getItem(key))localStorage.setItem(key,JSON.stringify(loaded));
      return loaded;
    } catch {
      return defaultState();
    }
  }

  function saveState() {
    try { localStorage.setItem(saveKey(), JSON.stringify(state)); } catch { /* local saves are optional */ }
  }

  function hasSlotSave(slot=activeSaveSlot) {
    return Boolean(localStorage.getItem(saveKey(slot)) || (clampSaveSlot(slot)===1&&localStorage.getItem(LEGACY_SAVE_KEY)));
  }

  function applyTownLayout(layout) {
    townEditorLayout=layout;townFoundationMode=layout.mode||"authored";townGenerationSettings=layout.generation||null;TOWN_LOCATION_POINTS=layout.houses;TOWN_TREE_POINTS=layout.trees;townNaturePoints=layout.nature||DEFAULT_TOWN_NATURE_POINTS.map(point=>[...point]);townPlacedDecor=layout.decor;townPlacedNpcs=layout.npcs;townTerrain=layout.terrain;
  }

  function updateSaveManagerUI(message="") {
    const select=$("#save-slot-select"),status=$("#save-manager-status"),continueButton=$("#continue-button"),hasSave=hasSlotSave();
    if(select)select.value=String(activeSaveSlot);
    if(continueButton){continueButton.classList.toggle("hidden",!hasSave);continueButton.textContent=hasSave?`Continue Slot ${activeSaveSlot} · Day ${state.day}`:`Continue Slot ${activeSaveSlot}`;}
    if(status)status.textContent=message||`Town slot ${activeSaveSlot} · ${hasSave?`Day ${state.day}, Timeline ${state.cycle}`:"empty"}`;
  }

  function switchSaveSlot(slot) {
    activeSaveSlot=clampSaveSlot(slot);localStorage.setItem(ACTIVE_SAVE_SLOT_KEY,String(activeSaveSlot));state=loadState();applyTownLayout(loadTownEditorLayout());interiorEditorLayout=loadInteriorEditorLayout();townPosition={...state.townPosition};selectedIndex=Math.max(0,LOCATION_ORDER.indexOf(state.currentLocation));waypointLocationId=null;townEditorUndo=[];townEditorRedo=[];roomEditorUndo=[];roomEditorRedo=[];
    sanitizeTownTerrainLayout();syncLocationMarkerGeometry();updateFoundingTools();createTownResidents();renderTownNpcEntities();drawTownLevel();townWaterFrame=-1;renderAll();updateSaveManagerUI();
  }

  function exportSaveBundle() {
    const payload={format:"ben-there-save",version:1,exportedAt:new Date().toISOString(),slot:activeSaveSlot,state:sanitizeSave(state),town:captureTownEditorLayout(),interiors:interiorEditorLayout};
    const blob=new Blob([JSON.stringify(payload,null,2)],{type:"application/json"}),url=URL.createObjectURL(blob),link=document.createElement("a");link.href=url;link.download=`ben-there-town-slot-${activeSaveSlot}.json`;document.body.append(link);link.click();link.remove();window.setTimeout(()=>URL.revokeObjectURL(url),1000);updateSaveManagerUI(`Town slot ${activeSaveSlot} exported`);
  }

  async function importSaveBundle(file) {
    if(!file)return;
    try {
      const payload=JSON.parse(await file.text());
      if(payload?.format!=="ben-there-save"||payload.version!==1||!payload.state)throw new Error("This is not a Ben There save backup.");
      const importedState=sanitizeSave(payload.state),importedTown=payload.town?normalizeImportedTownLayout(payload.town):loadTownEditorLayout(),importedInteriors=payload.interiors&&typeof payload.interiors==="object"?payload.interiors:{};
      localStorage.setItem(saveKey(),JSON.stringify(importedState));localStorage.setItem(`${TOWN_LAYOUT_PREFIX}${activeSaveSlot}`,JSON.stringify({layoutVersion:4,worldWidth:TOWN_SIZE.width,worldHeight:TOWN_SIZE.height,...importedTown}));localStorage.setItem(`${INTERIOR_LAYOUT_PREFIX}${activeSaveSlot}`,JSON.stringify(importedInteriors));
      switchSaveSlot(activeSaveSlot);updateSaveManagerUI(`Imported into town slot ${activeSaveSlot}`);
    } catch(error) { updateSaveManagerUI(error?.message||"Save import failed"); }
  }

  function clearActiveSaveSlot() {
    if(!window.confirm(`Clear the browser town-world progress, town edits, and room edits in town slot ${activeSaveSlot}? JRPG Campaign and Sandbox autosaves are unaffected. Export first if you want a backup.`))return;
    localStorage.removeItem(saveKey());localStorage.removeItem(`${TOWN_LAYOUT_PREFIX}${activeSaveSlot}`);localStorage.removeItem(`${INTERIOR_LAYOUT_PREFIX}${activeSaveSlot}`);
    if(activeSaveSlot===1){localStorage.removeItem(LEGACY_SAVE_KEY);localStorage.removeItem(TOWN_PREVIOUS_LAYOUT_KEY);localStorage.removeItem(TOWN_LEGACY_LAYOUT_KEY);localStorage.removeItem("ben-there-interior-layout-v1");}
    switchSaveSlot(activeSaveSlot);updateSaveManagerUI(`Town slot ${activeSaveSlot} cleared`);
  }

  function clamp(value, min, max) { return Math.min(max, Math.max(min, value)); }
  function pick(list) { return list[Math.floor(Math.random() * list.length)]; }
  function chance(percent) { return Math.random() * 100 < percent; }
  function seasonForDay(day) {
    const wrapped = ((Number(day) || 1) - 1) % 30 + 1;
    return SEASONS.find(season => wrapped >= season.start && wrapped <= season.end) || SEASONS[0];
  }
  function currentSeason() { return seasonForDay(state.day); }
  function currentWeather() { return WEATHER.find(item => item.id === state.weather) || WEATHER[0]; }
  function stableHash(value) { return [...String(value)].reduce((hash,char)=>(hash*31+char.charCodeAt(0))>>>0,7); }
  function npcWorkplace(npcId) { return NPC_LIFE[npcId]?.job || LOCATION_ORDER.find(id=>ROSTERS[id]?.includes(npcId)) || "market"; }
  function npcHome(npcId) {
    if(NPC_LIFE[npcId]?.home)return NPC_LIFE[npcId].home;
    const homes=["mansion","farm","ranch","guildhall","skyhouse","clockstation"];
    return homes[stableHash(npcId)%homes.length];
  }
  function npcLeisure(npcId) {
    if(NPC_LIFE[npcId]?.leisure)return NPC_LIFE[npcId].leisure;
    const places=["cafe","market","conservatory","arcade","club","restaurant"];
    return places[stableHash(`${npcId}:leisure`)%places.length];
  }
  function npcScheduleEntry(npcId,slot=state.slot,day=state.day) {
    const npc=NPCS[npcId],index=Object.keys(NPCS).indexOf(npcId),dayOff=(day+index)%7===0;
    const job=npcWorkplace(npcId),home=npcHome(npcId),leisure=npcLeisure(npcId);
    if(slot===0) return dayOff?{location:leisure,activity:"Taking a weekly morning off"}:{location:job,activity:`Working · ${npc.role.split("·")[0].trim()}`};
    if(slot===1) {
      if(["thunderstorm","blizzard"].includes(state.weather))return{location:job,activity:"Sheltering indoors and catching up"};
      if((day+index)%3===0)return{location:"market",activity:"Running errands at Lantern Market"};
      return dayOff?{location:leisure,activity:"Visiting friends"}:{location:job,activity:"Finishing the afternoon shift"};
    }
    return (day+index)%2===0?{location:home,activity:"Home for supper"}:{location:leisure,activity:"Spending the evening with neighbors"};
  }
  function npcStoryProfile(npcId) {
    const npc=NPCS[npcId],job=LOCATIONS[npcWorkplace(npcId)]?.short||"workshop",home=LOCATIONS[npcHome(npcId)]?.short||"home",friend=npcConnections(npcId)[0],friendName=NPCS[friend?.id]?.name||"a neighbor";
    const needs=["a missing supply crate","a troublesome civic permit","an unfinished community project","a promise that has gone overdue","a mystery tied to their work"];
    const need=needs[stableHash(npcId)%needs.length];
    return {
      title:`${npc.name}: ${need.replace(/^a /,"")}`,
      dialogue:[npc.line,`I spend my mornings at ${job}. Lately, ${need} has made the work harder.`,`Could you check in on ${friendName}? They know part of the story.`,`You came back. That matters more than a grand speech, Ben.`],
      steps:[`Hear ${npc.name}'s concern at ${job}`,`Follow up about ${need} and ${friendName}`,`Return to ${npc.name} with a practical answer`],
      epilogue:`With Ben's help, ${npc.name} resolves ${need} and makes ${home} feel a little more connected to the town.`
    };
  }
  function talkToTownResident(sim) {
    if(townEditMode){showTownPrompt("Finish town editing before talking to residents",1800);return;}
    const conversation=advanceNpcConversation(sim.npcId),{dialogue,status,progress}=conversation;
    showDialogue(sim.npcId,dialogue,status,sim.activity);spawnTownVfx(sim.x,sim.y,progress.complete?"gold":"social");
  }
  function advanceNpcConversation(npcId) {
    const profile=npcStoryProfile(npcId),stored=state.npcStories[npcId]||{progress:0,lastDay:0,complete:false},transition=CORE.advanceConversation(stored,state.day,profile.steps.length),progress=transition.next;
    const dialogue=profile.dialogue[Math.min(transition.spokenIndex,profile.dialogue.length-1)];
    if(transition.advanced){
      state.relationships[npcId]=clamp((state.relationships[npcId]||0)+1,0,30);
      if(progress.complete){state.stats.reputation+=2;addNote(`${profile.title} — ${profile.epilogue}`);}
      else addNote(`${profile.title} — ${profile.steps[transition.completedStep-1]}`);
      state.npcStories[npcId]=progress;encounterNpc(npcId);saveState();renderActiveNotebookTab();
    }
    const nextStep=profile.steps[Math.min(progress.progress,profile.steps.length-1)],status=progress.complete?"Personal mission complete":`Step ${transition.completedStep} of ${profile.steps.length} complete · Next: ${nextStep}`;
    return {profile,progress,dialogue,status};
  }
  function encounterNpc(npcId) {
    if(!NPCS[npcId]||state.encounteredNpcs.includes(npcId))return;
    state.encounteredNpcs.push(npcId);state.encounteredNpcs=state.encounteredNpcs.slice(-Object.keys(NPCS).length);
  }
  function showDialogue(npcId,line,status,activity="Around town") {
    const npc=NPCS[npcId];if(!npc)return;lastFocusedBeforeDialogue=document.activeElement;encounterNpc(npcId);heldKeys.clear();clearAutoMovement();$("#dialogue-avatar").textContent=npc.avatar;$("#dialogue-name").textContent=npc.name;$("#dialogue-activity").textContent=activity;$("#dialogue-line").textContent=`“${line}”`;$("#dialogue-mission").textContent=status;show("dialogue-overlay");saveState();renderActiveNotebookTab();window.setTimeout(()=>$("#dialogue-continue").focus({preventScroll:true}),30);
  }
  function closeDialogue() {
    hide("dialogue-overlay");const fallback=isVisible("location-sheet")?$("#location-scene"):$("#town-map");(lastFocusedBeforeDialogue?.isConnected?lastFocusedBeforeDialogue:fallback)?.focus?.({preventScroll:true});lastFocusedBeforeDialogue=null;
  }
  function npcConnections(npcId) {
    const connections=SOCIAL_TIES.filter(tie=>tie.a===npcId||tie.b===npcId).map(tie=>({id:tie.a===npcId?tie.b:tie.a,type:tie.type,bond:state.communityBonds[[tie.a,tie.b].sort().join(":")]||0}));
    const addDerived=(id,type)=>{if(id!==npcId&&!connections.some(connection=>connection.id===id))connections.push({id,type,bond:5});};
    const peers=Object.keys(NPCS).filter(id=>id!==npcId);
    const colleague=peers.find(id=>npcWorkplace(id)===npcWorkplace(npcId));if(colleague)addDerived(colleague,"coworkers");
    const neighbor=peers.find(id=>npcHome(id)===npcHome(npcId));if(neighbor)addDerived(neighbor,"neighbors");
    if(connections.length<2){const friend=peers[(stableHash(npcId)+state.day)%peers.length];if(friend)addDerived(friend,"town friends");}
    return connections.slice(0,3);
  }
  function advanceCommunityLives() {
    SOCIAL_TIES.forEach(tie=>{
      const key=[tie.a,tie.b].sort().join(":"),a=npcScheduleEntry(tie.a,2,state.day),b=npcScheduleEntry(tie.b,2,state.day);
      const gain=a.location===b.location?2:1;
      state.communityBonds[key]=clamp((state.communityBonds[key]||0)+gain,0,25);
    });
  }
  function virtueById(id) { return VIRTUES.find(virtue => virtue.id === id) || VIRTUES[0]; }
  function dailyVirtue() { return VIRTUES[(state.day + state.cycle - 2) % VIRTUES.length]; }
  function virtueTotal() { return Object.values(state.virtues).reduce((sum, value) => sum + value, 0); }
  function virtueForAction(actionId, locationId) {
    return actionId === "challenge" ? CHALLENGES[locationId].virtue : ACTION_VIRTUES[actionId] || "humility";
  }

  function practiceVirtue(id, amount = 1) {
    const virtue = virtueById(id);
    const focused = dailyVirtue().id === virtue.id;
    const gain = amount + (focused ? 1 : 0);
    state.virtues[virtue.id] = clamp((state.virtues[virtue.id] || 0) + gain, 0, 99);
    if (!state.virtuesToday.includes(virtue.id)) state.virtuesToday.push(virtue.id);
    let completedFocus = false;
    if (focused && !state.focusCompleted) {
      state.focusCompleted = true;
      state.focusStreak += 1;
      state.focusDays += 1;
      completedFocus = true;
    }
    return { id: virtue.id, name: virtue.name, icon: virtue.icon, gain, focused, completedFocus };
  }

  function rollWeather(day = state?.day || 1, cycle = state?.cycle || 1) {
    const season = seasonForDay(day);
    const pool = WEATHER.flatMap(item => Array(item.weights[season.id] || 0).fill(item.id));
    return pick(pool);
  }

  function advanceForecast() {
    const existing = Array.isArray(state.forecast) ? state.forecast.slice(1) : [];
    while (existing.length < 4) existing.push(rollWeather(state.day + existing.length, state.cycle));
    state.forecast = existing.slice(0,4);
    state.weather = state.forecast[0];
  }

  function makeErrand() {
    const template = ERRANDS[(state.day + state.cycle * 2 - 3) % ERRANDS.length];
    return { ...template, status: "pickup" };
  }

  function initializeGame(isNew) {
    heldKeys.clear();clearAutoMovement();gamepadMove={x:0,y:0,magnitude:0};
    if (isNew) {
      state = defaultState();
      if(townFoundationMode==="founded"){townFoundationMode="authored";townGenerationSettings=null;TOWN_LOCATION_POINTS=Object.fromEntries(Object.entries(DEFAULT_TOWN_LOCATION_POINTS).map(([id,point])=>[id,{...point}]));TOWN_TREE_POINTS=DEFAULT_TOWN_TREE_POINTS.map(point=>[...point]);townNaturePoints=DEFAULT_TOWN_NATURE_POINTS.map(point=>[...point]);townPlacedDecor=[];townPlacedNpcs=[];townTerrain={cells:{}};syncLocationMarkerGeometry();updateFoundingTools();saveTownEditorLayout();createTownResidents();drawTownLevel();}
    }
    state.townMode=townFoundationMode;
    if (!state.activeErrand) state.activeErrand = makeErrand();
    selectedIndex = LOCATION_ORDER.indexOf(state.currentLocation);
    if (selectedIndex < 0) selectedIndex = 0;
    townPosition = { ...state.townPosition };
    saveState();
    renderAll();
    hide("start-screen");
    startAudio();
    $("#town-map").focus({ preventScroll: true });
  }

  function foundTownSettingsFromControls(){return normalizedFoundTownSettings({seed:$("#found-town-seed").value,maxHeight:$("#found-town-height").value,grass:$("#found-town-grass").value,water:$("#found-town-water").value,trees:$("#found-town-trees").value});}

  function initializeFoundedTown() {
    state=defaultState();const settings=createFoundedTown(foundTownSettingsFromControls());state.townMode="founded";townPosition={x:Math.floor(TOWN_SIZE.width/2),y:Math.floor(TOWN_SIZE.height/2)};state.townPosition={...townPosition};state.currentLocation="cafe";selectedIndex=0;townEditorUndo=[];townEditorRedo=[];sanitizeTownTerrainLayout();syncLocationMarkerGeometry();updateFoundingTools();saveTownEditorLayout();saveState();createTownResidents();renderTownNpcEntities();renderAll();hide("start-screen");startAudio();townEditMode=true;townEditorDrag=null;$("#town-edit-toggle").textContent="✓ Done Editing";setTownEditorToolsCollapsed(true);renderTownEditorHandles();openAssetBrowser("town");showTownPrompt(`Empty plot generated · ${settings.grass}% grass · ${settings.trees}% trees`,3200);$("#town-map").focus({preventScroll:true});
  }

  function cloneTownEditorSnapshot() {
    return JSON.parse(JSON.stringify({mode:townFoundationMode,generation:townGenerationSettings,houses:TOWN_LOCATION_POINTS,trees:TOWN_TREE_POINTS,nature:townNaturePoints,decor:townPlacedDecor,npcs:townPlacedNpcs,terrain:townTerrain}));
  }

  function exportTownEditorLayout(){
    const blob=new Blob([JSON.stringify(captureTownEditorLayout(),null,2)],{type:"application/json"}),url=URL.createObjectURL(blob),link=document.createElement("a");
    link.href=url;link.download=`ben-there-town-day-${state.day}.json`;document.body.append(link);link.click();link.remove();window.setTimeout(()=>URL.revokeObjectURL(url),1000);showTownPrompt("Town map exported",1800);
  }

  function normalizeImportedTownLayout(raw){
    if(!raw||typeof raw!=="object")throw new Error("This file does not contain a town layout.");
    const sourceWidth=Math.max(1,Number(raw.worldWidth)||TOWN_SIZE.width),sourceHeight=Math.max(1,Number(raw.worldHeight)||TOWN_SIZE.height),scaleX=TOWN_SIZE.width/sourceWidth,scaleY=TOWN_SIZE.height/sourceHeight;
    const mode=raw.mode==="founded"?"founded":"authored",generation=raw.generation&&typeof raw.generation==="object"?{...raw.generation}:null;
    const houses=Object.fromEntries(Object.entries(DEFAULT_TOWN_LOCATION_POINTS).map(([id,point])=>[id,{...point}]));
    Object.keys(houses).forEach(id=>{const point=raw.houses?.[id];if(!point){if(mode==="founded")houses[id].active=false;return;}houses[id]={x:clamp(Math.round((Number(point.x)||0)*scaleX/16)*16,144,TOWN_SIZE.width-144),y:clamp(Math.round((Number(point.y)||0)*scaleY/16)*16,112,TOWN_SIZE.height-128),active:point.active!==false};});
    const importedTrees=Array.isArray(raw.trees)?raw.trees:null,trees=(importedTrees||[]).slice(0,120).filter(point=>Array.isArray(point)&&point.length>=2).map(([x,y])=>[clamp(Math.round((Number(x)||0)*scaleX),0,TOWN_SIZE.width-96),clamp(Math.round((Number(y)||0)*scaleY),0,TOWN_SIZE.height-96)]);
    const allowedNature=new Set(Object.keys(TOWN_NATURE_DISPLAY)),importedNature=Array.isArray(raw.nature)?raw.nature:null,nature=(importedNature||[]).slice(0,240).filter(point=>Array.isArray(point)&&point.length>=3&&allowedNature.has(point[0])).map(([kind,x,y])=>[kind,clamp(Math.round((Number(x)||0)*scaleX),0,TOWN_SIZE.width-(TOWN_NATURE_DISPLAY[kind]||64)),clamp(Math.round((Number(y)||0)*scaleY),0,TOWN_SIZE.height-(kind==="grass"?(TOWN_NATURE_DISPLAY[kind]||64)*2:(TOWN_NATURE_DISPLAY[kind]||64)))]);
    const usedDecorIds=new Set(),allowed=new Set(["cottage","shop","barn","tree","flower","bench","pond","path","asset"]),decor=(Array.isArray(raw.decor)?raw.decor:[]).slice(0,400).filter(item=>item&&allowed.has(item.type)).map((item,index)=>{
      const baseId=String(item.id||`imported-${index}`);let id=baseId,suffix=2;while(usedDecorIds.has(id))id=`${baseId}-${suffix++}`;usedDecorIds.add(id);
      const restored={id,type:item.type,x:clamp(Math.round((Number(item.x)||0)*scaleX),0,TOWN_SIZE.width-8),y:clamp(Math.round((Number(item.y)||0)*scaleY),0,TOWN_SIZE.height-8)};
      if(item.type==="asset"){
        restored.src=String(item.src||"");restored.sx=Math.max(0,Number(item.sx)||0);restored.sy=Math.max(0,Number(item.sy)||0);restored.sw=Math.max(1,Number(item.sw)||1);restored.sh=Math.max(1,Number(item.sh)||1);restored.width=clamp(Number(item.width)||96,8,640);restored.height=clamp(Number(item.height)||96,8,640);
        restored.animation=normalizeAssetAnimation(item.animation);restored.assetId=String(item.assetId||"");restored.variantId=String(item.variantId||"");restored.assetKind=String(item.assetKind||"");
      }
      return restored;
    });
    const usedNpcIds=new Set(),npcs=(Array.isArray(raw.npcs)?raw.npcs:[]).slice(0,200).filter(item=>item&&NPCS[item.npcId]).map((item,index)=>{
      const entity=normalizeNpcEntity({...item,x:(Number(item.x)||0)*scaleX,y:(Number(item.y)||0)*scaleY},index,TOWN_SIZE.width,TOWN_SIZE.height,"town-npc");
      const base=entity.id;let id=base,suffix=2;while(usedNpcIds.has(id))id=`${base}-${suffix++}`;usedNpcIds.add(id);entity.id=id;return entity;
    });
    const terrain={cells:{}},sourceCells=new Map();if(raw.terrain?.cells&&typeof raw.terrain.cells==="object")Object.entries(raw.terrain.cells).slice(0,5000).forEach(([key,value])=>{
      if(!/^\d+,\d+$/.test(key)||!value||typeof value!=="object")return;
      const [gx,gy]=key.split(",").map(Number);if(gx*TERRAIN_CELL<sourceWidth&&gy*TERRAIN_CELL<sourceHeight)sourceCells.set(key,normalizeTerrainCell(value));
    });
    const targetColumns=Math.ceil(TOWN_SIZE.width/TERRAIN_CELL),targetRows=Math.ceil(TOWN_SIZE.height/TERRAIN_CELL);
    for(let gy=0;gy<targetRows;gy+=1)for(let gx=0;gx<targetColumns;gx+=1){
      const sourceGX=Math.floor(((gx+.5)*TERRAIN_CELL)/scaleX/TERRAIN_CELL),sourceGY=Math.floor(((gy+.5)*TERRAIN_CELL)/scaleY/TERRAIN_CELL),cell=sourceCells.get(terrainKey(sourceGX,sourceGY));
      if(cell)terrain.cells[terrainKey(gx,gy)]={...cell};
    }
    return {mode,generation,houses,trees:importedTrees?trees:DEFAULT_TOWN_TREE_POINTS.map(point=>[...point]),nature:importedNature?nature:(mode==="authored"?DEFAULT_TOWN_NATURE_POINTS.map(point=>[...point]):[]),decor,npcs,terrain};
  }

  async function importTownEditorLayout(file){
    if(!file)return;
    try{
      const imported=normalizeImportedTownLayout(JSON.parse(await file.text()));if(!window.confirm("Replace the current town layout with this imported map? You can undo afterward."))return;
      recordTownEditorHistory();townFoundationMode=imported.mode;townGenerationSettings=imported.generation;TOWN_LOCATION_POINTS=imported.houses;TOWN_TREE_POINTS=imported.trees;townNaturePoints=imported.nature;townPlacedDecor=imported.decor;townPlacedNpcs=imported.npcs;townTerrain=imported.terrain;townEditorSelection=null;sanitizeTownTerrainLayout();syncLocationMarkerGeometry();updateFoundingTools();saveTownEditorLayout();renderTownNpcEntities();townWaterFrame=-1;drawTownLevel();drawTownWater(performance.now());renderTownEditorHandles();showTownPrompt("Town map imported · Undo is available",2600);
    }catch(error){window.alert(`Could not import this map. ${error?.message||"Invalid JSON."}`);}
  }

  function recordTownEditorHistory() {
    townEditorUndo.push(cloneTownEditorSnapshot());
    if(townEditorUndo.length>60)townEditorUndo.shift();
    townEditorRedo=[];
    updateTownEditorHistoryControls();
  }

  function restoreTownEditorSnapshot(snapshot) {
    if(!snapshot)return;
    const copy=JSON.parse(JSON.stringify(snapshot));
    townFoundationMode=copy.mode==="founded"?"founded":"authored";
    townGenerationSettings=copy.generation||null;
    TOWN_LOCATION_POINTS=copy.houses;
    TOWN_TREE_POINTS=copy.trees;
    townNaturePoints=copy.nature||DEFAULT_TOWN_NATURE_POINTS.map(point=>[...point]);
    townPlacedDecor=copy.decor;
    townPlacedNpcs=(copy.npcs||[]).map((item,index)=>normalizeNpcEntity(item,index,TOWN_SIZE.width,TOWN_SIZE.height,"town-npc"));
    townTerrain=copy.terrain;
    sanitizeTownTerrainLayout();
    townEditorSelection=null;
    townEditorDrag=null;
    townTerrainPainting=false;
    townTerrainStrokeCells=new Set();
    townTerrainStrokeSnapshot=null;
    townTerrainLastPoint=null;
    $("#town-map")?.classList.remove("terrain-painting");
    townResidents.forEach(sim=>{sim.route=[];sim.nextRoutineAt=performance.now()+500;});
    syncLocationMarkerGeometry();
    updateFoundingTools();
    saveTownEditorLayout();
    syncTownResidents(true);
    renderTownNpcEntities();
    drawTownLevel();
    townWaterFrame=-1;
    drawTownWater(performance.now());
    renderTownEditorHandles();
  }

  function undoTownEditor() {
    if(!townEditorUndo.length)return;
    townEditorRedo.push(cloneTownEditorSnapshot());
    restoreTownEditorSnapshot(townEditorUndo.pop());
    updateTownEditorHistoryControls();
    showTownPrompt("Town edit undone",1400);
  }

  function redoTownEditor() {
    if(!townEditorRedo.length)return;
    townEditorUndo.push(cloneTownEditorSnapshot());
    restoreTownEditorSnapshot(townEditorRedo.pop());
    updateTownEditorHistoryControls();
    showTownPrompt("Town edit restored",1400);
  }

  function updateTownEditorHistoryControls() {
    const undo=$("#terrain-undo"),redo=$("#terrain-redo");
    if(undo)undo.disabled=!townEditorUndo.length;
    if(redo)redo.disabled=!townEditorRedo.length;
  }

  function townBuildingGeometry(id,point=locationPoint(id)) {
    const art=TOWN_BUILDING_ART[id],[sx,sy,sw,sh]=art.crop,scale=art.height/sh,width=sw*scale,groundY=point.y+BUILDING_GROUND_OFFSET;
    const left=point.x-width*art.door,top=groundY-art.height,centerX=left+width/2;
    const foundationWidth=clamp(width*.92,190,340),foundationDepth=94;
    return {
      id,art,point,source:{sx,sy,sw,sh},scale,width,height:art.height,left,top,groundY,centerX,
      doorPoint:{x:point.x,y:groundY+28},
      foundation:{left:centerX-foundationWidth/2,top:groundY-foundationDepth*.58,width:foundationWidth,height:foundationDepth},
      footprint:{left:left+width*.08,right:left+width*.92,top:groundY-76,bottom:groundY+34},
      collision:{left:left+width*.1,right:left+width*.9,top:groundY-112,bottom:groundY+24}
    };
  }

  function fitTownBuildingPoint(id,point) {
    const next={x:Number(point.x)||0,y:Number(point.y)||0};
    for(let pass=0;pass<2;pass+=1){
      const geometry=townBuildingGeometry(id,next);
      if(geometry.left<24)next.x+=24-geometry.left;
      if(geometry.left+geometry.width>TOWN_SIZE.width-24)next.x-=geometry.left+geometry.width-(TOWN_SIZE.width-24);
      if(geometry.top<24)next.y+=24-geometry.top;
      if(geometry.groundY+40>TOWN_SIZE.height-24)next.y-=geometry.groundY+40-(TOWN_SIZE.height-24);
    }
    next.x=Math.round(next.x/16)*16;next.y=Math.round(next.y/16)*16;
    const finalGeometry=townBuildingGeometry(id,next);
    if(finalGeometry.left<24)next.x+=24-finalGeometry.left;
    if(finalGeometry.left+finalGeometry.width>TOWN_SIZE.width-24)next.x-=finalGeometry.left+finalGeometry.width-(TOWN_SIZE.width-24);
    if(finalGeometry.top<24)next.y+=24-finalGeometry.top;
    if(finalGeometry.groundY+40>TOWN_SIZE.height-24)next.y-=finalGeometry.groundY+40-(TOWN_SIZE.height-24);
    return next;
  }

  function fitTownBuildingPlacement(id,point) {
    const avoidRiver=next=>{
      if(!townUsesAuthoredBase())return next;
      const geometry=townBuildingGeometry(id,next);
      if(geometry.footprint.right>TOWN_RIVER_BLOCK.left&&geometry.footprint.left<TOWN_RIVER_BLOCK.right){
        const shiftLeft=geometry.footprint.right-TOWN_RIVER_BLOCK.left,shiftRight=TOWN_RIVER_BLOCK.right-geometry.footprint.left;
        next.x+=shiftLeft<shiftRight?-shiftLeft:shiftRight;
      }
      return next;
    };
    return avoidRiver(fitTownBuildingPoint(id,avoidRiver(fitTownBuildingPoint(id,point))));
  }

  function syncLocationMarkerGeometry() {
    $$(".location-marker").forEach(marker=>{
      const active=townLocationActive(marker.dataset.location);marker.hidden=!active;marker.disabled=!active;marker.setAttribute("aria-hidden",String(!active));
      const geometry=townBuildingGeometry(marker.dataset.location);
      marker.style.left=`${geometry.centerX}px`;
      marker.style.top=`${geometry.point.y}px`;
      marker.style.setProperty("--building-width",`${Math.ceil(geometry.width)}px`);
      marker.style.setProperty("--building-height",`${Math.ceil(geometry.height)}px`);
      marker.style.zIndex=String(TOWN_DEPTH_BASE+Math.round(geometry.groundY)+1);
    });
  }

  function terrainCellOverlapsBox(gx,gy,box,pad=0) {
    const left=gx*TERRAIN_CELL,top=gy*TERRAIN_CELL,right=left+TERRAIN_CELL,bottom=top+TERRAIN_CELL;
    return right>box.left-pad&&left<box.right+pad&&bottom>box.top-pad&&top<box.bottom+pad;
  }

  function terrainCellProtected(gx,gy) {
    if(LOCATION_ORDER.some(id=>townLocationActive(id)&&(()=>{
      const footprint=townBuildingGeometry(id).footprint;
      return terrainCellOverlapsBox(gx,gy,footprint,24);
    })()))return true;
    return townPlacedDecor.some(item=>{
      if(!TOWN_DECOR_BUILDING_ART[item.type])return false;
      const size=townDecorSize(item),top=item.y+size.height-78;
      return terrainCellOverlapsBox(gx,gy,{left:item.x,right:item.x+size.width,top,bottom:item.y+size.height+4},24);
    });
  }

  function clearTerrainUnderBuilding(id) {
    const footprint=townBuildingGeometry(id).footprint;
    Object.keys(townTerrain.cells).forEach(key=>{
      const [gx,gy]=key.split(",").map(Number);
      if(terrainCellOverlapsBox(gx,gy,footprint,24))delete townTerrain.cells[key];
    });
  }

  function clearTerrainUnderDecorBuilding(item) {
    if(!item||!TOWN_DECOR_BUILDING_ART[item.type])return;
    const size=townDecorSize(item),top=item.y+size.height-78;
    Object.keys(townTerrain.cells).forEach(key=>{
      const [gx,gy]=key.split(",").map(Number);
      if(terrainCellOverlapsBox(gx,gy,{left:item.x,right:item.x+size.width,top,bottom:item.y+size.height+4},24))delete townTerrain.cells[key];
    });
  }

  function sanitizeTownTerrainLayout() {
    let changed=false;
    LOCATION_ORDER.forEach(id=>{
      if(!townLocationActive(id))return;
      const current=TOWN_LOCATION_POINTS[id],fitted=fitTownBuildingPlacement(id,current);
      if(current.x!==fitted.x||current.y!==fitted.y){TOWN_LOCATION_POINTS[id]=fitted;changed=true;}
    });
    townPlacedDecor.forEach(item=>{
      const fitted=fitTownDecorPosition(item);
      if(item.x!==fitted.x||item.y!==fitted.y){item.x=fitted.x;item.y=fitted.y;changed=true;}
    });
    const usedNpcIds=new Set();townPlacedNpcs=townPlacedNpcs.filter(item=>item&&NPCS[item.npcId]).slice(0,200).map((item,index)=>{
      const entity=normalizeNpcEntity(item,index,TOWN_SIZE.width,TOWN_SIZE.height,"town-npc"),base=entity.id;let id=base,suffix=2;while(usedNpcIds.has(id))id=`${base}-${suffix++}`;usedNpcIds.add(id);entity.id=id;
      if(entity.visible&&entity.collision&&!canTownStaticMove(entity.x,entity.y,14)){const point=nearestTownWalkablePoint(entity);if(point.x!==entity.x||point.y!==entity.y){entity.x=point.x;entity.y=point.y;changed=true;}}
      return entity;
    });
    Object.keys(townTerrain.cells).forEach(key=>{
      const [gx,gy]=key.split(",").map(Number);
      if(!terrainGridInBounds(gx,gy)||terrainCellProtected(gx,gy)){
        delete townTerrain.cells[key];changed=true;
      }
    });
    if(changed)saveTownEditorLayout();
  }

  function createLocationMarkers() {
    const container = $("#location-markers");
    container.replaceChildren();
    LOCATION_ORDER.forEach((id, index) => {
      const loc = LOCATIONS[id];
      const button = document.createElement("button");
      button.type = "button";
      button.className = "location-marker";
      button.dataset.location = id;
      const point = locationPoint(id);
      button.setAttribute("aria-label", `${loc.name}. Walk to the door and press E to enter.`);
      const copy = document.createElement("span");
      copy.className = "marker-copy";
      const title = document.createElement("b");
      title.textContent = loc.short;
      const subtitle = document.createElement("span");
      subtitle.textContent = loc.subtitle;
      copy.append(title, subtitle);
      button.append(copy);
      button.addEventListener("pointerdown", event => {
        if(townEditMode) beginTownEditorDrag(event,"house",id,locationPoint(id));
      });
      button.addEventListener("click", event => {
        if(townEditMode){ event.preventDefault(); return; }
        selectedIndex = index;
        renderMap();
        setTownMoveDestination(townBuildingGeometry(id).doorPoint,`${loc.short}'s front door`);
      });
      container.append(button);
    });
    syncLocationMarkerGeometry();
    drawTownLevel();
    renderTownEditorHandles();
  }

  function townPointerPosition(event) {
    const rect=$("#town-world").getBoundingClientRect();
    return {x:event.clientX-rect.left,y:event.clientY-rect.top};
  }

  function beginTownEditorDrag(event,kind,key,point) {
    if(!townEditMode) return;
    event.preventDefault(); event.stopPropagation();
    const npcEntity=kind==="npc"?townPlacedNpcs.find(entity=>entity.id===key):null;
    if(npcEntity?.locked){townEditorSelection={kind,key};renderTownEditorHandles();return;}
    recordTownEditorHistory();
    const cursor=townPointerPosition(event);
    townEditorSelection={kind,key};
    townEditorDrag={kind,key,offsetX:cursor.x-point.x,offsetY:cursor.y-point.y};
    event.currentTarget.setPointerCapture?.(event.pointerId);
    renderTownEditorHandles();
  }

  function moveTownEditorDrag(event) {
    if(!townEditorDrag) return;
    event.preventDefault();
    const cursor=townPointerPosition(event);
    const snap=townEditorDrag.kind==="house"?16:8;
    const x=clamp(Math.round((cursor.x-townEditorDrag.offsetX)/snap)*snap,0,TOWN_SIZE.width-96);
    const y=clamp(Math.round((cursor.y-townEditorDrag.offsetY)/snap)*snap,0,TOWN_SIZE.height-96);
    if(townEditorDrag.kind==="house") {
      TOWN_LOCATION_POINTS[townEditorDrag.key]=fitTownBuildingPlacement(townEditorDrag.key,{x,y});
      syncLocationMarkerGeometry();
    } else if(townEditorDrag.kind==="tree") TOWN_TREE_POINTS[Number(townEditorDrag.key)]=[x,y];
    else if(townEditorDrag.kind==="nature"){
      const point=townNaturePoints[Number(townEditorDrag.key)];if(point){const width=TOWN_NATURE_DISPLAY[point[0]]||64,height=point[0]==="grass"?width*2:width;point[1]=clamp(x,0,TOWN_SIZE.width-width);point[2]=clamp(y,0,TOWN_SIZE.height-height);}
    }
    else if(townEditorDrag.kind==="npc"){
      const entity=townPlacedNpcs.find(item=>item.id===townEditorDrag.key);if(entity){entity.x=clamp(x,36,TOWN_SIZE.width-36);entity.y=clamp(y,80,TOWN_SIZE.height-24);}
      renderTownNpcEntities();
    }
    else {
      const item=townPlacedDecor.find(entry=>entry.id===townEditorDrag.key);
      if(item){const fitted=fitTownDecorPosition(item,x,y);item.x=fitted.x;item.y=fitted.y;}
    }
    drawTownLevel();
    renderTownEditorHandles();
  }

  function finishTownEditorDrag() {
    if(!townEditorDrag) return;
    if(townEditorDrag.kind==="house")clearTerrainUnderBuilding(townEditorDrag.key);
    else if(townEditorDrag.kind==="decor")clearTerrainUnderDecorBuilding(townPlacedDecor.find(item=>item.id===townEditorDrag.key));
    else if(townEditorDrag.kind==="npc"){
      const entity=townPlacedNpcs.find(item=>item.id===townEditorDrag.key);if(entity?.visible&&entity.collision&&!canTownStaticMove(entity.x,entity.y,14)){const point=nearestTownWalkablePoint(entity);entity.x=point.x;entity.y=point.y;}
    }
    townEditorDrag=null;
    saveTownEditorLayout();
    renderTownNpcEntities();
    townWaterFrame=-1;
    drawTownLevel();
    drawTownWater(performance.now());
    renderTownEditorHandles();
  }

  function renderTownEditorHandles() {
    const layer=$("#town-editor-layer");
    if(!layer) return;
    layer.replaceChildren();
    const map=$("#town-map");
    map?.classList.toggle("town-editing",townEditMode);
    map?.classList.toggle("terrain-tool-active",townEditMode&&Boolean(townTerrainTool));
    map?.classList.toggle("grid-visible",townEditMode&&Boolean($("#terrain-grid-toggle")?.checked));
    if(!townEditMode){$$(".location-marker").forEach(marker=>marker.classList.remove("editor-selected"));return;}
    TOWN_TREE_POINTS.forEach((point,index)=>createTownEditorHandle(layer,"tree",String(index),point[0],point[1],96,96));
    townNaturePoints.forEach(([kind,x,y],index)=>{const width=TOWN_NATURE_DISPLAY[kind]||64,height=kind==="grass"?width*2:width;createTownEditorHandle(layer,"nature",String(index),x,y,width,height,kind);});
    townPlacedDecor.forEach(item=>{const size=townDecorSize(item);createTownEditorHandle(layer,"decor",item.id,item.x,item.y,size.width,size.height);});
    townPlacedNpcs.forEach(entity=>createTownNpcEditorHandle(layer,entity));
    $$(".location-marker").forEach(marker=>marker.classList.toggle("editor-selected",townEditorSelection?.kind==="house"&&townEditorSelection.key===marker.dataset.location));
    const selectedNpc=townEditorSelection?.kind==="npc"?townPlacedNpcs.find(entity=>entity.id===townEditorSelection.key):null;
    const editable=townEditorSelection&&(townEditorSelection.kind!=="house"||townFoundationMode==="founded");
    $("#town-delete-item").disabled=!editable||Boolean(selectedNpc?.locked);
    $("#town-duplicate-item").disabled=!editable||townEditorSelection?.kind==="house";
    const selectedLabel=$("#town-editor-selection");
    if(selectedLabel)selectedLabel.textContent=!townEditorSelection?"Nothing selected":townEditorSelection.kind==="house"?LOCATIONS[townEditorSelection.key]?.short||"Building":townEditorSelection.kind==="tree"?"Tree":townEditorSelection.kind==="nature"?friendlyAssetLabel(townNaturePoints[Number(townEditorSelection.key)]?.[0]||"Nature"):townEditorSelection.kind==="npc"?NPCS[selectedNpc?.npcId]?.name||"NPC":townPlacedDecor.find(item=>item.id===townEditorSelection.key)?.type||"Object";
    renderTownNpcInspector();
    updateTownEditorHistoryControls();
    renderTownTerrainOverlay();
  }

  function createTownEditorHandle(layer,kind,key,x,y,width,height,label="") {
    const handle=document.createElement("button");
    handle.type="button"; handle.className="town-editor-handle";
    handle.dataset.kind=kind; handle.dataset.key=key;
    handle.title=label?`${friendlyAssetLabel(label)} · drag to move`:kind==="tree"?"Tree · drag to move":"Town object · drag to move";handle.setAttribute("aria-label",handle.title);
    handle.style.left=`${x}px`; handle.style.top=`${y}px`; handle.style.width=`${width}px`; handle.style.height=`${height}px`;
    handle.classList.toggle("selected",townEditorSelection?.kind===kind&&String(townEditorSelection.key)===String(key));
    handle.addEventListener("pointerdown",event=>beginTownEditorDrag(event,kind,key,{x,y}));
    layer.append(handle);
  }

  function createTownNpcEditorHandle(layer,entity) {
    const handle=document.createElement("button");handle.type="button";handle.className="town-editor-handle npc-handle";handle.dataset.kind="npc";handle.dataset.key=entity.id;
    handle.style.left=`${entity.x-38}px`;handle.style.top=`${entity.y-94}px`;handle.style.width="76px";handle.style.height="96px";
    handle.classList.toggle("selected",townEditorSelection?.kind==="npc"&&townEditorSelection.key===entity.id);handle.classList.toggle("locked",entity.locked);handle.classList.toggle("hidden-prop",!entity.visible);
    handle.title=`${NPCS[entity.npcId].name} · ${entity.behavior}${entity.locked?" · locked":""}${!entity.visible?" · hidden":""}`;
    handle.addEventListener("pointerdown",event=>beginTownEditorDrag(event,"npc",entity.id,{x:entity.x,y:entity.y}));layer.append(handle);
  }

  function setTownEditorToolsCollapsed(collapsed) {
    townEditorToolsCollapsed=Boolean(collapsed);const tools=$(".town-edit-tools"),button=$("#town-tools-collapse"),palette=$("#town-edit-palette");
    tools?.classList.toggle("tools-collapsed",townEditorToolsCollapsed);button?.classList.toggle("hidden",!townEditMode);palette?.classList.toggle("hidden",!townEditMode||townEditorToolsCollapsed);
    if(button){button.textContent=townEditorToolsCollapsed?"☰ Tools":"× Hide Tools";button.setAttribute("aria-expanded",String(!townEditorToolsCollapsed));}
  }

  function townDecorSize(item) {
    const type=typeof item==="string"?item:item?.type;
    if(type==="asset") return {width:clamp(Number(item.width)||96,8,640),height:clamp(Number(item.height)||96,8,640)};
    return TOWN_DECOR_BUILDING_ART[type]||({tree:{width:96,height:96},flower:{width:48,height:40},bench:{width:96,height:48},pond:{width:160,height:112},path:{width:128,height:64}})[type]||{width:96,height:96};
  }

  function fitTownDecorPosition(item,x=item.x,y=item.y) {
    const size=townDecorSize(item),next={x:clamp(Number(x)||0,0,TOWN_SIZE.width-size.width),y:clamp(Number(y)||0,0,TOWN_SIZE.height-size.height)};
    if(townUsesAuthoredBase()&&TOWN_DECOR_BUILDING_ART[item.type]&&next.x+size.width>TOWN_RIVER_BLOCK.left&&next.x<TOWN_RIVER_BLOCK.right){
      const shiftLeft=next.x+size.width-TOWN_RIVER_BLOCK.left,shiftRight=TOWN_RIVER_BLOCK.right-next.x;
      next.x=clamp(next.x+(shiftLeft<shiftRight?-shiftLeft:shiftRight),0,TOWN_SIZE.width-size.width);
    }
    return next;
  }

  function addTownDecor(type) {
    const viewport=$("#town-map").getBoundingClientRect();
    const world=$("#town-world").getBoundingClientRect();
    const size=townDecorSize(type);
    const x=clamp(Math.round((viewport.left+viewport.width/2-world.left-size.width/2)/8)*8,0,TOWN_SIZE.width-size.width);
    const y=clamp(Math.round((viewport.top+viewport.height/2-world.top-size.height/2)/8)*8,0,TOWN_SIZE.height-size.height);
    const item={id:`decor-${Date.now()}-${Math.random().toString(16).slice(2)}`,type,x,y};
    Object.assign(item,fitTownDecorPosition(item,x,y));
    recordTownEditorHistory();
    townPlacedDecor.push(item); townEditorSelection={kind:"decor",key:item.id};
    clearTerrainUnderDecorBuilding(item);
    saveTownEditorLayout(); drawTownLevel(); renderTownEditorHandles();
  }

  function selectedTownNpcEntity(){return townEditorSelection?.kind==="npc"?townPlacedNpcs.find(entity=>entity.id===townEditorSelection.key)||null:null;}

  function addTownNpcEntity(npcId) {
    if(!NPCS[npcId])return;
    if(townPlacedNpcs.length>=200){showTownPrompt("Town NPC limit reached (200)",1800);return;}
    const viewport=$("#town-map").getBoundingClientRect(),world=$("#town-world").getBoundingClientRect();
    const x=clamp(Math.round((viewport.left+viewport.width/2-world.left)/8)*8,36,TOWN_SIZE.width-36),y=clamp(Math.round((viewport.top+viewport.height/2-world.top)/8)*8,80,TOWN_SIZE.height-24);
    const walkable=nearestTownWalkablePoint({x,y}),entity=normalizeNpcEntity({id:uniqueNpcEntityId("town-npc",townPlacedNpcs),npcId,x:walkable.x,y:walkable.y},townPlacedNpcs.length,TOWN_SIZE.width,TOWN_SIZE.height,"town-npc");
    recordTownEditorHistory();townPlacedNpcs.push(entity);townEditorSelection={kind:"npc",key:entity.id};saveTownEditorLayout();renderTownNpcEntities();renderTownEditorHandles();showTownPrompt(`${NPCS[npcId].name} placed as an interactive NPC`,1800);
  }

  function mutateSelectedTownNpc(mutator) {
    const entity=selectedTownNpcEntity();if(!entity)return;
    recordTownEditorHistory();mutator(entity);Object.assign(entity,normalizeNpcEntity(entity,townPlacedNpcs.indexOf(entity),TOWN_SIZE.width,TOWN_SIZE.height,"town-npc"));if(entity.visible&&entity.collision&&!canTownStaticMove(entity.x,entity.y,14)){const point=nearestTownWalkablePoint(entity);entity.x=point.x;entity.y=point.y;}saveTownEditorLayout();renderTownNpcEntities();renderTownEditorHandles();
  }

  function renderTownNpcInspector() {
    const inspector=$("#town-npc-inspector"),entity=selectedTownNpcEntity();if(!inspector)return;
    inspector.classList.toggle("hidden",!entity);$("#town-npc-count").textContent=`${townPlacedNpcs.length} placed`;if(!entity)return;
    $("#town-npc-selected-name").textContent=`${NPCS[entity.npcId].avatar} ${NPCS[entity.npcId].name}`;$("#town-npc-x").value=String(entity.x);$("#town-npc-y").value=String(entity.y);$("#town-npc-behavior").value=entity.behavior;$("#town-npc-facing").value=entity.facing;$("#town-npc-collision").checked=entity.collision;$("#town-npc-visible").checked=entity.visible;$("#town-npc-locked").checked=entity.locked;
  }

  function populateTownNpcSelect() {
    const select=$("#town-npc-select");if(!select)return;select.replaceChildren();
    Object.values(NPCS).sort((a,b)=>a.name.localeCompare(b.name)).forEach(npc=>{const option=document.createElement("option");option.value=npc.id;option.textContent=`${npc.avatar} ${npc.name} — ${npc.role}`;select.append(option);});
  }

  function deleteTownEditorItem() {
    if(!townEditorSelection||(townEditorSelection.kind==="house"&&townFoundationMode!=="founded")) return;
    if(townEditorSelection.kind==="npc"&&townPlacedNpcs.find(entity=>entity.id===townEditorSelection.key)?.locked)return;
    recordTownEditorHistory();
    if(townEditorSelection.kind==="house")TOWN_LOCATION_POINTS[townEditorSelection.key]={...TOWN_LOCATION_POINTS[townEditorSelection.key],active:false};
    else if(townEditorSelection.kind==="tree") TOWN_TREE_POINTS.splice(Number(townEditorSelection.key),1);
    else if(townEditorSelection.kind==="nature")townNaturePoints.splice(Number(townEditorSelection.key),1);
    else if(townEditorSelection.kind==="npc")townPlacedNpcs=townPlacedNpcs.filter(entity=>entity.id!==townEditorSelection.key);
    else townPlacedDecor=townPlacedDecor.filter(item=>item.id!==townEditorSelection.key);
    townEditorSelection=null;syncLocationMarkerGeometry();updateFoundingTools();saveTownEditorLayout();renderTownNpcEntities();drawTownLevel();renderTownEditorHandles();syncTownResidents(true);
  }

  function duplicateTownEditorItem() {
    if(!townEditorSelection||townEditorSelection.kind==="house")return;
    if(townEditorSelection.kind==="npc"&&townPlacedNpcs.length>=200){showTownPrompt("Town NPC limit reached (200)",1800);return;}
    recordTownEditorHistory();
    if(townEditorSelection.kind==="tree"){
      const source=TOWN_TREE_POINTS[Number(townEditorSelection.key)];if(!source)return;
      TOWN_TREE_POINTS.push([clamp(source[0]+32,0,TOWN_SIZE.width-96),clamp(source[1]+32,0,TOWN_SIZE.height-96)]);
      townEditorSelection={kind:"tree",key:String(TOWN_TREE_POINTS.length-1)};
    } else if(townEditorSelection.kind==="nature"){
      const source=townNaturePoints[Number(townEditorSelection.key)];if(!source)return;const width=TOWN_NATURE_DISPLAY[source[0]]||64,height=source[0]==="grass"?width*2:width;townNaturePoints.push([source[0],clamp(source[1]+32,0,TOWN_SIZE.width-width),clamp(source[2]+32,0,TOWN_SIZE.height-height)]);townEditorSelection={kind:"nature",key:String(townNaturePoints.length-1)};
    } else if(townEditorSelection.kind==="npc"){
      const source=townPlacedNpcs.find(entity=>entity.id===townEditorSelection.key);if(!source)return;
      const copy=normalizeNpcEntity({...source,id:uniqueNpcEntityId("town-npc",townPlacedNpcs),x:source.x+32,y:source.y+32,locked:false},townPlacedNpcs.length,TOWN_SIZE.width,TOWN_SIZE.height,"town-npc");
      if(copy.visible&&copy.collision){const point=nearestTownWalkablePoint(copy);copy.x=point.x;copy.y=point.y;}
      townPlacedNpcs.push(copy);townEditorSelection={kind:"npc",key:copy.id};renderTownNpcEntities();
    } else {
      const source=townPlacedDecor.find(item=>item.id===townEditorSelection.key);if(!source)return;
      const size=townDecorSize(source),copy={...source,id:`decor-${Date.now()}-${Math.random().toString(16).slice(2)}`,x:clamp(source.x+32,0,TOWN_SIZE.width-size.width),y:clamp(source.y+32,0,TOWN_SIZE.height-size.height)};
      Object.assign(copy,fitTownDecorPosition(copy));
      townPlacedDecor.push(copy);clearTerrainUnderDecorBuilding(copy);townEditorSelection={kind:"decor",key:copy.id};
    }
    saveTownEditorLayout();drawTownLevel();renderTownEditorHandles();
  }

  function normalizedFoundTownSettings(value={}) {
    const number=(candidate,fallback)=>Number.isFinite(Number(candidate))?Number(candidate):fallback;
    return {
      seed:String(value.seed||"New Philadelphia").trim().slice(0,48)||"New Philadelphia",
      maxHeight:clamp(Math.round(number(value.maxHeight,2)),0,5),
      grass:clamp(Math.round(number(value.grass,78)),0,100),
      water:clamp(Math.round(number(value.water,8)),0,35),
      trees:clamp(Math.round(number(value.trees,28)),0,100)
    };
  }

  function terrainSeedValue(seed,x,y,salt){
    let hash=stableHash(`${seed}:${salt}`);hash^=Math.imul((x|0)+0x9e3779b9,0x85ebca6b);hash^=Math.imul((y|0)+0x632be5ab,0xc2b2ae35);hash=Math.imul(hash^(hash>>>16),0x7feb352d);hash=Math.imul(hash^(hash>>>15),0x846ca68b);return ((hash^(hash>>>16))>>>0)/4294967296;
  }
  function terrainValueNoise(seed,gx,gy,salt,scale=6){
    const x=gx/scale,y=gy/scale,x0=Math.floor(x),y0=Math.floor(y),tx=x-x0,ty=y-y0,smooth=value=>value*value*(3-2*value),sx=smooth(tx),sy=smooth(ty),mix=(a,b,t)=>a+(b-a)*t;
    const north=mix(terrainSeedValue(seed,x0,y0,salt),terrainSeedValue(seed,x0+1,y0,salt),sx),south=mix(terrainSeedValue(seed,x0,y0+1,salt),terrainSeedValue(seed,x0+1,y0+1,salt),sx);
    return mix(north,south,sy);
  }

  function treeConflictsWithTownBuild([x,y]) {
    const cx=x+48,cy=y+76;
    if(LOCATION_ORDER.some(id=>townLocationActive(id)&&(()=>{const box=townBuildingGeometry(id).footprint;return cx>box.left-36&&cx<box.right+36&&cy>box.top-36&&cy<box.bottom+36;})()))return true;
    return townPlacedDecor.some(item=>{const size=townDecorSize(item);return cx>item.x-24&&cx<item.x+size.width+24&&cy>item.y-24&&cy<item.y+size.height+24;});
  }

  function generateFoundedLand(rawSettings) {
    const settings=normalizedFoundTownSettings(rawSettings),columns=Math.ceil(TOWN_SIZE.width/TERRAIN_CELL),rows=Math.ceil(TOWN_SIZE.height/TERRAIN_CELL),records=[];
    for(let gy=0;gy<rows;gy+=1)for(let gx=0;gx<columns;gx+=1)records.push({gx,gy,waterNoise:terrainValueNoise(settings.seed,gx,gy,"water",7),grassNoise:terrainValueNoise(settings.seed,gx,gy,"grass",5),heightNoise:terrainValueNoise(settings.seed,gx,gy,"height",8)});
    const waterCount=Math.round(records.length*settings.water/100),waterKeys=new Set(records.slice().sort((a,b)=>a.waterNoise-b.waterNoise).slice(0,waterCount).map(item=>terrainKey(item.gx,item.gy))),dry=records.filter(item=>!waterKeys.has(terrainKey(item.gx,item.gy))),grassCount=Math.round(dry.length*settings.grass/100),grassKeys=new Set(dry.slice().sort((a,b)=>a.grassNoise-b.grassNoise).slice(0,grassCount).map(item=>terrainKey(item.gx,item.gy))),cells={};
    records.forEach(item=>{
      const key=terrainKey(item.gx,item.gy),nearSpawn=Math.hypot(item.gx-Math.floor(columns/2),item.gy-Math.floor(rows/2))<3.2;
      const surface=nearSpawn?"grass":waterKeys.has(key)?"water":grassKeys.has(key)?"grass":"dirt",elevation=nearSpawn?0:surface==="water"?-1:Math.round(item.heightNoise*settings.maxHeight);
      if(surface!=="grass"||elevation!==0)cells[key]={surface,elevation};
    });
    townTerrain={cells};
    const treeTarget=Math.round(120*settings.trees/100),candidates=records.filter(item=>{
      const cell=terrainCellAtGrid(item.gx,item.gy);return cell.surface==="grass"&&cell.elevation<=Math.min(2,settings.maxHeight)&&Math.hypot(item.gx-columns/2,item.gy-rows/2)>3.4;
    }).sort((a,b)=>terrainSeedValue(settings.seed,a.gx,a.gy,"trees")-terrainSeedValue(settings.seed,b.gx,b.gy,"trees"));
    const trees=[];for(const item of candidates){if(trees.length>=treeTarget)break;const x=item.gx*TERRAIN_CELL+Math.floor(terrainSeedValue(settings.seed,item.gx,item.gy,"tree-x")*24),y=item.gy*TERRAIN_CELL-20+Math.floor(terrainSeedValue(settings.seed,item.gx,item.gy,"tree-y")*24),point=[clamp(x,0,TOWN_SIZE.width-96),clamp(y,0,TOWN_SIZE.height-96)];if(trees.some(([tx,ty])=>Math.hypot(tx-point[0],ty-point[1])<92)||treeConflictsWithTownBuild(point))continue;trees.push(point);}
    TOWN_TREE_POINTS=trees;townGenerationSettings=settings;
    return settings;
  }

  function createFoundedTown(rawSettings) {
    townFoundationMode="founded";
    TOWN_LOCATION_POINTS=Object.fromEntries(Object.entries(DEFAULT_TOWN_LOCATION_POINTS).map(([id,point])=>[id,{...point,active:false}]));
    townNaturePoints=[];townPlacedDecor=[];townPlacedNpcs=[];townEditorSelection=null;
    return generateFoundedLand(rawSettings);
  }

  function updateFoundingTools() {
    const panel=$("#town-founding-tools");if(!panel)return;const founded=townFoundationMode==="founded";panel.classList.toggle("hidden",!founded);if(!founded){$("#town-reset-layout").textContent="Reset Town";return;}
    const select=$("#town-landmark-select"),inactive=LOCATION_ORDER.filter(id=>!townLocationActive(id));select.replaceChildren();inactive.forEach(id=>{const option=document.createElement("option");option.value=id;option.textContent=`${LOCATIONS[id].short} — ${LOCATIONS[id].subtitle}`;select.append(option);});if(!inactive.length){const option=document.createElement("option");option.textContent="All destinations placed";option.value="";select.append(option);}select.disabled=!inactive.length;$("#town-landmark-add").disabled=!inactive.length;$("#town-landmark-count").textContent=`${LOCATION_ORDER.length-inactive.length} of ${LOCATION_ORDER.length} placed`;$("#town-reset-layout").textContent="Reset Empty Town";
  }

  function addTownLandmark(id) {
    if(townFoundationMode!=="founded"||!LOCATIONS[id]||townLocationActive(id))return;
    recordTownEditorHistory();const point=fitTownBuildingPoint(id,{x:townPosition.x,y:townPosition.y-40});TOWN_LOCATION_POINTS[id]={...point,active:true};clearTerrainUnderBuilding(id);townEditorSelection={kind:"house",key:id};syncLocationMarkerGeometry();updateFoundingTools();saveTownEditorLayout();drawTownLevel();renderTownEditorHandles();syncTownResidents(true);showTownPrompt(`${LOCATIONS[id].short} placed · drag the building to move it`,2200);
  }

  function regenerateFoundedTerrain() {
    if(townFoundationMode!=="founded")return;recordTownEditorHistory();const current=normalizedFoundTownSettings(townGenerationSettings||{}),settings={...current,seed:`${current.seed.replace(/\s+#\d+$/,'')} #${(stableHash(`${current.seed}:${Date.now()}`)%9999)+1}`};generateFoundedLand(settings);sanitizeTownTerrainLayout();saveTownEditorLayout();drawTownLevel();townWaterFrame=-1;drawTownWater(performance.now());renderTownEditorHandles();showTownPrompt(`Land regenerated from seed “${settings.seed}”`,2200);
  }

  function resetTownEditorLayout() {
    const founded=townFoundationMode==="founded";if(!window.confirm(founded?"Return to a fresh empty plot using the current terrain settings?":"Reset every overworld building, decoration, NPC, road, and terrain edit to the default layout?"))return;
    recordTownEditorHistory();
    if(founded)createFoundedTown(townGenerationSettings||{});else {townFoundationMode="authored";townGenerationSettings=null;TOWN_LOCATION_POINTS=Object.fromEntries(Object.entries(DEFAULT_TOWN_LOCATION_POINTS).map(([id,p])=>[id,{...p}]));TOWN_TREE_POINTS=DEFAULT_TOWN_TREE_POINTS.map(point=>[...point]);townNaturePoints=DEFAULT_TOWN_NATURE_POINTS.map(point=>[...point]);townPlacedDecor=[];townPlacedNpcs=[];townTerrain={cells:{}};townEditorSelection=null;}
    syncLocationMarkerGeometry();
    updateFoundingTools();saveTownEditorLayout();createTownResidents();renderTownNpcEntities();drawTownLevel();renderTownEditorHandles();
  }

  function terrainKey(gx,gy){return `${gx},${gy}`;}
  function terrainGridInBounds(gx,gy){return gx>=0&&gy>=0&&gx*TERRAIN_CELL<TOWN_SIZE.width&&gy*TERRAIN_CELL<TOWN_SIZE.height;}
  function defaultTerrainSurface(gx,gy){
    if(!townUsesAuthoredBase())return "grass";
    const x=gx*TERRAIN_CELL+TERRAIN_CELL/2,y=gy*TERRAIN_CELL+TERRAIN_CELL/2;
    const inRiver=x>=TOWN_RIVER.x&&x<TOWN_RIVER.x+TOWN_RIVER.width;
    if(inRiver&&!isTownBridgeY(y))return "water";
    return TOWN_ROADS.some(road=>x>=road.x&&x<road.x+road.w&&y>=road.y&&y<road.y+road.h)?"road":"grass";
  }
  function terrainCellAtGrid(gx,gy,cells=townTerrain.cells){
    const saved=cells[terrainKey(gx,gy)];
    return saved?normalizeTerrainCell(saved):{surface:defaultTerrainSurface(gx,gy),elevation:0};
  }
  function terrainCellAtWorld(x,y){return terrainCellAtGrid(Math.floor(x/TERRAIN_CELL),Math.floor(y/TERRAIN_CELL));}
  function writeTerrainCell(gx,gy,cell){
    const normalized=normalizeTerrainCell(cell),key=terrainKey(gx,gy);
    if(normalized.surface===defaultTerrainSurface(gx,gy)&&normalized.elevation===0)delete townTerrain.cells[key];
    else townTerrain.cells[key]=normalized;
  }

  function drawRoadTile(ctx,image,x,y,width,height,season){
    ctx.fillStyle=season.path;ctx.fillRect(x,y,width,height);
    ctx.save();ctx.beginPath();ctx.rect(x,y,width,height);ctx.clip();
    const unit=32,startX=Math.floor(x/unit)*unit,startY=Math.floor(y/unit)*unit;
    for(let py=startY;py<y+height;py+=unit)for(let px=startX;px<x+width;px+=unit){const hash=Math.abs((px/unit)*37+(py/unit)*53),stoneW=12+hash%11,stoneH=6+(hash>>2)%5;ctx.fillStyle=hash%3===0?"rgba(92,65,44,.28)":"rgba(255,232,174,.16)";ctx.fillRect(px+3+(hash%5),py+5+((hash>>3)%11),stoneW,stoneH);}
    if(season.id==="winter"){ctx.fillStyle="rgba(230,239,233,.2)";ctx.fillRect(x,y,width,height);}
    ctx.restore();
  }

  function drawTerrainSurface(ctx,images,season,gx,gy,cell){
    const x=gx*TERRAIN_CELL,y=gy*TERRAIN_CELL,variant=Math.abs(gx+gy*3)%6;
    if(cell.surface==="water"){ctx.clearRect(x,y,TERRAIN_CELL,TERRAIN_CELL);return;}
    if(cell.surface==="road")drawRoadTile(ctx,images.roadTiles,x,y,TERRAIN_CELL,TERRAIN_CELL,season);
    else if(cell.surface==="dirt"){
      ctx.fillStyle=season.id==="winter"?"#8f7c69":"#9c6b43";ctx.fillRect(x,y,TERRAIN_CELL,TERRAIN_CELL);
      ctx.fillStyle="rgba(71,47,31,.24)";
      for(let i=0;i<8;i+=1){const px=x+6+((gx*17+gy*11+i*23)%52),py=y+7+((gx*7+gy*19+i*17)%50);ctx.fillRect(px,py,i%3===0?6:3,i%2===0?3:2);}
    } else {ctx.fillStyle=season.grass;ctx.fillRect(x,y,TERRAIN_CELL,TERRAIN_CELL);ctx.fillStyle=season.grassDetail;ctx.globalAlpha=.18;for(let i=0;i<5;i+=1)ctx.fillRect(x+7+(variant*13+i*17)%52,y+8+(variant*19+i*11)%48,3,6);ctx.globalAlpha=1;}
    if(cell.elevation!==0){
      ctx.fillStyle=cell.elevation<0?`rgba(31,42,49,${Math.min(.32,Math.abs(cell.elevation)*.13)})`:`rgba(244,231,163,${Math.min(.16,cell.elevation*.035)})`;
      ctx.fillRect(x,y,TERRAIN_CELL,TERRAIN_CELL);
    }
  }

  function drawTerrainTransitions(ctx,season,gx,gy,cell){
    const x=gx*TERRAIN_CELL,y=gy*TERRAIN_CELL,neighbor=(ox,oy)=>terrainCellAtGrid(gx+ox,gy+oy);
    const north=neighbor(0,-1),east=neighbor(1,0),south=neighbor(0,1),west=neighbor(-1,0);
    if(cell.surface==="grass"||cell.surface==="dirt"){
      const colorFor=surface=>surface==="road"?season.path:surface==="dirt"?(season.id==="winter"?"#8f7c69":"#9c6b43"):season.grass;
      const blend=(side,adjacent,seed)=>{
        if(adjacent.surface===cell.surface||adjacent.surface==="water")return;
        ctx.save();ctx.globalAlpha=.72;ctx.fillStyle=colorFor(adjacent.surface);
        for(let segment=0;segment<8;segment+=1){
          const hash=Math.abs(gx*31+gy*47+segment*19+seed*13),depth=2+hash%6,along=segment*8+(hash%3),length=5+(hash%4);
          if(side==="north")ctx.fillRect(x+along,y,length,depth);
          else if(side==="south")ctx.fillRect(x+along,y+TERRAIN_CELL-depth,length,depth);
          else if(side==="west")ctx.fillRect(x,y+along,depth,length);
          else ctx.fillRect(x+TERRAIN_CELL-depth,y+along,depth,length);
        }
        ctx.restore();
      };
      blend("north",north,1);blend("east",east,2);blend("south",south,3);blend("west",west,4);
    }
    if(cell.surface==="water"){
      const shore=(side,adjacent,seed)=>{
        if(adjacent.surface==="water")return;
        ctx.save();ctx.fillStyle=season.bank;
        for(let segment=0;segment<8;segment+=1){
          const hash=Math.abs(gx*37+gy*29+segment*17+seed),depth=4+hash%5,along=segment*8-(hash%2),length=9+(hash%3);
          if(side==="north")ctx.fillRect(x+along,y,length,depth);
          else if(side==="south")ctx.fillRect(x+along,y+TERRAIN_CELL-depth,length,depth);
          else if(side==="west")ctx.fillRect(x,y+along,depth,length);
          else ctx.fillRect(x+TERRAIN_CELL-depth,y+along,depth,length);
        }
        ctx.restore();
      };
      shore("north",north,11);shore("east",east,23);shore("south",south,37);shore("west",west,51);
    }
    if(cell.surface==="road"){
      const roadEdge=(side,adjacent,seed)=>{
        if(adjacent.surface==="road")return;
        ctx.save();ctx.fillStyle="rgba(91,66,45,.42)";
        for(let segment=0;segment<8;segment+=1){
          const depth=2+Math.abs(gx*19+gy*31+segment*13+seed)%3,along=segment*8,length=6+(segment+seed)%4;
          if(side==="north")ctx.fillRect(x+along,y,length,depth);
          else if(side==="south")ctx.fillRect(x+along,y+TERRAIN_CELL-depth,length,depth);
          else if(side==="west")ctx.fillRect(x,y+along,depth,length);
          else ctx.fillRect(x+TERRAIN_CELL-depth,y+along,depth,length);
        }
        ctx.restore();
      };
      roadEdge("north",north,3);roadEdge("east",east,7);roadEdge("south",south,11);roadEdge("west",west,17);
    }
    if(cell.elevation>south.elevation){
      const difference=cell.elevation-south.elevation,depth=Math.min(30,8+difference*7),top=y+TERRAIN_CELL-depth;
      ctx.fillStyle=season.id==="winter"?"#7b7f7a":"#675a4b";ctx.fillRect(x,top,TERRAIN_CELL,depth);
      ctx.fillStyle="rgba(255,255,255,.16)";ctx.fillRect(x,top,TERRAIN_CELL,3);
      ctx.fillStyle="rgba(28,31,33,.2)";
      for(let px=x+4;px<x+TERRAIN_CELL;px+=16)ctx.fillRect(px,top+7+((px/16)%2)*8,10,4);
    }
    if(cell.elevation>west.elevation){ctx.fillStyle="rgba(42,38,33,.26)";ctx.fillRect(x,y,4,TERRAIN_CELL);}
    if(cell.elevation>east.elevation){ctx.fillStyle="rgba(42,38,33,.2)";ctx.fillRect(x+TERRAIN_CELL-4,y,4,TERRAIN_CELL);}
  }

  function drawEditedTerrain(ctx,images,season){
    const entries=Object.entries(townTerrain.cells).map(([key,value])=>({key,cell:normalizeTerrainCell(value),grid:key.split(",").map(Number)})).sort((a,b)=>a.grid[1]-b.grid[1]||a.grid[0]-b.grid[0]);
    entries.forEach(entry=>drawTerrainSurface(ctx,images,season,entry.grid[0],entry.grid[1],entry.cell));
    entries.forEach(entry=>drawTerrainTransitions(ctx,season,entry.grid[0],entry.grid[1],entry.cell));
  }

  function terrainBrushOffsets(){
    const radius=Math.max(0,(Number($("#terrain-brush-size")?.value)||2)-1),shape=$("#terrain-brush-shape")?.value||"circle",offsets=[];
    for(let oy=-radius;oy<=radius;oy+=1)for(let ox=-radius;ox<=radius;ox+=1){
      if(shape==="circle"&&Math.hypot(ox,oy)>radius+.35)continue;
      offsets.push([ox,oy]);
    }
    return offsets;
  }

  function sampleTownTerrain(gx,gy){
    const cell=terrainCellAtGrid(gx,gy),height=$("#terrain-target-height"),fill=$("#terrain-fill-material");
    if(height)height.value=String(cell.elevation);
    if(fill)fill.value=cell.surface;
    setTownTerrainTool(cell.surface);
    showTownPrompt(`Sampled ${cell.surface} · elevation ${cell.elevation}`,1800);
  }

  function floodTownTerrain(gx,gy){
    const surface=$("#terrain-fill-material")?.value||"grass",start=terrainCellAtGrid(gx,gy),queue=[[gx,gy]],visited=new Set(),maxX=Math.ceil(TOWN_SIZE.width/TERRAIN_CELL),maxY=Math.ceil(TOWN_SIZE.height/TERRAIN_CELL);
    while(queue.length&&visited.size<maxX*maxY){
      const [x,y]=queue.shift(),key=terrainKey(x,y);if(visited.has(key)||!terrainGridInBounds(x,y)||terrainCellProtected(x,y))continue;
      visited.add(key);const cell=terrainCellAtGrid(x,y);if(cell.surface!==start.surface)continue;
      writeTerrainCell(x,y,{surface,elevation:surface==="water"?-1:surface==="road"?0:cell.elevation});
      queue.push([x+1,y],[x-1,y],[x,y+1],[x,y-1]);
    }
  }

  function applyTownTerrainCell(gx,gy,snapshot){
    const key=terrainKey(gx,gy);if(!terrainGridInBounds(gx,gy)||terrainCellProtected(gx,gy)||townTerrainStrokeCells.has(key))return;
    townTerrainStrokeCells.add(key);
    const strength=Number($("#terrain-brush-strength")?.value)||1,current=terrainCellAtGrid(gx,gy),cell={...current};
    if(townTerrainTool==="raise"){cell.elevation=clamp(cell.elevation+strength,-2,5);if(cell.surface==="water"&&cell.elevation>=0)cell.surface="grass";}
    else if(townTerrainTool==="lower")cell.elevation=clamp(cell.elevation-strength,-2,5);
    else if(townTerrainTool==="flatten"){cell.elevation=0;if(cell.surface==="water")cell.surface="grass";}
    else if(townTerrainTool==="terrace"){cell.elevation=clamp(Number($("#terrain-target-height")?.value)||0,-2,5);if(cell.surface==="water"&&cell.elevation>=0)cell.surface="grass";}
    else if(townTerrainTool==="smooth"){
      const heights=[];for(let sy=-1;sy<=1;sy+=1)for(let sx=-1;sx<=1;sx+=1)heights.push(terrainCellAtGrid(gx+sx,gy+sy,snapshot).elevation);
      cell.elevation=clamp(Math.round(heights.reduce((sum,value)=>sum+value,0)/heights.length),-2,5);
    } else if(townTerrainTool==="restore"){
      cell.surface=defaultTerrainSurface(gx,gy);cell.elevation=0;
    } else if(TERRAIN_SURFACES.has(townTerrainTool)){
      cell.surface=townTerrainTool;
      if(cell.surface==="water")cell.elevation=-1;
      if(cell.surface==="road")cell.elevation=0;
    }
    writeTerrainCell(gx,gy,cell);
  }

  function applyTownTerrainBrushAt(point){
    const centerX=Math.floor(point.x/TERRAIN_CELL),centerY=Math.floor(point.y/TERRAIN_CELL);
    if(townTerrainTool==="sample"){sampleTownTerrain(centerX,centerY);townTerrainPainting=false;return;}
    if(townTerrainTool==="fill"){if(!townTerrainStrokeCells.size)floodTownTerrain(centerX,centerY);townTerrainStrokeCells.add(terrainKey(centerX,centerY));return;}
    terrainBrushOffsets().forEach(([ox,oy])=>applyTownTerrainCell(centerX+ox,centerY+oy,townTerrainStrokeSnapshot||townTerrain.cells));
  }

  function scheduleTownTerrainRender(){
    if(townTerrainRenderFrame)return;
    townTerrainRenderFrame=requestAnimationFrame(()=>{townTerrainRenderFrame=0;townWaterFrame=-1;drawTownLevel();drawTownWater(performance.now());renderTownTerrainOverlay();});
  }

  function applyTownTerrainBrush(event){
    if(!townEditMode||!townTerrainTool)return;
    const point=townPointerPosition(event),previous=townTerrainLastPoint||point,distance=Math.hypot(point.x-previous.x,point.y-previous.y),steps=Math.max(1,Math.ceil(distance/(TERRAIN_CELL*.35)));
    for(let index=1;index<=steps;index+=1)applyTownTerrainBrushAt({x:previous.x+(point.x-previous.x)*index/steps,y:previous.y+(point.y-previous.y)*index/steps});
    townTerrainLastPoint=point;scheduleTownTerrainRender();
  }

  function beginTownTerrainPaint(event){
    if(!townEditMode||!townTerrainTool||event.button>0||event.target.closest?.(".location-marker,.town-editor-handle,.town-edit-tools"))return;
    event.preventDefault();event.stopImmediatePropagation();
    if(townTerrainTool==="sample"){
      const point=townPointerPosition(event);
      sampleTownTerrain(Math.floor(point.x/TERRAIN_CELL),Math.floor(point.y/TERRAIN_CELL));
      return;
    }
    if(townTerrainTool!=="sample")recordTownEditorHistory();
    townTerrainPainting=true;townTerrainStrokeCells=new Set();townTerrainStrokeSnapshot=JSON.parse(JSON.stringify(townTerrain.cells));townTerrainLastPoint=null;
    $("#town-map").classList.add("terrain-painting");event.currentTarget.setPointerCapture?.(event.pointerId);applyTownTerrainBrush(event);
  }
  function moveTownTerrainPaint(event){if(townTerrainPainting){event.preventDefault();applyTownTerrainBrush(event);}}
  function finishTownTerrainPaint(){
    if(!townTerrainPainting)return;
    townTerrainPainting=false;townTerrainStrokeSnapshot=null;townTerrainLastPoint=null;$("#town-map")?.classList.remove("terrain-painting");
    saveTownEditorLayout();townResidents.forEach(sim=>{sim.route=[];sim.nextRoutineAt=performance.now()+500;});renderTownEditorHandles();
  }

  function setTownTerrainTool(tool){
    townTerrainTool=townTerrainTool===tool?null:tool;
    townEditorSelection=null;townEditorDrag=null;
    $$('[data-terrain-tool]').forEach(item=>item.classList.toggle("active",item.dataset.terrainTool===townTerrainTool));
    renderTownEditorHandles();
    const label=townTerrainTool?`${townTerrainTool.replace(/^(.)/,letter=>letter.toUpperCase())} tool · drag on the grid`:"Choose a brush, then paint the world";
    const status=$("#terrain-editor-status");if(status)status.textContent=label;
    showTownPrompt(townTerrainTool?label:"Terrain brush off",1800);
  }

  function updateTownTerrainHover(event){
    if(!townEditMode||!townTerrainTool)return;
    townTerrainHoverPoint=townPointerPosition(event);updateTownTerrainPreview();
  }

  function updateTownTerrainPreview(){
    const preview=$("#town-editor-layer")?.querySelector(".terrain-brush-preview");if(!preview||!townTerrainHoverPoint)return;
    preview.style.display="";
    const size=Number($("#terrain-brush-size")?.value)||2,radius=size-1,diameter=(radius*2+1)*TERRAIN_CELL,gx=Math.floor(townTerrainHoverPoint.x/TERRAIN_CELL),gy=Math.floor(townTerrainHoverPoint.y/TERRAIN_CELL);
    preview.classList.toggle("round",($("#terrain-brush-shape")?.value||"circle")==="circle");
    preview.style.left=`${(gx-radius)*TERRAIN_CELL}px`;preview.style.top=`${(gy-radius)*TERRAIN_CELL}px`;preview.style.width=`${diameter}px`;preview.style.height=`${diameter}px`;
    const cell=terrainCellAtGrid(gx,gy),status=$("#terrain-editor-status");if(status)status.textContent=`${townTerrainTool} · ${cell.surface} at elevation ${cell.elevation} · cell ${gx}, ${gy}`;
  }

  function renderTownTerrainOverlay(){
    const layer=$("#town-editor-layer");if(!layer||!townEditMode)return;
    [...layer.querySelectorAll(".terrain-height-label,.terrain-brush-preview")].forEach(element=>element.remove());
    const preview=document.createElement("span");preview.className="terrain-brush-preview";layer.append(preview);
    if($("#terrain-height-toggle")?.checked)Object.entries(townTerrain.cells).forEach(([key,value])=>{
      const [gx,gy]=key.split(",").map(Number),cell=normalizeTerrainCell(value),label=document.createElement("span");
      label.className=`terrain-height-label ${cell.surface}`;label.textContent=cell.elevation>0?`+${cell.elevation}`:String(cell.elevation);
      label.style.left=`${gx*TERRAIN_CELL+TERRAIN_CELL/2}px`;label.style.top=`${gy*TERRAIN_CELL+TERRAIN_CELL/2}px`;layer.append(label);
    });
    updateTownTerrainPreview();
  }

  function clearTownTerrainEdits(){
    if(!Object.keys(townTerrain.cells).length)return;
    if(!window.confirm("Clear terrain painting and elevation while keeping buildings and decorations?"))return;
    recordTownEditorHistory();townTerrain={cells:{}};saveTownEditorLayout();townWaterFrame=-1;drawTownLevel();drawTownWater(performance.now());renderTownEditorHandles();
  }

  function drawTownBuildingPads(ctx,images,season){
    LOCATION_ORDER.forEach(id=>{
      if(!townLocationActive(id))return;
      const geometry=townBuildingGeometry(id),pad=geometry.foundation;
      const road=TOWN_ROADS.filter(item=>item.w>item.h&&geometry.doorPoint.x>=item.x&&geometry.doorPoint.x<=item.x+item.w&&item.y>=geometry.groundY-12).sort((a,b)=>a.y-b.y)[0];
      const pathBottom=road?Math.min(road.y+8,geometry.groundY+150):geometry.groundY+84,pathTop=geometry.groundY-4;
      if(pathBottom>pathTop)drawRoadTile(ctx,images.roadTiles,geometry.doorPoint.x-32,pathTop,64,pathBottom-pathTop,season);
      ctx.fillStyle="rgba(40,53,42,.24)";ctx.fillRect(pad.left-7,pad.top+7,pad.width+14,pad.height-6);
      ctx.fillStyle=season.id==="winter"?"#c9d2c8":"#8c6a48";ctx.fillRect(pad.left,pad.top,pad.width,pad.height);
      ctx.fillStyle=season.id==="winter"?"#e6ece7":"#a98055";ctx.fillRect(pad.left+8,pad.top+6,pad.width-16,pad.height-12);
      ctx.fillStyle="rgba(74,49,33,.26)";
      for(let offset=12;offset<pad.width-8;offset+=28)ctx.fillRect(pad.left+offset,pad.top+14+(offset%3)*13,9,4);
      ctx.fillStyle="rgba(25,34,31,.28)";ctx.fillRect(geometry.left+geometry.width*.13,geometry.groundY-4,geometry.width*.74,9);
    });
  }

  function renderTownBuildings(images,season){
    const layer=$("#town-buildings");if(!layer)return;
    const existing=new Map($$(".town-building").map(canvas=>[canvas.dataset.buildingKey||`location:${canvas.dataset.location}`,canvas]));
    const getCanvas=key=>{
      let canvas=existing.get(key);
      if(!canvas){canvas=document.createElement("canvas");canvas.className="town-building";canvas.dataset.buildingKey=key;layer.append(canvas);}
      existing.delete(key);return canvas;
    };
    LOCATION_ORDER.forEach(id=>{
      if(!townLocationActive(id))return;
      const geometry=townBuildingGeometry(id),image=images[geometry.art.atlas];
      const canvas=getCanvas(`location:${id}`);canvas.dataset.location=id;
      const width=Math.ceil(geometry.width),height=Math.ceil(geometry.height);
      if(canvas.width!==width)canvas.width=width;if(canvas.height!==height)canvas.height=height;
      canvas.style.left=`${Math.round(geometry.left)}px`;canvas.style.top=`${Math.round(geometry.top)}px`;canvas.style.width=`${width}px`;canvas.style.height=`${height}px`;
      canvas.style.zIndex=String(TOWN_DEPTH_BASE+Math.round(geometry.groundY));
      const buildingCtx=canvas.getContext("2d");buildingCtx.clearRect(0,0,width,height);buildingCtx.imageSmoothingEnabled=false;
      if(image?.complete&&image.naturalWidth){
        const {sx,sy,sw,sh}=geometry.source;buildingCtx.drawImage(image,sx,sy,sw,sh,0,0,geometry.width,geometry.height);
        if(season.id==="winter"){buildingCtx.fillStyle="rgba(242,249,247,.78)";buildingCtx.fillRect(geometry.width*.12,geometry.height*.12,geometry.width*.76,8);}
      }
    });
    townPlacedDecor.filter(item=>TOWN_DECOR_BUILDING_ART[item.type]).forEach(item=>{
      const art=TOWN_DECOR_BUILDING_ART[item.type],image=images.fantasyHouses,size=townDecorSize(item),canvas=getCanvas(`decor:${item.id}`),width=Math.ceil(size.width),height=Math.ceil(size.height),[sx,sy,sw,sh]=art.crop;
      delete canvas.dataset.location;
      if(canvas.width!==width)canvas.width=width;if(canvas.height!==height)canvas.height=height;
      canvas.style.left=`${Math.round(item.x)}px`;canvas.style.top=`${Math.round(item.y)}px`;canvas.style.width=`${width}px`;canvas.style.height=`${height}px`;
      canvas.style.zIndex=String(TOWN_DEPTH_BASE+Math.round(item.y+height-10));
      const buildingCtx=canvas.getContext("2d");buildingCtx.clearRect(0,0,width,height);buildingCtx.imageSmoothingEnabled=false;
      if(image?.complete&&image.naturalWidth){
        const scale=Math.min(width/sw,height/sh),dw=sw*scale,dh=sh*scale;
        buildingCtx.drawImage(image,sx,sy,sw,sh,(width-dw)/2,height-dh,dw,dh);
        if(season.id==="winter"){buildingCtx.fillStyle="rgba(242,249,247,.7)";buildingCtx.fillRect(width*.14,height*.13,width*.72,7);}
      }
    });
    existing.forEach(canvas=>canvas.remove());
    syncLocationMarkerGeometry();
  }

  function drawTownBridges(ctx){
    TOWN_BRIDGES.forEach(bridge=>{
      const x=TOWN_RIVER.x-32,y=bridge.y,w=TOWN_RIVER.width+64,h=bridge.height;
      ctx.fillStyle="rgba(20,35,45,.34)";ctx.fillRect(x+10,y+12,w,h-8);
      ctx.fillStyle="rgba(20,35,45,.18)";ctx.fillRect(x+18,y+20,w-16,h-16);
      ctx.fillStyle="#875b39";ctx.fillRect(x,y,w,h);ctx.fillStyle="#bd8551";
      for(let px=x+6;px<x+w-5;px+=22)ctx.fillRect(px,y+5,16,h-10);
    });
  }

  function renderTownDepthScenery(images,season){
    const layer=$("#town-scenery");if(!layer)return;const existing=new Map($$(".town-depth-item").map(canvas=>[canvas.dataset.sceneryKey,canvas]));
    const render=(key,x,y,width,height,groundY,paint)=>{let canvas=existing.get(key);if(!canvas){canvas=document.createElement("canvas");canvas.className="town-depth-item";canvas.dataset.sceneryKey=key;layer.append(canvas);}existing.delete(key);const w=Math.max(1,Math.ceil(width)),h=Math.max(1,Math.ceil(height));if(canvas.width!==w)canvas.width=w;if(canvas.height!==h)canvas.height=h;canvas.style.left=`${Math.round(x)}px`;canvas.style.top=`${Math.round(y)}px`;canvas.style.width=`${w}px`;canvas.style.height=`${h}px`;canvas.style.zIndex=String(TOWN_DEPTH_BASE+Math.round(groundY));const itemCtx=canvas.getContext("2d");itemCtx.clearRect(0,0,w,h);itemCtx.imageSmoothingEnabled=false;animatedEditorCanvases.delete(canvas);delete canvas._editorAssetPaint;paint(itemCtx,w,h,canvas);};
    if(images.trees.complete&&images.trees.naturalWidth)TOWN_TREE_POINTS.forEach(([x,y],index)=>{if(terrainCellAtWorld(x+48,y+72).surface==="water")return;render(`tree:${index}`,x,y,96,96,y+88,itemCtx=>{itemCtx.save();itemCtx.filter=season.treeFilter;if(index%2===0)itemCtx.drawImage(images.trees,0,32,32,32,16,32,64,64);else itemCtx.drawImage(images.trees,32,16,48,48,0,0,96,96);itemCtx.restore();});});
    townNaturePoints.forEach(([kind,x,y],index)=>{const width=TOWN_NATURE_DISPLAY[kind]||64,height=kind==="grass"?width*2:width,image=images[kind];if(terrainCellAtWorld(x+width/2,y+height*.7).surface==="water"||!image?.complete||!image.naturalWidth)return;render(`nature:${index}`,x,y,width,height,y+height*.86,(itemCtx,w,h)=>{itemCtx.save();if(["bushA","bushB","plantA","plantB","grass"].includes(kind))itemCtx.filter=season.treeFilter;if(kind==="grass")itemCtx.drawImage(image,TOWN_MATURE_GRASS_FRAME_X,0,16,32,0,0,w,h);else itemCtx.drawImage(image,0,0,image.naturalWidth,image.naturalHeight,0,0,w,h);itemCtx.restore();});});
    townPlacedDecor.forEach((item,index)=>{if(item.type==="pond"||item.type==="path"||TOWN_DECOR_BUILDING_ART[item.type])return;const size=townDecorSize(item),key=`decor:${item.id||index}`;
      render(key,item.x,item.y,size.width,size.height,item.y+size.height*.88,(itemCtx,w,h,canvas)=>{
        if(item.type==="asset"){configureEditorAssetCanvas(canvas,getLevelImage(item.src),{sx:item.sx,sy:item.sy,sw:item.sw,sh:item.sh},item.animation);}
        else if(item.type==="tree"&&images.trees.complete&&images.trees.naturalWidth){itemCtx.save();itemCtx.filter=season.treeFilter;itemCtx.drawImage(images.trees,32,16,48,48,0,0,w,h);itemCtx.restore();}
        else if(item.type==="flower")[[8,18,"#f18d86"],[22,8,"#f3d45f"],[34,20,"#d8eff0"]].forEach(([ox,oy,color])=>{itemCtx.fillStyle="#34733b";itemCtx.fillRect(ox+3,oy+5,4,14);itemCtx.fillStyle=color;itemCtx.fillRect(ox,oy,10,10);});
        else if(item.type==="bench"){itemCtx.fillStyle="#68472e";itemCtx.fillRect(6,10,84,10);itemCtx.fillRect(10,27,76,9);itemCtx.fillRect(16,36,8,12);itemCtx.fillRect(72,36,8,12);itemCtx.fillStyle="#bd8551";for(let px=10;px<88;px+=18)itemCtx.fillRect(px,12,13,5);}
      });
    });
    existing.forEach(canvas=>canvas.remove());
  }

  function drawTownLevel() {
    const canvas = $("#town-canvas");
    if (!canvas) return;
    const ctx = canvas.getContext("2d");
    const sources = {
      trees: "assets/Ranch Stuff/assets/tiles/tree_01_16x16.png",
      water: "assets/Ranch Stuff/assets/tiles/water_01_16x16_5frames.png",
      roadTiles:"assets/Ranch Stuff/assets/tiles/ground_01_16x16.png",
      fantasyHouses:"assets/haydeos/Fantasy Houses Tileset/Fantasy Houses Tileset.png",
      greatWarHouses:"assets/haydeos/Great War RPG Maker Houses/GW_Houses_1.png",
      bushA:"assets/More Tilesets/Flying Islands/PNG/Objects_separately/Bush1_1.png",
      bushB:"assets/More Tilesets/Flying Islands/PNG/Objects_separately/Bush2_1.png",
      plantA:"assets/More Tilesets/Flying Islands/PNG/Objects_separately/Plant1_1.png",
      plantB:"assets/More Tilesets/Flying Islands/PNG/Objects_separately/Plant2_1.png",
      mushroom:"assets/More Tilesets/cursed land/PNG/Objects_separately/Mushrooms_shadow1_1.png",
      rock:"assets/More Tilesets/Flying Islands/PNG/Objects_separately/Rock_grass_shadow1.png",
      smallRock:"assets/More Tilesets/Flying Islands/PNG/Objects_separately/Small_rock_grass_shadow1.png",
      grass:"assets/Ranch Stuff/assets/crops/tallgrass/growth_basic/tallgrass_16x32_6frames.png"
    };
    const images = Object.fromEntries(Object.entries(sources).map(([key,src]) => [key,getLevelImage(src)]));
    const paint = () => {
      const season=currentSeason();
      const weather=currentWeather();
      ctx.imageSmoothingEnabled = false;
      ctx.clearRect(0,0,TOWN_SIZE.width,TOWN_SIZE.height);
      ctx.fillStyle = season.grass;
      ctx.fillRect(0,0,TOWN_SIZE.width,TOWN_SIZE.height);
      ctx.fillStyle = season.grassDetail;
      ctx.globalAlpha=.24;
      for (let y=12;y<TOWN_SIZE.height;y+=32) for (let x=(y%64);x<TOWN_SIZE.width;x+=47) ctx.fillRect(x,y,3,6);
      ctx.globalAlpha=1;
      // Small tile-aligned flower and long-grass clusters keep open ground readable
      // without turning traversal lanes into visual noise.
      if(townUsesAuthoredBase()){
        const flowerColors=season.id==="autumn"?["#df9a3c","#b95b42","#f1d37a"]:season.id==="winter"?["#eef7f5","#c9dcd7","#ffffff"]:["#f3d45f","#f18d86","#d8eff0"];
        for(let y=96;y<TOWN_SIZE.height-80;y+=160) for(let x=112+(y%96);x<TOWN_SIZE.width-80;x+=224){
          if(x>1450&&x<1770) continue;
          ctx.fillStyle="#3d873f"; ctx.fillRect(x,y+8,4,10); ctx.fillRect(x+10,y+12,4,8);
          ctx.fillStyle=flowerColors[(x+y)%flowerColors.length]; ctx.fillRect(x-3,y+3,9,7); ctx.fillRect(x+7,y+7,9,7);
        }
      }

      if(townUsesAuthoredBase()){
        ctx.fillStyle="rgba(88,61,42,.18)";
        TOWN_ROADS.forEach(road=>ctx.fillRect(road.x-8,road.y-8,road.w+16,road.h+16));
        TOWN_ROADS.forEach(road=>{
          ctx.save();ctx.beginPath();ctx.rect(road.x,road.y,road.w,road.h);ctx.clip();
          for(let py=road.y;py<road.y+road.h;py+=64)for(let px=road.x;px<road.x+road.w;px+=64)drawRoadTile(ctx,images.roadTiles,px,py,64,64,season);
          ctx.restore();
        });
        ctx.clearRect(TOWN_RIVER.x,0,TOWN_RIVER.width,TOWN_SIZE.height);
        ctx.fillStyle=season.bank;
        ctx.fillRect(TOWN_RIVER.x-16,0,16,TOWN_SIZE.height);
        ctx.fillRect(TOWN_RIVER.x+TOWN_RIVER.width,0,16,TOWN_SIZE.height);
      }

      drawEditedTerrain(ctx,images,season);
      if(townUsesAuthoredBase())drawTownBridges(ctx);

      drawTownBuildingPads(ctx,images,season);

      drawPlacedTownDecor(ctx,images,true);

      if(weather.category==="rain") {
        ctx.fillStyle=`rgba(79,126,145,${.08 + weather.intensity*.035})`;
        [[260,770,72,12],[860,830,92,14],[1310,760,58,10],[1840,820,110,14],[2240,744,64,11]].forEach(([x,y,w,h])=>ctx.fillRect(x,y,w,h));
      }

      renderTownDepthScenery(images,season);
      renderTownBuildings(images,season);
      townWaterFrame=-1;drawTownWater(performance.now());
    };
    Object.values(images).forEach(image => { if(!image.complete) image.addEventListener("load",paint,{once:true}); });
    paint();
  }

  function drawTownWater(timestamp=0) {
    const frame=Math.floor(timestamp/180)%5;
    if(frame===townWaterFrame)return;
    const canvas=$("#town-water-canvas");if(!canvas)return;
    const image=getLevelImage("assets/Ranch Stuff/assets/tiles/water_01_16x16_5frames.png");
    if(!image.complete||!image.naturalWidth){
      if(!townWaterWaiting){townWaterWaiting=true;image.addEventListener("load",()=>{townWaterWaiting=false;townWaterFrame=-1;drawTownWater(performance.now());},{once:true});}
      return;
    }
    townWaterFrame=frame;
    const ctx=canvas.getContext("2d");ctx.imageSmoothingEnabled=false;ctx.clearRect(0,0,canvas.width,canvas.height);
    const waterTile=32;
    if(townUsesAuthoredBase())for(let y=0;y<TOWN_SIZE.height;y+=waterTile)for(let x=TOWN_RIVER.x;x<TOWN_RIVER.x+TOWN_RIVER.width;x+=waterTile)ctx.drawImage(image,frame*16,0,16,16,x,y,waterTile,waterTile);
    Object.entries(townTerrain.cells).forEach(([key,cell])=>{
      if(normalizeTerrainCell(cell).surface!=="water")return;
      const [gx,gy]=key.split(",").map(Number),x=gx*TERRAIN_CELL,y=gy*TERRAIN_CELL;
      for(let py=y;py<y+TERRAIN_CELL;py+=waterTile)for(let px=x;px<x+TERRAIN_CELL;px+=waterTile)ctx.drawImage(image,frame*16,0,16,16,px,py,waterTile,waterTile);
    });
    townPlacedDecor.filter(item=>item.type==="pond").forEach(item=>{const size=townDecorSize(item);for(let py=item.y;py<item.y+size.height;py+=waterTile)for(let px=item.x;px<item.x+size.width;px+=waterTile)ctx.drawImage(image,frame*16,0,16,16,px,py,waterTile,waterTile);});
  }

  function drawPlacedTownDecor(ctx,images,underlay) {
    townPlacedDecor.forEach((item,index) => {
      const {type,x,y}=item;
      const decorBuilding=Boolean(TOWN_DECOR_BUILDING_ART[type]);
      if(underlay !== (type==="pond"||type==="path"||decorBuilding)) return;
      const size=townDecorSize(item);
      if(decorBuilding){
        ctx.fillStyle="rgba(40,53,42,.24)";ctx.fillRect(x+size.width*.06,y+size.height-61,size.width*.88,65);
        ctx.fillStyle=currentSeason().id==="winter"?"#cbd4cb":"#99734d";ctx.fillRect(x+size.width*.1,y+size.height-65,size.width*.8,61);
        ctx.fillStyle=currentSeason().id==="winter"?"#e5ece6":"#b28a5f";ctx.fillRect(x+size.width*.14,y+size.height-57,size.width*.72,47);
        ctx.fillStyle="rgba(29,42,48,.24)";ctx.fillRect(x+size.width*.16,y+size.height-7,size.width*.68,9);
      } else if(type==="path") {
        drawRoadTile(ctx,images.roadTiles,x,y,size.width,size.height,currentSeason());
      } else if(type==="pond") {
        ctx.fillStyle="#477b3f"; ctx.fillRect(x-8,y-8,size.width+16,size.height+16);
        ctx.clearRect(x,y,size.width,size.height);
      } else if(type==="asset") {
        const image=getLevelImage(item.src);
        if(image.complete&&image.naturalWidth) {
          const sourceWidth=Math.min(item.sw,image.naturalWidth-item.sx),sourceHeight=Math.min(item.sh,image.naturalHeight-item.sy);
          if(sourceWidth>0&&sourceHeight>0)ctx.drawImage(image,item.sx,item.sy,sourceWidth,sourceHeight,x,y,size.width,size.height);
        }
        else image.addEventListener("load",drawTownLevel,{once:true});
      } else if(type==="tree"&&images.trees.complete&&images.trees.naturalWidth) {
        ctx.save();ctx.filter=currentSeason().treeFilter;
        ctx.drawImage(images.trees,32,16,48,48,x,y,96,96);
        ctx.restore();
      } else if(type==="flower") {
        [[8,18,"#f18d86"],[22,8,"#f3d45f"],[34,20,"#d8eff0"]].forEach(([ox,oy,color])=>{ctx.fillStyle="#34733b";ctx.fillRect(x+ox+3,y+oy+5,4,14);ctx.fillStyle=color;ctx.fillRect(x+ox,y+oy,10,10);});
      } else if(type==="bench") {
        ctx.fillStyle="#68472e";ctx.fillRect(x+6,y+10,84,10);ctx.fillRect(x+10,y+27,76,9);ctx.fillRect(x+16,y+36,8,12);ctx.fillRect(x+72,y+36,8,12);
        ctx.fillStyle="#bd8551";for(let px=x+10;px<x+88;px+=18)ctx.fillRect(px,y+12,13,5);
      }
    });
  }

  function locationPoint(id) {
    return TOWN_LOCATION_POINTS[id] || TOWN_LOCATION_POINTS.cafe;
  }

  function createTownScenery() {
    const layer = $("#town-scenery");
    layer.replaceChildren();
    const trees = [[75,90],[165,170],[285,80],[530,130],[665,235],[1435,85],[1650,170],[1530,470],[90,910],[210,1040],[565,1010],[700,930],[1470,1030],[1690,910],[1300,620]];
    const flowers = [[320,530],[380,560],[610,690],[690,720],[1015,475],[990,750],[1450,620],[1560,680],[520,360]];
    const lamps = [[720,440],[1040,440],[720,735],[1030,735],[470,600],[1310,600]];
    const benches = [[680,510],[1020,680],[650,675],[1040,510]];
    [[trees,"town-tree"],[flowers,"town-flower"],[lamps,"town-lamp"],[benches,"town-bench"]].forEach(([items,className]) => {
      items.forEach(([x,y]) => {
        const item = document.createElement("span");
        item.className = className;
        item.style.left = `${x}px`;
        item.style.top = `${y}px`;
        layer.append(item);
      });
    });
  }

  function residentPoint(npcId,locationId) {
    const p=locationPoint(locationId),hash=stableHash(`${npcId}:${locationId}`);
    const offsets=[[-82,126],[0,132],[82,126],[-118,165],[118,165],[0,178]],offset=offsets[hash%offsets.length];
    return nearestTownWalkablePoint({x:clamp(p.x+offset[0],45,TOWN_SIZE.width-45),y:clamp(p.y+offset[1],85,TOWN_SIZE.height-45)});
  }

  function residentRoutineStop(sim) {
    const entry=npcScheduleEntry(sim.npcId),base=residentPoint(sim.npcId,entry.location),job=npcWorkplace(sim.npcId),home=npcHome(sim.npcId),role=sim.npc.role.split("·")[0].trim().toLowerCase(),phase=sim.routineStep++,offsets=[[0,0],[52,10],[-48,18],[28,52],[-24,50]],offset=offsets[(phase+stableHash(sim.npcId))%offsets.length];
    let activities;
    if(entry.location===job)activities=[`Checking ${role} supplies`,`Helping a neighbor at ${LOCATIONS[job].short}`,`Finishing a careful ${role} task`,`Taking a proper work break`];
    else if(entry.location===home)activities=["Preparing supper at home","Tending the doorstep","Catching up with a neighbor","Settling in for the evening"];
    else if(entry.location==="market")activities=["Comparing today’s market prices","Picking up household supplies","Trading news with a merchant","Checking the public scales"];
    else activities=[`Meeting friends at ${LOCATIONS[entry.location].short}`,"Sharing a meal with neighbors","Enjoying a quiet break","Checking in on the community"];
    return{point:nearestTownWalkablePoint({x:base.x+offset[0],y:base.y+offset[1]}),activity:activities[phase%activities.length]};
  }

  function syncResidentPurpose(sim) {
    const workplace=LOCATIONS[npcWorkplace(sim.npcId)]?.name||"town",home=LOCATIONS[npcHome(sim.npcId)]?.name||"home",label=sim.element.querySelector("span");if(label)label.textContent=`${sim.npc.name} · ${sim.activity}`;sim.element.title=`${sim.npc.name}\n${sim.activity}\nWork: ${workplace}\nHome: ${home}`;sim.element.setAttribute("aria-label",`${sim.npc.name}. ${sim.activity}`);
  }

  function activeTownResidentIds() {
    const ranked=Object.keys(NPCS).map(npcId=>({npcId,entry:npcScheduleEntry(npcId),rank:stableHash(`${state.day}:${state.slot}:${npcId}`)})).sort((a,b)=>a.rank-b.rank);
    const chosen=[],occupied=new Set();
    ranked.forEach(candidate=>{
      if(chosen.length>=MAX_TOWN_RESIDENTS||occupied.has(candidate.entry.location)||!townLocationActive(candidate.entry.location))return;
      occupied.add(candidate.entry.location);chosen.push(candidate.npcId);
    });
    return chosen;
  }

  function nearestTownWalkablePoint(point) {
    if(canTownStaticMove(point.x,point.y,15))return point;
    for(let ring=1;ring<=7;ring+=1){
      for(let oy=-ring;oy<=ring;oy+=1)for(let ox=-ring;ox<=ring;ox+=1){
        if(Math.abs(ox)!==ring&&Math.abs(oy)!==ring)continue;
        const candidate={x:clamp(Math.round(point.x/TOWN_NAV_GRID)*TOWN_NAV_GRID+ox*TOWN_NAV_GRID,40,TOWN_SIZE.width-40),y:clamp(Math.round(point.y/TOWN_NAV_GRID)*TOWN_NAV_GRID+oy*TOWN_NAV_GRID,70,TOWN_SIZE.height-40)};
        if(canTownStaticMove(candidate.x,candidate.y,15))return candidate;
      }
    }
    return{x:620,y:1080};
  }

  function residentRoute(from,to) {
    const start=nearestTownWalkablePoint(from),goal=nearestTownWalkablePoint(to),key=(x,y)=>`${x},${y}`;
    const snap=point=>({x:clamp(Math.round(point.x/TOWN_NAV_GRID)*TOWN_NAV_GRID,TOWN_NAV_GRID,TOWN_SIZE.width-TOWN_NAV_GRID),y:clamp(Math.round(point.y/TOWN_NAV_GRID)*TOWN_NAV_GRID,TOWN_NAV_GRID*2,TOWN_SIZE.height-TOWN_NAV_GRID)}),startNode=snap(start),goalNode=snap(goal),startKey=key(startNode.x,startNode.y),parents=new Map([[startKey,null]]),nodes=new Map([[startKey,startNode]]),costs=new Map([[startKey,0]]),open=[];
    const heuristic=node=>(Math.abs(node.x-goalNode.x)+Math.abs(node.y-goalNode.y))/TOWN_NAV_GRID*.72;
    const push=item=>{open.push(item);let index=open.length-1;while(index>0){const parent=(index-1)>>1;if(open[parent].score<=item.score)break;open[index]=open[parent];index=parent;}open[index]=item;};
    const pop=()=>{const first=open[0],last=open.pop();if(open.length&&last){let index=0;while(true){const left=index*2+1,right=left+1;if(left>=open.length)break;const child=right<open.length&&open[right].score<open[left].score?right:left;if(open[child].score>=last.score)break;open[index]=open[child];index=child;}open[index]=last;}return first;};
    const stepCost=node=>{const surface=terrainCellAtWorld(node.x,node.y).surface,nearEndpoint=Math.min(Math.hypot(node.x-startNode.x,node.y-startNode.y),Math.hypot(node.x-goalNode.x,node.y-goalNode.y))<TOWN_NAV_GRID*4;let cost=surface==="road"?.72:surface==="dirt"?1.25:3.6;if(nearEndpoint)cost=Math.min(cost,1.05);return cost+Math.abs(terrainCellAtWorld(node.x,node.y).elevation)*.08;};
    push({node:startNode,key:startKey,cost:0,score:heuristic(startNode)});let found=null,visited=0;
    while(open.length&&visited++<16000){
      const current=pop(),node=current.node,nodeKey=current.key;if(current.cost!==costs.get(nodeKey))continue;
      if(Math.abs(node.x-goalNode.x)<=TOWN_NAV_GRID&&Math.abs(node.y-goalNode.y)<=TOWN_NAV_GRID){found=nodeKey;break;}
      [[TOWN_NAV_GRID,0],[-TOWN_NAV_GRID,0],[0,TOWN_NAV_GRID],[0,-TOWN_NAV_GRID]].forEach(([ox,oy])=>{
        const next={x:node.x+ox,y:node.y+oy},nextKey=key(next.x,next.y);if(!canTownStaticMove(next.x,next.y,15)||!canTownTerrainStep(node.x,node.y,next.x,next.y))return;
        const nextCost=current.cost+stepCost(next);if(nextCost>=Number(costs.get(nextKey)??Infinity))return;costs.set(nextKey,nextCost);parents.set(nextKey,nodeKey);nodes.set(nextKey,next);push({node:next,key:nextKey,cost:nextCost,score:nextCost+heuristic(next)});
      });
    }
    if(!found)return[goal];
    const reverse=[];while(found){reverse.push(nodes.get(found));found=parents.get(found);}
    const route=reverse.reverse().slice(1).filter((node,index,array)=>index===array.length-1||index===0||(node.x-array[index-1].x)!==(array[index+1].x-node.x)||(node.y-array[index-1].y)!==(array[index+1].y-node.y));
    route.push(goal);return route;
  }

  function manualMoveVector() {
    let x=0,y=0;
    if(heldKeys.has("arrowleft")||heldKeys.has("a"))x-=1;
    if(heldKeys.has("arrowright")||heldKeys.has("d"))x+=1;
    if(heldKeys.has("arrowup")||heldKeys.has("w"))y-=1;
    if(heldKeys.has("arrowdown")||heldKeys.has("s"))y+=1;
    x+=gamepadMove.x||0;y+=gamepadMove.y||0;
    const magnitude=Math.hypot(x,y);
    if(!magnitude)return{x:0,y:0,magnitude:0};
    const travel=Math.min(1,magnitude);
    return{x:x/magnitude*travel,y:y/magnitude*travel,magnitude:travel};
  }

  function routeMoveVector(position,route,arrivalDistance=12) {
    while(route.length&&Math.hypot(route[0].x-position.x,route[0].y-position.y)<=arrivalDistance)route.shift();
    if(!route.length)return{x:0,y:0,magnitude:0};
    const dx=route[0].x-position.x,dy=route[0].y-position.y,length=Math.hypot(dx,dy)||1;
    return{x:dx/length,y:dy/length,magnitude:1};
  }

  function moveTargetIndicator(id,world) {
    let indicator=$("#"+id);
    if(!indicator){indicator=document.createElement("span");indicator.id=id;indicator.className="move-target-indicator";indicator.setAttribute("aria-hidden","true");world.append(indicator);}
    return indicator;
  }

  function showMoveTarget(id,world,x,y) {
    const indicator=moveTargetIndicator(id,world);indicator.style.left=`${Math.round(x)}px`;indicator.style.top=`${Math.round(y)}px`;indicator.classList.remove("hidden");indicator.classList.remove("pulse");void indicator.offsetWidth;indicator.classList.add("pulse");
  }

  function hideMoveTarget(id) { $("#"+id)?.classList.add("hidden"); }

  function clearAutoMovement(context="all") {
    if(context==="all"||context==="town"){townMoveRoute=[];townRouteBlockedFor=0;hideMoveTarget("town-move-target");}
    if(context==="all"||context==="interior"){interiorMoveRoute=[];interiorRouteBlockedFor=0;hideMoveTarget("interior-move-target");}
  }

  function setTownMoveDestination(point,label="marked spot") {
    if(townEditMode||isVisible("start-screen")||isVisible("location-sheet"))return;
    const goal=nearestTownWalkablePoint({x:clamp(point.x,40,TOWN_SIZE.width-40),y:clamp(point.y,70,TOWN_SIZE.height-40)});
    townMoveRoute=residentRoute(townPosition,goal);townRouteBlockedFor=0;showMoveTarget("town-move-target",$("#town-world"),goal.x,goal.y);showTownPrompt(`Walking to ${label} · move manually to cancel`,1500);$("#town-map")?.focus({preventScroll:true});
  }

  function handleTownClickMove(event) {
    if(event.button!==0||!event.isPrimary||townEditMode||isVisible("start-screen")||isVisible("location-sheet"))return;
    if(event.target.closest("button,input,select,textarea,a,[contenteditable='true']"))return;
    setTownMoveDestination(townPointerPosition(event));
  }

  function addTownResident(npcId,immediate=true) {
    const layer=$("#town-npcs"),npc=NPCS[npcId];if(!layer||!npc)return;
    const button=document.createElement("button");button.type="button";button.className="town-resident";button.dataset.npc=npcId;
    const visual=document.createElement("canvas");visual.width=112;visual.height=112;visual.className="town-resident-sprite";
    const label=document.createElement("span");label.textContent=npc.name;button.append(visual,label);layer.append(button);
    const entry=npcScheduleEntry(npcId),point=residentPoint(npcId,entry.location);
    const sim={npcId,npc,element:button,visual,x:point.x,y:point.y,direction:"south",moving:false,location:entry.location,activity:entry.activity,route:[],goal:point,routineStep:0,nextRoutineAt:performance.now()+4200+(stableHash(npcId)%4200),blockedFor:0};
    townResidents.set(npcId,sim);
    syncResidentPurpose(sim);
    button.addEventListener("click",event=>{event.stopPropagation();talkToTownResident(sim);});
    if(!immediate){const previous=npcScheduleEntry(npcId,Math.max(0,state.slot-1),state.day),origin=residentPoint(npcId,previous.location);sim.x=origin.x;sim.y=origin.y;sim.route=residentRoute(sim,point);}
  }

  function createTownResidents() {
    const layer=$("#town-npcs");if(!layer)return;layer.replaceChildren();townResidents.clear();
    getLevelImage("assets/Sci-Fi Magic UI & VFX/Sci-Fi Magic UI & VFX Spritesheet – 2D Game Assets (HUD, Icons, Effects, PNG Sheet).png");
    activeTownResidentIds().forEach(npcId=>addTownResident(npcId,true));
    residentScheduleKey="";syncTownResidents(true);
  }

  function syncTownResidents(immediate=false) {
    if(!state)return;
    const key=`${state.day}:${state.slot}:${state.weather}`;if(key===residentScheduleKey&&!immediate)return;
    const changed=residentScheduleKey&&residentScheduleKey!==key;residentScheduleKey=key;
    const activeIds=activeTownResidentIds(),activeSet=new Set(activeIds);
    [...townResidents.entries()].forEach(([npcId,sim])=>{if(!activeSet.has(npcId)){sim.element.remove();townResidents.delete(npcId);}});
    activeIds.forEach(npcId=>{if(!townResidents.has(npcId))addTownResident(npcId,immediate);});
    townResidents.forEach(sim=>{
      const entry=npcScheduleEntry(sim.npcId),target=residentPoint(sim.npcId,entry.location);
      sim.activity=entry.activity;syncResidentPurpose(sim);
      sim.goal=target;
      if(immediate){sim.x=target.x;sim.y=target.y;sim.route=[];}else if(sim.location!==entry.location)sim.route=residentRoute(sim,target);
      sim.location=entry.location;sim.routineStep=0;sim.nextRoutineAt=performance.now()+2200+(stableHash(sim.npcId)%5000);
    });
    if(changed){const travelers=[...townResidents.values()].filter(sim=>sim.route.length).slice(0,4);travelers.forEach((sim,index)=>window.setTimeout(()=>spawnTownVfx(sim.x,sim.y,index%2?"gold":"social"),index*120));}
  }

  function spriteFramePlan(sprite,direction,moving,animationIndex,image){
    const width=sprite.w||image.naturalWidth,height=sprite.h||image.naturalHeight,x=sprite.x||0,y=sprite.y||0;
    if(sprite.layout==="directionRects"){
      const values=sprite.directionRects?.[direction]||sprite.directionRects?.south||[x,y,width,height],rect={x:values[0],y:values[1],w:values[2],h:values[3]};
      return {current:rect,sequence:[rect]};
    }
    if(sprite.layout==="actionRows"){
      const count=moving?(sprite.walkFrames||8):(sprite.idleFrames||6),row=moving?1:0,frame=((animationIndex%count)+count)%count;
      const sequence=Array.from({length:count},(_,index)=>({x:x+index*width,y:y+row*height,w:width,h:height}));
      return {current:sequence[frame],sequence};
    }
    if(sprite.layout==="strip"){
      const count=Math.max(1,sprite.frameCount||Math.floor((sprite.sheetWidth||image.naturalWidth)/width)),frame=moving?animationIndex%count:Math.min(sprite.idleFrame??1,count-1);
      const sequence=Array.from({length:count},(_,index)=>({x:x+index*width,y,w:width,h:height}));
      return {current:sequence[frame],sequence};
    }
    const looksRpg=sprite.layout==="rpg"||image.naturalHeight>=y+height*4;
    if(looksRpg){
      const row={south:0,west:1,east:2,north:3}[direction]||0,frame=moving?animationIndex%3:Math.min(sprite.idleFrame??1,2);
      const sequence=Array.from({length:3},(_,index)=>({x:x+index*width,y:y+row*height,w:width,h:height}));
      return {current:sequence[frame],sequence};
    }
    const count=Math.max(1,Math.min(sprite.frameCount||Math.floor((sprite.sheetWidth||image.naturalWidth)/width),8)),frame=moving?animationIndex%count:0;
    const sequence=Array.from({length:count},(_,index)=>({x:x+index*width,y,w:width,h:height}));
    return {current:sequence[frame],sequence};
  }

  function opaqueUnionBounds(image,rects,key){
    let bounds=residentSpriteBounds.get(key);if(bounds)return bounds;
    const width=Math.max(...rects.map(rect=>rect.w)),height=Math.max(...rects.map(rect=>rect.h)),scratch=document.createElement("canvas");scratch.width=width;scratch.height=height;
    const scratchCtx=scratch.getContext("2d",{willReadFrequently:true});let left=width,top=height,right=-1,bottom=-1;
    rects.forEach(rect=>{
      scratchCtx.clearRect(0,0,width,height);scratchCtx.drawImage(image,rect.x,rect.y,rect.w,rect.h,0,0,rect.w,rect.h);
      const pixels=scratchCtx.getImageData(0,0,rect.w,rect.h).data;
      for(let py=0;py<rect.h;py+=1)for(let px=0;px<rect.w;px+=1)if(pixels[(py*rect.w+px)*4+3]>20){left=Math.min(left,px);right=Math.max(right,px);top=Math.min(top,py);bottom=Math.max(bottom,py);}
    });
    bounds=right>=left?{x:left,y:top,w:right-left+1,h:bottom-top+1}:{x:0,y:0,w:width,h:height};residentSpriteBounds.set(key,bounds);return bounds;
  }

  function paintTownResident(sim,timestamp) {
    const sprite=sim.npc.sprite,animationIndex=Math.floor(timestamp/(sim.moving?135:320)),fileFrames=typeof sprite.walkFrames==="string";let source,plan;
    if(sprite.directions)source=`${sprite.directions}${sim.direction}.png`;
    else if(fileFrames){
      const direction={north:"Back",south:"Front",east:"Right",west:"Left"}[sim.direction],frame=sim.moving?animationIndex%3:0;
      source=`${sprite.walkFrames}/${direction}/Standing/${direction}_Standing_Walk_${frame+1}.png`;
    } else source=sprite.sheet;
    const image=getLevelImage(source);if(!image.complete||!image.naturalWidth)return;
    if(sprite.directions||fileFrames){const rect={x:0,y:0,w:image.naturalWidth,h:image.naturalHeight};plan={current:rect,sequence:[rect]};}
    else plan=spriteFramePlan(sprite,sim.direction,sim.moving,animationIndex,image);
    const boundsKey=`${source}:${sim.direction}:${sim.moving?"move":"idle"}:${plan.sequence.map(rect=>`${rect.x},${rect.y},${rect.w},${rect.h}`).join("|")}`,[boundX,boundY,boundW,boundH]=sprite.contentBounds||[],relative=sprite.contentBounds?{x:boundX,y:boundY,w:boundW,h:boundH}:opaqueUnionBounds(image,plan.sequence,boundsKey),sourceRect={x:plan.current.x+relative.x,y:plan.current.y+relative.y,w:relative.w,h:relative.h};
    const animalIds=new Set(["pigford","petunia","emberwing","scraps","whistle","marmalade"]),fallbackHeight=animalIds.has(sim.npcId)?52:sim.npcId==="milo"?60:76,targetHeight=sprite.displayHeight??fallbackHeight,bob=sim.moving?Math.sin(timestamp/105)*1.2:0,scale=targetHeight/sourceRect.h,dw=sourceRect.w*scale,dh=targetHeight;
    const ctx=sim.visual.getContext("2d");ctx.clearRect(0,0,112,112);ctx.imageSmoothingEnabled=false;
    ctx.save();ctx.fillStyle="rgba(24,36,43,.24)";ctx.beginPath();ctx.ellipse(56,105,Math.max(10,Math.min(25,dw*.42)),5,0,0,Math.PI*2);ctx.fill();ctx.restore();
    ctx.drawImage(image,sourceRect.x,sourceRect.y,sourceRect.w,sourceRect.h,56-dw/2,105-dh+bob,dw,dh);
  }

  function paintNpcEntityCanvas(canvas,npcId,direction="south",moving=false,timestamp=performance.now()) {
    const npc=NPCS[npcId];if(!canvas||!npc)return;
    paintTownResident({npcId,npc,visual:canvas,direction:NPC_ENTITY_FACINGS.has(direction)?direction:"south",moving:Boolean(moving)},timestamp);
  }

  function renderTownNpcEntities() {
    const layer=$("#town-custom-npcs");if(!layer)return;
    layer.replaceChildren();townCustomNpcSims.clear();
    townPlacedNpcs.forEach(entity=>{
      const npc=NPCS[entity.npcId];if(!npc)return;
      const button=document.createElement("button");button.type="button";button.className="placed-npc-entity";button.dataset.entityId=entity.id;button.dataset.npc=entity.npcId;button.hidden=!entity.visible&&!townEditMode;button.classList.toggle("entity-hidden",!entity.visible);
      const visual=document.createElement("canvas");visual.width=112;visual.height=112;const label=document.createElement("span");label.textContent=npc.name;button.append(visual,label);layer.append(button);
      const sim={entity,npcId:entity.npcId,npc,element:button,visual,x:entity.x,y:entity.y,direction:entity.facing,moving:false,route:[],goal:{x:entity.x,y:entity.y},nextRoutineAt:performance.now()+1400+(stableHash(entity.id)%3000),activity:"Editor-placed resident"};
      townCustomNpcSims.set(entity.id,sim);button.addEventListener("click",event=>{event.stopPropagation();talkToTownResident(sim);});
      button.style.left=`${sim.x}px`;button.style.top=`${sim.y}px`;button.style.zIndex=String(TOWN_DEPTH_BASE+Math.round(sim.y));paintNpcEntityCanvas(visual,entity.npcId,sim.direction,false,performance.now());
    });
  }

  function canTownNpcEntityStep(sim,x,y) {
    if(!canTownStaticMove(x,y,14)||!canTownTerrainStep(sim.x,sim.y,x,y)||Math.hypot(x-townPosition.x,y-townPosition.y)<35)return false;
    if([...townResidents.values()].some(other=>Math.hypot(x-other.x,y-other.y)<31))return false;
    return ![...townCustomNpcSims.values()].some(other=>other!==sim&&other.entity.visible&&Math.hypot(x-other.x,y-other.y)<31);
  }

  function updateTownNpcEntities(dt,timestamp) {
    townCustomNpcSims.forEach(sim=>{
      const entity=sim.entity;sim.element.hidden=!entity.visible&&!townEditMode;sim.element.classList.toggle("entity-hidden",!entity.visible);
      if(townEditMode){sim.x=entity.x;sim.y=entity.y;sim.direction=entity.facing;sim.route=[];sim.moving=false;}
      else if(entity.behavior==="face-player"){
        const dx=townPosition.x-sim.x,dy=townPosition.y-sim.y;sim.direction=Math.abs(dx)>Math.abs(dy)?(dx>0?"east":"west"):(dy>0?"south":"north");sim.moving=false;
      } else if(entity.behavior==="wander"){
        if(!sim.route.length&&timestamp>=sim.nextRoutineAt){
          const phase=Math.floor(timestamp/3200)+stableHash(entity.id),angle=(phase%8)*Math.PI/4,distance=48+(phase%3)*24,target=nearestTownWalkablePoint({x:clamp(entity.x+Math.cos(angle)*distance,40,TOWN_SIZE.width-40),y:clamp(entity.y+Math.sin(angle)*distance,70,TOWN_SIZE.height-40)});sim.goal=target;sim.route=residentRoute(sim,target);sim.nextRoutineAt=timestamp+4200+(stableHash(`${entity.id}:${phase}`)%3200);
        }
        const target=sim.route[0];if(target){const dx=target.x-sim.x,dy=target.y-sim.y,distance=Math.hypot(dx,dy);if(distance<3){sim.x=target.x;sim.y=target.y;sim.route.shift();}else{const step=Math.min(.052*dt,distance),nx=sim.x+dx/distance*step,ny=sim.y+dy/distance*step;if(canTownNpcEntityStep(sim,nx,ny)){sim.x=nx;sim.y=ny;}else sim.route=[];sim.direction=Math.abs(dx)>Math.abs(dy)?(dx>0?"east":"west"):(dy>0?"south":"north");}sim.moving=Boolean(sim.route.length);}else sim.moving=false;
      } else {sim.direction=entity.facing;sim.moving=false;}
      sim.element.style.left=`${sim.x}px`;sim.element.style.top=`${sim.y}px`;sim.element.style.zIndex=String(TOWN_DEPTH_BASE+Math.round(sim.y));paintNpcEntityCanvas(sim.visual,entity.npcId,sim.direction,sim.moving,timestamp);
    });
  }

  function canTownResidentStep(sim,x,y) {
    if(!canTownStaticMove(x,y,15)||!canTownTerrainStep(sim.x,sim.y,x,y))return false;
    if(Math.hypot(x-townPosition.x,y-townPosition.y)<38&&Math.hypot(x-townPosition.x,y-townPosition.y)<=Math.hypot(sim.x-townPosition.x,sim.y-townPosition.y))return false;
    const blockedByResident=[...townResidents.values()].some(other=>other!==sim&&Math.hypot(x-other.x,y-other.y)<34&&Math.hypot(x-other.x,y-other.y)<=Math.hypot(sim.x-other.x,sim.y-other.y));
    if(blockedByResident)return false;
    return ![...townCustomNpcSims.values()].some(other=>other.entity.visible&&other.entity.collision&&Math.hypot(x-other.x,y-other.y)<34&&Math.hypot(x-other.x,y-other.y)<=Math.hypot(sim.x-other.x,sim.y-other.y));
  }

  function residentStepAroundTraffic(sim,dx,dy,step) {
    const distance=Math.hypot(dx,dy)||1,ux=dx/distance,uy=dy/distance,lane=stableHash(sim.npcId)%2?1:-1,candidates=[[ux,uy],[ux*.58-uy*.92*lane,uy*.58+ux*.92*lane],[ux*.58+uy*.92*lane,uy*.58-ux*.92*lane],[-uy*lane,ux*lane]];
    for(const [mx,my] of candidates){const length=Math.hypot(mx,my)||1,x=sim.x+mx/length*step,y=sim.y+my/length*step;if(canTownResidentStep(sim,x,y))return{x,y};}
    return null;
  }

  function updateTownResidents(dt,timestamp) {
    syncTownResidents();
    townResidents.forEach(sim=>{
      if(!sim.route.length&&timestamp>sim.nextRoutineAt){
        const routine=residentRoutineStop(sim);sim.activity=routine.activity;sim.goal=routine.point;sim.route=residentRoute(sim,routine.point);sim.nextRoutineAt=timestamp+5000+(stableHash(`${sim.npcId}:${sim.routineStep}`)%3500);syncResidentPurpose(sim);
      }
      const target=sim.route[0];let dx=0,dy=0;
      if(target){
        dx=target.x-sim.x;dy=target.y-sim.y;const distance=Math.hypot(dx,dy);
        if(distance<3){sim.x=target.x;sim.y=target.y;sim.route.shift();sim.blockedFor=0;if(!sim.route.length)sim.nextRoutineAt=timestamp+5200+(stableHash(`${sim.npcId}:pause:${sim.routineStep}`)%4800);}
        else{
          const speed=.065*dt,step=Math.min(speed,distance),next=residentStepAroundTraffic(sim,dx,dy,step);
          if(next){sim.x=next.x;sim.y=next.y;sim.blockedFor=0;}else{sim.blockedFor+=dt;if(sim.blockedFor>720){sim.route=residentRoute(sim,sim.goal);sim.blockedFor=0;sim.nextRoutineAt=timestamp+1600+(stableHash(sim.npcId)%1200);}}
          sim.direction=Math.abs(dx)>Math.abs(dy)?(dx>0?"east":"west"):(dy>0?"south":"north");
        }
      }
      sim.moving=Boolean(target)&&sim.blockedFor===0;sim.element.classList.toggle("walking",sim.moving);sim.element.style.left=`${sim.x}px`;sim.element.style.top=`${sim.y}px`;sim.element.style.zIndex=String(TOWN_DEPTH_BASE+Math.round(sim.y));paintTownResident(sim,timestamp);
    });
    if(state.weather==="thunderstorm"&&timestamp-lastTownVfxAt>3200){lastTownVfxAt=timestamp;const residents=[...townResidents.values()];const sim=residents[Math.floor(timestamp/3200)%residents.length];if(sim)spawnTownVfx(sim.x,sim.y-30,"lightning");}
    updateTownNpcEntities(dt,timestamp);
  }

  function spawnTownVfx(x,y,kind="social") {
    const layer=$("#town-npcs"),image=getLevelImage("assets/Sci-Fi Magic UI & VFX/Sci-Fi Magic UI & VFX Spritesheet – 2D Game Assets (HUD, Icons, Effects, PNG Sheet).png");if(!layer||!image.complete||!image.naturalWidth)return;
    const crops={social:[90,510,82,92],gold:[615,510,82,92],lightning:[1120,548,82,92]},crop=crops[kind]||crops.social;
    const canvas=document.createElement("canvas");canvas.className=`town-vfx ${kind}`;canvas.width=96;canvas.height=96;canvas.style.left=`${x-48}px`;canvas.style.top=`${y-68}px`;canvas.style.zIndex=String(TOWN_DEPTH_BASE+Math.round(y)+120);
    const ctx=canvas.getContext("2d");ctx.drawImage(image,...crop,0,0,96,96);layer.append(canvas);window.setTimeout(()=>canvas.remove(),950);
  }

  function renderAll() {
    renderHeader();
    renderMap();
    renderSchedule();
    renderErrand();
    renderProject();
    renderVirtueFocus();
    renderOnboarding();
    renderActiveNotebookTab();
  }

  function renderHeader() {
    $("#cycle-label").textContent = `Timeline ${state.cycle}`;
    $("#day-label").textContent = `Day ${state.day}`;
    const season=currentSeason();
    $("#season-label").textContent = `${season.icon} ${season.label}`;
    $("#time-label").textContent = TIME_SLOTS[state.slot] || "Bedtime";
    $("#cash-label").textContent = `$${state.stats.cash}`;
    const weather = currentWeather();
    $("#weather-icon").textContent = weather.icon;
    $("#weather-label").textContent = weather.label;
    const forecast=(state.forecast||[]).slice(1,4).map((id,index)=>{
      const item=WEATHER.find(entry=>entry.id===id)||WEATHER[0];
      return `Day ${state.day+index+1}: ${item.icon} ${item.label}`;
    });
    $("#weather-status").title = `${season.label} · ${weather.effect}${forecast.length?`\nNext: ${forecast.join(" · ")}`:""}`;
    $("#headline").textContent = HEADLINES[(state.day + state.cycle - 2) % HEADLINES.length];
    $("#sound-toggle").textContent = state.sound ? "♫" : "×";
    $("#sound-toggle").setAttribute("aria-pressed", String(state.sound));
    const pips = $("#energy-pips");
    pips.replaceChildren();
    for (let i = 0; i < MAX_ENERGY; i += 1) {
      const pip = document.createElement("span");
      pip.className = `pip${i < state.stats.energy ? " full" : ""}`;
      pips.append(pip);
    }
  }

  function renderMap() {
    $$(".location-marker").forEach((button, index) => {
      const id = button.dataset.location;
      button.classList.toggle("selected", index === selectedIndex);
      button.classList.toggle("visited", state.visitedToday.includes(id));
      button.classList.toggle("waypoint", id === currentObjectiveTarget());
      button.setAttribute("aria-current", index === selectedIndex ? "true" : "false");
    });
    const marker = $("#ben-marker");
    marker.style.left = `${townPosition.x}px`;
    marker.style.top = `${townPosition.y}px`;
    marker.style.zIndex=String(TOWN_DEPTH_BASE+Math.round(townPosition.y));
    updateTownCamera();
    const weatherLayer = $("#weather-layer");
    const weather=currentWeather();
    const season=currentSeason();
    weatherLayer.className = `weather-layer ${weather.category} ${weather.id} intensity-${weather.intensity}`;
    document.body.dataset.season=season.id;
    document.body.dataset.weather=weather.id;
    $("#town-world").dataset.season=season.id;
    $("#town-world").dataset.weather=weather.id;
    syncTownResidents();
    $("#rest-button").disabled = state.slot >= 3;
    updateObjectiveCompass();
  }

  function currentObjectiveTarget() {
    const target=CORE.objectiveTarget(state.activeErrand,waypointLocationId);
    return target&&townLocationActive(target)?target:null;
  }

  function setWaypoint(locationId,{announce=true}={}) {
    if(!LOCATIONS[locationId]||!townLocationActive(locationId))return;
    waypointLocationId=locationId;selectedIndex=LOCATION_ORDER.indexOf(locationId);renderMap();
    if(announce)showTownPrompt(`${LOCATIONS[locationId].short} marked · follow the gold arrow`,2200);
    $("#town-map")?.focus({preventScroll:true});
  }

  function updateObjectiveCompass() {
    const button=$("#objective-compass"),targetId=currentObjectiveTarget();if(!button)return;
    button.classList.toggle("hidden",!targetId||townEditMode||isVisible("location-sheet"));if(!targetId)return;
    const target=townBuildingGeometry(targetId).doorPoint,dx=target.x-townPosition.x,dy=target.y-townPosition.y,distance=Math.hypot(dx,dy),angle=Math.atan2(dy,dx)*180/Math.PI+90,arrived=distance<90;
    $("#objective-compass-arrow").style.transform=`rotate(${Math.round(angle)}deg)`;$("#objective-compass-name").textContent=LOCATIONS[targetId].short;$("#objective-compass-distance").textContent=arrived?"At the front door":`${Math.max(1,Math.round(distance/32))} blocks away`;button.classList.toggle("arrived",arrived);button.dataset.location=targetId;button.setAttribute("aria-label",`${LOCATIONS[targetId].name}, ${arrived?"at the front door":`${Math.max(1,Math.round(distance/32))} blocks away`}`);
  }

  function renderOnboarding() {
    const card=$("#onboarding-card");if(!card)return;const hidden=state.tutorialDismissed||state.tutorialStep>=3||state.day>1;card.classList.toggle("hidden",hidden);
    [$("#town-edit-toggle"),$("#room-edit-toggle")].forEach(button=>{if(!button)return;button.disabled=!hidden;button.title=!hidden?"Finish or skip the three-step field guide to unlock editing.":"";});
    if(hidden)return;
    const steps=[
      ["First morning · 1 of 3","Start at the Daily Grind","Follow the gold waypoint to the Café, then press E or Enter at its front door."],
      ["First morning · 2 of 3","Pick up today’s priority","Inside the Café, choose “Pick up the experimental oat latte.” Actions use one of today’s three time slots."],
      ["First morning · 3 of 3","Deliver to the Tomorrow Lab","Follow the waypoint to the Laboratory and hand the latte to Dr. Hex. After that, the day is yours."]
    ],copy=steps[state.tutorialStep]||steps[0];$("#onboarding-step").textContent=copy[0];$("#onboarding-title").textContent=copy[1];$("#onboarding-copy").textContent=copy[2];
  }

  function updateTownCamera() {
    const viewport = $("#town-map");
    const world = $("#town-world");
    if (!viewport || !world) return;
    const x = clamp(viewport.clientWidth / 2 - townPosition.x, viewport.clientWidth - TOWN_SIZE.width, 0);
    const y = clamp(viewport.clientHeight / 2 - townPosition.y, viewport.clientHeight - TOWN_SIZE.height, 0);
    world.style.transform = `translate3d(${Math.round(x)}px, ${Math.round(y)}px, 0)`;
  }

  function showTownPrompt(message,holdMs=0) {
    const prompt = $("#town-prompt");
    if(holdMs>0)townPromptHoldUntil=performance.now()+holdMs;
    prompt.textContent = message;
    prompt.classList.toggle("visible", Boolean(message));
  }

  function nearestTownResident() {
    let nearest=null;
    townResidents.forEach(sim=>{const distance=Math.hypot(townPosition.x-sim.x,townPosition.y-sim.y);if(!nearest||distance<nearest.distance)nearest={id:sim.npcId,distance,sim};});
    townCustomNpcSims.forEach(sim=>{if(!sim.entity.visible)return;const distance=Math.hypot(townPosition.x-sim.x,townPosition.y-sim.y);if(!nearest||distance<nearest.distance)nearest={id:sim.npcId,distance,sim};});
    return nearest;
  }

  function nearestTownLocation() {
    let nearest = null;
    LOCATION_ORDER.forEach(id => {
      if(!townLocationActive(id))return;
      const door = townBuildingGeometry(id).doorPoint;
      const distance = Math.hypot(townPosition.x - door.x, townPosition.y - door.y);
      if (!nearest || distance < nearest.distance) nearest = { id, distance };
    });
    return nearest;
  }

  function isTownRiverBlocked(x, y) {
    return terrainCellAtWorld(x,y).surface==="water";
  }

  function canTownStaticPoint(x, y) {
    if (x < 34 || y < 60 || x > TOWN_SIZE.width - 34 || y > TOWN_SIZE.height - 30) return false;
    if (isTownRiverBlocked(x, y)) return false;
    const terrain=terrainCellAtWorld(x,y);
    if (terrain.surface==="water") return false;
    const gx=Math.floor(x/TERRAIN_CELL),gy=Math.floor(y/TERRAIN_CELL),localY=((y%TERRAIN_CELL)+TERRAIN_CELL)%TERRAIN_CELL,south=terrainCellAtGrid(gx,gy+1);
    if(terrain.elevation-south.elevation>1&&localY>TERRAIN_CELL-Math.min(30,8+(terrain.elevation-south.elevation)*7))return false;
    if (townNaturePoints.some(([kind,nx,ny])=>{const size=TOWN_NATURE_DISPLAY[kind]||64;return ["rock","smallRock"].includes(kind)&&x>nx+size*.18&&x<nx+size*.82&&y>ny+size*.35&&y<ny+size*.88;})) return false;
    if (TOWN_TREE_POINTS.some(([tx,ty]) => x > tx+12 && x < tx+84 && y > ty+45 && y < ty+100)) return false;
    if (townPlacedDecor.some(item => {
      const size=townDecorSize(item);
      if(item.type==="flower"||item.type==="path") return false;
      if(item.type==="tree") return x>item.x+18&&x<item.x+78&&y>item.y+62&&y<item.y+100;
      if(item.type==="bench") return x>item.x+4&&x<item.x+size.width-4&&y>item.y+20&&y<item.y+size.height+6;
      if(item.type==="pond") return x>item.x-8&&x<item.x+size.width+8&&y>item.y-8&&y<item.y+size.height+8;
      return x>item.x+10&&x<item.x+size.width-10&&y>item.y+size.height*.48&&y<item.y+size.height+8;
    })) return false;
    return !LOCATION_ORDER.some(id => {
      if(!townLocationActive(id))return false;
      const geometry=townBuildingGeometry(id),box=geometry.collision,insideBuilding=x>box.left&&x<box.right&&y>box.top&&y<box.bottom;
      const atDoor=x>geometry.doorPoint.x-30&&x<geometry.doorPoint.x+30&&y>=geometry.groundY-22;
      return insideBuilding && !atDoor;
    });
  }

  function canTownStaticMove(x,y,radius=0) {
    return [[0,0],[-radius,-radius],[radius,-radius],[-radius,radius],[radius,radius]].every(([ox,oy])=>canTownStaticPoint(x+ox,y+oy));
  }

  function canTownTerrainStep(fromX,fromY,toX,toY) {
    return Math.abs(terrainCellAtWorld(toX,toY).elevation-terrainCellAtWorld(fromX,fromY).elevation)<=1;
  }

  function pushTownResident(sim,x,y,pushX,pushY) {
    const length=Math.hypot(pushX,pushY)||1,ux=pushX/length,uy=pushY/length,currentDistance=Math.hypot(x-sim.x,y-sim.y),distance=Math.max(7,38-currentDistance),sideX=-uy,sideY=ux;
    const candidates=[[ux*distance,uy*distance],[ux*4+sideX*distance,uy*4+sideY*distance],[ux*4-sideX*distance,uy*4-sideY*distance]];
    const offset=candidates.find(([ox,oy])=>{
      const nx=sim.x+ox,ny=sim.y+oy;
      return canTownStaticMove(nx,ny,15)&&canTownTerrainStep(sim.x,sim.y,nx,ny)&&Math.hypot(x-nx,y-ny)>=34&&![...townResidents.values()].some(other=>other!==sim&&Math.hypot(nx-other.x,ny-other.y)<34);
    });
    if(!offset)return false;
    sim.x+=offset[0];sim.y+=offset[1];sim.route=[];sim.goal={x:sim.x,y:sim.y};sim.wanderAt=performance.now()+1200;sim.blockedFor=0;sim.direction=Math.abs(offset[0])>Math.abs(offset[1])?(offset[0]>0?"east":"west"):(offset[1]>0?"south":"north");
    sim.element.style.left=`${sim.x}px`;sim.element.style.top=`${sim.y}px`;return true;
  }

  function canTownMove(x, y, pushX=0, pushY=0) {
    if(!canTownStaticMove(x,y,14))return false;
    if(!canTownTerrainStep(townPosition.x,townPosition.y,x,y))return false;
    const placedBlocker=[...townCustomNpcSims.values()].some(sim=>sim.entity.visible&&sim.entity.collision&&Math.hypot(x-sim.x,y-sim.y)<32&&Math.hypot(x-sim.x,y-sim.y)<=Math.hypot(townPosition.x-sim.x,townPosition.y-sim.y));
    if(placedBlocker)return false;
    const blockers=[...townResidents.values()].filter(sim=>{
      const nextDistance=Math.hypot(x-sim.x,y-sim.y),currentDistance=Math.hypot(townPosition.x-sim.x,townPosition.y-sim.y);
      return nextDistance<34&&nextDistance<=currentDistance;
    });
    return blockers.every(sim=>pushTownResident(sim,x,y,pushX,pushY));
  }

  function townLoop(timestamp) {
    drawTownWater(timestamp);
    const dt = Math.min(32, timestamp - townLastFrame || 16);
    townLastFrame = timestamp;
    updateTownResidents(dt,timestamp);
    const blocked = isVisible("start-screen") || isVisible("location-sheet") || isVisible("minigame-overlay") || isVisible("result-overlay") || isVisible("day-end-overlay") || isVisible("cycle-end-overlay") || isVisible("help-overlay") || isVisible("dialogue-overlay");
    let dx = 0, dy = 0, inputMagnitude=0, followingRoute=false;
    if (!blocked) {
      const manual=manualMoveVector();
      if(manual.magnitude){if(townMoveRoute.length)clearAutoMovement("town");dx=manual.x;dy=manual.y;inputMagnitude=manual.magnitude;}
      else {const routed=routeMoveVector(townPosition,townMoveRoute);dx=routed.x;dy=routed.y;inputMagnitude=routed.magnitude;followingRoute=Boolean(routed.magnitude);if(!townMoveRoute.length)hideMoveTarget("town-move-target");}
    }
    if (dx || dy) {
      const length = Math.hypot(dx, dy);
      const speed = (heldKeys.has("shift") ? 0.11 : 0.18) * dt * Math.max(.25,inputMagnitude||1);
      const nextX = townPosition.x + dx / length * speed;
      const nextY = townPosition.y + dy / length * speed;
      const beforeX=townPosition.x,beforeY=townPosition.y;
      if (canTownMove(nextX, townPosition.y,dx,0)) townPosition.x = nextX;
      if (canTownMove(townPosition.x, nextY,0,dy)) townPosition.y = nextY;
      const moved=Math.hypot(townPosition.x-beforeX,townPosition.y-beforeY)>.05;
      if(followingRoute){townRouteBlockedFor=moved?0:townRouteBlockedFor+dt;if(townRouteBlockedFor>900){const goal=townMoveRoute.at(-1);townMoveRoute=goal?residentRoute(townPosition,goal):[];townRouteBlockedFor=0;}}
      townFacing = Math.abs(dx) > Math.abs(dy) ? (dx > 0 ? "east" : "west") : (dy > 0 ? "south" : "north");
      townWalkFrame += dt;
      const frame = Math.floor(townWalkFrame / 90) % 6;
      $("#ben-sprite").src = `${ASSETS.benRunning}${townFacing}/frame_${String(frame).padStart(3,"0")}.png`;
      $("#ben-marker").style.left = `${townPosition.x}px`;
      $("#ben-marker").style.top = `${townPosition.y}px`;
      updateTownCamera();
      if (timestamp - townSaveAt > 1000) {
        state.townPosition = { x: Math.round(townPosition.x), y: Math.round(townPosition.y) };
        saveState();
        townSaveAt = timestamp;
      }
      if(followingRoute&&!routeMoveVector(townPosition,townMoveRoute).magnitude){hideMoveTarget("town-move-target");state.townPosition={x:Math.round(townPosition.x),y:Math.round(townPosition.y)};saveState();}
    } else if (!blocked) {
      townWalkFrame = 0;
      $("#ben-sprite").src = `${ASSETS.benDirections}${townFacing}.png`;
    }
    $("#ben-marker").style.zIndex=String(TOWN_DEPTH_BASE+Math.round(townPosition.y));
    const interiorBlocked = isVisible("minigame-overlay") || isVisible("result-overlay") || isVisible("day-end-overlay") || isVisible("cycle-end-overlay") || isVisible("help-overlay") || isVisible("dialogue-overlay");
    if (isVisible("location-sheet") && !interiorBlocked && !roomEditMode) updateInteriorMovement(dt);
    if(isVisible("location-sheet"))updateInteriorNpcEntities(dt,timestamp);
    const nearest = nearestTownLocation();
    const resident=nearestTownResident();
    nearbyLocationId = nearest?.distance < 78 ? nearest.id : null;
    nearbyResidentId = resident?.distance < 88 ? resident.id : null;nearbyResidentSim=resident?.distance<88?resident.sim:null;
    $$(".location-marker").forEach(marker => marker.classList.toggle("nearby", marker.dataset.location === nearbyLocationId));
    if (!blocked&&timestamp>=townPromptHoldUntil) showTownPrompt(townEditMode?"Editor · drag any outlined object · tools and build catalog stay docked":nearbyResidentId?`E · Talk to ${NPCS[nearbyResidentId].name}`:nearbyLocationId ? `E · Enter ${LOCATIONS[nearbyLocationId].name}` : "");
    updateObjectiveCompass();
    animateNpcSprites(timestamp);
    animatePlacedEditorAssets(timestamp);
    requestAnimationFrame(townLoop);
  }

  function enterNearbyLocation() {
    if(townEditMode){showTownPrompt("Finish town editing before entering a location",1800);return;}
    if(nearbyResidentId){const sim=nearbyResidentSim||townResidents.get(nearbyResidentId);if(sim)talkToTownResident(sim);return;}
    if (nearbyLocationId) visitLocation(nearbyLocationId);
  }

  function renderSchedule() {
    const container = $("#schedule-slots");
    container.replaceChildren();
    TIME_SLOTS.forEach((slot, index) => {
      const item = document.createElement("div");
      item.className = "schedule-slot";
      if (index < state.slot) item.classList.add("done");
      if (index === state.slot) item.classList.add("current");
      item.textContent = state.schedule[index] || slot;
      container.append(item);
    });
  }

  function renderErrand() {
    const errand = state.activeErrand;
    $("#errand-card").classList.toggle("hidden",!errand);
    if (!errand) { $("#errand-route").replaceChildren(); return; }
    $("#errand-title").textContent = errand.title;
    $("#errand-copy").textContent = errand.status === "pickup"
      ? errand.copy
      : errand.status === "carrying"
        ? `You have the ${errand.item}. Take it to ${activeNpc(errand.to).name} before bedtime.`
        : `Delivered! The ${errand.item} reached ${LOCATIONS[errand.to].short}, and the town is marginally more functional.`;
    $("#errand-reward").textContent = `+$${errand.reward}`;
    const route = $("#errand-route");
    route.replaceChildren();
    const from = document.createElement("button");
    from.type="button";
    from.className = "route-dot";
    from.textContent = `${errand.status === "pickup" ? "○" : "✓"} ${LOCATIONS[errand.from].short}`;
    from.classList.toggle("active",currentObjectiveTarget()===errand.from);from.setAttribute("aria-label",`Mark ${LOCATIONS[errand.from].name} on the map`);from.addEventListener("click",()=>setWaypoint(errand.from));
    const arrow = document.createElement("span");
    arrow.className = "route-arrow";
    arrow.textContent = "→";
    const to = document.createElement("button");
    to.type="button";
    to.className = "route-dot";
    to.textContent = `${errand.status === "done" ? "✓" : "○"} ${LOCATIONS[errand.to].short}`;
    to.classList.toggle("active",currentObjectiveTarget()===errand.to);to.setAttribute("aria-label",`Mark ${LOCATIONS[errand.to].name} on the map`);to.addEventListener("click",()=>setWaypoint(errand.to));
    route.append(from, arrow, to);
  }

  function renderProject() {
    $("#spark-count").textContent = `${state.sparks} ⚡`;
    $("#project-progress").style.width = `${clamp(state.sparks / 30 * 100, 0, 100)}%`;
    const list = $("#invention-list");
    list.replaceChildren();
    INVENTIONS.forEach(invention => {
      const chip = document.createElement("div");
      const unlocked = state.inventions.includes(invention.name);
      chip.className = `invention-chip${unlocked ? " unlocked" : ""}`;
      chip.textContent = unlocked ? `${invention.icon} ${invention.name}` : `🔒 ${invention.threshold} sparks`;
      list.append(chip);
    });
  }

  function renderVirtueFocus() {
    const focus = dailyVirtue();
    const container = $("#virtue-focus");
    container.classList.toggle("complete", state.focusCompleted);
    container.replaceChildren();
    const head = document.createElement("div");
    head.className = "virtue-focus-head";
    const label = document.createElement("span");
    label.textContent = state.focusCompleted ? `Practiced · ${state.focusStreak} day streak` : "Today’s virtue focus · +1 bonus";
    const name = document.createElement("b");
    name.textContent = `${focus.icon} ${focus.name}`;
    const maxim = document.createElement("p");
    maxim.textContent = focus.maxim;
    head.append(label, name);
    container.append(head, maxim);
  }

  function renderVirtues() {
    const list = $("#virtue-ledger");
    const focus = dailyVirtue();
    list.replaceChildren();
    VIRTUES.forEach(virtue => {
      const points = state.virtues[virtue.id] || 0;
      const row = document.createElement("div");
      row.className = "virtue-row";
      row.classList.toggle("focus", virtue.id === focus.id);
      row.classList.toggle("practiced", state.virtuesToday.includes(virtue.id));
      row.setAttribute("aria-label", `${virtue.name}: ${points} practice points${virtue.id === focus.id ? ", today's focus" : ""}`);
      const head = document.createElement("div");
      head.className = "virtue-row-head";
      const name = document.createElement("b");
      name.textContent = `${virtue.icon} ${virtue.name}`;
      const score = document.createElement("span");
      score.textContent = points;
      const maxim = document.createElement("p");
      maxim.textContent = virtue.maxim;
      const track = document.createElement("div");
      track.className = "virtue-track";
      const fill = document.createElement("span");
      fill.style.width = `${clamp(points / 30 * 100, 0, 100)}%`;
      head.append(name, score);
      track.append(fill);
      row.append(head, maxim, track);
      list.append(row);
    });
  }

  function renderActiveNotebookTab() {
    if(activeNotebookTab==="people")renderRelationships();
    else if(activeNotebookTab==="pockets")renderInventory();
    else if(activeNotebookTab==="virtues")renderVirtues();
    else if(activeNotebookTab==="notes")renderNotes();
  }

  function relevantNpcIds() {
    const ids=new Set(state.encounteredNpcs||[]),errand=state.activeErrand;
    if(errand){ids.add(activeNpc(errand.from).id);ids.add(activeNpc(errand.to).id);}
    if(nearbyResidentId)ids.add(nearbyResidentId);
    if(isVisible("location-sheet")&&NPCS[currentNpcId])ids.add(currentNpcId);
    return ids;
  }

  function renderRelationships() {
    const list = $("#relationship-list");
    list.replaceChildren();
    const query=$("#people-search")?.value.trim().toLowerCase()||"",filter=$("#people-filter")?.value||"known",relevant=relevantNpcIds(),ids=Object.keys(NPCS).filter(npcId=>(filter==="all"||relevant.has(npcId))&&(!query||`${NPCS[npcId].name} ${NPCS[npcId].role} ${LOCATIONS[npcWorkplace(npcId)]?.name||""}`.toLowerCase().includes(query))).sort((a,b)=>Number(relevant.has(b))-Number(relevant.has(a))||(state.relationships[b]||0)-(state.relationships[a]||0)||NPCS[a].name.localeCompare(NPCS[b].name));
    if(!ids.length){const empty=document.createElement("p");empty.className="relationship-empty";empty.textContent=query?"No residents match that search.":"Meet residents around town, or choose Everyone to browse the full directory.";list.append(empty);return;}
    ids.forEach(npcId => {
        const npc = NPCS[npcId];
        const points = state.relationships[npcId] || 0;
        const row = document.createElement("div");
        row.className = "relationship-row";
        const face = document.createElement("div");
        face.className = "relationship-face";
        face.textContent = npc.avatar;
        face.style.display = "grid";
        face.style.placeItems = "center";
        const copy = document.createElement("div");
        copy.className = "relationship-copy";
        const name = document.createElement("b");
        name.textContent = npc.name;
        const hearts = document.createElement("div");
        hearts.className = "heart-track";
        for (let i = 1; i <= 5; i += 1) {
          const heart = document.createElement("span");
          heart.className = `heart${points >= i * 5 ? " full" : ""}`;
          heart.textContent = "♥";
          hearts.append(heart);
        }
        copy.append(name, hearts);
        const rank = document.createElement("span");
        rank.className = "relationship-rank";
        const work=npcWorkplace(npcId),schedule=npcScheduleEntry(npcId),connections=npcConnections(npcId);
        rank.textContent = `${LOCATIONS[work]?.short||"Town"} · ${friendshipRank(points)}`;
        const life=document.createElement("small");life.className="relationship-life";
        const social=connections.slice(0,2).map(connection=>`${NPCS[connection.id]?.name} (${connection.type})`).join(" · ");
        life.textContent=`${schedule.activity} · Home: ${LOCATIONS[npcHome(npcId)]?.short||"Town"}${social?` · ${social}`:""}`;
        row.title=`Today: ${schedule.activity}\nJob: ${npc.role}\nHome: ${LOCATIONS[npcHome(npcId)]?.name||"New Philadelphia"}${social?`\nTies: ${social}`:""}`;
        row.append(face, copy, rank,life);
        list.append(row);
    });
  }

  function activeNpc(locationId) {
    const roster = ROSTERS[locationId];
    const index = (state.day + state.cycle + LOCATION_ORDER.indexOf(locationId) - 2) % roster.length;
    return NPCS[roster[(index + roster.length) % roster.length]];
  }

  function friendshipRank(points) {
    if (points >= 25) return "Kindred";
    if (points >= 18) return "Close";
    if (points >= 11) return "Pal";
    if (points >= 5) return "Friendly";
    return "New";
  }

  function renderInventory() {
    const values = [
      ["Spare parts", state.inventory.parts, "⚙"],
      ["Fresh produce", state.inventory.produce, "🥕"],
      ["Odd keepsakes", state.inventory.keepsakes, "✦"],
      ["Reputation", state.stats.reputation, "★"]
    ];
    const list = $("#inventory-list");
    list.replaceChildren();
    values.forEach(([label, count, icon]) => {
      const item = document.createElement("div");
      item.className = "inventory-item";
      const text = document.createElement("span");
      text.textContent = `${icon} ${label}`;
      const value = document.createElement("b");
      value.textContent = count;
      item.append(text, value);
      list.append(item);
    });
  }

  function renderNotes() {
    const list = $("#notes-list");
    list.replaceChildren();
    state.notes.slice(0, 6).forEach(note => {
      const li = document.createElement("li");
      li.textContent = note;
      list.append(li);
    });
  }

  function selectLocation(id, visit = false) {
    selectedIndex = LOCATION_ORDER.indexOf(id);
    renderMap();
    if (visit) visitLocation(id);
  }

  function cycleLocation(direction) {
    selectedIndex = (selectedIndex + direction + LOCATION_ORDER.length) % LOCATION_ORDER.length;
    renderMap();
    playSfx(ASSETS.click, 0.28);
    const selected = $(`.location-marker[data-location="${LOCATION_ORDER[selectedIndex]}"]`);
    selected?.focus({ preventScroll: true });
  }

  function visitSelected() { visitLocation(LOCATION_ORDER[selectedIndex]); }

  function visitLocation(id) {
    if (state.slot >= 3) {
      showDayEnd();
      return;
    }
    state.currentLocation = id;
    if(waypointLocationId===id)waypointLocationId=null;
    selectedIndex = LOCATION_ORDER.indexOf(id);
    renderMap();
    saveState();
    playSfx(ASSETS.transition, 0.25);
    window.setTimeout(() => openLocation(id), 180);
  }

  function animateBen(dx, dy) {
    if (moveTimer) window.clearInterval(moveTimer);
    let direction = "south";
    if (Math.abs(dx) > Math.abs(dy)) direction = dx >= 0 ? "east" : "west";
    else direction = dy >= 0 ? "south" : "north";
    let frame = 0;
    const sprite = $("#ben-sprite");
    moveTimer = window.setInterval(() => {
      sprite.src = `${ASSETS.benRunning}${direction}/frame_${String(frame % 6).padStart(3, "0")}.png`;
      frame += 1;
    }, 90);
    window.setTimeout(() => {
      window.clearInterval(moveTimer);
      moveTimer = null;
      sprite.src = `${ASSETS.benDirections}${direction}.png`;
    }, 720);
  }

  function openLocation(id) {
    const loc = LOCATIONS[id];
    clearAutoMovement();heldKeys.clear();
    show("location-sheet");
    $("#location-eyebrow").textContent = `${TIME_SLOTS[state.slot]} at`;
    $("#location-title").textContent = loc.name;
    currentNpcId = activeNpc(id).id;
    encounterNpc(currentNpcId);
    if(!state.tutorialDismissed&&state.day===1&&state.tutorialStep===0&&id==="cafe")state.tutorialStep=1;
    currentSceneIndex = Math.max(0, EXPLORATION_SCENES[id].findIndex(scene => scene.npcId === currentNpcId));
    const scene=$("#location-scene");
    const savedRoom=interiorEditorLayout[id]||{};
    currentLevelWidth = Math.max(1100,scene?.clientWidth||0,clamp(Number(savedRoom.worldWidth)||0,0,4096));
    currentLevelHeight = Math.max(LEVEL_HEIGHT,scene?.clientHeight||0,clamp(Number(savedRoom.worldHeight)||0,0,4096));
    roomEditMode=false; roomEditorSelection=null; roomEditorDrag=null;roomEditorUndo=[];roomEditorRedo=[];roomEditorInspectorSnapshot=null;
    $("#room-edit-toggle").textContent="✥ Edit Room";
    $("#room-edit-palette").classList.add("hidden");
    interiorPosition = { ...levelNpcPoint(id, currentSceneIndex), y: 790 };
    buildInteriorWorld(id);
    renderNpcRoster(id);
    actionFocus = 0;
    renderExplorationScene(id);
    saveState();renderOnboarding();renderActiveNotebookTab();
    window.setTimeout(() => {
      updateInteriorViewport();
      $("#location-scene").focus?.({ preventScroll:true });
    }, 40);
  }

  function buildInteriorWorld(locationId) {
    const world = $("#interior-world");
    const ben=$("#scene-ben");
    world.replaceChildren();
    world.style.width = `${currentLevelWidth}px`;
    world.style.height = `${currentLevelHeight}px`;
    const canvas = document.createElement("canvas");
    canvas.className = "level-canvas";
    canvas.width = currentLevelWidth;
    canvas.height = currentLevelHeight;
    world.append(canvas);
    drawLevel(locationId, canvas);
    currentInteriorProps=resolveInteriorProps(locationId);
    interiorCustomNpcSims.clear();
    currentInteriorNpcs=resolveInteriorNpcs(locationId);
    if(Number(interiorEditorLayout[locationId]?.layoutVersion)!==5||interiorEditorLayout[locationId]?.themeSignature!==interiorThemeSignature(locationId))persistCurrentInteriorLayout();
    currentInteriorProps.forEach(prop => createLevelProp(world, prop));
    EXPLORATION_SCENES[locationId].forEach((area, index) => {
      const label = document.createElement("span");
      label.className = "interior-zone-label";
      const point = levelNpcPoint(locationId,index);
      label.style.left = `${point.x}px`;
      label.textContent = area.name;
      const npc = document.createElement("span");
      npc.className = "interior-npc";
      npc.dataset.name = NPCS[area.npcId].name;
      npc.dataset.npc = area.npcId;
      npc.style.left = `${point.x}px`;
      npc.style.top = `${point.npcY}px`;
      npc.style.zIndex = `${100 + point.npcY}`;
      const sprite = NPCS[area.npcId].sprite;
      npc.style.backgroundImage = `url("${sprite.sheet}")`;
      applyNpcFrame(npc, sprite, 1);
      world.append(label, npc);
    });
    renderInteriorNpcEntities();
    if(ben)world.append(ben);
    renderRoomEditorHandles();
    updateInteriorPosition();
  }

  function resolveInteriorProps(locationId) {
    const saved=interiorEditorLayout[locationId]||{base:{},custom:[]},themeMatches=saved.themeSignature===interiorThemeSignature(locationId);
    const base=LEVEL_THEMES[locationId].props.map((source,index)=>{
      const prop=[...source],position=saved.base?.[index];
      if(Array.isArray(position)&&themeMatches){
        const savedVersion=Number(saved.layoutVersion)||1;
        if(Number.isFinite(Number(position[0])))prop[5]=Number(position[0]);
        if(Number.isFinite(Number(position[1])))prop[6]=Number(position[1]);
        if(savedVersion>=4&&themeMatches){
          if(Number.isFinite(Number(position[2])))prop[7]=Number(position[2]);
          if(Number.isFinite(Number(position[3])))prop[8]=Number(position[3]);
        }
        if(position.length>4)prop[9]=Number(position[4]);
        if(position.length>5)prop[10]=Boolean(position[5]);
        if(position.length>6)prop[11]=Boolean(position[6]);
        if(position.length>7)prop[12]=Boolean(position[7]);
        if(position.length>8)prop[13]=Boolean(position[8]);
      }
      prop.editorKey=`base-${index}`;prop.editorCustom=false;return normalizeInteriorProp(prop);
    });
    const custom=(Array.isArray(saved.custom)?saved.custom:[]).slice(0,100).map((entry,index)=>{
      if(!Array.isArray(entry.prop)||entry.prop.length<9)return null;
      const prop=[...entry.prop];prop.editorKey=String(entry.id||`custom-${index}`);prop.editorCustom=true;return normalizeInteriorProp(prop);
    }).filter(Boolean);
    return [...base,...custom];
  }

  function resolveInteriorNpcs(locationId) {
    const saved=interiorEditorLayout[locationId],items=Array.isArray(saved?.npcs)?saved.npcs:[];
    const usedIds=new Set();return items.slice(0,100).filter(item=>item&&NPCS[item.npcId]).map((item,index)=>{const entity=normalizeNpcEntity(item,index,currentLevelWidth,currentLevelHeight,"room-npc"),base=entity.id;let id=base,suffix=2;while(usedIds.has(id))id=`${base}-${suffix++}`;usedIds.add(id);entity.id=id;if(entity.visible&&entity.collision){const point=nearestInteriorNpcPoint(entity);entity.x=point.x;entity.y=point.y;}return entity;});
  }

  function interiorThemeSignature(locationId){return LEVEL_THEMES[locationId].props.map(prop=>prop.slice(0,14).join(",")).join("|");}

  function interiorPropLayer(prop){const layer=Number(prop[9]);return layer===0||layer===2?layer:1;}
  function interiorPropCollides(prop){return prop[10]===undefined?interiorPropLayer(prop)!==0:Boolean(prop[10]);}
  function normalizeInteriorProp(prop){
    prop[0]=String(prop[0]||"");prop[1]=Math.max(0,Number(prop[1])||0);prop[2]=Math.max(0,Number(prop[2])||0);prop[3]=Math.max(1,Number(prop[3])||1);prop[4]=Math.max(1,Number(prop[4])||1);
    prop[7]=clamp(Math.round(Number(prop[7])||8),8,640);prop[8]=clamp(Math.round(Number(prop[8])||8),8,640);
    prop[5]=clamp(Math.round(Number(prop[5])||0),0,Math.max(0,currentLevelWidth-prop[7]));prop[6]=clamp(Math.round(Number(prop[6])||0),0,Math.max(0,currentLevelHeight-prop[8]));
    prop[9]=interiorPropLayer(prop);prop[10]=interiorPropCollides(prop);prop[11]=Boolean(prop[11]);prop[12]=Boolean(prop[12]);prop[13]=Boolean(prop[13]);
    if(prop[14])prop[14]=normalizeAssetAnimation(prop[14]);
    if(prop[15]&&typeof prop[15]==="object")prop[15]={assetId:String(prop[15].assetId||""),variantId:String(prop[15].variantId||""),kind:String(prop[15].kind||"")};
    return prop;
  }

  function interiorPropZIndex(prop){
    const layer=interiorPropLayer(prop);
    if(layer===0)return 20;
    if(layer===2)return currentLevelHeight+1200+Math.round(prop[6]);
    return 100+Math.round(prop[6]+prop[8]);
  }

  function applyNpcFrame(element,sprite,frame) {
    const sheetWidth=sprite.sheetWidth||inferSheetWidth(sprite.sheet),imageInfo={naturalWidth:sheetWidth,naturalHeight:sprite.layout==="actionRows"?sprite.h*18:sprite.layout==="rpg"?sprite.h*4:sprite.h};
    const plan=spriteFramePlan(sprite,"south",true,frame,imageInfo),rect=plan.current,singleFrame=plan.sequence.length<=1;
    const [boundX=0,boundY=0,boundW=rect.w,boundH=rect.h]=sprite.contentBounds||[],targetHeight=sprite.displayHeight||(boundH>=100?72:boundH>=66?68:boundH>=36?62:54),scale=targetHeight/boundH;
    element.style.width = `${Math.ceil(boundW*scale)}px`;
    element.style.height = `${targetHeight}px`;
    element.style.backgroundSize = `${Math.round(sheetWidth*scale)}px auto`;
    element.style.backgroundPosition = `${-Math.round((rect.x+boundX)*scale)}px ${-Math.round((rect.y+boundY)*scale)}px`;
    element.classList.toggle("single-frame",singleFrame);
  }

  function animateNpcSprites(timestamp) {
    const sequence=[0,1,2,1];
    const frame=sequence[Math.floor(timestamp/230)%sequence.length];
    $$(".interior-npc[data-npc]").forEach(element => {
      const npc=NPCS[element.dataset.npc];
      if(npc) applyNpcFrame(element,npc.sprite,frame);
    });
  }

  function renderInteriorNpcEntities() {
    const world=$("#interior-world");if(!world)return;
    $$(".interior-npc-entity",world).forEach(element=>element.remove());interiorCustomNpcSims.clear();
    currentInteriorNpcs.forEach(entity=>{
      const npc=NPCS[entity.npcId];if(!npc)return;
      const button=document.createElement("button");button.type="button";button.className="interior-npc-entity";button.dataset.entityId=entity.id;button.dataset.npcEntity=entity.npcId;button.hidden=!entity.visible&&!roomEditMode;button.classList.toggle("entity-hidden",!entity.visible);button.setAttribute("aria-label",`Talk to ${npc.name}`);
      const visual=document.createElement("canvas");visual.width=112;visual.height=112;const label=document.createElement("span");label.textContent=npc.name;button.append(visual,label);world.append(button);
      const sim={entity,npcId:entity.npcId,npc,element:button,visual,x:entity.x,y:entity.y,direction:entity.facing,moving:false,goal:null,nextRoutineAt:performance.now()+1600+(stableHash(entity.id)%2800)};interiorCustomNpcSims.set(entity.id,sim);
      button.addEventListener("click",event=>{event.stopPropagation();talkToInteriorNpcEntity(entity);});syncInteriorNpcSimElement(sim,performance.now());
    });
  }

  function syncInteriorNpcSimElement(sim,timestamp) {
    sim.element.style.left=`${sim.x}px`;sim.element.style.top=`${sim.y}px`;sim.element.style.zIndex=String(100+Math.round(sim.y));paintNpcEntityCanvas(sim.visual,sim.npcId,sim.direction,sim.moving,timestamp);
  }

  function canInteriorNpcStep(sim,x,y,avoidPlayer=true,ignoreEntity=null) {
    if(x<55||x>currentLevelWidth-55||y<85||y>currentLevelHeight-75||interiorStaticBlocked(state.currentLocation,x,y))return false;
    if(currentInteriorProps.some(prop=>{if(!interiorPropCollides(prop)||prop[13])return false;const dx=prop[5],dy=prop[6],dw=prop[7],dh=prop[8],padX=Math.max(8,dw*.12);return x>dx+padX-16&&x<dx+dw-padX+16&&y>dy+dh*.68-8&&y<dy+dh+12;}))return false;
    if(avoidPlayer&&Math.hypot(x-interiorPosition.x,y-interiorPosition.y)<34)return false;
    return ![...interiorCustomNpcSims.values()].some(other=>other!==sim&&other.entity!==ignoreEntity&&other.entity.visible&&Math.hypot(x-other.x,y-other.y)<32);
  }

  function nearestInteriorNpcPoint(point,avoidPlayer=false,ignoreEntity=null) {
    const start={x:clamp(Number(point.x)||0,55,currentLevelWidth-55),y:clamp(Number(point.y)||0,85,currentLevelHeight-75)};if(canInteriorNpcStep(null,start.x,start.y,avoidPlayer,ignoreEntity))return start;
    for(let ring=1;ring<=12;ring+=1)for(let oy=-ring;oy<=ring;oy+=1)for(let ox=-ring;ox<=ring;ox+=1){if(Math.abs(ox)!==ring&&Math.abs(oy)!==ring)continue;const candidate={x:clamp(start.x+ox*32,55,currentLevelWidth-55),y:clamp(start.y+oy*32,85,currentLevelHeight-75)};if(canInteriorNpcStep(null,candidate.x,candidate.y,avoidPlayer,ignoreEntity))return candidate;}
    return start;
  }

  function updateInteriorNpcEntities(dt,timestamp) {
    interiorCustomNpcSims.forEach(sim=>{
      const entity=sim.entity;sim.element.hidden=!entity.visible&&!roomEditMode;sim.element.classList.toggle("entity-hidden",!entity.visible);
      if(roomEditMode){sim.x=entity.x;sim.y=entity.y;sim.direction=entity.facing;sim.moving=false;sim.goal=null;}
      else if(entity.behavior==="face-player"){
        const dx=interiorPosition.x-sim.x,dy=interiorPosition.y-sim.y;sim.direction=Math.abs(dx)>Math.abs(dy)?(dx>0?"east":"west"):(dy>0?"south":"north");sim.moving=false;
      } else if(entity.behavior==="wander"){
        if(!sim.goal&&timestamp>=sim.nextRoutineAt){const phase=Math.floor(timestamp/3000)+stableHash(entity.id),angle=(phase%8)*Math.PI/4,distance=40+(phase%3)*20;sim.goal={x:clamp(entity.x+Math.cos(angle)*distance,55,currentLevelWidth-55),y:clamp(entity.y+Math.sin(angle)*distance,85,currentLevelHeight-75)};sim.nextRoutineAt=timestamp+3800+(stableHash(`${entity.id}:${phase}`)%2400);}
        if(sim.goal){const dx=sim.goal.x-sim.x,dy=sim.goal.y-sim.y,distance=Math.hypot(dx,dy);if(distance<3){sim.x=sim.goal.x;sim.y=sim.goal.y;sim.goal=null;sim.moving=false;}else{const step=Math.min(.046*dt,distance),nx=sim.x+dx/distance*step,ny=sim.y+dy/distance*step;if(canInteriorNpcStep(sim,nx,ny)){sim.x=nx;sim.y=ny;sim.moving=true;}else{sim.goal=null;sim.moving=false;}sim.direction=Math.abs(dx)>Math.abs(dy)?(dx>0?"east":"west"):(dy>0?"south":"north");}}
        else sim.moving=false;
      } else {sim.direction=entity.facing;sim.moving=false;}
      syncInteriorNpcSimElement(sim,timestamp);
    });
  }

  function nearestInteriorNpcEntity(maxDistance=92) {
    let nearest=null;interiorCustomNpcSims.forEach(sim=>{if(!sim.entity.visible)return;const distance=Math.hypot(interiorPosition.x-sim.x,interiorPosition.y-sim.y);if(distance<=maxDistance&&(!nearest||distance<nearest.distance))nearest={entity:sim.entity,distance,sim};});return nearest;
  }

  function talkToInteriorNpcEntity(entity) {
    if(roomEditMode){showSceneToast("Finish room editing before talking to residents.");return;}
    const npc=NPCS[entity?.npcId];if(!npc)return;currentNpcId=npc.id;
    const conversation=advanceNpcConversation(npc.id);$("#npc-name").textContent=npc.name;$("#npc-role").textContent=npc.role;$("#npc-line").textContent=`“${conversation.dialogue}”`;configureNpcSprite(npc.sprite);showDialogue(npc.id,conversation.dialogue,conversation.status,`${LOCATIONS[state.currentLocation].short} · ${npc.role}`);playSfx(ASSETS.click,.2);
  }

  function levelNpcPoint(locationId,index) {
    const points = {
      cafe: [{x:360,npcY:285},{x:770,npcY:285},{x:925,npcY:535}],
      lab: [{x:320,npcY:340},{x:560,npcY:570},{x:900,npcY:330}],
      restaurant: [{x:230,npcY:555},{x:550,npcY:300},{x:900,npcY:520}],
      club: [{x:320,npcY:310},{x:590,npcY:545},{x:900,npcY:300}],
      mansion: [{x:235,npcY:335},{x:550,npcY:580},{x:880,npcY:355}],
      farm: [{x:245,npcY:500},{x:565,npcY:350},{x:890,npcY:540}],
      ranch: [{x:245,npcY:500},{x:565,npcY:490},{x:890,npcY:520}]
      ,arcade: [{x:230,npcY:535},{x:550,npcY:330},{x:890,npcY:520}]
      ,conservatory: [{x:235,npcY:520},{x:555,npcY:335},{x:900,npcY:510}]
      ,skyhouse: [{x:230,npcY:500},{x:560,npcY:320},{x:900,npcY:500}]
      ,guildhall:[{x:230,npcY:500},{x:560,npcY:320},{x:900,npcY:500}]
      ,market:[{x:230,npcY:500},{x:560,npcY:320},{x:900,npcY:500}]
      ,elementalbaths:[{x:230,npcY:500},{x:560,npcY:320},{x:900,npcY:500}]
      ,clockstation:[{x:230,npcY:500},{x:560,npcY:320},{x:900,npcY:500}]
    };
    return points[locationId]?.[index] || {x:250,npcY:390};
  }

  function normalizeAssetCrop(value,fallback=null){
    if(!value)return fallback;
    const source=value.crop&&typeof value.crop==="object"?value.crop:value.trim&&typeof value.trim==="object"?value.trim:value.bounds&&typeof value.bounds==="object"?value.bounds:value;
    if(Array.isArray(source)){
      const [sx,sy,sw,sh]=source.map(Number);
      return Number.isFinite(sx)&&Number.isFinite(sy)&&sw>0&&sh>0?{sx:Math.max(0,Math.floor(sx)),sy:Math.max(0,Math.floor(sy)),sw:Math.max(1,Math.floor(sw)),sh:Math.max(1,Math.floor(sh))}:fallback;
    }
    if(!source||typeof source!=="object")return fallback;
    const sx=Number(source.x??source.sx??source.left),sy=Number(source.y??source.sy??source.top);
    let sw=Number(source.w??source.sw??source.width),sh=Number(source.h??source.sh??source.height);
    if(!(sw>0)&&Number.isFinite(Number(source.right))&&Number.isFinite(sx))sw=Number(source.right)-sx+1;
    if(!(sh>0)&&Number.isFinite(Number(source.bottom))&&Number.isFinite(sy))sh=Number(source.bottom)-sy+1;
    return Number.isFinite(sx)&&Number.isFinite(sy)&&sw>0&&sh>0?{sx:Math.max(0,Math.floor(sx)),sy:Math.max(0,Math.floor(sy)),sw:Math.max(1,Math.floor(sw)),sh:Math.max(1,Math.floor(sh))}:fallback;
  }

  function normalizeAssetAnimation(animation,fallbackCrop=null){
    if(!animation||typeof animation!=="object")return null;
    const fps=clamp(Number(animation.fps)||8,1,60),loop=animation.loop!==false,layout=String(animation.layout||"");
    let frames=(Array.isArray(animation.frames)?animation.frames:[]).slice(0,240).map(frame=>{
      const crop=normalizeAssetCrop(frame);if(!crop)return null;
      return {...crop,src:typeof frame.src==="string"?frame.src:"",duration:clamp(Number(frame.duration)||0,0,10000)};
    }).filter(Boolean);
    const declaredCount=clamp(Math.floor(Number(animation.frameCount)||frames.length||0),0,240),gif=layout==="gif"||String(animation.format||"").toLowerCase()==="gif";
    if(!gif&&!frames.length&&declaredCount>0){
      const declaredColumns=Math.max(0,Math.floor(Number(animation.columns)||0)),declaredRows=Math.max(0,Math.floor(Number(animation.rows)||0));
      const inferredColumns=declaredColumns||(layout==="vertical"?1:declaredCount),inferredRows=declaredRows||Math.max(1,Math.ceil(declaredCount/inferredColumns));
      const frameWidth=Math.floor(Number(animation.frameWidth)||(fallbackCrop?.sw?fallbackCrop.sw/inferredColumns:0)),frameHeight=Math.floor(Number(animation.frameHeight)||(fallbackCrop?.sh?fallbackCrop.sh/inferredRows:0));
      if(frameWidth>0&&frameHeight>0){
        const columns=Math.max(1,inferredColumns),baseX=Math.max(0,Math.floor(Number(animation.x)||fallbackCrop?.sx||0)),baseY=Math.max(0,Math.floor(Number(animation.y)||fallbackCrop?.sy||0));
        frames=Array.from({length:declaredCount},(_,index)=>({sx:baseX+(index%columns)*frameWidth,sy:baseY+Math.floor(index/columns)*frameHeight,sw:frameWidth,sh:frameHeight,src:"",duration:0}));
      }
    }
    if(frames.length<2&&!gif)return null;
    const totalDuration=Number(animation.duration)||0,defaultDuration=totalDuration>0&&frames.length?totalDuration/frames.length:1000/fps;
    frames.forEach(frame=>{frame.duration=clamp(frame.duration||defaultDuration,16,10000);});
    return {frameCount:frames.length||Math.max(1,declaredCount),frames,fps,loop,layout:gif?"gif":layout||"frames"};
  }

  function editorAnimationFrame(animation,timestamp){
    if(!animation)return {key:0,frame:null};
    if(animation.layout==="gif"&&!animation.frames.length)return {key:Math.floor(timestamp/(1000/animation.fps)),frame:null};
    const frames=animation.frames;if(!frames.length)return {key:0,frame:null};
    const total=frames.reduce((sum,frame)=>sum+frame.duration,0),elapsed=animation.loop?timestamp%total:Math.min(timestamp,total-1);let cursor=0,index=frames.length-1;
    for(let i=0;i<frames.length;i+=1){cursor+=frames[i].duration;if(elapsed<cursor){index=i;break;}}
    return {key:index,frame:frames[index]};
  }

  function paintEditorAssetCanvas(canvas,timestamp=performance.now(),force=false){
    const state=canvas._editorAssetPaint;if(!state)return;
    const current=editorAnimationFrame(state.animation,Math.max(0,timestamp-state.startedAt)),frame=current.frame,crop=frame||state.crop,image=frame?.src?getLevelImage(frame.src):state.image;
    if(!force&&state.lastFrame===current.key&&state.lastImage===image)return;
    if(!image?.complete||!image.naturalWidth||!image.naturalHeight){
      if(state.waitingFor!==image){state.waitingFor=image;image?.addEventListener("load",()=>{state.waitingFor=null;paintEditorAssetCanvas(canvas,performance.now(),true);},{once:true});}
      return;
    }
    const sx=clamp(Math.floor(crop.sx),0,image.naturalWidth-1),sy=clamp(Math.floor(crop.sy),0,image.naturalHeight-1),sw=clamp(Math.floor(crop.sw),1,image.naturalWidth-sx),sh=clamp(Math.floor(crop.sh),1,image.naturalHeight-sy),ctx=canvas.getContext("2d");
    ctx.clearRect(0,0,canvas.width,canvas.height);ctx.imageSmoothingEnabled=false;let dx=0,dy=0,dw=canvas.width,dh=canvas.height;
    if(state.fit){const scale=Math.min(canvas.width/sw,canvas.height/sh);dw=Math.max(1,Math.round(sw*scale));dh=Math.max(1,Math.round(sh*scale));dx=Math.round((canvas.width-dw)/2);dy=Math.round((canvas.height-dh)/2);}
    ctx.save();if(state.flipX){ctx.translate(canvas.width,0);ctx.scale(-1,1);dx=canvas.width-dx-dw;}ctx.drawImage(image,sx,sy,sw,sh,dx,dy,dw,dh);ctx.restore();
    state.lastFrame=current.key;state.lastImage=image;
  }

  function configureEditorAssetCanvas(canvas,image,crop,animation=null,flipX=false,fit=false){
    const normalizedAnimation=normalizeAssetAnimation(animation,crop);canvas._editorAssetPaint={image,crop,animation:normalizedAnimation,flipX:Boolean(flipX),fit:Boolean(fit),lastFrame:null,lastImage:null,waitingFor:null,startedAt:performance.now()};
    if(normalizedAnimation)animatedEditorCanvases.add(canvas);else animatedEditorCanvases.delete(canvas);
    paintEditorAssetCanvas(canvas,performance.now(),true);
  }

  function animatePlacedEditorAssets(timestamp){
    animatedEditorCanvases.forEach(canvas=>{if(!canvas.isConnected){animatedEditorCanvases.delete(canvas);return;}paintEditorAssetCanvas(canvas,timestamp);});
  }

  function createLevelProp(world, prop) {
    normalizeInteriorProp(prop);
    const canvas = document.createElement("canvas");
    canvas.className = "level-prop";
    canvas.dataset.propKey=prop.editorKey||"";
    world.append(canvas);
    syncLevelPropElement(prop,canvas);
  }

  function syncLevelPropElement(prop,existingCanvas=null) {
    normalizeInteriorProp(prop);
    const [src,sx,sy,sw,sh,dx,dy,dw,dh] = prop;
    const canvas=existingCanvas||$(`.level-prop[data-prop-key="${prop.editorKey}"]`);
    if(!canvas)return;
    const pixelWidth=Math.max(1,Math.round(dw)),pixelHeight=Math.max(1,Math.round(dh));
    if(canvas.width!==pixelWidth)canvas.width=pixelWidth;
    if(canvas.height!==pixelHeight)canvas.height=pixelHeight;
    canvas.style.left=`${dx}px`;canvas.style.top=`${dy}px`;canvas.style.width=`${dw}px`;canvas.style.height=`${dh}px`;
    canvas.style.zIndex=String(interiorPropZIndex(prop));canvas.hidden=Boolean(prop[13]);
    canvas.classList.toggle("prop-locked",Boolean(prop[12]));canvas.classList.toggle("prop-flipped",Boolean(prop[11]));
    configureEditorAssetCanvas(canvas,getLevelImage(src),{sx,sy,sw,sh},prop[14],prop[11]);
  }

  function renderRoomEditorPalette() {
    const palette=$("#room-edit-palette");
    palette.replaceChildren();
    const theme=LEVEL_THEMES[state.currentLocation];
    const selectedProp=selectedRoomEditorProp(),selectedNpc=selectedRoomEditorNpc(),selected=selectedProp||selectedNpc;
    const makeButton=(label,handler,options={})=>{const button=document.createElement("button");button.type="button";button.textContent=label;button.disabled=Boolean(options.disabled);if(options.title)button.title=options.title;button.addEventListener("click",event=>{event.stopPropagation();handler();});return button;};
    const top=document.createElement("div");top.className="room-editor-toolbar";
    const catalogNotice=document.createElement("span");catalogNotice.className="catalog-presence";catalogNotice.textContent="Build catalog open below";top.append(catalogNotice,makeButton("↶ Undo",undoRoomEditor,{disabled:!roomEditorUndo.length,title:"Undo room edit (Ctrl+Z)"}),makeButton("↷ Redo",redoRoomEditor,{disabled:!roomEditorRedo.length,title:"Redo room edit (Ctrl+Y)"}));
    const snapLabel=document.createElement("label");snapLabel.textContent="Snap ";const snap=document.createElement("select");snap.setAttribute("aria-label","Room editor snap size");[1,4,8,16,32].forEach(value=>{const option=document.createElement("option");option.value=String(value);option.textContent=value===1?"Off":`${value}px`;option.selected=value===roomEditorSnap;snap.append(option);});snap.addEventListener("change",()=>{roomEditorSnap=Number(snap.value)||1;});snapLabel.append(snap);top.append(snapLabel);
    const gridLabel=document.createElement("label");const grid=document.createElement("input");grid.type="checkbox";grid.checked=roomEditorShowGrid;grid.addEventListener("change",()=>{roomEditorShowGrid=grid.checked;renderRoomEditorHandles();});gridLabel.append(grid," Grid");top.append(gridLabel);
    palette.append(top);

    const additions=document.createElement("div");additions.className="room-editor-additions";const assetSelect=document.createElement("select");assetSelect.setAttribute("aria-label","Choose a room asset to add");
    if(theme.floor){const option=document.createElement("option");option.value="floor";option.textContent="Floor tile";assetSelect.append(option);}
    theme.props.forEach((prop,index)=>{const option=document.createElement("option");option.value=String(index);const file=friendlyAssetLabel(prop[0].split("/").pop().replace(/-Photoroom/gi,""),prop[0]);option.textContent=`${file} · ${index+1}`;assetSelect.append(option);});
    additions.append(assetSelect,makeButton("+ Add",()=>addRoomEditorProp(assetSelect.value)));palette.append(additions);

    const npcAdditions=document.createElement("div");npcAdditions.className="room-editor-additions room-npc-additions";const npcSelect=document.createElement("select");npcSelect.setAttribute("aria-label","Choose an NPC entity to add");
    Object.values(NPCS).sort((a,b)=>a.name.localeCompare(b.name)).forEach(npc=>{const option=document.createElement("option");option.value=npc.id;option.textContent=`${npc.avatar} ${npc.name} — ${npc.role}`;npcSelect.append(option);});npcAdditions.append(npcSelect,makeButton("+ Add NPC",()=>addRoomEditorNpc(npcSelect.value)));palette.append(npcAdditions);

    const inspector=document.createElement("div");inspector.className="room-editor-inspector";
    const selectionLabel=document.createElement("strong");selectionLabel.textContent=selectedNpc?`${NPCS[selectedNpc.npcId].avatar} ${NPCS[selectedNpc.npcId].name} · NPC entity`:selectedProp?(selectedProp.editorCustom?"Custom item":"Room item"):"Select an item or NPC to inspect";inspector.append(selectionLabel);
    if(selectedProp){
      const numberField=(labelText,index,min,max)=>{const label=document.createElement("label");label.textContent=labelText;const input=document.createElement("input");input.type="number";input.min=String(min);input.max=String(max);input.step="1";input.value=String(Math.round(selected[index]));input.addEventListener("change",()=>mutateSelectedRoomProp(prop=>{prop[index]=clamp(Math.round(Number(input.value)||0),min,max);if(index===7)prop[5]=clamp(prop[5],0,currentLevelWidth-prop[7]);if(index===8)prop[6]=clamp(prop[6],0,currentLevelHeight-prop[8]);}));label.append(input);return label;};
      inspector.append(numberField("X",5,0,currentLevelWidth-selected[7]),numberField("Y",6,0,currentLevelHeight-selected[8]),numberField("W",7,8,640),numberField("H",8,8,640));
      const layerLabel=document.createElement("label");layerLabel.textContent="Layer";const layer=document.createElement("select");[[0,"Floor"],[1,"Objects"],[2,"Overhead"]].forEach(([value,name])=>{const option=document.createElement("option");option.value=String(value);option.textContent=name;option.selected=interiorPropLayer(selected)===value;layer.append(option);});layer.addEventListener("change",()=>mutateSelectedRoomProp(prop=>{prop[9]=Number(layer.value);if(prop[9]===0&&prop[10]===undefined)prop[10]=false;}));layerLabel.append(layer);inspector.append(layerLabel);
      const toggleField=(labelText,index,invert=false)=>{const label=document.createElement("label");label.className="room-editor-check";const input=document.createElement("input");input.type="checkbox";input.checked=invert?!selected[index]:Boolean(selected[index]);input.addEventListener("change",()=>mutateSelectedRoomProp(prop=>{prop[index]=invert?!input.checked:input.checked;}));label.append(input,` ${labelText}`);return label;};
      inspector.append(toggleField("Collision",10),toggleField("Flip X",11),toggleField("Locked",12),toggleField("Visible",13,true));
    } else if(selectedNpc){
      const npcNumberField=(labelText,key,max)=>{const label=document.createElement("label");label.textContent=labelText;const input=document.createElement("input");input.type="number";input.min="0";input.max=String(max);input.step=String(roomEditorSnap);input.value=String(selectedNpc[key]);input.addEventListener("change",()=>mutateSelectedRoomNpc(entity=>{entity[key]=Number(input.value);}));label.append(input);return label;};
      inspector.append(npcNumberField("X","x",currentLevelWidth),npcNumberField("Y","y",currentLevelHeight));
      const npcSelectField=(labelText,key,values)=>{const label=document.createElement("label");label.textContent=labelText;const select=document.createElement("select");values.forEach(([value,name])=>{const option=document.createElement("option");option.value=value;option.textContent=name;option.selected=selectedNpc[key]===value;select.append(option);});select.addEventListener("change",()=>mutateSelectedRoomNpc(entity=>{entity[key]=select.value;}));label.append(select);return label;};
      inspector.append(npcSelectField("Behavior","behavior",[["static","Stay put"],["face-player","Face player"],["wander","Wander nearby"]]),npcSelectField("Facing","facing",[["south","South"],["west","West"],["east","East"],["north","North"]]));
      const npcToggle=(labelText,key)=>{const label=document.createElement("label");label.className="room-editor-check";const input=document.createElement("input");input.type="checkbox";input.checked=Boolean(selectedNpc[key]);input.addEventListener("change",()=>mutateSelectedRoomNpc(entity=>{entity[key]=input.checked;}));label.append(input,` ${labelText}`);return label;};
      inspector.append(npcToggle("Collision","collision"),npcToggle("Visible","visible"),npcToggle("Locked","locked"));
    }
    palette.append(inspector);

    const actions=document.createElement("div");actions.className="room-editor-actions";
    actions.append(makeButton("Duplicate",duplicateRoomEditorItem,{disabled:!selected}),makeButton(selectedNpc?"Remove":selectedProp?.editorCustom?"Remove":selectedProp?.[13]?"Show":"Hide",deleteRoomEditorItem,{disabled:!selected||Boolean(selectedNpc?.locked)}),makeButton("Reset Room",resetRoomEditorLayout));palette.append(actions);
  }

  function selectedRoomEditorProp(){return roomEditorSelection?.kind==="npc"?null:currentInteriorProps.find(prop=>prop.editorKey===roomEditorSelection?.key)||null;}
  function selectedRoomEditorNpc(){return roomEditorSelection?.kind==="npc"?currentInteriorNpcs.find(entity=>entity.id===roomEditorSelection.key)||null:null;}

  function cloneRoomEditorSnapshot(){return {props:currentInteriorProps.map(prop=>({data:Array.from(prop),key:prop.editorKey,custom:Boolean(prop.editorCustom)})),npcs:currentInteriorNpcs.map(entity=>({...entity}))};}
  function roomEditorSnapshotKey(snapshot){const normalized=Array.isArray(snapshot)?{props:snapshot,npcs:[]}:snapshot||{props:[],npcs:[]};return JSON.stringify([normalized.props.map(item=>[item.key,item.custom,item.data]),normalized.npcs]);}
  function commitRoomEditorHistory(before){
    if(!before||roomEditorSnapshotKey(before)===roomEditorSnapshotKey(cloneRoomEditorSnapshot()))return;
    roomEditorUndo.push(before);if(roomEditorUndo.length>60)roomEditorUndo.shift();roomEditorRedo=[];
  }
  function restoreRoomEditorSnapshot(snapshot){
    if(!snapshot)return;const normalized=Array.isArray(snapshot)?{props:snapshot,npcs:[]}:snapshot;
    currentInteriorProps=(normalized.props||[]).map(item=>{const prop=normalizeInteriorProp([...item.data]);prop.editorKey=item.key;prop.editorCustom=Boolean(item.custom);return prop;});
    currentInteriorNpcs=(normalized.npcs||[]).filter(item=>item&&NPCS[item.npcId]).map((item,index)=>normalizeNpcEntity(item,index,currentLevelWidth,currentLevelHeight,"room-npc"));
    $$(".level-prop",$("#interior-world")).forEach(element=>element.remove());currentInteriorProps.forEach(prop=>createLevelProp($("#interior-world"),prop));
    renderInteriorNpcEntities();if(!selectedRoomEditorProp()&&!selectedRoomEditorNpc())roomEditorSelection=null;persistCurrentInteriorLayout();renderRoomEditorHandles();
  }
  function undoRoomEditor(){if(!roomEditorUndo.length)return;roomEditorRedo.push(cloneRoomEditorSnapshot());restoreRoomEditorSnapshot(roomEditorUndo.pop());}
  function redoRoomEditor(){if(!roomEditorRedo.length)return;roomEditorUndo.push(cloneRoomEditorSnapshot());restoreRoomEditorSnapshot(roomEditorRedo.pop());}

  function mutateSelectedRoomProp(mutator){
    const prop=selectedRoomEditorProp();if(!prop)return;
    const before=cloneRoomEditorSnapshot();mutator(prop);normalizeInteriorProp(prop);syncLevelPropElement(prop);commitRoomEditorHistory(before);persistCurrentInteriorLayout();renderRoomEditorHandles();
  }

  function mutateSelectedRoomNpc(mutator){
    const entity=selectedRoomEditorNpc();if(!entity)return;const before=cloneRoomEditorSnapshot();mutator(entity);Object.assign(entity,normalizeNpcEntity(entity,currentInteriorNpcs.indexOf(entity),currentLevelWidth,currentLevelHeight,"room-npc"));if(entity.visible&&entity.collision){const point=nearestInteriorNpcPoint(entity,false,entity);entity.x=point.x;entity.y=point.y;}commitRoomEditorHistory(before);persistCurrentInteriorLayout();renderInteriorNpcEntities();renderRoomEditorHandles();
  }

  function renderRoomEditorHandles() {
    const world=$("#interior-world");
    if(!world)return;
    $$(".room-editor-handle",world).forEach(handle=>handle.remove());
    $("#location-scene")?.classList.toggle("room-editing",roomEditMode);
    world.classList.toggle("room-grid-visible",roomEditMode&&roomEditorShowGrid);
    if(!roomEditMode)return;
    currentInteriorProps.forEach(prop=>{
      const handle=document.createElement("button");handle.type="button";handle.className="room-editor-handle";handle.dataset.propKey=prop.editorKey;
      handle.style.left=`${prop[5]}px`;handle.style.top=`${prop[6]}px`;handle.style.width=`${prop[7]}px`;handle.style.height=`${prop[8]}px`;
      handle.classList.toggle("selected",roomEditorSelection?.kind!=="npc"&&roomEditorSelection?.key===prop.editorKey);
      handle.classList.toggle("locked",Boolean(prop[12]));handle.classList.toggle("hidden-prop",Boolean(prop[13]));
      handle.title=`${prop.editorCustom?"Custom":"Room"} item${prop[12]?" · locked":""}${prop[13]?" · hidden":""}`;
      handle.addEventListener("pointerdown",event=>beginRoomEditorDrag(event,prop));world.append(handle);
    });
    currentInteriorNpcs.forEach(entity=>{
      const handle=document.createElement("button");handle.type="button";handle.className="room-editor-handle npc-handle";handle.dataset.npcEntityKey=entity.id;handle.style.left=`${entity.x-38}px`;handle.style.top=`${entity.y-94}px`;handle.style.width="76px";handle.style.height="96px";
      handle.classList.toggle("selected",roomEditorSelection?.kind==="npc"&&roomEditorSelection.key===entity.id);handle.classList.toggle("locked",entity.locked);handle.classList.toggle("hidden-prop",!entity.visible);handle.title=`${NPCS[entity.npcId].name} · ${entity.behavior}${entity.locked?" · locked":""}${!entity.visible?" · hidden":""}`;
      handle.addEventListener("pointerdown",event=>beginRoomNpcDrag(event,entity));world.append(handle);
    });
    renderRoomEditorPalette();
  }

  function roomPointerPosition(event){const rect=$("#interior-world").getBoundingClientRect();return{x:event.clientX-rect.left,y:event.clientY-rect.top};}

  function beginRoomEditorDrag(event,prop){
    if(!roomEditMode)return;
    event.preventDefault();event.stopPropagation();const cursor=roomPointerPosition(event);
    roomEditorSelection={kind:"prop",key:prop.editorKey,custom:Boolean(prop.editorCustom)};
    if(prop[12]){renderRoomEditorHandles();return;}
    roomEditorDrag={prop,offsetX:cursor.x-prop[5],offsetY:cursor.y-prop[6],before:cloneRoomEditorSnapshot(),moved:false};
    event.currentTarget.setPointerCapture?.(event.pointerId);renderRoomEditorHandles();
  }

  function beginRoomNpcDrag(event,entity){
    if(!roomEditMode)return;event.preventDefault();event.stopPropagation();roomEditorSelection={kind:"npc",key:entity.id};
    if(entity.locked){renderRoomEditorHandles();return;}
    const cursor=roomPointerPosition(event);roomEditorDrag={kind:"npc",entity,offsetX:cursor.x-entity.x,offsetY:cursor.y-entity.y,before:cloneRoomEditorSnapshot(),moved:false};event.currentTarget.setPointerCapture?.(event.pointerId);renderRoomEditorHandles();
  }

  function moveRoomEditorDrag(event){
    if(!roomEditorDrag)return;
    event.preventDefault();const cursor=roomPointerPosition(event);
    if(roomEditorDrag.kind==="npc"){
      const entity=roomEditorDrag.entity,oldX=entity.x,oldY=entity.y,snap=Math.max(1,roomEditorSnap);entity.x=clamp(Math.round((cursor.x-roomEditorDrag.offsetX)/snap)*snap,36,currentLevelWidth-36);entity.y=clamp(Math.round((cursor.y-roomEditorDrag.offsetY)/snap)*snap,80,currentLevelHeight-24);roomEditorDrag.moved=roomEditorDrag.moved||oldX!==entity.x||oldY!==entity.y;
      const sim=interiorCustomNpcSims.get(entity.id),handle=$(`.room-editor-handle[data-npc-entity-key="${entity.id}"]`);if(sim){sim.x=entity.x;sim.y=entity.y;syncInteriorNpcSimElement(sim,performance.now());}if(handle){handle.style.left=`${entity.x-38}px`;handle.style.top=`${entity.y-94}px`;}return;
    }
    const prop=roomEditorDrag.prop;
    const oldX=prop[5],oldY=prop[6],snap=Math.max(1,roomEditorSnap);
    prop[5]=clamp(Math.round((cursor.x-roomEditorDrag.offsetX)/snap)*snap,0,currentLevelWidth-prop[7]);
    prop[6]=clamp(Math.round((cursor.y-roomEditorDrag.offsetY)/snap)*snap,0,currentLevelHeight-prop[8]);
    roomEditorDrag.moved=roomEditorDrag.moved||oldX!==prop[5]||oldY!==prop[6];
    const canvas=$(`.level-prop[data-prop-key="${prop.editorKey}"]`),handle=$(`.room-editor-handle[data-prop-key="${prop.editorKey}"]`);
    [canvas,handle].forEach(element=>{if(element){element.style.left=`${prop[5]}px`;element.style.top=`${prop[6]}px`;}});
    if(canvas)canvas.style.zIndex=String(interiorPropZIndex(prop));
  }

  function finishRoomEditorDrag(){if(!roomEditorDrag)return;const drag=roomEditorDrag;roomEditorDrag=null;if(drag.kind==="npc"&&drag.entity.visible&&drag.entity.collision){const point=nearestInteriorNpcPoint(drag.entity,false,drag.entity);drag.entity.x=point.x;drag.entity.y=point.y;renderInteriorNpcEntities();}if(drag.moved){commitRoomEditorHistory(drag.before);persistCurrentInteriorLayout();}renderRoomEditorHandles();}

  function persistCurrentInteriorLayout(){
    const id=state.currentLocation,entry=interiorEditorLayout[id]||{base:{},custom:[]};entry.base={};entry.layoutVersion=5;entry.themeSignature=interiorThemeSignature(id);entry.worldWidth=currentLevelWidth;entry.worldHeight=currentLevelHeight;
    currentInteriorProps.filter(prop=>!prop.editorCustom).forEach(prop=>entry.base[prop.editorKey.split("-")[1]]=[prop[5],prop[6],prop[7],prop[8],interiorPropLayer(prop),interiorPropCollides(prop),Boolean(prop[11]),Boolean(prop[12]),Boolean(prop[13])]);
    entry.custom=currentInteriorProps.filter(prop=>prop.editorCustom).map(prop=>({id:prop.editorKey,prop:Array.from(prop)}));
    entry.layoutVersion=5;entry.npcs=currentInteriorNpcs.map(entity=>({...entity}));
    interiorEditorLayout[id]=entry;saveInteriorEditorLayout();
  }

  function addRoomEditorProp(key){
    const theme=LEVEL_THEMES[state.currentLocation];let prop;
    if(key==="floor"&&theme.floor){const [src,sx,sy,sw,sh]=theme.floor;const size=sw<=16?64:Math.max(32,Math.min(96,sw));prop=[src,sx,sy,sw,sh,0,0,size,size,0,false];}
    else {const source=theme.props[Number(key)];if(!source)return;prop=[...source];}
    const before=cloneRoomEditorSnapshot();normalizeInteriorProp(prop);
    const scene=$("#location-scene").getBoundingClientRect(),world=$("#interior-world").getBoundingClientRect();
    prop[5]=clamp(Math.round((scene.left+scene.width/2-world.left-prop[7]/2)/roomEditorSnap)*roomEditorSnap,0,currentLevelWidth-prop[7]);
    prop[6]=clamp(Math.round((scene.top+scene.height/2-world.top-prop[8]/2)/roomEditorSnap)*roomEditorSnap,0,currentLevelHeight-prop[8]);
    prop.editorKey=`custom-${Date.now()}-${Math.random().toString(16).slice(2)}`;prop.editorCustom=true;
    currentInteriorProps.push(prop);createLevelProp($("#interior-world"),prop);roomEditorSelection={key:prop.editorKey,custom:true};commitRoomEditorHistory(before);persistCurrentInteriorLayout();renderRoomEditorHandles();
  }

  function addRoomEditorNpc(npcId){
    if(!NPCS[npcId])return;if(currentInteriorNpcs.length>=100){showSceneToast("Room NPC limit reached (100).");return;}const before=cloneRoomEditorSnapshot(),scene=$("#location-scene").getBoundingClientRect(),world=$("#interior-world").getBoundingClientRect(),snap=Math.max(1,roomEditorSnap);
    const x=clamp(Math.round((scene.left+scene.width/2-world.left)/snap)*snap,36,currentLevelWidth-36),y=clamp(Math.round((scene.top+scene.height/2-world.top)/snap)*snap,80,currentLevelHeight-24),point=nearestInteriorNpcPoint({x,y},true),entity=normalizeNpcEntity({id:uniqueNpcEntityId("room-npc",currentInteriorNpcs),npcId,x:point.x,y:point.y},currentInteriorNpcs.length,currentLevelWidth,currentLevelHeight,"room-npc");
    currentInteriorNpcs.push(entity);roomEditorSelection={kind:"npc",key:entity.id};commitRoomEditorHistory(before);persistCurrentInteriorLayout();renderInteriorNpcEntities();renderRoomEditorHandles();showSceneToast(`${NPCS[npcId].name} added as an interactive NPC.`);
  }

  function deleteRoomEditorItem(){
    const npcEntity=selectedRoomEditorNpc();if(npcEntity){if(npcEntity.locked)return;const before=cloneRoomEditorSnapshot();currentInteriorNpcs=currentInteriorNpcs.filter(entity=>entity!==npcEntity);roomEditorSelection=null;commitRoomEditorHistory(before);persistCurrentInteriorLayout();renderInteriorNpcEntities();renderRoomEditorHandles();return;}
    const prop=selectedRoomEditorProp();if(!prop)return;const before=cloneRoomEditorSnapshot();
    if(prop.editorCustom){currentInteriorProps=currentInteriorProps.filter(item=>item!==prop);$(`.level-prop[data-prop-key="${prop.editorKey}"]`)?.remove();roomEditorSelection=null;}
    else {prop[13]=!prop[13];syncLevelPropElement(prop);}
    commitRoomEditorHistory(before);persistCurrentInteriorLayout();renderRoomEditorHandles();
  }

  function duplicateRoomEditorItem(){
    const npcSource=selectedRoomEditorNpc();if(npcSource){if(currentInteriorNpcs.length>=100){showSceneToast("Room NPC limit reached (100).");return;}const before=cloneRoomEditorSnapshot(),target=nearestInteriorNpcPoint({x:npcSource.x+32,y:npcSource.y+32}),entity=normalizeNpcEntity({...npcSource,id:uniqueNpcEntityId("room-npc",currentInteriorNpcs),x:target.x,y:target.y,locked:false},currentInteriorNpcs.length,currentLevelWidth,currentLevelHeight,"room-npc");currentInteriorNpcs.push(entity);roomEditorSelection={kind:"npc",key:entity.id};commitRoomEditorHistory(before);persistCurrentInteriorLayout();renderInteriorNpcEntities();renderRoomEditorHandles();return;}
    const source=currentInteriorProps.find(prop=>prop.editorKey===roomEditorSelection?.key);if(!source)return;
    const before=cloneRoomEditorSnapshot(),prop=[...source];prop[5]=clamp(source[5]+32,0,currentLevelWidth-source[7]);prop[6]=clamp(source[6]+32,0,currentLevelHeight-source[8]);prop[12]=false;prop[13]=false;
    prop.editorKey=`custom-${Date.now()}-${Math.random().toString(16).slice(2)}`;prop.editorCustom=true;
    currentInteriorProps.push(prop);createLevelProp($("#interior-world"),prop);roomEditorSelection={key:prop.editorKey,custom:true};commitRoomEditorHistory(before);persistCurrentInteriorLayout();renderRoomEditorHandles();
  }

  function nudgeRoomEditorSelection(dx,dy){
    const npcEntity=selectedRoomEditorNpc();if(npcEntity){if(npcEntity.locked)return;mutateSelectedRoomNpc(entity=>{entity.x=clamp(entity.x+dx,36,currentLevelWidth-36);entity.y=clamp(entity.y+dy,80,currentLevelHeight-24);});return;}
    const prop=selectedRoomEditorProp();if(!prop||prop[12])return;mutateSelectedRoomProp(item=>{item[5]=clamp(item[5]+dx,0,currentLevelWidth-item[7]);item[6]=clamp(item[6]+dy,0,currentLevelHeight-item[8]);});
  }

  function resetRoomEditorLayout(){
    if(!window.confirm(`Reset ${LOCATIONS[state.currentLocation].short} to its default interior layout?`))return;
    const before=cloneRoomEditorSnapshot();delete interiorEditorLayout[state.currentLocation];saveInteriorEditorLayout();roomEditorSelection=null;buildInteriorWorld(state.currentLocation);commitRoomEditorHistory(before);renderExplorationScene(state.currentLocation);renderRoomEditorHandles();
  }

  async function ensureAssetCatalogLoaded() {
    if(window.CURATED_ART_ASSET_CATALOG)return window.CURATED_ART_ASSET_CATALOG;
    if(assetCatalogLoadPromise)return assetCatalogLoadPromise;
    assetCatalogLoadPromise=new Promise((resolve,reject)=>{const script=document.createElement("script");script.src="curated-asset-catalog.js?v=5";script.async=true;script.addEventListener("load",()=>resolve(window.CURATED_ART_ASSET_CATALOG),{once:true});script.addEventListener("error",()=>reject(new Error("The build catalog could not be loaded.")),{once:true});document.head.append(script);});
    return assetCatalogLoadPromise;
  }

  async function openAssetBrowser(context) {
    assetBrowserContext=context;
    assetBrowserPage=0;
    assetDockCollapsed=true;$("#asset-browser-overlay").classList.add("collapsed");$("#asset-browser-close").textContent="⌃";$("#asset-browser-close").setAttribute("aria-expanded","false");$("#asset-browser-close").setAttribute("aria-label","Expand build catalog");
    $("#asset-browser-title").textContent=context==="town"?"Town Build Catalog":"Interior Build Catalog";
    $("#asset-place-button").textContent=context==="town"?"Place in town":"Place in room";
    show("asset-browser-overlay");
    const grid=$("#asset-browser-grid");grid.replaceChildren();const loading=document.createElement("div");loading.className="asset-browser-loading";loading.textContent="Loading the full build catalog only when you need it…";grid.append(loading);$("#asset-browser-count").textContent="Loading…";
    try{await ensureAssetCatalogLoaded();setupAssetBrowser();renderAssetBrowser();}catch(error){loading.textContent=`${error.message} Resident placement is still available.`;setupAssetBrowser();renderAssetBrowser();}
  }

  function closeAssetBrowser(){hide("asset-browser-overlay");}
  function toggleAssetDock(){assetDockCollapsed=!assetDockCollapsed;const dock=$("#asset-browser-overlay"),button=$("#asset-browser-close");dock.classList.toggle("collapsed",assetDockCollapsed);button.textContent=assetDockCollapsed?"⌃":"⌄";button.setAttribute("aria-expanded",String(!assetDockCollapsed));button.setAttribute("aria-label",assetDockCollapsed?"Expand build catalog":"Collapse build catalog");}

  function assetCatalogSources(){
    const curated=window.CURATED_ART_ASSET_CATALOG;
    if(Array.isArray(curated?.sources)&&curated.sources.length)return curated.sources;
    if(Array.isArray(curated)&&curated.length)return curated;
    const legacy=window.ART_ASSET_CATALOG;
    if(Array.isArray(legacy?.sources))return legacy.sources;
    return Array.isArray(legacy)?legacy:[];
  }

  function inferredAssetKind(entry){
    const explicit=entry?.kind||entry?.classification?.kind;if(explicit)return String(explicit).toLowerCase();
    const text=`${entry?.name||""} ${entry?.src||""}`.toLowerCase();
    if(/(?:^|[/ _-])(preview|contact[ _-]?sheet|reference|sample)(?:[. /_-]|$)/.test(text))return text.includes("contact")?"contact-sheet":"preview";
    if(/sprite[ _-]?sheet/.test(text))return "character-sheet";
    if(/tile[ _-]?(?:set|sheet|map)/.test(text))return "tile-sheet";
    if(/(?:animation|\d+frames?|\.gif$)/.test(text))return "animation";
    return "standalone";
  }

  function friendlyAssetLabel(raw,src=""){
    let value=String(raw||src.split("/").pop()||"Asset").replace(/\.[^.]+$/," ").replace(/(?<=[a-z0-9])(?=[A-Z])/g," ").replace(/[_-]+/g," ").replace(/^[!$#@]+/,"").replace(/\s+\d{2,4}\s*[x×]\s*\d{2,4}$/i,"").replace(/\s+/g," ").trim();
    const frame=value.match(/^frame\s*(\d+)$/i);if(frame){const parts=src.split("/").slice(0,-1),direction=parts.at(-1)?.replace(/[_-]+/g," "),action=parts.at(-2)?.replace(/[_-]+/g," ");value=[action,direction,`Frame ${Number(frame[1])+1}`].filter(Boolean).join(" · ");}
    if(/^\d+$/.test(value)){const parent=src.split("/").at(-2)?.replace(/[_-]+/g," ")||"Collection";value=`${parent} · Sheet ${Number(value)}`;}
    value=value.replace(/^dfgui icon (.+)$/i,"$1 Icon").replace(/\bdetilazation\b/ig,"Detailing").replace(/\bcrystael\b/ig,"Crystal");
    return value.replace(/\b(?:td)\b/ig,"Top Down").replace(/\biso\b/ig,"Isometric").replace(/\batk\b/ig,"Attack");
  }

  function inferAssetCategory(asset){
    if(asset.entityType==="npc")return "npcs";const explicit=String(asset.variant?.category||asset.source?.category||"").toLowerCase();if(["buildings","terrain","nature","furniture","decor","characters","effects","interface"].includes(explicit))return explicit;
    const text=` ${asset.name} ${asset.pack} ${asset.kind} ${asset.src} `.toLowerCase(),has=(...words)=>words.some(word=>text.includes(word));
    if(has("character"," npc","enemy","monster","zombie","skeleton","villager","robot","dragon"))return "characters";
    if(has("building","house","cottage","shop","castle","roof","door","window","wall","arch","tower","village"))return "buildings";
    if(has("furniture","chair","table","desk"," bed ","sofa","couch","bench","shelf","cabinet","counter","stool"))return "furniture";
    if(has("tree","plant","flower","bush","grass","rock","crystal","mushroom","forest","river"))return "nature";
    if(has("terrain","ground","floor","road","path","tile","tileset","autotile"," map "))return "terrain";
    if(has("effect"," fx ","magic","lightning","fire","smoke","spark","explosion","particle"))return "effects";
    if(has(" gui"," ui","icon","button","cursor"," hud","banner","panel"))return "interface";
    return "decor";
  }

  function loadAssetLibraryPrefs(){try{const saved=JSON.parse(localStorage.getItem(ASSET_LIBRARY_PREFS_KEY)||"{}");assetFavoriteKeys=new Set(Array.isArray(saved.favorites)?saved.favorites.slice(0,500).map(String):[]);assetRecentKeys=Array.isArray(saved.recent)?saved.recent.slice(0,40).map(String):[];}catch{assetFavoriteKeys=new Set();assetRecentKeys=[];}}
  function saveAssetLibraryPrefs(){try{localStorage.setItem(ASSET_LIBRARY_PREFS_KEY,JSON.stringify({favorites:[...assetFavoriteKeys],recent:assetRecentKeys}));}catch{/* optional */}}
  function toggleAssetFavorite(key){if(!key)return;if(assetFavoriteKeys.has(key))assetFavoriteKeys.delete(key);else assetFavoriteKeys.add(key);saveAssetLibraryPrefs();renderAssetBrowser();syncSelectedAssetFavorite();}
  function rememberRecentAsset(key){assetRecentKeys=[key,...assetRecentKeys.filter(item=>item!==key)].slice(0,40);saveAssetLibraryPrefs();}
  function syncSelectedAssetFavorite(){const button=$("#asset-selected-favorite"),selected=assetBrowserSelected;if(!button)return;button.disabled=!selected;const active=Boolean(selected&&assetFavoriteKeys.has(selected.key));button.classList.toggle("active",active);button.textContent=active?"★":"☆";button.setAttribute("aria-label",active?"Remove selected asset from favorites":"Add selected asset to favorites");}

  function normalizeAssetGrid(grid,source){
    if(!grid||typeof grid!=="object")return null;
    const rawCellWidth=Math.floor(Number(grid.cellWidth??grid.tileWidth)||0),rawCellHeight=Math.floor(Number(grid.cellHeight??grid.tileHeight)||0);if(rawCellWidth<1||rawCellHeight<1)return null;const cellWidth=rawCellWidth,cellHeight=rawCellHeight;
    const columns=Math.max(1,Math.floor(Number(grid.columns)||(Number(source.width)>0?Number(source.width)/cellWidth:1))),rows=Math.max(1,Math.floor(Number(grid.rows)||(Number(source.height)>0?Number(source.height)/cellHeight:1)));
    return {cellWidth,cellHeight,columns,rows,confidence:Number(grid.confidence)||0};
  }

  function expandAssetCatalog(sources){
    const visible=[];
    const sourceViews=[];
    sources.forEach((raw,index)=>{
      sourceViews.push({raw,index});
      if(raw&&typeof raw==="object"&&Array.isArray(raw.aliases))raw.aliases.forEach((alias,aliasIndex)=>{
        if(!alias?.src)return;
        const aliasId=String(alias.id||`alias-${aliasIndex}`),clone={...raw,...alias,id:`${raw.id||`source-${index}`}::${aliasId}`,aliases:[]};
        if(Array.isArray(raw.variants))clone.variants=raw.variants.map((variant,variantIndex)=>({...variant,id:`${variant.id||`variant-${variantIndex}`}::${aliasId}`,src:alias.src}));
        sourceViews.push({raw:clone,index:`${index}-alias-${aliasIndex}`});
      });
    });
    sourceViews.forEach(({raw,index})=>{
      const source=typeof raw==="string"?{src:raw}:raw;if(!source||typeof source!=="object")return;
      const src=String(source.src||source.path||"");if(!src)return;
      const file=src.split("/").pop()||`Asset ${index}`,name=friendlyAssetLabel(source.name||file,src),pack=String(source.pack||src.split("/").slice(0,-1).join(" / ")||"Other").trim(),sourceId=String(source.id||`source-${index}-${src}`),sourceKind=inferredAssetKind(source),grid=normalizeAssetGrid(source.grid,source);
      const listed=Array.isArray(source.variants)?source.variants:Array.isArray(source.crops)?source.crops:[],regions=Array.isArray(source.regions)?source.regions:[],group=[],sourceWarnings=(Array.isArray(source.warnings)?source.warnings:[source.warning]).filter(Boolean).map(String);
      const hasDirectionalVariants=listed.some(variant=>Boolean(variant?.animation?.directionName));
      const add=(variant,variantIndex,options={})=>{
        const variantSrc=String(variant?.src||src),kind=String(variant?.kind||sourceKind).toLowerCase(),gifSource=String(source.format||"").toLowerCase()==="gif"||/\.gif$/i.test(variantSrc),rawAnimation=options.manual?null:variant?.animation||source.animation||(gifSource?{layout:"gif",fps:10}:null),animation=normalizeAssetAnimation(gifSource&&rawAnimation?{...rawAnimation,layout:"gif",format:"gif"}:rawAnimation,normalizeAssetCrop(variant)),animatedCrop=animation?.frames?.[0]||null;
        const crop=animatedCrop||normalizeAssetCrop(variant,normalizeAssetCrop(source.bounds));
        const preview=!options.manual&&(source.preview===true||variant?.preview===true||["preview","contact-sheet","reference"].includes(kind)),usableValue=variant?.usable===undefined?source.usable:variant.usable,usable=usableValue===undefined?true:usableValue===true,review=!options.manual&&(variant?.review===true||source.review===true||String(variant?.status||source.status||usableValue).toLowerCase()==="review"),ready=usable&&!preview&&(!review||options.regionCrop),rawConfidence=Number(variant?.confidence??source.confidence??grid?.confidence)||0,confidence=clamp(rawConfidence>1?rawConfidence/100:rawConfidence,0,1),warnings=[...sourceWarnings,...(Array.isArray(variant?.warnings)?variant.warnings:[variant?.warning]).filter(Boolean).map(String)];
        const variantId=String(variant?.id||options.variantId||`${sourceId}:${variantIndex}`),variantName=friendlyAssetLabel(variant?.name||options.name||name,variantSrc),candidate={
          key:`${sourceId}::${variantId}`,sourceId,variantId,src:variantSrc,name:variantName,sourceName:name,pack,kind,usable,ready,review,preview,crop,animation,grid,source,variant:variant||{},warnings,confidence,reason:String(variant?.reason||source.reason||""),manual:Boolean(options.manual),isRegion:Boolean(options.regionCrop),libraryVisible:options.libraryVisible!==false
        };
        candidate.directionPreview=String(variant?.animation?.directionName||"").toLowerCase()||null;candidate.category=inferAssetCategory(candidate);
        group.push(candidate);if(candidate.libraryVisible)visible.push(candidate);return candidate;
      };
      if(listed.length)listed.forEach((variant,variantIndex)=>{const direction=String(variant?.animation?.directionName||"").toLowerCase();add(variant,variantIndex,{libraryVisible:!hasDirectionalVariants||direction==="south"});});
      else if(!regions.length&&grid)for(let row=0;row<grid.rows;row+=1)for(let column=0;column<grid.columns;column+=1)add({x:column*grid.cellWidth,y:row*grid.cellHeight,w:grid.cellWidth,h:grid.cellHeight,kind:sourceKind,usable:source.usable},row*grid.columns+column,{variantId:`${sourceId}:grid:${column}:${row}`,name:`${name} · Cell ${column+1}, ${row+1}`});
      else if(!regions.length)add(source,0,{variantId:`${sourceId}:whole`,name});
      const existingRegionCrops=new Set(group.map(candidate=>candidate.crop?`${candidate.crop.sx}:${candidate.crop.sy}:${candidate.crop.sw}:${candidate.crop.sh}`:""));
      regions.forEach((region,regionIndex)=>{
        const crop=normalizeAssetCrop(region);if(!crop)return;const cropKey=`${crop.sx}:${crop.sy}:${crop.sw}:${crop.sh}`;if(existingRegionCrops.has(cropKey))return;existingRegionCrops.add(cropKey);
        add({
          id:`${sourceId}:region:${regionIndex}`,name:`${name} · Region ${regionIndex+1}`,x:crop.sx,y:crop.sy,w:crop.sw,h:crop.sh,
          kind:source.regionsKind||((sourceKind==="tileset"||sourceKind==="tile-sheet")?"tile":"sprite"),usable:source.regionsUsable??source.usable,
          review:source.regionsReview??source.review,confidence:source.regionsConfidence??source.confidence,reason:source.regionsReason||source.reason
        },group.length,{libraryVisible:true,regionCrop:true});
      });
      if(grid||regions.length)add({x:0,y:0,w:Number(source.width)||(grid?.cellWidth||1),h:Number(source.height)||(grid?.cellHeight||1),kind:sourceKind,usable:true},group.length,{variantId:`${sourceId}:manual`,name:`${name} · Manual crop`,manual:true,libraryVisible:false});
      group.forEach(candidate=>{candidate.group=group;});
    });
    return visible;
  }

  function runtimeNpcAssetCatalog(){return Object.values(NPCS).sort((a,b)=>a.name.localeCompare(b.name)).map(npc=>{const candidate={key:`npc::${npc.id}`,sourceId:`npc-${npc.id}`,variantId:`npc-${npc.id}-south`,name:npc.name,sourceName:npc.name,pack:"Residents",kind:"npc",category:"npcs",entityType:"npc",npcId:npc.id,npc,ready:true,usable:true,review:false,preview:false,warnings:[],confidence:1,reason:"",libraryVisible:true,directionPreview:"south"};candidate.group=[candidate];return candidate;});}

  function assetKindLabel(kind){return String(kind||"asset").replace(/[-_]+/g," ").replace(/\b\w/g,letter=>letter.toUpperCase());}

  function setupAssetBrowser() {
    if(assetBrowserReady&&assetCatalogSources().length)return;
    loadAssetLibraryPrefs();assetBrowserCatalog=[...runtimeNpcAssetCatalog(),...expandAssetCatalog(assetCatalogSources())];
    const packSelect=$("#asset-pack-filter"),kindSelect=$("#asset-kind-filter"),packDefault=document.createElement("option"),kindDefault=document.createElement("option");packDefault.value="";packDefault.textContent="All asset packs";kindDefault.value="";kindDefault.textContent="All asset kinds";packSelect.replaceChildren(packDefault);kindSelect.replaceChildren(kindDefault);
    [...new Set(assetBrowserCatalog.map(asset=>asset.pack).filter(Boolean))].sort((a,b)=>a.localeCompare(b)).forEach(pack=>{const option=document.createElement("option");option.value=pack;option.textContent=pack;packSelect.append(option);});
    [...new Set(assetBrowserCatalog.map(asset=>asset.kind).filter(Boolean))].sort().forEach(kind=>{const option=document.createElement("option");option.value=kind;option.textContent=assetKindLabel(kind);kindSelect.append(option);});
    renderAssetCategories();
    assetBrowserReady=Boolean(assetCatalogSources().length);
  }

  const ASSET_CATEGORIES=[["all","All","▦"],["favorites","Favorites","★"],["recent","Recent","◷"],["npcs","Residents","☺"],["buildings","Buildings","⌂"],["terrain","Terrain","▤"],["nature","Nature","♣"],["furniture","Furniture","▰"],["decor","Decor","✦"],["characters","Characters","♟"],["effects","Effects","ϟ"],["interface","Interface","▣"]];
  function assetMatchesCategory(asset,category){if(category==="all")return true;if(category==="favorites")return assetFavoriteKeys.has(asset.key);if(category==="recent")return assetRecentKeys.includes(asset.key);return asset.category===category;}
  function renderAssetCategories(){const nav=$("#asset-category-tabs");if(!nav)return;nav.replaceChildren();ASSET_CATEGORIES.forEach(([id,label,icon])=>{const count=assetBrowserCatalog.filter(asset=>asset.ready&&assetMatchesCategory(asset,id)).length,button=document.createElement("button");button.type="button";button.dataset.category=id;button.classList.toggle("active",assetBrowserCategory===id);button.setAttribute("aria-pressed",String(assetBrowserCategory===id));button.append(document.createTextNode(`${icon} ${label} `));const small=document.createElement("small");small.textContent=count.toLocaleString();button.append(small);button.addEventListener("click",()=>{assetBrowserCategory=id;assetBrowserPage=0;renderAssetBrowser();});nav.append(button);});}

  function renderAssetCardPreview(canvas,asset){
    if(asset.entityType==="npc"){
      const sprite=asset.npc.sprite,source=sprite.directions?`${sprite.directions}south.png`:typeof sprite.walkFrames==="string"?`${sprite.walkFrames}/Front/Standing/Front_Standing_Walk_1.png`:sprite.sheet,image=getLevelImage(source),paint=()=>paintNpcEntityCanvas(canvas,asset.npcId,"south",false,0);if(image.complete&&image.naturalWidth)paint();else image.addEventListener("load",paint,{once:true});return;
    }
    const image=getLevelImage(asset.src),paint=()=>{
      if(!image.naturalWidth||!image.naturalHeight)return;const crop=asset.animation?.frames?.[0]||asset.crop||{sx:0,sy:0,sw:image.naturalWidth,sh:image.naturalHeight},sx=clamp(crop.sx,0,image.naturalWidth-1),sy=clamp(crop.sy,0,image.naturalHeight-1),sw=clamp(crop.sw,1,image.naturalWidth-sx),sh=clamp(crop.sh,1,image.naturalHeight-sy),ctx=canvas.getContext("2d"),scale=Math.min(canvas.width/sw,canvas.height/sh),dw=Math.max(1,Math.round(sw*scale)),dh=Math.max(1,Math.round(sh*scale));ctx.clearRect(0,0,canvas.width,canvas.height);ctx.imageSmoothingEnabled=false;ctx.drawImage(image,sx,sy,sw,sh,Math.round((canvas.width-dw)/2),Math.round((canvas.height-dh)/2),dw,dh);
    };
    if(image.complete&&image.naturalWidth)paint();else image.addEventListener("load",paint,{once:true});
  }

  function renderAssetBrowser() {
    const query=$("#asset-search").value.trim().toLowerCase();
    const pack=$("#asset-pack-filter").value;
    const kind=$("#asset-kind-filter").value,usableOnly=$("#asset-usable-only").checked,sort=$("#asset-sort").value,recentRanks=new Map(assetRecentKeys.map((key,index)=>[key,index]));
    assetBrowserFiltered=assetBrowserCatalog.filter(asset=>assetMatchesCategory(asset,assetBrowserCategory)&&(!pack||asset.pack===pack)&&(!kind||asset.kind===kind)&&(!usableOnly||asset.ready)&&(!query||`${asset.name} ${asset.sourceName} ${asset.pack} ${asset.kind} ${asset.category} ${asset.src||""} ${asset.npc?.role||""} ${asset.reason} ${asset.warnings.join(" ")}`.toLowerCase().includes(query)));
    assetBrowserFiltered.sort((a,b)=>{if(sort==="name")return a.name.localeCompare(b.name)||a.pack.localeCompare(b.pack);if(sort==="pack")return a.pack.localeCompare(b.pack)||a.name.localeCompare(b.name);const favorite=Number(assetFavoriteKeys.has(b.key))-Number(assetFavoriteKeys.has(a.key));if(favorite)return favorite;const recent=(recentRanks.get(a.key)??999)-(recentRanks.get(b.key)??999);if(recent)return recent;return Number(b.ready)-Number(a.ready)||a.name.localeCompare(b.name);});
    const pageSize=48;
    const pages=Math.max(1,Math.ceil(assetBrowserFiltered.length/pageSize));
    assetBrowserPage=clamp(assetBrowserPage,0,pages-1);
    const sourceCount=new Set(assetBrowserFiltered.map(asset=>asset.sourceId)).size;$("#asset-browser-count").textContent=`${assetBrowserFiltered.length.toLocaleString()} items · ${sourceCount.toLocaleString()} sources`;
    $("#asset-page-label").textContent=`Page ${assetBrowserPage+1} of ${pages}`;
    $("#asset-page-prev").disabled=assetBrowserPage===0;
    $("#asset-page-next").disabled=assetBrowserPage>=pages-1;
    const grid=$("#asset-browser-grid");grid.replaceChildren();
    const items=assetBrowserFiltered.slice(assetBrowserPage*pageSize,(assetBrowserPage+1)*pageSize);if(!items.length){const empty=document.createElement("div");empty.className="asset-browser-empty";empty.textContent=assetBrowserCategory==="favorites"?"Star items to keep them in Favorites.":assetBrowserCategory==="recent"?"Placed items will appear here.":"No build items match these filters.";grid.append(empty);}
    let lastPack="";
    items.forEach(asset=>{
      if(sort==="pack"&&asset.pack!==lastPack){lastPack=asset.pack;const heading=document.createElement("h3");heading.className="asset-pack-heading";heading.textContent=asset.pack;grid.append(heading);}
      const card=document.createElement("article");card.className="asset-card";card.dataset.assetKey=asset.key;card.classList.toggle("selected",assetBrowserSelected?.key===asset.key);card.title=[asset.src,asset.npc?.role,asset.reason,...asset.warnings].filter(Boolean).join("\n");card.setAttribute("role","listitem");
      const main=document.createElement("button");main.type="button";main.className="asset-card-main";main.setAttribute("aria-label",`${asset.name}, ${asset.entityType==="npc"?"resident":assetKindLabel(asset.kind)}${asset.animation?", animated":""}${asset.ready?"":", not ready to place"}`);
      const canvas=document.createElement("canvas");canvas.width=112;canvas.height=112;canvas.setAttribute("aria-hidden","true");renderAssetCardPreview(canvas,asset);
      const label=document.createElement("span");label.className="asset-card-name";label.textContent=asset.name;const badges=document.createElement("div");badges.className="asset-card-badges";const badge=text=>{const element=document.createElement("small");element.textContent=text;badges.append(element);return element;};badge(asset.entityType==="npc"?"Resident":assetKindLabel(asset.kind));if(asset.directionPreview==="south")badge("South preview");if(asset.isRegion)badge("Sliced sprite");else if(asset.grid)badge("Grid cell");if(asset.animation)badge(`${asset.animation.frameCount}f`).classList.add("animated");if(!asset.ready)badge(asset.review?"Review":"Reference").classList.add("unusable");
      main.append(canvas,label,badges);main.addEventListener("click",()=>selectBrowserAsset(asset));main.addEventListener("dblclick",()=>{selectBrowserAsset(asset);if(asset.entityType==="npc")placeBrowserAsset();});
      const favorite=document.createElement("button");favorite.type="button";favorite.className="asset-card-favorite";favorite.classList.toggle("active",assetFavoriteKeys.has(asset.key));favorite.textContent=assetFavoriteKeys.has(asset.key)?"★":"☆";favorite.setAttribute("aria-label",`${assetFavoriteKeys.has(asset.key)?"Remove":"Add"} ${asset.name} ${assetFavoriteKeys.has(asset.key)?"from":"to"} favorites`);favorite.addEventListener("click",event=>{event.stopPropagation();toggleAssetFavorite(asset.key);});
      card.append(main,favorite);grid.append(card);
    });
    renderAssetCategories();
  }

  function handleAssetGridKeydown(event){
    if(!["ArrowLeft","ArrowRight","ArrowUp","ArrowDown","Home","End"].includes(event.key))return;const buttons=$$(".asset-card-main",$("#asset-browser-grid"));if(!buttons.length)return;const current=Math.max(0,buttons.indexOf(document.activeElement)),cardWidth=buttons[0].closest(".asset-card")?.getBoundingClientRect().width||112,columns=Math.max(1,Math.floor($("#asset-browser-grid").clientWidth/cardWidth));let next=current;if(event.key==="ArrowLeft")next-=1;if(event.key==="ArrowRight")next+=1;if(event.key==="ArrowUp")next-=columns;if(event.key==="ArrowDown")next+=columns;if(event.key==="Home")next=0;if(event.key==="End")next=buttons.length-1;next=clamp(next,0,buttons.length-1);event.preventDefault();buttons[next].focus({preventScroll:true});buttons[next].scrollIntoView({block:"nearest",inline:"nearest"});
  }

  function browserCatalogCrop(asset,image){
    const crop=asset?.activeCatalogCrop||asset?.animation?.frames?.[0]||asset?.crop||normalizeAssetCrop(asset?.source?.bounds)||{sx:0,sy:0,sw:image.naturalWidth,sh:image.naturalHeight};
    const sx=clamp(Math.floor(crop.sx),0,image.naturalWidth-1),sy=clamp(Math.floor(crop.sy),0,image.naturalHeight-1);return {sx,sy,sw:clamp(Math.floor(crop.sw),1,image.naturalWidth-sx),sh:clamp(Math.floor(crop.sh),1,image.naturalHeight-sy)};
  }

  function applyBrowserCatalogCrop(crop,resetDisplay=true){
    if(!crop)return;$("#asset-crop-x").value=crop.sx;$("#asset-crop-y").value=crop.sy;$("#asset-crop-w").value=crop.sw;$("#asset-crop-h").value=crop.sh;
    if(resetDisplay){const scale=Math.min(2,160/Math.max(crop.sw,crop.sh));$("#asset-display-w").value=clamp(Math.round(crop.sw*scale),8,640);$("#asset-display-h").value=clamp(Math.round(crop.sh*scale),8,640);}
    updateAssetCropPreview(true);
  }

  function selectBrowserAsset(asset) {
    assetBrowserSelected=asset;
    syncSelectedAssetFavorite();
    $$('.asset-card').forEach(card=>card.classList.toggle("selected",card.dataset.assetKey===asset.key));
    if(asset.entityType==="npc"){
      assetBrowserSelectedImage=null;$("#asset-selected-name").textContent=`${asset.npc.avatar} ${asset.npc.name}`;$("#asset-selected-meta").textContent=`${asset.npc.role} · South-facing library preview · All directions remain active after placement`;
      const preview=$("#asset-preview"),canvas=document.createElement("canvas");canvas.width=112;canvas.height=112;canvas.setAttribute("aria-label",`${asset.npc.name}, facing south`);preview.replaceChildren(canvas);renderAssetCardPreview(canvas,asset);
      $("#asset-variant-select").replaceChildren(new Option("South-facing preview",asset.key));$("#asset-variant-select").disabled=true;$("#asset-grid-picker").classList.add("hidden");$(".asset-advanced-controls").classList.add("hidden");$("#asset-place-button").disabled=false;$("#asset-trim-alpha").disabled=true;$("#asset-reset-crop").disabled=true;$("#asset-animate").disabled=true;return;
    }
    $(".asset-advanced-controls").classList.remove("hidden");
    asset.activeCatalogCrop=null;asset.activeVariantId=asset.variantId;$$('.asset-card').forEach(card=>card.classList.toggle("selected",card.dataset.assetKey===asset.key));
    $("#asset-selected-name").textContent=`${asset.name} · ${asset.pack}`;
    const details=[assetKindLabel(asset.kind),asset.animation?`${asset.animation.frameCount} frames at ${asset.animation.fps} fps`:"Static",asset.confidence?`${Math.round(asset.confidence*100)}% confidence`:"",asset.ready?"Ready to place":asset.reason||"Reference only",...asset.warnings.slice(0,2)].filter(Boolean);$("#asset-selected-meta").textContent=details.join(" · ");
    const variantSelect=$("#asset-variant-select");variantSelect.replaceChildren();const visibleVariants=asset.group.filter(candidate=>!candidate.directionPreview||candidate.directionPreview==="south");visibleVariants.forEach(candidate=>{const option=document.createElement("option");option.value=candidate.key;option.textContent=candidate.manual?"Manual crop (whole sheet)":candidate.name;option.selected=candidate===asset;variantSelect.append(option);});variantSelect.disabled=visibleVariants.length<2;
    const gridPicker=$("#asset-grid-picker"),grid=asset.grid;gridPicker.classList.toggle("hidden",!grid);if(grid){const column=$("#asset-grid-column"),row=$("#asset-grid-row"),crop=asset.crop||{sx:0,sy:0};column.max=String(grid.columns);row.max=String(grid.rows);column.value=String(clamp(Math.floor(crop.sx/grid.cellWidth)+1,1,grid.columns));row.value=String(clamp(Math.floor(crop.sy/grid.cellHeight)+1,1,grid.rows));}
    const image=new Image();image.alt=asset.name;assetBrowserSelectedImage=image;
    $("#asset-place-button").disabled=true;$("#asset-trim-alpha").disabled=true;$("#asset-reset-crop").disabled=true;$("#asset-animate").disabled=true;$("#asset-preview").innerHTML="<span>Loading crop preview…</span>";
    image.addEventListener("load",()=>{
      if(assetBrowserSelectedImage!==image)return;
      const crop=browserCatalogCrop(asset,image);asset.activeCatalogCrop=crop;applyBrowserCatalogCrop(crop,true);
      $("#asset-place-button").disabled=!asset.ready;$("#asset-trim-alpha").disabled=false;$("#asset-reset-crop").disabled=false;$("#asset-animate").disabled=!asset.animation;$("#asset-animate").checked=Boolean(asset.animation);
    },{once:true});
    image.addEventListener("error",()=>{if(assetBrowserSelectedImage!==image)return;$("#asset-preview").innerHTML="<span>Could not load this asset</span>";$("#asset-place-button").disabled=true;$("#asset-trim-alpha").disabled=true;$("#asset-reset-crop").disabled=true;},{once:true});
    image.src=asset.src;
  }

  function assetCropSpec(clampInputs=false){
    const image=assetBrowserSelectedImage;if(!image?.naturalWidth)return null;const number=id=>Number($(id).value)||0;
    const sx=clamp(Math.floor(number("#asset-crop-x")),0,image.naturalWidth-1),sy=clamp(Math.floor(number("#asset-crop-y")),0,image.naturalHeight-1),sw=clamp(Math.floor(number("#asset-crop-w")),1,image.naturalWidth-sx),sh=clamp(Math.floor(number("#asset-crop-h")),1,image.naturalHeight-sy);
    if(clampInputs){$("#asset-crop-x").value=sx;$("#asset-crop-y").value=sy;$("#asset-crop-w").value=sw;$("#asset-crop-h").value=sh;}
    return {sx,sy,sw,sh};
  }

  function updateAssetCropPreview(clampInputs=false){
    const crop=assetCropSpec(clampInputs),preview=$("#asset-preview");if(!crop)return;
    const canvas=document.createElement("canvas");canvas.width=220;canvas.height=160;canvas.setAttribute("aria-label",`Crop preview ${crop.sw} by ${crop.sh} pixels`);preview.replaceChildren(canvas);
    const animation=$("#asset-animate").checked?assetBrowserSelected?.animation:null;configureEditorAssetCanvas(canvas,assetBrowserSelectedImage,crop,animation,false,true);
  }

  function resetBrowserCatalogCrop(){
    const asset=assetBrowserSelected,image=assetBrowserSelectedImage;if(!asset||!image?.naturalWidth)return;asset.activeCatalogCrop=browserCatalogCrop({...asset,activeCatalogCrop:null},image);asset.activeVariantId=asset.variantId;$("#asset-animate").checked=Boolean(asset.animation);applyBrowserCatalogCrop(asset.activeCatalogCrop,true);
  }

  function useBrowserGridCell(){
    const asset=assetBrowserSelected,image=assetBrowserSelectedImage,grid=asset?.grid;if(!asset||!grid||!image?.naturalWidth)return;
    const maxColumns=Math.max(1,Math.min(grid.columns,Math.floor(image.naturalWidth/grid.cellWidth))),maxRows=Math.max(1,Math.min(grid.rows,Math.floor(image.naturalHeight/grid.cellHeight))),column=clamp(Math.floor(Number($("#asset-grid-column").value)||1),1,maxColumns),row=clamp(Math.floor(Number($("#asset-grid-row").value)||1),1,maxRows),sx=(column-1)*grid.cellWidth,sy=(row-1)*grid.cellHeight;
    $("#asset-grid-column").value=column;$("#asset-grid-row").value=row;asset.activeCatalogCrop={sx,sy,sw:Math.min(grid.cellWidth,image.naturalWidth-sx),sh:Math.min(grid.cellHeight,image.naturalHeight-sy)};asset.activeVariantId=`${asset.sourceId}:grid:${column-1}:${row-1}`;$("#asset-animate").checked=false;applyBrowserCatalogCrop(asset.activeCatalogCrop,true);$("#asset-selected-meta").textContent=`${assetKindLabel(asset.kind)} · Grid cell ${column}, ${row} · ${asset.activeCatalogCrop.sw}×${asset.activeCatalogCrop.sh}px · Ready to place`;
  }

  function syncAssetDisplayRatio(changed){
    if(!$("#asset-lock-ratio").checked)return;const crop=assetCropSpec(true);if(!crop)return;
    if(changed==="width")$("#asset-display-h").value=clamp(Math.round((Number($("#asset-display-w").value)||8)*crop.sh/crop.sw),8,640);
    else $("#asset-display-w").value=clamp(Math.round((Number($("#asset-display-h").value)||8)*crop.sw/crop.sh),8,640);
  }

  function trimBrowserAssetTransparency(){
    const image=assetBrowserSelectedImage;if(!image?.naturalWidth)return;const canvas=document.createElement("canvas");canvas.width=image.naturalWidth;canvas.height=image.naturalHeight;const ctx=canvas.getContext("2d",{willReadFrequently:true});ctx.drawImage(image,0,0);
    const data=ctx.getImageData(0,0,canvas.width,canvas.height).data;let left=canvas.width,top=canvas.height,right=-1,bottom=-1;
    for(let y=0;y<canvas.height;y+=1)for(let x=0;x<canvas.width;x+=1)if(data[(y*canvas.width+x)*4+3]>8){left=Math.min(left,x);right=Math.max(right,x);top=Math.min(top,y);bottom=Math.max(bottom,y);}
    if(right<left){showTownPrompt("This asset has no visible pixels",1800);return;}
    $("#asset-crop-x").value=left;$("#asset-crop-y").value=top;$("#asset-crop-w").value=right-left+1;$("#asset-crop-h").value=bottom-top+1;const scale=Math.min(2,160/Math.max(right-left+1,bottom-top+1));$("#asset-display-w").value=clamp(Math.round((right-left+1)*scale),8,640);$("#asset-display-h").value=clamp(Math.round((bottom-top+1)*scale),8,640);updateAssetCropPreview(true);
  }

  function placeBrowserAsset() {
    if(!assetBrowserSelected?.ready)return;
    if(assetBrowserSelected.entityType==="npc"){
      if(assetBrowserContext==="town")addTownNpcEntity(assetBrowserSelected.npcId);else addRoomEditorNpc(assetBrowserSelected.npcId);
      rememberRecentAsset(assetBrowserSelected.key);renderAssetBrowser();return;
    }
    const crop=assetCropSpec(true);if(!crop)return;const number=id=>Number($(id).value)||0;
    const animation=$("#asset-animate").checked?normalizeAssetAnimation(assetBrowserSelected.animation,crop):null,provenance={assetId:assetBrowserSelected.sourceId,variantId:assetBrowserSelected.activeVariantId||assetBrowserSelected.variantId,kind:assetBrowserSelected.kind};
    const spec={src:assetBrowserSelected.src,...crop,width:clamp(number("#asset-display-w"),8,640),height:clamp(number("#asset-display-h"),8,640),animation,assetId:provenance.assetId,variantId:provenance.variantId,assetKind:provenance.kind};
    if(assetBrowserContext==="town") {
      const viewport=$("#town-map").getBoundingClientRect(),world=$("#town-world").getBoundingClientRect();
      const item={id:`asset-${Date.now()}-${Math.random().toString(16).slice(2)}`,type:"asset",...spec,x:clamp(Math.round((viewport.left+viewport.width/2-world.left-spec.width/2)/8)*8,0,TOWN_SIZE.width-spec.width),y:clamp(Math.round((viewport.top+viewport.height/2-world.top-spec.height/2)/8)*8,0,TOWN_SIZE.height-spec.height)};
      recordTownEditorHistory();townPlacedDecor.push(item);townEditorSelection={kind:"decor",key:item.id};saveTownEditorLayout();drawTownLevel();renderTownEditorHandles();
    } else {
      const before=cloneRoomEditorSnapshot(),snap=Math.max(1,roomEditorSnap);
      const scene=$("#location-scene").getBoundingClientRect(),world=$("#interior-world").getBoundingClientRect();
      const prop=[spec.src,spec.sx,spec.sy,spec.sw,spec.sh,clamp(Math.round((scene.left+scene.width/2-world.left-spec.width/2)/snap)*snap,0,currentLevelWidth-spec.width),clamp(Math.round((scene.top+scene.height/2-world.top-spec.height/2)/snap)*snap,0,currentLevelHeight-spec.height),spec.width,spec.height,1,true,false,false,false,spec.animation,provenance];
      prop.editorKey=`custom-${Date.now()}-${Math.random().toString(16).slice(2)}`;prop.editorCustom=true;currentInteriorProps.push(prop);createLevelProp($("#interior-world"),prop);roomEditorSelection={key:prop.editorKey,custom:true};commitRoomEditorHistory(before);persistCurrentInteriorLayout();renderRoomEditorHandles();
    }
    rememberRecentAsset(assetBrowserSelected.key);renderAssetBrowser();
  }

  function getLevelImage(src) {
    src = window.resolveAssetPath ? window.resolveAssetPath(src) : src;
    if (levelImageCache.has(src)) return levelImageCache.get(src);
    const image = new Image();
    image.src = src;
    levelImageCache.set(src, image);
    return image;
  }

  function drawLevel(locationId, canvas) {
    const ctx = canvas.getContext("2d");
    const theme = LEVEL_THEMES[locationId];
    ctx.imageSmoothingEnabled = false;
    ctx.fillStyle = theme.tint;
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    const paint = () => {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      ctx.fillStyle = theme.tint;
      ctx.fillRect(0, 0, canvas.width, canvas.height);
      if (theme.floor) {
        const [src,sx,sy,sw,sh] = theme.floor;
        const image = getLevelImage(src);
        if (image.complete && image.naturalWidth) {
          const scale=sw<=16?4:sw<=32?2:1,tileW=Math.max(16,Math.round(sw*scale)),tileH=Math.max(16,Math.round(sh*scale));
          for (let y = 0; y < canvas.height; y += tileH) for (let x = 0; x < canvas.width; x += tileW) {
            ctx.drawImage(image,sx,sy,sw,sh,x,y,tileW,tileH);
          }
        }
      } else if (theme.outdoor) {
        drawOutdoorGround(ctx, locationId, canvas.width);
      } else drawInteriorGround(ctx, locationId, canvas.width);
      drawLevelArchitecture(ctx, locationId, canvas.width);
    };

    const sources = [...new Set([...(theme.floor ? [theme.floor[0]] : []), ...theme.props.map(prop => prop[0])])];
    sources.forEach(src => {
      const image = getLevelImage(src);
      if (!image.complete) image.addEventListener("load", paint, { once:true });
    });
    paint();
  }

  function drawOutdoorGround(ctx, locationId, width) {
    const height=currentLevelHeight;
    if(locationId==="market"){
      ctx.fillStyle="#b99a70";ctx.fillRect(0,0,width,height);
      for(let y=0;y<height;y+=48)for(let x=(Math.floor(y/48)%2)*24-24;x<width;x+=48){ctx.fillStyle=(x/48+y/48)%3===0?"#a98761":"#c1a47b";ctx.fillRect(x+2,y+2,44,44);}
      ctx.fillStyle="rgba(92,62,43,.24)";ctx.fillRect(0,334,width,104);ctx.fillRect(500,0,100,height);
      ctx.fillStyle="rgba(255,229,151,.18)";for(let x=24;x<width;x+=96)ctx.fillRect(x,348,54,7);
      return;
    }
    if(locationId==="skyhouse"){
      const sky=ctx.createLinearGradient(0,0,0,height);sky.addColorStop(0,"#7fc7df");sky.addColorStop(1,"#d9eef0");ctx.fillStyle=sky;ctx.fillRect(0,0,width,height);
      ctx.fillStyle="rgba(255,255,255,.72)";for(let x=-50;x<width;x+=210){const y=70+(Math.abs(x*7)%230);ctx.fillRect(x,y,145,28);ctx.fillRect(x+28,y-18,86,64);}
      ctx.fillStyle="#8bb89a";ctx.fillRect(28,42,width-56,height-84);ctx.fillStyle="#b6d0a6";ctx.fillRect(42,56,width-84,height-112);
      ctx.fillStyle="#d6c89a";ctx.fillRect(0,350,width,112);ctx.fillRect(500,40,100,height-80);
      ctx.strokeStyle="#53777c";ctx.lineWidth=8;for(let x=50;x<width-40;x+=64){ctx.beginPath();ctx.moveTo(x,46);ctx.lineTo(x,82);ctx.stroke();}
      return;
    }
    ctx.fillStyle = locationId === "farm" ? "#79aa5c" : "#6f9a57";
    ctx.fillRect(0,0,width,height);
    ctx.fillStyle = "rgba(45,91,49,.22)";
    for (let y=18;y<height;y+=38) for (let x=(y%76);x<width;x+=74) ctx.fillRect(x,y,3,7);
    ctx.fillStyle = "#cba36f";
    ctx.fillRect(0,535,width,115);
    ctx.fillRect(460,0,90,height);
    ctx.fillRect(950,0,90,height);
    ctx.strokeStyle = "#8a6645";
    ctx.lineWidth = 5;
    for (let x=0;x<width;x+=52) { ctx.beginPath(); ctx.moveTo(x,525); ctx.lineTo(x,655); ctx.stroke(); }
  }

  function drawInteriorGround(ctx,locationId,width){
    const height=currentLevelHeight;
    const palettes={club:["#271d35","#34213f"],mansion:["#493c3e","#554447"],arcade:["#182b43","#203954"],conservatory:["#6e9768","#83a877"],guildhall:["#33484d","#3e5558"],elementalbaths:["#41465b","#57404a"],clockstation:["#55483d","#665344"]};
    const [base,alternate]=palettes[locationId]||[LEVEL_THEMES[locationId].tint,"rgba(255,255,255,.07)"];ctx.fillStyle=base;ctx.fillRect(0,0,width,height);
    if(locationId==="mansion"){
      for(let y=0;y<height;y+=32)for(let x=(Math.floor(y/32)%2)*48-48;x<width;x+=96){ctx.fillStyle=(Math.floor(x/96)+Math.floor(y/32))%2?"#5c4845":"#493a3a";ctx.fillRect(x+1,y+1,94,30);ctx.fillStyle="rgba(25,18,22,.22)";ctx.fillRect(x+47,y+3,2,26);}
    } else {
      for(let y=0;y<height;y+=48)for(let x=0;x<width;x+=48){ctx.fillStyle=(Math.floor(x/48)+Math.floor(y/48))%2?alternate:base;ctx.fillRect(x,y,48,48);ctx.strokeStyle="rgba(255,255,255,.055)";ctx.strokeRect(x+.5,y+.5,47,47);}
    }
    if(locationId==="club"){
      const colors=["#e35972","#6d58b7","#3aa5b6","#f2b84b"];for(let y=352;y<626;y+=48)for(let x=350;x<750;x+=48){ctx.fillStyle=colors[(x/48+y/48)%colors.length|0];ctx.globalAlpha=.68;ctx.fillRect(x+2,y+2,44,44);}ctx.globalAlpha=1;
    } else if(locationId==="arcade"){
      ctx.strokeStyle="rgba(45,224,231,.28)";ctx.lineWidth=2;for(let x=24;x<width;x+=48){ctx.beginPath();ctx.moveTo(x,0);ctx.lineTo(x,height);ctx.stroke();}for(let y=24;y<height;y+=48){ctx.beginPath();ctx.moveTo(0,y);ctx.lineTo(width,y);ctx.stroke();}
      ctx.fillStyle="rgba(239,74,160,.28)";ctx.fillRect(352,344,396,12);ctx.fillRect(352,628,396,12);
    } else if(locationId==="conservatory"){
      ctx.fillStyle="rgba(204,235,173,.16)";for(let x=0;x<width;x+=96)ctx.fillRect(x+4,0,42,height);ctx.fillStyle="#7b6650";ctx.fillRect(0,344,width,88);ctx.fillRect(512,0,76,height);
    } else if(locationId==="guildhall"){
      ctx.fillStyle="rgba(224,209,151,.15)";ctx.beginPath();ctx.arc(width/2,height/2,190,0,Math.PI*2);ctx.fill();ctx.strokeStyle="rgba(229,191,86,.38)";ctx.lineWidth=7;ctx.stroke();
    } else if(locationId==="elementalbaths"){
      const water=ctx.createLinearGradient(330,0,770,0);water.addColorStop(0,"#83d2db");water.addColorStop(.5,"#7e8ec7");water.addColorStop(1,"#e77954");ctx.fillStyle=water;ctx.fillRect(350,286,400,330);ctx.strokeStyle="#d7c599";ctx.lineWidth=18;ctx.strokeRect(350,286,400,330);
    } else if(locationId==="clockstation"){
      ctx.fillStyle="#2f3438";ctx.fillRect(0,620,width,72);ctx.fillStyle="#8d6a45";for(let x=0;x<width;x+=48)ctx.fillRect(x+3,632,40,44);ctx.fillStyle="#1d242a";ctx.fillRect(0,704,width,18);ctx.fillRect(0,770,width,18);for(let x=18;x<width;x+=54)ctx.fillRect(x,690,12,110);
    }
  }

  function drawLevelArchitecture(ctx, locationId, width) {
    const height=currentLevelHeight;
    if (LEVEL_THEMES[locationId].outdoor) {
      ctx.strokeStyle = locationId==="skyhouse"?"#53777c":locationId==="market"?"#70533c":"#744f31";
      ctx.lineWidth = 12;
      ctx.strokeRect(8,8,width-16,height-16);
      return;
    }
    if (locationId === "cafe") {
      ctx.fillStyle = "#3b2b25";
      ctx.fillRect(0,0,width,72); ctx.fillRect(0,height-50,width,50); ctx.fillRect(0,0,38,height); ctx.fillRect(width-38,0,38,height);
      ctx.fillStyle = "#8a5b39";
      for (let x=40;x<width-40;x+=64) ctx.fillRect(x,18,54,28);
      return;
    }
    ctx.fillStyle = locationId === "mansion" ? "#302a31" : "#263545";
    ctx.fillRect(0,0,width,54);
    ctx.fillRect(0,height-50,width,50);
    ctx.fillRect(0,0,35,height);
    ctx.fillRect(width-35,0,35,height);
    ctx.fillStyle = "rgba(255,255,255,.12)";
    for (let x=55;x<width-50;x+=74) ctx.fillRect(x,21,42,8);
    ctx.fillStyle="rgba(23,34,56,.38)";
    [Math.round(width/3),Math.round(width*2/3)].forEach(x=>{ctx.fillRect(x-8,54,16,94);ctx.fillRect(x-8,height-140,16,90);});
  }

  function updateInteriorPosition() {
    const scene = $("#location-scene");
    const world = $("#interior-world");
    const ben = $("#scene-ben");
    if (!scene || !world || !ben) return;
    const cameraX = clamp(scene.clientWidth / 2 - interiorPosition.x, Math.min(0,scene.clientWidth-currentLevelWidth), 0);
    const cameraY = clamp(scene.clientHeight / 2 - interiorPosition.y, Math.min(0,scene.clientHeight-currentLevelHeight), 0);
    world.style.transform = `translate3d(${Math.round(cameraX)}px,${Math.round(cameraY)}px,0)`;
    ben.style.left = `${interiorPosition.x}px`;
    ben.style.top = `${interiorPosition.y}px`;
    ben.style.zIndex = `${100 + Math.round(interiorPosition.y)}`;
  }

  function updateInteriorViewport() {
    if(!state||!isVisible("location-sheet"))return;
    const scene=$("#location-scene"),world=$("#interior-world"),canvas=world?.querySelector(".level-canvas");if(!scene||!world||!canvas)return;
    const width=Math.max(currentLevelWidth,1100,scene.clientWidth),height=Math.max(currentLevelHeight,LEVEL_HEIGHT,scene.clientHeight);
    if(width!==currentLevelWidth||height!==currentLevelHeight){currentLevelWidth=width;currentLevelHeight=height;world.style.width=`${width}px`;world.style.height=`${height}px`;canvas.width=width;canvas.height=height;drawLevel(state.currentLocation,canvas);}
    updateInteriorPosition();
  }

  function nearestInteriorWalkablePoint(point) {
    const safe={x:clamp(point.x,60,currentLevelWidth-60),y:clamp(point.y,90,currentLevelHeight-80)};
    if(canInteriorMove(safe.x,safe.y,interiorPosition))return safe;
    const step=28;
    for(let ring=1;ring<=10;ring+=1){
      for(let oy=-ring;oy<=ring;oy+=1)for(let ox=-ring;ox<=ring;ox+=1){
        if(Math.abs(ox)!==ring&&Math.abs(oy)!==ring)continue;
        const candidate={x:clamp(Math.round(safe.x/step)*step+ox*step,60,currentLevelWidth-60),y:clamp(Math.round(safe.y/step)*step+oy*step,90,currentLevelHeight-80)};
        if(canInteriorMove(candidate.x,candidate.y,interiorPosition))return candidate;
      }
    }
    return{...interiorPosition};
  }

  function interiorRoute(from,to) {
    const step=28,key=(x,y)=>`${x},${y}`,snap=point=>({x:clamp(Math.round(point.x/step)*step,56,currentLevelWidth-56),y:clamp(Math.round(point.y/step)*step,84,currentLevelHeight-76)}),start=snap(from),goal=nearestInteriorWalkablePoint(to),goalNode=snap(goal),queue=[start],parents=new Map([[key(start.x,start.y),null]]),nodes=new Map([[key(start.x,start.y),start]]);
    let cursor=0,found=null;
    while(cursor<queue.length&&cursor<6000){
      const node=queue[cursor++],nodeKey=key(node.x,node.y);
      if(Math.abs(node.x-goalNode.x)<=step&&Math.abs(node.y-goalNode.y)<=step){found=nodeKey;break;}
      [[step,0],[-step,0],[0,step],[0,-step]].forEach(([ox,oy])=>{const next={x:node.x+ox,y:node.y+oy},nextKey=key(next.x,next.y);if(parents.has(nextKey)||!canInteriorMove(next.x,next.y,node))return;parents.set(nextKey,nodeKey);nodes.set(nextKey,next);queue.push(next);});
    }
    if(!found)return[goal];
    const reverse=[];while(found){reverse.push(nodes.get(found));found=parents.get(found);}
    const route=reverse.reverse().slice(1).filter((node,index,array)=>index===array.length-1||index===0||(node.x-array[index-1].x)!==(array[index+1].x-node.x)||(node.y-array[index-1].y)!==(array[index+1].y-node.y));route.push(goal);return route;
  }

  function setInteriorMoveDestination(point) {
    if(roomEditMode||!isVisible("location-sheet"))return;
    const goal=nearestInteriorWalkablePoint(point);interiorMoveRoute=interiorRoute(interiorPosition,goal);interiorRouteBlockedFor=0;showMoveTarget("interior-move-target",$("#interior-world"),goal.x,goal.y);$("#location-scene")?.focus({preventScroll:true});
  }

  function handleInteriorClickMove(event) {
    if(event.button!==0||!event.isPrimary||roomEditMode||!isVisible("location-sheet"))return;
    if(event.target.closest("button,input,select,textarea,a,[contenteditable='true']"))return;
    const rect=$("#interior-world").getBoundingClientRect();setInteriorMoveDestination({x:event.clientX-rect.left,y:event.clientY-rect.top});
  }

  function updateInteriorMovement(dt) {
    const manual=manualMoveVector();let vector=manual,followingRoute=false;
    if(manual.magnitude){if(interiorMoveRoute.length)clearAutoMovement("interior");}
    else {vector=routeMoveVector(interiorPosition,interiorMoveRoute);followingRoute=Boolean(vector.magnitude);if(!interiorMoveRoute.length)hideMoveTarget("interior-move-target");}
    const dx=vector.x,dy=vector.y;
    if (!dx && !dy) {
      $("#scene-ben").src = `${ASSETS.benDirections}${interiorFacing}.png`;
      return;
    }
    const length = Math.hypot(dx,dy);
    const speed = .18 * dt * Math.max(.25,vector.magnitude||1);
    const nextX = interiorPosition.x + dx / length * speed;
    const nextY = interiorPosition.y + dy / length * speed;
    const beforeX=interiorPosition.x,beforeY=interiorPosition.y;
    if (canInteriorMove(nextX, interiorPosition.y)) interiorPosition.x = nextX;
    if (canInteriorMove(interiorPosition.x, nextY)) interiorPosition.y = nextY;
    const moved=Math.hypot(interiorPosition.x-beforeX,interiorPosition.y-beforeY)>.05;
    if(followingRoute){interiorRouteBlockedFor=moved?0:interiorRouteBlockedFor+dt;if(interiorRouteBlockedFor>700){const goal=interiorMoveRoute.at(-1);interiorMoveRoute=goal?interiorRoute(interiorPosition,goal):[];interiorRouteBlockedFor=0;}if(!routeMoveVector(interiorPosition,interiorMoveRoute).magnitude)hideMoveTarget("interior-move-target");}
    interiorFacing = Math.abs(dx) > Math.abs(dy) ? (dx > 0 ? "east" : "west") : (dy > 0 ? "south" : "north");
    interiorWalkFrame += dt;
    const frame = Math.floor(interiorWalkFrame / 90) % 6;
    $("#scene-ben").src = `${ASSETS.benRunning}${interiorFacing}/frame_${String(frame).padStart(3,"0")}.png`;
    updateInteriorPosition();
    const zoneIndex = EXPLORATION_SCENES[state.currentLocation].map((_,index) => {
        const p = levelNpcPoint(state.currentLocation,index);
        return Math.hypot(interiorPosition.x-p.x,interiorPosition.y-p.npcY);
      }).reduce((best,distance,index,list) => distance < list[best] ? index : best,0);
    if (zoneIndex !== currentSceneIndex) {
      currentSceneIndex = zoneIndex;
      renderExplorationScene(state.currentLocation);
    }
  }

  function canInteriorMove(x,y,fromPosition=interiorPosition) {
    if (x < 55 || x > currentLevelWidth-55 || y < 85 || y > currentLevelHeight-75) return false;
    if(interiorStaticBlocked(state.currentLocation,x,y))return false;
    if([...interiorCustomNpcSims.values()].some(sim=>sim.entity.visible&&sim.entity.collision&&Math.hypot(x-sim.x,y-sim.y)<31&&Math.hypot(x-sim.x,y-sim.y)<=Math.hypot(fromPosition.x-sim.x,fromPosition.y-sim.y)))return false;
    return !currentInteriorProps.some(prop => {
      if(!interiorPropCollides(prop)||prop[13])return false;
      const [, , , , ,dx,dy,dw,dh] = prop;
      const padX = Math.max(8,dw*.12);
      const left = dx + padX, right = dx + dw - padX;
      const top = dy + dh * .68, bottom = dy + dh + 5;
      const playerLeft=x-18, playerRight=x+18, playerTop=y-7, playerBottom=y+7;
      return playerRight > left && playerLeft < right && playerBottom > top && playerTop < bottom;
    });
  }

  function interiorStaticBlocked(locationId,x,y){
    if(locationId!=="elementalbaths")return false;
    const bridge=currentInteriorProps.find(prop=>String(prop[0]).includes("17. Bridges and walkways.png")&&!prop[13]),insidePool=x>359&&x<741&&y>295&&y<607,bridgeCorridor=bridge&&x>=bridge[5]-6&&x<=bridge[5]+bridge[7]+6&&y>=bridge[6]-6&&y<=bridge[6]+bridge[8]+6;
    return insidePool&&!bridgeCorridor;
  }

  function renderExplorationScene(locationId) {
    const scenes = EXPLORATION_SCENES[locationId];
    const area = scenes[currentSceneIndex] || scenes[0];
    const scene = $("#location-scene");
    const ben = $("#scene-ben");
    currentNpcId = area.npcId;
    $("#scene-area-count").textContent = `Exploring · Area ${currentSceneIndex + 1} of ${scenes.length}`;
    $("#scene-area-name").textContent = area.name;
    $("#scene-description").textContent = area.description;
    $("#scene-toast").textContent = "";
    ben.classList.remove("walking-left", "walking-right");
    updateInteriorPosition();
    $("#scene-prev").disabled = sceneMoving;
    $("#scene-next").disabled = sceneMoving;

    const npc = NPCS[currentNpcId];
    $("#npc-name").textContent = npc.name;
    $("#npc-role").textContent = npc.role;
    $("#npc-line").textContent = `“${npc.line}”`;
    configureNpcSprite(npc.sprite);
    $$("#npc-roster .roster-button").forEach(button => button.classList.toggle("active", button.dataset.npc === currentNpcId));

    const path = $("#scene-path");
    path.replaceChildren();
    scenes.forEach((item, index) => {
      const dot = document.createElement("span");
      dot.className = "scene-dot";
      dot.classList.toggle("active", index === currentSceneIndex);
      dot.classList.toggle("discovered", state.discoveries.includes(`${locationId}:${item.id}`));
      dot.title = item.name;
      path.append(dot);
    });

    const inspect = $("#scene-inspect");
    const discovered = state.discoveries.includes(`${locationId}:${area.id}`);
    inspect.disabled = discovered;
    inspect.textContent = discovered ? `✓ ${virtueById(area.virtue).name} noted` : "◎ Observe";
    inspect.setAttribute("aria-label", discovered ? `${area.name} already observed` : `Observe ${area.name}`);
    renderActions(locationId);
  }

  function moveInsideLocation(direction) {
    if (sceneMoving || !isVisible("location-sheet")) return;
    const locationId = state.currentLocation;
    const scenes = EXPLORATION_SCENES[locationId];
    const nextIndex = (currentSceneIndex + direction + scenes.length) % scenes.length;
    currentSceneIndex = nextIndex;
    interiorPosition.x = levelNpcPoint(locationId,nextIndex).x;
    interiorPosition.y = 790;
    renderExplorationScene(locationId);
    playSfx(ASSETS.transition, .18);
  }

  function inspectCurrentScene() {
    if (sceneMoving || !isVisible("location-sheet")) return;
    const locationId = state.currentLocation;
    const area = EXPLORATION_SCENES[locationId][currentSceneIndex];
    const key = `${locationId}:${area.id}`;
    if (state.discoveries.includes(key)) return;
    state.discoveries.push(key);
    const practice = practiceVirtue(area.virtue);
    const keepsakeFound = state.discoveries.length % 3 === 0;
    if (keepsakeFound) {
      state.inventory.keepsakes += 1;
      addNote(`Exploration: Ben filled a notebook page at ${area.name} and kept one useful curiosity.`);
    }
    saveState();
    renderAll();
    renderExplorationScene(locationId);
    const bonus = practice.focused ? " Daily focus bonus!" : "";
    const keepsake = keepsakeFound ? " Odd keepsake found." : "";
    showSceneToast(`${area.discovery} +${practice.gain} ${practice.name}.${bonus}${keepsake}`);
    playSfx(ASSETS.success, .24);
  }

  function showSceneToast(message) {
    window.clearTimeout(sceneToastTimeout);
    const toast = $("#scene-toast");
    toast.textContent = message;
    sceneToastTimeout = window.setTimeout(() => { toast.textContent = ""; }, 7600);
  }

  function renderNpcRoster(locationId) {
    const roster = $("#npc-roster");
    roster.replaceChildren();
    ROSTERS[locationId].forEach(npcId => {
      const npc = NPCS[npcId];
      const button = document.createElement("button");
      button.type = "button";
      button.className = `roster-button${npcId === currentNpcId ? " active" : ""}`;
      button.dataset.npc = npcId;
      button.setAttribute("aria-label", `Spend time with ${npc.name}`);
      const avatar = document.createElement("span");
      avatar.className = "roster-avatar";
      avatar.textContent = npc.avatar;
      const name = document.createElement("span");
      name.className = "roster-name";
      name.textContent = npc.name;
      button.append(avatar, name);
      button.addEventListener("click", () => selectNpc(locationId, npcId));
      roster.append(button);
    });
  }

  function selectNpc(locationId, npcId) {
    if (!ROSTERS[locationId].includes(npcId)) return;
    const targetIndex = EXPLORATION_SCENES[locationId].findIndex(scene => scene.npcId === npcId);
    if (targetIndex < 0 || targetIndex === currentSceneIndex) return;
    currentSceneIndex = targetIndex;
    encounterNpc(npcId);saveState();renderActiveNotebookTab();
    interiorPosition.x = levelNpcPoint(locationId,targetIndex).x;
    interiorPosition.y = 790;
    renderExplorationScene(locationId);
    playSfx(ASSETS.click, .22);
  }

  function configureNpcSprite(sprite) {
    const element = $("#npc-sprite");
    if(!sprite){element.style.backgroundImage="none";return;}
    if(!sprite.sheet&&(sprite.directions||typeof sprite.walkFrames==="string")){
      const source=sprite.directions?`${sprite.directions}south.png`:`${sprite.walkFrames}/Front/Standing/Front_Standing_Walk_1.png`,image=getLevelImage(source);
      const apply=()=>{if(!image.naturalWidth||!image.naturalHeight)return;const targetHeight=sprite.displayHeight||68,scale=targetHeight/image.naturalHeight;element.style.width=`${Math.ceil(image.naturalWidth*scale)}px`;element.style.height=`${targetHeight}px`;element.style.backgroundImage=`url("${source}")`;element.style.backgroundSize=`${Math.ceil(image.naturalWidth*scale)}px ${targetHeight}px`;element.style.backgroundPosition="0 0";};
      if(image.complete)apply();else image.addEventListener("load",apply,{once:true});return;
    }
    if(!sprite.sheet){element.style.backgroundImage="none";return;}
    const scale = sprite.scale || 1;
    const sheetWidth=sprite.sheetWidth||inferSheetWidth(sprite.sheet),plan=spriteFramePlan(sprite,"south",false,0,{naturalWidth:sheetWidth,naturalHeight:sprite.layout==="rpg"?sprite.h*4:sprite.h}),rect=plan.current,[boundX=0,boundY=0,boundW=rect.w,boundH=rect.h]=sprite.contentBounds||[],displayScale=sprite.displayHeight? sprite.displayHeight/boundH:scale;
    element.style.width = `${boundW * displayScale}px`;
    element.style.height = `${boundH * displayScale}px`;
    element.style.backgroundImage = `url("${sprite.sheet}")`;
    element.style.backgroundSize = `${sheetWidth * displayScale}px auto`;
    element.style.backgroundPosition = `${-(rect.x+boundX) * displayScale}px ${-(rect.y+boundY) * displayScale}px`;
  }

  function inferSheetWidth(sheet) {
    if(!sheet)return 1;
    if (sheet.includes("dotd_skeletonsheet_3") || sheet.includes("vampire_3")) return 936;
    if (sheet.includes("dotd_skeletonsheet_2") || sheet.includes("vampire_2")) return 624;
    if (sheet.includes("dotd_") || sheet.includes("vampire")) return 312;
    if (sheet.includes("RMMV")) return 234;
    if (sheet.includes("pig_")) return 32;
    if (sheet.includes("ghost3")) return 234;
    if (sheet.includes("ghost2")) return 156;
    return 78;
  }

  function getLocationActions(id) {
    const errand = state.activeErrand;
    const special = [];
    if (errand?.status === "pickup" && errand.from === id) {
      special.push({ id: "pickup", title: `Pick up the ${errand.item}`, desc: `Promise ${currentNpcId ? NPCS[currentNpcId].name : activeNpc(id).name} it will reach ${activeNpc(errand.to).name}.`, cost: "−1 energy · errand", energy: 1 });
    } else if (errand?.status === "carrying" && errand.to === id) {
      special.push({ id: "deliver", title: `Deliver the ${errand.item}`, desc: `Complete today's errand and collect your fee.`, cost: `−1 energy · +$${errand.reward}`, energy: 1 });
    }
    const challenge = {
      id: "challenge",
      title: CHALLENGES[id].action,
      desc: CHALLENGES[id].description,
      cost: "−1 energy · skill reward",
      energy: 1,
      virtue: CHALLENGES[id].virtue,
      mini: true
    };
    return special.length
      ? [...special, ...ACTIONS[id].slice(0, 2), challenge]
      : [...ACTIONS[id], challenge];
  }

  function renderActions(id) {
    const list = $("#action-list");
    list.replaceChildren();
    getLocationActions(id).forEach((action, index) => {
      const virtue = virtueById(action.virtue || virtueForAction(action.id, id));
      const focused = virtue.id === dailyVirtue().id;
      const button = document.createElement("button");
      const enoughEnergy = state.stats.energy >= action.energy;
      const meetsRequirement = actionMeetsRequirement(action);
      button.type = "button";
      button.className = "action-button";
      button.dataset.action = action.id;
      button.disabled = roomEditMode || !enoughEnergy || !meetsRequirement;
      if (roomEditMode) button.title = "Finish room editing before starting an activity.";
      else if (!enoughEnergy) button.title = "Ben needs more energy.";
      else if (!meetsRequirement) button.title = "You do not have what this action needs.";
      const number = document.createElement("span");
      number.className = "action-number";
      number.textContent = index + 1;
      const copy = document.createElement("span");
      copy.className = "action-copy";
      const title = document.createElement("b");
      title.textContent = action.title;
      const desc = document.createElement("span");
      desc.textContent = action.desc;
      copy.append(title, desc);
      const cost = document.createElement("span");
      cost.className = "action-cost";
      cost.textContent = action.cost;
      const virtueCue = document.createElement("span");
      virtueCue.className = `virtue-cue${focused ? " focus" : ""}`;
      virtueCue.textContent = `${virtue.icon} ${virtue.name}${focused ? " ×2" : ""}`;
      const meta = document.createElement("span");
      meta.className = "action-meta";
      meta.append(cost, virtueCue);
      button.append(number, copy, meta);
      button.addEventListener("click", () => action.mini ? startMinigame(id) : performAction(id, action));
      list.append(button);
    });
  }

  function actionMeetsRequirement(action) {
    if(action.requires&&!action.requires(state))return false;
    if(action.requiresCash&&state.stats.cash<action.requiresCash)return false;
    if(action.requiresParts&&state.inventory.parts<action.requiresParts)return false;
    return true;
  }

  function startMinigame(locationId) {
    if(roomEditMode){showSceneToast("Finish room editing before starting a challenge.");return;}
    if (state.slot >= 3 || state.stats.energy < 1) return;
    clearMinigameTimers();
    const config = CHALLENGES[locationId];
    miniGame = {
      locationId,
      config,
      before: snapshotStats(),
      npcId: currentNpcId,
      score: 0,
      active: true,
      finished: false
    };
    const arena = $("#minigame-arena");
    const areaArt = EXPLORATION_SCENES[locationId][currentSceneIndex]?.art || LOCATIONS[locationId].art;
    arena.style.setProperty("--mini-art", `url("${areaArt}")`);
    $("#minigame-eyebrow").textContent = `${LOCATIONS[locationId].short} · Franklin skill challenge`;
    $("#minigame-title").textContent = config.title;
    $("#minigame-instructions").textContent = config.instructions;
    $("#minigame-score").textContent = "0";
    hide("location-sheet");
    show("minigame-overlay");

    if (config.type === "timing") setupTimingRound();
    if (config.type === "sequence") setupSequenceChallenge();
    if (config.type === "hunt") setupHuntChallenge();
    window.setTimeout(() => $("#minigame-primary").focus({ preventScroll: true }), 40);
  }

  function clearMinigameTimers() {
    if (miniAnimationFrame) cancelAnimationFrame(miniAnimationFrame);
    if (miniInterval) window.clearInterval(miniInterval);
    miniTimeouts.forEach(timeout => window.clearTimeout(timeout));
    miniAnimationFrame = 0;
    miniInterval = 0;
    miniTimeouts = [];
  }

  function resetMinigameControls() {
    $("#minigame-arena").replaceChildren();
    $("#minigame-inputs").replaceChildren();
    const primary = $("#minigame-primary");
    primary.hidden = false;
    primary.disabled = false;
  }

  function setupTimingRound() {
    if (!miniGame) return;
    resetMinigameControls();
    const { config } = miniGame;
    miniGame.round = miniGame.round || 1;
    miniGame.active = true;
    miniGame.position = 0;
    miniGame.targetCenter = 27 + Math.random() * 46;
    miniGame.startedAt = performance.now();
    $("#minigame-progress-label").textContent = "Round";
    $("#minigame-progress").textContent = `${miniGame.round}/${config.rounds}`;
    $("#minigame-primary").textContent = config === CHALLENGES.cafe ? "Print!" : "Tune!";
    $("#minigame-control-hint").innerHTML = "<kbd>Space</kbd> / <kbd>A</kbd> / tap to stop";

    const wrap = document.createElement("div");
    wrap.className = "timing-wrap";
    const track = document.createElement("div");
    track.className = "timing-track";
    const zone = document.createElement("span");
    zone.className = "timing-zone";
    zone.style.left = `${miniGame.targetCenter}%`;
    const needle = document.createElement("span");
    needle.className = "timing-needle";
    const caption = document.createElement("div");
    caption.className = "timing-caption";
    caption.innerHTML = "<span>Too early</span><span>Perfect registration</span><span>Too late</span>";
    track.append(zone, needle);
    wrap.append(track, caption);
    $("#minigame-arena").append(wrap);

    const sweep = timestamp => {
      if (!miniGame?.active || miniGame.config.type !== "timing") return;
      const phase = ((timestamp - miniGame.startedAt) / 820) % 2;
      miniGame.position = phase <= 1 ? phase * 100 : (2 - phase) * 100;
      needle.style.left = `${miniGame.position}%`;
      miniAnimationFrame = requestAnimationFrame(sweep);
    };
    miniAnimationFrame = requestAnimationFrame(sweep);
  }

  function stopTimingMarker() {
    if (!miniGame?.active || miniGame.config.type !== "timing") return;
    miniGame.active = false;
    cancelAnimationFrame(miniAnimationFrame);
    miniAnimationFrame = 0;
    $("#minigame-primary").disabled = true;
    const distance = Math.abs(miniGame.position - miniGame.targetCenter);
    const points = distance <= 3.2 ? 2 : distance <= 10.5 ? 1 : 0;
    miniGame.score += points;
    $("#minigame-score").textContent = String(miniGame.score);
    const wrap = $(".timing-wrap");
    wrap?.classList.add(points ? "hit" : "miss");
    if (wrap) wrap.querySelector(".timing-caption").textContent = points === 2 ? "Perfect impression!" : points === 1 ? "Readable—ship it." : "The type slipped.";
    playSfx(points ? ASSETS.success : ASSETS.click, .3);
    const timeout = window.setTimeout(() => {
      if (!miniGame) return;
      if (miniGame.round >= miniGame.config.rounds) finishMinigame();
      else {
        miniGame.round += 1;
        setupTimingRound();
      }
    }, 620);
    miniTimeouts.push(timeout);
  }

  function setupSequenceChallenge() {
    if (!miniGame) return;
    resetMinigameControls();
    const directions = ["ArrowUp", "ArrowRight", "ArrowDown", "ArrowLeft"];
    const symbols = { ArrowUp: "↑", ArrowRight: "→", ArrowDown: "↓", ArrowLeft: "←" };
    miniGame.sequence = Array.from({ length: miniGame.config.length }, () => pick(directions));
    miniGame.sequenceIndex = 0;
    miniGame.phase = "memorize";
    $("#minigame-progress-label").textContent = "Circuit";
    $("#minigame-progress").textContent = `0/${miniGame.config.length}`;
    $("#minigame-primary").hidden = true;
    $("#minigame-control-hint").innerHTML = "Use <kbd>arrows</kbd>, <kbd>D-pad</kbd>, or tap";

    const wrap = document.createElement("div");
    wrap.className = "sequence-wrap";
    const prompt = document.createElement("div");
    prompt.className = "sequence-prompt";
    prompt.textContent = "Memorize Ben’s route…";
    const display = document.createElement("div");
    display.className = "sequence-display";
    miniGame.sequence.forEach(direction => {
      const symbol = document.createElement("span");
      symbol.className = "sequence-symbol";
      symbol.textContent = symbols[direction];
      display.append(symbol);
    });
    wrap.append(prompt, display);
    $("#minigame-arena").append(wrap);

    directions.forEach((direction, index) => {
      const button = document.createElement("button");
      button.type = "button";
      button.className = "sequence-input";
      button.textContent = symbols[direction];
      button.setAttribute("aria-label", direction.replace("Arrow", ""));
      button.title = `Key ${index + 1}`;
      button.addEventListener("click", () => handleSequenceInput(direction));
      $("#minigame-inputs").append(button);
    });

    const timeout = window.setTimeout(() => {
      if (!miniGame || miniGame.config.type !== "sequence") return;
      miniGame.phase = "input";
      display.classList.add("hidden-sequence");
      prompt.textContent = "Now repeat the route";
      $("#minigame-inputs .sequence-input")?.focus({ preventScroll: true });
    }, 2200);
    miniTimeouts.push(timeout);
  }

  function handleSequenceInput(direction) {
    if (!miniGame || miniGame.config.type !== "sequence" || miniGame.phase !== "input") return;
    const symbols = $$(".sequence-symbol");
    const expected = miniGame.sequence[miniGame.sequenceIndex];
    const symbol = symbols[miniGame.sequenceIndex];
    if (direction !== expected) {
      symbol?.classList.add("wrong");
      if (symbol) symbol.textContent = "×";
      miniGame.phase = "settled";
      playSfx(ASSETS.click, .3);
      const timeout = window.setTimeout(finishMinigame, 650);
      miniTimeouts.push(timeout);
      return;
    }
    symbol?.classList.add("correct");
    miniGame.sequenceIndex += 1;
    miniGame.score += 1;
    $("#minigame-score").textContent = String(miniGame.score);
    $("#minigame-progress").textContent = `${miniGame.sequenceIndex}/${miniGame.config.length}`;
    playSfx(ASSETS.click, .22);
    if (miniGame.sequenceIndex >= miniGame.config.length) {
      miniGame.phase = "settled";
      const prompt = $(".sequence-prompt");
      if (prompt) prompt.textContent = "The route is sound!";
      playSfx(ASSETS.success, .34);
      const timeout = window.setTimeout(finishMinigame, 650);
      miniTimeouts.push(timeout);
    }
  }

  function setupHuntChallenge() {
    if (!miniGame) return;
    resetMinigameControls();
    miniGame.endsAt = performance.now() + miniGame.config.duration * 1000;
    $("#minigame-progress-label").textContent = "Time";
    $("#minigame-progress").textContent = `${miniGame.config.duration.toFixed(1)}s`;
    $("#minigame-primary").hidden = true;
    $("#minigame-control-hint").innerHTML = "Tap targets · <kbd>Space</kbd> / <kbd>A</kbd> collects";
    const status = document.createElement("div");
    status.className = "hunt-status";
    status.textContent = `Collected 0/${miniGame.config.targetCount}`;
    const target = document.createElement("button");
    target.type = "button";
    target.className = `hunt-target ${miniGame.config.targetClass || ""}`.trim();
    target.style.backgroundImage = `url("${miniGame.config.targetAsset}")`;
    target.setAttribute("aria-label", `Collect target 1 of ${miniGame.config.targetCount}`);
    target.addEventListener("click", collectHuntTarget);
    $("#minigame-arena").append(status, target);
    moveHuntTarget();
    window.setTimeout(() => target.focus({ preventScroll: true }), 30);
    miniInterval = window.setInterval(() => {
      if (!miniGame || miniGame.config.type !== "hunt") return;
      const remaining = Math.max(0, (miniGame.endsAt - performance.now()) / 1000);
      $("#minigame-progress").textContent = `${remaining.toFixed(1)}s`;
      if (remaining <= 0) finishMinigame();
    }, 80);
  }

  function moveHuntTarget() {
    if (!miniGame || miniGame.config.type !== "hunt") return;
    const target = $(".hunt-target");
    if (!target) return;
    target.style.left = `${8 + Math.random() * 76}%`;
    target.style.top = `${15 + Math.random() * 62}%`;
  }

  function collectHuntTarget() {
    if (!miniGame?.active || miniGame.config.type !== "hunt") return;
    miniGame.score += 1;
    $("#minigame-score").textContent = String(miniGame.score);
    const status = $(".hunt-status");
    if (status) status.textContent = `Collected ${miniGame.score}/${miniGame.config.targetCount}`;
    const target = $(".hunt-target");
    target?.classList.remove("pop");
    void target?.offsetWidth;
    target?.classList.add("pop");
    playSfx(ASSETS.click, .25);
    if (miniGame.score >= miniGame.config.targetCount) {
      playSfx(ASSETS.success, .35);
      finishMinigame();
    } else {
      target?.setAttribute("aria-label", `Collect target ${miniGame.score + 1} of ${miniGame.config.targetCount}`);
      moveHuntTarget();
    }
  }

  function minigameAction() {
    if (!miniGame) return;
    if (miniGame.config.type === "timing") stopTimingMarker();
    if (miniGame.config.type === "hunt") collectHuntTarget();
  }

  function finishMinigame() {
    if (!miniGame || miniGame.finished) return;
    miniGame.finished = true;
    clearMinigameTimers();
    const game = miniGame;
    const { config, locationId } = game;
    const maximum = config.type === "timing" ? config.rounds * 2 : config.type === "sequence" ? config.length : config.targetCount;
    const mastered = game.score >= Math.ceil(maximum * .72);
    const reward = config.baseReward + game.score;
    state.stats.energy = clamp(state.stats.energy - 1, 0, MAX_ENERGY);
    state.stats.cash += reward;
    state.stats.reputation += mastered ? 2 : 1;
    state.relationships[game.npcId] = clamp((state.relationships[game.npcId] || 0) + (mastered ? 2 : 1), 0, 25);
    if (locationId === "lab") state.sparks += mastered ? 2 : 1;
    if (locationId === "farm") state.inventory.produce += mastered ? 2 : 1;
    if (locationId === "mansion") {
      state.inventory.keepsakes += 1;
      if (mastered) state.inventory.parts += 1;
    }
    if (locationId === "ranch" && mastered) state.stats.reputation += 1;
    if (locationId === "club" && mastered) state.stats.reputation += 1;
    const virtuePractice = practiceVirtue(config.virtue, mastered ? 2 : 1);
    state.slot += 1;
    state.actionsTaken += 1;
    state.schedule.push(`${LOCATIONS[locationId].short} challenge`);
    if (!state.visitedToday.includes(locationId)) state.visitedToday.push(locationId);
    const result = challengeResult(locationId, mastered, game.score, maximum, reward);
    if (mastered) addNote(`Day ${state.day}: ${config.title} mastered (${game.score}/${maximum}).`);
    unlockInventions();
    saveState();
    renderAll();
    hide("minigame-overlay");
    miniGame = null;
    showResult(result, game.before, config.animationAction, virtuePractice);
    pendingDayEnd = state.slot >= 3;
  }

  function challengeResult(locationId, mastered, score, maximum, reward) {
    const results = {
      cafe: ["PRESS REGISTERED", "A Free Press, Precisely Aligned", "Ben prints a clear civic broadsheet and distributes it with breakfast."],
      lab: ["CIRCUIT GROUNDED", "Useful Science, Safely Wired", "Ben routes the charge into a practical municipal battery without alarming the ethics board."],
      restaurant: ["COURSES RATIFIED", "Diplomacy Is Served", "Ben seats rival committees, times every course, and negotiates a shared dessert."],
      farm: ["ALMANAC VERIFIED", "A Forecast You Can Eat", "Ben’s notes, instruments, and muddy boots agree on the harvest window."],
      ranch: ["POSTAL TEAM ASSEMBLED", "The Rural Route Has Hooves", "Ben organizes the carrier pigs by route, temperament, and willingness to wear a satchel."],
      mansion: ["SPIRITS GROUNDED", "No Taxation Without Apparition", "Ben maps the charged spirits, grounds the old wiring, and gives the ghosts a maintenance schedule."],
      club: ["RESONANCE FOUND", "The Armonica Meets the Beat", "Ben tunes his glass instrument to the club’s electronic pulse and earns a very modern encore."],
      arcade: ["CABINETS GROUNDED", "The High Scores Survive", "Ben restores the breaker sequence without erasing a single suspicious three-letter high score."],
      conservatory: ["BEDS BALANCED", "A Useful Growing Window", "Ben matches irrigation, light, and public appetite before the seedlings become argumentative."],
      skyhouse: ["AERIAL POST SORTED", "Every Parcel Has a Hook", "Ben catches the windblown route and files the clouds under ‘uncooperative infrastructure.’"],
      guildhall: ["CHARTER FILED", "The Assembly Has Its Seals", "Ben recovers every charter seal before the unusual citizens can vote to replace paperwork with roaring."],
      market: ["SCALES BALANCED", "An Honest Market Measure", "Ben repeats the standard weights exactly and leaves the mushroom riddles unregulated."],
      elementalbaths: ["VALVES BALANCED", "Ember and Frost Agree", "Ben holds the baths inside the narrow temperature range accepted by dragons and insurers."],
      clockstation: ["PARCELS CAUGHT", "The Express Leaves on Time", "Ben returns every parcel to the platform before the third bell clears the line."]
    };
    const [stamp, title, successCopy] = results[locationId];
    return {
      stamp: mastered ? stamp : "PROMISING EXPERIMENT",
      title: mastered ? title : "A Useful First Attempt",
      copy: `${mastered ? successCopy : `Ben records what went wrong and schedules a better second experiment.`} Score: ${score}/${maximum}. Commission: $${reward}.`
    };
  }

  function cancelMinigame() {
    if (!miniGame) return;
    const locationId = miniGame.locationId;
    clearMinigameTimers();
    miniGame = null;
    hide("minigame-overlay");
    show("location-sheet");
    renderActions(locationId);
    window.setTimeout(() => $("#action-list .action-button:last-child")?.focus({ preventScroll: true }), 30);
  }

  function performAction(locationId, action) {
    if(roomEditMode){showSceneToast("Finish room editing before starting an activity.");return;}
    if (state.slot >= 3 || state.stats.energy < action.energy) return;
    if (!actionMeetsRequirement(action)) return;
    const before = snapshotStats();clearAutoMovement("interior");heldKeys.clear();
    state.stats.energy = clamp(state.stats.energy - action.energy, 0, MAX_ENERGY);
    const result = resolveAction(locationId, action.id);
    const virtuePractice = practiceVirtue(action.virtue||virtueForAction(action.id, locationId));
    state.slot += 1;
    state.actionsTaken += 1;
    state.schedule.push(action.id === "pickup" ? "Errand pickup" : action.id === "deliver" ? "Delivery" : LOCATIONS[locationId].short);
    if (!state.visitedToday.includes(locationId)) state.visitedToday.push(locationId);
    unlockInventions();
    saveState();
    renderAll();
    hide("location-sheet");
    showResult(result, before, action.id, virtuePractice);
    pendingDayEnd = state.slot >= 3;
    playSfx(action.id === "pastry" || action.id === "meal" ? ASSETS.eat : ASSETS.success, 0.32);
  }

  function resolveAction(locationId, actionId) {
    const weather = currentWeather();
    const electricBonus = weather.id === "thunderstorm" ? 1 : 0;
    const secondary=CORE.actionOutcome(locationId,actionId,{weatherId:weather.id});
    if(secondary){applyActionEffects(locationId,secondary.effects);return {stamp:secondary.stamp,title:secondary.title,copy:secondary.copy};}
    switch (actionId) {
      case "pickup": {
        state.activeErrand.status = "carrying";
        waypointLocationId=null;if(!state.tutorialDismissed&&state.day===1&&state.tutorialStep<2)state.tutorialStep=2;
        addRelationship(locationId, 1);
        return { stamp: "SPECIAL DELIVERY", title: "Package Secured", copy: `${NPCS[currentNpcId].name} hands Ben the ${state.activeErrand.item}. It is labeled “this side probably up.”` };
      }
      case "deliver": {
        const errand = state.activeErrand;
        state.stats.cash += errand.reward;
        state.stats.reputation += 2;
        state.errandsDone += 1;
        addRelationship(locationId, 2);
        errand.status = "done";
        waypointLocationId=null;if(!state.tutorialDismissed&&state.day===1)state.tutorialStep=3;
        addNote(`Day ${state.day}: Delivered the ${errand.item} without creating a new ordinance.`);
        return { stamp: "ERRAND COMPLETE", title: "Signed, Sealed, Questioned", copy: `${NPCS[currentNpcId].name} accepts the ${errand.item}. Against all odds, this was exactly what they ordered.` };
      }
      case "barista": {
        const tip = 10 + (chance(35) ? 4 : 0);
        state.stats.cash += tip;
        state.stats.reputation += 1;
        addRelationship("cafe", 1);
        return { stamp: "HOT OFF THE PRESS", title: "The Morning Edition", copy: tip > 10 ? "Ben’s lead story fixes a pothole by lunchtime. The advice column is syndicated by dinner." : "The broadsheet sells briskly, despite a regrettable inkblot over the weather forecast." };
      }
      case "counsel":
        addRelationship("cafe", 3);
        state.stats.reputation += 1;
        return { stamp: "JUNTO ADJOURNED", title: "A Club for Mutual Improvement", copy: "The table proposes a crosswalk, a tool library, and quieter smoothie blenders. Ben records all three motions." };
      case "pastry":
        state.stats.cash -= 5;
        state.stats.energy = clamp(state.stats.energy + 3, 0, MAX_ENERGY);
        addRelationship("cafe", 1);
        return { stamp: "THERMAL RESEARCH", title: "A Better Cup", copy: "The insulated mug keeps coffee hot without scorching the hand. Ben drinks the complete experimental sample." };
      case "tinker": {
        state.inventory.parts -= 1;
        const gain = 2 + electricBonus + (chance(22) ? 1 : 0);
        state.sparks += gain;
        addRelationship("lab", 1);
        return { stamp: "PROGRESS, PROBABLY", title: "A Productive Crackle", copy: `The Civic Spark gains ${gain} sparks. One dial now goes past eleven, which Dr. Hex calls “ambitious.”` };
      }
      case "intern": {
        const parts = chance(55) ? 2 : 1;
        state.inventory.parts += parts;
        state.stats.cash += 8;
        addRelationship("lab", 1);
        return { stamp: "CIVIC SAFETY", title: "Properly Grounded", copy: `Ben documents four unsafe conductors and recovers ${parts} obsolete fitting${parts > 1 ? "s" : ""} for reuse.` };
      }
      case "hexchat":
        addRelationship("lab", 3);
        state.sparks += 1;
        return { stamp: "USEFUL KNOWLEDGE", title: "A Frank Discussion", copy: "Ben argues that invention should improve ordinary life. The lab adds ‘public benefit’ to its design checklist." };
      case "serve": {
        const pay = 12 + (state.inventory.produce > 0 ? 3 : 0);
        state.stats.cash += pay;
        addRelationship("restaurant", 1);
        return { stamp: "EFFICIENT HEAT", title: "The Franklin Stove, Reheated", copy: `Ben improves the kitchen’s airflow and fuel use. Chef Howl pays $${pay} and names one baffle after him.` };
      }
      case "meal":
        state.stats.cash -= 8;
        state.stats.energy = clamp(state.stats.energy + 4, 0, MAX_ENERGY);
        addRelationship("restaurant", 1);
        return { stamp: "TABLE DIPLOMACY", title: "Life, Liberty & Soup", copy: "A zoning dispute ends over shared bread and practical compromise. Ben also negotiates a second dessert." };
      case "kitchen":
        addRelationship("restaurant", 3);
        if (state.inventory.produce > 0) {
          state.inventory.produce -= 1;
          state.stats.cash += 6;
        }
        return { stamp: "PUBLIC TABLE", title: "A Menu for the Neighborhood", copy: "Ben and the kitchen design an affordable local supper. One tasteful howl marks unanimous approval." };
      case "garden": {
        if (!state.garden.crop) {
          state.garden = { crop: pick(["tomatoes", "corn", "radishes", "pumpkins"]), age: 0, tended: 1 };
          addRelationship("farm", 1);
          return { stamp: "SEEDS OF CHANGE", title: "A Row Well Planted", copy: `Ben plants ${state.garden.crop}. Pigford gives a stirring speech about compost.` };
        }
        if (state.garden.age < 3) {
          state.garden.tended += 1;
          state.garden.age += 1;
          addRelationship("farm", 2);
          return { stamp: "GOOD GROWTH", title: "Outstanding in His Field", copy: `The ${state.garden.crop} look noticeably more civic-minded after Ben weeds and waters them.` };
        }
        const harvest = 2 + Math.min(2, state.garden.tended);
        state.inventory.produce += harvest;
        state.stats.cash += harvest * 3;
        state.cropsHarvested += harvest;
        state.garden = { crop: null, age: 0, tended: 0 };
        addRelationship("farm", 2);
        return { stamp: "BUMPER CROP", title: "Harvest of Consequences", copy: `Ben gathers ${harvest} bundles of produce. One tomato asks to retain counsel.` };
      }
      case "pigchat":
        addRelationship("farm", 3);
        state.stats.reputation += 1;
        return { stamp: "POOR RICHARD REPORTS", title: "Weather, With Qualifications", copy: "Ben compares barometer, clouds, and farmer testimony. The forecast says rain; the pigs remain skeptical." };
      case "forage": {
        const found = chance(30) ? 3 : 2;
        state.inventory.parts += found;
        return { stamp: "SALVAGE RIGHTS", title: "Useful-Looking Junk", copy: `Ben finds ${found} spare parts, a button, and a receipt from 1997. All may be essential.` };
      }
      case "inspect": {
        const found = chance(40) ? 2 : 1;
        state.inventory.parts += found;
        state.inventory.keepsakes += 1;
        state.stats.reputation += 1;
        return { stamp: "ELECTRICAL INQUIRY", title: "Charge, Draft, or Ghost?", copy: `Ben traces the disturbance to old wiring plus one cooperative spirit. He recovers ${found} fitting${found > 1 ? "s" : ""} and grounds the circuit.` };
      }
      case "seance":
        addRelationship("mansion", 3);
        state.stats.reputation += 1;
        return { stamp: "COMPACT ADOPTED", title: "Representation for Every Resident", copy: "Living and spectral tenants approve shared quiet hours, archive access, and transparent maintenance records." };
      case "dust":
        state.stats.cash += 13;
        addRelationship("mansion", 1);
        return { stamp: "ARCHIVE RECOVERED", title: "The Papers of Several Lifetimes", copy: "Ben dates, sorts, and indexes a century of letters. The ghosts pay him in modern currency after a brief tutorial." };
      case "openmic": {
        const reputation = chance(35) ? 4 : 2;
        state.stats.reputation += reputation;
        addRelationship("club", 1);
        return { stamp: "GLASS ARMONICA LIVE", title: reputation > 2 ? "An Electric Encore" : "A Delicate First Set", copy: reputation > 2 ? "Ben’s glass armonica floats over the electronic beat. The crowd demands an encore." : "The glass tones start softly, then find the room’s frequency. Even the vampires stop talking." };
      }
      case "dance":
        addRelationship("club", 3);
        state.sparks += weather.id === "thunderstorm" ? 2 : 1;
        return { stamp: "HISTORICAL THEATER", title: "One Founder, Every Role", copy: "Ben performs patriot, redcoat, horse, cannon, and dramatic casualty. Accuracy is debated; commitment is not." };
      case "bartend":
        state.stats.cash += 12;
        addRelationship("club", 1);
        return { stamp: "CIVIC SALON", title: "Ideas in Good Company", copy: "Ben connects a musician, a carpenter, and a transit planner. The mocktail garnish requires two-thirds approval." };
      case "groom":
        addRelationship("ranch", 3);
        state.stats.reputation += 1;
        return { stamp: "USEFUL AMUSEMENT", title: "Kites for Curious Creatures", copy: "Ben’s low-flying ribbon kite keeps the pigs active and entertained. The animals approve the tail design." };
      case "irrigate": {
        const found = chance(40) ? 2 : 1;
        state.inventory.parts += found;
        state.stats.cash += 9;
        addRelationship("ranch", 1);
        return { stamp: "LIGHTNING PROTECTION", title: "A Properly Grounded Pump", copy: `Ben protects the irrigation controls and salvages ${found} outdated part${found > 1 ? "s" : ""}. The livestock shelter is safer before the next storm.` };
      }
      case "trailride":
        state.stats.reputation += 3;
        addRelationship("ranch", 2);
        return { stamp: "POSTAL SERVICE", title: "The Rural Route Reopens", copy: "Ben marks safe crossings, sensible stops, and one pig-accessible mailbox. The first delivery arrives before sundown." };
      default:
        return { stamp: "TIME PASSES", title: "An Ordinary Miracle", copy: "Ben does something unrecorded by history and feels better for it." };
    }
  }

  function applyActionEffects(locationId,effects={}) {
    state.stats.cash=Math.max(0,state.stats.cash+(Number(effects.cash)||0));state.stats.energy=clamp(state.stats.energy+(Number(effects.energy)||0),0,MAX_ENERGY);state.stats.reputation=Math.max(0,state.stats.reputation+(Number(effects.reputation)||0));state.sparks=Math.max(0,state.sparks+(Number(effects.sparks)||0));state.inventory.parts=Math.max(0,state.inventory.parts+(Number(effects.parts)||0));state.inventory.produce=Math.max(0,state.inventory.produce+(Number(effects.produce)||0));state.inventory.keepsakes=Math.max(0,state.inventory.keepsakes+(Number(effects.keepsakes)||0));if(effects.friendship)addRelationship(locationId,Number(effects.friendship)||0);
  }

  function snapshotStats() {
    return {
      cash: state.stats.cash,
      energy: state.stats.energy,
      reputation: state.stats.reputation,
      parts: state.inventory.parts,
      produce: state.inventory.produce,
      sparks: state.sparks,
      friendship: Object.values(state.relationships).reduce((a, b) => a + b, 0)
    };
  }

  function addRelationship(id, amount) {
    const npcId = NPCS[id]
      ? id
      : ROSTERS[id]?.includes(currentNpcId)
        ? currentNpcId
        : activeNpc(id).id;
    state.relationships[npcId] = clamp((state.relationships[npcId] || 0) + amount, 0, 25);
  }

  function addNote(note) {
    state.notes.unshift(note);
    state.notes = state.notes.slice(0, 8);
  }

  function unlockInventions() {
    INVENTIONS.forEach(invention => {
      if (state.sparks >= invention.threshold && !state.inventions.includes(invention.name)) {
        state.inventions.push(invention.name);
        addNote(`Invented: ${invention.name}. Nobody asked for it, which is how progress starts.`);
      }
    });
  }

  function showResult(result, before, actionId, virtuePractice = null) {
    $("#result-stamp").textContent = result.stamp;
    $("#result-title").textContent = result.title;
    $("#result-copy").textContent = result.copy;
    const after = snapshotStats();
    const labels = { cash: "$", energy: "energy", reputation: "reputation", parts: "parts", produce: "produce", sparks: "sparks", friendship: "friendship" };
    const deltas = $("#result-deltas");
    deltas.replaceChildren();
    Object.keys(labels).forEach(key => {
      const delta = after[key] - before[key];
      if (!delta) return;
      const chip = document.createElement("span");
      chip.className = `delta-chip ${delta > 0 ? "good" : "bad"}`;
      chip.textContent = `${delta > 0 ? "+" : ""}${key === "cash" ? `$${delta}` : delta} ${key === "cash" ? "cash" : labels[key]}`;
      deltas.append(chip);
    });
    if (virtuePractice) {
      const chip = document.createElement("span");
      chip.className = "delta-chip good";
      chip.textContent = `+${virtuePractice.gain} ${virtuePractice.icon} ${virtuePractice.name}${virtuePractice.focused ? " · focus" : ""}`;
      deltas.append(chip);
    }
    show("result-overlay");
    playBenAnimation(actionId);
    $("#result-continue").focus({ preventScroll: true });
  }

  function playBenAnimation(actionId) {
    const sequence = ACTION_ANIMATIONS[actionId] || ["breathing"];
    const token = ++benAnimationToken;
    const image = $("#result-ben");
    const label = $("#result-action-label");
    let sequenceIndex = 0;

    const playClip = () => {
      if (token !== benAnimationToken || !isVisible("result-overlay")) return;
      const animation = BEN_ANIMATIONS[sequence[sequenceIndex % sequence.length]];
      const root = animation.kite
        ? "assets/characters/Main Character/Ben_Franklin_with_Kite/animations"
        : "assets/characters/Main Character/Ben_Franklin/animations";
      label.textContent = `Ben move: ${animation.label}`;
      let frame = 0;
      const tick = () => {
        if (token !== benAnimationToken || !isVisible("result-overlay")) return;
        image.src = `${root}/${animation.folder}/south/frame_${String(frame).padStart(3, "0")}.png`;
        frame += 1;
        if (frame < animation.frames) {
          window.setTimeout(tick, animation.frames > 12 ? 65 : 90);
        } else {
          sequenceIndex += 1;
          if (sequenceIndex < sequence.length) window.setTimeout(playClip, 120);
          else window.setTimeout(() => {
            if (token === benAnimationToken && isVisible("result-overlay")) {
              sequenceIndex = 0;
              playClip();
            }
          }, 420);
        }
      };
      tick();
    };
    playClip();
  }

  function takeNap() {
    if(townEditMode||roomEditMode){showTownPrompt("Finish editing before advancing time",1800);return;}
    if (state.slot >= 3) return;
    const before = snapshotStats();
    state.stats.energy = clamp(state.stats.energy + 3, 0, MAX_ENERGY);
    const virtuePractice = practiceVirtue("temperance");
    state.slot += 1;
    state.actionsTaken += 1;
    state.schedule.push("Power nap");
    saveState();
    renderAll();
    pendingDayEnd = state.slot >= 3;
    showResult({ stamp: "EFFICIENT REST", title: "A Constitutionally Sound Nap", copy: "Ben sleeps for exactly twenty-three minutes and dreams of bifocals with dark mode." }, before, "nap", virtuePractice);
  }

  function showDayEnd() {
    clearAutoMovement();heldKeys.clear();
    hide("location-sheet");
    hide("result-overlay");
    const titleTail = pick(["Productive-ish", "Historically Adequate", "No Major Fires", "A Net Positive", "Mostly Constitutional"]);
    $("#day-end-title").textContent = `Day ${state.day}, Filed Under “${titleTail}”`;
    $("#day-end-event").textContent = NIGHT_EVENTS[state.day] || pick([
      "Ben writes three aphorisms before deciding two are tweets and one is a cry for help.",
      "The town settles in. Somewhere, a suspiciously modern rooster checks its alarm.",
      "Ben puts the kite by the door. It immediately falls over with comic precision.",
      "A quiet evening passes, except at the mansion, where quiet has a different definition.",
      "Ben updates his résumé to include ‘cross-century adaptability.’"
    ]);
    const friendship = Object.values(state.relationships).reduce((sum, value) => sum + value, 0);
    setSummary($("#day-end-summary"), [
      [state.schedule.length, "things accomplished"],
      [state.focusCompleted ? dailyVirtue().name : "Missed", "virtue focus"],
      [state.focusStreak, "focus streak"]
    ]);
    $("#next-day-button").textContent = state.day >= 30 ? "Attend the Showcase" : "Start Tomorrow";
    show("day-end-overlay");
    $("#next-day-button").focus({ preventScroll: true });
  }

  function nextDay() {
    hide("day-end-overlay");
    if (state.day >= 30) {
      showCycleEnd();
      return;
    }
    if (!state.focusCompleted) state.focusStreak = 0;
    const departingWeather=currentWeather();
    advanceCommunityLives();
    state.day += 1;
    state.slot = 0;
    state.stats.energy = MAX_ENERGY;
    state.schedule = [];
    state.visitedToday = [];
    state.virtuesToday = [];
    state.focusCompleted = false;
    advanceForecast();
    const arrivingWeather=currentWeather();
    if (["heatwave","blizzard"].includes(arrivingWeather.id)) state.stats.energy=Math.max(1,MAX_ENERGY-1);
    if (state.garden.crop && departingWeather.category==="rain") state.garden.tended += departingWeather.intensity;
    state.activeErrand = makeErrand();
    if (state.garden.crop) state.garden.age += 1;
    saveState();
    drawTownLevel();
    renderAll();
    playSfx(ASSETS.transition, 0.25);
    $("#town-map").focus({ preventScroll: true });
  }

  function showCycleEnd() {
    const friendship = Object.values(state.relationships).reduce((sum, value) => sum + value, 0);
    const score = state.sparks * 3 + state.stats.reputation * 2 + friendship + state.errandsDone * 4 + state.cropsHarvested + Math.floor(virtueTotal() / 2) + state.focusDays * 2;
    let grade = "C";
    let copy = "The Civic Spark makes a sincere buzzing noise. The crowd politely agrees this is a foundation for future greatness.";
    if (score >= 150) {
      grade = "A+";
      copy = "The Lightning-Powered Latte Cart serves the entire town during a blackout. Ben is declared a civic treasure and asked to stop ‘improving’ the grid for one weekend.";
    } else if (score >= 105) {
      grade = "A";
      copy = "The showcase is a crackling success. Several inventions work, the coffee is hot, and only one committee member briefly glows.";
    } else if (score >= 70) {
      grade = "B+";
      copy = "The Civic Spark wobbles, whistles, and successfully charges a municipal golf cart. The town is genuinely charmed.";
    } else if (score >= 40) {
      grade = "B−";
      copy = "Ben’s demonstration becomes an excellent conversation starter, mainly because nobody can agree on what it demonstrated.";
    }
    $("#cycle-grade").textContent = grade;
    $("#cycle-copy").textContent = copy;
    setSummary($("#cycle-stats"), [
      [state.inventions.length, "inventions"],
      [state.focusDays, "focus days"],
      [virtueTotal(), "virtue practice"]
    ]);
    show("cycle-end-overlay");
    $("#next-cycle-button").focus({ preventScroll: true });
  }

  function beginNextCycle() {
    if (!state.focusCompleted) state.focusStreak = 0;
    state.cycle += 1;
    state.day = 1;
    state.slot = 0;
    state.stats.energy = MAX_ENERGY;
    state.schedule = [];
    state.visitedToday = [];
    state.virtuesToday = [];
    state.focusCompleted = false;
    state.focusDays = 0;
    state.discoveries = [];
    state.weather = rollWeather(state.day,state.cycle);
    state.forecast = [state.weather];
    while(state.forecast.length<4) state.forecast.push(rollWeather(state.day+state.forecast.length,state.cycle));
    state.activeErrand = makeErrand();
    addNote(`Timeline ${state.cycle}: Ben remembers the friends and inventions that mattered.`);
    saveState();
    drawTownLevel();
    renderAll();
    hide("cycle-end-overlay");
    $("#town-map").focus({ preventScroll: true });
  }

  function setSummary(container, values) {
    container.replaceChildren();
    values.forEach(([value, label]) => {
      const item = document.createElement("div");
      item.className = "summary-stat";
      const number = document.createElement("b");
      number.textContent = value;
      const caption = document.createElement("span");
      caption.textContent = label;
      item.append(number, caption);
      container.append(item);
    });
  }

  function show(id) { $(`#${id}`).classList.remove("hidden"); }
  function hide(id) { $(`#${id}`).classList.add("hidden"); }
  function isVisible(id) { return !$("#" + id).classList.contains("hidden"); }

  function closeLocationSheet(){
    if(roomEditorDrag)finishRoomEditorDrag();
    if(roomEditMode)persistCurrentInteriorLayout();
    roomEditMode=false;roomEditorSelection=null;roomEditorDrag=null;roomEditorInspectorSnapshot=null;heldKeys.clear();clearAutoMovement("interior");
    $("#room-edit-toggle").textContent="✥ Edit Room";$("#room-edit-palette").classList.add("hidden");$("#location-scene")?.classList.remove("room-editing");
    closeAssetBrowser();
    renderInteriorNpcEntities();renderRoomEditorHandles();
    hide("location-sheet");$("#town-map")?.focus({preventScroll:true});
  }

  function closeTopOverlay() {
    if (isVisible("dialogue-overlay")) closeDialogue();
    else if (isVisible("help-overlay")) hide("help-overlay");
    else if (isVisible("minigame-overlay")) cancelMinigame();
    else if (isVisible("location-sheet")) closeLocationSheet();
    else if (isVisible("result-overlay")) $("#result-continue").click();
  }

  function toggleSound() {
    state.sound = !state.sound;
    saveState();
    $("#sound-toggle").textContent = state.sound ? "♫" : "×";
    const music = $("#music-player");
    if (state.sound) startAudio();
    else music.pause();
  }

  function startAudio() {
    if (!state.sound) return;
    const music = $("#music-player");
    music.volume = 0.18;
    music.play().catch(() => { /* browsers wait for another interaction */ });
  }

  function playSfx(src, volume = 0.3) {
    if (!state.sound) return;
    const player = $("#sfx-player");
    player.src = src;
    player.volume = volume;
    player.play().catch(() => {});
  }

  function trapModalFocus(event) {
    if(event.key!=="Tab")return false;
    const modal=["dialogue-overlay","help-overlay","minigame-overlay","result-overlay","day-end-overlay","cycle-end-overlay","location-sheet","start-screen"].map(id=>$("#"+id)).find(element=>element&&!element.classList.contains("hidden"));if(!modal)return false;
    const focusable=$$("button:not([disabled]),input:not([disabled]),select:not([disabled]),textarea:not([disabled]),a[href],[tabindex]:not([tabindex='-1'])",modal).filter(element=>element.offsetParent!==null);if(!focusable.length)return false;
    const first=focusable[0],last=focusable.at(-1);
    // A modal can become visible while focus remains on the page beneath it.
    // The next Tab must enter the dialog, not expose background town controls.
    if(!modal.contains(document.activeElement)){event.preventDefault();(event.shiftKey?last:first).focus();return true;}
    if(event.shiftKey&&document.activeElement===first){event.preventDefault();last.focus();return true;}if(!event.shiftKey&&document.activeElement===last){event.preventDefault();first.focus();return true;}return false;
  }

  function handleKeydown(event) {
    if(trapModalFocus(event))return;
    if(event.defaultPrevented)return;
    if (isVisible("start-screen")) return;
    if(isVisible("dialogue-overlay")){if(["Escape","Enter"," "].includes(event.key)){event.preventDefault();closeDialogue();}return;}
    const editableTarget=event.target.matches?.("input,select,textarea,[contenteditable='true']");
    if(townEditMode||roomEditMode){
      if(editableTarget)return;
      if(event.key==="/"){event.preventDefault();if(assetDockCollapsed)toggleAssetDock();$("#asset-search").focus({preventScroll:true});return;}
      if(event.key==="Escape"){event.preventDefault();$(townEditMode?"#town-edit-toggle":"#room-edit-toggle").click();return;}
      const modifier=event.ctrlKey||event.metaKey,key=event.key.toLowerCase();
      if(modifier&&!event.shiftKey&&key==="z"){event.preventDefault();townEditMode?undoTownEditor():undoRoomEditor();return;}
      if(modifier&&(key==="y"||(event.shiftKey&&key==="z"))){event.preventDefault();townEditMode?redoTownEditor():redoRoomEditor();return;}
      if(event.key==="Delete"||event.key==="Backspace"){event.preventDefault();townEditMode?deleteTownEditorItem():deleteRoomEditorItem();return;}
      if(modifier&&key==="d"){event.preventDefault();townEditMode?duplicateTownEditorItem():duplicateRoomEditorItem();return;}
      if(roomEditMode&&["arrowleft","arrowright","arrowup","arrowdown"].includes(key)){event.preventDefault();const step=event.shiftKey?8:1;nudgeRoomEditorSelection(key==="arrowleft"?-step:key==="arrowright"?step:0,key==="arrowup"?-step:key==="arrowdown"?step:0);return;}
      return;
    }
    if (event.key.toLowerCase() === "m") { toggleSound(); return; }
    if (isVisible("minigame-overlay")) {
      if (event.key === "Escape") cancelMinigame();
      else if (miniGame?.config.type === "sequence" && ["ArrowUp", "ArrowRight", "ArrowDown", "ArrowLeft"].includes(event.key)) {
        event.preventDefault();
        handleSequenceInput(event.key);
      } else if (miniGame?.config.type === "sequence" && ["1", "2", "3", "4"].includes(event.key)) {
        handleSequenceInput(["ArrowUp", "ArrowRight", "ArrowDown", "ArrowLeft"][Number(event.key) - 1]);
      } else if (event.key === "Enter" || event.key === " ") {
        event.preventDefault();
        minigameAction();
      }
      return;
    }
    if (event.key.toLowerCase() === "h") { show("help-overlay"); return; }
    if (event.key === "Escape") { closeTopOverlay(); return; }
    if (isVisible("result-overlay") || isVisible("day-end-overlay") || isVisible("cycle-end-overlay") || isVisible("help-overlay")) return;
    if (isVisible("location-sheet")) {
      const number = Number(event.key);
      if (number >= 1 && number <= 4) {
        const button = $$("#action-list .action-button")[number - 1];
        if (button && !button.disabled) button.click();
      }
      const key = event.key.toLowerCase();
      if (["arrowleft","arrowright","arrowup","arrowdown","a","d","w","s"].includes(key)) { event.preventDefault(); clearAutoMovement("interior");heldKeys.add(key); }
      if (key === "e") { event.preventDefault();const placedNpc=nearestInteriorNpcEntity();if(placedNpc)talkToInteriorNpcEntity(placedNpc.entity);else inspectCurrentScene(); }
      return;
    }
    const key = event.key.toLowerCase();
    if (["arrowleft", "arrowright", "arrowup", "arrowdown", "a", "d", "w", "s", "shift"].includes(key)) {
      event.preventDefault();
      clearAutoMovement("town");
      heldKeys.add(key);
    }
    if (key === "e" || event.key === "Enter" || event.key === " ") { event.preventDefault(); enterNearbyLocation(); }
  }

  function handleKeyup(event) { heldKeys.delete(event.key.toLowerCase()); }

  function focusAction(direction) {
    const buttons = $$("#action-list .action-button");
    if (!buttons.length) return;
    let attempts = 0;
    do {
      actionFocus = (actionFocus + direction + buttons.length) % buttons.length;
      attempts += 1;
    } while (buttons[actionFocus].disabled && attempts <= buttons.length);
    buttons[actionFocus].focus();
  }

  function pollGamepad(timestamp) {
    const pads=navigator.getGamepads?Array.from(navigator.getGamepads()).filter(Boolean):[];
    if(!pads.length){activeGamepadIndex=null;gamepadButtons=[];gamepadMove={x:0,y:0,magnitude:0};requestAnimationFrame(pollGamepad);return;}
    const engaging=pads.find(candidate=>{const normalized=CORE.normalizeGamepad(candidate);return normalized.move.magnitude>.05||normalized.pressed.some(Boolean);});
    const previous=pads.find(candidate=>candidate.index===activeGamepadIndex),pad=engaging||previous||pads[0];
    if(activeGamepadIndex!==pad.index){activeGamepadIndex=pad.index;gamepadButtons=[];}
    const input=CORE.normalizeGamepad(pad),pressed=index=>Boolean(input.pressed[index]),edge=index=>pressed(index)&&!gamepadButtons[index];
    if(isVisible("start-screen")){
      gamepadMove={x:0,y:0,magnitude:0};
      if(edge(0)){const button=$("#continue-button");(button&&!button.classList.contains("hidden")?button:$("#new-game-button"))?.click();}
      gamepadButtons=input.pressed.slice();requestAnimationFrame(pollGamepad);return;
    }
    if(isVisible("minigame-overlay")){
      gamepadMove={x:0,y:0,magnitude:0};
      if(miniGame?.config.type==="sequence"&&input.move.magnitude>.55&&timestamp-gamepadNavAt>220){const direction=Math.abs(input.move.x)>Math.abs(input.move.y)?(input.move.x>0?"ArrowRight":"ArrowLeft"):(input.move.y>0?"ArrowDown":"ArrowUp");handleSequenceInput(direction);gamepadNavAt=timestamp;}
      if(edge(0))minigameAction();if(edge(1))cancelMinigame();gamepadButtons=input.pressed.slice();requestAnimationFrame(pollGamepad);return;
    }
    const modalBlocked=isVisible("result-overlay")||isVisible("day-end-overlay")||isVisible("cycle-end-overlay")||isVisible("help-overlay")||isVisible("dialogue-overlay");
    gamepadMove=modalBlocked?{x:0,y:0,magnitude:0}:input.move;
    if(gamepadMove.magnitude)clearAutoMovement(isVisible("location-sheet")?"interior":"town");
    if(edge(0)){
      if(isVisible("dialogue-overlay"))closeDialogue();
      else if(isVisible("result-overlay"))$("#result-continue").click();
      else if(isVisible("day-end-overlay"))$("#next-day-button").click();
      else if(isVisible("cycle-end-overlay"))$("#next-cycle-button").click();
      else if(isVisible("help-overlay"))hide("help-overlay");
      else if(isVisible("location-sheet")){const button=$$("#action-list .action-button")[actionFocus];if(button&&!button.disabled)button.click();}
      else if(nearbyLocationId||nearbyResidentId)enterNearbyLocation();
      else {const id=LOCATION_ORDER[selectedIndex];setTownMoveDestination(townBuildingGeometry(id).doorPoint,`${LOCATIONS[id].short}'s front door`);}
    }
    if(edge(2)&&isVisible("location-sheet")&&!modalBlocked){const placedNpc=nearestInteriorNpcEntity();if(placedNpc)talkToInteriorNpcEntity(placedNpc.entity);else inspectCurrentScene();}
    if(edge(1))closeTopOverlay();
    if(edge(4)&&!modalBlocked){if(isVisible("location-sheet"))focusAction(-1);else cycleLocation(-1);}
    if(edge(5)&&!modalBlocked){if(isVisible("location-sheet"))focusAction(1);else cycleLocation(1);}
    if(edge(9)&&!isVisible("dialogue-overlay")){show("help-overlay");gamepadMove={x:0,y:0,magnitude:0};}
    gamepadButtons=input.pressed.slice();requestAnimationFrame(pollGamepad);
  }

  function setupTabs() {
    const tabs=$$(".tab");
    tabs.forEach((tab,index) => {
      const panel=$(`#tab-${tab.dataset.tab}`);tab.id=`notebook-tab-${tab.dataset.tab}`;tab.setAttribute("aria-controls",panel.id);tab.tabIndex=tab.classList.contains("active")?0:-1;panel.setAttribute("aria-labelledby",tab.id);panel.hidden=!panel.classList.contains("active");
      const activate=() => {
        activeNotebookTab=tab.dataset.tab;
        $$(".tab").forEach(item => {
          const active = item === tab;
          item.classList.toggle("active", active);
          item.setAttribute("aria-selected", String(active));
          item.tabIndex=active?0:-1;
        });
        $$(".tab-content").forEach(content => {const active=content.id === `tab-${tab.dataset.tab}`;content.classList.toggle("active",active);content.hidden=!active;});
        renderActiveNotebookTab();
      };
      tab.addEventListener("click",activate);
      tab.addEventListener("keydown",event=>{if(!["ArrowLeft","ArrowRight","Home","End"].includes(event.key))return;event.preventDefault();const nextIndex=event.key==="Home"?0:event.key==="End"?tabs.length-1:(index+(event.key==="ArrowRight"?1:-1)+tabs.length)%tabs.length;tabs[nextIndex].focus();tabs[nextIndex].click();});
    });
  }

  function bindEvents() {
    $("#new-game-button").addEventListener("click", () => initializeGame(true));
    $("#found-town-button").addEventListener("click",()=>{$("#found-town-setup").classList.remove("hidden");$("#found-town-seed").focus();});
    $("#found-town-cancel").addEventListener("click",()=>$("#found-town-setup").classList.add("hidden"));
    [["found-town-height",""],["found-town-grass","%"],["found-town-water","%"],["found-town-trees","%"]].forEach(([id,suffix])=>{const input=$("#"+id),output=input.closest("label").querySelector("output");input.addEventListener("input",()=>{output.value=input.value;output.textContent=input.value+suffix;});});
    $("#found-town-random-seed").addEventListener("click",()=>{$("#found-town-seed").value=`Philadelphia ${Math.floor(Math.random()*9000+1000)}`;});
    $("#found-town-start").addEventListener("click",initializeFoundedTown);
    $("#continue-button").addEventListener("click", () => initializeGame(false));
    $("#save-slot-select").addEventListener("change",event=>switchSaveSlot(event.target.value));
    $("#save-export").addEventListener("click",exportSaveBundle);
    $("#save-import").addEventListener("click",()=>$("#save-import-file").click());
    $("#save-import-file").addEventListener("change",async event=>{await importSaveBundle(event.target.files?.[0]);event.target.value="";});
    $("#save-reset").addEventListener("click",clearActiveSaveSlot);
    $("#sound-toggle").addEventListener("click", toggleSound);
    $("#help-button").addEventListener("click", () => show("help-overlay"));
    $("#rest-button").addEventListener("click", takeNap);
    $("#objective-compass").addEventListener("click",()=>setWaypoint($("#objective-compass").dataset.location));
    $("#onboarding-skip").addEventListener("click",()=>{state.tutorialDismissed=true;saveState();renderOnboarding();});
    $("#dialogue-close").addEventListener("click",closeDialogue);
    $("#dialogue-continue").addEventListener("click",closeDialogue);
    $("#people-search").addEventListener("input",renderRelationships);
    $("#people-filter").addEventListener("change",renderRelationships);
    $("#town-edit-toggle").addEventListener("click",event=>{
      event.stopPropagation(); townEditMode=!townEditMode; townEditorDrag=null;
      $("#town-edit-toggle").textContent=townEditMode?"✓ Done Editing":"✥ Edit Town";
      setTownEditorToolsCollapsed(true);
      if(townEditMode){clearAutoMovement("town");updateFoundingTools();openAssetBrowser("town");}else{closeAssetBrowser();townEditorSelection=null;townTerrainTool=null;townTerrainPainting=false;$$('[data-terrain-tool]').forEach(button=>button.classList.remove("active"));$("#town-map").classList.remove("terrain-painting");saveTownEditorLayout();}
      renderTownNpcEntities();
      renderTownEditorHandles();
      showTownPrompt(townEditMode?"Town editor · drag objects or open Terrain Studio":"");
    });
    $("#town-tools-collapse").addEventListener("click",event=>{event.stopPropagation();setTownEditorToolsCollapsed(!townEditorToolsCollapsed);});
    $$('[data-terrain-tool]').forEach(button=>button.addEventListener("click",event=>{
      event.stopPropagation();setTownTerrainTool(button.dataset.terrainTool);
    }));
    $("#terrain-undo").addEventListener("click",event=>{event.stopPropagation();undoTownEditor();});
    $("#terrain-redo").addEventListener("click",event=>{event.stopPropagation();redoTownEditor();});
    [["terrain-brush-size","terrain-brush-size-output"],["terrain-brush-strength","terrain-brush-strength-output"]].forEach(([inputId,outputId])=>{
      const input=$(`#${inputId}`),output=$(`#${outputId}`);input.addEventListener("input",()=>{output.value=input.value;output.textContent=input.value;renderTownTerrainOverlay();});
    });
    $("#terrain-brush-shape").addEventListener("change",renderTownTerrainOverlay);
    $("#terrain-grid-toggle").addEventListener("change",renderTownEditorHandles);
    $("#terrain-height-toggle").addEventListener("change",renderTownEditorHandles);
    $("#terrain-export").addEventListener("click",event=>{event.stopPropagation();exportTownEditorLayout();});
    $("#terrain-import").addEventListener("click",event=>{event.stopPropagation();$("#terrain-import-file").click();});
    $("#terrain-import-file").addEventListener("change",async event=>{await importTownEditorLayout(event.target.files?.[0]);event.target.value="";});
    $("#terrain-clear-edits").addEventListener("click",event=>{event.stopPropagation();clearTownTerrainEdits();});
    $$('[data-town-add]').forEach(button=>button.addEventListener("click",event=>{event.stopPropagation();addTownDecor(button.dataset.townAdd);}));
    $("#town-npc-add").addEventListener("click",event=>{event.stopPropagation();addTownNpcEntity($("#town-npc-select").value);});
    [["town-npc-x",entity=>{entity.x=Number($("#town-npc-x").value);}], ["town-npc-y",entity=>{entity.y=Number($("#town-npc-y").value);}], ["town-npc-behavior",entity=>{entity.behavior=$("#town-npc-behavior").value;}], ["town-npc-facing",entity=>{entity.facing=$("#town-npc-facing").value;}], ["town-npc-collision",entity=>{entity.collision=$("#town-npc-collision").checked;}], ["town-npc-visible",entity=>{entity.visible=$("#town-npc-visible").checked;}], ["town-npc-locked",entity=>{entity.locked=$("#town-npc-locked").checked;}]].forEach(([id,mutator])=>$("#"+id).addEventListener("change",()=>mutateSelectedTownNpc(mutator)));
    $("#town-landmark-add").addEventListener("click",event=>{event.stopPropagation();addTownLandmark($("#town-landmark-select").value);});
    $("#town-reroll-terrain").addEventListener("click",event=>{event.stopPropagation();regenerateFoundedTerrain();});
    $("#asset-browser-close").addEventListener("click",toggleAssetDock);
    $("#asset-search").addEventListener("input",()=>{assetBrowserPage=0;renderAssetBrowser();});
    $("#asset-pack-filter").addEventListener("change",()=>{assetBrowserPage=0;renderAssetBrowser();});
    $("#asset-kind-filter").addEventListener("change",()=>{assetBrowserPage=0;renderAssetBrowser();});
    $("#asset-sort").addEventListener("change",()=>{assetBrowserPage=0;renderAssetBrowser();});
    $("#asset-usable-only").addEventListener("change",()=>{assetBrowserPage=0;renderAssetBrowser();});
    $("#asset-clear-filters").addEventListener("click",()=>{$("#asset-search").value="";$("#asset-pack-filter").value="";$("#asset-kind-filter").value="";$("#asset-sort").value="recommended";$("#asset-usable-only").checked=true;assetBrowserCategory="all";assetBrowserPage=0;renderAssetBrowser();});
    $("#asset-selected-favorite").addEventListener("click",()=>toggleAssetFavorite(assetBrowserSelected?.key));
    $("#asset-browser-grid").addEventListener("keydown",handleAssetGridKeydown);
    $("#asset-page-prev").addEventListener("click",()=>{assetBrowserPage=Math.max(0,assetBrowserPage-1);renderAssetBrowser();});
    $("#asset-page-next").addEventListener("click",()=>{assetBrowserPage+=1;renderAssetBrowser();});
    $("#asset-variant-select").addEventListener("change",()=>{const next=assetBrowserSelected?.group.find(candidate=>candidate.key===$("#asset-variant-select").value);if(next)selectBrowserAsset(next);});
    ["asset-crop-x","asset-crop-y","asset-crop-w","asset-crop-h"].forEach(id=>$("#"+id).addEventListener("input",()=>updateAssetCropPreview(false)));
    $("#asset-display-w").addEventListener("change",()=>syncAssetDisplayRatio("width"));
    $("#asset-display-h").addEventListener("change",()=>syncAssetDisplayRatio("height"));
    $("#asset-animate").addEventListener("change",()=>updateAssetCropPreview(true));
    $("#asset-reset-crop").addEventListener("click",resetBrowserCatalogCrop);
    $("#asset-use-grid-cell").addEventListener("click",useBrowserGridCell);
    $("#asset-trim-alpha").addEventListener("click",trimBrowserAssetTransparency);
    $("#asset-place-button").addEventListener("click",placeBrowserAsset);
    $("#town-duplicate-item").addEventListener("click",event=>{event.stopPropagation();duplicateTownEditorItem();});
    $("#town-delete-item").addEventListener("click",event=>{event.stopPropagation();deleteTownEditorItem();});
    $("#town-reset-layout").addEventListener("click",event=>{event.stopPropagation();resetTownEditorLayout();});
    $("#town-map").addEventListener("pointerdown",beginTownTerrainPaint,{capture:true,passive:false});
    $("#town-map").addEventListener("pointerup",handleTownClickMove);
    $("#town-map").addEventListener("pointermove",updateTownTerrainHover,{passive:true});
    $("#town-map").addEventListener("pointerleave",()=>{townTerrainHoverPoint=null;const preview=$(".terrain-brush-preview");if(preview)preview.style.display="none";});
    $("#town-map").addEventListener("contextmenu",event=>{if(townEditMode&&townTerrainTool)event.preventDefault();});
    window.addEventListener("pointermove",moveTownTerrainPaint,{passive:false});
    window.addEventListener("pointerup",finishTownTerrainPaint);
    window.addEventListener("pointercancel",finishTownTerrainPaint);
    window.addEventListener("pointermove",moveTownEditorDrag,{passive:false});
    window.addEventListener("pointermove",moveRoomEditorDrag,{passive:false});
    window.addEventListener("pointerup",finishTownEditorDrag);
    window.addEventListener("pointerup",finishRoomEditorDrag);
    window.addEventListener("pointercancel",finishTownEditorDrag);
    window.addEventListener("pointercancel",finishRoomEditorDrag);
    $("#scene-prev").addEventListener("click", () => moveInsideLocation(-1));
    $("#scene-next").addEventListener("click", () => moveInsideLocation(1));
    $("#scene-inspect").addEventListener("click", inspectCurrentScene);
    $("#location-scene").addEventListener("pointerup",handleInteriorClickMove);
    $("#room-edit-toggle").addEventListener("click",event=>{
      event.stopPropagation();roomEditMode=!roomEditMode;roomEditorDrag=null;
      $("#room-edit-toggle").textContent=roomEditMode?"✓ Done Editing":"✥ Edit Room";
      $("#room-edit-palette").classList.toggle("hidden",!roomEditMode);
      if(roomEditMode)openAssetBrowser("room");else{closeAssetBrowser();roomEditorSelection=null;persistCurrentInteriorLayout();}
      renderInteriorNpcEntities();
      renderRoomEditorHandles();
      renderActions(state.currentLocation);
    });
    $("#minigame-close").addEventListener("click", cancelMinigame);
    $("#minigame-primary").addEventListener("click", minigameAction);
    $("#result-continue").addEventListener("click", () => {
      hide("result-overlay");
      if (pendingDayEnd) {
        pendingDayEnd = false;
        showDayEnd();
      } else $("#town-map").focus({ preventScroll: true });
    });
    $("#next-day-button").addEventListener("click", nextDay);
    $("#next-cycle-button").addEventListener("click", beginNextCycle);
    [["touch-up","arrowup"],["touch-down","arrowdown"],["touch-left","arrowleft"],["touch-right","arrowright"]].forEach(([id,key]) => {
      const button = $(`#${id}`);
      const start = event => { event.preventDefault(); clearAutoMovement(isVisible("location-sheet")?"interior":"town");heldKeys.add(key); $(isVisible("location-sheet")?"#location-scene":"#town-map").focus({ preventScroll:true }); };
      const stop = event => { event.preventDefault(); heldKeys.delete(key); };
      button.addEventListener("pointerdown", start);
      button.addEventListener("pointerup", stop);
      button.addEventListener("pointercancel", stop);
      button.addEventListener("pointerleave", stop);
    });
    $("#touch-enter").addEventListener("click", enterNearbyLocation);
    $$('[data-close]').forEach(button => button.addEventListener("click", () => button.dataset.close==="location-sheet"?closeLocationSheet():hide(button.dataset.close)));
    document.addEventListener("keydown", handleKeydown);
    document.addEventListener("keyup", handleKeyup);
    $("#start-screen .start-copy").addEventListener("focusin",event=>{
      // The title menu owns its vertical overflow on constrained desktop
      // viewports. Keyboard focus must reveal its own control instead of
      // leaving save management below the clipped card boundary.
      event.target.scrollIntoView({block:"nearest",inline:"nearest"});
    });
    window.addEventListener("blur", () => {heldKeys.clear();gamepadMove={x:0,y:0,magnitude:0};});
    window.addEventListener("resize",()=>{updateTownCamera();updateInteriorViewport();});
    document.addEventListener("pointerdown", startAudio, { once: true });
    window.addEventListener("gamepadconnected", startAudio);
    window.addEventListener("gamepaddisconnected",event=>{if(event.gamepad.index===activeGamepadIndex){activeGamepadIndex=null;gamepadButtons=[];gamepadMove={x:0,y:0,magnitude:0};}});
  }

  function boot() {
    state = loadState();
    sanitizeTownTerrainLayout();
    loadAssetLibraryPrefs();
    populateTownNpcSelect();
    createLocationMarkers();
    updateFoundingTools();
    createTownResidents();
    renderTownNpcEntities();
    setupTabs();
    bindEvents();
    renderAll();
    updateSaveManagerUI();
    requestAnimationFrame(pollGamepad);
    requestAnimationFrame(townLoop);
  }

  boot();
})();
