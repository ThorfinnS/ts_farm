local dirt = "default:dirt"
local sand = "group:sand"
local leaves = "group:leaves"
local wood  = "group:wood"
local nada = ""
local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)



local function dumper(s,m,o,a,l,i)
-- s-table to output
-- m-message, default ""
-- o-output file name, default "logger.txt"
-- a-open attribute (a)ppend, (w)rite, default "a"
-- l-limit to structure depth, default 100
-- i-indent, string prepending each line, default ""
-- use no parameters to clear logger.txt

local n='\n'
local h

local function rWrite(s, l, i) 
	if (l<1) then 
		h:write("ERROR: Item limit reached.\n")
		return l-1 
	end;
	local ts = type(s);
	if (ts ~= "table") then 
		h:write(tostring(i),tostring(ts),'-- ',tostring(s),'\n')
		return l-1 
	end
	h:write(tostring(i),tostring(ts),'\n')
	for k,v in pairs(s) do  
		l = rWrite(v, l, i.."\t["..tostring(k).."]");
		if (l < 0) then break end
	end
	return l
end	

if s==nil then s={} end
if a~="w" then
	a='a'
end
if o=="" or o==nil then 
	h = assert(io.open(modpath..'/logger.txt',a))
else
	h = assert(io.open(modpath..'/'..o,a))
end
if m==nil then m="" end

l = (l) or 100; i = i or "" -- set defaults
h:write(n,m,n)
rWrite(s,l,i)
h:write(n,n)
h:flush()
h:close()

end


local function define_crops(name, desc, cropgroups, seedgroups, growgroups, mature,
	fully_grown, lmin, lmax, dropper,
	hmin, hmax, spawnon, spawnby, num, seed, rarity, deco_name)

	local cropname=modname..":"..name
	local seedname=modname..":seed_"..name
	local croppng="farming_"..name..".png"
	local seedpng="farming_"..name.."_seed"..".png"
	local stagename="farming_"..name.."_"


	-- concatenate groups if any passed in
	local seed_grp = {seed = 1, snappy = 3, attached_node = 1}
	for _, v in pairs(seedgroups) do
		table.insert(seed_grp, v)
	end

	local grow_grp = {snappy = 3, flammable = 2, plant = 1, attached_node = 1,
		not_in_creative_inventory = 1, growing = 1}
	for _, v in pairs(growgroups) do
		table.insert(grow_grp, v)
	end

	local crop_grp = {food_barley = 1, flammable = 2}
	for _, v in pairs(cropgroups) do
		table.insert(crop_grp, v)
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
		inventory_image = name..".png",
		groups = crop_grp,
	})


	-- define crop growth
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
	-- local v={}
	local w={}
	local s={}
	-- local t={}
	-- local t1=9
	for n=1,fully_grown do
		u={}
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
	-- minetest.register_craft({
		-- type = "shapeless",
		-- output = "farming:flour",
		-- recipe = {
			-- "farming:barley", "farming:barley", "farming:barley",
			-- "farming:barley", "farming:mortar_pestle"
		-- },
		-- replacements = {{"group:food_mortar_pestle", "farming:mortar_pestle"}},
	-- })

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

	minetest.override_item("default:marram_grass_3", {
		drop = {
			max_items = 5, --3,
			items = {
				{items = {seedname}},
				{items = {"default:marram_grass_1"}},
				{items = {seedname}, rarity = 5},
				{items = {seedname}, rarity = 12},
				{items = {cropname}},
			}
		},
	})


end


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

-- ----------------------------------Begin Main Code Section --------------------------

dumper()


craft_dirt("default:dirt_with_rainforest_litter", "default:junglegrass", dirt)
craft_dirt("default:dirt_with_dry_grass", "default:dry_grass_1", dirt)
craft_dirt("default:dirt_with_grass", "default:grass_1", dirt)
craft_dirt("default:dirt_with_snow", "default:snowblock", dirt)
craft_dirt("default:dirt_with_snow", "default:snow", dirt)
craft_dirt("default:dirt_with_coniferous_litter", "default:fern_1", dirt)
craft_dirt("default:desert_sand", "default:cactus", sand)
craft_dirt("default:desert_sand", "default:dry_shrub", sand)
craft_dirt("default:sand","default:marram_grass_1", sand)

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
	spawnon,	t- block mapgen places the crop on
	spawnby,	t- block mapgen places the crop next to
	num			i- number of adjacent blocks that must be "spawnby"
	seed		i- sigh. some people want repeatable mapgens. just put in some integer
	rarity		f- .01 is thick, .0001 is very rare. I use around .0005
	deco_name	t- node to place during mapgen
	)
--]]

--[[
local function define_crops(
	name, desc, cropgroups, seedgroups, growgroups, mature, fully_grown, lmin, lmax, 
	dropper, hmin, hmax, spawnon, spawnby, num, seed, rarity, deco_name)
--]]

define_crops("marram","Marram Grass",{},{},{},5,6,12,15,
	{{9,{'c',1,3},{'s',1,2}},
	{9,{'c',2,1},{'c',1,3},{'s',1,1},{'s',1,3}}},
	0, 0, nil, nil, 0, 1, nil,"")


