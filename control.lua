-- /c remote.call("lua-processor", "initialize") 
require("config")
require("lib")
require("bios")

-------------------------------------------------------------------------------
-- data

local programs, programs_id = require("programs.index")() --[[ user programs connection point ]]--
local object_tag_source = {}; for i = 1, 100 do object_tag_source[i] = i end -- used for assign tag's to objects 1-100 (static table)

-------------------------------------------------------------------------------
-- main

local function initialize(reset)
	if reset then
		global = {}
		for _, force in pairs(game.forces) do
			if force.technologies["circuit-network"].researched then
				force.recipes["lua-processor-cpu"].enabled = true
				force.recipes["lua-processor-io"].enabled = true
				force.recipes["lua-processor-ram"].enabled = true
				shout(string.format("lua-processor: enabled for force %s", force.name))
			end
		end
	end
	global.objects  = global.objects  or {}
	global.opened  = global.opened  or {}
	shout("lua-processor: initilized !")
end
remote.add_interface("lua-processor", {	initialize = function()	initialize(true); end })

local banner_color_default = {r = 1, g = 1, b = 1}
function banner(text, position, surface, color)
	surface.create_entity({ name = "flying-text-banner", position = position, text = text, color = (color and color or banner_color_default)})
end

-------------------------------------------------------------------------------
-- controllers

local controller = {}

controller["lua-processor-cpu"] = {
	-------------------------------------------------------------------------------------------------------------------
	on_built = function(entity)
		if global.objects == nil then global.objects = {} end
		local object = {
			tag = 1,
			entity = entity,
			program_id = nil, -- nil  "storage-controller"  "lua-executor"
			program_data = {},
			io = bios:new(entity.get_or_create_control_behavior()),
		}
		global.objects[get_eid(entity)] = object
	end,
	-------------------------------------------------------------------------------------------------------------------
	on_destroy = function(entity)
		local object, eid = find_object(entity)
		if not object then return end
		
		if object.program_id and programs[object.program_id] and programs[object.program_id].on_destroy ~= nil then
			programs[object.program_id].on_destroy(object)
		end
		global.objects[eid] = nil
	end,
	-------------------------------------------------------------------------------------------------------------------
	on_tick = function(eid, object, tick)
		if object.io.control.enabled == false then return end	
		if object.program_id and programs[object.program_id] and programs[object.program_id].on_tick ~= nil then
			programs[object.program_id].on_tick(object, tick)
		end
	end,
	-------------------------------------------------------------------------------------------------------------------
	on_gui_create = function(entity, player)
		local object = find_object(entity)
		if not object then return end
		
		local selected_index = 1
		if object.program_id then
			for k, v in pairs(programs_id) do  
				if object.program_id == v then selected_index = k; break; end
			end
		end
				
		gui = gui_or_new(player.gui.left, entity.name, {type = "frame", name = entity.name, caption = {"msg-options-title"}, direction = "vertical"})		
		panel = gui_or_new(gui, "panel", {type = "flow", name = "panel", direction = "vertical"})
		
		tag_panel = gui_or_new(panel, "tag-panel", {type = "flow", name = "tag-panel", direction = "horizontal"})
		gui_or_new(tag_panel, "tag-label", {type = "label", name = "tag-label", caption = {"msg-object-tag-label"}, style = "label_style_1"})
		gui_or_new(tag_panel, "tag-selector", {type = "drop-down", name = "tag-selector", items = object_tag_source, selected_index = object.tag })
		gui_or_new(tag_panel, "tag-ok", {type="button", name = "tag-ok", caption = "OK", style = "button_style_1"}) 
				
		gui_or_new(panel, "program-current", {type = "label", name = "program-current",  caption = {"msg-program-id-current", object.program_id or "none"}, style = "label_style_1" })				
		program_panel = gui_or_new(panel, "program-panel", {type="flow", name="program-panel", direction="horizontal"})
		gui_or_new(program_panel, "program-label", {type = "label", name = "program-label", caption = {"msg-program-id", ""} })
		gui_or_new(program_panel, "program-selector", {type = "drop-down", name = "program-selector", items = programs_id, selected_index = selected_index })
		gui_or_new(program_panel, "program-load", {type = "button", name = "program-load", caption = {"msg-button-load"}, style = "button_style_1"}) 

		description_panel = gui_or_new(panel, "description-panel", {type="flow", name="description-panel", direction="horizontal"})
		local element = gui_or_new(description_panel, "program-description", {type = "label", name = "program-description", caption = {"", ""}, single_line = false })
		if object.program_id and programs[object.program_id] and programs[object.program_id].description ~= nil then
			-- programs[object.program_id].on_gui_create(object, player, panel)
			element.parent["program-description"].caption = programs[object.program_id].description
		end
				
		if object.program_id and programs[object.program_id] and programs[object.program_id].on_gui_create ~= nil then			
			programs[object.program_id].on_gui_create(object, player, panel)
		end
	end,
	-------------------------------------------------------------------------------------------------------------------	
	on_gui_destroy = function(entity, player)
		local object = find_object(entity)
		if not object then return end
			
		if object.program_id and programs[object.program_id] and programs[object.program_id].on_gui_destroy ~= nil then
			programs[object.program_id].on_gui_destroy(object, player)
		end
	end,
	-------------------------------------------------------------------------------------------------------------------
	on_gui_click = function(entity, player, element)
		local object = find_object(entity)
		if not object then return end
		
		if element.name == "program-load" then
			local new_program_id = programs_id[element.parent["program-selector"].selected_index]			
			if object.program_id ~= new_program_id then
				object.io:clear()
				if new_program_id == "none" then
					object.program_id = nil
				else
					object.program_id = new_program_id				
					say(player, {"msg-program-loaded", object.program_id})
					if programs[object.program_id].on_load ~= nil then
						programs[object.program_id].on_load(object, player)
					end					
				end
				element.parent.parent.parent.destroy()
			end
		elseif element.name == "tag-ok" then
			object.tag = element.parent["tag-selector"].selected_index
			say(player, {"msg-object-tag-changed", object.tag})
		elseif object.program_id and programs[object.program_id] and programs[object.program_id].on_gui_click ~= nil then
			programs[object.program_id].on_gui_click(object, player, element)
		end
	end,
	-------------------------------------------------------------------------------------------------------------------
	on_settings_pasted = function(source, destination) -- src and dst entities
		local object_src = find_object(source)
		local object_dst = find_object(destination)

		if object_src.program_id and programs[object_src.program_id] and programs[object_src.program_id].on_settings_pasted ~= nil then
			programs[object_src.program_id].on_settings_pasted(object_src, object_dst)
		end		
	end,
	-------------------------------------------------------------------------------------------------------------------
}

