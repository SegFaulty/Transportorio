require("prototypes.log1")
--science recipes


for r=0,21,1 do
  
  local rate =  10*math.pow( math.exp(math.log(4)/21) ,r)/2 
  
   data:extend({
   {
    type = "recipe",
    name = "T1-Science-"..r,
    energy_required = .1,
    enabled = true,
	hidden = true,
	subgroup = "tier-1",
    ingredients =
    {
		{"stone", 10 },
		{"coal", 10 },
		{"copper-ore", 10 },
		{"iron-ore", 10 }
	},
    results ={{"automation-science-pack", math.floor(rate) }},
  allow_decomposition =false,
  allow_as_intermediate=false,
  allow_intermediates = false
  },
  })
  table.insert( can_productivity_module, "T1-Science-"..r )
  
  data:extend({
  {
    type = "recipe",
    name = "T2-Science-"..r,
    energy_required = .1,
    enabled = true,
	hidden = true,
	subgroup = "tier-2",
    ingredients =
    {
		{"copper-cable", 10 },
		{"iron-stick", 10 },
		{"stone-brick", 10 },
		{"copper-plate", 10 },
		{"iron-plate", 10 }
	},
    results ={{"logistic-science-pack", math.floor(rate) }},
  allow_decomposition =false,
  allow_as_intermediate=false,
  allow_intermediates = false
  },
  })
  table.insert( can_productivity_module, "T2-Science-"..r )
  
  data:extend({
  {
    type = "recipe",
    name = "T3-Science-"..r,
    energy_required = .1,
    enabled = true,
	hidden = true,
	subgroup = "tier-3",
    ingredients =
    {
		{"pipe", 10 },
		{"steel-plate", 10 },
		{"iron-gear-wheel", 10 },
		{"electronic-circuit", 10 },
		{"firearm-magazine", 10 },
		{"stone-wall", 10 }
	},
    results ={{"military-science-pack", math.floor(rate) }},
  allow_decomposition =false,
  allow_as_intermediate=false,
  allow_intermediates = false
  },
  })
  table.insert( can_productivity_module, "T3-Science-"..r )
  
  data:extend({
  {
    type = "recipe",
    name = "T4-Science-"..r,
    category = "crafting-with-fluid",
    energy_required = .1,
    enabled = true,
	hidden = true,
	subgroup = "tier-4",
	ingredients =
    {
      {type="item", name="plastic-bar", amount=10 },
      {type="item", name="explosives", amount=10 },
      {type="item", name="rocket-fuel", amount=10 },
      {type="fluid", name="sulfuric-acid", amount=100 },
    },
    results ={{"chemical-science-pack", math.floor(rate) }},
  allow_decomposition =false,
  allow_as_intermediate=false,
  allow_intermediates = false
  },
  })
  table.insert( can_productivity_module, "T4-Science-"..r )
  
  data:extend({
  {
    type = "recipe",
    name = "T5-Science-"..r,
    energy_required = .1,
    enabled = true,
	hidden = true,
	subgroup = "tier-5",
    ingredients =
    {
  		{"engine-unit", 10 },
  		{"advanced-circuit", 10 },
  		{"low-density-structure", 10 },
    	{"electric-engine-unit", 10 },
  		{"speed-module", 10 },
  		{"effectivity-module", 10 },
  		{"productivity-module", 10 },
	},
    results ={{"production-science-pack", math.floor(rate) }},
  allow_decomposition =false,
  allow_as_intermediate=false,
  allow_intermediates = false
  },
  })
  table.insert( can_productivity_module, "T5-Science-"..r )
  
  data:extend({
  {
    type = "recipe",
    name = "T6-Science-"..r,
    energy_required = .1,
    enabled = true,
	hidden = true,
	subgroup = "tier-6",
    ingredients =
    {
    		{"battery", 10 },
    		{"electric-engine-unit", 10 },
    		{"logistic-robot", 10 },
    		{"construction-robot", 10 },
    		{"processing-unit", 10 },
    		{"rocket-control-unit", 10 },
    		{"atomic-bomb", 10 },
	},
    results ={{"utility-science-pack", math.floor(rate) }},
  allow_decomposition =false,
  allow_as_intermediate=false,
  allow_intermediates = false
  },	
  })
  table.insert( can_productivity_module, "T6-Science-"..r )
  
   data:extend({
   {
    type = "recipe",
    name = "satellite-"..r,
    energy_required = .1,
    enabled = true,
	hidden = true,
	subgroup = "tier-6",
    ingredients =
    {
		{"automation-science-pack", math.floor(10000/rate)+1 },
		{"logistic-science-pack", math.floor(10000/rate)+1 },
		{"military-science-pack", math.floor(10000/rate)+1 },
		{"chemical-science-pack", math.floor(10000/rate)+1 },
		{"production-science-pack", math.floor(10000/rate)+1 },
		{"utility-science-pack", math.floor(10000/rate)+1 }
	},
    results ={{"satellite", 1 }},
  allow_decomposition =false,
  allow_as_intermediate=false,
  allow_intermediates = false
  },
  })
  table.insert( can_productivity_module, "satellite-"..r )
  
   data:extend({
   {
    type = "recipe",
    name = "s-1-3-5-"..r,
    icon = "__Transportorio__/graphics/s-1-3-5.png",
    icon_size = 64, icon_mipmaps = 4,
    energy_required = .1,
    enabled = true,
	hidden = true,
	subgroup = "tier-6",
    ingredients =
    {
		{"automation-science-pack", math.floor(30000/rate)+1 },
		{"military-science-pack",   math.floor(30000/rate)+1 },
		{"production-science-pack", math.floor(30000/rate)+1 }
	},
    results ={{"satellite", 1 }},
  allow_decomposition =false,
  allow_as_intermediate=false,
  allow_intermediates = false
  },
  })
  table.insert( can_productivity_module, "s-1-3-5-"..r )
  
   data:extend({
   {
    type = "recipe",
    name = "s-1-3-6-"..r,
    icon = "__Transportorio__/graphics/s-1-3-6.png",
    icon_size = 64, icon_mipmaps = 4,
    energy_required = .1,
    enabled = true,
	hidden = true,
	subgroup = "tier-6",
    ingredients =
    {
		{"automation-science-pack", math.floor(30000/rate)+1 },
		{"military-science-pack", math.floor(30000/rate)+1 },
		{"utility-science-pack", math.floor(30000/rate)+1 }
	},
    results ={{"satellite", 1 }},
  allow_decomposition =false,
  allow_as_intermediate=false,
  allow_intermediates = false
  },
  })
  table.insert( can_productivity_module, "s-1-3-6-"..r )
  
   data:extend({
   {
    type = "recipe",
    name = "s-1-4-5-"..r,
    icon = "__Transportorio__/graphics/s-1-4-5.png",
    icon_size = 64, icon_mipmaps = 4,
    energy_required = .1,
    enabled = true,
	hidden = true,
	subgroup = "tier-6",
    ingredients =
    {
		{"automation-science-pack", math.floor(30000/rate)+1 },
		{"chemical-science-pack", math.floor(30000/rate)+1 },
		{"production-science-pack", math.floor(30000/rate)+1 }
	},
    results ={{"satellite", 1 }},
  allow_decomposition =false,
  allow_as_intermediate=false,
  allow_intermediates = false
  },
  })
  table.insert( can_productivity_module, "s-1-4-5-"..r )
  
   data:extend({
   {
    type = "recipe",
    name = "s-1-4-6-"..r,
    icon = "__Transportorio__/graphics/s-1-4-6.png",
    icon_size = 64, icon_mipmaps = 4,
    energy_required = .1,
    enabled = true,
	hidden = true,
	subgroup = "tier-6",
    ingredients =
    {
		{"automation-science-pack", math.floor(30000/rate)+1 },
		{"chemical-science-pack", math.floor(30000/rate)+1 },
		{"utility-science-pack", math.floor(30000/rate)+1 }
	},
    results ={{"satellite", 1 }},
  allow_decomposition =false,
  allow_as_intermediate=false,
  allow_intermediates = false
  },
  })
  table.insert( can_productivity_module, "s-1-4-6-"..r )
  
   data:extend({
   {
    type = "recipe",
    name = "s-2-3-5-"..r,
    icon = "__Transportorio__/graphics/s-2-3-5.png",
    icon_size = 64, icon_mipmaps = 4,
    energy_required = .1,
    enabled = true,
	hidden = true,
	subgroup = "tier-6",
    ingredients =
    {
		{"logistic-science-pack", math.floor(30000/rate)+1 },
		{"military-science-pack",   math.floor(30000/rate)+1 },
		{"production-science-pack", math.floor(30000/rate)+1 }
	},
    results ={{"satellite", 1 }},
  allow_decomposition =false,
  allow_as_intermediate=false,
  allow_intermediates = false
  },
  })
  table.insert( can_productivity_module, "s-2-3-5-"..r )
  
   data:extend({
   {
    type = "recipe",
    name = "s-2-3-6-"..r,
    icon = "__Transportorio__/graphics/s-2-3-6.png",
    icon_size = 64, icon_mipmaps = 4,
    energy_required = .1,
    enabled = true,
	hidden = true,
	subgroup = "tier-6",
    ingredients =
    {
		{"logistic-science-pack", math.floor(30000/rate)+1 },
		{"military-science-pack", math.floor(30000/rate)+1 },
		{"utility-science-pack", math.floor(30000/rate)+1 }
	},
    results ={{"satellite", 1 }},
  allow_decomposition =false,
  allow_as_intermediate=false,
  allow_intermediates = false
  },
  })
  table.insert( can_productivity_module, "s-2-3-6-"..r )
  
   data:extend({
   {
    type = "recipe",
    name = "s-2-4-5-"..r,
    icon = "__Transportorio__/graphics/s-2-4-5.png",
    icon_size = 64, icon_mipmaps = 4,
    energy_required = .1,
    enabled = true,
	hidden = true,
	subgroup = "tier-6",
    ingredients =
    {
		{"logistic-science-pack", math.floor(30000/rate)+1 },
		{"chemical-science-pack", math.floor(30000/rate)+1 },
		{"production-science-pack", math.floor(30000/rate)+1 }
	},
    results ={{"satellite", 1 }},
  allow_decomposition =false,
  allow_as_intermediate=false,
  allow_intermediates = false
  },
  })
  table.insert( can_productivity_module, "s-2-4-5-"..r )
  
   data:extend({
   {
    type = "recipe",
    name = "s-2-4-6-"..r,
    icon = "__Transportorio__/graphics/s-2-4-6.png",
    icon_size = 64, icon_mipmaps = 4,
    energy_required = .1,
    enabled = true,
	hidden = true,
	subgroup = "tier-6",
    ingredients =
    {
		{"logistic-science-pack", math.floor(30000/rate)+1 },
		{"chemical-science-pack", math.floor(30000/rate)+1 },
		{"utility-science-pack", math.floor(30000/rate)+1 }
	},
    results ={{"satellite", 1 }},
  allow_decomposition =false,
  allow_as_intermediate=false,
  allow_intermediates = false
  },
  })
  table.insert( can_productivity_module, "s-2-4-6-"..r )
  
end

