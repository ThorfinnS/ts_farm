local dirt = "default:dirt"
local sand = "group:sand"
local nada = ""


local function craft_dirt(o,i,d)
	minetest.register_craft({
		output = o,
		recipe = {
			{nada, d, nada},
			{d, i, d},
			{nada, d, nada}
		}
	})
end

craft_dirt("default:dirt_with_rainforest_litter", "default:junglegrass", dirt)
craft_dirt("default:dirt_with_dry_grass", "default:dry_grass_1", dirt)
craft_dirt("default:dirt_with_grass", "default:grass_1", dirt)
craft_dirt("default:dirt_with_snow", "default:snowblock", dirt)
craft_dirt("default:dirt_with_snow", "default:snow", dirt)
craft_dirt("default:dirt_with_coniferous_litter", "default:fern_1", dirt)
craft_dirt("default:desert_sand", "default:cactus", sand)
craft_dirt("default:desert_sand", "default:dry_shrub", sand)
craft_dirt("default:sand","default:marram_grass_1", sand)


