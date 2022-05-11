
local a = 1664525
local c = 1013904223
local M = 0x80000000
local state = settings.startup["base-item-values-seed"].value

-- Returns an integer from 0 to N - 1
function rand(N)
    state = (a * state + c) % M
    return (math.floor( N*state / M ))
end


--data.lua

require("prototypes.tiers")
require("prototypes.cross_city_trades")
require("prototypes.power")
require("prototypes.science")
require("prototypes.map-gen-presets")
require("prototypes.mapgen")
require("prototypes.log1")
require("prototypes.malls")
require("prototypes.productivity")
require("prototypes.research")
require("prototypes.keybindings")

data.raw["character"]["character"].reach_distance = 25
data.raw["beacon"]["beacon"].supply_area_distance = 25
data.raw["beacon"]["beacon"].allowed_effects = {"consumption", "speed", "productivity", "pollution"}
data.raw["assembling-machine"]["assembling-machine-1"].allowed_effects = {"consumption", "speed", "productivity", "pollution"}
data.raw["module"]["productivity-module"  ].effect.productivity.bonus = 0.02
data.raw["module"]["productivity-module-2"].effect.productivity.bonus = 0.03
data.raw["module"]["productivity-module-3"].effect.productivity.bonus = 0.05
data.raw["module"]["productivity-module"  ].effect.speed.bonus = -0.1
--data.raw["module"]["productivity-module-2"].effect.speed.bonus = -0.15
data.raw["module"]["productivity-module-3"].effect.speed.bonus = -0.25

local styles = data.raw["gui-style"].default

styles["tro_trades_list"] = {
    type = "scroll_pane_style",
    horizontally_stretchable = "on"
}

styles["tro_trade_row"] = {
    type = "frame_style",
    horizontally_stretchable = "on",
}

styles["tro_trade_row_flow"] = {
  type = "horizontal_flow_style",
  horizontally_stretchable = "on",
  vertical_align = "center"
}

-- trade menu shortcut
data:extend({
  {
    type = "shortcut",
    name = "trades",
    localised_name = { "tro.shortcut_name"},
    order = "a",
    action = "lua",
    style = "green",
    icon = {
      filename = "__Transportorio__/graphics/icons/t.png",
      flags = {
        "icon"
      },
      priority = "extra-high-no-scale",
      scale = 2,
      size = 64
    },
    small_icon = {
      filename = "__Transportorio__/graphics/icons/t.png",
      flags = {
        "icon"
      },
      priority = "extra-high-no-scale",
      scale = 1,
      size = 64
    },
    disabled_small_icon = {
      filename = "__Transportorio__/graphics/icons/t.png",
      flags = {
        "icon"
      },
      priority = "extra-high-no-scale",
      scale = 1,
      size = 64
    },
  },
})

