Search_history = require("data.Search_history")

local Trades_menu = {
	active = false,
	search_history = Search_history:new(),
	filter = {
		traders=true,
		malls=true,
		ingredients=true,
		products=true
	}
}

function Trades_menu:new()
	local trades_menu = {
		active = false,
		search_history = Search_history:new(),
		filter = {
			group_by_city = true,
			traders = true,
			malls = true,
			ingredients = true,
			products = true
		}
	}
	setmetatable(trades_menu, self)
	self.__index = self

	return trades_menu
end

-- re-sets the metatable of an instance
function Trades_menu:reset_metatable(trades_menu_instance)
	setmetatable(trades_menu_instance, self)
	self.__index = self
end

-- opens players trade menu if closed; closes players trade menu if open
function Trades_menu:toggle(player)
	if self.active == false then
		self:open(player)
	else
		self:close(player)
	end
end

function Trades_menu:open(player)
	local player_global = global.players[player.index]
	local screen_element = player.gui.screen

	player.set_shortcut_toggled("trades", not self.active)
	local root_frame = screen_element.add{type="frame", name="tro_trade_root_frame", direction="vertical"}

	self:create_title_bar(root_frame)

	filter_flow = root_frame.add{type="flow", direction="horizontal", name="tro_filter_bar"}
	filter_flow.add{type="textfield", name="tro_trade_menu_search", tooltip = {"tro.trade_menu_textfield"}}
	filter_flow.add{
        type = "sprite-button",
        name = "tro_trade_menu_clear_search_button",
        style = "tool_button",
        sprite = "utility/close_black",
        hovered_sprite = "utility/close_white",
        clicked_sprite = "utility/close_white",
        tooltip = {"tro.trade_menu_clear_search"}
    }
    filter_flow.add{
        type = "sprite-button",
		name="tro_move_back_in_search_history_button",
        style = "tool_button",
        sprite = "utility/reset",
        tooltip = {"tro.trade_menu_back_but"},
        enabled = true -- #self.search_history >= 1
	}

    filter_flow.add{type="label", name="tro_trade_menu_spacer", caption="     "}

	filter_flow.add{
        type="checkbox",
		caption="Cities",
        name="tro_group_trades_checkbox",
		tooltip = {"tro.group_trades_button"},
        state = player_global.trades_menu.filter.group_by_city
	}

    filter_flow.add{type="label", name="tro_trade_menu_group_spacer", caption="     "}

    local switch_state = "none"
    if player_global.trades_menu.filter.traders == false then
        switch_state = "right"
    elseif player_global.trades_menu.filter.malls == false then
        switch_state = "left"
    end
	filter_flow.add{
        type="switch",
        name="tro_switch_traders_or_malls" ,
        allow_none_state=true,
        switch_state=switch_state ,
        left_label_caption={"tro.switch_traders_only"}, left_label_tooltip={"tro.switch_traders_only_tooltip"},
        right_label_caption={"tro.switch_malls_only"}, right_label_tooltip={"tro.switch_malls_only_tooltip"}
    }

	local filler = filter_flow.add{type="empty-widget"}
	filler.style.horizontally_stretchable = true

    filter_flow.add{
        type = "sprite-button",
        name = "tro_export_trades_csv",
        style = "tool_button",
        sprite = "utility/downloading",
        horizontal_align = "right",
        tooltip = "export all trades as transportorio-trades.csv to script-output dir"
    }

	local trades_list = root_frame.add{type="scroll-pane", name="tro_trades_list", direction="vertical", style="inventory_scroll_pane"}

	if #self.search_history >= 1 then
		local search_term = self.search_history[1].searched_item
		local filter = self.search_history[1].filter
		self:create_list_rows(trades_list, global.cities, search_term, filter, player)
        self:update_search_text(player, search_term, filter)
	else
		-- search for all
		self:create_list_rows(trades_list, global.cities, "", player)
	end
	
	root_frame.style.size = {800, 700}
	root_frame.auto_center = true
	self.active = not self.active
end

-- closes gui and resets search history
function Trades_menu:close(player)
	player.set_shortcut_toggled("trades", not self.active)
	self:destroy(player)
	self.search_history:reset()
end

-- closes gui without reseting search history
function Trades_menu:minimize(player)
	player.set_shortcut_toggled("trades", not self.active)
	self:destroy(player)
end

-- destroys the root gui element and all its child elements
function Trades_menu:destroy(player)
	local player_global = global.players[player.index]
	local screen_element = player.gui.screen
	local main_frame = screen_element["tro_trade_root_frame"]

	main_frame.destroy()

	-- update players state
	self.active = not self.active
