require "defines"
require "recipe_finder"
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

asm_sides = {left = 1, right = 2, top = 3, bottom = 4}

cyberchest = {}
cyberchest.__index = cyberchest
cyberchest.requester_slots = 10
cyberchest.assembler = nil

cyberchest.entity = nil	
cyberchest.is_asm_free = nil
cyberchest.current_order = 1
cyberchest.working = false
cyberchest.autoreset = true
cyberchest.reserve_slots = true
cyberchest.collect_from_ground = true
cyberchest.autoreset_count = 30
cyberchest.bar_value = 0

cyberchest.all_green = false
cyberchest.recipes = {}
cyberchest.orders = {}

cyberchest.asm_in = nil
cyberchest.asm_out = nil
cyberchest.inv = nil
cyberchest.ing = nil

cyberchest.bar_bypass_allowed = false
cyberchest.ground_collection_allowed = false
cyberchest.speed_50_allowed = false
cyberchest.speed_100_allowed = false
cyberchest.speed_200_allowed = false
cyberchest.speed_400_allowed = false
cyberchest.beacon = nil
cyberchest.asm_side = nil

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
	if not self:has_assembler() or not self.asm_in then 
		self.state = self.find_assembler 
		self:destroy_beacon()
		self.message = "Looking for an assembling machine.."
	end
	--game.players[1].print(self.message)
	
	self:state() --run state function
end

function cyberchest.check_tech(self)
	if not self.bar_bypass_allowed then
		if self.assembler.force.technologies["inventory-override"].researched then 
			self.bar_bypass_allowed = true
		end
	end
	
	if not self.ground_collection_allowed then
		if self.assembler.force.technologies["cyberarms"].researched then 
			self.ground_collection_allowed = true
		end
	end
	
	if not self.speed_50_allowed then
		if self.assembler.force.technologies["cyberfusion_1"].researched then 
			self.speed_50_allowed = true
			self.state = self.find_assembler
			self:state()
		end
	end
	
	if not self.speed_100_allowed then
		if self.assembler.force.technologies["cyberfusion_2"].researched then 
			self.speed_100_allowed = true
			self.state = self.find_assembler
			self:state()
		end
	end
	
	if not self.speed_200_allowed then
		if self.assembler.force.technologies["cyberfusion_3"].researched then 
			self.speed_200_allowed = true
			self.state = self.find_assembler
			self:state()
		end
	end

	if not self.speed_400_allowed then
		if self.assembler.force.technologies["cyberfusion_4"].researched then 
			self.speed_400_allowed = true
			self.state = self.find_assembler
			self:state()
		end
	end
	
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
	self.all_green = false
	self.state = self.ready
	self.message = "Awaiting orders.."
end

function cyberchest.autoreset_countdown(self)
	self.autoreset_count = self.autoreset_count - 1
	if self.autoreset_count < 0 then
		self.autoreset_count = 30
		self.current_order = 1
		self.state = self.ready
		self.message = "Awaiting orders.."
	end
end

function cyberchest.clear_orders(self)
	self.orders = {}
	self.recipes = {}
end

function cyberchest.get_recipes(self)
	self:clear_orders()
	k = 1
	for i = 1, self.requester_slots do
		local item = self.entity.getrequestslot(i)
		if item then
			self.orders[k] = item
			self.recipes[k] = self:get_recipe_for(item.name) 
			if not self.recipes[k]  then
				self:clear_orders()
				self.working = false
				self.state = self.ready
				return
			end		
			k = k + 1
		end	
	end
	if #self.orders == 0 then
		self:clear_orders()
		self.working = false
		self.state = self.ready
		return
	end
	self.all_green = true
	self.current_order = 1
end

function cyberchest.get_recipe_for(self, item_name)
	local exclude_list = {}
	local recipe_name = ""
	repeat
		recipe_name = GetRecipeFor(item_name, exclude_list)
		if recipe_name and self:recipe_is_good(recipe_name) then
			return recipe_name
		end
		table.insert(exclude_list, recipe_name) --exclude bad recipe from search
	until recipe_name == nil
	return nil
