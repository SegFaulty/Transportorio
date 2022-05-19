Search_history = require("data.Search_history")

local Trades_menu = {
	active = false,
	search_history = Search_history:new(),
	filter = {
		traders=true,
		malls=true,
		ingredients=true,
		products=true
	},
	pagination_pages = {},
	current_page = 1,
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
function Trades_menu:toggle(player, assemblers)
	if self.active == false then
		self:open(player, global.cities)
	else
		self:close(player)
	end
end

function Trades_menu:filter_cities(cities, search)
	local filtered_cities = {}

	-- filter the cities trades
	for i, city in ipairs(cities) do
		-- get trades for each city
		local city_trades = get_city_trades(city, self.filter.traders, self.filter.malls, false)

		-- if the menu was minimized instead of closed, filter trades by last search
		if search ~= nil then
			city_trades = filter_assemblers_by_recipe(city_trades, search, self.filter.ingredients, self.filter.products)
		elseif #self.search_history >= 1 then
			local last_search = self.search_history[1].searched_item
			city_trades = filter_assemblers_by_recipe(city_trades, last_search, self.filter.ingredients, self.filter.products)
		end

		if #city_trades == 0 then goto next_loop end

		-- insert trades by group or individual
		if self.filter.group_by_city then
			table.insert(filtered_cities, city_trades)
		else
			for x, trade in ipairs(city_trades) do
				table.insert(filtered_cities, trade)
			end
		end
		::next_loop::
	end

	return filtered_cities
end

-- open the trades menu
function Trades_menu:open(player, cities)
	player.set_shortcut_toggled("trades", true)
	local filtered_cities = self:filter_cities(cities)
	local max_trades = settings.get_player_settings(player)["max-trades-per-page"].value
	self.pagination_pages = {}
	if self.filter.group_by_city then
		self:create_pagination_pages_by_city(max_trades, filtered_cities)
	else
		self:create_pagination_pages_by_assembler(max_trades, filtered_cities)
	end

	self:create(player)

	if #self.search_history >= 1 then 
		search = self.search_history[1]
		self:update_search_text(player, search.searched_item, search.filter) 
	end
	self.active = true
end

-- creates the entire trades_menu GUI
function Trades_menu:create(player)
	local player_global = global.players[player.index]
	local screen_element = player.gui.screen
	local root_frame = screen_element.add{type="frame", name="tro_trade_root_frame", direction="vertical", style="tro_trades_gui"}

	self:create_title_bar(root_frame)
	self:create_filter_options(root_frame)
	local list_element = root_frame.add{type="scroll-pane", name="tro_trades_list", direction="vertical", style="inventory_scroll_pane"}
	self:fill_trades_list(list_element, self.pagination_pages[1])
	self:create_pagination(root_frame, #self.pagination_pages)
	root_frame.auto_center = true
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

function Trades_menu:create_filter_options(root)
	filter_flow = root.add{type="flow", direction="horizontal", name="tro_filter_bar"}
	filter_flow.add{type="textfield", name="tro_trade_menu_search", tooltip = {"tro.trade_menu_textfield"}}
	filter_flow.add{
		type="button",
		caption="back",
		name="tro_move_back_in_search_history_button",
		tooltip = {"tro.trade_menu_back_but"}
	}	filter_flow.add{
		type="button",
		caption="group",
		name="tro_group_trades_button",
		tooltip = {"tro.group_trades_button"},
		style="tro_trade_group_button",
	}	filter_flow.add{
		type="button",
		caption="trades",
		name="tro_allow_trades_button",
		tooltip = {"tro.allow_trades_button"},

	}	filter_flow.add{
		type="button",
		caption="malls",
		name="tro_allow_malls_button",
		tooltip = {"tro.allow_malls_button"}
	}
end

function Trades_menu:create_pagination(frame, amount)
	local root = frame.add{type="frame", direction="horizontal", style="tro_page_index_root"}
	root.add{type="button", caption="<<", style="tro_page_index_button", name="pagination_start"}
	root.add{type="button", caption="<", style="tro_page_index_button", name="pagination_back"}
	local page_buttons = root.add{type="flow", style="tro_page_index_button_flow"}
	root.add{type="button", caption=">", style="tro_page_index_button", name="pagination_next"}
	root.add{type="button", caption=">>", style="tro_page_index_button", name="pagination_end"}

	for i=1, amount do
		page_buttons.add{
			type = "button",
			caption = i,
			style = "tro_page_index_button",
			tags = {
				action = "switch_pagination_page", 
				page_number = i
			}
		}
	end
end

-- updates the GUI search box
function Trades_menu:update_search_text(player, search, filter)
	local textfield = player.gui.screen["tro_trade_root_frame"]["tro_filter_bar"]["tro_trade_menu_search"]
	local text = filter .. ":" .. search

	if filter == nil then
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

-- return each assembler that has the item in its recipe ingredients and / or products
function filter_assemblers_by_recipe(assemblers, item_name, search_ingredients, search_products)
	search_ingredients = (search_ingredients ~= false)
	search_products = (search_products ~= false)

	local filtered_assemblers = {}
	
	for i, assembler in ipairs(assemblers) do
		local recipe = assembler.get_recipe()
		if recipe_contains(recipe, item_name, search_ingredients, search_products) then
			table.insert(filtered_assemblers, assembler)
		end
	end

	return filtered_assemblers
end

-- check if a recipe has an item in ingredients and / or products   
function recipe_contains(recipe, item_name, search_ingredients, search_products)
	search_ingredients = (search_ingredients ~= false)
	search_products = (search_products ~= false)

	-- check if the recipe has the item as a product
	if search_products == false then goto ingredient end -- skip product search
	for i, product in ipairs(recipe.products) do
		if string.find(product.name, item_name, 0, true) then
			return true
		end
	end

	::ingredient::
	-- check if the recipe has the item as an ingredient
	if search_ingredients == false then goto finish end -- skip ingredient search
	for i, ingredient in ipairs(recipe.ingredients) do
		if string.find(ingredient.name, item_name, 0, true) then
			return true
		end
	end

	::finish::
	return false
end

-- updates the trade menu window search bar and search list based on search text
function Trades_menu:update_trades_list(player, search, add_to_search_history, update_search_field)
	update_search_field = update_search_field or false

	-- if the trade menu isnt open you cant update it
	if self.active == false then
		return
	end

	-- update search history
	if add_to_search_history then
		self.search_history:add_search(search)
	end

	-- update search field
	if update_search_field then
		self:update_search_text(player, search.searched_item, search.filter)
	end

	-- update GUI filter
	if search.filter == "products" then
		self.filter.products = true
		self.filter.ingredients = false
	elseif search.filter == "ingredients" then
		self.filter.products = false
		self.filter.ingredients = true
	elseif search.filter == "" or search.filter == "any" then
		self.filter.products = true
		self.filter.ingredients = true
	else
		self.filter.products = false
		self.filter.ingredients = false
	end

	-- update trades list
	local trades_list = player.gui.screen["tro_trade_root_frame"]["tro_trades_list"]
	trades_list.clear()

	player.set_shortcut_toggled("trades", true)
	local filtered_cities = self:filter_cities(global.cities, search.searched_item)
	if(#filtered_cities == 0) then
		self:create_failed_search_message(trades_list, player, search.searched_item)
	else
		self:fill_trades_list(trades_list, filtered_cities)
	end
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

function get_city_trades(city, allow_traders, allow_malls, allow_other)
	allow_traders = (allow_traders ~= false)
	allow_malls = (allow_malls ~= false)
	allow_other = (allow_other ~= false)

	local city_trades = {}

	-- retrieve each citys trader trades
	if allow_traders == false then goto malls end
	for x, building in ipairs(city.buildings.traders) do
		table.insert(city_trades, building)
	end

	::malls::
	-- retrieve each citys mall trades
	if allow_malls == false then goto finish end
	for x, building in ipairs(city.buildings.malls) do
		table.insert(city_trades, building)
	end

	::finish::
	return city_trades

end

function Trades_menu:fill_trades_list(list_element, assemblers)
	if self.filter.group_by_city then
		self:fill_trades_list_with_groups(list_element, assemblers)
	else
		self:fill_trades_list_without_groups(list_element, assemblers)
	end
end

-- fills an element with groups of rows
function Trades_menu:fill_trades_list_with_groups(element, assembler_groups)
	for i, assemblers in ipairs(assembler_groups) do
		local group_element	= element.add{type="frame", direction="vertical", style="inner_frame_in_outer_frame"}
		self:fill_trades_list_without_groups(group_element, assemblers)
	end
end

-- fills an element with rows
function Trades_menu:fill_trades_list_without_groups(element, assemblers)
	for i, assembler in ipairs(assemblers) do
		self:create_trade_row(element, assembler)
	end
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

-- create the ui for a trade row
function Trades_menu:create_trade_row(element, assembler)
	-- disassemble assembler into usable parts
	local recipe = assembler.get_recipe()
	local position = assembler.position
	local ingredients = recipe.ingredients
	local products = recipe.products

	local root = element.add{type="frame", style="tro_trade_row"}
	local trade_row_flow = root.add{type="flow", style="tro_trade_row_flow"} -- needed for vertical align (wont work on root frame)

	-- create row buttons
	trade_row_flow.add{
		type="button",
		caption="ping",
		name="tro_ping_button",
		tags={location=position}, 
		tooltip={"tro.trade_menu_ping"}
	}
	trade_row_flow.add{
		type="button",
		caption="goto",
		name="tro_goto_button",
		tags={location=position},
		tooltip={"tro.trade_menu_goto"}
	}
	
	-- create sprite buttons and labels for each ingredient 
	if #ingredients == 0 then goto products end-- recipes can have no ingredient (free items)
	for i, ingredient in ipairs(ingredients) do
		self:create_trade_row_item(trade_row_flow, ingredient, "ingredient")
	end

	-- create divider between ingredients and products
	trade_row_flow.add{type="label", caption = " --->"}

	::products::
	-- create sprite buttons and labels for each product
	for i, product in ipairs(products) do
		self:create_trade_row_item(trade_row_flow, product, "product")
	end
end

-- create a custom set of elements for the trade row
function Trades_menu:create_trade_row_item(element, item, type)
	element.add{
		type = "sprite-button",
		sprite = item.type .. "/" .. item.name, 
		tags = {
			action = "tro_filter_list",
			item_name = item.name,
			filter = type, 
			type = item.type
		},
		tooltip = {"", {"tro.item_name"}, ": ", item.name, " | ", {"tro.trade_menu_item_sprite_button_instructions"}}
	}
	-- item amount
	element.add{type = "label", caption = item.amount}
end

function Trades_menu:move_backward_in_search_history(player)
	self.search_history:remove_last_added_term()

	local new_search = Search:new("any", "")


	if #self.search_history >= 1 then
		new_search = self.search_history[1]
	end

	self:update_trades_list(player, new_search, false, true)
end

---Fills a page up to the max_trades amount with trades while keeping the trades in their original group.
---If a page cannot hold the entire group a new page is created and the old one stored.
---Continues to create fill pages until there are no more groups left.
---@param max_trades number the maximum amount of trades on each page.
---@param cities table[]
function Trades_menu:create_pagination_pages_by_city(max_trades, cities)
	local trades_in_page = 0
	page = {}
	for i, city in ipairs(cities) do
		if (trades_in_page + #city) <= max_trades then -- adding city would stay within page limit
			table.insert(page, city)
			trades_in_page = trades_in_page + #city
		else -- adding city would exceed page limit
			table.insert(self.pagination_pages, page)
			page = {}
			trades_in_page = 0
			table.insert(page, city)
			trades_in_page = trades_in_page + #city
		end
	end
	table.insert(self.pagination_pages, page) -- add last page
end

---Fills a page up to the max_trades amount with assemblers.
---When a page is full it gets stored in memory and a new one is created.
---Continues to create fill pages until there are no more assemblers left.
---@param max_trades number the maximum amount of trades on each page.
---@param assemblers table[]
function Trades_menu:create_pagination_pages_by_assembler(max_trades, assemblers)
	local max_trades
	local page = {}
	
	for i, assembler in ipairs(assemblers) do
		table.insert(page, assembler)
		if i % max_trades == 0 then -- if max trades = 100 and 100/100 has 0 remainder or 200/100 has 0 remainder (etc) then page is full
			table.insert(self.pagination_pages, page)
			page = {}
		end
	end
	table.insert(self.pagination_pages, page) -- add last page
end

---Switchs which trades are rendered based on the page selected
---@param player LuaPlayer
---@param page number
function Trades_menu:switch_page(player, page)
	local trades_list = player.gui.screen["tro_trade_root_frame"]["tro_trades_list"]
	if page <= #self.pagination_pages and page >= 1 then
		trades_list.clear()
		self:fill_trades_list(trades_list, self.pagination_pages[page])
		self.current_page = page
	end
end

return Trades_menu