end

-- updates the GUI search box
function Trades_menu:update_search_text(player, search, filter)
	local textfield = player.gui.screen["tro_trade_root_frame"]["tro_filter_bar"]["tro_trade_menu_search"]
	local text = ""

    if filter == nil or filter == "any" then
		text = search
	else
		text = filter .. ":" .. search
	end

	textfield.text = text
end

-- recreate the trades list
function Trades_menu:refresh_trades_list(player)
	local textfield = player.gui.screen["tro_trade_root_frame"]["tro_filter_bar"]["tro_trade_menu_search"]
	local current_search = convert_search_text_to_search_object(textfield.text)

	self:update_trades_list(player, current_search, false, false)
end

-- updates the trade menu window search bar and search list based on search text
function Trades_menu:update_trades_list(player, search, add_to_search_history, update_search_field)
	update_search_field = update_search_field or false

	-- if the trade menu isnt open you cant update it
	if self.active == false then
		return
	end

	if add_to_search_history then
		self.search_history:add_search(search)
	end

	if update_search_field then
		self:update_search_text(player, search.searched_item, search.filter)
	end
	-- update trades list
	local trades_list = player.gui.screen["tro_trade_root_frame"]["tro_trades_list"]
	trades_list.clear()

	-- update GUI filter
	if search.filter == "products" then
		self.filter["products"] = true
		self.filter["ingredients"] = false
	elseif search.filter == "ingredients" then
		self.filter["products"] = false
		self.filter["ingredients"] = true
	elseif search.filter == "" or search.filter == "any" then
		self.filter["products"] = true
		self.filter["ingredients"] = true
	else
		self.filter["products"] = false
		self.filter["ingredients"] = false
	end

	self:create_list_rows(trades_list, global.cities, search.searched_item, player)
end

function Trades_menu:create_title_bar(root_element)
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
		clicked_sprite = "utility/close_black"
	}
end

-- check an assemblers current recipe for an item. The filter decides whether to check the ingredients, products, or both.
function Trades_menu:check_assembler_recipe_for_item(assembler, item_name, filter)

    -- hide trades in unrevealed map areas, assembler needs to be visible on the map,
    -- prevents trades in new generated chunks are in the list before the machines are visible or explored
    local assembler_chunk_position = { math.floor(assembler.position.x / 32), math.floor(assembler.position.y / 32 )}
    if not game.forces.player.is_chunk_charted(game.surfaces[1], assembler_chunk_position) then
        return false
    end

	-- check if searchterm item_name is a game item name then  filter for this item  else make a "item.name contains ..." search
	local use_exact_match = false
	if item_name ~= nil and game.item_prototypes[item_name] ~= nil then
		use_exact_match = true
	end

	local recipe = assembler.get_recipe()
	-- check if the recipe has the item as a product
	if self.filter.products == false then goto ingredient end -- skip product search
	for i, product in ipairs(recipe.products) do
		if use_exact_match then
			if item_name == product.name then
				return true
			end
		else
			if string.find(product.name, item_name, 0, true) then
				return true
			end
		end
	end

	::ingredient::
	-- check if the recipe has the item as an ingredient
	if self.filter.ingredients == false then goto finish end -- skip ingredient search
	for i, ingredient in ipairs(recipe.ingredients) do
		if use_exact_match then
			if item_name == ingredient.name then
				return true
			end
		else
			if string.find(ingredient.name, item_name, 0, true) then
				return true
			end
		end
	end

	::finish::
	return false
end

-- creates each trade row from the list of machines and a filter. then adds the rows onto the list
function Trades_menu:create_list_rows(list, cities, search_term, player)

	local cities_trades = {}

	-- filter which city trades are allowed
    for city_index, city in ipairs(cities) do

		local city_trades = {}
		if self.filter.traders then
			for x, building in ipairs(city.buildings.traders) do
				if self:check_assembler_recipe_for_item(building, search_term, self.filter) then
					table.insert(city_trades, building)
				end
			end
		end

		if self.filter.malls then
			for x, building in ipairs(city.buildings.malls) do
				if self:check_assembler_recipe_for_item(building, search_term, self.filter) then
					table.insert(city_trades, building)
				end
			end
		end
		if #city_trades > 0 then
			table.insert(cities_trades, city_trades)

			local city_name = ""
			local city_name_map = self:get_city_name_from_map(city)
			if city_name_map ~= "" then
				city_name = city_name_map
			else
				city_name = self:get_city_name_generated(city, city_index)
			end

			if self.filter.group_by_city and #city_trades > 0 then
				grouped_list = list.add{type="frame", direction="vertical", style="inner_frame_in_outer_frame"}

				city_header = grouped_list.add{type="flow", direction="horizontal"}
				city_header.add{type="label", caption=city_name, style="frame_title"}

				--local filler = city_header.add{type="empty-widget"}
				--filler.style.horizontally_stretchable = true

				if city_name_map == "" then
					city_header.add{
						type = "sprite-button",
						name = "tro_tag_city",
						style = "frame_action_button",
						sprite = "utility/downloading_white",
						tags={position = city.center, text = city_name},
						tooltip = "add a name tag on the city, you can rename the city by editing the tag"
					}
				end




				for x, trade in ipairs(city_trades) do
					self:create_row(grouped_list, trade)
				end
				table.insert(list, grouped_list)
			elseif self.filter.group_by_city == false then
				for x, trade in ipairs(city_trades) do
                    self:create_row(list, trade, city_name)
				end
			end
		end
    end

    -- create the list rows
    if #cities_trades > 0 then

	else
		-- if list is empty, create a message saying as much
		local message_element = self:create_failed_search_message(list, player, search_term)
	end
