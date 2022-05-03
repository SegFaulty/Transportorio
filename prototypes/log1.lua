--disable and remove mats from recipes
for k, v in pairs(data.raw.recipe) do
	v.enabled = false
	if v.normal then 
		v.normal.enabled = false 
		v.normal.ingredients = {} 
	end

	if v.expensive then 
		v.expensive.enabled = false 
		v.expensive.ingredients = {}
	end

	if v.name ~= "rocket-part" then
		v.ingredients = {}
	end
end
 
--starter coal recipe
data:extend({
  {
	type = "recipe",
	name = "Coal",
	energy_required = .1,
	enabled = true,
	hidden = true,
	ingredients =
	{},
	result = "coal"
  },
  {
	type = "recipe",
	name = "Belts",
	icon = "__TradeRouteOverhaul__/graphics/mall-7-0-0-1.png",
	icon_size = 64, icon_mipmaps = 4,
	energy_required = .1,
	enabled = true,
	hidden = true,
	ingredients = {{"coal", 5}},
	results = {	 {"transport-belt", 1 }	},
  },
  {
	type = "recipe",
	name = "Rails",
	icon = "__TradeRouteOverhaul__/graphics/mall-7-0-0-2.png",
	icon_size = 64, icon_mipmaps = 4,
	energy_required = .1,
	enabled = true,
	hidden = true,
	ingredients = {{"coal", 10}},
	results = {	 {"rail", 1 }	},
  }
})
  
desired_items = {}
desired_fluids = {}
  
desired_items.t0 = {
	"coal",
}

desired_items.t1 = {
	"stone",
	"coal",
	"copper-ore",
	"iron-ore",
}

desired_items.t2 = {
	"copper-cable",
	"iron-stick",
	"stone-brick",
	"copper-plate",
	"iron-plate",
}

desired_items.t3 = {
	"pipe",
	"steel-plate",
	"iron-gear-wheel",
	"electronic-circuit",
	"firearm-magazine",
	"stone-wall",
}

desired_items.t4 = {
	"plastic-bar",
	"explosives",
	"rocket-fuel",
}

desired_fluids.t4 = {
	"lubricant",
	"petroleum-gas",
	"sulfuric-acid",
}

desired_items.t5 = {
	"engine-unit",
	"advanced-circuit",
	"low-density-structure",
	"electric-engine-unit",
	"speed-module",
	"effectivity-module",
	"productivity-module",
}

desired_items.t6 = {
	"battery",
	"electric-engine-unit",
	"logistic-robot",
	"construction-robot",
	"processing-unit",
	"rocket-control-unit",
	"atomic-bomb",
}

can_productivity_module = {"rocket-part"}
  
sci_cost = {5,50,500,1000,10000,20000}
base =   {.625,	7,		50,		100,	750,	1500}
inrate = {1.6,	1.5,	1.4,	1.3,	1.35,	1.25}

l1 = math.log(2000)
l2 = math.log(2)
r0 = 1000000

sci_cost[1] = 10*math.exp(l1*0/11+l2/3*rand(r0)/r0)
sci_cost[2] = sci_cost[1]*math.exp(l1*3/11+l2/9*rand(r0)/r0)
sci_cost[3] = sci_cost[2]*math.exp(l1*3/11+l2/9*rand(r0)/r0)
sci_cost[4] = sci_cost[3]*math.exp(l1*1/11+l2/6*rand(r0)/r0)
sci_cost[5] = sci_cost[4]*math.exp(l1*3/11+l2/9*rand(r0)/r0)
sci_cost[6] = sci_cost[5]*math.exp(l1*1/11+l2/6*rand(r0)/r0)
  
item_cost = { 
	{ rand(r0)/r0, 0, 0, 0 }, 
	{ rand(r0)/r0, 0, 0, 0, 0 }, 
	{ rand(r0)/r0, 0, 0, 0, 0, 0 }, 
	{ rand(r0)/r0, 0, 0, 0, 0, 0 }, 
	{ rand(r0)/r0, 0, 0, 0, 0, 0, 0 }, 
	{ rand(r0)/r0, 0, 0, 0, 0, 0, 0 } 
}

for i=1,6 do
	for j=2,#item_cost[i] do
		item_cost[i][j] = item_cost[i][j-1]+rand(r0)/r0
	end
end

item_sum = {0,0,0,0,0,0}
spread = {8,8,8,5,8,5}

