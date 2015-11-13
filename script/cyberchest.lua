require "defines"
require "recipe_finder"
--Remember to use game.surfaces['nauvis'] instead of game when dealing with position stuff like when doing a find_entities

--transforms recipe.ingredient format to simplestack format
function ingredients_to_simplestack(recipename)
	local ingredients = game.forces.player.recipes[recipename].ingredients
	local stack = {}
	for i, ingredient in pairs(ingredients) do
		if ingredient.type == "item" then
		--Little bit unsure about this: defines.recipe.material_type.item But i guess it has something to do if its a liquid or not so i set to 0 because only items can be stacked ;)!
			table.insert(stack, {name = ingredient.name, count = ingredient.amount})
		end
	end
	return stack
end

--safe stack transer, true on success, false on failure (stack remains untouched)
function stack_transfer(source_inv, stack, target_inv)
	local source_init_count = source_inv.get_item_count(stack.name)
	local target_init_count = target_inv.get_item_count(stack.name)
	--check if the inventories are valid for transfer
	if source_init_count < stack.count or not target_inv.can_insert(stack) then 
		return false 
	end
	target_inv.insert(stack)
	--check if all the items were transferred
	if target_inv.get_item_count(stack.name) < target_init_count + stack.count then
		if not target_inv.remove then
			target_inv.removeitem({name = stack.name, count = target_inv.get_item_count(stack.name) - target_init_count})
		else
			target_inv.remove({name = stack.name, count = target_inv.get_item_count(stack.name) - target_init_count})
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
cyberchest.tick_index = 0

cyberchest.entity = nil	
cyberchest.is_asm_free = nil
cyberchest.current_order = 1
cyberchest.working = false
cyberchest.autoreset = true
cyberchest.reserve_slots = true
cyberchest.collect_from_ground = true
cyberchest.ignore_errors = false
cyberchest.autoreset_calls_count = 30 
cyberchest.autoreset_count = cyberchest.autoreset_calls_count
cyberchest.bar_value = 0
cyberchest.stack_mult = 1

cyberchest.all_green = false
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

function cyberchest.on_tick(self)
	if not self.tick_index then
	self.tick_index = 10
	end
	if self.tick_index == 20 then
		self.tick_index = 1
		if self:is_valid() then
			self:state_execute()
			return true
		else	
			self:destroy_beacon()
			return false
		end
	else
		self.tick_index = self.tick_index + 1
		return true
	end
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
	
	if self.stack_mult < 2 then
		if self.assembler.force.technologies["burst_input_1"].researched then 
			self.stack_mult = 2
		end
	end
	
	if self.stack_mult < 3 then
		if self.assembler.force.technologies["burst_input_2"].researched then 
			self.stack_mult = 4
		end
	end
	
	if self.stack_mult < 8 then
		if self.assembler.force.technologies["burst_input_3"].researched then 
			self.stack_mult = 8
		end
	end
	
	if self.stack_mult < math.huge then
		if self.assembler.force.technologies["burst_input_4"].researched then 
			self.stack_mult = math.huge
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
		self.autoreset_count = cyberchest.autoreset_calls_count
		self.current_order = 1
		self.state = self.ready
		self.message = "Awaiting orders.."
	end
end

function cyberchest.clear_orders(self)
	self.orders = {}
	self.all_green = false
end

function cyberchest.get_recipes(self)
	self:clear_orders()
	local recipe
	local k = 1
	for i = 1, self.requester_slots do
		local item = self.entity.get_request_slot(i)
		if item then
			recipe = self:get_recipe_name_for(item.name)
			if not self.ignore_errors and not recipe then
				self:clear_orders()
				self.working = false
				self.state = self.ready
				return
			end
			--ignoring bad recipes
			if recipe then 
				self.orders[k] = {
					target_stack = item, 
					recipe_name = recipe,	
					result_amount = Result_Count(self.assembler.force.recipes[recipe], item.name), 
					stack_size = game.item_prototypes[item.name].stack_size,
					ingredients = ingredients_to_simplestack(recipe),
					ingredients_stack_sizes = {}
				}
				for	_,ing in pairs(self.orders[k].ingredients) do
					self.orders[k].ingredients_stack_sizes[ing.name] = game.item_prototypes[ing.name].stack_size
				end
				
				k = k + 1			
			end
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

