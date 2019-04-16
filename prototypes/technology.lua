data:extend(
	{
		{
			type = "technology",
			name = "cyberchest",
			icon = "__CyberChest__/graphics/cyberchest-tech.png",
			icon_size = 128,
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
					{"automation-science-pack", 1},
					{"logistic-science-pack", 1}
			  },
			  time = 20
			},
			order = "a-d-b",
	  },
		{
			type = "technology",
			name = "inventory-override",
			icon = "__CyberChest__/graphics/inventory-override.png",
			icon_size = 64,
			prerequisites = {"cyberchest"},
			unit =
			{
			  count = 50,
			  ingredients =
			  {
					{"automation-science-pack", 1},
					{"logistic-science-pack", 1}
			  },
			  time = 30
			},
			order = "a-d-c",
	  },
		{
			type = "technology",
			name = "cyberarms",
			icon = "__CyberChest__/graphics/cyberarms.png",
			icon_size = 64,
			prerequisites = {"cyberchest", "inventory-override"},
			unit =
			{
			  count = 60,
			  ingredients =
			  {
					{"automation-science-pack", 1},
					{"logistic-science-pack", 1},
					{"chemical-science-pack", 1}
			  },
			  time = 30
			},
			order = "a-d-d",
	  },
		{
			type = "technology",
			name = "cyberfusion_1",
			icon = "__CyberChest__/graphics/cyberfusion-1.png",
			icon_size = 64,
			prerequisites = {"cyberchest", "modules"},
			unit =
			{
			  count = 100,
			  ingredients =
			  {
					{"automation-science-pack", 1},
					{"logistic-science-pack", 1}
			  },
			  time = 30
			},
			order = "a-d-e",
	  },
		{
			type = "technology",
			name = "cyberfusion_2",
			icon = "__CyberChest__/graphics/cyberfusion-2.png",
			icon_size = 64,
			prerequisites = {"cyberfusion_1", "speed-module"},
			unit =
			{
			  count = 100,
			  ingredients =
			  {
					{"automation-science-pack", 2},
					{"logistic-science-pack", 2}
			  },
			  time = 60
			},
			order = "a-d-f",
	  },
		{
			type = "technology",
			name = "cyberfusion_3",
			icon = "__CyberChest__/graphics/cyberfusion-3.png",
			icon_size = 64,
			prerequisites = {"cyberfusion_2", "speed-module-2"},
			unit =
			{
			  count = 100,
			  ingredients =
			  {
					{"automation-science-pack", 1},
					{"logistic-science-pack", 1},
					{"chemical-science-pack", 1}
			  },
			  time = 60
			},
			order = "a-d-g",
	  },
		{
			type = "technology",
			name = "cyberfusion_4",
			icon = "__CyberChest__/graphics/cyberfusion-4.png",
			icon_size = 64,
			prerequisites = {"cyberfusion_3", "speed-module-3"},
			unit =
			{
			  count = 300,
			  ingredients =
			  {
					{"automation-science-pack", 1},
					{"logistic-science-pack", 1},
					{"chemical-science-pack", 1},
					{"production-science-pack", 1}
			  },
			  time = 90
			},
			order = "a-d-h",
	  },
		{
			type = "technology",
			name = "burst_input_1",
			icon = "__CyberChest__/graphics/burst-input-1.png",
			icon_size = 64,
			prerequisites = {"cyberfusion_1", "inserter-capacity-bonus-1"},
			unit =
			{
			  count = 100,
			  ingredients =
			  {
					{"automation-science-pack", 1},
					{"logistic-science-pack", 1}
			  },
			  time = 30
			},
			order = "a-d-i",
	  },
		{
			type = "technology",
			name = "burst_input_2",
			icon = "__CyberChest__/graphics/burst-input-2.png",
			icon_size = 64,
			prerequisites = {"cyberfusion_2", "inserter-capacity-bonus-2", "burst_input_1"},
			unit =
			{
			  count = 100,
			  ingredients =
			  {
					{"automation-science-pack", 1},
					{"logistic-science-pack", 1},
					{"chemical-science-pack", 1}
			  },
			  time = 60
			},
			order = "a-d-j",
	    },
		{
			type = "technology",
			name = "burst_input_3",
			icon = "__CyberChest__/graphics/burst-input-3.png",
			icon_size = 64,
			prerequisites = {"cyberfusion_3", "inserter-capacity-bonus-3", "burst_input_2"},
			unit =
			{
			  count = 200,
			  ingredients =
			  {
					{"automation-science-pack", 1},
					{"logistic-science-pack", 1},
					{"chemical-science-pack", 1}
			  },
			  time = 60
			},
			order = "a-d-k",
	  },
		{
			type = "technology",
			name = "burst_input_4",
			icon = "__CyberChest__/graphics/burst-input-4.png",
			icon_size = 64,
			prerequisites = {"cyberfusion_4", "inserter-capacity-bonus-4", "burst_input_3"},
			unit =
			{
			  count = 300,
			  ingredients =
			  {
					{"automation-science-pack", 1},
					{"logistic-science-pack", 1},
					{"chemical-science-pack", 1},
					{"production-science-pack", 1}
			  },
			  time = 60
			},
			order = "a-d-l",
	  }
	}
)