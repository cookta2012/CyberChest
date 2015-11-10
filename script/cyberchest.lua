require "defines"

--tips, limitations, and known issues 
--productivity modules
--autoreset
--do not take anything (apart from modules) directly from the assembler
--you can insert some, but not all of the ingredients directly to the assembler
--use smart inserters for chest or assembler input (connect them with wires)

--transforms recipe.ingredient format to simplestack format
function ingredients_to_simplestack(recipename)
	local ingredients = game.forces.player.recipes[recipename].ingredients
	local stack = {}
	for i, ingredient in pairs(ingredients) do
		if ingredient.type == defines.recipe.materialtype.item then
			table.insert(stack, {name = ingredient.name, count = ingredient.amount})
		end
	end
	return stack
end

--safe stack transer, true on success, false on failure (stack remains untouched)
function stack_transfer(source_inv, stack, target_inv)
	local source_init_count = source_inv.getitemcount(stack.name)
	local target_init_count = target_inv.getitemcount(stack.name)
	--check if the inventories are valid for transfer
	if source_init_count < stack.count or not target_inv.caninsert(stack) then 
		return false 
	end
	target_inv.insert(stack)
	--check if all the items were transferred
	if target_inv.getitemcount(stack.name) < target_init_count + stack.count then
		if not target_inv.remove then
			target_inv.removeitem({name = stack.name, count = target_inv.getitemcount(stack.name) - target_init_count})
		else
			target_inv.remove({name = stack.name, count = target_inv.getitemcount(stack.name) - target_init_count})
		end
		return false
	end
	
	if not source_inv.remove then
		source_inv.removeitem(stack) --entity method
	else
		source_inv.remove(stack)
	end
	return true	
end

function positive(number)
	if number > 0 then
		return number
	else
		return 0
	end
end

function table_concat(t1,t2)
    for _,item in pairs(t2) do
        table.insert(t1, item)
    end
    return t1
end

cyberchest = {}
cyberchest.__index = cyberchest
cyberchest.requester_slots = 10
cyberchest.assembler = nil
cyberchest.entity = nil	
cyberchest.is_asm_free = nil
cyberchest.current_order = 1
cyberchest.working = false
cyberchest.autoreset = true
cyberchest.autoreset_count = 30

cyberchest.state = cyberchest.ready
cyberchest.message = "Awaiting orders.."

function cyberchest.new(self,t)
	new = t or {}
	setmetatable(new, self)
	--self.__index = self
	return new
end
--run state machine, ensures that chest has an assembler attached
function cyberchest.state_execute(self)
	if not self:has_assembler() then 
		self.state = self.find_assembler 
		self.message = "Looking for an assembling machine.."
	end 
	--game.players[1].print(self.message)
	self:state() --run state function
end

function cyberchest.on_start_pause(self)
	if self.working then
		self.working = false
		self.state = self.ready
		self.message = "Awaiting orders.."
	else
		self.working = true
	end
end

function cyberchest.on_reset(self)
	self.current_order = 1
	self.state = self.ready
	self.message = "Awaiting orders.."
end

function cyberchest.autoreset_countdown(self)
	self.autoreset_count = self.autoreset_count - 1
	if self.autoreset_count < 0 then
		self.autoreset_count = 30
		self:on_reset()
	end
end

function cyberchest.getorder(self)
	return self.entity.getrequestslot(self.current_order)
end

function cyberchest.getprogress(self)
	if not self:getorder() then
		return 0
	end
	local count = self.entity.getitemcount(self:getorder().name)
	local progress = count/self:getorder().count
	return progress
end

--unused
function cyberchest.error(self)
end
	
--main check
function cyberchest.is_valid(self)
	if self.entity and self.entity.valid then
		return true
	else
		return false
	end
end	
	
function cyberchest.has_assembler(self)
	if self.assembler and self.assembler.valid then
		return true
	else
		return false
	end
end

--starting state
function cyberchest.ready(self)
	if self.working then
		if not self:getorder() then
			self:next_order()
			return
		end
		if self:order_done() then	--next order
			self:next_order()
			return
		end
		self.state = self.initialize_assembler
		self:state()
	end