local controller_shared = {
	-------------------------------------------------------------------------------------------------------------------
	on_built = function(entity)
		if global.objects == nil then global.objects = {} end
		local object = {
			tag = 1,
			entity = entity,
			io = bios:new(entity.get_or_create_control_behavior()),
		}
		global.objects[get_eid(entity)] = object
	end,
	-------------------------------------------------------------------------------------------------------------------
	on_destroy = function(entity)
		local eid, object = find_object(entity)
		if not object then return end
	
		global.objects[eid] = nil 
	end,
	-------------------------------------------------------------------------------------------------------------------
	on_gui_create = function(entity, player)	
		local object = find_object(entity)
		if not object then return end
				
		gui = gui_or_new(player.gui.left, entity.name, {type = "frame", name = entity.name, caption = {"msg-options-title"}, direction = "vertical"})
		panel = gui_or_new(gui, "panel", {type = "flow", name = "panel", direction = "vertical"})
		
		tag_panel = gui_or_new(panel, "tag-panel", {type = "flow", name = "tag-panel", direction = "horizontal"})
		gui_or_new(tag_panel, "tag-label", {type = "label", name = "tag-label", caption = {"msg-object-tag-label"}, style = "label_style_1"})
		gui_or_new(tag_panel, "tag-selector", {type = "drop-down", name = "tag-selector", items = object_tag_source, selected_index = object.tag })
		gui_or_new(tag_panel, "tag-ok", {type="button", name = "tag-ok", caption = "OK", style = "button_style_1"})				
	end,
	-------------------------------------------------------------------------------------------------------------------
	on_gui_click = function(entity, player, element)
		local object = find_object(entity)
		if not object then return end

		if element.name == "tag-ok" then
			object.tag = element.parent["tag-selector"].selected_index
			say(player, {"msg-object-tag-changed", object.tag})
		end
	end,
	-------------------------------------------------------------------------------------------------------------------	
}

