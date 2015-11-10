require "util"

cyber_speed_module = 
{
    type = "module",
    name = "cyber_speed_module",
    icon = "__CyberChest__/graphics/empty.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "module",
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
    flags = {},
    max_health = 0,
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
			},
		}
	}
)