function add_term_to_player_search_history(player, search)
	local search_history = global.players[player.index].trade_menu.search_history
	local history_length = #search_history
	-- add search to search history
	table.insert(search_history, 1, search)

	-- dont add to search history if it hasnt changed (A,A,A,A,A,A)
	if history_length >= 2 then
		if search:compare(search_history[2]) then
			table.remove(search_history, 2)
		end
	end

	-- prevent repeating history (A,B,A,B,A,B) by removing second last if it matches new search
	if history_length >= 3 then
		if search:compare(search_history[3]) then
			table.remove(search_history, 3)
		end
	end

	-- stop history from going past max size for performance
	if history_length >= 100 then
		table.remove(search_history, history_length) -- remove oldest search term
	end

	--debug, prints out search history
	-- local history_string = ""
	-- for i, search_term in ipairs(search_history) do
	-- 	history_string = history_string .. ", " .. search_term.searched_item
	-- end
	-- game.print("search history" .. history_string)
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

	local new_search = Search:new("any", "")


	if #search_history >= 1 then
		new_search = search_history[1]
	end

	update_trade_menu_search(player, new_search, false, true)
end
