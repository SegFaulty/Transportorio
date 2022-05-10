require("data.Search_history")

-- opens players trade menu if closed; closes players trade menu if open
function toggle_trade_menu(player)
	local player_global = global.players[player.index]
	if player_global.trade_menu.active == false then
		open_trade_menu(player)
	else
		close_trade_menu(player)
	end
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

function close_trade_menu(player)
	local player_global = global.players[player.index]
	local screen_element = player.gui.screen
	local main_frame = screen_element["tro_trade_root_frame"]

	main_frame.destroy()

	-- update players state
	player_global.trade_menu.active = not player_global.trade_menu.active
	reset_search_history(player)
end

-- updates the trade menu window search bar and search list based on search text
function update_trade_menu_search(player, search, add_to_search_history, update_search_field)
	update_search_field = update_search_field or false

	-- if the trade menu isnt open you cant update it
	if global.players[player.index].trade_menu.active == false then
		return
	end

	if add_to_search_history then
		add_term_to_player_search_history(player, search)
	end

	-- update search field
	if update_search_field then
		local textfield = player.gui.screen["tro_trade_root_frame"]["tro_trade_menu_search"]
		textfield.text = search.filter .. ":" .. search.searched_item
	end
		
	-- update trades list
	local trades_list = player.gui.screen["tro_trade_root_frame"]["tro_trades_list"]
	trades_list.clear()
	create_trade_menu_list_rows(trades_list, global.machine_entities, search.searched_item, search.filter, player)
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
					table.insert(filtered_assemblers, assembler)
					goto next_loop
				end
			end
			for i, ingredient in ipairs(recipe.ingredients) do
				if string.find(ingredient.name, search_term, 0, true) then
					table.insert(filtered_assemblers, assembler)
					goto next_loop
				end
			end
			
			

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
		::next_loop::
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
		local message_element = create_failed_search_message(list, player, filter, search_term)
	end
end

-- creates a ui explaining the search for an item failed as well as next steps
function create_failed_search_message(list, player, filter, search_term)
	local search_history = global.players[player.index].trade_menu.search_history
	local message_element = list.add{type="flow"}
	local horizontal_flow = message_element.add{type="flow", direction="horizontal"}

	-- main text
	if filter == "any" then
		horizontal_flow.add{type="label", caption="No recipes found."}
	elseif filter == "product" then
		horizontal_flow.add{type="label", caption="No recipes create"}
		horizontal_flow.add{type="sprite", sprite=search_history[1].item_type .. "/" .. search_history[1].searched_item}
		horizontal_flow.add{type="label", caption=search_term}
	elseif filter == "ingredient" then
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

function create_row(list, ingredients, products, position)
	local trade_row = list.add{type="frame", style="tro_trade_row"}
	local trade_row_flow = trade_row.add{type="flow", style="tro_trade_row_flow"}
	trade_row_flow.add{type="button", caption="ping", name="tro_ping_button", tags={location=position}}
	
	if #ingredients >= 1 then
		for i, ingredient in ipairs(ingredients) do
			trade_row_flow.add{type="sprite-button", sprite = ingredient.type .. "/" .. ingredient.name, 
				tags={action="tro_filter_list", item_name=ingredient.name, filter="ingredient", type=ingredient.type}}
			trade_row_flow.add{type="label", caption = ingredient.amount}
		end
	end

	trade_row_flow.add{type="label", caption = " --->"}

	for i, product in ipairs(products) do
		trade_row_flow.add{type="sprite-button", sprite = product.type .. "/" .. product.name, 
			tags={action="tro_filter_list", item_name=product.name, filter="product", type=product.type}}
		trade_row_flow.add{type="label", caption = product.amount}
	end
end
