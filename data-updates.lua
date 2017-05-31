require("prototypes.styles")
require("prototypes.lua-processor-cpu")
require("prototypes.lua-processor-io")
require("prototypes.lua-processor-ram")

data:extend({
  {
    type = "flying-text",
    name = "flying-text-banner",
    flags = {"not-on-map"},
    time_to_live = 30,
    speed = 0.0
  }
})