end


--finds unoccupied assembler (see control.lua/is_assembler_free), clockwise from top
function cyberchest.find_assembler(self)
	local top = {{self.entity.position.x,self.entity.position.y - 2}, {self.entity.position.x, self.entity.position.y}}
	local right = {{self.entity.position.x,self.entity.position.y}, {self.entity.position.x + 2, self.entity.position.y}}
	local left = {{self.entity.position.x - 2,self.entity.position.y}, {self.entity.position.x, self.entity.position.y}}
	local bottom = {{self.entity.position.x,self.entity.position.y}, {self.entity.position.x, self.entity.position.y + 2}}
	
	if not self:has_assembler() then self:search_area(top) end
	if not self:has_assembler() then self:search_area(right) end
	if not self:has_assembler() then self:search_area(left) end
	if not self:has_assembler() then self:search_area(bottom) end
	
	if self:has_assembler() then
		self.state = self.ready
		self.message = "Awaiting orders.."
		self:state()
		return
	end	
end

function cyberchest.search_area(self, area)
	local targets = game.findentitiesfiltered({area = area,type = "assembling-machine"})
	for _,asm in pairs(targets) do
		if self.is_asm_free(asm) then
			self.assembler = asm
			return true
		end
	end	
	return false
end

function cyberchest.on_search_top(self)
	local area = {{self.entity.position.x,self.entity.position.y - 2}, {self.entity.position.x, self.entity.position.y}}
	if not self:search_area(area) then
		self.message = "No suitable assembler was found/occupied already"
	else
		self.state = self.ready
		self.message = "Awaiting orders.."
		self:state()
	end
end

function cyberchest.on_search_right(self)
	local area = {{self.entity.position.x,self.entity.position.y}, {self.entity.position.x + 2, self.entity.position.y}}
	if not self:search_area(area) then
		self.message = "No suitable assembler was found/occupied already"
	else
		self.state = self.ready
		self.message = "Awaiting orders.."
		self:state()
	end
end

function cyberchest.on_search_left(self)
	local area = {{self.entity.position.x - 2,self.entity.position.y}, {self.entity.position.x, self.entity.position.y}}
	if not self:search_area(area) then
		self.message = "No suitable assembler was found/occupied already"
	else
		self.state = self.ready
		self.message = "Awaiting orders.."
		self:state()
	end
end

function cyberchest.on_search_bottom(self)
	local area = {{self.entity.position.x,self.entity.position.y}, {self.entity.position.x, self.entity.position.y + 2}}
	if not self:search_area(area) then
		self.message = "No suitable assembler was found/occupied already"
	else
		self.state = self.ready
		self.message = "Awaiting orders.."
		self:state()
	end
end

--sets up recipe for the assembler 
function cyberchest.initialize_assembler(self)
	local recipe_name = self:getorder().name
	
	if self.assembler.recipe and self.assembler.recipe.name == self:getorder().name then --skip
		self.state = self.wait_for_ingredients
		self.message = "Waiting for ingredients.."
		self:state()
	end
	
	if not self.assembler.force.recipes[recipe_name] then
		--self.state = self.error
		self.message = "Recipe: ".. recipe_name .. " does not exist"
		return
	end
	
	if not self.assembler.force.recipes[recipe_name].enabled then
		--self.state = self.error
		self.message = "Recipe: ".. recipe_name .. " is not available"
		return
	end
	
	--clear out assembler
	local asm_out = self.assembler.getinventory(defines.inventory.assemblingmachineoutput)
	local asm_in = self.assembler.getinventory(defines.inventory.assemblingmachineinput)
	if not (self:assembler_clear_inventory(asm_out) and self:assembler_clear_inventory(asm_in)) then
		self.message = "Chest is full"	
		return
	end
	--set recipe
	self.assembler.recipe = self.assembler.force.recipes[recipe_name]  
	if not self.assembler.recipe then
		--self.state = self.error
		self.message = "Wrong type of the assembling machine"
		return
	end
	--self.assembler.operable = false
	self.state = self.wait_for_ingredients
	self.message = "Waiting for ingredients.."
	self:state()
