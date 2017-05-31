-------------------------------------------------------------------------------
-- bios

require("lib")

bios = {}
local bios_mt = new_class(bios)

function bios:new(control)
	return setmetatable( { control = control }, bios_mt)
end

function bios:clear()
    self.control.enabled = true
    self.control.parameters = { parameters = {} }
end

function bios:inr(signal) -- in red
	local red = self.control.get_circuit_network(defines.wire_type.red)
	local result = 0
	if red then
		result = red.get_signal(signal) or 0
	end
	return result	
end

function bios:ing(signal) -- in green
	local green = self.control.get_circuit_network(defines.wire_type.green)
	local result = 0
	if green then 
		result = green.get_signal(signal) or 0
	end
	return result	
end

function bios:inrg(signal)  -- in r+g
	return self:INR(signal) + self:ING(signal)
end

function bios:ins(include_red, include_green) -- in snapshot r+g
	local network = {}
	if include_red == nil or include_red then
		local red = self.control.get_circuit_network(defines.wire_type.red)
		if red and red.signals then
			for _,v in pairs(red.signals) do
				if v.signal.name then
					network[v.signal.name] = v.count
				end
			end
		end
	end	
	if include_green == nil or include_green then
		local green = self.control.get_circuit_network(defines.wire_type.green)
		if green and green.signals then
			for _,v in pairs(green.signals) do
				if v.signal.name then				
					network[v.signal.name] = (network[v.signal.name] or 0) + v.count --network[v.signal.name] = v
				end
			end
		end
	end	
	return network
end

function bios:gets() -- get out snapshot	
	local result = {}
	for k, v in pairs(self.control.parameters.parameters) do
		if v.signal.name then
			result[v.signal.name] = v.count
		end
	end
	return result
end

function bios:get(signal)
	for _, v in pairs(self.control.parameters.parameters) do
		if v.signal == nil or v.signal.name == nil then
			return 0
		elseif v.signal.name == signal then
			return v.count
		end
	end	
end

function bios:outs(signals) -- set out snapshot
	local parameters =  {}
	local index = 1
	for n, v in pairs(signals) do
		table.insert(parameters, {index = index, signal = {name = n, type = string.starts(n, "signal-") and "virtual" or "item"}, count = v or 1})
		index = index + 1
	end	
	self.control.parameters = { parameters = parameters }
	self.control.enabled = true
end

function bios:out(signal, value)	
	local parameters = self.control.parameters
	for _, v in pairs(parameters.parameters) do		
		if v.signal == nil or v.signal.name == nil then
			v.signal = {name = signal, type = string.starts(signal, "signal-") and "virtual" or "item"}
			v.count = value or 1	
			break
		elseif v.signal.name == signal then
			v.count = value or 1
			break
		end
	end
	self.control.parameters = parameters
	self.control.enabled = true
end

return bios