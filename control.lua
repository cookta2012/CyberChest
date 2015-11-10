require "defines"
require "script.cyberchest"
require "script.gui"
local version = 9
local forced_reset = false
game.oninit(function()
if not glob.cyberchests then glob.cyberchests = {} end
glob.gui = new_gui()
glob.version = version
end)

game.onload(function()
	for _,chest in pairs(glob.cyberchests) do
		setmetatable(chest, cyberchest)
	end
	if not glob.version or glob.version < version then
		migrate()
	end
	if forced_reset then
		for _,chest in pairs(glob.cyberchests) do
			chest.state = chest.ready
			chest.all_green = false
		end
	end
	
	glob.gui = new_gui()
end)

function migrate()
	if not glob.version then
		glob.version = 9
		for _,chest in pairs(glob.cyberchests) do
			chest.state = chest.ready
			chest.all_green = false
		end
	end
	--add migration for future updates here
	--if glob.version < 10 then
	
end

game.onevent(defines.events.onbuiltentity, function(event)
	if event.createdentity.name == "cyberchest" then
		table.insert(glob.cyberchests, cyberchest:new({entity = event.createdentity, is_asm_free = is_assembler_free}))
		--game.players[1].print("chest_created")
	end
end)

game.onevent(defines.events.onrobotbuiltentity, function(event)
	if event.createdentity.name == "cyberchest" then
		table.insert(glob.cyberchests, cyberchest:new({entity = event.createdentity, is_asm_free = is_assembler_free}))
		--game.players[1].print("chest_created")
	end
end)



--[[game.onevent(defines.events.onentitydied, function(event)
	if event.entity.name == "cyberchest" then
		cyberchest_get_from_entity(entity) = nil
	end
end)

game.onevent(defines.events.onentitydied, function(event)
	if event.entity.name == "cyberchest" then
		cyberchest_get_from_entity(entity) = nil
	end
end)]]

--checks if assembler is occupied by some chest
function is_assembler_free(assembler)
	for _,chest in pairs(glob.cyberchests) do
		if chest:has_assembler() and assembler.equals(chest.assembler) then
			return false
		end
	end 
	return true
end

function cyberchest_get_from_entity(entity)
	for _,chest in pairs(glob.cyberchests) do
		if entity.equals(chest.entity) then
			return chest
		end
	end 
	return nil
end

game.onevent(defines.events.ontick, function(event)
	if event.tick % 20 ~= 0 then return end
	--game.players[1].print(#glob.cyberchests)
	
	for i,chest in pairs(glob.cyberchests) do
		if chest:is_valid() then
			chest:state_execute()
		else	
			chest:destroy_beacon()
			chest = nil
			table.remove(glob.cyberchests,i)
		end
	end

	for i,player in pairs(game.players) do
		if player.character and player.opened and player.opened.name == 'cyberchest' then
			glob.gui.show(i, cyberchest_get_from_entity(player.opened))
		else
			glob.gui.hide(i)
		end
	end
	
end)

game.onevent(defines.events.onguiclick, function(event)
	
	glob.gui.dispatch(event.playerindex, event.element.name)
end)

