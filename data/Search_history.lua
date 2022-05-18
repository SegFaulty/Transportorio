---@class Search_history
local Search_history = {}

---create a new search_history object
---@return table
function Search_history:new()
	local search = {}
	setmetatable(search, self)
	self.__index = self

	return search
end

---re-sets the metatable of an instance
---@param search_history_instance Search_history
function Search_history:reset_metatable(search_history_instance)
	setmetatable(search_history_instance, self)
	self.__index = self
end

---add a new search to the history
---@param search Search
function Search_history:add_search(search)
	local history_length = #self

	-- add search to search history
	table.insert(self, 1, search)

	-- dont add to search history if it hasnt changed (A,A,A,A,A,A)
	if history_length >= 2 then
		if search:compare(self[2]) then
			table.remove(self, 2)
		end
	end

	-- prevent repeating history (A,B,A,B,A,B) by removing second last if it matches new search
	if history_length >= 3 then
		if search:compare(self[3]) then
			table.remove(self, 3)
		end
	end

	-- stop history from going past max size for performance
	if history_length >= 100 then
		table.remove(self, history_length) -- remove oldest search term
	end

	--debug, prints out search history
	-- local history_string = ""
	-- for i, search_term in ipairs(search_history) do
	-- 	history_string = history_string .. ", " .. search_term.searched_item
	-- end
	-- game.print("search history" .. history_string)
end

---remove the last added search from itself
function Search_history:remove_last_added_term()
	-- if theres no history then theres nothing to do
	if #self > 0 then
		table.remove(self, 1) -- remove first term from search history
	end
end

---deletes the search history
function Search_history:reset()
	self = {}
end

return Search_history