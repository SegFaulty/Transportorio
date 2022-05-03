require("prototypes.log1")

--Tier up recipes
for i=1,#desired_items.t0,1 do
	for z=1,#desired_items.t1,1 do
		if  desired_items.t0[i] ~= desired_items.t1[z] then
			for r=0,21,1 do
				local rate = 10*item_cost[1][2]/item_cost[1][z] *math.pow( math.exp(math.log(4)/21) ,r)/2

				if rate<1 then
					data:extend({
					{
					type = "recipe",
					name = "Trade-0-"..i.."-1-"..z.."-"..r,
					icon = "__TradeRouteOverhaul__/graphics/trade-0-"..i.."-1-"..z..".png",
					icon_size = 64, icon_mipmaps = 4,
					energy_required = .1,
					enabled = true,
					hidden = true,
					subgroup = "tier-1",
					ingredients = {{desired_items.t0[i], 10 }},
					results = {
					 {name=desired_items.t1[z], probability=( rate )%1, amount=1 },
					},
					allow_decomposition =false,
					allow_as_intermediate=false,
					allow_intermediates = false
					}
					})
					table.insert( can_productivity_module, "Trade-0-"..i.."-1-"..z.."-"..r )

				elseif rate<fraction_starts and math.floor(fraction*rate)%fraction~=0 then
					data:extend({
					{
					type = "recipe",
					name = "Trade-0-"..i.."-1-"..z.."-"..r,
					icon = "__TradeRouteOverhaul__/graphics/trade-0-"..i.."-1-"..z..".png",
					icon_size = 64, icon_mipmaps = 4,
					energy_required = .1,
					enabled = true,
					hidden = true,
					subgroup = "tier-1",
					ingredients = {{desired_items.t0[i], 10 }},
					results = {
					 {desired_items.t1[z], math.floor(rate) },
					 {name=desired_items.t1[z], probability=( math.floor(fraction*rate)/fraction )%1, amount=1 },
					},
					main_product = desired_items.t1[z],
					allow_decomposition =false,
					allow_as_intermediate=false,
					allow_intermediates = false
					}
					})
					table.insert( can_productivity_module, "Trade-0-"..i.."-1-"..z.."-"..r )

				else
					data:extend({
					{
					type = "recipe",
					name = "Trade-0-"..i.."-1-"..z.."-"..r,
					icon = "__TradeRouteOverhaul__/graphics/trade-0-"..i.."-1-"..z..".png",
					icon_size = 64, icon_mipmaps = 4,
					energy_required = .1,
					enabled = true,
					hidden = true,
					subgroup = "tier-1",
					ingredients = {{desired_items.t0[i], 10 }},
					results = {
					 {desired_items.t1[z], math.floor(rate) },
					},
					allow_decomposition =false,
					allow_as_intermediate=false,
					allow_intermediates = false
					}
					})
					table.insert( can_productivity_module, "Trade-0-"..i.."-1-"..z.."-"..r )
				end
			end --end r do
		end --if
	end --end z do
end -- end i do

for i=1,#desired_items.t1,1 do
	for z=1,#desired_items.t2,1 do
		for r=0,21,1 do
			local rate = 10 *item_cost[1][i]/item_cost[2][z] *math.pow( math.exp(math.log(4)/21) ,r)/2
			if rate<1 then
				data:extend({
				{
				type = "recipe",
				name = "Trade-1-"..i.."-2-"..z.."-"..r,
				icon = "__TradeRouteOverhaul__/graphics/trade-1-"..i.."-2-"..z..".png",
				icon_size = 64, icon_mipmaps = 4,
				energy_required = .1,
				enabled = true,
				hidden = true,
				subgroup = "tier-2",
				ingredients = {{desired_items.t1[i], 10 }},
				results = {
				 {name=desired_items.t2[z], probability=( rate )%1, amount=1 },
				},
				allow_decomposition =false,
				allow_as_intermediate=false,
				allow_intermediates = false
				}
				})
				table.insert( can_productivity_module, "Trade-1-"..i.."-2-"..z.."-"..r )

			elseif rate<fraction_starts and math.floor(fraction*rate)%fraction~=0 then
				data:extend({
				{
				type = "recipe",
				name = "Trade-1-"..i.."-2-"..z.."-"..r,
				icon = "__TradeRouteOverhaul__/graphics/trade-1-"..i.."-2-"..z..".png",
				icon_size = 64, icon_mipmaps = 4,
				energy_required = .1,
				enabled = true,
				hidden = true,
				subgroup = "tier-2",
				ingredients = {{desired_items.t1[i], 10 }},
				results = {
					{desired_items.t2[z], math.floor(rate) },	
				 {name=desired_items.t2[z], probability=( math.floor(fraction*rate)/fraction )%1, amount=1 },
				},
				main_product = desired_items.t2[z],
				allow_decomposition =false,
				allow_as_intermediate=false,
				allow_intermediates = false
				}
				})
				table.insert( can_productivity_module, "Trade-1-"..i.."-2-"..z.."-"..r )

			else
				data:extend({
				{
				type = "recipe",
				name = "Trade-1-"..i.."-2-"..z.."-"..r,
				icon = "__TradeRouteOverhaul__/graphics/trade-1-"..i.."-2-"..z..".png",
				icon_size = 64, icon_mipmaps = 4,
				energy_required = .1,
				enabled = true,
				hidden = true,
				subgroup = "tier-2",
				ingredients = {{desired_items.t1[i], 10 }},
				results = {	 
					{desired_items.t2[z], math.floor(rate) },	
				},
				allow_decomposition =false,
				allow_as_intermediate=false,
				allow_intermediates = false
				}
				})
				table.insert( can_productivity_module, "Trade-1-"..i.."-2-"..z.."-"..r )
			end
		end --end r do
	end --end z do
