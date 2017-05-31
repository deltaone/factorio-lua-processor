require ("util")

-------------------------------------------------------------------------------
function new_class(members)
  members = members or {}
  local mt = {
	__metatable = members;
	__index     = members;
  }

  local function new(_, init)
	return setmetatable(init or {}, mt)
  end

  local function copy(obj, ...)
	local newobj = obj:new(unpack(arg))
	for n,v in pairs(obj) do newobj[n] = v end
	return newobj
  end

  members.new  = members.new  or new
  members.copy = members.copy or copy

  return mt
end

-------------------------------------------------------------------------------
-- entity / object

function is_valid(entity)
	return (entity ~= nil and entity.valid)
end

-- https://wiki.factorio.com/World_generator#Maximum_Map_Size_and_used_Memory
-- The map limit is 2,000,000 x 2,000,000 tiles
-- https://stackoverflow.com/questions/7539810/saving-a-vector-as-a-single-number
-- V = fromXY(X, Y) = (y+65000)*130001+(x+65000)
-- (X,Y) = toXY(V) = (V%130001-65000,V/130001-65000)    // <= / is integer division
-- (130001 is the number of distinct values for X or Y)
function get_eid(entity)
	return (entity.position.y + 2000000) * 4000001 + (entity.position.x + 2000000)
end

function eid_to_position(eid)
	local x = eid % 4000001 - 2000000
	local y = math.floor(eid / 4000001) - 2000000
	return x, y
end

function find_object(entity)
	local eid = get_eid(entity)
	return global.objects[eid], eid
end

function find_tag(tag)
	for i, object in pairs(global.objects) do
		if object.tag == tag then return i, object; end
	end
end

function find_adjacent(entity)
	entities = {}
	search = entity.surface.find_entities({{entity.position.x - 1, entity.position.y - 1}, {entity.position.x + 1, entity.position.y + 1}})
	for _, entry in pairs(search) do
		if is_valid(entry) and (entry.position.x ~= entity.position.x or entry.position.y ~= entity.position.y) then
			table.insert(entities, entry)
		end
	end
	return entities
end

-- get entity in front direction
-- local target = entity.surface.find_entities_filtered({ area = position_area(position_move(entity.position, entity.direction, 1), 0.2), 
-- type = "assembling-machine"})[1]

function position_area(position, distance) -- around
	return {{x = position.x - distance, y = position.y - distance}, { x = position.x + distance, y = position.y + distance}}
end

function position_move(position, direction, distance)
	local x, y = position.x, position.y	
	if     direction == defines.direction.north then y = y - distance
	elseif direction == defines.direction.south then y = y + distance
	elseif direction == defines.direction.east  then x = x + distance
	elseif direction == defines.direction.west  then x = x - distance
	end	
	return {x=x, y=y}
end

-------------------------------------------------------------------------------
-- misc

function not_nil(class, var) -- if notNil(gametime_combinator, "position") then
  value = false
  pcall(function() if class[var] then value = true end end)
  return value
end

function string.starts(string_in, string_starts)
   return string.sub(string_in, 1, string.len(string_starts)) == string_starts
end

function gui_or_new(parent, name, new_element)
	if parent[name] == nil then
		parent.add(new_element)
	end
	return parent[name]
end

function table_or_new(table_a)
	if table_a == nil then
		return {}
	else
		return table_a
	end
end

function table_merge(table1, table2)
	for index, value in pairs(table2) do
		if type(value) == "table" then
			table_merge(table1[index], table2[index])
		else
			table1[index] = value
		end
	end
end

function say(player, message)
	player.print(message or "")
end

function shout(message)
	for _,player in pairs(game.players) do
		player.print(message or "")
	end
end

-------------------------------------------------------------------------------
-- debug

local cfg = config or {}
local debug_mode = cfg.debug or false
local debug_file = cfg.debug_file or "debug.log"
local debug_file_reset = cfg.debug_file_reset or true

function dump(thing, indent) -- http://stackoverflow.com/questions/9168058/how-to-dump-a-table-to-console
	local dmp = ""	
	if not indent then indent = 0 end  
	
	for k, v in pairs(thing) do		
		if type(v) == "table" then
			dmp = dmp .. string.rep(" ", indent) .. "[" .. tostring(k) .. "]:\n" .. dump(v, indent + 2)
		else
			dmp = dmp .. string.rep(" ", indent) .. tostring(k) .. " = '" .. tostring(v) .. "'\n"
		end
	end
	return dmp
end

function debug_log(data)
	if not debug_mode then return end

	if debug_file_reset then
		game.write_file(debug_file, game.tick .. ": Log started ...\n", false)
		debug_file_reset = false		
	end

	if type(data) == "table" then
		data = "dump:\n" .. dump(data, 2) -- serpent.block(data, {nocode=true, comment=false})
	else
		data = tostring(data)
		for _, player in pairs(game.players) do
			player.print(game.tick .. ": " .. data)
		end	
	end
	game.write_file(debug_file, game.tick .. ": " .. data .. "\n", true)
end

function error(text)
	error(text .. "\n" .. debug.traceback())
end