--luacheck: no max line length
--luacheck: ignore script global defines cyberchest

require("script/includes");

local handlers = require("event/handlers");
local version = 10;
local forced_reset = false;
script.on_init(function()
	if not global.cyberchests then global.cyberchests = {}; end
	global.gui = new_gui();
	global.version = version;
end);


script.on_load(function()
	--not allowed to change global table in onload
	for _,chest in pairs(global.cyberchests) do
		setmetatable(chest, cyberchest)
	end
	if forced_reset then
		for _,chest in pairs(global.cyberchests) do
			chest.state = chest.ready
			chest.all_green = false
		end
	end
	global.gui = new_gui()
end)

script.on_configuration_changed(handlers.on_configuration_changed)

local function register(name)
	script.on_event(defines.events[name],handlers[name])
end;

register("on_built_entity")
register("on_robot_built_entity")
register("on_tick")
register("on_gui_opened")
register("on_gui_closed")
register("script_raised_destroy")
register("on_entity_died")
register("on_player_mined_entity")

script.on_event(defines.events.on_gui_click, function(event)
	global.gui.dispatch(event.player_index, event.element.name)
end)

--[[script.on_event(defines.events.onentitydied, function(event)
	if event.entity.name == "cyberchest" then
		cyberchest_get_from_entity(entity) = nil
	end
end)

script.on_event(defines.events.onentitydied, function(event)
	if event.entity.name == "cyberchest" then
		cyberchest_get_from_entity(entity) = nil
	end
end)]]