end -- end i do

for i=1,#desired_items.t2,1 do
	for z=1,#desired_items.t3,1 do
		for r=0,21,1 do
			local rate = 10 *item_cost[2][i]/item_cost[3][z] *math.pow( math.exp(math.log(4)/21) ,r)/2
			if rate<1 then
				data:extend({
				{
				type = "recipe",
				name = "Trade-2-"..i.."-3-"..z.."-"..r,
				icon = "__TradeRouteOverhaul__/graphics/trade-2-"..i.."-3-"..z..".png",
				icon_size = 64, icon_mipmaps = 4,
				energy_required = .1,
				enabled = true,
				hidden = true,
				subgroup = "tier-3",
				ingredients = {{desired_items.t2[i], 10 }},
				results = {
				 {name=desired_items.t3[z], probability=( rate )%1, amount=1 },
				},
				allow_decomposition =false,
				allow_as_intermediate=false,
				allow_intermediates = false
				}
				})
				table.insert( can_productivity_module, "Trade-2-"..i.."-3-"..z.."-"..r )

			elseif rate<fraction_starts and math.floor(fraction*rate)%fraction~=0 then
				data:extend({
				{
				type = "recipe",
				name = "Trade-2-"..i.."-3-"..z.."-"..r,
				icon = "__TradeRouteOverhaul__/graphics/trade-2-"..i.."-3-"..z..".png",
				icon_size = 64, icon_mipmaps = 4,
				energy_required = .1,
				enabled = true,
				hidden = true,
				subgroup = "tier-3",
				ingredients = {{desired_items.t2[i], 10 }},
				results = {
					{desired_items.t3[z], math.floor(rate) },
				 {name=desired_items.t3[z], probability=( math.floor(fraction*rate)/fraction )%1, amount=1 },
				},
				main_product = desired_items.t3[z],
				allow_decomposition =false,
				allow_as_intermediate=false,
				allow_intermediates = false
				}
				})
				table.insert( can_productivity_module, "Trade-2-"..i.."-3-"..z.."-"..r )

			else
				data:extend({
				{
				type = "recipe",
				name = "Trade-2-"..i.."-3-"..z.."-"..r,
				icon = "__TradeRouteOverhaul__/graphics/trade-2-"..i.."-3-"..z..".png",
				icon_size = 64, icon_mipmaps = 4,
				energy_required = .1,
				enabled = true,
				hidden = true,
				subgroup = "tier-3",
				ingredients = {{desired_items.t2[i], 10 }},
				results = {	 
					{desired_items.t3[z], math.floor(rate) },	
					},
				allow_decomposition =false,
				allow_as_intermediate=false,
				allow_intermediates = false
				}
				})
				table.insert( can_productivity_module, "Trade-2-"..i.."-3-"..z.."-"..r )

			end
		end --end r do
	end --end z do
end -- end i do

