local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local function define_crops(name, desc, cropgroups, seedgroups, growgroups, mature,
	fully_grown, lmin, lmax, dropper,
	hmin, hmax, seed, rarity, dec_name, spawnon, spawnby, num)

local m,s,f,p,u=modname..':','seed','farming_'..name,'.png','_'
local cropname,seedname,stagename=m..name,m..s..u..name,f..u
local croppng,seedpng=f..p,f..u..s..p

local function multiplier()
	return (math.random()+math.random()+math.random()+math.random())/2
end


-- concatenate groups if any passed in
local seed_grp = {seed = 1, snappy = 3, attached_node = 1}
for _, v in pairs(seedgroups) do seed_grp[#seed_grp+1]=v
	-- table.insert(seed_grp, v)
end

local grow_grp = {snappy = 3, flammable = 2, plant = 1, attached_node = 1,
	not_in_creative_inventory = 1, growing = 1}
for _, v in pairs(growgroups) do grow_grp[#grow_grp+1]=v
	-- table.insert(grow_grp, v)
end

local crop_grp = {food_barley = 1, flammable = 2}
for _, v in pairs(cropgroups) do crop_grp[#crop_grp+1]=v
	-- table.insert(crop_grp, v)
end


-- define crop seed
minetest.register_node(seedname, {
	description = desc.." Seed",
	tiles = {seedpng},
	inventory_image = seedpng,
	wield_image = seedpng,
	drawtype = "signlike",
	groups = seed_grp,
	paramtype = "light",
	paramtype2 = "wallmounted",
	walkable = false,
	sunlight_propagates = true,
	selection_box = farming.select,
	on_place = function(itemstack, placer, pointed_thing)
		return farming.place_seed(itemstack, placer, pointed_thing, cropname.."_1")
	end,
})

-- define harvested crop
minetest.register_craftitem(cropname, {
	description = desc,
	inventory_image = croppng,
	groups = crop_grp,
})


-- define crop growth stages
local crop_def = {
	drawtype = "plantlike",
	paramtype = "light",
	paramtype2 = "meshoptions",
	place_param2 = 3,
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	drop = {},
	selection_box = farming.select,
	groups = grow_grp,
	sounds = default.node_sound_leaves_defaults()
}

local u={}
local v,w,s=u,u,u
for n=1,fully_grown do
	u=v
	crop_def.tiles = {stagename..tostring(n)..".png"} 
	if n>= mature then -- define each stage
		s=dropper[n-mature+1] -- stage n harvest 
		crop_def.drop={max_items=s[1]}
		for m=1,#s-1 do
			local t=s[m+1] -- 
			if t[1]=='c' then
				t[1]=cropname
			elseif t[1]=='s' then
				t[1]=seedname
			end
			u[#u+1]={items={t[1].." "..tostring(t[2])}, rarity = t[3]}
		end
		crop_def.drop={items=u,max_items=s[1]}
		if n==fully_grown then crop_def.groups.growing = 0 end
	end
	minetest.register_node(cropname.."_"..tostring(n), table.copy(crop_def))
end


-- add to registered_plants
farming.registered_plants[cropname] = {
	crop = cropname,
	seed = seedname,
	minlight = lmin, 
	maxlight = lmax, 
	steps = fully_grown
}

-- Fuel
minetest.register_craft({
	type = "fuel",
	recipe = cropname,
	burntime = 1,
})

-- flour
if minetest.get_item_group(cropname,'mill')==1 then 
	minetest.register_craftitem(cropname..'_flour', {
		description = desc..' Flour',
		inventory_image = croppng,
		groups = {flammable = 2, flour=1},
	})

	minetest.register_craft({
		type = "shapeless",
		output = cropname..'_flour',
		recipe = {
			cropname, cropname, cropname,
			cropname, "farming:mortar_pestle"
		},
		replacements = {{"group:food_mortar_pestle", "farming:mortar_pestle"}},
	})
end





-- Code inspired by TenPlus1's Farming Redo
if dec_name~='' or dec_name~=nil then
	local v=minetest.settings:get_bool("variable_crop_rarity") or true
	local r=minetest.settings:get_bool("random_crop_seed") or true
	if v == true then rarity = rarity * multiplier() end
	if spawnon == nil then spawnon = {"default:dirt_with_grass"} end
	minetest.log(name.."  Rarity: "..rarity)
	local seeder = math.random(999)

-- Next code block is legacy support for TenPlus1's fixed seeds.	
-- Kill the whole block if you don't care about static mapgen.
-- From here:
	if r == false then -- No, I want my TenPlus1's static seeds!
		if string.find(name, "hemp")  == 1 then 
			seeder = 420
		elseif string.find(name, "chili") == 1 then
			seeder = 760
		elseif string.find(name, "pepper") == 1 then
			seeder = 933
		elseif string.find(name, "pineapple") == 1 then
			seeder = 917
		else
			seeder = 329
		end
	end
-- To here.	


minetest.register_decoration({
	deco_type = "simple",
	place_on = spawnon,
	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = rarity, 
		spread = {x = 100, y = 100, z = 100},
		seed = seeder,
		octaves = 3,
		persist = 0.6
	},
	y_min = hmin,
	y_max = hmax,
	decoration = dec_name,
	spawn_by = spawnby,
	num_spawn_by = num,
})
end
end

-- ---------------------------------------------------------------------------------------
-- --------------------------------------------BEGIN MAIN CODE ---------------------------
-- ---------------------------------------------------------------------------------------


dofile(modpath..'/newblocks.lua')
dofile(modpath..'/mod_tweaks.lua')
dofile(modpath..'/overrides.lua')
dofile(modpath..'/recipes.lua')


--[[
define_crops(
field -- type- description
	name,	s- internal name (used for all file, tile, node, craft etc. references)
	desc,	s- Description: what the player sees it called
	{},		t- additional groups the harvested crop belongs to 
	{},		t-additional groups the seed belongs to 
	{},		t-additional groups the growing crop belongs to 
	6,		i- mature plant stage (first stage with drops)
	8,		i- fully grown plant stage (no more growing beyond this)
	lmin,	i- minimum light for the plant to grow
	lmax	i-maximum light for the plant to grow
	{
	{max_items,				i- maximum items from growth stage 
	{drop, qty, rarity}		t- first stage drops
	[,{drop2, qty2, rarity2}
	[...] ]} 
	},
				repeat for next stages as needed
	hmin,		i- minimum placement elevation (mapgen) 
	hmax,		i- maximum placement elevation  (mapgen)
	seed		i- sigh. some people want repeatable mapgens. just put in some integer
	rarity		f- .01 is thick, .0001 is very rare. I use around .0005
	dec_name	t- node to place during mapgen
	spawnon,	t- block mapgen places the crop on
	spawnby,	t- block mapgen places the crop next to
	num			i- number of adjacent blocks that must be "spawnby"
	)
--]]


local grass = "default:dirt_with_grass"
local dry = "default:dirt_with_dry_grass"
local jungle = "default:dirt_with_rainforest_litter"
-- for future crops for under-served biomes?
-- local forest = "default:dirt_with_coniferous_litter" -- raspberries?
-- local snow = "default:dirt_with_snow" -- cloudberries?
-- local desert = "default:desert_sand" -- agave?


define_crops(
-- plant and growth parameters
	"marram","Marram Grass", --name, desc
	{},{},{}, --cropgroups, seedgroups, growgroups
	5,6,12,15, --mature, fully_grown, lmin, lmax
--drops
	{
	{9,{'c',1,3},{'s',1,2}}, -- mature stage, {max items,{drop,qty,rarity}...} 
	{9,{'c',2,1},{'c',1,3},{'s',1,1},{'s',1,3}} --next stage, repeat as needed
	},
-- mapgen parameters
	1, 100, 329, .0005,"", --hmin, hmax, seed, rarity, dec_name
	nil, nil,-1) --spawnon, spawnby, num


