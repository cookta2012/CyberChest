cyber_speed_module = 
{
    type = "module",
    name = "cyber_speed_module",
    localized_description="This is a technical item you can not obtain this item.",
    icon = "__CyberChest__/graphics/empty.png",
    icon_size = 32,
    category = "speed",
    flags = {},
    subgroup = "module",
    tier = 1,
    order = "a[speed]-a[speed-module-1]",
    stack_size = 1,
    default_request_amount = 1,
    effect = { speed = {bonus = 0.5}, consumption = {bonus = 0.7}}
}

cyber_beacon_50 =
{
    type = "beacon",
    name = "cyber_beacon_50",
    icon = "__CyberChest__/graphics/empty.png",
    icon_size = 32,
    flags = {},
    max_health = 1,
    corpse = "small-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
    selection_box = {{-0.2, -0.2}, {0.2, 0.2}},
    allowed_effects = {"consumption", "speed", "pollution"},
	    module_specification =
    {
      module_slots = 2
    },
    base_picture =
    {
      filename = "__CyberChest__/graphics/empty.png",
      width = 1,
      height = 1,
      shift = {0, 0}
    },
    animation =
    {
      filename = "__CyberChest__/graphics/empty.png",
      width = 1,
      height = 1,
      line_length = 1,
      frame_count = 1,
      shift = { 0, 0},
      animation_speed = 1
    },
    animation_shadow =
    {
      filename = "__CyberChest__/graphics/empty.png",
      width = 1,
      height = 1,
      line_length = 1,
      frame_count = 1,
      shift = {0, 0},
      animation_speed = 1
    },
    radius_visualisation_picture =
    {
      filename = "__CyberChest__/graphics/empty.png",
      width = 1,
      height = 1
    },
    supply_area_distance = 1,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input"
    },
    energy_usage = "100kW",
    distribution_effectivity = 1,
    num_module_slots = 1
}
cyber_beacon_100 = table.deepcopy(cyber_beacon_50)
cyber_beacon_100.distribution_effectivity = 2
cyber_beacon_100.name = "cyber_beacon_100"

cyber_beacon_200 = table.deepcopy(cyber_beacon_50)
cyber_beacon_200.distribution_effectivity = 4
cyber_beacon_200.name = "cyber_beacon_200"

cyber_beacon_400 = table.deepcopy(cyber_beacon_50)
cyber_beacon_400.distribution_effectivity = 8
cyber_beacon_400.name = "cyber_beacon_400"

data:extend(
	{
		cyber_speed_module,
		cyber_beacon_50,
		cyber_beacon_100,
		cyber_beacon_200,
		cyber_beacon_400,
		{
			type = "item",
			name = "cyberchest",
      icon = "__CyberChest__/graphics/cyberchest-icon.png",
      icon_size = 32,
			--flags = {},
			----group = "production",
			subgroup = "production-machine",
			order = "h[cyberchest]",
			place_result = "cyberchest_meta",
			stack_size = 20
		},
		{
			type = "recipe",
			name = "cyberchest",
			energy_required = 3.0,
			enabled = "false",
			ingredients = {{"iron-plate", 10}, {"iron-chest", 2}, {"fast-inserter", 2}}, 
			--group = "production",
			--subgroup = "production-machine",
			result = "cyberchest",
			result_count = 1
		},
		{
			type = "container",
			name = "cyberchest",
      icon = "__CyberChest__/graphics/cyberchest-icon.png",
      icon_size = 32,
      flags = {"not-flammable"},
			open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.65 },
			close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 },
      minable = { minable=false, mining_time=0},
      resistances =
      {
        {
          type = "physical",
          percent = 100
        },
        {
          type = "explosion",
          percent = 100
        },
        {
          type = "acid",
          percent = 100
        },
        {
          type = "fire",
          percent = 100
        }
      },
			max_health = 350,
			corpse = "medium-remnants",
			collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
      selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
      selectable_in_game = false,
      selection_priority = 0,
      --fast_replaceable_group = "container-medium",
			inventory_size = 60,
			picture =
			{
				filename = "__CyberChest__/graphics/cyberchest.png",
				priority = "high",
				width = 128,
				height = 100,
				shift = {0.35, 0.05}
			}
    },
    {
			type = "container",
			name = "cyberchest_meta",
      icon = "__CyberChest__/graphics/cyberchest-icon.png",
      icon_size = 32,
			flags = {"placeable-neutral", "player-creation"},
			open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.65 },
			close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 },
			minable = {mining_time = 1, result = "cyberchest"},
			max_health = 350,
			corpse = "medium-remnants",
      resistances = {
        {type = "physical", percent = 20},
        {type = "fire", percent = 50}
      },
      selectable_in_game = true,
      selection_priority = 255,
			collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
			selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
      --fast_replaceable_group = "container-medium",
			inventory_size = 0,
			picture =
			{
				filename = "__CyberChest__/graphics/cyberchest.png",
				priority = "high",
				width = 128,
				height = 100,
				shift = {0.35, 0.05}
			}
		}
	}
)