for i=1,#desired_items.t2,1 do
	for z=1,#desired_fluids.t4,1 do
		for r=0,21,1 do
			local rate = 10 *item_cost[2][i]/item_cost[4][2*z-1] *math.pow( math.exp(math.log(4)/21) ,r)/2

			data:extend({
			{
			type = "recipe",
			name = "Trade-2-"..i.."-4-"..(2*z-1).."-"..r,
			icon = "__TradeRouteOverhaul__/graphics/trade-2-"..i.."-4-"..(2*z-1)..".png",
			icon_size = 64, icon_mipmaps = 4,
			category = "crafting-with-fluid",
			energy_required = .1,
			enabled = true,
			hidden = true,
			subgroup = "tier-4",
			ingredients = {{desired_items.t2[i], 10 }},
			results = {	 {type="fluid", name=desired_fluids.t4[z], amount=math.floor(10*rate) }	},
			allow_decomposition =false,
			allow_as_intermediate=false,
			allow_intermediates = false
			}
			})
			table.insert( can_productivity_module, "Trade-2-"..i.."-4-"..(2*z-1).."-"..r )

		end --end r do
	end --end z do
end -- end i do

for i=1,#desired_items.t3,1 do
	for z=1,#desired_fluids.t4,1 do
		for r=0,21,1 do
			local rate = 10 *item_cost[3][i]/item_cost[4][2*z-1] *math.pow( math.exp(math.log(4)/21) ,r)/2

			data:extend({
			{
			type = "recipe",
			name = "Trade-3-"..i.."-4-"..(2*z-1).."-"..r,
			icon = "__TradeRouteOverhaul__/graphics/trade-3-"..i.."-4-"..(2*z-1)..".png",
			icon_size = 64, icon_mipmaps = 4,
			category = "crafting-with-fluid",
			energy_required = .1,
			enabled = true,
			hidden = true,
			subgroup = "tier-4",
			ingredients = {{desired_items.t3[i], 10 }},
			results = {	 {type="fluid", name=desired_fluids.t4[z], amount=math.floor(10*rate) }	},
			allow_decomposition =false,
			allow_as_intermediate=false,
			allow_intermediates = false
			}
			})
			table.insert( can_productivity_module, "Trade-3-"..i.."-4-"..(2*z-1).."-"..r )

		end --end r do
	end --end z do
end -- end i do

for i=1,#desired_items.t3,1 do
	for z=1,#desired_items.t5,1 do
		for r=0,21,1 do
			local rate = 10 *item_cost[3][i]/item_cost[5][z] *math.pow( math.exp(math.log(4)/21) ,r)/2
			if rate<1 then
				data:extend({
				{
				type = "recipe",
				name = "Trade-3-"..i.."-5-"..z.."-"..r,
				icon = "__TradeRouteOverhaul__/graphics/trade-3-"..i.."-5-"..z..".png",
				icon_size = 64, icon_mipmaps = 4,
				energy_required = .1,
				enabled = true,
				hidden = true,
				subgroup = "tier-5",
				ingredients = {{desired_items.t3[i], 10 }},
				results = {
				 {name=desired_items.t5[z], probability=( rate )%1, amount=1 },
				},
				allow_decomposition =false,
				allow_as_intermediate=false,
				allow_intermediates = false
				}
				})
				table.insert( can_productivity_module, "Trade-3-"..i.."-5-"..z.."-"..r )

			elseif rate<fraction_starts and math.floor(fraction*rate)%fraction~=0 then
				data:extend({
				{
				type = "recipe",
				name = "Trade-3-"..i.."-5-"..z.."-"..r,
				icon = "__TradeRouteOverhaul__/graphics/trade-3-"..i.."-5-"..z..".png",
				icon_size = 64, icon_mipmaps = 4,
				energy_required = .1,
				enabled = true,
				hidden = true,
				subgroup = "tier-5",
				ingredients = {{desired_items.t3[i], 10 }},
				results = {
					{desired_items.t5[z], math.floor(rate) },	
				 {name=desired_items.t5[z], probability=( math.floor(fraction*rate)/fraction )%1, amount=1 },
				},
				main_product = desired_items.t5[z],
				allow_decomposition =false,
				allow_as_intermediate=false,
				allow_intermediates = false
				}
				})
				table.insert( can_productivity_module, "Trade-3-"..i.."-5-"..z.."-"..r )

			else
				data:extend({
				{
				type = "recipe",
				name = "Trade-3-"..i.."-5-"..z.."-"..r,
				icon = "__TradeRouteOverhaul__/graphics/trade-3-"..i.."-5-"..z..".png",
				icon_size = 64, icon_mipmaps = 4,
				energy_required = .1,
				enabled = true,
				hidden = true,
				subgroup = "tier-5",
				ingredients = {{desired_items.t3[i], 10 }},
				results = {	
					{desired_items.t5[z], math.floor(rate) },	
				},
				allow_decomposition =false,
				allow_as_intermediate=false,
				allow_intermediates = false
				}
				})
				table.insert( can_productivity_module, "Trade-3-"..i.."-5-"..z.."-"..r )

			end
		end --end r do
	end --end z do
