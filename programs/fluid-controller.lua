local root = require "root"

local name = "fluid-controller"
root[name] = {
	on_load = function(object, player) 
		object.program_data[name] = object.program_data[name] or { 			
			cleanup = false,
			cleanup_tick = 0,
			fluid = "",
			item = "",
			tick = 0,
		}
		object.io:clear()
	end,
	on_tick = function(object, tick)
		local data = object.program_data[name]
		if data.tick > tick then return	end
		data.tick = tick + 60 * 5 -- every 5 second
		
		local ins = object.io:ins() -- in snapshot
		item = data["item"]
		for _, value in pairs(ins) do 
			item = _ --value.signal.name
			break
		end
		if item == data["item"] then
			return
		end

		fluid = data["fluid"]
		if item == "processing-unit" then
			fluid = "sulfuric-acid"
		elseif item == "express-transport-belt" or item == "express-underground-belt" or item == "express-splitter" or item == "electric-engine-unit" then
			fluid = "lubricant"
		elseif item == "concrete" or item == "refined-concrete" then
			fluid = "water"
		end

		if fluid == data["fluid"] then
			data["item"] = item
			return
		end

		position_forward = position_move(object.entity.position, object.entity.direction, 1)
		position_left = position_move(object.entity.position, direction_rotate(object.entity.direction, 270), 1)
		position_right = position_move(object.entity.position, direction_rotate(object.entity.direction, 90), 1)
		
		if data["cleanup"] then
			local amount = 0
			local pipes = object.entity.surface.find_entities_filtered({ area = position_area(object.entity.position, 1), type = "pipe" }) 
			for i, pipe in pairs(pipes) do
				for i = 1, #pipe.fluidbox do --pipe.fluidbox[i] = nil					
					if pipe.fluidbox[i] ~= nil then
						amount = pipe.fluidbox[i].amount
					end
				end				
			end
			if amount ~= 0 then 
				return							
			end

			pipes = object.entity.surface.find_entities_filtered({ area = position_area(position_left, 0), type = "pipe" })
			for i, pipe in pairs(pipes) do 
				pipe.destroy()
			end
			objs = object.entity.surface.find_entities(position_area(object.entity.position, 2))
			for i, obj in pairs(objs) do 
				for i = 1, #obj.fluidbox do 
					obj.fluidbox[i] = nil
				end
			end

			if fluid == "sulfuric-acid" then
				object.entity.surface.create_entity({name="pipe-to-ground", amount = 1, force=object.entity.force, direction=direction_rotate(object.entity.direction, 180),
					position = position_move(object.entity.position, direction_rotate(object.entity.direction, 360), 2)})			
			elseif fluid == "lubricant" then
				object.entity.surface.create_entity({name="pipe-to-ground", amount = 1, force=object.entity.force, direction=direction_rotate(object.entity.direction, 180), 
					position = position_move(position_left, direction_rotate(object.entity.direction, 360), 2)})
			elseif fluid == "water" then
				object.entity.surface.create_entity({name="pipe-to-ground", amount = 1, force=object.entity.force, direction=direction_rotate(object.entity.direction, 180),
					position = position_move(position_right, direction_rotate(object.entity.direction, 360), 2)})			
			end
			
			data["cleanup"] = false
			data["item"] = item
			data["fluid"] = fluid
		else -- start caleanup
			data["cleanup"] = true
			local pipes = object.entity.surface.find_entities_filtered({ area = position_area(position_forward, 1), type = "pipe-to-ground" }) 
			for i, pipe in pairs(pipes) do 
				pipe.destroy()
			end
			object.entity.surface.create_entity({name="pipe", amount = 1, force=object.entity.force, position = position_left, 1})
		end
		
		--game.print(dump(ins))
		--game.print(item)		
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
