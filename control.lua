require "defines"
require "script.cyberchest"
require "script.gui"
local version = 9
local forced_reset = false
tickerA = 1
script.on_init(function()
if not global.cyberchests then global.cyberchests = {} end
global.gui = new_gui()
global.version = version
end)

script.on_load(function()
	for _,chest in pairs(global.cyberchests) do
		setmetatable(chest, cyberchest)
	end
	if not global.version or global.version < version then
		migrate()
	end
	if forced_reset then
		for _,chest in pairs(global.cyberchests) do
			chest.state = chest.ready
			chest.all_green = false
		end
	end
	
	global.gui = new_gui()
end)

function migrate()
	if not global.version then
		global.version = 9
		for _,chest in pairs(global.cyberchests) do
			chest.state = chest.ready
			chest.all_green = false
		end
	end
	--add migration for future updates here
	--if global.version < 10 then
	
end

script.on_event(defines.events.on_built_entity, function(event)
	if event.created_entity.name == "cyberchest" then
		table.insert(global.cyberchests, cyberchest:new({entity = event.created_entity, is_asm_free = is_assembler_free}))
		--game.players[1].print("chest_created")
	end
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
	if event.created_entity.name == "cyberchest" then
		table.insert(global.cyberchests, cyberchest:new({entity = event.created_entity, is_asm_free = is_assembler_free}))
		--game.players[1].print("chest_created")
	end
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

--checks if assembler is occupied by some chest
function is_assembler_free(assembler)
	for _,chest in pairs(global.cyberchests) do
		if chest:has_assembler() and assembler == chest.assembler then
			return false
		end
	end 
	return true
end

function cyberchest_get_from_entity(entity)
	for _,chest in pairs(global.cyberchests) do
		if entity == chest.entity then
			return chest
		end
	end 
	return nil
end

script.on_event(defines.events.on_tick, function(event)
cycles = math.floor((#global.cyberchests /60)+1.5)
--game.players[1].print(cycles)
  for cycle = 1, cycles do
    if (tickerA+((cycle-1)*60)) <= #global.cyberchests then
	    chest = global.cyberchests[tickerA+((cycle-1)*60)]
		if chest:is_valid() then
			chest:state_execute()
		else	
			chest:destroy_beacon()
			chest = nil
			table.remove(global.cyberchests,i)
		end
  end
end
  if tickerA == 60 then
    tickerA = 1
  else
    tickerA = tickerA + 1
  end 
  if event.tick % 20 ~= 0 then return end
	for i,player in pairs(game.players) do
		if player.character and player.opened and player.opened.name == 'cyberchest' then
		    thingOpened = cyberchest_get_from_entity(player.opened)
			if thingOpened ~= nil then
			  global.gui.show(i, cyberchest_get_from_entity(player.opened))
			end
		else
			global.gui.hide(i)
		end
	end
end)

script.on_event(defines.events.on_gui_click, function(event)
	global.gui.dispatch(event.player_index, event.element.name)
end)

