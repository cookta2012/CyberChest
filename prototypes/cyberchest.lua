data:extend(
	{
		{
			type = "technology",
			name = "cyberchest",
			icon = "__CyberChest__/graphics/cyberchest.png",
			effects =
			{
			  {
				type = "unlock-recipe",
				recipe = "cyberchest"
			  },
			},
			prerequisites = {"advanced-electronics"},
			unit =
			{
			  count = 50,
			  ingredients =
			  {
				{"science-pack-1", 1},
				{"science-pack-2", 1}
			  },
			  time = 20
			},
			order = "a-d-b",
	    },
	  
		{
			type = "technology",
			name = "inventory-override",
			icon = "__CyberChest__/graphics/inventory-override.png",
			prerequisites = {"cyberchest"},
			unit =
			{
			  count = 50,
			  ingredients =
			  {
				{"science-pack-1", 1},
				{"science-pack-2", 1},
			  },
			  time = 30
			},
			order = "b-d-b",
	    },
	  
		{
			type = "technology",
			name = "cyberarms",
			icon = "__CyberChest__/graphics/cyberarms.png",
			prerequisites = {"cyberchest", "inventory-override"},
			unit =
			{
			  count = 60,
			  ingredients =
			  {
				{"science-pack-1", 1},
				{"science-pack-2", 1},
				{"science-pack-3", 1}
			  },
			  time = 30
			},
			order = "c-d-b",
	    },
	  
	  
		{
			type = "item",
			name = "cyberchest",
			icon = "__CyberChest__/graphics/cyberchest-icon.png",
			flags = {"goes-to-quickbar"},
			--group = "production",
			subgroup = "production-machine",
			order = "h[cyberchest]",
			place_result = "cyberchest",
			stack_size = 20,
		},
		{
			type = "recipe",
			name = "cyberchest",
			energy_required = 3.0,
			enabled = "false",
			ingredients = {{"iron-plate", 10}, {"smart-chest", 2}, {"smart-inserter", 2}}, 
			--group = "production",
			--subgroup = "production-machine",
			result = "cyberchest",		
			result_count = 1,
		},	
		{
			type = "logistic-container",
			name = "cyberchest",
			logistic_mode = "requester",
			icon = "__CyberChest__/graphics/cyberchest-icon.png",
			flags = {"placeable-neutral", "player-creation"},
			open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.65 },
			close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 },
			minable = {mining_time = 1, result = "cyberchest"},
			max_health = 350,
			corpse = "medium-remnants",
			resistances = {{type = "physical",percent = 20,},{type = "fire",percent = 50,}},
			collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
			selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
			--fast_replaceable_group = "container-medium",
			inventory_size = 60,
			picture =
			{
				filename = "__CyberChest__/graphics/cyberchest.png",
				priority = "high",
				width = 128,
				height = 100,
				shift = {0.35, 0.05},
			}
		},
	}
)