local leaves = "group:leaves"
local wood  = "group:wood"
local nada = ''


-- wooden_bucket mod
if minetest.settings:get_bool("wooden_bucket_recipe") ~= false then
	if minetest.registered_items["bucket_wooden:bucket_empty"] then
-- change recipe for wooden_bucket so it doesn't conflict with farming_redo or ethereal
		minetest.register_craft({
			output = 'bucket_wooden:bucket_empty',
			recipe = {
				{wood, leaves, wood},
				{nada, wood, nada},
			}
		})
	end
end -- wooden_bucket mod


-- basic materials
if minetest.registered_items["basic_materials:oil_extract"] then
	if minetest.settings:get_bool("basic_materials_oil_rebalance") ~= false then
-- Rebalanced basic materials mod. Still turns a 24 burn time into a 30 burn time, but
--	better than 8 sec into 30 sec.
		minetest.register_craft({
			type = "shapeless",
			output = "basic_materials:oil_extract",
			recipe = {
				leaves,
				leaves,
				leaves,
				leaves,
				leaves,
				leaves
			}
		})
	end


-- A use for extra seeds!
	minetest.register_craft({
		type = "shapeless",
		output = "basic_materials:oil_extract",
		recipe = {
			"group:seed"
		}
	})
end -- basic materials

