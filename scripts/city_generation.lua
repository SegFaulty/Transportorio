
-- creates any building that doesnt have specific attributes
function create_normal(surface, name, position)
	local new_entity = surface.create_entity{
		name = name, 
		position = position,
		force = game.forces.player,
	} 
	-- configure entity
	new_entity.destructible = false
	new_entity.minable = false
	new_entity.operable =true

	return new_entity
end

function create_assembler(surface, name, position, recipe)
	local new_entity = surface.create_entity{
		name = name, 
		position = position,
		force = game.forces.player,
		recipe = recipe
	} 

	-- configure entity
	new_entity.destructible = false
	new_entity.minable = false
	new_entity.recipe_locked = true 
	new_entity.operable =true

	return new_entity
end
-- specific_attributes: see luaSurface create_entity.
function create_city_building(surface, entity_prototype_name, search_center, pavement_size, specific_attributes)

	-- find area mall can be spawned
	local available_spawn_location = surface.find_non_colliding_position(entity_prototype_name, search_center, 30, 4, true)
	
	-- return if there are no suitable spawn locations
	if available_spawn_location == nil then return nil end

	-- save pavement locations for new mall
	local top_left = {x = available_spawn_location.x - (pavement_size.x / 2), y=available_spawn_location.y - (pavement_size.y / 2)}
	for l=top_left.x, top_left.x + pavement_size.x, 1 do
		for w=top_left.y,top_left.y + pavement_size.y, 1 do
			table.insert(pavement, {x=l, y=w})
		end
	end

	-- create new entity
	local new_entity
	if entity_prototype_name == "assembling-machine-1" 
	or entity_prototype_name == "assembling-machine-2" 
	or entity_prototype_name == "assembling-machine-3" then
		new_entity = create_assembler(surface, entity_prototype_name, available_spawn_location, specific_attributes.recipe)
	else
		new_entity = create_normal(surface, entity_prototype_name, available_spawn_location)
	end

	return new_entity
end

