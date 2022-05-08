
DEBUG = true -- Used for debug, users should not enable
local debugCount = 0 -- Stops debugging messages
local debugMaxCount = 0 -- Maximum debug messages, 0 for infinite
local debugType = "File" -- "File" to output to a .log file, "Terminal" to output to terminal, anything else to output to in-game console

-- Writes to the final debug output method based on type selection
local function debugWriteType(text)
	if debugType == "File" then
		game.write_file("traderouteoverhaul-debug.log", text, true)
	elseif debugType == "Terminal" then
		log(text)
	else
		game.print(text)
	end
end

-- Debug writer for calling elsewhere in the program
function debugWrite(text)
	if DEBUG then
		debugCount = debugCount + 1
		if debugMaxCount == 0 or debugCount < debugMaxCount then
			debugWriteType(text)
		elseif debugCount == debugMaxCount then 
			debugWriteType("Message count at " .. debugMaxCount .. ", logging stopped")
		end
	end
end

local a = 214013 
local c = 2531011 
local M = 0x80000000
local state = settings.startup["base-item-values-seed"].value

-- Returns an integer from 0 to N - 1
function rand(N)
	state = (a * state + c) % M
	return (math.floor( N*state / M ))
end

--control.lua
global.machine_entities={}
global.machine_pointer = 1
global.city_locations={}
global.city_need_map={}
--on_chunk_generated
--Called when a chunk is generated.
--Contains
--area :: BoundingBox: Area of the chunk
--surface :: LuaSurface: The surface the chunk is on
--cities
cities = {
	"assembling-machine-1",
	"assembling-machine-2",
	"assembling-machine-3"
}

minimum_city_distance = 100
minimum_city_distance = settings.global["minimum-city-distance"].value

cycles = { {1,2,3,4}, {1,2,3,4,5}, {1,2,3,4,5,6}, {{1,3,5},{2,4,6}}, {1,2,3,4,5,6,7}, {1,2,3,4,5,6,7} }
trade_map_set = { 
	{ {2,3,4}, {1,3,4}, {1,2,4}, {1,2,3} }, 
	{ {2,3}, {3,4}, {4,5}, {5,1}, {1,2} }, 
	{ {2,3,4}, {3,4}, {4,5,6}, {5,6}, {6,1,2}, {1,2} }, 
	{ {2,4}, {3,4,6}, {4,6}, {5,6}, {2,6}, {1} }, 
	{ {2,3,4}, {3,4,5}, {4,5,6}, {5,6,7}, {6,7,1}, {7,1,2}, {1,2,3} }, 
	{ {2,3}, {3,4}, {4,5}, {5,6}, {6,7}, {7,1}, {1,2} } 
}
global.trade_map = { 
	{ {}, {}, {}, {} }, 
	{ {}, {}, {}, {}, {} }, 
	{ {}, {}, {}, {}, {}, {} }, 
	{ {}, {}, {}, {}, {}, {} }, 
	{ {}, {}, {}, {}, {}, {}, {} }, 
	{ {}, {}, {}, {}, {}, {}, {} } 
}
bad_trade_map_set = { 
	{ {}, {}, {}, {} }, 
	{ {4,5}, {5,1}, {1,2}, {2,3}, {3,4} }, 
	{ {5,6}, {5,6,1}, {1,2}, {1,2,3}, {3,4}, {3,4,5} }, 
	{ {6}, {1,5}, {2}, {1,2,3}, {4}, {2,3,4,5} }, 
	{ {5,6,7}, {6,7,1}, {7,1,2}, {1,2,3}, {2,3,4}, {3,4,5}, {4,5,6} }, 
	{ {4,5,6,7}, {5,6,7,1}, {6,7,1,2}, {7,1,2,3}, {1,2,3,4}, {2,3,4,5}, {3,4,5,6} } 
}
global.bad_trade_map = { 
	{ {}, {}, {}, {} }, 
	{ {}, {}, {}, {}, {} }, 
	{ {}, {}, {}, {}, {}, {} }, 
	{ {}, {}, {}, {}, {}, {} }, 
	{ {}, {}, {}, {}, {}, {}, {} }, 
	{ {}, {}, {}, {}, {}, {}, {} } 
}

--spawn cities on chunk generation
script.on_event({defines.events.on_chunk_generated},
   function (e)
		if math.random(1,100)>math.max(1,settings.global["probability-of-city-placement"].value) then return end
		spawn_city(e)
	end
)

