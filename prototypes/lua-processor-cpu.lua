local root = "__lua-processor__"
local name = "lua-processor-cpu"

local entity = util.table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
entity.name = name
entity.minable.result = name
entity.item_slot_count = 60
entity.icon = root .. "/graphics/" .. name .. "-icon.png"

local offset_x = {128, 0, 192, 64}
local directions = {"north", "east", "south", "west"}
for _, value in pairs(directions) do
	entity.sprites[value] =	{
		filename = root .. "/graphics/" .. name .. ".png",
		y = 0, x = offset_x[_],
		width = 64, height = 64,
		priority = "high",
		frame_count = 1,
		shift = {0, 0},
	}	
	entity.activity_led_sprites[value].shift = {0.0,-0.25}
	entity.activity_led_sprites[value].filename = entity.activity_led_sprites.north.filename
end

entity.circuit_wire_connection_points =
{
  {
	shadow = { red = {0.15625, -0.28125}, green = {0.65625, -0.25}},
	wire = { red = {-0.28125, -0.5625}, green = {0.21875, -0.5625}}
  },
  {
	shadow = { red = {0.75, 0.15}, green = {0.75, 0.55}},
	wire = { red = {0.46875, -0.2}, green = {0.46875, 0.2}}
  },
  {
	shadow = { red = {0.75, 0.9625}, green = {0.21875, 0.9625}},
	wire = { red = {0.28125, 0.55625}, green = {-0.21875, 0.55625}}
  },
  {
	shadow = { red = {-0.03125, 0.48125}, green = {-0.03125, 0.75}},
	wire = { red = {-0.46875, 0.2}, green = {-0.46875, -0.20625}}
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