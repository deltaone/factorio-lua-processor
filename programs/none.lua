local root = require "root"

local name = "none"
root[name] = {
	on_load = function(object, player)
	end,
	on_tick = function(object, tick)	
	end,
	on_destroy = function(object)
	end,
	on_gui_create = function(object, player, gui)
	end,
	on_gui_destroy = function(object, player)
	end,
	on_gui_click = function(object, player, element)
	end,
	on_settings_pasted = function(object_src, object_dst)
	end,
}