function cyberchest.get_recipe_name_for(self, item_name)
	local exclude_list = {}
	local recipe_name = ""
	repeat
		recipe_name = Get_Recipe_For(item_name, exclude_list)
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
	
	--local order = table.deepcopy()
	return self.orders[self.current_order]
end

function cyberchest.getprogress(self)
	if not self.all_green then
		return 0
	end
	local count = self.entity.get_item_count(self:getorder().target_stack.name)
	local progress = count/self:getorder().target_stack.count
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
		self.beacon = self.entity.surface.create_entity{name = "cyber_beacon_400", position = self:get_beacon_placement(), force = self.entity.force}
	elseif self.speed_200_allowed then
		self.beacon = self.entity.surface.create_entity{name = "cyber_beacon_200", position = self:get_beacon_placement(), force = self.entity.force}
	elseif self.speed_100_allowed then
		self.beacon = self.entity.surface.create_entity{name = "cyber_beacon_100", position = self:get_beacon_placement(), force = self.entity.force}
	elseif self.speed_50_allowed then
		self.beacon = self.entity.surface.create_entity{name = "cyber_beacon_50", position = self:get_beacon_placement(), force = self.entity.force}
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
	self.asm_out = self.assembler.get_inventory(defines.inventory.assembling_machine_output)
	self.asm_in = self.assembler.get_inventory(defines.inventory.assembling_machine_input)
	self.inv = self.entity.get_inventory(defines.inventory.chest)
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
	local targets = self.entity.surface.find_entities_filtered({area = area,type = "assembling-machine"})
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
	local recipe_name = self:getorder().recipe_name
	
	if self.assembler.recipe and self.assembler.recipe.name == recipe_name then --skip
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
		self.message = "Wrong type of the assembling machine"
		self.state = self.ready
		return
	end
	--self.assembler.operable = false
	
	self.state = self.wait_for_ingredients
	self.message = "Waiting for ingredients.."
	self:state()
end

--counts items with particular name up to max_count 
function cyberchest.get_count_on_ground(self, item_name, max_count)
	if not self.ground_collection_allowed then return 0 end
	local area = {{self.entity.position.x - 5,self.entity.position.y - 5}, {self.entity.position.x + 5, self.entity.position.y + 5}}
	local items = self.surface.find_entities_filtered{area = area, name = "item-on-ground"}
	local count = 0
	for _,item in pairs(items) do
		if count >= max_count then --stop when enough
			return count
		end
		if item.stack.name == item_name then
			count = count + 1
		end	
	end
	return count
end
--removes items with particular name
function cyberchest.remove_from_ground(self, item_name, count)
	local area = {{self.entity.position.x - 5,self.entity.position.y - 5}, {self.entity.position.x + 5, self.entity.position.y + 5}}
	local items = self.surface.find_entities_filtered{area = area, name = "item-on-ground"}
	for _,item in pairs(items) do
		if count == 0 then
			return
		end
		if item.stack.name == item_name then
			item.destroy()
			count = count - 1
		end	
	end
end