function spawn_city (e)
	local surface = e.surface

	-- choose a random location in a chunk for the city center
	local center = {}
	center.x = e.area.right_bottom.x - math.random(0,31)
	center.y = e.area.right_bottom.y - math.random(0,31)
	
	-- check surroundings for another city
	traders = game.surfaces[1].find_entities_filtered{position = center, type = "assembling-machine", radius = minimum_city_distance}
	if next(traders) ~= nil then return end
	
	-- search around the city center for obstacles and remove them
	local area = {{center.x-20,center.y-20},{center.x+20,center.y+20}}
	for index, entity in pairs(game.surfaces[1].find_entities(area)) do
		if entity.valid and (entity.type == "tree" or entity.type == "simple-entity") then
			entity.destroy()
		end
	end
	
	-- city variables i think
	pavement = {}
	local science_city = false
	local city_tier = get_city_tier(center)
	local city_tier2 = get_city_tier(center)
	
	-- randomly roll on city assembly machine level
	local buildingroll = math.random(1,6)
	buildingtype="assembling-machine-3"
	if buildingroll<6 then buildingtype="assembling-machine-2" end
	if buildingroll<4 then buildingtype="assembling-machine-1" end
	
	-- random numbers from 1 - 100. possibly tied to city tiers?
	local item_values = {
		{ math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100) },
		{ math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100) },
		{ math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100) },
		{ math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100) },
		{ math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100) },
		{ math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100) },
		{ math.random(1,100)}, 
	}
	-- why?
	item_values[6][2] = item_values[5][4]
	
	-- some sort of math but to what end i have no clue
	function bits(input)
		local output = {}
		for n=1,7 do
			t = math.pow(2, n - 1)
			t2 = input / t
			t3 = math.floor(t2)
			if t3 % 2 == 1 then 
				table.insert(output,n) 
			end
		end
		return output
	end
	
	-- ??? wtf is this
	local thing = {1,4,5,16,17,20}
	local dontwant6 = { 4,8,16,31,32,47,55,59}
	local dontwant7 = { 4,8,16,32,63,64,95,111,119,123 } 
	local wants = { 13, 31+0*math.random(1,30), math.random(1+2,50+2), {math.random(1,6), math.random(1,6) }, math.random(1+2,112+2), math.random(1+2,112+2) }
	local wants4 = bits( 2*thing[wants[4][2]] ) -- used elsewhere
	local gives4 = bits( thing[7-wants[4][1]] ) -- used elsewhere
	wants[4] = thing[wants[4][1]]+2*thing[wants[4][2]]
	for n=1,10-2,1 do
		if wants[3]>=dontwant6[n] then wants[3] = wants[3]+1 end
	end
	for n=1,12-2,1 do
		if wants[5]>=dontwant7[n] then wants[5] = wants[5]+1 end
		if wants[6]>=dontwant7[n] then wants[6] = wants[6]+1 end
	end
	local gives = { 15, math.random(1,30), 63-wants[3], 63-wants[4], 127-wants[5], 127-wants[6] }
	local wants2 = { bits(wants[1]), bits(wants[2]), bits(wants[3]), bits(wants[4]), bits(wants[5]), bits(wants[6]) } -- used elsewhere
	local gives2 = { bits(gives[1]), bits(gives[2]), bits(gives[3]), bits(gives[4]), bits(gives[5]), bits(gives[6]) } -- used elsewhere

	-- i think this decides how many mall buildings per city and which recipe somehow
	local whichmall = 2*city_tier-math.random(0,1)
	local a = wants2[city_tier][ math.random(1,#wants2[city_tier]) ]
	if city_tier == 4 then 
		a = wants4[ math.random(1,#wants4) ]
	end
	local fromitem = city_tier.."-"..a
	if whichmall % 2 == 0 then 
		fromitem = "7-"..city_tier 
		a = #item_values[city_tier]
	end
		
	-- creates the cities malls.
	malls = { 9, 7, 5, 7, 9, 10, 6, 10, 7, 4, 6, 6 }
	for i = 1, malls[whichmall], 1 do
		local r = math.floor( 21*math.log(2*(69+30*city_tier+50)/(69+30*city_tier+item_values[city_tier][ a ]))/math.log(4) )
		local chosen_recipe = "mall-"..fromitem.."-"..whichmall.."-"..i.."-"..r
		local search_center = {center.x +((i-1)%5)*8-16 , center.y +math.floor((i-1)/5)*8+8}
		local building = create_city_building(surface, buildingtype, search_center, {x=8, y=8}, {recipe=chosen_recipe})
		if building ~= nil then
			table.insert(global.machine_entities, building)
		end
	end
	
	-- create a assembler that can craft a satellite i think
	if city_tier>4 and math.random(1,5)>1 then
		local r = math.floor( 21*math.log(2*(69+30*city_tier+item_values[6][8])/(69+30*city_tier+item_values[7][1]))/math.log(4) )
		local possible_recipes = { "s-1-3-"..city_tier.."-"..r, "s-1-4-"..city_tier.."-"..r, "s-2-3-"..city_tier.."-"..r, "s-2-4-"..city_tier.."-"..r, "satellite-"..r }
		local chosen_recipe = possible_recipes[ math.random(1,5) ]
		local search_center = {center.x +((10-1)%5)*8-16 , center.y +math.floor((10-1)/5)*8+8 }
		local building = create_city_building(surface, buildingtype, search_center, {x=8, y=8}, {recipe=chosen_recipe})
		if building ~= nil then
			table.insert(global.machine_entities, building)
		end
	end
	
	-- create a rocket silo
	local silo = 0
	if city_tier == 6 and math.random(1, 4) == 1 then 
		silo = 1
		local search_center = {center.x  , center.y}
		local building = create_city_building(surface, "rocket-silo", search_center, {x=14, y=14})
		if building ~= nil then
			table.insert(global.machine_entities, new_entity)
			record_city(7, building.position, science_city)
		end
	end

	if city_tier == 4 and buildingtype == "assembling-machine-1" then buildingtype = "assembling-machine-2" end

	-- create a science lab
	local r = math.floor( 21*math.log(2*(69+30*city_tier+item_values[city_tier][ #item_values[city_tier]-1 ])/(69+30*city_tier+item_values[city_tier][ #item_values[city_tier] ]))/math.log(4) )
	local chosen_recipe = "T"..city_tier.."-Science-"..r
	local search_center = {center.x +16  , center.y  }
	local building = create_city_building(surface, buildingtype, search_center, {x=8, y=8}, {recipe=chosen_recipe})
	if building ~= nil then
		record_city(city_tier, building.position, science_city)
		table.insert(global.machine_entities, building)
	end

	-- uptier trades 1 // wtf does this mean? MASON WHAT DO THE NUMBERS MEAN?
	-- wait i think i got it. These are the trades that go up a tier in the city tier.
	uptier = { {1}, {1}, {2}, {2,3}, {3,4}, {4,5} }
	local city_size = math.random(1,2)
	local fromtier = math.random(1,#uptier[city_tier])
	--if city_tier>3 then fromtier = math.random(1,2) end
		
	for i=1,city_size,1 do
		local c = uptier[city_tier][ fromtier ]
		local a = wants2[c][ math.random(1,#wants2[c]) ]
		local b = gives2[city_tier][ math.random(1,#gives2[city_tier]) ]
		if city_tier==4 then b = gives4[ math.random(1,#gives4) ] end
		if city_tier==1 then
		 c=1
		 a=2
		end
		if city_tier==1 and b==2 then b = 1 end
		if city_tier==2 and a==2 then a = 1 end
		--if city_tier==4 and b%2==0 then b = b-1 end
		if c==4 then a = wants4[ math.random(1,#wants4) ] end
		if city_tier==6 and b==2 and c==5 and a==4 then a = 5 end


		local r = math.floor( 21*math.log(2*(69+30*city_tier+item_values[c][a])/(69+30*city_tier+item_values[city_tier][b]))/math.log(4) )
		local chosen_recipe = "Trade-"..c.."-"..a.."-"..city_tier.."-"..b.."-"..r
		local search_center = {center.x +((i-1)%5)*8-16 , center.y -math.floor((i-1)/5)*8-8}		
		local building = create_city_building(surface, buildingtype, search_center, {x=8, y=8}, {recipe=chosen_recipe})
		if building ~= nil then
			table.insert(global.machine_entities, building)
		end
	end
	
	-- intier trades 1 // trades that stay in the city tier
	local possible_recipes = {}
	for a2=1,#wants2[city_tier] do
		for b2=1,#gives2[city_tier] do
			for c=1,#global.trade_map[city_tier][wants2[city_tier][a2]] do
				if global.trade_map[city_tier][wants2[city_tier][a2]][c]==gives2[city_tier][b2] then
					local r2 = math.floor( 21*math.log(2*(69+30*city_tier+item_values[city_tier][wants2[city_tier][a2]])/(69+30*city_tier+item_values[city_tier][gives2[city_tier][b2]]))/math.log(4) )
					for n=1,math.max(1,r2) do
						table.insert(possible_recipes,{wants2[city_tier][a2],gives2[city_tier][b2],r2})
					end
				end
			end
		end
	end
	local city_size2 = math.random(2,math.min(5-city_size,#possible_recipes+1)) 
	for i=city_size+1,city_size+city_size2,1 do
	
		local choice = math.random(1,#possible_recipes)
		local a = possible_recipes[choice][1]
		local b = possible_recipes[choice][2]
		local r = possible_recipes[choice][3]
		chosen_recipe = "Trade-"..city_tier.."-"..a.."-"..city_tier.."-"..b.."-"..r
		local search_center = {center.x +((i-1)%5)*8-16 , center.y -math.floor((i-1)/5)*8-8}		
		local building = create_city_building(surface, buildingtype, search_center, {x=8, y=8}, {recipe=chosen_recipe})
		if building ~= nil then
			table.insert(global.machine_entities, building)
		end
	end
	
	-- bad trades 1 // trades that are not worth much im guessing
	if city_size+city_size2<5 and math.random(1,5)>1 and city_tier>1 then
		local possible_recipes = {}
		for a2=1,#wants2[city_tier] do
			for b2=1,#gives2[city_tier] do
				for c=1,#global.bad_trade_map[city_tier][wants2[city_tier][a2]] do
					if global.bad_trade_map[city_tier][wants2[city_tier][a2]][c]==gives2[city_tier][b2] then
						table.insert(possible_recipes,{wants2[city_tier][a2],gives2[city_tier][b2]})
					end
				end
			end
		end
		i=city_size+city_size2+1
		
		local choice = math.random(1,#possible_recipes)
		local a = possible_recipes[choice][1]
		local b = possible_recipes[choice][2]
		local r = math.max(1,math.floor( 21*math.log(2*(69+30*city_tier+item_values[city_tier][a])/(69+30*city_tier+item_values[city_tier][b]))/math.log(4) )-2)
		chosen_recipe = "Trade-"..city_tier.."-"..a.."-"..city_tier.."-"..b.."-"..r
		local search_center = {center.x +((i-1)%5)*8-16 , center.y -math.floor((i-1)/5)*8-8}		
		local building = create_city_building(surface, buildingtype, search_center, {x=8, y=8}, {recipe=chosen_recipe})
		if building ~= nil then
			table.insert(global.machine_entities, building)
		end
	end
	
	--science 2 // my guess is this decides if a second science lab generates
	if city_tier2~=city_tier then
		if city_tier2 == 4 and buildingtype=="assembling-machine-1" then buildingtype = "assembling-machine-2" end
		
		local r = math.floor( 21*math.log(2*(69+30*city_tier2+item_values[city_tier2][ #item_values[city_tier2]-1 ])/(69+30*city_tier2+item_values[city_tier2][ #item_values[city_tier2] ]))/math.log(4) )
		chosen_recipe = "T"..city_tier2.."-Science-"..r
		local search_center = {center.x -16  , center.y}		
		local building = create_city_building(surface, buildingtype, search_center, {x=8, y=8}, {recipe=chosen_recipe})
		if building ~= nil then
			table.insert(global.machine_entities, building)
		end
	end

	--uptier trades 2 // increase trade tier again? idk
	uptier = { {1}, {1}, {2}, {2,3}, {3,4}, {4,5} }
	local city_size = math.random(1,2)
	local fromtier = math.random(1,#uptier[city_tier2])
	--if city_tier>3 then fromtier = math.random(1,2) end
		
	for i=5+1,5+city_size,1 do
		local c = uptier[city_tier2][ fromtier ]
		local a = wants2[c][ math.random(1,#wants2[c]) ]
		local b = gives2[city_tier2][ math.random(1,#gives2[city_tier2]) ]
		if city_tier2==4 then b = gives4[ math.random(1,#gives4) ] end
		if city_tier2==1 then
			c=1
			a=2
		end
		if city_tier2==1 and b==2 then b = 1 end
		if city_tier2==2 and a==2 then a = 1 end
		--if city_tier==4 and b%2==0 then b = b-1 end
		if c==4 then a = wants4[ math.random(1,#wants4) ] end
		if city_tier2==6 and b==2 and c==5 and a==4 then a = 5 end
		local r = math.floor( 21*math.log(2*(69+30*city_tier2+item_values[c][a])/(69+30*city_tier2+item_values[city_tier2][b]))/math.log(4) )
		chosen_recipe = "Trade-"..c.."-"..a.."-"..city_tier2.."-"..b.."-"..r
		local search_center = {center.x +((i-1)%5)*8-16 , center.y -math.floor((i-1)/5)*8-8}
		local building = create_city_building(surface, buildingtype, search_center, {x=8, y=8}, {recipe=chosen_recipe})
		if building ~= nil then
			table.insert(global.machine_entities, building)
		end
	end
	
	--intier trades 2
	local possible_recipes = {}
	for a2=1,#wants2[city_tier2] do
		for b2=1,#gives2[city_tier2] do
			for c=1,#global.trade_map[city_tier2][wants2[city_tier2][a2]] do
				if global.trade_map[city_tier2][wants2[city_tier2][a2]][c]==gives2[city_tier2][b2] then
					local r2 = math.floor( 21*math.log(2*(69+30*city_tier2+item_values[city_tier2][wants2[city_tier2][a2]])/(69+30*city_tier2+item_values[city_tier2][gives2[city_tier2][b2]]))/math.log(4) )
					for n=1,math.max(1,r2) do
						table.insert(possible_recipes,{wants2[city_tier2][a2],gives2[city_tier2][b2],r2})
					end
				end
			end
		end
	end
	local city_size2 = math.random(2,math.min(5-city_size,#possible_recipes+1)) 
	for i=5+city_size+1,5+city_size+city_size2,1 do
	
		local choice = math.random(1,#possible_recipes)
		local a = possible_recipes[choice][1]
		local b = possible_recipes[choice][2]
		local r = possible_recipes[choice][3]
		chosen_recipe = "Trade-"..city_tier2.."-"..a.."-"..city_tier2.."-"..b.."-"..r
		local search_center = {center.x +((i-1)%5)*8-16 , center.y -math.floor((i-1)/5)*8-8}
		local building = create_city_building(surface, buildingtype, search_center, {x=8, y=8}, {recipe=chosen_recipe})
		if building ~= nil then
			table.insert(global.machine_entities, building)
		end
	end
	
	--bad trades 2
	if city_size+city_size2<5 and math.random(1,5)>1 and city_tier2>1 then
		local possible_recipes = {}
		for a2=1,#wants2[city_tier2] do
			for b2=1,#gives2[city_tier2] do
				for c=1,#global.bad_trade_map[city_tier2][wants2[city_tier2][a2]] do
					if global.bad_trade_map[city_tier2][wants2[city_tier2][a2]][c]==gives2[city_tier2][b2] then
						table.insert(possible_recipes,{wants2[city_tier2][a2],gives2[city_tier2][b2]})
					end
				end
			end
		end
		i=5+city_size+city_size2+1
		
		local choice = math.random(1,#possible_recipes)
		local a = possible_recipes[choice][1]
		local b = possible_recipes[choice][2]
		local r = math.max(1,math.floor( 21*math.log(2*(69+30*city_tier2+item_values[city_tier2][a])/(69+30*city_tier2+item_values[city_tier2][b]))/math.log(4) )-2)
		chosen_recipe = "Trade-"..city_tier2.."-"..a.."-"..city_tier2.."-"..b.."-"..r
		local search_center = {center.x +((i-1)%5)*8-16 , center.y -math.floor((i-1)/5)*8-8}
		local building = create_city_building(surface, buildingtype, search_center, {x=8, y=8}, {recipe=chosen_recipe})
		if building ~= nil then
			table.insert(global.machine_entities, building)
		end
	end
	
	-- beacon // places a beacon i presume
	if math.random(1,4) == 1 then
		local search_center = {center.x-8  , center.y}
		local building = create_city_building(surface, "beacon", search_center, {x=8, y=8})
		if building ~= nil then
			table.insert(global.machine_entities, building)
		end
	end
	
	-- beacon 2
	if math.random(1,4) == 1 then
		local search_center = {center.x+8  , center.y}
		local building = create_city_building(surface, "beacon", search_center, {x=8, y=8})
		if building ~= nil then
			table.insert(global.machine_entities, building)
		end
	end
	
	-- lab // places a lab i presume
	if math.random(1,10)==1 and silo==0 then
		local search_center = {center.x  , center.y}
		local building = create_city_building(surface, "lab", search_center, {x=8, y=8})
		if building ~= nil then
			table.insert(global.machine_entities, building)
		end
	end

	-- paves around the city
	paved = {}	
	tiles=
	{
		"dry-dirt",
		"stone-path",
		"concrete",
		"hazard-concrete-left",
		"refined-concrete",
		"refined-hazard-concrete-right",
		"tutorial-grid",
	}
	
	for i,v in ipairs(pavement) do
	paved[i]={name = tiles[math.max(city_tier,city_tier2)], position = v} 
	end
	game.surfaces[1].set_tiles(paved)
end

