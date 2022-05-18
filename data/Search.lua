---@class Search
---@field filter string
---@field searched_item string
---@field item_type string
local Search = {
	filter="any", -- any, product, ingredient
	searched_item="",
	item_type="unknown"
}

---create a new search table
---@param filter string
---@param searched_item string
---@param item_type string
---@return table search
function Search:new(filter, searched_item, item_type)
	item_type = item_type or self.item_type
	search = {filter=filter, searched_item=searched_item, item_type=item_type}
	setmetatable(search, self)
	self.__index = self

	return search
end

---checks if a search object has the same contents as itself.
---comment
---@param search Search
---@return boolean
function Search:compare(search)
	for key, value in pairs(search) do
		if self[key] ~= value then
			return false
		end
	end
	return true
end

return Search