end -- end i do

for i=1,#desired_items.t4,1 do
	for z=1,#desired_items.t5,1 do
		for r=0,21,1 do
			local rate = 10 *item_cost[4][2*i]/item_cost[5][z] *math.pow( math.exp(math.log(4)/21) ,r)/2
			if rate<1 then
				data:extend({
				{
				type = "recipe",
				name = "Trade-4-"..(2*i).."-5-"..z.."-"..r,
				icon = "__TradeRouteOverhaul__/graphics/trade-4-"..(2*i).."-5-"..z..".png",
				icon_size = 64, icon_mipmaps = 4,
				energy_required = .1,
				enabled = true,
				hidden = true,
				subgroup = "tier-5",
				ingredients = {{desired_items.t4[i], 10 }},
				results = {
				 {name=desired_items.t5[z], probability=( rate )%1, amount=1 },
				},
				allow_decomposition =false,
				allow_as_intermediate=false,
				allow_intermediates = false
				}
				})
				table.insert( can_productivity_module, "Trade-4-"..(2*i).."-5-"..z.."-"..r )

			elseif rate<fraction_starts and math.floor(fraction*rate)%fraction~=0 then
				data:extend({
				{
				type = "recipe",
				name = "Trade-4-"..(2*i).."-5-"..z.."-"..r,
				icon = "__TradeRouteOverhaul__/graphics/trade-4-"..(2*i).."-5-"..z..".png",
				icon_size = 64, icon_mipmaps = 4,
				energy_required = .1,
				enabled = true,
				hidden = true,
				subgroup = "tier-5",
				ingredients = {{desired_items.t4[i], 10 }},
				results = {
					{desired_items.t5[z], math.floor( rate) },
				 {name=desired_items.t5[z], probability=( math.floor(fraction*rate)/fraction )%1, amount=1 },
				},
				main_product = desired_items.t5[z],
				allow_decomposition =false,
				allow_as_intermediate=false,
				allow_intermediates = false
				}
				})
				table.insert( can_productivity_module, "Trade-4-"..(2*i).."-5-"..z.."-"..r )

			else
				data:extend({
				{
				type = "recipe",
				name = "Trade-4-"..(2*i).."-5-"..z.."-"..r,
				icon = "__TradeRouteOverhaul__/graphics/trade-4-"..(2*i).."-5-"..z..".png",
				icon_size = 64, icon_mipmaps = 4,
				energy_required = .1,
				enabled = true,
				hidden = true,
				subgroup = "tier-5",
				ingredients = {{desired_items.t4[i], 10 }},
				results = {
					{desired_items.t5[z], math.floor( rate) },
					},
				allow_decomposition =false,
				allow_as_intermediate=false,
				allow_intermediates = false
				}
				})
				table.insert( can_productivity_module, "Trade-4-"..(2*i).."-5-"..z.."-"..r )

			end
		end --end r do
	end --end z do
end -- end i do

