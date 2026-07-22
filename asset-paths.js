(function () {
  "use strict";

  const PREFIXES = Object.freeze([
    ["assets/Main Character/", "assets/characters/Main Character/"],
    ["assets/NPCs/", "assets/characters/NPCs/"],
    ["assets/Topdown Monsters Part 1/", "assets/characters/Topdown Monsters Part 1/"],
    ["assets/Baby Dragon/", "assets/characters/Baby Dragon/"],
    ["assets/Bots and Bolts 2D robot/", "assets/characters/Bots and Bolts 2D robot/"],
    ["assets/quirky npcs/", "assets/characters/quirky npcs/"],
    ["assets/More Tilesets/", "assets/Tilesets/"],
    ["assets/Ranch Stuff/", "assets/Tilesets/Ranch Stuff/"],
    ["assets/Cafe Assets/", "assets/Tilesets/Cafe Assets/"],
    ["assets/Farm Assets/", "assets/Tilesets/Farm Assets/"],
    ["assets/Haunted Mansion/", "assets/Tilesets/Haunted Mansion/"],
    ["assets/Modern Laboratory Assets/", "assets/Tilesets/Modern Laboratory Assets/"],
    ["assets/Modern Bar & Nightclub/", "assets/Tilesets/Modern Bar & Nightclub/"],
    ["assets/Modern Restaurant/", "assets/Tilesets/Modern Restaurant/"],
    ["assets/haydeos/Fantasy Houses Tileset/", "assets/Tilesets/Fantasy Houses Tileset/"],
    ["assets/haydeos/Great War RPG Maker Houses/", "assets/Tilesets/Great War RPG Maker Houses/"]
  ]);

  function resolveAssetPath(value) {
    if (typeof value !== "string" || !value.includes("assets/")) return value;
    let resolved = value;
    for (const [oldPrefix, newPrefix] of PREFIXES) resolved = resolved.split(oldPrefix).join(newPrefix);
    return resolved;
  }

  window.resolveAssetPath = resolveAssetPath;
  window.ASSET_PATH_PREFIXES = PREFIXES;

  function wrapProperty(prototype, property) {
    const descriptor = Object.getOwnPropertyDescriptor(prototype, property);
    if (!descriptor || !descriptor.configurable || !descriptor.set) return;
    Object.defineProperty(prototype, property, {
      configurable: descriptor.configurable,
      enumerable: descriptor.enumerable,
      get: descriptor.get,
      set(value) { descriptor.set.call(this, resolveAssetPath(value)); }
    });
  }

  wrapProperty(HTMLImageElement.prototype, "src");
  wrapProperty(HTMLSourceElement.prototype, "src");
  wrapProperty(HTMLMediaElement.prototype, "src");
  wrapProperty(CSSStyleDeclaration.prototype, "background");
  wrapProperty(CSSStyleDeclaration.prototype, "backgroundImage");

  const nativeSetAttribute = Element.prototype.setAttribute;
  Element.prototype.setAttribute = function (name, value) {
    const lower = String(name).toLowerCase();
    if (lower === "src" || lower === "poster" || lower === "style") value = resolveAssetPath(value);
    return nativeSetAttribute.call(this, name, value);
  };
})();
