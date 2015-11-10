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
			order = "a-d-c",
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
			order = "a-d-d",
	    },
		{
			type = "technology",
			name = "cyberfusion_1",
			icon = "__CyberChest__/graphics/cyberfusion-1.png",
			prerequisites = {"cyberchest"},
			unit =
			{
			  count = 100,
			  ingredients =
			  {
				{"science-pack-1", 1},
				{"science-pack-2", 1}
			  },
			  time = 30
			},
			order = "a-d-e",
	    },
		{
			type = "technology",
			name = "cyberfusion_2",
			icon = "__CyberChest__/graphics/cyberfusion-2.png",
			prerequisites = {"cyberfusion_1"},
			unit =
			{
			  count = 100,
			  ingredients =
			  {
				{"science-pack-1", 2},
				{"science-pack-2", 2}
			  },
			  time = 30
			},
			order = "a-d-f",
	    },
		{
			type = "technology",
			name = "cyberfusion_3",
			icon = "__CyberChest__/graphics/cyberfusion-3.png",
			prerequisites = {"cyberfusion_2"},
			unit =
			{
			  count = 100,
			  ingredients =
			  {
				{"science-pack-1", 1},
				{"science-pack-2", 1},
				{"science-pack-3", 1},
			  },
			  time = 30
			},
			order = "a-d-g",
	    },
		{
			type = "technology",
			name = "cyberfusion_4",
			icon = "__CyberChest__/graphics/cyberfusion-4.png",
			prerequisites = {"cyberfusion_3"},
			unit =
			{
			  count = 100,
			  ingredients =
			  {
				{"science-pack-1", 1},
				{"science-pack-2", 1},
				{"science-pack-3", 1},
				{"alien-science-pack", 1}
			  },
			  time = 30
			},
			order = "a-d-h",
	    }	
	}
)