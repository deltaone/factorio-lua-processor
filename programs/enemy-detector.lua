local root = require "root"

local name = "enemy-detector"
root[name] = {
	on_load = function(object, player) 
		object.program_data[name] = object.program_data[name] or { 
			alert = false,
			alert_tick = 0,
			tick = 0,
		}
		object.io:clear()
	end,
	on_tick = function(object, tick)
		local data = object.program_data[name]
		if data.tick > tick then return	end
		data.tick = tick + 60 * 2 -- every 2 second
			
		local enemies = object.entity.surface.find_entities_filtered
		({
			area = {{ x = object.entity.position.x - 30, y = object.entity.position.y - 30}, { x = object.entity.position.x + 30, y = object.entity.position.y + 30}},
			type = "unit", 
			force = game.forces.enemy
		})
		
		if #enemies >= 1 then
			data.alert_tick = tick
			if not data.alert then
				data.alert = true
				object.io:out({signal = {name = "signal-red", type = "virtual"}, count = 1})
				--object.io:out("signal-red", 1)			
			end
		else 
			if data.alert and tick > data.alert_tick + 60 * 15 then
				data.alert = false
				object.io:clear() 			
			end
		end
		
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