end

function cyberchest.recipe_is_good(self, recipe_name)
	if not self.assembler.force.recipes[recipe_name] then
		self.message = "Recipe: ".. recipe_name .. " does not exist"
		return false
	end

	if not self.assembler.force.recipes[recipe_name].enabled then
		self.message = "Recipe: ".. recipe_name .. " is not available"
		return false
	end
	--try set recipe
	self.assembler.recipe = self.assembler.force.recipes[recipe_name]  
	if not self.assembler.recipe then
		self.message = "Recipe:" .. recipe_name.. ". Wrong type of the assembling machine"
		return false
	end
	return true
end

function cyberchest.getorder(self)
	if not self.all_green then
		return nil
	end
	
	local stack = {name = self.orders[self.current_order].name, count = self.orders[self.current_order].count}
	if self.reserve_slots then
		stack.count = stack.count + 1 --produce 1 extra
	end
	return stack
end

function cyberchest.getrecipe(self)
	if not self.all_green then
		return nil
	end
	return self.recipes[self.current_order]
end


function cyberchest.getprogress(self)
	if not self.all_green then
		return 0
	end
	local count = self.entity.getitemcount(self:getorder().name)
	local progress = count/self:getorder().count
	return progress
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
		if not self.all_green then
			self:get_recipes()
			return
		end
		if self:order_done() then	--next order
			self:next_order()
			return
		end
		self:check_tech()
		
		self.state = self.initialize_assembler	
		self:state()
	end
end

--unused
function cyberchest.destroy_beacon(self)
	if self.beacon and self.beacon.valid then
		self.beacon.destroy()
	end
end

function cyberchest.create_beacon(self)
	self:destroy_beacon()
	if self.speed_400_allowed then
		self.beacon = game.createentity{name = "cyber_beacon_400", position = self:get_beacon_placement(), force = self.entity.force}
	elseif self.speed_200_allowed then
		self.beacon = game.createentity{name = "cyber_beacon_200", position = self:get_beacon_placement(), force = self.entity.force}
	elseif self.speed_100_allowed then
		self.beacon = game.createentity{name = "cyber_beacon_100", position = self:get_beacon_placement(), force = self.entity.force}
	elseif self.speed_50_allowed then
		self.beacon = game.createentity{name = "cyber_beacon_50", position = self:get_beacon_placement(), force = self.entity.force}
	end
	
	if self.beacon and self.beacon.valid then
		self.beacon.insert({name = "cyber_speed_module", count = 1}) --insert module
		self.beacon.operable = false
	end
end

function cyberchest.get_beacon_placement(self)
	if self.asm_side == asm_sides.top then
		return {self.entity.position.x, self.entity.position.y - 1}
	elseif self.asm_side == asm_sides.bottom then
		return {self.entity.position.x, self.entity.position.y + 1}
	elseif self.asm_side == asm_sides.left then
		return {self.entity.position.x - 1, self.entity.position.y}
	elseif self.asm_side == asm_sides.right then
		return {self.entity.position.x + 1, self.entity.position.y}
	end
end

function cyberchest.assembler_assign(self, asm)
	self.assembler = asm
	self.asm_out = self.assembler.getinventory(defines.inventory.assemblingmachineoutput)
	self.asm_in = self.assembler.getinventory(defines.inventory.assemblingmachineinput)
	self.inv = self.entity.getinventory(defines.inventory.chest)
	self:create_beacon()
end