for i=1,#desired_items.t4,1 do
	for z=1,#desired_items.t6,1 do
		for r=0,21,1 do
			local rate = 10 *item_cost[4][2*i]/item_cost[6][z] *math.pow( math.exp(math.log(4)/21) ,r)/2
			if rate<1 then
				data:extend({
				{
				type = "recipe",
				name = "Trade-4-"..(2*i).."-6-"..z.."-"..r,
				icon = "__TradeRouteOverhaul__/graphics/trade-4-"..(2*i).."-6-"..z..".png",
				icon_size = 64, icon_mipmaps = 4,
				energy_required = .1,
				enabled = true,
				hidden = true,
				subgroup = "tier-6",
				ingredients = {{desired_items.t4[i], 10 }},
				results = {
				 {name=desired_items.t6[z], probability=( rate )%1, amount=1 },
				},
				allow_decomposition =false,
				allow_as_intermediate=false,
				allow_intermediates = false
				}
				})
				table.insert( can_productivity_module, "Trade-4-"..(2*i).."-6-"..z.."-"..r )

			elseif rate<fraction_starts and math.floor(fraction*rate)%fraction~=0 then
				data:extend({
				{
				type = "recipe",
				name = "Trade-4-"..(2*i).."-6-"..z.."-"..r,
				icon = "__TradeRouteOverhaul__/graphics/trade-4-"..(2*i).."-6-"..z..".png",
				icon_size = 64, icon_mipmaps = 4,
				energy_required = .1,
				enabled = true,
				hidden = true,
				subgroup = "tier-6",
				ingredients = {{desired_items.t4[i], 10 }},
				results = {
					{desired_items.t6[z], math.floor(rate) },	
				 {name=desired_items.t6[z], probability=( math.floor(fraction*rate)/fraction )%1, amount=1 },
				},
				main_product = desired_items.t6[z],
				allow_decomposition =false,
				allow_as_intermediate=false,
				allow_intermediates = false
				}
				})
				table.insert( can_productivity_module, "Trade-4-"..(2*i).."-6-"..z.."-"..r )

			else
				data:extend({
				{
				type = "recipe",
				name = "Trade-4-"..(2*i).."-6-"..z.."-"..r,
				icon = "__TradeRouteOverhaul__/graphics/trade-4-"..(2*i).."-6-"..z..".png",
				icon_size = 64, icon_mipmaps = 4,
				energy_required = .1,
				enabled = true,
				hidden = true,
				subgroup = "tier-6",
				ingredients = {{desired_items.t4[i], 10 }},
				results = {	 
					{desired_items.t6[z], math.floor(rate) },	
					},
				allow_decomposition =false,
				allow_as_intermediate=false,
				allow_intermediates = false
				}
				})
				table.insert( can_productivity_module, "Trade-4-"..(2*i).."-6-"..z.."-"..r )

			end
		end --end r do
	end --end z do
end -- end i do

for i=1,#desired_items.t5,1 do
	for z=1,#desired_items.t6,1 do
		for r=0,21,1 do
			local rate = 10 *item_cost[5][i]/item_cost[6][z] *math.pow( math.exp(math.log(4)/21) ,r)/2
			if rate<1 then
				data:extend({
				{
				type = "recipe",
				name = "Trade-5-"..i.."-6-"..z.."-"..r,
				icon = "__TradeRouteOverhaul__/graphics/trade-5-"..i.."-6-"..z..".png",
				icon_size = 64, icon_mipmaps = 4,
				energy_required = .1,
				enabled = true,
				hidden = true,
				subgroup = "tier-6",
				ingredients = {{desired_items.t5[i], 10 }},
				results = {
				 {name=desired_items.t6[z], probability=( rate )%1, amount=1 },
				},
				allow_decomposition =false,
				allow_as_intermediate=false,
				allow_intermediates = false
				}
				})
				table.insert( can_productivity_module, "Trade-5-"..i.."-6-"..z.."-"..r )

			elseif rate<fraction_starts and math.floor(fraction*rate)%fraction~=0 then
				data:extend({
				{
				type = "recipe",
				name = "Trade-5-"..i.."-6-"..z.."-"..r,
				icon = "__TradeRouteOverhaul__/graphics/trade-5-"..i.."-6-"..z..".png",
				icon_size = 64, icon_mipmaps = 4,
				energy_required = .1,
				enabled = true,
				hidden = true,
				subgroup = "tier-6",
				ingredients = {{desired_items.t5[i], 10 }},
				results = {
					{desired_items.t6[z], math.floor(rate) },	
				 {name=desired_items.t6[z], probability=( math.floor(fraction*rate)/fraction )%1, amount=1 },
				},
				main_product = desired_items.t6[z],
				allow_decomposition =false,
				allow_as_intermediate=false,
				allow_intermediates = false
				}
				})
				table.insert( can_productivity_module, "Trade-5-"..i.."-6-"..z.."-"..r )

			else
				data:extend({
				{
				type = "recipe",
				name = "Trade-5-"..i.."-6-"..z.."-"..r,
				icon = "__TradeRouteOverhaul__/graphics/trade-5-"..i.."-6-"..z..".png",
				icon_size = 64, icon_mipmaps = 4,
				energy_required = .1,
				enabled = true,
				hidden = true,
				subgroup = "tier-6",
				ingredients = {{desired_items.t5[i], 10 }},
				results = {	 
					{desired_items.t6[z], math.floor(rate) },	
					},
				allow_decomposition =false,
				allow_as_intermediate=false,
				allow_intermediates = false
				}
				})
				table.insert( can_productivity_module, "Trade-5-"..i.."-6-"..z.."-"..r )
				
			end
		end --end r do
	end --end z do
end -- end i do
 
 