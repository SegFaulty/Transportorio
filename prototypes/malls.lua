require("prototypes.log1")
  
  
  mall_items = {}
  
  mall_items.t1 =
  {
  "transport-belt",
  "underground-belt",
  "splitter",
  "loader",
  "wooden-chest",
  "inserter",
  "long-handed-inserter",
  "radar",
  "repair-pack",
  }
  mall_items.t2 =
  {
  "rail",
  "train-stop",
  "rail-signal",
  "rail-chain-signal",
  "locomotive",
  "cargo-wagon",
  "fast-inserter",
  }
  mall_items.t3 =
  {
  "pipe",
  "pipe-to-ground",
  "pump",
  "storage-tank",
  "fluid-wagon",
  }
  mall_items.t4 =
  {
  "fast-transport-belt",
  "fast-underground-belt",
  "fast-splitter",
  "fast-loader",
  "iron-chest",
  "fast-inserter",
  "filter-inserter",
  }
  
  mall_items.t5 =
  {
  "small-lamp",
  "red-wire",
  "green-wire",
  "arithmetic-combinator",
  "decider-combinator",
  "constant-combinator",
  "programmable-speaker",
  "medium-electric-pole",
  "big-electric-pole",
  }
  mall_items.t6 =
  {
  "submachine-gun",
  "shotgun",
  "heavy-armor",
  "gun-turret",
  "car",
  "tank",
  "grenade",
  "poison-capsule",
  "spidertron",
  "spidertron-remote",
  }
  
  mall_items.t7 =
  {
  "landfill",
  "concrete",
  "hazard-concrete",
  "refined-concrete",
  "refined-hazard-concrete",
  "cliff-explosives",
  }
  mall_items.t8 =
  {
  "modular-armor",
  "solar-panel-equipment",
  "exoskeleton-equipment",
  "night-vision-equipment",
  "battery-equipment",
  "personal-roboport-equipment",
  "energy-shield-equipment",
  "belt-immunity-equipment",
  "construction-robot",
  "power-armor",
  }
  mall_items.t9 =
  {
  "express-transport-belt",
  "express-underground-belt",
  "express-splitter",
  "express-loader",
  "steel-chest",
  "stack-inserter",
  "stack-filter-inserter"
  }
  mall_items.t10 =
  {
  "speed-module-2",
  "speed-module-3",
  "productivity-module-2",
  "productivity-module-3",
  }
  mall_items.t11 =
  {
  "roboport",
  "logistic-chest-active-provider",
  "logistic-chest-passive-provider",
  "logistic-chest-storage",
  "logistic-chest-buffer",
  "logistic-chest-requester",
  }
  mall_items.t12 =
  {
  "power-armor-mk2",
  "fusion-reactor-equipment",
  "battery-mk2-equipment",
  "personal-roboport-mk2-equipment",
  "energy-shield-mk2-equipment",
  "nuclear-fuel",
  }


  mall_cost = {}
  
  mall_cost.t1 = {0.5,2.5,2.5,2.5,2.5,2.5,2.5,25,2.5} --yellow		from t1
  mall_cost.t2 = {1,20,10,10,100,100,50,50} --rail		from s1
  
  mall_cost.t3 = {2,2,4,40,40} --pipe		from t2
  mall_cost.t4 = {5,25,25,25,25,25,25} --red belt	from s2
  mall_cost.t5 = {5,2.5,2.5,5,5,5,5,5,10} --circuit	from t3
  mall_cost.t6 = {5,5,5,15,50,250,2,5,1000,5} --guns		from s3
  
  mall_cost.t7 = {2,0.5,0.5,5,5,2,2,2} --landscaping	from t4
  mall_cost.t8 = {100,20,50,50,50,50,50,50,20,2000,10} --eq	from S4
  mall_cost.t9 = {5,25,25,25,25,25,25} --blue belts	from t5
  mall_cost.t10 = {20,250,20,250} --modules		from S5
  mall_cost.t11 = {25,5,5,5,5,5} --roboports	from t6
  mall_cost.t12 = {500,100,50,50,50,10} --mk2 eq		from S6
    
  for i=1,#desired_items.t1,1 do
  for z=1,#mall_items.t1,1 do
  if  desired_items.t1[i] ~= mall_items.t1[z] and desired_items.t1[i]~= "coal" then
  for r=0,21,1 do
  local rate = mall_cost.t1[z]*sci_cost[1]/item_cost[1][i] *math.pow( math.exp(math.log(4)/21) ,r)/2
  data:extend({
  {
    type = "recipe",
    name = "mall-1-"..i.."-1-"..z.."-"..r,
    icon = "__TradeRouteOverhaul__/graphics/mall-1-"..i.."-1-"..z..".png",
    icon_size = 64, icon_mipmaps = 4,
    energy_required = .1,
    enabled = true,
	hidden = true,
	subgroup = "tier-1",
    ingredients =
    {{desired_items.t1[i], math.floor(rate)+1 }},
    results = {{mall_items.t1[z], 1 }},
  allow_decomposition =false,
  allow_as_intermediate=false,
  allow_intermediates = false
  }
  })
  table.insert( can_productivity_module, "mall-1-"..i.."-1-"..z.."-"..r )
  end --r
  end --if
  end --end mz do
  end -- end DI do#
 
 
  for i=1,#desired_items.t2,1 do
  for z=1,#mall_items.t3,1 do
  if  desired_items.t2[i] ~= mall_items.t3[z] then
  for r=0,21,1 do
  local rate = mall_cost.t3[z]*sci_cost[2]/item_cost[2][i] *math.pow( math.exp(math.log(4)/21) ,r)/2
  data:extend({
  {
    type = "recipe",
    name = "mall-2-"..i.."-3-"..z.."-"..r,
    icon = "__TradeRouteOverhaul__/graphics/mall-2-"..i.."-3-"..z..".png",
    icon_size = 64, icon_mipmaps = 4,
    energy_required = .1,
    enabled = true,
	hidden = true,
	subgroup = "tier-2",
    ingredients =
    {{desired_items.t2[i], math.floor(rate)+1 }},
    results = {{mall_items.t3[z], 1 }},
  allow_decomposition =false,
  allow_as_intermediate=false,
  allow_intermediates = false
  }
  })
  table.insert( can_productivity_module, "mall-2-"..i.."-3-"..z.."-"..r )
  end --r
  end --if
  end --end mz do
  end -- end DI do#
 
 
  
  for i=1,#desired_items.t3,1 do
  for z=1,#mall_items.t5,1 do
  if  desired_items.t3[i] ~= mall_items.t5[z] then
  for r=0,21,1 do
  local rate = mall_cost.t5[z]*sci_cost[3]/item_cost[3][i] *math.pow( math.exp(math.log(4)/21) ,r)/2
  data:extend({
  {
    type = "recipe",
    name = "mall-3-"..i.."-5-"..z.."-"..r,
    icon = "__TradeRouteOverhaul__/graphics/mall-3-"..i.."-5-"..z..".png",
    icon_size = 64, icon_mipmaps = 4,
    energy_required = .1,
    enabled = true,
	hidden = true,
	subgroup = "tier-3",
    ingredients =
    {{desired_items.t3[i], math.floor(rate)+1 }},
    results = {{mall_items.t5[z], 1 }},
  allow_decomposition =false,
  allow_as_intermediate=false,
  allow_intermediates = false
  }
  })
  table.insert( can_productivity_module, "mall-3-"..i.."-5-"..z.."-"..r )
  end --r
  end --if
  end --end mz do
  end -- end DI do#
 
 
 
  for i=1,#desired_items.t4,1 do
  for z=1,#mall_items.t7,1 do
  if  desired_items.t4[i] ~= mall_items.t7[z] then
  for r=0,21,1 do
  local rate = mall_cost.t7[z]*sci_cost[4]/item_cost[4][2*i] *math.pow( math.exp(math.log(4)/21) ,r)/2
  data:extend({
  {
    type = "recipe",
    name = "mall-4-"..(2*i).."-7-"..z.."-"..r,
    icon = "__TradeRouteOverhaul__/graphics/mall-4-"..(2*i).."-7-"..z..".png",
    icon_size = 64, icon_mipmaps = 4,
    energy_required = .1,
    enabled = true,
	hidden = true,
	subgroup = "tier-4",
    ingredients =
    {{desired_items.t4[i], math.floor(rate)+1 }},
    results = {{mall_items.t7[z], 1 }},
  allow_decomposition =false,
  allow_as_intermediate=false,
  allow_intermediates = false
  }
  })
  table.insert( can_productivity_module, "mall-4-"..(2*i).."-7-"..z.."-"..r )
  end --r
  end --if
  end --end mz do
  end -- end DI do#
 
 
  
  for i=1,#desired_items.t5,1 do
  for z=1,#mall_items.t9,1 do
  if  desired_items.t5[i] ~= mall_items.t9[z] then
  for r=0,21,1 do
  local rate = mall_cost.t9[z]*sci_cost[5]/item_cost[5][i] *math.pow( math.exp(math.log(4)/21) ,r)/2
  data:extend({
  {
    type = "recipe",
    name = "mall-5-"..i.."-9-"..z.."-"..r,
    icon = "__TradeRouteOverhaul__/graphics/mall-5-"..i.."-9-"..z..".png",
    icon_size = 64, icon_mipmaps = 4,
    energy_required = .1,
    enabled = true,
	hidden = true,
	subgroup = "tier-5",
    ingredients =
    {{desired_items.t5[i], math.floor(rate)+1 }},
    results = {{mall_items.t9[z], 1 }},
  allow_decomposition =false,
  allow_as_intermediate=false,
  allow_intermediates = false
  }
  })
  table.insert( can_productivity_module, "mall-5-"..i.."-9-"..z.."-"..r )
  end --r
  end --if
  end --end mz do
  end -- end DI do#
 
  
  for i=1,#desired_items.t6,1 do
  for z=1,#mall_items.t11,1 do
  if  desired_items.t6[i] ~= mall_items.t11[z] then
  for r=0,21,1 do
  local rate = mall_cost.t11[z]*sci_cost[6]/item_cost[6][i] *math.pow( math.exp(math.log(4)/21) ,r)/2
  data:extend({
  {
    type = "recipe",
    name = "mall-6-"..i.."-11-"..z.."-"..r,
    icon = "__TradeRouteOverhaul__/graphics/mall-6-"..i.."-11-"..z..".png",
    icon_size = 64, icon_mipmaps = 4,
    energy_required = .1,
    enabled = true,
	hidden = true,
	subgroup = "tier-6",
    ingredients =
    {{desired_items.t6[i], math.floor(rate)+1 }},
    results = {{mall_items.t11[z], 1 }},
  allow_decomposition =false,
  allow_as_intermediate=false,
  allow_intermediates = false
  }
  })
  table.insert( can_productivity_module, "mall-6-"..i.."-11-"..z.."-"..r )
  end --r
  end --if
  end --end mz do
  end -- end DI do#


  for i=1,#mall_items.t2,1 do
  for r=0,21,1 do
  local rate = mall_cost.t2[i]*sci_cost[1] /sci_cost[1] *math.pow( math.exp(math.log(4)/21) ,r)/2
  data:extend({
  {
    type = "recipe",
    name = "mall-7-1-2-"..i.."-"..r,
    icon = "__TradeRouteOverhaul__/graphics/mall-7-1-2-"..i..".png",
    icon_size = 64, icon_mipmaps = 4,
    energy_required = .1,
    enabled = true,
	hidden = true,
	subgroup = "tier-1",
    ingredients =
    {{"automation-science-pack", math.floor(rate)+1 }},
    results = {{mall_items.t2[i], 1 }},
  allow_decomposition =false,
  allow_as_intermediate=false,
  allow_intermediates = false
  }
  })
  table.insert( can_productivity_module, "mall-7-1-2-"..i.."-"..r )
  end --r
  end -- end i do
  
  
  for i=1,#mall_items.t4,1 do
  for r=0,21,1 do
  local rate = mall_cost.t4[i]*sci_cost[2] /sci_cost[2] *math.pow( math.exp(math.log(4)/21) ,r)/2
  data:extend({
  {
    type = "recipe",
    name = "mall-7-2-4-"..i.."-"..r,
    icon = "__TradeRouteOverhaul__/graphics/mall-7-2-4-"..i..".png",
    icon_size = 64, icon_mipmaps = 4,
    energy_required = .1,
    enabled = true,
	hidden = true,
	subgroup = "tier-2",
    ingredients =
    {{"logistic-science-pack", math.floor(rate)+1 }},
    results = {{mall_items.t4[i], 1 }},
  allow_decomposition =false,
  allow_as_intermediate=false,
  allow_intermediates = false
  }
  })
  table.insert( can_productivity_module, "mall-7-2-4-"..i.."-"..r )
  end --r
  end -- end i do
  
  for i=1,#mall_items.t6-2,1 do
  for r=0,21,1 do
  local rate = mall_cost.t6[i]*sci_cost[3] /sci_cost[3] *math.pow( math.exp(math.log(4)/21) ,r)/2
  data:extend({
  {
    type = "recipe",
    name = "mall-7-3-6-"..i.."-"..r,
    icon = "__TradeRouteOverhaul__/graphics/mall-7-3-6-"..i..".png",
    icon_size = 64, icon_mipmaps = 4,
    energy_required = .1,
    enabled = true,
	hidden = true,
	subgroup = "tier-3",
    ingredients =
    {{"military-science-pack", math.floor(rate)+1 }},
    results = {{mall_items.t6[i], 1 }},
  allow_decomposition =false,
  allow_as_intermediate=false,
  allow_intermediates = false
  }
  })
  table.insert( can_productivity_module, "mall-7-3-6-"..i.."-"..r )
  end --r
  end -- end i do
  
  for i=9,#mall_items.t6,1 do
  for r=0,21,1 do
  local rate = mall_cost.t6[i]*sci_cost[3] /sci_cost[3] *math.pow( math.exp(math.log(4)/21) ,r)/2
  data:extend({
  {
    type = "recipe",
    name = "mall-7-3-6-"..i.."-"..r,
    icon = "__TradeRouteOverhaul__/graphics/mall-7-7-14-"..(i-7)..".png",
    icon_size = 64, icon_mipmaps = 4,
    energy_required = .1,
    enabled = true,
	hidden = true,
	subgroup = "tier-3",
    ingredients =    {
	{"space-science-pack", math.floor(rate)+1 }
	},
    results = {{mall_items.t6[i], 1 }},
  allow_decomposition =false,
  allow_as_intermediate=false,
  allow_intermediates = false
  }
  })
  table.insert( can_productivity_module, "mall-7-3-6-"..i.."-"..r )
  end --r
  end -- end i do

  for i=1,#mall_items.t8,1 do
  for r=0,21,1 do
  local rate = mall_cost.t8[i]*sci_cost[4] /sci_cost[4] *math.pow( math.exp(math.log(4)/21) ,r)/2
  data:extend({
  {
    type = "recipe",
    name = "mall-7-4-8-"..i.."-"..r,
    icon = "__TradeRouteOverhaul__/graphics/mall-7-4-8-"..i..".png",
    icon_size = 64, icon_mipmaps = 4,
    energy_required = .1,
    enabled = true,
	hidden = true,
	subgroup = "tier-4",
    ingredients =
    {{"chemical-science-pack", math.floor(rate)+1 }},
    results = {{mall_items.t8[i], 1 }},
  allow_decomposition =false,
  allow_as_intermediate=false,
  allow_intermediates = false
  }
  })
  table.insert( can_productivity_module, "mall-7-4-8-"..i.."-"..r )
  end --r
  end -- end i do

  for i=1,#mall_items.t10-1,1 do
  for r=0,21,1 do
  local rate = mall_cost.t10[i]*sci_cost[5] /sci_cost[5] *math.pow( math.exp(math.log(4)/21) ,r)/2
  data:extend({
  {
    type = "recipe",
    name = "mall-7-5-10-"..i.."-"..r,
    icon = "__TradeRouteOverhaul__/graphics/mall-7-5-10-"..i..".png",
    icon_size = 64, icon_mipmaps = 4,
    energy_required = .1,
    enabled = true,
	hidden = true,
	subgroup = "tier-5",
    ingredients =
    {{"production-science-pack", math.floor(rate)+1 }},
    results = {{mall_items.t10[i], 1 }},
  allow_decomposition =false,
  allow_as_intermediate=false,
  allow_intermediates = false
  }
  })
  table.insert( can_productivity_module, "mall-7-5-10-"..i.."-"..r )
  end --r
  end -- end i do
  
  --prod 4
  for r=0,21,1 do
  local rate = mall_cost.t10[4]*sci_cost[5] /sci_cost[5] *math.pow( math.exp(math.log(4)/21) ,r)/2
  data:extend({
  {
    type = "recipe",
    name = "mall-7-5-10-4-"..r,
    icon = "__TradeRouteOverhaul__/graphics/mall-7-7-14-1.png",
    icon_size = 64, icon_mipmaps = 4,
    energy_required = .1,
    enabled = true,
	hidden = true,
	subgroup = "tier-5",
    ingredients =    {
	{"space-science-pack", math.floor(rate)+1 }
	},
    results = {{mall_items.t10[4], 1 }},
  allow_decomposition =false,
  allow_as_intermediate=false,
  allow_intermediates = false
  }
  })
  table.insert( can_productivity_module, "mall-7-5-10-4-"..r )
  end --r
  
  

  for i=1,#mall_items.t12,1 do
  for r=0,21,1 do
  local rate = mall_cost.t12[i]*sci_cost[6] /sci_cost[6] *math.pow( math.exp(math.log(4)/21) ,r)/2
  data:extend({
  {
    type = "recipe",
    name = "mall-7-6-12-"..i.."-"..r,
    icon = "__TradeRouteOverhaul__/graphics/mall-7-6-12-"..i..".png",
    icon_size = 64, icon_mipmaps = 4,
    energy_required = .1,
    enabled = true,
	hidden = true,
	subgroup = "tier-6",
    ingredients =
    {{"utility-science-pack", math.floor(rate)+1 }},
    results = {{mall_items.t12[i], 1 }},
  allow_decomposition =false,
  allow_as_intermediate=false,
  allow_intermediates = false
  }
  })
  table.insert( can_productivity_module, "mall-7-6-12-"..i.."-"..r )
  end --r
  end -- end i do

