--luacheck: no max line length
--luacheck: ignore game

-- require "cyberchest"
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
        local player = game.players[player_index];
        local player_gui = player.gui.center

        if gui.opened_chests[player_index] then
            game.player.surface.print("If this happens report to the mod maintainer! Which it shouldn't")
            return
        end;


--[[
        if middleFrame then
            gui.update(player_index, cyberchest)
            return
        end
]]
        gui.opened_chests[player_index] = cyberchest

        player.opened=player_gui.add{
            type="flow",
            name="cyberchest_main",
            direction="horizontal"
        }
        player.opened.style.horizontal_spacing=0;
        local leftFrame = player.opened.add{
            type="frame",
            name="leftFrame",
            caption="Character",
            style="inner_frame_in_outer_frame"}
        local middleFrame = player.opened.add{
            type="frame",
            name="middleFrame",
            caption="Crafting",
            style="inner_frame_in_outer_frame"}
        local rightFrame = player.opened.add{
            type="frame",
            name="rightFrame",
            caption="Cyberchest",
            style="inner_frame_in_outer_frame"}


        middleFrame.add({
			type="frame", name="button_f",
			direction="vertical",
			style = "inner_frame"
		})
        middleFrame.add({
			type="frame", name="info_f",
			direction="vertical",
			style = "inner_frame"
		})


        middleFrame.button_f.add({
            type="button",
            name="start_pause_b".. player_index,
            caption="Start/Pause"
        })
        gui.dispatch_map["start_pause_b".. player_index] = cyberchest.on_start_pause
        middleFrame.button_f.add({
			type="button",
			name="reset_b".. player_index,
			caption="Reset"
		})
        gui.dispatch_map["reset_b" .. player_index] = cyberchest.on_reset
        middleFrame.button_f.add({
			type="label",
			name="switch_capt",
			caption="Switch assembler:"
        })
        
        --[[
        middleFrame.button_f.add({
			type="frame",
			name="switch_f",
			direction="horizontal",
			style = "inner_frame"
        })
        ]]

        middleFrame.button_f.add({
			type="table",
			name="switch_f",
			column_count= 3,
			style = "slot_table"
        })
        middleFrame.button_f.switch_f.style.horizontal_spacing = 0;
        middleFrame.button_f.switch_f.style.vertical_spacing = 0;

        local button_size = 32

        -- Above is a change
        local spacer_count = 1

        -- Add spacer button
        middleFrame.button_f.switch_f.add({ type="button", name="spacer_button_" .. spacer_count })
		middleFrame.button_f.switch_f["spacer_button_" .. spacer_count].style.width=button_size
        middleFrame.button_f.switch_f["spacer_button_" .. spacer_count].style.height=button_size
        middleFrame.button_f.switch_f["spacer_button_" .. spacer_count].enabled = false
        spacer_count = spacer_count + 1;

        middleFrame.button_f.switch_f.add({
			type="button",
			name="switch_top".. player_index,
			caption="^"
		})
		middleFrame.button_f.switch_f["switch_top" .. player_index].style.width=button_size
		middleFrame.button_f.switch_f["switch_top" .. player_index].style.height=button_size
        gui.dispatch_map["switch_top" .. player_index] = cyberchest.on_search_top

        -- Add spacer button
        middleFrame.button_f.switch_f.add({ type="button", name="spacer_button_" .. spacer_count })
		middleFrame.button_f.switch_f["spacer_button_" .. spacer_count].style.width=button_size
        middleFrame.button_f.switch_f["spacer_button_" .. spacer_count].style.height=button_size
        middleFrame.button_f.switch_f["spacer_button_" .. spacer_count].enabled = false
        spacer_count = spacer_count + 1;

        middleFrame.button_f.switch_f.add({
			type="button",
			name="switch_left".. player_index,
			caption="<"
		})
		middleFrame.button_f.switch_f["switch_left" .. player_index].style.width=button_size
		middleFrame.button_f.switch_f["switch_left" .. player_index].style.height=button_size
        gui.dispatch_map["switch_left" .. player_index] = cyberchest.on_search_left

        -- Add spacer button
        middleFrame.button_f.switch_f.add({ type="button", name="spacer_button_" .. spacer_count })
		middleFrame.button_f.switch_f["spacer_button_" .. spacer_count].style.width=button_size
        middleFrame.button_f.switch_f["spacer_button_" .. spacer_count].style.height=button_size
        middleFrame.button_f.switch_f["spacer_button_" .. spacer_count].enabled = false
        spacer_count = spacer_count + 1;
        
        middleFrame.button_f.switch_f.add({
			type="button",
			name="switch_right".. player_index,
			caption=">"
		})
		middleFrame.button_f.switch_f["switch_right" .. player_index].style.width=button_size
		middleFrame.button_f.switch_f["switch_right" .. player_index].style.height=button_size
        gui.dispatch_map["switch_right" .. player_index] = cyberchest.on_search_right

        -- Add spacer button
        middleFrame.button_f.switch_f.add({ type="button", name="spacer_button_" .. spacer_count })
		middleFrame.button_f.switch_f["spacer_button_" .. spacer_count].style.width=button_size
        middleFrame.button_f.switch_f["spacer_button_" .. spacer_count].style.height=button_size
        middleFrame.button_f.switch_f["spacer_button_" .. spacer_count].enabled = false
        spacer_count = spacer_count + 1;

        middleFrame.button_f.switch_f.add({
			type="button",
			name="switch_bottom".. player_index,
			caption="v"
		})
		middleFrame.button_f.switch_f["switch_bottom" .. player_index].style.width=button_size
		middleFrame.button_f.switch_f["switch_bottom" .. player_index].style.height=button_size
        gui.dispatch_map["switch_bottom" .. player_index] = cyberchest.on_search_bottom

        -- Add spacer button
        middleFrame.button_f.switch_f.add({ type="button", name="spacer_button_" .. spacer_count })
		middleFrame.button_f.switch_f["spacer_button_" .. spacer_count].style.width=button_size
        middleFrame.button_f.switch_f["spacer_button_" .. spacer_count].style.height=button_size
        middleFrame.button_f.switch_f["spacer_button_" .. spacer_count].enabled = false
        spacer_count = spacer_count + 1;

        middleFrame.button_f.add({ type="checkbox", name="reserve_ch", caption="Reserve slots", state = cyberchest.reserve_slots})
        if game.players[player_index].force.technologies["cyberarms"].researched then
            middleFrame.button_f.add({ type="checkbox", name="collect_ch", caption="Ground collection", state = cyberchest.collect_from_ground})
        end
		middleFrame.button_f.add({ type="checkbox", name="ignore_ch", caption="Ignore errors", state = cyberchest.ignore_errors})

        middleFrame.info_f.add({ type="label", name="status_l", caption="Status: "..cyberchest.message})
        --recipe name
        local recipe_loc_name
        if cyberchest:getorder() then
            recipe_loc_name = game.item_prototypes[cyberchest:getorder().target_stack.name].localised_name
        end
        if recipe_loc_name then
            middleFrame.info_f.add({ type="label", name="current_recipe_l", caption={"", "Recipe: ", recipe_loc_name}})
        else
            middleFrame.info_f.add({ type="label", name="current_recipe_l", caption="Recipe: None"})
        end
        --progress
        middleFrame.info_f.add({ type="progressbar", name="progress_bar", size=100, value = cyberchest:getprogress()})
    end

    function gui.update(player_index, cyberchest)
        local player_gui = game.players[player_index].gui.top

        middleFrame.info_f.status_l.caption = "Status: "..cyberchest.message
        local recipe_loc_name
        if cyberchest:getorder() then
            recipe_loc_name = game.item_prototypes[cyberchest:getorder().target_stack.name].localised_name
        end
        if recipe_loc_name then
            middleFrame.info_f.current_recipe_l.caption = {"", "Recipe: ", recipe_loc_name}
        else
            middleFrame.info_f.current_recipe_l.caption = "Recipe: None"
        end
        middleFrame.info_f.progress_bar.value = cyberchest:getprogress()
        cyberchest.reserve_slots = middleFrame.button_f.reserve_ch.state
        cyberchest.ignore_errors = middleFrame.button_f.ignore_ch.state
        if middleFrame.button_f.collect_ch then
            cyberchest.collect_from_ground = middleFrame.button_f.collect_ch.state
        end
    end

    function gui.hide(player_index)
        local player_gui = game.players[player_index].gui.center
        if not player_gui.cyberchest_main then
            return
        end
        gui.opened_chests[player_index] = nil
        player_gui.cyberchest_main.destroy()
    end

    return gui
end
