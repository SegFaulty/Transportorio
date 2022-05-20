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

----------------------------------------------------------------------
-- public functions

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

-- open the trades menu
function Trades_menu_model:open_trades_menu(player)
	player.set_shortcut_toggled("trades", true)
	self.trades_menu_view:create(player)

	-- find, filter, and group each city's entities
	local cities_entities = get_cities_entities(true, true, false)
    local filtered_assemblers = filter_entities_by_recipe(cities_entities, "")
	local max_group_size = settings.get_player_settings(player)["max-trades-per-page"].value
	self.pagination_pages = self:split_entities_into_groups(filtered_assemblers, max_group_size)

	-- send data to view
	self.trades_menu_view:update_trades_list(self.pagination_pages[1])
	self.trades_menu_view:update_pagination_buttons(#self.pagination_pages, 1)

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
function Trades_menu_model:invert_filter(player, filter)
	self.filter[filter] = not self.filter[filter]

	-- find, filter, and group each city's entities
	local cities_entities = get_cities_entities(self.filter.traders, self.filter.malls, false)
    local filtered_assemblers = filter_entities_by_recipe(cities_entities, "")
	local max_group_size = settings.get_player_settings(player)["max-trades-per-page"].value
	self.pagination_pages = self:split_entities_into_groups(filtered_assemblers, max_group_size)

	-- send data to view
	self.trades_menu_view:update_trades_list(self.pagination_pages[1])
	self.trades_menu_view:update_pagination_buttons(#self.pagination_pages, 1)
end

----------------------------------------------------------------------
-- private functions

-- group assemblers into pages and pages into groups
function Trades_menu_model:split_entities_into_groups(entities, max_group_size)
	local groups = {}
	local group = {}

	for i, entity in ipairs(entities) do
		table.insert(group, entity)

		-- if max group size = 100 and 100/100 has 0 remainder or 200/100 has 0 remainder (etc) then page is full
		if i % max_group_size == 0 then 
			table.insert(groups, group)
			group = {}
		end
	end

	if #group > 0 then -- add last page
		table.insert(groups, group)
	end	

	return groups
end

-- return each assembler that has the item in its recipe ingredients and / or products
function filter_entities_by_recipe(entities, item_name, search_ingredients, search_products)
	search_ingredients = (search_ingredients ~= false)
	search_products = (search_products ~= false)

	local filtered_entities = {}
	
	for i, assembler in ipairs(entities) do
		local recipe = assembler.get_recipe()
		if recipe_contains(recipe, item_name, search_ingredients, search_products) then
			table.insert(filtered_entities, assembler)
		end
	end

	return filtered_entities
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

---Get every entity that makes up the city.
---@param city City the city the entities are coming from
---@param traders? boolean get a city's trader entities
---@param malls? boolean get a city's mall entities
---@param other? boolean get any other city entities that dont fit in a specific category
---@return table[] city_entities an array of entities from the city
function get_city_entities(city, traders, malls, other)
	traders = (traders ~= false)
	malls = (malls ~= false)
	other = (other ~= false)

	local city_entities = {}

	-- retrieve each citys trader trades
	if traders == false then goto malls end
	for i, entity in ipairs(city.buildings.traders) do
		table.insert(city_entities, entity)
	end

	::malls::
	-- retrieve each citys mall trades
	if malls == false then goto other end
	for i, entity in ipairs(city.buildings.malls) do
		table.insert(city_entities, entity)
	end

	::other::
	-- retrieve each citys mall trades
	if other == false then goto finish end
	for i, building in ipairs(city.buildings.other) do
		table.insert(city_entities, building)
	end

	::finish::
	return city_entities
end

---Get every entity that makes up each city on the map.
---@param traders? boolean get a city's trader entities
---@param malls? boolean get a city's mall entities
---@param other? boolean get any other city entities that dont fit in a specific category
---@return table[] cities_entities an array of entities from each city
function get_cities_entities(traders, malls, other)
	traders = (traders ~= false)
	malls = (malls ~= false)
	other = (other ~= false)
	local cities = global.cities

    local cities_entities = {}
    for i, city in ipairs(cities) do
		local entities = get_city_entities(city, traders, malls, other)
		for i, entity in ipairs(entities) do
			table.insert(cities_entities, entity)
		end
    end
	return cities_entities
end

return Trades_menu_model