--finds unoccupied assembler (see control.lua/is_assembler_free), clockwise from top
function cyberchest.find_assembler(self)
	--[[local top = {{self.entity.position.x,self.entity.position.y - 2}, {self.entity.position.x, self.entity.position.y}}
	local right = {{self.entity.position.x,self.entity.position.y}, {self.entity.position.x + 2, self.entity.position.y}}
	local left = {{self.entity.position.x - 2,self.entity.position.y}, {self.entity.position.x, self.entity.position.y}}
	local bottom = {{self.entity.position.x,self.entity.position.y}, {self.entity.position.x, self.entity.position.y + 2}}
	
	self.assembler = nil
	
	if not self:has_assembler() then self:search_area(top) end
	if not self:has_assembler() then self:search_area(right) end
	if not self:has_assembler() then self:search_area(left) end
	if not self:has_assembler() then self:search_area(bottom) end--]]

	self.assembler = nil
	
	if not self:has_assembler() then self:on_search_top() end
	if not self:has_assembler() then self:on_search_right() end
	if not self:has_assembler() then self:on_search_bottom() end
	if not self:has_assembler() then self:on_search_left() end
end

function cyberchest.search_area(self, area)
	local targets = game.findentitiesfiltered({area = area,type = "assembling-machine"})
	for _,asm in pairs(targets) do
		if self.is_asm_free(asm) then
			self:assembler_assign(asm)
			return true
		end
	end	
	return false
end

function cyberchest.on_search_top(self)
	local area = {{self.entity.position.x,self.entity.position.y - 2}, {self.entity.position.x, self.entity.position.y}}
	self.asm_side = asm_sides.top
	if self:search_area(area) then
		self:set_state_ready();
		self:state()
	end
end

function cyberchest.on_search_right(self)
	local area = {{self.entity.position.x,self.entity.position.y}, {self.entity.position.x + 2, self.entity.position.y}}
	self.asm_side = asm_sides.right
	if self:search_area(area) then
		self:set_state_ready()
		self:state()
	end
end

function cyberchest.on_search_left(self)
	local area = {{self.entity.position.x - 2,self.entity.position.y}, {self.entity.position.x, self.entity.position.y}}
	self.asm_side = asm_sides.left
	if self:search_area(area) then
		self:set_state_ready()
		self:state()
	end
end

function cyberchest.on_search_bottom(self)
	local area = {{self.entity.position.x,self.entity.position.y}, {self.entity.position.x, self.entity.position.y + 2}}
	self.asm_side = asm_sides.bottom
	if self:search_area(area) then
		self:set_state_ready()
		self:state()
	end
end

function cyberchest.set_state_ready(self)
		self.state = self.ready
		self.message = "Awaiting orders.."
end

--sets up recipe for the assembler 
function cyberchest.initialize_assembler(self)
	local recipe_name = self:getrecipe()
	
	if self.assembler.recipe and self.assembler.recipe.name == self:getrecipe() and self.ing then --skip
		self.state = self.wait_for_ingredients
		self.message = "Waiting for ingredients.."
		self:state()
	end
	
	--clear out assembler
	if not (self:assembler_clear_inventory(self.asm_out) and self:assembler_clear_inventory(self.asm_in)) then
		self.message = "Chest is full"	
		self.state = self.ready
		return
	end
	--set recipe
	self.assembler.recipe = self.assembler.force.recipes[recipe_name]  
	if not self.assembler.recipe then
		--self.state = self.error
		self.message = "Wrong type of the assembling machine"
		self.state = self.ready
		return
	end
	--self.assembler.operable = false
	self.ing = ingredients_to_simplestack(self.assembler.recipe.name)
	
	self.state = self.wait_for_ingredients
	self.message = "Waiting for ingredients.."
	self:state()
end

function cyberchest.collected_from_ground(self, stack)
	if not self.ground_collection_allowed then return false end

	local area = {{self.entity.position.x - 5,self.entity.position.y - 5}, {self.entity.position.x + 5, self.entity.position.y + 5}}
	local items = game.findentitiesfiltered{area = area, name = "item-on-ground"}
	--search
	local count = 0
	local enough = false
	for _,item in pairs(items) do
		if item.stack.name == stack.name then
			count = count + 1
			if count >= stack.count then
				enough = true
				break
			end
		end	
	end
	
	if not enough then return false end
	--remove
	count = 0
	for _,item in pairs(items) do
		if item.stack.name == stack.name then
			item.destroy()
			count = count + 1
			if count >= stack.count then
				break
			end
		end	
	end
	
	return true
