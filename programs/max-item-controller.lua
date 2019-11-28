local root = require "root"

local function get_modules(object, data)
	local module_io
	local modules = object.entity.surface.find_entities_filtered({ area = position_area(object.entity.position, 1), type = "constant-combinator" })
	for i, module in pairs(modules) do
		if not module_io and module.name == "lua-processor-io" then
			module_io = module
			break
		end
	end
	if module_io then module_io, data.eid_io = find_object(module_io) end
	return module_io
end

local name = "max-item-controller"
root[name] = {
	-------------------------------------------------------------------------------------------------------------------
	on_load = function(object, player)
		object.program_data[name] = object.program_data[name] or {
			tick = 0,
		}
	end,
	-------------------------------------------------------------------------------------------------------------------
	on_tick = function(object, tick)
		local data = object.program_data[name]
		if data.tick > tick then return	end
		data.tick = tick + 30 * 1 -- every 1 second
		-- get modules
		local module_io = get_modules(object, data)
		if not module_io then
			if not module_io then banner("IO module not found!", object.entity.position, object.entity.surface) end
			object.io:clear()
			return
		end
		-- process
		local outs = {} -- out snapshot
		local ins = module_io.io:ins() -- in snapshot
		local max_signal = nil
		for _, value in pairs(ins) do
			if value.signal.type == "item" then
				-- process only items
				if max_signal == nil or value.count > max_signal.count then
					max_signal = value
				end
			end
		end
		if max_signal ~= nil then
			outs[max_signal.signal.name] = max_signal
		end
		object.io:outs(outs)
	end,
	description = [[Outputs to CPU's port maximum item signal that found
	in circuit attached to IO port]],
}