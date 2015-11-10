function FoundInProducts(recipe, item_name)
	for j, result in pairs(recipe.products) do
		if result.name == item_name then
			return true
		end
	end
	return false
end

function Result_Count(recipe, item_name)
	for j, result in pairs(recipe.products) do
		if result.name == item_name then
			return result.amount 
		end
	end
	return 0
end

function InExcluded(recipe_name, excluded_list)
	for	_,name in pairs(excluded_list) do
		if name == recipe_name then
			return true
		end
	end
	return false
end

function Get_Recipe_For(item_name, excluded_list)
	if not game.forces.player.recipes[item_name] or InExcluded(item_name, excluded_list) then
		for i, rec in pairs(game.forces.player.recipes) do
			if not InExcluded(rec.name, excluded_list) and FoundInProducts(rec, item_name) then
				return rec.name
			end
		end
		return nil
	else	
		return game.forces.player.recipes[item_name].name
	end
end