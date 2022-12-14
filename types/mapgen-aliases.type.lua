---@diagnostic disable: codestyle-check
---https://github.com/sumneko/lua-language-server/wiki

--- In a game, a certain number of these must be set to tell core mapgens which of the game's nodes are to be used for core mapgen generation.
---@alias MapgenAliasesNonV6
---| '"mapgen_stone"'
---| '"mapgen_water_source"'
---| '"mapgen_river_water_source"'
---| '"mapgen_river_water_source"' # is required for mapgens with sloping rivers where it is necessary to have a river liquid node with a short `liquid_range` and `liquid_renewable = false` to avoid flooding.
---| '"mapgen_lava_source"' # Optional, Fallback lava node used if cave liquids are not defined in biome definitions. Deprecated, define cave liquids in biome definitions instead.
---| '"mapgen_cobble"' # Optional, Fallback node used if dungeon nodes are not defined in biome definitions. Deprecated, define dungeon nodes in biome definitions instead.

--- In a game, a certain number of these must be set to tell core mapgens which of the game's nodes are to be used for core mapgen generation.
---@alias MapgenAliasesV6
---| '"mapgen_stone"'
---| '"mapgen_water_source"'
---| '"mapgen_lava_source"'
---| '"mapgen_dirt"'
---| '"mapgen_dirt_with_grass"'
---| '"mapgen_sand"'
---| '"mapgen_tree"'
---| '"mapgen_leaves"'
---| '"mapgen_apple"'
---| '"mapgen_cobble"'
---| '"mapgen_gravel"' # Optional, (falls back to stone)
---| '"mapgen_desert_stone"' # Optional, (falls back to stone)
---| '"mapgen_desert_sand"' # Optional, (falls back to sand)
---| '"mapgen_dirt_with_snow"' # Optional, (falls back to dirt_with_grass)
---| '"mapgen_snowblock"' # Optional, (falls back to dirt_with_grass)
---| '"mapgen_snow"' # Optional, (not placed if missing)
---| '"mapgen_ice"' # Optional, (falls back to water_source)
---| '"mapgen_jungletree"' # Optional, (falls back to tree)
---| '"mapgen_jungleleaves"' # Optional, (falls back to leaves)
---| '"mapgen_junglegrass"' # Optional, (not placed if missing)
---| '"mapgen_pine_tree"' # Optional, (falls back to tree)
---| '"mapgen_pine_needles"' # Optional, (falls back to leaves)
---| '"mapgen_stair_cobble"' # Optional, (falls back to cobble)
---| '"mapgen_mossycobble"' # Optional, (falls back to cobble)
---| '"mapgen_stair_desert_stone"' # Optional, (falls backto desert_stone)
