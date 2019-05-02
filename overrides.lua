local name,modname='marram',minetest.get_current_modname()
local m,s,u=modname..':','seed','_'
local cropname,seedname=m..name,m..s..u..name

minetest.override_item("default:marram_grass_3", {
	drop = {
		items = {
			{items = {cropname}},
			{items = {seedname}},
			{items = {seedname}, rarity = 5},
			{items = {seedname}, rarity = 8},
		}
	},
})

