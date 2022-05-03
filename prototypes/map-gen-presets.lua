data:extend({
	{
		type = "map-gen-presets",
		name = "default",
		-- default changes nothing
		Singistics = {
			order = "a",
	 		basic_settings = {
				autoplace_controls = {
					["enemy-base"] = {
						frequency = 0,
						size = 0
					},
					["trees"] = {
						frequency = 0,
						size = 0,
						richness = 0
					}
				},
				peaceful_mode = true,
			},
			advanced_settings = {
				enemy_evolution = {
					enabled = false
				},
				enemy_expansion = {
					enabled = false
				},
				pollution = {
					enabled = false
				}
			}
		},
	}
})