controller["lua-processor-io"] = controller_shared
controller["lua-processor-ram"] = controller_shared

-------------------------------------------------------------------------------
-- events

local function on_built(event)
	local entity = event.created_entity
	if controller[entity.name] ~= nil and controller[entity.name].on_built then
		controller[entity.name].on_built(entity)
	end
end

local function on_destroy(event)
	local entity = event.entity	
	if controller[entity.name] ~= nil and controller[entity.name].on_destroy ~= nil then
		controller[entity.name].on_destroy(entity)
	end
end

local function on_tick(event)	
	global.objects = global.objects or {} -- if global.objects == nil then return end
	global.opened = global.opened or {}	
	-- handle gui
	if event.tick % config.refresh_rate_gui == 0 then -- 7
		for _, player in pairs(game.players) do
			entity = player.opened
			opened = global.opened[player.index]
			
			isOpen = is_valid(entity) and is_valid_("entity.name") ~= nil and controller[entity.name]
			
			if (not isOpen and opened) or (isOpen and opened and entity ~= opened.entity) then --close = true
				if is_valid(opened.entity) and controller[opened.name].on_gui_destroy ~= nil then 
					controller[opened.name].on_gui_destroy(opened.entity)
				end
				if player.gui.left[opened.name] ~= nil then 
					player.gui.left[opened.name].destroy()				
				end
				global.opened[player.index] = nil								
			elseif isOpen and not opened then --open = true
				if not player.gui.left[entity.name] and controller[entity.name].on_gui_create ~= nil then
					global.opened[player.index] = { entity = entity, name = entity.name }
					controller[entity.name].on_gui_create(entity, player)					
				end									
			end		
--[[		
			if is_valid(entity) and is_valid_("entity.name") ~= nil and controller[entity.name] and controller[entity.name].on_gui_create ~= nil then 
				if not player.gui.left[entity.name] and opened == nil then
					global.opened[player.index] = { entity = entity, name = entity.name }
					controller[entity.name].on_gui_create(entity, player)					
				end			
			elseif opened and player.gui.left[opened.name] ~= nil then
				if is_valid(opened.entity) and controller[opened.name].on_gui_destroy ~= nil then 
					controller[opened.name].on_gui_destroy(opened.entity)
				end
				player.gui.left[opened.name].destroy()
				global.opened[player.index] = nil
			end
]]--		
		end		
	end 

	-- handle entity update
	if event.tick % config.refresh_rate == 0 then -- 23
		for index, object in pairs(global.objects) do
			if object.entity.valid and controller[object.entity.name].on_tick ~= nil then			
				controller[object.entity.name].on_tick(index, object, event.tick)
			end
		end
	end
end

local function on_gui_click(event)
	local player = game.players[event.player_index]
	local entity = player.opened
	
	if is_valid(entity) and controller[entity.name] and controller[entity.name].on_gui_click then
		controller[entity.name].on_gui_click(entity, player, event.element)
	end	
end 

local function on_settings_pasted(event)
	if event.source.name ~= event.destination.name or controller[event.source.name] == nil or controller[event.source.name].on_settings_pasted == nil then
		return
	end
	controller[event.source.name].on_settings_pasted(event.source, event.destination)
end

local function on_init()
	initialize(true)
end

local function on_load() 
	if global.objects ~= nil then
		for _,object in pairs(global.objects) do
			object.io = bios:new(object.io.control)
		end
	end
end

local function on_configuration_changed()
	initialize(false)
end

--[[ Setup event handlers ]]--

script.on_init(on_init)
script.on_load(on_load)
script.on_configuration_changed(on_configuration_changed)
script.on_event(defines.events.on_tick, on_tick)
script.on_event(defines.events.on_gui_click, on_gui_click)
script.on_event(defines.events.on_built_entity, on_built)
script.on_event(defines.events.on_robot_built_entity, on_built)
script.on_event(defines.events.on_pre_player_mined_item, on_destroy)
script.on_event(defines.events.on_robot_pre_mined, on_destroy)
script.on_event(defines.events.on_entity_died, on_destroy)
script.on_event(defines.events.on_entity_settings_pasted, on_settings_pasted)
