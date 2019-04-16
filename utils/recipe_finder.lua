--luacheck: no max line length
--luacheck: ignore global
--luacheck: ignore game

local finder = {};

function finder.positive(number)
	if number > 0 then
		return number
	else
		return 0
	end
end

--transforms recipe.ingredient format to simplestack format
function finder.ingredients_to_simplestack(recipename)
	local ingredients = game.forces.player.recipes[recipename].ingredients
	local stack = {}
	for i, ingredient in pairs(ingredients) do --luacheck: ignore i
		if ingredient.type == "item" then
		--Little bit unsure about this: defines.recipe.material_type.item But i guess it has something to do if its a liquid or not so i set to 0 because only items can be stacked ;)!
			table.insert(stack, {name = ingredient.name, count = ingredient.amount})
		end
	end
	return stack
end

--safe stack transer, true on success, false on failure (stack remains untouched)
function finder.stack_transfer(source_inv, stack, target_inv)
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

function finder.FoundInProducts(recipe, item_name)
	for _, result in pairs(recipe.products) do
		if result.name == item_name then
			return true
		end
	end
	return false
end

function finder.Result_Count(recipe, item_name)
	for _, result in pairs(recipe.products) do
		if result.name == item_name then
			return result.amount
		end
	end
	return 0
end

function finder.InExcluded(recipe_name, excluded_list)
	for	_,name in pairs(excluded_list) do
		if name == recipe_name then
			return true
		end
	end
	return false
end

function finder.Get_Recipe_For(item_name, excluded_list)
	if not game.forces.player.recipes[item_name] or finder.InExcluded(item_name, excluded_list) then
		for _, rec in pairs(game.forces.player.recipes) do
			if not finder.InExcluded(rec.name, excluded_list) and finder.FoundInProducts(rec, item_name) then
				return rec.name
			end
		end
		return nil
	else
		return game.forces.player.recipes[item_name].name
	end
end