end
--waits for ingredients for the current recipe
function cyberchest.wait_for_ingredients(self)

	if not self.asm_out.isempty() then --already contains results
		self.state = self.wait_for_output
		self.message = "Waiting for results.."
		--self:state()
	end

	local asm_in_count, needed_stack = {}
	local inv_count
	local all_in_place = true

	self:reset_bar()
	for _,item_stack in pairs(self.ing) do
		asm_in_count = self.asm_in.getitemcount(item_stack.name)
		inv_count = self.inv.getitemcount(item_stack.name)
		if self.reserve_slots then
			inv_count = inv_count - 1 --reserve 1 item
		end
	
		if inv_count + asm_in_count < item_stack.count then	
			needed_stack = {name = item_stack.name, count = item_stack.count - asm_in_count - inv_count} --only needed counter
			if self.collect_from_ground and self.inv.caninsert(needed_stack) then --option, tech, space
				if self:collected_from_ground(needed_stack) then
					self.inv.insert(needed_stack)
					inv_count = inv_count + needed_stack.count
				else
					all_in_place = false
					break
				end
			else
				all_in_place = false
				break
			end
		end
	end
	self:restore_bar()
	
	if not all_in_place then
		if self.autoreset then --resets after 5 seconds
			self:autoreset_countdown()
		end
		return --not enough of something
	end
	self.autoreset_count = 30 --reset countdown
	
	--all in place
	for _,item_stack in pairs(self.ing) do
	--insert only needed count
		if item_stack.count > 0 then
			if not stack_transfer(self.inv, item_stack, self.assembler) then
				self.message = "Unknown error while trying to insert ingredients"
				return
			end
		end
	end
	
	self.state = self.wait_for_output
	self.message = "Waiting for results.."
	self:state()
end

function cyberchest.reset_bar(self)
	if not self.bar_bypass_allowed then return end
	local inventory = self.entity.getinventory(defines.inventory.chest)
	self.bar_value = inventory.getbar()
	inventory.setbar()
end

function cyberchest.restore_bar(self)
	if not self.bar_bypass_allowed then return end
	local inventory = self.entity.getinventory(defines.inventory.chest)
	inventory.setbar(self.bar_value)
end

--waits for the item to be made
function cyberchest.wait_for_output(self)
	if self.asm_out.isempty() then
		return
	end
	
	if not self:assembler_clear_inventory(self.asm_out) then
		self.message = "Chest is full"	
		return
	end
	
	if self:order_done() then
		self.state = self.ready
		self.message = "Awaiting orders.."
		self:state()
	else
		self.state = self.wait_for_ingredients
		self.message = "Waiting for ingredients.."
		self:state()
	end
end

--reclaims items from the specific assembler inventory
function cyberchest.assembler_clear_inventory(self, asm_inv)
	local item_map = asm_inv.getcontents()
	
	self:reset_bar()
	for name,count in pairs(item_map) do
		if not stack_transfer(asm_inv, {name = name, count = count}, self.inv) then
			self:restore_bar()
			return false
		end
	end
	self:restore_bar()
	return true
end

--reclaims items from all assembler inventories
function cyberchest.assembler_clear(self)
	
	local ok = true
	ok = self:assembler_clear_inventory(self.asm_out) and ok 
	ok = self:assembler_clear_inventory(self.asm_in) and ok 
	ok = self:assembler_clear_inventory(self.asm_modules) and ok 
	return ok
end

function cyberchest.next_order(self)
	self.current_order = self.current_order + 1
	if #self.orders < self.current_order then
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


