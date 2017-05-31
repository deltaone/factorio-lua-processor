local root = "__lua-processor__"
local name = "lua-processor-io"

local entity = util.table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
entity.name = name
entity.minable.result = name
entity.item_slot_count = 60
entity.icon = root .. "/graphics/" .. name .. "-icon.png"

local directions = {"north", "east", "south", "west"}
for _, value in pairs(directions) do
	entity.sprites[value] =	{
		filename = root .. "/graphics/" .. name .. ".png",		
		width = 64, height = 64,
		frame_count = 1,
		shift = {0, 0},
	}
end

entity.circuit_wire_connection_points = {
	{
		shadow = {red = {0.143, -0.25}, green = {0.35, -0.25}},
		wire   = {red = {-0.07, -0.4}, green = {0.1, -0.4}}
	}, {
		shadow = {red = {0.35, -0.25}, green = {0.143, -0.25}},
		wire   = {red = {0.1, -0.4}, green = {-0.07, -0.4}}
	}, {
		shadow = {red = {0.143, -0.25}, green = {0.35, -0.25}},
		wire   = {red = {-0.07, -0.4}, green = {0.1, -0.4}}
	}, {
		shadow = {red = {0.35, -0.25}, green = {0.143, -0.25}},
		wire   = {red = {0.1, -0.4}, green = {-0.07, -0.4}}
	}
}

local item = util.table.deepcopy(data.raw["item"]["constant-combinator"])
item.name = name
item.place_result = name
item.order = "b[combinators]-cb[" .. name .."]"
item.icon = root .. "/graphics/" .. name .. "-icon.png"

local recipe = util.table.deepcopy(data.raw["recipe"]["constant-combinator"])
recipe.name = name
recipe.result = name

table.insert(data.raw.technology["circuit-network"].effects, { type = "unlock-recipe", recipe = name })

data:extend({entity, item, recipe})