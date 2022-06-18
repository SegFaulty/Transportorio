local City_helper = {}

-- make a list of alle buildings traders, malls, [other]
function City_helper:get_all_buildings(city, exclude_other)
    local buildings = {}

    for _, building in ipairs(city.buildings.traders) do
        table.insert( buildings, building)
    end

    for _, building in ipairs(city.buildings.malls) do
        table.insert( buildings, building)
    end
    if not exclude_other then
        for _, building in ipairs(city.buildings.other) do
            table.insert( buildings, building)
        end
    end
    return buildings
end

-- get usefull position for city name tag,  use bottom left of city  min x max y
function City_helper:get_name_tag_position(city)
    local x = city.center.x
    local y = city.center.y

    for _, building in ipairs(self:get_all_buildings(city)) do
        if building.position.x < x then
            x = building.position.x
        end
        if building.position.y > y then
            y = building.position.y
        end
    end

    return {x=x-5, y=y+5}
end


function City_helper:get_distance(city)
    -- distance $d = sqrt(pow($x, 2) + pow($y, 2) );
    return math.floor( math.sqrt( city.center.x^2 + city.center.y^2 )  / 32 )
end

function City_helper:get_orientation(city)
    -- compass N = 0  $deg = (atan2($y, $x) * (180/3.14) + 360) % 360;
    return math.floor( ( math.atan2(city.center.x, -city.center.y) * (180 / 3.14) +360 ) % 360 ) -- y north = negative
end

-- try to read the city name from a map tag or if nothing found generate it
function City_helper:get_name(city, city_index)

    local city_name = self:get_name_from_map(city)

    if city_name == "" then
        city_name = self:get_name_generated(city, city_index)
    end

    return city_name
end

-- read the city from a map tag -- if no map tag found empty "" name returned
function City_helper:get_name_from_map(city)
    local city_name = ""

    -- check for city name tag on the exact position an the map
    local map_tag_position = self:get_name_tag_position(city)
    local name_tags = game.forces.player.find_chart_tags(game.surfaces[1], {map_tag_position, {map_tag_position.x+1, map_tag_position.y+1}} )   -- area of one tile seem not to work {city.center, city.center}
    for i, tag in pairs (name_tags) do
        if tag.position.x ==map_tag_position.x or tag.position.y == map_tag_position.y  then -- only exact matching tags, because the science tags are 0.5 tiles off    dont know why
            --if tag and tag.icon then
            --	city_name = city_name .. tag.icon.name .. " "
            --end
            if tag and tag.text then
                city_name = city_name .. tag.text
                city_name = string.gsub(city_name, " *#%d+ *", "") -- remove # city index and trim
            end
        end
    end

    return city_name
end



