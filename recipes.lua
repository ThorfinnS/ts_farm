local name,modname='marram',minetest.get_current_modname()
local m,s,f,p,u=modname..':','seed','farming_'..name,'.png','_'
local cropname,seedname,stagename=m..name,m..s..u..name,f..u
local croppng,seedpng=f..p,f..u..s..p


-- marram grass to thatch
minetest.register_craftitem(cropname, {
	description = "Thatch",
	inventory_image = croppng,
	groups = {flammable = 2},
})

minetest.register_craft({
	type = "shapeless",
	output = "farming:straw 3",
	recipe = {
		cropname
	}
})
