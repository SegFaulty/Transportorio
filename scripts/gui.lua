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
	self:save_search(player)
	player.set_shortcut_toggled("trades", not self.active)
	self:destroy(player)
	self.search_history:reset()
end

-- closes gui without reseting search history
function Trades_menu:minimize(player)
	self:save_search(player)
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

function Trades_menu:save_search(player)
	local text_field = player.gui.screen["tro_trade_root_frame"]["tro_filter_bar"]["tro_trade_menu_search"]
	local current_search = convert_search_text_to_search_object(text_field.text)
	self.search_history:add_search(current_search)
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
function Trades_menu:check_assembler_recipe_for_item(assembler, search_query, filter)

	-- skip empty assembler
	local recipe = assembler.get_recipe()
	if recipe == nil then -- prevent /scripts/gui.lua:253: attempt to index local 'recipe' (a nil value)
		return false
	end

	-- hide trades in unrevealed map areas, assembler needs to be visible on the map,
    -- prevents trades in new generated chunks are in the list before the machines are visible or explored
    local assembler_chunk_position = { math.floor(assembler.position.x / 32), math.floor(assembler.position.y / 32 )}
    if not game.forces.player.is_chunk_charted(game.surfaces[1], assembler_chunk_position) then
		return  false
    end

	local search_result = true

	-- for each searchterm
	for search_term in string.gmatch(search_query, "%S+") do

		-- chech for ingredients or product filter
		-- string.sub(item_name, 1, 1) == "P"
		index_start, index_end = string.find(search_term, ":")
		local side = nil
		if index_end ~= nil then
			side = string.sub(search_term, 1, index_end - 1)
			search_term = string.sub(search_term, index_end + 1, -1)
		end

		local search_items = {}
		if side==nil or side=="ingredients" or side=="i" then
			for _, item in ipairs(recipe.ingredients) do
				table.insert(search_items, item)
			end
		end
		if side==nil or side=="products" or side=="p" then
			for _, item in ipairs(recipe.products) do
				table.insert(search_items, item)
			end
		end

		search_term_result = false
		for _, item in ipairs(search_items) do
			if game.item_prototypes[search_term] ~= nil then -- check if searchterm item_name is a game item name then  filter for this item  else make a "item.name contains ..." search
				if search_term == item.name then -- it exist an game item with this name so we make an exact match
					search_term_result = true
				end
			else
				if string.find(item.name, search_term, 0, true) then
					search_term_result = true
				end
			end
		end
		search_result = search_result and search_term_result

	end

	return search_result
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
			local city_name_map = City_helper:get_name_from_map(city)
			if city_name_map ~= "" then
				city_name = city_name_map
			else
				city_name = City_helper:get_name_generated(city, city_index)
			end

			if self.filter.group_by_city and #city_trades > 0 then
				grouped_list = list.add{type="frame", name="city_"..city_index, direction="vertical", style="inner_frame_in_outer_frame"}

				city_header = grouped_list.add{type="flow", name="header", direction="horizontal"}
				city_header.add{type="label", caption=city_name, style="frame_title"}


				if city_name_map == "" then
					city_header.add{
						type = "sprite-button",
						name = "tro_tag_city",
						style = "frame_action_button",
						sprite = "utility/downloading_white",
						tags={position = City_helper:get_name_tag_position(city), text = city_name .. " #" .. city_index, city_index = city_index},
						tooltip = {"tro.trade_menu_row_city_tag_button_tooltip"}
					}
				end

				local filler = city_header.add{type="empty-widget"}
				filler.style.horizontally_stretchable = true


				local distance = City_helper:get_distance(city)
				local orientation = City_helper:get_orientation(city)
				local direction_arrow = ""
				if distance < 10 then
					direction_arrow = "⊙"
				else
					local direction_arrows = { "⬆", "⬈", "⬈", "➡", "➡", "⬊", "⬊", "⬇", "⬇", "⬋", "⬋", "⬅", "⬅", "⬉", "⬉", "⬆"}
					direction_arrow = direction_arrows[math.ceil(orientation / (360 / #direction_arrows))]
				end

				city_header.add{type="label", caption=direction_arrow .. distance, tooltip={"tro.trade_menu_row_city_direction_tooltip"}}
				city_header.add{type="label", caption=" #" .. city_index, tooltip={"tro.trade_menu_row_city_index_tooltip"}}

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

-- creates a ui explaining the search for an item failed as well as next steps
function Trades_menu:create_failed_search_message(list, player, search_term)
	local search_history = self.search_history
	local message_element = list.add{type="flow"}
	local horizontal_flow = message_element.add{type="flow", direction="horizontal"}

	-- main text
	--if self.filter.products == true and self.filter.ingredients == true then
	--	horizontal_flow.add{type="label", caption="No recipes found."}
	--elseif self.filter.products == true then
	--	horizontal_flow.add{type="label", caption="No recipes create"}
	--	horizontal_flow.add{type="sprite", sprite=search_history[1].item_type .. "/" .. search_history[1].searched_item}
	--	horizontal_flow.add{type="label", caption=search_term}
	--elseif self.filter.ingredients == true then
	--	horizontal_flow.add{type="label", caption="No recipes require"}
	--	horizontal_flow.add{type="sprite", sprite=search_history[1].item_type .. "/" .. search_history[1].searched_item}
	--	horizontal_flow.add{type="label", caption=search_term}
	--else
	--	horizontal_flow.add{type="label", caption="Unknown filter!"}
	--end

	horizontal_flow.add{type="label", caption="No Deals found."}


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
				mouse_button_filter =  {'left','right','middle'},
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
			mouse_button_filter =  {'left','right','middle'},
			tags={
				action="tro_filter_list",
				item_name=product.name,
				filter="product", 
				type=product.type
			},
			tooltip={"", {"tro.item_name"}, ": ", product.name, " |  ", {"tro.trade_menu_item_sprite_button_instructions"}}
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