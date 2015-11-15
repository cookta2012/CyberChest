require "defines"
require "cyberchest"
function new_gui()
	local gui = {}
	gui.opened_chests = {}
	gui.dispatch_map = {}
	
	function gui.dispatch(player_index, element_name)
		local handler = gui.dispatch_map[element_name]
		--game.players[player_index].print(element_name)
		if handler then		
			local cyberchest = gui.opened_chests[player_index]
			handler(cyberchest)
		end
	end
	
	function gui.show(player_index, cyberchest)
		local player_gui = game.players[player_index].gui.top
		if player_gui.cyberchest_main then 
			gui.update(player_index, cyberchest)
			return
		end
	
		gui.opened_chests[player_index] = cyberchest
		player_gui.add({ type="frame", name="cyberchest_main", direction="horizontal", style = "machine_frame_style"})
		player_gui.cyberchest_main.add({ type="frame", name="button_f", direction="vertical", style = "inner_frame_style"})
		player_gui.cyberchest_main.add({ type="frame", name="info_f", direction="vertical", style = "inner_frame_style"})

		
		player_gui.cyberchest_main.button_f.add({ type="button", name="start_pause_b".. player_index, caption="Start/Pause"})
			gui.dispatch_map["start_pause_b".. player_index] = cyberchest.on_start_pause
		player_gui.cyberchest_main.button_f.add({ type="button", name="reset_b".. player_index, caption="Reset"})
			gui.dispatch_map["reset_b" .. player_index] = cyberchest.on_reset
		player_gui.cyberchest_main.button_f.add({ type="label", name="switch_capt", caption="Switch assembler:"})
		player_gui.cyberchest_main.button_f.add({ type="frame", name="switch_f", direction="horizontal",style = "inner_frame_style"})
		player_gui.cyberchest_main.button_f.switch_f.add({ type="button", name="switch_top".. player_index, caption="^"})
			gui.dispatch_map["switch_top" .. player_index] = cyberchest.on_search_top
		player_gui.cyberchest_main.button_f.switch_f.add({ type="button", name="switch_left".. player_index, caption="<"})
			gui.dispatch_map["switch_left" .. player_index] = cyberchest.on_search_left
		player_gui.cyberchest_main.button_f.switch_f.add({ type="button", name="switch_right".. player_index, caption=">"})
			gui.dispatch_map["switch_rigth" .. player_index] = cyberchest.on_search_right
		player_gui.cyberchest_main.button_f.switch_f.add({ type="button", name="switch_bottom".. player_index, caption="v"})
			gui.dispatch_map["switch_bottom" .. player_index] = cyberchest.on_search_bottom
		
		player_gui.cyberchest_main.button_f.add({ type="checkbox", name="reserve_ch", caption="Reserve slots", state = cyberchest.reserve_slots})
		if game.players[player_index].force.technologies["cyberarms"].researched then
			player_gui.cyberchest_main.button_f.add({ type="checkbox", name="collect_ch", caption="Ground collection", state = cyberchest.collect_from_ground})
		end	
		player_gui.cyberchest_main.button_f.add({ type="checkbox", name="ignore_ch", caption="Ignore errors", state = cyberchest.ignore_errors})
		
		player_gui.cyberchest_main.info_f.add({ type="label", name="status_l", caption="Status: "..cyberchest.message})
		--recipe name
		local recipe_loc_name
		if cyberchest:getorder() then
			recipe_loc_name = game.item_prototypes[cyberchest:getorder().target_stack.name].localised_name
		end
		if recipe_loc_name then
			player_gui.cyberchest_main.info_f.add({ type="label", name="current_recipe_l", caption={"", "Recipe: ", recipe_loc_name}})
		else
			player_gui.cyberchest_main.info_f.add({ type="label", name="current_recipe_l", caption="Recipe: None"})
		end
		--progress
		player_gui.cyberchest_main.info_f.add({ type="progressbar", name="progress_bar", size=100, value = cyberchest:getprogress()})
	end
	
	function gui.update(player_index, cyberchest)
		local player_gui = game.players[player_index].gui.top
		
		player_gui.cyberchest_main.info_f.status_l.caption = "Status: "..cyberchest.message
		local recipe_loc_name
		if cyberchest:getorder() then
			recipe_loc_name = game.item_prototypes[cyberchest:getorder().target_stack.name].localised_name
		end
		if recipe_loc_name then
			player_gui.cyberchest_main.info_f.current_recipe_l.caption = {"", "Recipe: ", recipe_loc_name}
		else
			player_gui.cyberchest_main.info_f.current_recipe_l.caption = "Recipe: None"
		end
		player_gui.cyberchest_main.info_f.progress_bar.value = cyberchest:getprogress()	
		cyberchest.reserve_slots = player_gui.cyberchest_main.button_f.reserve_ch.state
		cyberchest.ignore_errors = player_gui.cyberchest_main.button_f.ignore_ch.state
		if player_gui.cyberchest_main.button_f.collect_ch then
			cyberchest.collect_from_ground = player_gui.cyberchest_main.button_f.collect_ch.state
		end
	end
	
	function gui.hide(player_index)
		local player_gui = game.players[player_index].gui.top
		if not player_gui.cyberchest_main then 
			return  
		end
		
		gui.opened_chests[player_index] = nil
		player_gui.cyberchest_main.destroy()
	--[[	gui.dispatch_map["start_pause_b".. player_index] = nil
		gui.dispatch_map["reset_b" .. player_index] = nil	
		gui.dispatch_map["switch_top" .. player_index] = nil
		gui.dispatch_map["switch_left" .. player_index] = nil
		gui.dispatch_map["switch_rigth" .. player_index] = nil
		gui.dispatch_map["switch_bottom" .. player_index] = nil--]]
	end
	
	return gui
end

