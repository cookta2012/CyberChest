--luacheck: no max line length, ignore global

local utils = {}

--checks if assembler is occupied by some chest
function utils.is_assembler_free(assembler)
	for _,chest in pairs(global.cyberchests) do
		if chest:has_assembler() and assembler == chest.assembler then
			return false
		end
	end
	return true
end

function utils.cyberchest_get_from_entity(entity)
	for _,chest in pairs(global.cyberchests) do
		if entity == chest.entity then
			return chest
		end
	end
	return nil
end

function utils.cyberchest_get_from_meta_cyberchest(entity)
	for _,chest in pairs(global.cyberchests) do
		if entity == chest.entity then
			return chest
		end
	end
	return nil
end

function utils.every_ticker()
	-- reset index if out of bounds
	for i,v in ipairs(global.cyberchests) do
		if not v:on_tick() then
			table.remove(global.cyberchests, i)
		end
	end
end

return utils