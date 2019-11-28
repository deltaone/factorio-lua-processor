local root = require "root"

local name = "ghost-alert-sensor"
root[name] = {
	-------------------------------------------------------------------------------------------------------------------
	on_load = function(object, player)
		object.program_data[name] = object.program_data[name] or {
			tick = 0,
			sensor = true,
			sensor_name = name
		}
	end,
	-------------------------------------------------------------------------------------------------------------------
	on_tick = function(object, tick)
		local data = object.program_data[name]
		if data.tick > tick then return	end
		data.tick = tick + 60 * 1 -- every 1 second

		local req = {}
		local lognetwork = object.entity.surface.find_logistic_network_by_position(object.entity.position, game.players[1].force)
		if lognetwork == nil then
			banner("Logistic Network not found", object.entity.position, object.entity.surface)
			object.io:clear()
			return
		end
		local notenougmats = game.players[1]:get_alerts(null, null, null,
			defines.alert_type.no_material_for_construction, object.entity.surface)
		for _, surface in pairs(notenougmats) do
			for _, alert in pairs(surface[defines.alert_type.no_material_for_construction]) do
				if alert.target ~= nil and alert.target.type == "entity-ghost" then
					for _, cell in pairs(lognetwork.cells) do
						if cell.is_in_construction_range(alert.position) then
							local name = alert.target.ghost_name
							if name == "curved-rail" or name == "straight-rail" then name = "rail" end
							req[name] = (req[name] or 0) + 1
							break
						end
					end
				end
			end
		end

		local outs = {}
		for _name, _count in pairs(req) do
			outs[_name] = {signal = {name = _name, type = "item"}, count = _count}
		end

		object.io:outs(outs)
	end,
	description = [[Reads alerts for items requests and outputs to circuit
	network. Handy to automate supply items for blueprint building.]],
}