end

--waits for ingredients for the current recipe
function cyberchest.wait_for_ingredients(self)
	local asm_out = self.assembler.getinventory(defines.inventory.assemblingmachineoutput)
	if not asm_out.isempty() then --already contains results
		self.state = self.wait_for_output
		self.message = "Waiting for results.."
		self:state()
	end
	--player altered recipe
	local reset = false
	if not self.assembler.recipe then
		reset = true
	elseif not self:getorder() then
		reset = true
	elseif self.assembler.recipe.name ~= self:getorder().name then
		reset = true
	end
	
	if reset then
		self.state = self.ready
		self.message = "Wrong recipe"
		return
	end
	
	
	local ing = ingredients_to_simplestack(self.assembler.recipe.name)
	local inv = self.entity.getinventory(defines.inventory.chest)
	local asm_in = self.assembler.getinventory(defines.inventory.assemblingmachineinput)
	
	local all_in_place = true
	for _,item_stack in pairs(ing) do
		if inv.getitemcount(item_stack.name) + asm_in.getitemcount(item_stack.name) < item_stack.count then
			all_in_place = false
		end
			--insert what we have already, up to the needed
		local asm_in_count = asm_in.getitemcount(item_stack.name)
		item_stack.count = math.min(inv.getitemcount(item_stack.name), item_stack.count - asm_in_count)
			
		if item_stack.count > 0 then
			if not stack_transfer(inv, item_stack, self.assembler) then
				self.message = "Unknown error while trying to insert ingredients"	
				return
			end
		end
	end
	
	if not all_in_place then
		if self.autoreset then --resets after 5 seconds
			self:autoreset_countdown()
		end
		return --not enough of something
	end
	self.autoreset_count = 30 --reset countdown
	
	--all in place
	--[[for _,item_stack in pairs(ing) do
	--insert only needed count
		if item_stack.count > 0 then
			if not stack_transfer(inv, item_stack, self.assembler) then
				self.message = "Unknown error while trying to insert ingredients"
				return
			end
		end
	end]]--
	
	self.state = self.wait_for_output
	self.message = "Waiting for results.."
	self:state()
end
--waits for the item to be made
function cyberchest.wait_for_output(self)
	local asm_out = self.assembler.getinventory(defines.inventory.assemblingmachineoutput)
	if asm_out.isempty() then
		return
	end
	
	if not self:assembler_clear_inventory(asm_out) then
		self.message = "Chest is full"	
		return
	end
	
	self.state = self.ready
	self.message = "Awaiting orders.."
	self:state()
end

--reclaims items from the specific assembler inventory
function cyberchest.assembler_clear_inventory(self, asm_inv)
	local item_map = asm_inv.getcontents()
	local inventory = self.entity.getinventory(defines.inventory.chest)
	
	for name,count in pairs(item_map) do
		if not stack_transfer(asm_inv, {name = name, count = count}, inventory) then
			return false
		end
	end
	return true
end

--reclaims items from all assembler inventories
function cyberchest.assembler_clear(self)
	local asm_out = self.assembler.getinventory(defines.inventory.assemblingmachineoutput)
	local asm_in = self.assembler.getinventory(defines.inventory.assemblingmachineinput)
	local asm_modules =  self.assembler.getinventory(defines.inventory.assemblingmachinemodules)
	
	local ok = true
	ok = self:assembler_clear_inventory(asm_out) and ok 
	ok = self:assembler_clear_inventory(asm_in) and ok 
	ok = self:assembler_clear_inventory(asm_modules) and ok 
	return ok
end

function cyberchest.next_order(self)
	self.current_order = self.current_order + 1
	if self.requester_slots < self.current_order then
		self.current_order = 1
	end
end

function cyberchest.order_done(self)
	local count = self.entity.getitemcount(self:getorder().name)
	if count >= self:getorder().count then
		return true
	else
		return false
	end
end


