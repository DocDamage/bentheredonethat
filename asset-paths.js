/* Shared asset-path aliases for the browser runtime and Node-based validators. */
(function (root, factory) {
  const api = factory();
  if (typeof module === "object" && module.exports) module.exports = api;
  if (!root || !root.document) return;

  root.resolveAssetPath = api.resolveAssetPath;
  root.ASSET_PATH_PREFIXES = api.ASSET_PATH_PREFIXES;

  function wrapProperty(prototype, property) {
    const descriptor = Object.getOwnPropertyDescriptor(prototype, property);
    if (!descriptor || !descriptor.configurable || !descriptor.set) return;
    Object.defineProperty(prototype, property, {
      configurable: descriptor.configurable,
      enumerable: descriptor.enumerable,
      get: descriptor.get,
      set(value) { descriptor.set.call(this, api.resolveAssetPath(value)); }
    });
  }

  wrapProperty(root.HTMLImageElement.prototype, "src");
  wrapProperty(root.HTMLSourceElement.prototype, "src");
  wrapProperty(root.HTMLMediaElement.prototype, "src");
  wrapProperty(root.CSSStyleDeclaration.prototype, "background");
  wrapProperty(root.CSSStyleDeclaration.prototype, "backgroundImage");

  const nativeSetAttribute = root.Element.prototype.setAttribute;
  root.Element.prototype.setAttribute = function (name, value) {
    const lower = String(name).toLowerCase();
    if (lower === "src" || lower === "poster" || lower === "style") value = api.resolveAssetPath(value);
    return nativeSetAttribute.call(this, name, value);
  };
})(typeof window === "undefined" ? null : window, function () {
  "use strict";

  const ASSET_PATH_PREFIXES = Object.freeze([
    ["assets/Main Character/", "assets/characters/Main Character/"],
    ["assets/NPCs/", "assets/characters/NPCs/"],
    ["assets/Topdown Monsters Part 1/", "assets/characters/Topdown Monsters Part 1/"],
    ["assets/Baby Dragon/", "assets/characters/Baby Dragon/"],
    ["assets/Bots and Bolts 2D robot/", "assets/characters/Bots and Bolts 2D robot/"],
    ["assets/quirky npcs/", "assets/characters/quirky npcs/"],
    ["assets/haydeos/High Fantasy Heroes/", "assets/characters/High Fantasy Heroes/"],
    ["assets/More Tilesets/", "assets/Tilesets/"],
    ["assets/Ranch Stuff/", "assets/Tilesets/Ranch Stuff/"],
    ["assets/Cafe Assets/", "assets/Tilesets/Cafe Assets/"],
    ["assets/Farm Assets/", "assets/Tilesets/Farm Assets/"],
    ["assets/Haunted Mansion/", "assets/Tilesets/Haunted Mansion/"],
    ["assets/Modern Laboratory Assets/", "assets/Tilesets/Modern Laboratory Assets/"],
    ["assets/Modern Bar & Nightclub/", "assets/Tilesets/Modern Bar & Nightclub/"],
    ["assets/Modern Restaurant/", "assets/Tilesets/Modern Restaurant/"],
    ["assets/haydeos/Fantasy Houses Tileset/", "assets/Tilesets/Fantasy Houses Tileset/"],
    ["assets/haydeos/Great War RPG Maker Houses/", "assets/Tilesets/Great War RPG Maker Houses/"],
    ["assets/haydeos/Ferrum Junkyard Heroes/", "assets/Tilesets/Ferrum Junkyard Heroes/"],
  ]);

  function resolveAssetPath(value) {
    if (typeof value !== "string" || !value.includes("assets/")) return value;
    let resolved = value;
    for (const [oldPrefix, newPrefix] of ASSET_PATH_PREFIXES) resolved = resolved.split(oldPrefix).join(newPrefix);
    return resolved;
  }

  return Object.freeze({ ASSET_PATH_PREFIXES, resolveAssetPath });
});
