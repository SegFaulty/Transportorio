local Search = {
	filter="any", -- any, product, ingredient
	searched_item="",
	item_type="unknown"
}

-- create a new search table
function Search:new(filter, searched_item, item_type)
	item_type = item_type or self.item_type
	search = {}
	search = {filter=filter, searched_item=searched_item, item_type=item_type}
	setmetatable(search, self)
	self.__index = self

	return search
end

-- checks if a search object has the same contents as itself.
function Search:compare(search)
	for key, value in pairs(search) do
		if self[key] ~= value then
			return false
		end
	end
	return true
end

return Search