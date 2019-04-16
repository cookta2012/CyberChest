--luacheck: no max line length
--luacheck: ignore global
--luacheck: ignore cyberchest
--luacheck: ignore game defines
--luacheck: ignore Table utils

local utils = require("__CyberChest__/utils/utils");
local GUI = require("__CyberChest__/script/new_gui");

local handlers = {};

handlers.init = function(options)
end;

function handlers.on_configuration_changed(event)
	if not global.version then
		global.version = version
		for _,chest in pairs(global.cyberchests) do
			chest.state = chest.ready
			chest.all_green = false
		end
	end
	--add migration for future updates here
	--if global.version < 10 then
end;

function handlers.on_robot_built_entity(event)
	handlers.on_built_entity(event);
end;

function handlers.on_built_entity(event)
	local entity = event.created_entity;
	if entity.name == "cyberchest_meta" then
		local _cyberchest = entity.surface.create_entity{
			name="cyberchest",
			position=entity.position,
			force="neutral",
			create_build_effect_smoke=false
		}
		entity.surface.print("Spawned Cyberchest from Meta")
		table.insert(global.cyberchests, cyberchest:new({entity = _cyberchest, is_asm_free = utils.is_assembler_free}))
	end;
end;

function handlers.on_gui_opened(event)
	local player = game.players[event.player_index];
	local entity = event.entity
	if player.opened then
		if event.entity and player.opened.name == 'cyberchest_meta' then
			local cyberchest = entity.surface.find_entity("cyberchest", {entity.position.x,player.opened.position.y});
			if cyberchest then
				player.surface.print("Found Cyberchest");
			end
			player.opened.destroy{raise_destroy=true};
			global.gui.show(event.player_index, utils.cyberchest_get_from_entity(cyberchest))
			return;
		end;
		if player.opened.name == "cyberchest_main" then
			player.surface.print("WORKING BABY")
			return;
		end;
	end;
end;

function handlers.on_gui_closed(event)
	local player = game.players[event.player_index];
	if event.element then
		if event.element.name == "cyberchest_main" then
			global.gui.hide(event.player_index)
		end;
	end;
end;

function handlers.script_raised_destroy(event)
	local entity = event.entity;
	if entity.name == "cyberchest_meta" then
		entity.surface.create_entity{
			name="cyberchest_meta",
			position=entity.position,
			force="neutral",
			create_build_effect_smoke=false
		}
	end;
end;

function handlers.on_entity_died(event)
end;

function handlers.on_player_mined_entity(event)
	local entity = event.entity;
	if entity.name == "cyberchest_meta" then
		local cyberchest = entity.surface.find_entity("cyberchest", {entity.position.x, entity.position.y});
		if cyberchest then
			cyberchest.destroy{raise_destroy=true};
		end;
	end
end;

function handlers.on_tick(event)
	utils.every_ticker()
	--game.players[1].print(cycles)
	--[[
	if event.tick % 20 ~= 0 then
		for i,player in pairs(game.players) do
			if player.character and player.opened and player.opened.name == 'cyberchest' then
				thingOpened = utils.cyberchest_get_from_entity(player.opened)
				if thingOpened ~= nil then
					global.gui.show(i, utils.cyberchest_get_from_entity(player.opened))
				end
			else
				global.gui.hide(i)
			end
		end
	end]]
end;

return handlers;