--waits for ingredients for the current recipe
function cyberchest.wait_for_ingredients(self)

	if not self.asm_out.is_empty() then --already contains results
		self.state = self.wait_for_output
		self.message = "Waiting for results.."
		--self:state()
	end
	if self:count_left() == 0 then -- in case when something (say a robot) brings results from outside
		self.state = self.ready
		self.message = "Awaiting orders.."
		return
	end
	
	local asm_in_count, desirable_stack
	local transfer_stack = {}
	local inv_count, ground_count
	local all_in_place = true

	self:reset_bar()
	local order = self:getorder()
	for _,item_stack in pairs(order.ingredients) do
		asm_in_count = self.asm_in.get_item_count(item_stack.name)
		inv_count = self.inv.get_item_count(item_stack.name)
		if self.reserve_slots then
			inv_count = inv_count - 1 --reserve 1 item
		end
		--count should be no more than: stack size limit, required by tech stack size, required by left count stack size 
		desirable_stack = {name = item_stack.name, count = math.min(order.ingredients_stack_sizes[item_stack.name], self.stack_mult*item_stack.count, math.ceil(self:count_left()/order.result_amount)*item_stack.count)}
						--- comment: math.ceil(self:count_left()/self:result_count()) - can produce at least one result
		       
		if asm_in_count < desirable_stack.count then
		
			if inv_count + asm_in_count < desirable_stack.count and self.collect_from_ground then -- try to grab from ground
				ground_count = self:get_count_on_ground(item_stack.name, desirable_stack.count - inv_count)
				
				if ground_count > 0 and self.inv.can_insert({name = item_stack.name, count = ground_count}) then --grab from ground
					self.inv.insert({name = item_stack.name, count = ground_count})
					inv_count = inv_count + ground_count
					self:remove_from_ground(item_stack.name, ground_count)
				end
			end
			
			if inv_count + asm_in_count < item_stack.count then --minimal requirements still aren't met
				all_in_place = false
				break
			end
			transfer_stack.name = item_stack.name;
			transfer_stack.count = math.min(desirable_stack.count - asm_in_count, inv_count)
			
			if transfer_stack.count > 0 then
				stack_transfer(self.inv, transfer_stack, self.assembler)
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
	self.autoreset_count = cyberchest.autoreset_calls_count --reset countdown
	
	self.predicted_result_count = math.huge
	local max_results
	for _,ing in pairs(order.ingredients) do
		max_results = math.floor(self.asm_in.get_item_count(ing.name)/ing.count)
		if max_results < self.predicted_result_count then
			self.predicted_result_count = max_results*order.result_amount --predict number of produced items
		end
	end

	self.state = self.wait_for_output
	self.message = "Waiting for results.."
	self:state()
end

function cyberchest.reset_bar(self)
	if not self.bar_bypass_allowed then return end
	local inventory = self.entity.get_inventory(defines.inventory.chest)
	self.bar_value = inventory.getbar()
	inventory.setbar()
end

function cyberchest.restore_bar(self)
	if not self.bar_bypass_allowed then return end
	local inventory = self.entity.get_inventory(defines.inventory.chest)
	inventory.setbar(self.bar_value)
end

--waits for the item to be made
function cyberchest.wait_for_output(self)
	local result_count = self.asm_out.get_item_count(self:getorder().target_stack.name)
	if self.asm_out.is_empty() or math.min(self.predicted_result_count, self:getorder().stack_size)  
	> result_count then --not enough results yet
		return --min - in case stack size is less then predicted amount
	end
	
	if not self:assembler_clear_inventory(self.asm_out) then
		self.message = "Chest is full"	
		return
	end
		
	self.predicted_result_count = self.predicted_result_count - result_count
	if self.predicted_result_count > 0 then --didn't collect all of the items
		return --stay in this state
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
	local item_map = asm_inv.get_contents()
	
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

function cyberchest.count_left(self) --count to complete an order
	local count = self.entity.get_item_count(self:getorder().target_stack.name)
	if count < self:getorder().target_stack.count then
		return self:getorder().target_stack.count - count
	else
		return 0
	end
end

function cyberchest.order_done(self)
	local count = self.entity.get_item_count(self:getorder().target_stack.name)
	if count >= self:getorder().target_stack.count then
		return true
	else
		return false
	end
end