end

-- try to read the city name from a map tag or if nothing found generate it
function Trades_menu:get_city_name(city, city_index)

	local city_name = self:get_city_name_from_map(city)

	if city_name == "" then
		city_name = self:get_city_name_generated(city, city_index)
	end

	return city_name
end

-- read the city from a map tag -- if no map tag found empty "" name returned
function Trades_menu:get_city_name_from_map(city)
	local city_name = ""

	-- check for city name tag on the exact position an the map
	local name_tags = game.forces.player.find_chart_tags(game.surfaces[1], {{city.center.x, city.center.y} , {city.center.x+1, city.center.y+1}} )   -- area of one tile seem not to work {city.center, city.center}
	for i, tag in pairs (name_tags) do
		if tag.position.x == city.center.x or tag.position.y == city.center.y  then -- only exact matching tags, because the science tags are 0.5 tiles off    dont know why
			--if tag and tag.icon then
			--	city_name = city_name .. tag.icon.name .. " "
			--end
			if tag and tag.text then
				city_name = city_name .. tag.text
			end
		end
	end

	return city_name
end

-- generate a creative informative unique name for the city
function Trades_menu:get_city_name_generated(city, city_index)
	local city_name = ""

	if city_name == ""  then

		city_name = city_name .. city_index

		-- compass N = 0  $deg = (atan2($y, $x) * (180/3.14) + 360) % 360;

		local orientation = math.floor( ( math.atan2(city.center.x, -city.center.y) * (180 / 3.14) +360 ) % 360 ) -- y north = negative
		city_name = city_name .. " " .. orientation

		-- distance $d = sqrt(pow($x, 2) + pow($y, 2) );
		local distance = math.floor( math.sqrt( city.center.x^2 + city.center.y^2 )  / 32 )
		city_name = city_name .. " " .. distance

		local orient_names = { "Nor", "Nore" , "Easo", "Eas", "Easu" , "Soue", "Sou", "Souw" , "Wesu", "Wes", "Weso" }

		city_name = city_name .. " " .. orient_names[math.ceil(orientation / (360 / #orient_names))]



		--if string.sub(i,-4,-4) ~= "" then
		--	city_name = city_name .. "[virtual-signal=signal-" .. string.sub(i, -4, -4) .. "]"
		--end
		--if string.sub(i,-3,-3) ~= "" then
		--	city_name = city_name .. "[virtual-signal=signal-" .. string.sub(i, -3, -3) .. "]"
		--end
		--if string.sub(i,-2,-2) ~= "" then
		--	city_name = city_name .. "[virtual-signal=signal-" .. string.sub(i, -2, -2) .. "]"
		--end
		--if string.sub(i,-1,-1) ~= "" then
		--	city_name = city_name .. "[virtual-signal=signal-" .. string.sub(i, -1, -1) .. "]"
		--end

		city_name = city_name .. " "

		if city.center.y >= 0 then
			city_name = city_name .. "Su"
		else
			city_name = city_name .. "No"
		end
		city_name = city_name .. math.floor( math.abs(city.center.y) / 32 )
		if city.center.x >= 0 then
			city_name = city_name .. "e"
		else
			city_name = city_name .. "w"
		end
		city_name = city_name .. math.floor( math.abs(city.center.x) / 32 )

	end

	return city_name
end

-- creates a ui explaining the search for an item failed as well as next steps
function Trades_menu:create_failed_search_message(list, player, search_term)
	local search_history = self.search_history
	local message_element = list.add{type="flow"}
	local horizontal_flow = message_element.add{type="flow", direction="horizontal"}

	-- main text
	if self.filter.products == true and self.filter.ingredients == true then
		horizontal_flow.add{type="label", caption="No recipes found."}
	elseif self.filter.products == true then
		horizontal_flow.add{type="label", caption="No recipes create"}
		horizontal_flow.add{type="sprite", sprite=search_history[1].item_type .. "/" .. search_history[1].searched_item}
		horizontal_flow.add{type="label", caption=search_term}
	elseif self.filter.ingredients == true then
		horizontal_flow.add{type="label", caption="No recipes require"}
		horizontal_flow.add{type="sprite", sprite=search_history[1].item_type .. "/" .. search_history[1].searched_item}
		horizontal_flow.add{type="label", caption=search_term}
	else
		horizontal_flow.add{type="label", caption="Unknown filter!"}
	end

	-- ending text
	if #search_history > 0 then
		message_element.add{type="label", caption='Try searching for something else. Or press "backspace" to see your last search!'}
	else
		message_element.add{type="label", caption="Try searching for something else!"}
	end
end

function Trades_menu:create_row(list, assembler, city_name)
	-- disassemble assembler into usable parts
	local recipe = assembler.get_recipe()
	local position = assembler.position
	local ingredients = recipe.ingredients
	local products = recipe.products

	local trade_row = list.add{type="frame", style="tro_trade_row"}

	-- create row buttons
	local trade_row_flow = trade_row.add{type="flow", style="tro_trade_row_flow"}
	trade_row_flow.add{
        type = "sprite-button",
		name="tro_ping_button",
        sprite = "utility/center",
        style = "tool_button",
		tags={location=position},
		tooltip={"tro.trade_menu_ping"}
	}

    trade_row_flow.add{
        type = "sprite-button",
		name="tro_goto_button",
        sprite = "utility/search_black",
        style = "tool_button",
		tags={location=position},
		tooltip={"tro.trade_menu_goto"}
	}

    if city_name ~= nil  then
        trade_row_flow.add{
            type = "button",
            name = "tro_city_name",
            caption = city_name,
            --	style = "tool_button",
            width = 50,
            tooltip = city_name
        }
    end

    trade_row_flow.add{type="label", name="tro_trade_menu_spacer", caption="     "}

	-- create sprite buttons and labels for each ingredient and product
	if #ingredients >= 1 then
		for i, ingredient in ipairs(ingredients) do
			trade_row_flow.add{
				type="sprite-button",
				sprite = ingredient.type .. "/" .. ingredient.name, 
				tags={
					action="tro_filter_list",
					item_name=ingredient.name,
					filter="ingredient",
					type=ingredient.type
				},
				tooltip={"", {"tro.item_name"}, ": ", ingredient.name, " | ", {"tro.trade_menu_item_sprite_button_instructions"}}
			}
			trade_row_flow.add{type="label", caption = ingredient.amount}
		end
	end

	trade_row_flow.add{type="label", caption = " --->"}

    local last_button = nil
    local last_amount = 0.0
	for i, product in ipairs(products) do

        -- calculate the precise product amount
        local product_amount = 0.0
        if product.amount ~= nil then
            product_amount = product.amount
        end
        if product.amount_min~=nil and product.amount_max~=nil then
            product_amount = product.amount_min * product.amount_max / 2 -- average of min and max
        end
        if product.probability~=nil then
            product_amount = product_amount * product.probability
        end
        -- round to 4 digits
        product_amount = math.floor(product_amount * 10^4 + 0.5) / 10^4

        if last_button~=nil then
            if last_button.sprite == product.type .. "/" .. product.name then
                -- same item so we only add the new amount
                product_amount = last_amount + product_amount
            else
                -- not the same item   show it
                trade_row_flow.add(last_button)
                trade_row_flow.add {type="label", caption = last_amount }
            end

        end

        last_amount =  product_amount
        last_button = {
			type="sprite-button",
			sprite = product.type .. "/" .. product.name, 
			tags={
				action="tro_filter_list",
				item_name=product.name,
				filter="product", 
				type=product.type
			},
			tooltip={"", {"tro.item_name"}, ": ", product.name, " | ", {"tro.trade_menu_item_sprite_button_instructions"}}
		}

	end

    trade_row_flow.add(last_button)
    trade_row_flow.add {type="label", caption = last_amount }

end

function Trades_menu:move_backward_in_search_history(player)
	self.search_history:remove_last_added_term()

	local new_search = Search:new("any", "")


	if #self.search_history >= 1 then
		new_search = self.search_history[1]
	end

	self:update_trades_list(player, new_search, false, true)
end

return Trades_menu