Trades_menu_view = require("views.trades_menu_view")
Search_history = require("data.Search_history")

local Trades_menu_model = {
    trades_menu_view = Trades_menu_view:new(),
    active = false,
	search_history = Search_history:new(),
	filter = {
		traders=true,
		malls=true,
		ingredients=true,
		products=true
	},
	pagination_pages = {},
}

function Trades_menu_model:new(view)
	local trades_menu_model = {
        trades_menu_view = view,
        active = false,
        search_history = Search_history:new(),
        filter = {
            traders=true,
            malls=true,
            ingredients=true,
            products=true
        },
	}
	setmetatable(trades_menu_model, self)
	self.__index = self

	return trades_menu_model
end

-- re-sets the metatable of an instance
function Trades_menu_model:reset_metatable(trades_menu_model_instance)
	setmetatable(trades_menu_model_instance, self)
	self.__index = self
end

-- opens players trade menu if closed; closes players trade menu if open
function Trades_menu_model:toggle(player)
	if self.active == false then
		self:open_trades_menu(player)
	else
		self:close_trades_menu(player)
	end
end

function Trades_menu_model:get_filtered_cities(cities, search)
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
function Trades_menu_model:open_trades_menu(player)
	player.set_shortcut_toggled("trades", true)
	self.trades_menu_view:create(player)

	local cities = global.cities
	
    -- get each city's assemblers
    local cities_assemblers = {}
    for i, city in ipairs(cities) do
		local buildings = get_city_buildings(city, self.filter.traders, self.filter.malls, false)
		for i, assembler in ipairs(buildings) do
			table.insert(cities_assemblers, assembler)
		end
    end

    -- filter assemblers by their recipe
    local filtered_assemblers = filter_assemblers_by_recipe(cities_assemblers, "")

    -- group assemblers into pages and pages into groups
	self.pagination_pages = {}
	local page = {}
	local max_trades = settings.get_player_settings(player)["max-trades-per-page"].value
	for i, assembler in ipairs(filtered_assemblers) do
		table.insert(page, assembler)
		if i % max_trades == 0 then -- if max trades = 100 and 100/100 has 0 remainder or 200/100 has 0 remainder (etc) then page is full
			table.insert(self.pagination_pages, page)
			page = {}
		end
	end
	if #page > 0 then -- add last page
		table.insert(self.pagination_pages, page)
	end

	-- send data to view
	self.trades_menu_view:fill_trades_list(self.pagination_pages[1])
	self.trades_menu_view:create_pagination_buttons(#self.pagination_pages, 1)

	self.active = true
end

-- closes gui and resets search history
function Trades_menu_model:close_trades_menu(player)
	player.set_shortcut_toggled("trades", false)
	self.trades_menu_view:destroy(player)
	self.active = false
end

-- closes gui without reseting search history
function Trades_menu_model:minimize(player)
	player.set_shortcut_toggled("trades", not self.active)
	self:destroy(player)
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

function get_city_buildings(city, allow_traders, allow_malls, allow_other)
	allow_traders = (allow_traders ~= false)
	allow_malls = (allow_malls ~= false)
	allow_other = (allow_other ~= false)

	local city_buildings = {}

	-- retrieve each citys trader trades
	if allow_traders == false then goto malls end
	for i, building in ipairs(city.buildings.traders) do
		table.insert(city_buildings, building)
	end

	::malls::
	-- retrieve each citys mall trades
	if allow_malls == false then goto finish end
	for i, building in ipairs(city.buildings.malls) do
		table.insert(city_buildings, building)
	end

	::finish::
	return city_buildings
end

function Trades_menu_model:move_backward_in_search_history(player)
	self.search_history:remove_last_added_term()

	local new_search = Search:new("any", "")


	if #self.search_history >= 1 then
		new_search = self.search_history[1]
	end

	self:update_trades_list(player, new_search, false, true)
end

---Switchs which trades are rendered based on the page selected
---@param page number
function Trades_menu_model:switch_page(page)
	if page <= #self.pagination_pages and page >= 1 then
		self.trades_menu_view.trades_list.clear()
		self.trades_menu_view:fill_trades_list(self.pagination_pages[page])
		self.current_page = page
	end
end

function Trades_menu_model:switch_pagination_set(player, set)
	self.pagination_button_set = set
	local pagination_buttons = self.trades_menu_view.pagination_buttons
	pagination_buttons.clear()
	local start = 1 + (self.max_pagination_buttons * (set - 1))
	local amount = self.max_pagination_buttons * set
	if #self.pagination_pages < amount then
		local remainder = amount - #self.pagination_pages
		amount = amount - remainder
	end
	self:create_pagination_buttons(pagination_buttons, amount, start)
end

---inverts the boolean filter and refreshes the GUI to reflect the filter changes
---@param filter string
function Trades_menu_model:invert_filter(filter)
	self.filter[filter] = not self.filter[filter]
end

return Trades_menu_model