for i=1,6 do
	for j=1,#item_cost[i] do
		item_cost[i][j] = spread[i]*math.exp(item_cost[i][j]/item_cost[i][#item_cost[i]])
		item_sum[i] = item_sum[i] + item_cost[i][j]
	end
end

for i=1,6 do
	for j=1,#item_cost[i] do
		item_cost[i][j] = sci_cost[i]*item_cost[i][j]/item_sum[i]
	end
end

fraction = 8
fraction_starts = 6

--for d,i in ipairs(desired_items.t1) do
--for m,z in ipairs(desired_items.t1) do
for i=1,#desired_items.t1,1 do
	for z=1,#desired_items.t1,1 do
		if  i ~= z then
			for r=0,21,1 do
				local rate = 10*item_cost[1][i]/item_cost[1][z]*math.pow( math.exp(math.log(4)/21) ,r)/2
				if rate<1 then
					data:extend({
					{
					type = "recipe",
					name = "Trade-1-"..i.."-1-"..z.."-"..r,
					icon = "__TradeRouteOverhaul__/graphics/trade-1-"..i.."-1-"..z..".png",
					icon_size = 64, icon_mipmaps = 4,
					energy_required = .1,
					enabled = true,
					hidden = true,
					subgroup = "tier-1",
					ingredients = {{desired_items.t1[i], 10}},
					results = {
					 {name=desired_items.t1[z], probability=( rate )%1, amount=1 },
					},
					allow_decomposition =false,
					allow_as_intermediate=false,
					allow_intermediates = false
					}
					})
					table.insert( can_productivity_module, "Trade-1-"..i.."-1-"..z.."-"..r )

				elseif rate<fraction_starts and math.floor(fraction*rate)%fraction~=0 then
					data:extend({
					{
					type = "recipe",
					name = "Trade-1-"..i.."-1-"..z.."-"..r,
					icon = "__TradeRouteOverhaul__/graphics/trade-1-"..i.."-1-"..z..".png",
					icon_size = 64, icon_mipmaps = 4,
					energy_required = .1,
					enabled = true,
					hidden = true,
					subgroup = "tier-1",
					ingredients = {{desired_items.t1[i], 10}},
					results = {
					 {desired_items.t1[z], math.floor( rate ) },
					 {name=desired_items.t1[z], probability=( math.floor(fraction*rate)/fraction )%1, amount=1 },
					},
					main_product=desired_items.t1[z],
					allow_decomposition =false,
					allow_as_intermediate=false,
					allow_intermediates = false
					}
					})
					table.insert( can_productivity_module, "Trade-1-"..i.."-1-"..z.."-"..r )

				else
					data:extend({
					{
					type = "recipe",
					name = "Trade-1-"..i.."-1-"..z.."-"..r,
					icon = "__TradeRouteOverhaul__/graphics/trade-1-"..i.."-1-"..z..".png",
					icon_size = 64, icon_mipmaps = 4,
					energy_required = .1,
					enabled = true,
					hidden = true,
					subgroup = "tier-1",
					ingredients = {{desired_items.t1[i], 10}},
					results = {
					 {desired_items.t1[z], math.floor( rate ) },
					},
					allow_decomposition =false,
					allow_as_intermediate=false,
					allow_intermediates = false
					}
					})
					table.insert( can_productivity_module, "Trade-1-"..i.."-1-"..z.."-"..r )

				end --if
			end --end r do
		end --if
	end --end z do
end -- end i do

for i=1,#desired_items.t2,1 do
	for z=1,#desired_items.t2,1 do
		if  i ~= z then
			for r=0,21,1 do
				local rate = 10*item_cost[2][i]/item_cost[2][z]*math.pow( math.exp(math.log(4)/21) ,r)/2
				if rate<1 then
					data:extend({
					{
					type = "recipe",
					name = "Trade-2-"..i.."-2-"..z.."-"..r,
					icon = "__TradeRouteOverhaul__/graphics/trade-2-"..i.."-2-"..z..".png",
					icon_size = 64, icon_mipmaps = 4,
					energy_required = .1,
					enabled = true,
					hidden = true,
					subgroup = "tier-2",
					ingredients = {{desired_items.t2[i], 10}},
					results = {
					 {name=desired_items.t2[z], probability=( rate )%1, amount=1 },
					},
					allow_decomposition =false,
					allow_as_intermediate=false,
					allow_intermediates = false
					}
					})
					table.insert( can_productivity_module, "Trade-2-"..i.."-2-"..z.."-"..r )

				elseif rate<fraction_starts and math.floor(fraction*rate)%fraction~=0 then
					data:extend({
					{
					type = "recipe",
					name = "Trade-2-"..i.."-2-"..z.."-"..r,
					icon = "__TradeRouteOverhaul__/graphics/trade-2-"..i.."-2-"..z..".png",
					icon_size = 64, icon_mipmaps = 4,
					energy_required = .1,
					enabled = true,
					hidden = true,
					subgroup = "tier-2",
					ingredients = {{desired_items.t2[i], 10}},
					results = {
					 {desired_items.t2[z], math.floor( rate ) },
					 {name=desired_items.t2[z], probability=( math.floor(fraction*rate)/fraction )%1, amount=1 },
					},
					main_product=desired_items.t2[z],
					allow_decomposition =false,
					allow_as_intermediate=false,
					allow_intermediates = false
					}
					})
					table.insert( can_productivity_module, "Trade-2-"..i.."-2-"..z.."-"..r )

				else
					data:extend({
					{
					type = "recipe",
					name = "Trade-2-"..i.."-2-"..z.."-"..r,
					icon = "__TradeRouteOverhaul__/graphics/trade-2-"..i.."-2-"..z..".png",
					icon_size = 64, icon_mipmaps = 4,
					energy_required = .1,
					enabled = true,
					hidden = true,
					subgroup = "tier-2",
					ingredients = {{desired_items.t2[i], 10}},
					results = {
					 {desired_items.t2[z], math.floor( rate ) },
					},
					allow_decomposition =false,
					allow_as_intermediate=false,
					allow_intermediates = false
					}
					})
					table.insert( can_productivity_module, "Trade-2-"..i.."-2-"..z.."-"..r )

				end --if
			end --end r do
		end --if
	end --end z do
end -- end i do

for i=1,#desired_items.t3,1 do
	for z=1,#desired_items.t3,1 do
		if  i ~= z then
			for r=0,21,1 do
				local rate = 10*item_cost[3][i]/item_cost[3][z]*math.pow( math.exp(math.log(4)/21) ,r)/2
				if rate<1 then
					data:extend({
					{
					type = "recipe",
					name = "Trade-3-"..i.."-3-"..z.."-"..r,
					icon = "__TradeRouteOverhaul__/graphics/trade-3-"..i.."-3-"..z..".png",
					icon_size = 64, icon_mipmaps = 4,
					energy_required = .1,
					enabled = true,
					hidden = true,
					subgroup = "tier-3",
					ingredients = {{desired_items.t3[i], 10}},
					results = {
					 {name=desired_items.t3[z], probability=( rate )%1, amount=1 },
					},
					allow_decomposition =false,
					allow_as_intermediate=false,
					allow_intermediates = false
					}
					})
					table.insert( can_productivity_module, "Trade-3-"..i.."-3-"..z.."-"..r )

				elseif rate<fraction_starts and math.floor(fraction*rate)%fraction~=0 then
					data:extend({
					{
					type = "recipe",
					name = "Trade-3-"..i.."-3-"..z.."-"..r,
					icon = "__TradeRouteOverhaul__/graphics/trade-3-"..i.."-3-"..z..".png",
					icon_size = 64, icon_mipmaps = 4,
					energy_required = .1,
					enabled = true,
					hidden = true,
					subgroup = "tier-3",
					ingredients = {{desired_items.t3[i], 10}},
					results = {
					 {desired_items.t3[z], math.floor( rate ) },
					 {name=desired_items.t3[z], probability=( math.floor(fraction*rate)/fraction )%1, amount=1 },
					},
					main_product=desired_items.t3[z],
					allow_decomposition =false,
					allow_as_intermediate=false,
					allow_intermediates = false
					}
					})
					table.insert( can_productivity_module, "Trade-3-"..i.."-3-"..z.."-"..r )

				else
					data:extend({
					{
					type = "recipe",
					name = "Trade-3-"..i.."-3-"..z.."-"..r,
					icon = "__TradeRouteOverhaul__/graphics/trade-3-"..i.."-3-"..z..".png",
					icon_size = 64, icon_mipmaps = 4,
					energy_required = .1,
					enabled = true,
					hidden = true,
					subgroup = "tier-3",
					ingredients = {{desired_items.t3[i], 10}},
					results = {
					 {desired_items.t3[z], math.floor( rate ) },
					},
					allow_decomposition =false,
					allow_as_intermediate=false,
					allow_intermediates = false
					}
					})
					table.insert( can_productivity_module, "Trade-3-"..i.."-3-"..z.."-"..r )

				end --if
			end --end r do
		end --if
	end --end z do
end -- end i do

for i=1,#desired_items.t5,1 do
	for z=1,#desired_items.t5,1 do
		if  i ~= z then
			for r=0,21,1 do

				local rate = 10*item_cost[5][i]/item_cost[5][z]*math.pow( math.exp(math.log(4)/21) ,r)/2
				if rate<1 then
					data:extend({
					{
					type = "recipe",
					name = "Trade-5-"..i.."-5-"..z.."-"..r,
					icon = "__TradeRouteOverhaul__/graphics/trade-5-"..i.."-5-"..z..".png",
					icon_size = 64, icon_mipmaps = 4,
					energy_required = .1,
					enabled = true,
					hidden = true,
					subgroup = "tier-5",
					ingredients = {{desired_items.t5[i], 10}},
					results = {
					 {name=desired_items.t5[z], probability=( rate )%1, amount=1 },
					},
					allow_decomposition =false,
					allow_as_intermediate=false,
					allow_intermediates = false
					}
					})
					table.insert( can_productivity_module, "Trade-5-"..i.."-5-"..z.."-"..r )

				elseif rate<fraction_starts and math.floor(fraction*rate)%fraction~=0 then
					data:extend({
					{
					type = "recipe",
					name = "Trade-5-"..i.."-5-"..z.."-"..r,
					icon = "__TradeRouteOverhaul__/graphics/trade-5-"..i.."-5-"..z..".png",
					icon_size = 64, icon_mipmaps = 4,
					energy_required = .1,
					enabled = true,
					hidden = true,
					subgroup = "tier-5",
					ingredients = {{desired_items.t5[i], 10}},
					results = {
					 {desired_items.t5[z], math.floor( rate ) },
					 {name=desired_items.t5[z], probability=( math.floor(fraction*rate)/fraction )%1, amount=1 },
					},
					main_product=desired_items.t5[z],
					allow_decomposition =false,
					allow_as_intermediate=false,
					allow_intermediates = false
					}
					})
					table.insert( can_productivity_module, "Trade-5-"..i.."-5-"..z.."-"..r )

				else
					data:extend({
					{
					type = "recipe",
					name = "Trade-5-"..i.."-5-"..z.."-"..r,
					icon = "__TradeRouteOverhaul__/graphics/trade-5-"..i.."-5-"..z..".png",
					icon_size = 64, icon_mipmaps = 4,
					energy_required = .1,
					enabled = true,
					hidden = true,
					subgroup = "tier-5",
					ingredients = {{desired_items.t5[i], 10}},
					results = {
					 {desired_items.t5[z], math.floor( rate ) },
					},
					allow_decomposition =false,
					allow_as_intermediate=false,
					allow_intermediates = false
					}
					})
					table.insert( can_productivity_module, "Trade-5-"..i.."-5-"..z.."-"..r )

				end --if
			end --end r do
		end --if
	end --end z do
end -- end i do

for i=1,#desired_items.t6,1 do
	for z=1,#desired_items.t6,1 do
		if  i ~= z then
			for r=0,21,1 do
				local rate = 10*item_cost[6][i]/item_cost[6][z]*math.pow( math.exp(math.log(4)/21) ,r)/2
				if rate<1 then
					data:extend({
					{
					type = "recipe",
					name = "Trade-6-"..i.."-6-"..z.."-"..r,
					icon = "__TradeRouteOverhaul__/graphics/trade-6-"..i.."-6-"..z..".png",
					icon_size = 64, icon_mipmaps = 4,
					energy_required = .1,
					enabled = true,
					hidden = true,
					subgroup = "tier-6",
					ingredients = {{desired_items.t6[i], 10}},
					results = {
					 {name=desired_items.t6[z], probability=( rate )%1, amount=1 },
					},
					allow_decomposition =false,
					allow_as_intermediate=false,
					allow_intermediates = false
					}
					})
					table.insert( can_productivity_module, "Trade-6-"..i.."-6-"..z.."-"..r )

				elseif rate<fraction_starts and math.floor(fraction*rate)%fraction~=0 then
					data:extend({
					{
					type = "recipe",
					name = "Trade-6-"..i.."-6-"..z.."-"..r,
					icon = "__TradeRouteOverhaul__/graphics/trade-6-"..i.."-6-"..z..".png",
					icon_size = 64, icon_mipmaps = 4,
					energy_required = .1,
					enabled = true,
					hidden = true,
					subgroup = "tier-6",
					ingredients = {{desired_items.t6[i], 10}},
					results = {
					 {desired_items.t6[z], math.floor( rate ) },
					 {name=desired_items.t6[z], probability=( math.floor(fraction*rate)/fraction )%1, amount=1 },
					},
					main_product=desired_items.t6[z],
					allow_decomposition =false,
					allow_as_intermediate=false,
					allow_intermediates = false
					}
					})
					table.insert( can_productivity_module, "Trade-6-"..i.."-6-"..z.."-"..r )

				else
					data:extend({
					{
					type = "recipe",
					name = "Trade-6-"..i.."-6-"..z.."-"..r,
					icon = "__TradeRouteOverhaul__/graphics/trade-6-"..i.."-6-"..z..".png",
					icon_size = 64, icon_mipmaps = 4,
					energy_required = .1,
					enabled = true,
					hidden = true,
					subgroup = "tier-6",
					ingredients = {{desired_items.t6[i], 10}},
					results = {
					 {desired_items.t6[z], math.floor( rate ) },
					},
					allow_decomposition =false,
					allow_as_intermediate=false,
					allow_intermediates = false
					}
					})
					table.insert( can_productivity_module, "Trade-6-"..i.."-6-"..z.."-"..r )

				end --if
			end --end r do
		end --if
	end --end z do
end -- end i do

--for d,i in ipairs(desired_items.t4) do
--for m,z in ipairs(desired_fluids.t4) do
for i=1,#desired_items.t4,1 do
	for z=1,#desired_fluids.t4,1 do
		for r=0,21,1 do
			local rate = 10*item_cost[4][2*i]/item_cost[4][2*z-1]*math.pow( math.exp(math.log(4)/21) ,r)/2
			data:extend({
				{
					type = "recipe",
					name = "Trade-4-"..(2*i).."-4-"..(2*z-1).."-"..r,
					icon = "__TradeRouteOverhaul__/graphics/trade-4-"..(2*i).."-4-"..(2*z-1)..".png",
					icon_size = 64, icon_mipmaps = 4,
					category = "crafting-with-fluid",
					energy_required = .1,
					enabled = true,
					hidden = true,
					subgroup = "tier-4",
					ingredients =
					{
					  {type="item", name=desired_items.t4[i], amount=10},
					},
					results=
					{
					  {type="fluid", name=desired_fluids.t4[z], amount=math.floor( 10*rate )}
					},
					allow_decomposition =false,
					allow_as_intermediate=false,
					allow_intermediates = false
				}
			})
			table.insert( can_productivity_module, "Trade-4-"..(2*i).."-4-"..(2*z-1).."-"..r )

			local rate = 10*item_cost[4][2*z-1]/item_cost[4][2*i]*math.pow( math.exp(math.log(4)/21) ,r)/2
			if rate<1 then
				data:extend({
				  {
				type = "recipe",
				name = "Trade-4-"..(2*z-1).."-4-"..(2*i).."-"..r,
				icon = "__TradeRouteOverhaul__/graphics/trade-4-"..(2*z-1).."-4-"..(2*i)..".png",
				icon_size = 64, icon_mipmaps = 4,
				category = "crafting-with-fluid",
				energy_required = .1,
				enabled = true,
				hidden = true,
				subgroup = "tier-4",
				ingredients =
				{
				  {type="fluid", name=desired_fluids.t4[z], amount=100}
				},
				results=
				{
				  {type="item", name=desired_items.t4[i], probability=( rate )%1, amount=1},
				},
				allow_decomposition =false,
				allow_as_intermediate=false,
				allow_intermediates = false
				}
				})
				table.insert( can_productivity_module, "Trade-4-"..(2*z-1).."-4-"..(2*i).."-"..r )

			elseif rate<fraction_starts and math.floor(fraction*rate)%fraction~=0 then
				data:extend({
				  {
				type = "recipe",
				name = "Trade-4-"..(2*z-1).."-4-"..(2*i).."-"..r,
				icon = "__TradeRouteOverhaul__/graphics/trade-4-"..(2*z-1).."-4-"..(2*i)..".png",
				icon_size = 64, icon_mipmaps = 4,
				category = "crafting-with-fluid",
				energy_required = .1,
				enabled = true,
				hidden = true,
				subgroup = "tier-4",
				ingredients =
				{
				  {type="fluid", name=desired_fluids.t4[z], amount=100}
				},
				results=
				{
				  {type="item", name=desired_items.t4[i], amount=math.floor(rate) },
				  {type="item", name=desired_items.t4[i], probability=( math.floor(fraction*rate)/fraction )%1, amount=1},
				},
				main_product=desired_items.t4[i],
				allow_decomposition =false,
				allow_as_intermediate=false,
				allow_intermediates = false
				}
				})
				table.insert( can_productivity_module, "Trade-4-"..(2*z-1).."-4-"..(2*i).."-"..r )

			else
				data:extend({
				  {
				type = "recipe",
				name = "Trade-4-"..(2*z-1).."-4-"..(2*i).."-"..r,
				icon = "__TradeRouteOverhaul__/graphics/trade-4-"..(2*z-1).."-4-"..(2*i)..".png",
				icon_size = 64, icon_mipmaps = 4,
				category = "crafting-with-fluid",
				energy_required = .1,
				enabled = true,
				hidden = true,
				subgroup = "tier-4",
				ingredients =
				{
				  {type="fluid", name=desired_fluids.t4[z], amount=100}
				},
				results=
				{
				  {type="item", name=desired_items.t4[i], amount=math.floor(rate) },
				},
				allow_decomposition =false,
				allow_as_intermediate=false,
				allow_intermediates = false
				}
				})
				table.insert( can_productivity_module, "Trade-4-"..(2*z-1).."-4-"..(2*i).."-"..r )

			end --rate
		end --end r
	end --end mz do
end -- end DI do

for i=1,#desired_items.t4,1 do
	for z=1,#desired_items.t4,1 do
		if  i ~= z then
			for r=0,21,1 do
				local rate = 10*item_cost[4][2*i]/item_cost[4][2*z]*math.pow( math.exp(math.log(4)/21) ,r)/2
				if rate<1 then
					data:extend({
					{
					type = "recipe",
					name = "Trade-4-"..(2*i).."-4-"..(2*z).."-"..r,
					icon = "__TradeRouteOverhaul__/graphics/trade-4-"..(2*i).."-4-"..(2*z)..".png",
					icon_size = 64, icon_mipmaps = 4,
					energy_required = .1,
					enabled = true,
					hidden = true,
					subgroup = "tier-4",
					ingredients = {{desired_items.t4[i], 10}},
					results = {
					 {name=desired_items.t4[z], probability=( rate )%1, amount=1 },
					},
					allow_decomposition =false,
					allow_as_intermediate=false,
					allow_intermediates = false
					}
					})
					table.insert( can_productivity_module, "Trade-4-"..(2*i).."-4-"..(2*z).."-"..r )

				elseif rate<fraction_starts and math.floor(fraction*rate)%fraction~=0 then
					data:extend({
					{
					type = "recipe",
					name = "Trade-4-"..(2*i).."-4-"..(2*z).."-"..r,
					icon = "__TradeRouteOverhaul__/graphics/trade-4-"..(2*i).."-4-"..(2*z)..".png",
					icon_size = 64, icon_mipmaps = 4,
					energy_required = .1,
					enabled = true,
					hidden = true,
					subgroup = "tier-4",
					ingredients = {{desired_items.t4[i], 10}},
					results = {
					 {desired_items.t4[z], math.floor( rate ) },
					 {name=desired_items.t4[z], probability=( math.floor(fraction*rate)/fraction )%1, amount=1 },
					},
					main_product=desired_items.t4[z],
					allow_decomposition =false,
					allow_as_intermediate=false,
					allow_intermediates = false
					}
					})
					table.insert( can_productivity_module, "Trade-4-"..(2*i).."-4-"..(2*z).."-"..r )

				else
					data:extend({
					{
					type = "recipe",
					name = "Trade-4-"..(2*i).."-4-"..(2*z).."-"..r,
					icon = "__TradeRouteOverhaul__/graphics/trade-4-"..(2*i).."-4-"..(2*z)..".png",
					icon_size = 64, icon_mipmaps = 4,
					energy_required = .1,
					enabled = true,
					hidden = true,
					subgroup = "tier-4",
					ingredients = {{desired_items.t4[i], 10}},
					results = {
					 {desired_items.t4[z], math.floor( rate ) },
					},
					allow_decomposition =false,
					allow_as_intermediate=false,
					allow_intermediates = false
					}
					})
					table.insert( can_productivity_module, "Trade-4-"..(2*i).."-4-"..(2*z).."-"..r )

				end --if
			end --end r do
		end --if
	end --end z do
end -- end i do