script.on_init(function()
	global.players = {}
	-- removed crashsite and cutscene start, so on_player_created inventory safe
	remote.call("freeplay", "set_disable_crashsite", true)  
	
	-- Skips popup message to press tab to start playing
	remote.call("freeplay", "set_skip_intro", true)

	--game.surfaces.nauvis.always_day = true
	--end recipes
	if game.forces["player"].stack_inserter_capacity_bonus < 7 then
		game.forces["player"].stack_inserter_capacity_bonus = 7
	end
	if game.forces["player"].inserter_stack_size_bonus < 3 then
		game.forces["player"].inserter_stack_size_bonus = 3
	end
	
	--spawn starting buildings
	found = game.surfaces[1].find_non_colliding_position("rocket-silo", {0,0}, 0, 3) 
	if found then
		city = game.surfaces[1].create_entity{name="rocket-silo", position=found, force=game.forces.player} 
		--prevent removal of cities as thats game breaking
		city.destructible = false
		city.minable = false
		--prevent player from changing trades
		city.recipe_locked = true 
		city.operable =true
	end --end if

	-- need coal source
	foundcoal = game.surfaces[1].find_non_colliding_position("assembling-machine-1", {math.random(-1, 1)*8,math.random(-1, 1)*8}, 30, 8, true) 
	if foundcoal then
		city = game.surfaces[1].create_entity{name="assembling-machine-1", position=foundcoal, force=game.forces.player, recipe ="Coal"}
		--prevent removal of cities as thats game breaking
		city.destructible = false
		city.minable = false
		
		--prevent player from changing trades
		city.recipe_locked = true 
		
		city.operable =true
		table.insert(global.machine_entities, city)
	end
	foundcoal = game.surfaces[1].find_non_colliding_position("assembling-machine-1", {math.random(-1, 1)*8,math.random(-1, 1)*8}, 30, 8, true) 
	if foundcoal then
		if settings.global["start-with-trains"].value then
			city = game.surfaces[1].create_entity{name="assembling-machine-1", position=foundcoal, force=game.forces.player, recipe ="Rails"}
						--prevent removal of cities as thats game breaking
						city.destructible = false
						city.minable = false
						
						--prevent player from changing trades
						city.recipe_locked = true 
						
						city.operable =true
						table.insert(global.machine_entities, city)
		else
			city = game.surfaces[1].create_entity{name="assembling-machine-1", position=foundcoal, force=game.forces.player, recipe ="Belts"}
						--prevent removal of cities as thats game breaking
						city.destructible = false
						city.minable = false
						
						--prevent player from changing trades
						city.recipe_locked = true 
						
						city.operable =true
						table.insert(global.machine_entities, city)
		end
	end

	function shuffle (input)
		local output = input
		for n=1,#output-1 do
		 roll = rand(#output-n+1)+n
		 temp = output[n]
		 output[n] = output[roll]
		 output[roll] = temp
		end
		return output
	end
	cycles = { shuffle(cycles[1]), shuffle(cycles[2]), shuffle(cycles[3]), {shuffle(cycles[4][1]),shuffle(cycles[4][2])}, shuffle(cycles[5]), shuffle(cycles[6]) }
	cycles[4] = { cycles[4][1][1], cycles[4][2][1], cycles[4][1][2], cycles[4][2][2], cycles[4][1][3], cycles[4][2][3] }
	for i=1,#trade_map_set do
		for j=1,#trade_map_set[i] do
			for k=1,#trade_map_set[i][j] do
				table.insert(global.trade_map[i][ cycles[i][j] ], cycles[i][ trade_map_set[i][j][k] ])
				--trade_map[i][ cycles[i][j] ][k] = cycles[i][ trade_map_set[i][j][k] ]
			end
		end
	end
	for i=2,#bad_trade_map_set do
		for j=1,#bad_trade_map_set[i] do
			for k=1,#bad_trade_map_set[i][j] do
				table.insert(global.bad_trade_map[i][ cycles[i][j] ], cycles[i][ bad_trade_map_set[i][j][k] ])
				--trade_map[i][ cycles[i][j] ][k] = cycles[i][ trade_map_set[i][j][k] ]
			end
		end
	end
end)

script.on_event(defines.events.on_player_created, function(e)
	--wipe inventory as we dont want starter machines available

	local player = game.get_player(e.player_index)
	  player.clear_items_inside()
	--remove all tech on spawn (if this causes problems it should prolly be moved to init as its faction based not player based - but this ensures a player exists)
	  --game.forces["player"].disable_research()
	--given started coin
	player.insert({name="transport-belt", count=1000})
	player.insert({name="splitter", count=50})
	player.insert({name="underground-belt", count=50})
	player.insert({name="loader", count=50})
	player.insert({name="wooden-chest", count=50})
	player.insert({name="car", count=1})
	
	if settings.global["start-with-trains"].value then
		player.insert({name="rail", count=1000})
		player.insert({name="train-stop", count=10})
		player.insert({name="rail-signal", count=50})
		player.insert({name="rail-chain-signal", count=50})
		player.insert({name="locomotive", count=5})
		player.insert({name="cargo-wagon", count=5})
		player.insert({name="fast-inserter", count=50})
	end
	--set filters and bars
	player.set_active_quick_bar_page(1, 10)
	player.set_active_quick_bar_page(2, 1)
	player.set_active_quick_bar_page(3, 2)
	player.set_active_quick_bar_page(4, 3)

	--tier 1
	  player.set_quick_bar_slot(1,"stone")
	  player.set_quick_bar_slot(2,"coal")
	  player.set_quick_bar_slot(3,"copper-ore")
	  player.set_quick_bar_slot(4,"iron-ore")
	  player.set_quick_bar_slot(10, "automation-science-pack")
	--tier 2
	  player.set_quick_bar_slot(11,"copper-cable")
	  player.set_quick_bar_slot(12,"iron-stick")
	  player.set_quick_bar_slot(13,"stone-brick")
	  player.set_quick_bar_slot(14,"copper-plate")
	  player.set_quick_bar_slot(15,"iron-plate")
	  player.set_quick_bar_slot(20, "logistic-science-pack")
	  --tier 3
	  player.set_quick_bar_slot(21,"pipe")
	  player.set_quick_bar_slot(22,"steel-plate")
	  player.set_quick_bar_slot(23,"iron-gear-wheel")
	  player.set_quick_bar_slot(24,"electronic-circuit")
	  player.set_quick_bar_slot(25,"firearm-magazine")
	  player.set_quick_bar_slot(26,"stone-wall")
	  player.set_quick_bar_slot(30, "military-science-pack")
	--tier 4
	  player.set_quick_bar_slot(31,"lubricant-barrel")
	  player.set_quick_bar_slot(32,"plastic-bar")
	  player.set_quick_bar_slot(33,"petroleum-gas-barrel")
	  player.set_quick_bar_slot(34,"explosives")
	  player.set_quick_bar_slot(35,"sulfuric-acid-barrel")
	  player.set_quick_bar_slot(36,"rocket-fuel")
	  player.set_quick_bar_slot(40, "chemical-science-pack")
	--tier 5
	  player.set_quick_bar_slot(41,"engine-unit")
	  player.set_quick_bar_slot(42,"advanced-circuit")
	  player.set_quick_bar_slot(43,"low-density-structure")
	  player.set_quick_bar_slot(44,"electric-engine-unit")
	  player.set_quick_bar_slot(45,"speed-module")
	  player.set_quick_bar_slot(46,"effectivity-module")
	  player.set_quick_bar_slot(47,"productivity-module")
	  player.set_quick_bar_slot(50, "production-science-pack")
	--tier 6
	  player.set_quick_bar_slot(51,"battery")
	  player.set_quick_bar_slot(52,"electric-engine-unit")
	  player.set_quick_bar_slot(53,"logistic-robot")
	  player.set_quick_bar_slot(54,"construction-robot")
	  player.set_quick_bar_slot(55,"processing-unit")
	  player.set_quick_bar_slot(56,"rocket-control-unit")
	  player.set_quick_bar_slot(57,"atomic-bomb")
	  player.set_quick_bar_slot(60, "utility-science-pack")
	  
	--utility bar 0
	player.set_quick_bar_slot(91, "transport-belt")
	player.set_quick_bar_slot(92, "splitter")
	player.set_quick_bar_slot(93, "underground-belt")
	player.set_quick_bar_slot(94, "loader")
	player.set_quick_bar_slot(95, "wooden-chest")
	player.set_quick_bar_slot(96, "radar")
	player.set_quick_bar_slot(97, "car")
	player.set_quick_bar_slot(98, "coal")
	player.set_quick_bar_slot(99, "repair-pack")
end)

function spawn_city (e)

	trades = { 1, 4, 5, 6, 6, 7, 7 }
	malls = { 9, 7, 5, 7, 9, 10, 6, 10, 7, 4, 6, 6 }
	malltrades = { 3, 5, 6, 3, 7, 7 }
	
	local center = {}
	center.x = e.area.right_bottom.x - math.random(0,31)
	center.y = e.area.right_bottom.y - math.random(0,31)
	
	traders = game.surfaces[1].find_entities_filtered{position = center, type = "assembling-machine", radius = minimum_city_distance}
	if next(traders) ~= nil then return end
	
	local area = {{center.x-20,center.y-20},{center.x+20,center.y+20}}
	-- If only obstacle is trees, remove the trees
	for index, entity in pairs(game.surfaces[1].find_entities(area)) do
		if entity.valid and (entity.type == "tree" or entity.type == "simple-entity") then
			entity.destroy()
		end
	end
	
	pavement = {}
	local recorded =false
	local science_city = false
	local city_tier = get_city_tier(center)
	local city_tier2 = get_city_tier(center)
	
	local buildingroll = math.random(1,6)
	buildingtype="assembling-machine-3"
	if buildingroll<6 then buildingtype="assembling-machine-2" end
	if buildingroll<4 then buildingtype="assembling-machine-1" end
	
	local item_values = {
		{ math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100) },
		{ math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100) },
		{ math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100) },
		{ math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100) },
		{ math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100) },
		{ math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100),math.random(1,100) },
		{ math.random(1,100) }, }
	item_values[6][2] = item_values[5][4]
	
	function bits(input)
		local output = {}
		for n=1,7 do
			if math.floor(input/math.pow(2,n-1))%2==1 then table.insert(output,n) end
		end
		return output
	end
	
	local thing = {1,4,5,16,17,20}
	local dontwant6 = { 4,8,16,31,32,47,55,59}
	local dontwant7 = { 4,8,16,32,63,64,95,111,119,123 } 
	local wants = { 13, 31+0*math.random(1,30), math.random(1+2,50+2), {math.random(1,6), math.random(1,6) }, math.random(1+2,112+2), math.random(1+2,112+2) }
	local wants4 = bits( 2*thing[wants[4][2]] )
	local gives4 = bits( thing[7-wants[4][1]] )
	wants[4] = thing[wants[4][1]]+2*thing[wants[4][2]]
	for n=1,10-2,1 do
	 if wants[3]>=dontwant6[n] then wants[3] = wants[3]+1 end
	end
	for n=1,12-2,1 do
	 if wants[5]>=dontwant7[n] then wants[5] = wants[5]+1 end
	 if wants[6]>=dontwant7[n] then wants[6] = wants[6]+1 end
	end
	local gives = { 15, math.random(1,30), 63-wants[3], 63-wants[4], 127-wants[5], 127-wants[6] }
	local wants2 = { bits(wants[1]), bits(wants[2]), bits(wants[3]), bits(wants[4]), bits(wants[5]), bits(wants[6]) }
	local gives2 = { bits(gives[1]), bits(gives[2]), bits(gives[3]), bits(gives[4]), bits(gives[5]), bits(gives[6]) }

	
	
	--mall
	local whichmall = 2*city_tier-math.random(0,1)
	local a = wants2[city_tier][ math.random(1,#wants2[city_tier]) ]
	if city_tier==4 then a = wants4[ math.random(1,#wants4) ] end
	--if city_tier==1 and a>1 then a=a+1 end
	--if city_tier==4 then a = a*2 end
	local fromitem = city_tier.."-"..a
	if whichmall%2==0 then 
	 fromitem = "7-"..city_tier 
	 a = #item_values[city_tier]
	end
		
	for i=1,malls[ whichmall ],1 do
	local r = math.floor( 21*math.log(2*(69+30*city_tier+50)/(69+30*city_tier+item_values[city_tier][ a ]))/math.log(4) )
	chosen_recipe = "mall-"..fromitem.."-"..whichmall.."-"..i.."-"..r

	found = game.surfaces[1].find_non_colliding_position("assembling-machine-1", {center.x +((i-1)%5)*8-16 , center.y +math.floor((i-1)/5)*8+8 } , 30, 4, true)
			if found then
				--pavement locations for new city
				local top_left = {x = found.x -4, y=found.y -4}
					for l=top_left.x, top_left.x+8, 1 do
						for w=top_left.y,top_left.y +8,1 do
						table.insert(pavement, {x=l, y=w})
						end
					end
			building = e.surface.create_entity{name=buildingtype, position= found, force=game.forces.player, recipe = chosen_recipe} 
			--prevent removal of cities as thats game breaking
			building.destructible = false
			building.minable = false
			--prevent player from changing trades
			building.recipe_locked = true 
			building.operable =true
			
			table.insert(global.machine_entities, building)
			end
	end --city for
	
	
	
	--satelite
	if city_tier>4 and math.random(1,5)>1 then
	local r = math.floor( 21*math.log(2*(69+30*city_tier+item_values[6][8])/(69+30*city_tier+item_values[7][1]))/math.log(4) )
	local possible_recipes = { "s-1-3-"..city_tier.."-"..r, "s-1-4-"..city_tier.."-"..r, "s-2-3-"..city_tier.."-"..r, "s-2-4-"..city_tier.."-"..r, "satellite-"..r }
	chosen_recipe = possible_recipes[ math.random(1,5) ]

	found = game.surfaces[1].find_non_colliding_position("assembling-machine-1", {center.x +((10-1)%5)*8-16 , center.y +math.floor((10-1)/5)*8+8 } , 30, 4, true)
			if found then
				--pavement locations for new city
				local top_left = {x = found.x -4, y=found.y -4}
					for l=top_left.x, top_left.x+8, 1 do
						for w=top_left.y,top_left.y +8,1 do
						table.insert(pavement, {x=l, y=w})
						end
					end
			building = e.surface.create_entity{name=buildingtype, position= found, force=game.forces.player, recipe = chosen_recipe} 
			--prevent removal of cities as thats game breaking
			building.destructible = false
			building.minable = false
			--prevent player from changing trades
			building.recipe_locked = true 
			building.operable =true
			
			table.insert(global.machine_entities, building)
			end
	end
	
	
	
	--silo
	local silo = 0
	if city_tier==6 and math.random(1,4)==1 then 
	silo = 1
	found = game.surfaces[1].find_non_colliding_position("rocket-silo", {center.x  , center.y  } , 30, 4, true)
			if found then
				record_city(7, found, science_city)
				--pavement locations for new city
				local top_left = {x = found.x -7, y=found.y -7}
					for l=top_left.x, top_left.x+14, 1 do
						for w=top_left.y,top_left.y +14,1 do
						table.insert(pavement, {x=l, y=w})
						end
					end
			building = e.surface.create_entity{name="rocket-silo", position= found, force=game.forces.player} 
			--prevent removal of cities as thats game breaking
			building.destructible = false
			building.minable = false
			--prevent player from changing trades
			building.operable =true
			
			table.insert(global.machine_entities, building)
			end
	end
	
	
	
	--science 1
	if city_tier == 4 and buildingtype=="assembling-machine-1" then buildingtype = "assembling-machine-2" end
	
	local r = math.floor( 21*math.log(2*(69+30*city_tier+item_values[city_tier][ #item_values[city_tier]-1 ])/(69+30*city_tier+item_values[city_tier][ #item_values[city_tier] ]))/math.log(4) )
	chosen_recipe = "T"..city_tier.."-Science-"..r

	found = game.surfaces[1].find_non_colliding_position("assembling-machine-1", {center.x +16  , center.y  } , 30, 4, true)
			if found then
				record_city(city_tier, found, science_city)
				--pavement locations for new city
				local top_left = {x = found.x -4, y=found.y -4}
					for l=top_left.x, top_left.x+8, 1 do
						for w=top_left.y,top_left.y +8,1 do
						table.insert(pavement, {x=l, y=w})
						end
					end
			building = e.surface.create_entity{name=buildingtype, position= found, force=game.forces.player, recipe = chosen_recipe} 
			--prevent removal of cities as thats game breaking
			building.destructible = false
			building.minable = false
			--prevent player from changing trades
			building.recipe_locked = true 
			building.operable =true
			
			table.insert(global.machine_entities, building)
			end



	--uptier trades 1
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
	chosen_recipe = "Trade-"..c.."-"..a.."-"..city_tier.."-"..b.."-"..r

	found = game.surfaces[1].find_non_colliding_position("assembling-machine-1", {center.x +((i-1)%5)*8-16 , center.y -math.floor((i-1)/5)*8-8 } , 30, 4, true)
			if found then
				--pavement locations for new city
				local top_left = {x = found.x -4, y=found.y -4}
					for l=top_left.x, top_left.x+8, 1 do
						for w=top_left.y,top_left.y +8,1 do
						table.insert(pavement, {x=l, y=w})
						end
					end
			building = e.surface.create_entity{name=buildingtype, position= found, force=game.forces.player, recipe = chosen_recipe} 
			--prevent removal of cities as thats game breaking
			building.destructible = false
			building.minable = false
			--prevent player from changing trades
			building.recipe_locked = true 
			building.operable =true
			
			table.insert(global.machine_entities, building)
			end
	end --city for
	
	
	
	--intier trades 1
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
	--if city_tier==4 and a%2==0 and b%2==0 then b=b-1 end
	--if city_tier==4 and a%2==1 and b%2==1 then b=b+1 end
	local r = possible_recipes[choice][3]
	chosen_recipe = "Trade-"..city_tier.."-"..a.."-"..city_tier.."-"..b.."-"..r

	found = game.surfaces[1].find_non_colliding_position("assembling-machine-1", {center.x +((i-1)%5)*8-16 , center.y -math.floor((i-1)/5)*8-8 } , 30, 4, true)
			if found then
				--pavement locations for new city
				local top_left = {x = found.x -4, y=found.y -4}
					for l=top_left.x, top_left.x+8, 1 do
						for w=top_left.y,top_left.y +8,1 do
						table.insert(pavement, {x=l, y=w})
						end
					end
			building = e.surface.create_entity{name=buildingtype, position= found, force=game.forces.player, recipe = chosen_recipe} 
			--prevent removal of cities as thats game breaking
			building.destructible = false
			building.minable = false
			--prevent player from changing trades
			building.recipe_locked = true 
			building.operable =true
			
			table.insert(global.machine_entities, building)
			end
	end --city for
	
	
	
	--bad trades 1
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
	--if city_tier==4 and a%2==0 and b%2==0 then b=b-1 end
	--if city_tier==4 and a%2==1 and b%2==1 then b=b+1 end
	local r = math.max(1,math.floor( 21*math.log(2*(69+30*city_tier+item_values[city_tier][a])/(69+30*city_tier+item_values[city_tier][b]))/math.log(4) )-2)
	chosen_recipe = "Trade-"..city_tier.."-"..a.."-"..city_tier.."-"..b.."-"..r

	found = game.surfaces[1].find_non_colliding_position("assembling-machine-1", {center.x +((i-1)%5)*8-16 , center.y -math.floor((i-1)/5)*8-8 } , 30, 4, true)
			if found then
				--pavement locations for new city
				local top_left = {x = found.x -4, y=found.y -4}
					for l=top_left.x, top_left.x+8, 1 do
						for w=top_left.y,top_left.y +8,1 do
						table.insert(pavement, {x=l, y=w})
						end
					end
			building = e.surface.create_entity{name=buildingtype, position= found, force=game.forces.player, recipe = chosen_recipe} 
			--prevent removal of cities as thats game breaking
			building.destructible = false
			building.minable = false
			--prevent player from changing trades
			building.recipe_locked = true 
			building.operable =true
			
			table.insert(global.machine_entities, building)
			end
	end --city if
	
	
	
	--science 2
	if city_tier2~=city_tier then
	if city_tier2 == 4 and buildingtype=="assembling-machine-1" then buildingtype = "assembling-machine-2" end
	
	local r = math.floor( 21*math.log(2*(69+30*city_tier2+item_values[city_tier2][ #item_values[city_tier2]-1 ])/(69+30*city_tier2+item_values[city_tier2][ #item_values[city_tier2] ]))/math.log(4) )
	chosen_recipe = "T"..city_tier2.."-Science-"..r

	found = game.surfaces[1].find_non_colliding_position("assembling-machine-1", {center.x -16  , center.y  } , 30, 4, true)
			if found then
				record_city(city_tier2, found, science_city)
				--pavement locations for new city
				local top_left = {x = found.x -4, y=found.y -4}
					for l=top_left.x, top_left.x+8, 1 do
						for w=top_left.y,top_left.y +8,1 do
						table.insert(pavement, {x=l, y=w})
						end
					end
			building = e.surface.create_entity{name=buildingtype, position= found, force=game.forces.player, recipe = chosen_recipe} 
			--prevent removal of cities as thats game breaking
			building.destructible = false
			building.minable = false
			--prevent player from changing trades
			building.recipe_locked = true 
			building.operable =true
			
			table.insert(global.machine_entities, building)
			end
	end



	--uptier trades 2
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

	found = game.surfaces[1].find_non_colliding_position("assembling-machine-1", {center.x +((i-1)%5)*8-16 , center.y -math.floor((i-1)/5)*8-8 } , 30, 4, true)
			if found then
				--pavement locations for new city
				local top_left = {x = found.x -4, y=found.y -4}
					for l=top_left.x, top_left.x+8, 1 do
						for w=top_left.y,top_left.y +8,1 do
						table.insert(pavement, {x=l, y=w})
						end
					end
			building = e.surface.create_entity{name=buildingtype, position= found, force=game.forces.player, recipe = chosen_recipe} 
			--prevent removal of cities as thats game breaking
			building.destructible = false
			building.minable = false
			--prevent player from changing trades
			building.recipe_locked = true 
			building.operable =true
			
			table.insert(global.machine_entities, building)
			end
	end --city for
	
	
	
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
	--if city_tier2==4 and a%2==0 and b%2==0 then b=b-1 end
	--if city_tier2==4 and a%2==1 and b%2==1 then b=b+1 end
	local r = possible_recipes[choice][3]
	chosen_recipe = "Trade-"..city_tier2.."-"..a.."-"..city_tier2.."-"..b.."-"..r

	found = game.surfaces[1].find_non_colliding_position("assembling-machine-1", {center.x +((i-1)%5)*8-16 , center.y -math.floor((i-1)/5)*8-8 } , 30, 4, true)
			if found then
				--pavement locations for new city
				local top_left = {x = found.x -4, y=found.y -4}
					for l=top_left.x, top_left.x+8, 1 do
						for w=top_left.y,top_left.y +8,1 do
						table.insert(pavement, {x=l, y=w})
						end
					end
			building = e.surface.create_entity{name=buildingtype, position= found, force=game.forces.player, recipe = chosen_recipe} 
			--prevent removal of cities as thats game breaking
			building.destructible = false
			building.minable = false
			--prevent player from changing trades
			building.recipe_locked = true 
			building.operable =true
			
			table.insert(global.machine_entities, building)
			end
	end --city for
	
	
	
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
	--if city_tier==4 and a%2==0 and b%2==0 then b=b-1 end
	--if city_tier==4 and a%2==1 and b%2==1 then b=b+1 end
	local r = math.max(1,math.floor( 21*math.log(2*(69+30*city_tier2+item_values[city_tier2][a])/(69+30*city_tier2+item_values[city_tier2][b]))/math.log(4) )-2)
	chosen_recipe = "Trade-"..city_tier2.."-"..a.."-"..city_tier2.."-"..b.."-"..r

	found = game.surfaces[1].find_non_colliding_position("assembling-machine-1", {center.x +((i-1)%5)*8-16 , center.y -math.floor((i-1)/5)*8-8 } , 30, 4, true)
			if found then
				--pavement locations for new city
				local top_left = {x = found.x -4, y=found.y -4}
					for l=top_left.x, top_left.x+8, 1 do
						for w=top_left.y,top_left.y +8,1 do
						table.insert(pavement, {x=l, y=w})
						end
					end
			building = e.surface.create_entity{name=buildingtype, position= found, force=game.forces.player, recipe = chosen_recipe} 
			--prevent removal of cities as thats game breaking
			building.destructible = false
			building.minable = false
			--prevent player from changing trades
			building.recipe_locked = true 
			building.operable =true
			
			table.insert(global.machine_entities, building)
			end
	end --city if
	
	
	
	--beacon
	if math.random(1,4) == 1 then
	found = game.surfaces[1].find_non_colliding_position("beacon", {center.x-8  , center.y  } , 30, 4, true)
			if found then
				--pavement locations for new city
				local top_left = {x = found.x -4, y=found.y -4}
					for l=top_left.x, top_left.x+8, 1 do
						for w=top_left.y,top_left.y +8,1 do
						table.insert(pavement, {x=l, y=w})
						end
					end
			building = e.surface.create_entity{name="beacon", position= found, force=game.forces.player} 
			--prevent removal of cities as thats game breaking
			building.destructible = false
			building.minable = false
			--prevent player from changing trades
			building.operable =true
			
			table.insert(global.machine_entities, building)
			end
	end
	
	
	
	--beacon 2
	if math.random(1,4) == 1 then
	found = game.surfaces[1].find_non_colliding_position("beacon", {center.x+8  , center.y  } , 30, 4, true)
			if found then
				--pavement locations for new city
				local top_left = {x = found.x -4, y=found.y -4}
					for l=top_left.x, top_left.x+8, 1 do
						for w=top_left.y,top_left.y +8,1 do
						table.insert(pavement, {x=l, y=w})
						end
					end
			building = e.surface.create_entity{name="beacon", position= found, force=game.forces.player} 
			--prevent removal of cities as thats game breaking
			building.destructible = false
			building.minable = false
			--prevent player from changing trades
			building.operable =true
			
			table.insert(global.machine_entities, building)
			end
	end
	
	
	
	--lab
	if math.random(1,10)==1 and silo==0 then
	found = game.surfaces[1].find_non_colliding_position("lab", {center.x  , center.y  } , 30, 4, true)
			if found then
				--pavement locations for new city
				local top_left = {x = found.x -4, y=found.y -4}
					for l=top_left.x, top_left.x+8, 1 do
						for w=top_left.y,top_left.y +8,1 do
						table.insert(pavement, {x=l, y=w})
						end
					end
			building = e.surface.create_entity{name="lab", position= found, force=game.forces.player} 
			--prevent removal of cities as thats game breaking
			building.destructible = false
			building.minable = false
			--prevent player from changing trades
			building.operable =true
			
			table.insert(global.machine_entities, building)
			end
	end

	
	
	
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

function get_city_tier(coord)
	max_tier = 1
	x = math.abs(coord.x)
	y= math.abs(coord.y)

	local factor = 1

	if x > factor*1.5*minimum_city_distance or y > factor*1.5*minimum_city_distance then max_tier = 2 end
	if x > factor*2.5*minimum_city_distance or y > factor*2.5*minimum_city_distance then max_tier = 3 end
	if x > factor*3.5*minimum_city_distance or y > factor*3.5*minimum_city_distance then max_tier = 4 end
	if x > factor*4.5*minimum_city_distance or y > factor*4.5*minimum_city_distance then max_tier = 5 end
	if x > factor*5.5*minimum_city_distance or y > factor*5.5*minimum_city_distance then max_tier = 6 end

	tier = math.random(1, max_tier)

	return tier
end

function record_city(tier, loc, science)
	--table.insert(global.city_locations, {loc=loc,tier=tier, mapped = false, road=false, science= science})
	table.insert(global.city_need_map, {loc=loc, tier=tier, science= science})
end

script.on_event(defines.events.on_script_path_request_finished, function(e)
	if e.path ~=nil and next(e.path) ~=nil then
	--game.get_player(1).print("path")
		pavement ={}
		for k,v in ipairs(e.path)do
		table.insert(pavement, v.position)
		--game.get_player(1).print(v.position)
		end
			tiles=
		{
		--"dry-dirt",
		--"stone-path",
		--"concrete",
		--"hazard-concrete-left",
		"refined-concrete",
		"refined-hazard-concrete-right",
		--"tutorial-grid",
		}
		for i,v in ipairs(pavement) do
		paved[i]={name = tiles[math.random(#tiles)], position = v} 
		end
		game.surfaces[1].set_tiles(paved)
	end
end)

function distance ( x1, y1, x2, y2 )
	local dx = x1 - x2
	local dy = y1 - y2
	return math.sqrt ( dx * dx + dy * dy )
end

if settings.global["map-tags"].value then
	script.on_event({defines.events.on_tick},
	   function (e)
		if e.tick > 100 and e.tick % 2 == 0 then 
			update_map()
		end
	end
	)
end

function update_map()
	if next(global.city_need_map) ~= nil then       
		v = table.remove(global.city_need_map, math.random(#global.city_need_map))
		--game.get_player(1).print(#global.city_need_map)   
		--game.get_player(1).print("Popped V"..v.loc[1])        
	
		signalID = {type = "", name = ""}               
		--if v.science then
		signalID = {type = "item",}             
		if v.tier == 1 then signalID.name = "automation-science-pack" end
		if v.tier == 2 then signalID.name = "logistic-science-pack" end
		if v.tier == 3 then signalID.name = "military-science-pack" end
		if v.tier == 4 then signalID.name = "chemical-science-pack" end
		if v.tier == 5 then signalID.name = "production-science-pack" end
		if v.tier == 6 then signalID.name = "utility-science-pack" end
		if v.tier == 7 then signalID.name = "space-science-pack" end
		tag = {position=v.loc, text = "", icon = signalID}
		--end
		--if not v.science then tag = {position=v.loc, text = ""..v.tier.."" }  end 
		valid = game.players[1].force.add_chart_tag(game.surfaces[1], tag)
		if valid == nil then table.insert(global.city_need_map,v) 
		--game.get_player(1).print("repushed V"..v.loc[1])  
		end	
	end 
end --end function
--
--
-- GUI
--
--
function close_trade_menu(player)
	local player_global = global.players[player.index]
	local screen_element = player.gui.screen
	local main_frame = screen_element["tro_trade_root_frame"]

	main_frame.destroy()

	-- update players state
	player_global.trade_menu.active = not player_global.trade_menu.active
	reset_search_history(player)
end

function open_trade_menu(player)
	local player_global = global.players[player.index]
	local screen_element = player.gui.screen

	local root_frame = screen_element.add{type="frame", name="tro_trade_root_frame", direction="vertical"}

	create_title_bar(root_frame)

	root_frame.add{type="textfield", name="tro_trade_menu_search"}
	local trades_list = root_frame.add{type="scroll-pane", name="tro_trades_list", direction="vertical"}

	create_trade_menu_list_rows(trades_list, global.machine_entities, "", "any", player)
	
	root_frame.style.size = {800, 700}
	root_frame.auto_center = true
	player_global.trade_menu.active = not player_global.trade_menu.active
end

function create_title_bar(root_element)
	local header = root_element.add{type="flow", name="tro_trade_menu_header", direction="horizontal"}
	header.add{type="label", caption={"tro.trade_menu_title"}, style="frame_title"}
	local filler = header.add{type="empty-widget", style="draggable_space"}
	filler.style.height = 24
		filler.style.horizontally_stretchable = true
		filler.drag_target = root_element
	header.add{
		type = "sprite-button",
		name = "tro_trade_menu_header_exit_button",
		style = "frame_action_button",
		sprite = "utility/close_white",
		hovered_sprite = "utility/close_black",
		clicked_sprite = "utility/close_black",
		tooltip = {"gui.close-instruction"}
	}
end

-- creates each trade row from the list of machines and a filter. then adds the rows onto the list
function create_trade_menu_list_rows(list, machines, search_term, filter, player)

	-- filter out machines that are not assemblers
	local assemblers = {}
	for x, machine in ipairs(machines) do
		if machine.name == "assembling-machine-1" 
		or machine.name == "assembling-machine-2" 
		or machine.name == "assembling-machine-3" then
			table.insert(assemblers, machine)		
		end
	end

	-- filter assemblers according to filter
	local filtered_assemblers = {}
	for x, assembler in ipairs(assemblers) do
		local recipe = assembler.get_recipe()

		-- add any assemblers that have the searched term in their recipe
		if filter == "any" then 
			for i, product in ipairs(recipe.products) do
				if string.find(product.name, search_term, 0, true) then
					goto add_item
				end
			end
			for i, ingredient in ipairs(recipe.ingredients) do
				if string.find(ingredient.name, search_term, 0, true) then
					goto add_item
				end
			end
			::add_item::
			table.insert(filtered_assemblers, assembler)

		-- add assemblers where they produce the searched term
		elseif filter == "product" then
			for i, product in ipairs(recipe.products) do
				if string.find(product.name, search_term, 0, true) then
					table.insert(filtered_assemblers, assembler)
				end
			end

		-- add assemblers where they require the searched term to produce something
		elseif filter == "ingredient" then
			for i, ingredient in ipairs(recipe.ingredients) do
				if string.find(ingredient.name, search_term, 0, true) then
					table.insert(filtered_assemblers, assembler)
				end
			end
		end
	end


	if #filtered_assemblers > 0 then
		-- create a row for each recipe for each assembler
		for i, assembler in ipairs(filtered_assemblers) do
			local position = assembler.position
			local recipe = assembler.get_recipe()
			local ingredients = recipe.ingredients
			local products = recipe.products
			create_row(list, ingredients, products, position)
		end
	else 
		-- if list is empty, create a message saying as much
		local message_element = create_failed_search_message(list, player, filter)
	end
end

-- creates a ui explaining the search for an item failed as well as next steps
function create_failed_search_message(list, player, filter)
	local search_history = global.players[player.index].trade_menu.search_history
	local message_element = list.add{type="flow"}
	local horizontal_flow = message_element.add{type="flow", direction="horizontal"}

	-- main text
	if filter.product ~= nil and filter.ingredient ~= nil then
		horizontal_flow.add{type="label", caption="No recipes found."}
	elseif filter.product ~= nil then
		horizontal_flow.add{type="label", caption="No recipes create"}
		horizontal_flow.add{type="label", caption=filter.product}
	elseif filter.ingredient ~= nil then
		horizontal_flow.add{type="label", caption="No recipes require"}
		horizontal_flow.add{type="label", caption=filter.ingredient}
	end

	-- ending text
	if #search_history > 0 then
		message_element.add{type="label", caption='Try searching for something else. Or press "backspace" to see your last search!'}
	else
		message_element.add{type="label", caption="Try searching for something else!"}
	end
end

function create_row(list, ingredients, products, position)
	local trade_row = list.add{type="frame", style="tro_trade_row"}
	local trade_row_flow = trade_row.add{type="flow", style="tro_trade_row_flow"}
	trade_row_flow.add{type="button", caption="ping", name="tro_ping_button", tags={location=position}}
	
	if #ingredients >= 1 then
		for i, ingredient in ipairs(ingredients) do
			trade_row_flow.add{type="sprite-button", sprite = ingredient.type .. "/" .. ingredient.name, tags={action="tro_filter_list", item=ingredient.name, type="ingredient"}}
			trade_row_flow.add{type="label", caption = ingredient.amount}
		end
	end

	trade_row_flow.add{type="label", caption = " --->"}

	for i, product in ipairs(products) do
		trade_row_flow.add{type="sprite-button", sprite = product.type .. "/" .. product.name, tags={action="tro_filter_list", item=product.name, type="product"}}
		trade_row_flow.add{type="label", caption = product.amount}
	end
end

function add_term_to_player_search_history(player, search_item)
	local history = global.players[player.index].trade_menu.search_history
	local history_length = #history

	-- prevent repeating history (A,B,A,B,A,B) by removing second last if it matches new search
	if search_item == history[2] then
		table.remove(history, 2)
		table.insert(history, 1, search_item)

	-- dont add to history if it hasnt changed
	elseif search_item ~= history[1] then
		table.insert(history, 1, search_item)
	end

	-- stop history from going past max size for performance
	if history_length >= 100 then
		table.remove(history, history_length) -- remove oldest search term
	end

	-- debug, prints out search history
		-- local history_string = ""
		-- for i, search_term in ipairs(history) do
		-- 	history_string = history_string .. ", " .. search_term
		-- end
		-- game.print(history_string)
end

function remove_last_added_term_from_player_search_history(player)
	local history = global.players[player.index].trade_menu.search_history
	-- if theres no history then theres nothing to do
	if #history > 0 then
		table.remove(history, 1) -- remove first term from search history
	end
end

-- deletes the search history
function reset_search_history(player)
	global.players[player.index].trade_menu.search_history = {}
end

function move_backward_in_trade_menu_search_history(player)
	remove_last_added_term_from_player_search_history(player)
	local search_history = global.players[player.index].trade_menu.search_history

	local new_search = ""

	if #search_history >= 1 then
		new_search = search_history[1]
	end

	update_trade_menu_search(player, new_search, false)
end

-- updates the trade menu window search bar and search list based on search text
function update_trade_menu_search(player, searched_term, add_to_search_history)
	if add_to_search_history then
		add_term_to_player_search_history(player, searched_term)
	end

	-- update search field
	local textfield = player.gui.screen["tro_trade_root_frame"]["tro_trade_menu_search"]
	textfield.text = searched_term

	-- convert search into proper data structure
	local search_filter = ""
	if string.find(searched_term, "product:") then
		searched_term = string.gsub(searched_term, "product:", "")
		search_filter = "product"
	elseif string.find(searched_term, "ingredient:") then
		searched_term = string.gsub(searched_term, "ingredient:", "")
		search_filter = "ingredient"
	else
		search_filter = "any"
	end
		
	-- update trades list
	local trades_list = player.gui.screen["tro_trade_root_frame"]["tro_trades_list"]
	trades_list.clear()
	create_trade_menu_list_rows(trades_list, global.machine_entities, searched_term, search_filter, player)
end

-- opens players trade menu if closed; closes players trade menu if open
function toggle_trade_menu(player)
	local player_global = global.players[player.index]
	if player_global.trade_menu.active == false then
		open_trade_menu(player)
	else
		close_trade_menu(player)
	end
end

script.on_event(defines.events.on_player_joined_game, 
	function(event)
		local player = game.get_player(event.player_index)
		global.players[player.index] = {
			trade_menu = {
				active = false,
				search_history = {}
			}
		}
	end
)

script.on_event(defines.events.on_gui_click,
	function(event)
		local player = game.get_player(event.player_index)
		if event.element.name == "tro_trade_menu_header_exit_button" then
			close_trade_menu(player)

		elseif event.element.name == "tro_ping_button" then
			player.print("[gps=".. event.element.tags.location.x ..",".. event.element.tags.location.y .."]")

		-- click on sprite buttons
		elseif event.element.tags.action == "tro_filter_list" then
			if event.button == 4 then -- right mouse button
				local search_term = "ingredient:" .. event.element.tags.item
				update_trade_menu_search(player, search_term, true)

			elseif event.button == 2 then -- left mouse button
				local search_term = "product:" .. event.element.tags.item
				update_trade_menu_search(player, search_term, true)
			end
		end
	end
)

script.on_event(defines.events.on_lua_shortcut,
	function(event)
		local player = game.get_player(event.player_index)
		if event.prototype_name == "trades" then
			toggle_trade_menu(player)
		end
	end
)

script.on_event(defines.events.on_gui_text_changed,
	function(event)
		local player = game.get_player(event.player_index)
		local new_search = event.element.text
		update_trade_menu_search(player, new_search, false)
	end
)

script.on_event("move_backwards_in_search_history",
	function(event)
		local player = game.get_player(event.player_index)
		move_backward_in_trade_menu_search_history(player)
	end
)