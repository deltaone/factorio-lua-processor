local root = require "root"

local function get_modules(object, data)
	local module_io, module_ram
	local modules = object.entity.surface.find_entities_filtered({ area = position_area(object.entity.position, 1), type = "constant-combinator" })
	for i, module in pairs(modules) do
		if not module_io and module.name == "lua-processor-io" then module_io = module
		elseif not module_ram and module.name == "lua-processor-ram" then module_ram = module end
		if module_io and module_ram then break end
	end
	if module_io then module_io, data.eid_io = find_object(module_io) end
	if module_ram then module_ram, data.eid_ram = find_object(module_ram) end
	return module_io, module_ram
end

local name = "storage-controller"
root[name] = {
	-------------------------------------------------------------------------------------------------------------------
	on_load = function(object, player)
		object.program_data[name] = object.program_data[name] or { 
			states = {},
			threshold = 10, 
			single_signal = true,
			tick = 0,
		}
	end,
	-------------------------------------------------------------------------------------------------------------------
	on_tick = function(object, tick)
		local data = object.program_data[name]
		if data.tick > tick then return	end
		data.tick = tick + 60 * 1 -- every 1 second
		-- get modules
		local module_io, module_ram = get_modules(object, data)
		if not module_io or not module_ram then
			if not module_io then banner("IO module not found!", object.entity.position, object.entity.surface) end
			if not module_ram then banner("RAM module not found!", { object.entity.position.x, object.entity.position.y - 1}, object.entity.surface) end
			object.io:clear()
			return
		end		
		-- process
		local outs = {} -- out snapshot
		local ins = module_io.io:ins() -- in snapshot
		local ram = module_ram.io:gets() -- ram snapshot
		for _, value in pairs(ram) do
			local _in_ = ins[_] or 0
			if not data.states[_] and _in_ <= value * (data.threshold / 100) then
				data.states[_] = true
			elseif data.states[_] and _in_ >= value then
				data.states[_] = false
			end
			if data.states[_] then	
				outs[_] = 1
				if data.single_signal then break end
			end
		end
		object.io:outs(outs)
	end,
	-------------------------------------------------------------------------------------------------------------------
	on_gui_create = function(object, player, gui)
		local data = object.program_data[name]
		gui_or_new(gui, "single-signal", { type = "checkbox", name = "single-signal", caption = "Single signal output", state = data.single_signal or false })
		local panel = gui_or_new(gui, "selector-panel", {type = "flow", name = "selector-panel", direction = "horizontal"})		
		gui_or_new(panel, "threshold-label", {type = "label", name = "threshold-label", caption = "Minimal threshold, %", style = "label_style_1"})
		gui_or_new(panel, "threshold-selector", {type = "drop-down", name = "threshold-selector",
			items = {5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95},  selected_index = data.threshold / 5 })	
		gui_or_new(gui, "ok", { type = "button", name = "ok", caption="OK" })
	end,
	-------------------------------------------------------------------------------------------------------------------
	on_gui_click = function(object, player, element)
		if element.name ~= "ok" then return end
		local data = object.program_data[name]
		data.threshold = element.parent["selector-panel"]["threshold-selector"].selected_index * 5
		data.single_signal = element.parent["single-signal"].state
		say(player, "Program configuration updated!")
	end,
	-------------------------------------------------------------------------------------------------------------------
}