-- generate a creative informative unique name for the city
function City_helper:get_name_generated(city, city_index)
    local city_name = ""

    if city_name == ""  then

        -- distance $d = sqrt(pow($x, 2) + pow($y, 2) );
        local distance = self:get_distance(city)


        if distance < 10 then
            city_name = city_name .. "Cen"
        else
            local orientation = self:get_orientation(city)

            local orient_names = { "Nor", "Nore" , "Easo", "Eas", "Easu" , "Soue", "Sou", "Souw" , "Wesu", "Wes", "Weso" }
            local orient_names = { "Nor", "Eas", "Eas", "Sou", "Sou", "Wes" , "Wes" , "Nor" }
            local orient_names = { "Nor", "Eas", "Eas", "Sou", "Sou", "Wes" , "Wes" , "Nor" }
            local orient_names = { "Aparctias", "Boreas", "Boreas", "Meses", "Meses", "Caicias", "Caicias", "Apeliotes", "Apeliotes", "Eurus", "Eurus", "Euronotus", "Euronotus", " Notos", " Notos", " Libonotos", "Libonotos", "Lips", "Lips", "Zephyrus", "Zephyrus", "Argestes", "Argestes", "Thrascias", "Thrascias", "Aparctias" }
            local orient_names = { "Apokoronas", "Baltoumaegnatia", "Baltoumaegnatia", "Chalandriou", "Chalandriou", "Dionolymbos", "Dionolymbos", "Emmanouilpa", "Emmanouilpa", "Folegandros", "Folegandros", "Gortyniavena", "Gortyniavena", "Hydraydral", "Hydraydral", "Igoumenitsa", "Igoumenitsa", "Kandanosselino", "Kandanosselino", "Limniplastira", "Limniplastira", "Mylopotamos", "Mylopotamos", "Neapropondida", "Neapropondida", "Oreokastrou", "Oreokastrou", "Papagoscholargos", "Papagoscholargos", "Rigasfereos", "Rigasfereos", "Syrosermoupoli", "Syrosermoupoli", "Triziniamethana", "Triziniamethana", "Olomadesarkadia", "Olomadesarkadia",  "Voriakynouria", "Voriakynouria", "Waleontades", "Waleontades", "Xylokastroevrostini", "Xylokastroevrostini", "Yameiamessinia", "Yameiamessinia", "Zagoramouresi", "Zagoramouresi", "Apokoronas"}
            local orient_name = orient_names[math.ceil(orientation / (360 / #orient_names))]

            city_name = city_name .. string.sub(orient_name, 1, math.sqrt(distance)+1)

            --			city_name = city_name .. " " .. orient_name
            --			city_name = city_name .. " " .. orientation
        end

        -- add name part for most traded item of this city
        local dominant_item = self:get_dominant_item(city, 5)
        if dominant_item ~= nil then
            local dominant_item_translations = {}
            dominant_item_translations["stone"] = "rock"
            dominant_item_translations["coal"] = "cokery"
            dominant_item_translations["stone-brick"] = "bric"
            dominant_item_translations["stone-wall"] = "wal"
            dominant_item_translations["iron-ore"] = "ferro"
            dominant_item_translations["copper-ore"] = "cop"
            dominant_item_translations["copper-cable"] = "wire"
            dominant_item_translations["copper-plate"] = "cup"
            dominant_item_translations["iron-plate"] = "plat"
            dominant_item_translations["iron-stick"] = "stick"
            dominant_item_translations["iron-gear-wheel"] = "gear"
            dominant_item_translations["steel-plate"] = "steel"
            dominant_item_translations["plastic-bar"] = "pvc"
            dominant_item_translations["electronic-circuit"] = "tron"
            dominant_item_translations["electric-engine-unit"] = "emotor"
            dominant_item_translations["firearm-magazine"] = "mag"
            dominant_item_translations["rocket-control-unit"] = "rcu"
            dominant_item_translations["rocket-fuel"] = "fuel"
            dominant_item_translations["explosives"] = "boom"
            dominant_item_translations["speed-module"] = "quik"
            dominant_item_translations["atomic-bomb"] = "nuk"
            if dominant_item_translations[dominant_item] ~= nil then
                city_name = city_name .. dominant_item_translations[dominant_item]
            else
                city_name = city_name .. "-" .. dominant_item
            end
        end

        -- add name part for special buildings  rocket-silo / lab
        if #city.buildings.other >= 1 then
            if city.buildings.other[1].name == "rocket-silo" then
                local parts = { "space", "station", "cosmo", "rouket" }
                city_name = city_name .. parts[1 + city_index % #parts] -- pseudo random
            elseif city.buildings.other[1].name == "lab" then
                local parts = { "lab", "tek", "tec", "tech" }
                city_name = city_name .. parts[1 + city_index % #parts] -- pseudo random
            end
        end

        -- check city size and use extremes for naming
        local city_size_name = ""
        city_building_count = #city.buildings.traders + #city.buildings.malls + #city.buildings.other
        if city_building_count <= 4 then
            city_size_name = "farm"
        elseif city_building_count <= 8 then
            city_size_name = "ville"
        elseif city_building_count <= 12 then
            city_size_name = "town"
        elseif city_building_count > 20 then
            local parts = { "met", "plex", "polis", "city" }
            city_size_name = parts[1 + city_index % #parts] -- pseudo random
        end

        -- check environment for trees water cliffs
        local city_environment_name = ""
        local city_environment_area = {{city.center.x-32, city.center.y-32},{city.center.x+32, city.center.y+32}}
        local rocks_count = game.surfaces[1].count_entities_filtered{ area=city_environment_area, name={"rock-big","rock-huge","rock-medium","rock-tiny","rock-small","sand-rock-medium","sand-rock-small"} }
        local cliffs_count = game.surfaces[1].count_entities_filtered{ area=city_environment_area, name={"cliff"} }
        local trees_count = game.surfaces[1].count_entities_filtered{ area=city_environment_area, type="tree" }
        local water_count = game.surfaces[1].count_tiles_filtered{ area=city_environment_area, name={"water","water-green","water-mud","water-shallow"} }

        if water_count > 300 then
            local parts = { "coast", "sea", "port" }
            city_environment_name = parts[1 + city_index % #parts] -- pseudo random
        elseif trees_count > 100 then
            local parts = { "wood", "forest" }
            city_environment_name = parts[1 + city_index % #parts] -- pseudo random
        elseif cliffs_count > 10 then
            local parts = { "mountain", "castle", "cliff", "valley", "canyon", "peak" }
            city_environment_name = parts[1 + city_index % #parts] -- pseudo random
        elseif water_count > 3 then
            local parts = { "lake", "swamp" }
            city_environment_name = parts[1 + city_index % #parts] -- pseudo random
        elseif rocks_count > 5 then
            local parts = { "boulder", "hill", "quarry" }
            city_environment_name = parts[1 + city_index % #parts] -- pseudo random
        elseif trees_count > 20 then
            local parts = { "tree", "bush" }
            city_environment_name = parts[1 + city_index % #parts] -- pseudo random
        end

        city_name = city_name .. city_environment_name
        city_name = city_name .. city_size_name

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

        --if city.center.y >= 0 then
        --	city_name = city_name .. "Su"
        --else
        --	city_name = city_name .. "No"
        --end
        --city_name = city_name .. math.floor( math.abs(city.center.y) / 32 )
        --if city.center.x >= 0 then
        --	city_name = city_name .. "e"
        --else
        --	city_name = city_name .. "w"
        --end
        --city_name = city_name .. math.floor( math.abs(city.center.x) / 32 )

    end

    return city_name
end

function City_helper:get_dominant_item(city, min_count)
    local item_counts = {}
    local max_count = 0
    local dominant_item = nil

    for x, assembler in ipairs(city.buildings.traders) do

        local recipe = assembler.get_recipe()
        if recipe ~= nil then
            for i, item in ipairs(recipe.ingredients) do
                if item_counts[item.name] == nil then
                    item_counts[item.name] = 0
                end
                item_counts[item.name] = item_counts[item.name] + 1
                if item_counts[item.name] > max_count then
                    max_count = item_counts[item.name]
                    if max_count > min_count then
                        dominant_item = item.name
                    end
                end
            end
            for i, item in ipairs(recipe.products) do
                if item_counts[item.name] == nil then
                    item_counts[item.name] = 0
                end
                item_counts[item.name] = item_counts[item.name] + 1
                if item_counts[item.name] > max_count then
                    max_count = item_counts[item.name]
                    if max_count > min_count then
                        dominant_item = item.name
                    end
                end
                break -- only 1 item because a second item will always be the same as the first
            end
        end
    end

    return dominant_item
end

return City_helper