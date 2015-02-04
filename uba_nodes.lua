
-- register the arena chest node
local new_slab = uba.copy_table(minetest.registered_nodes["stairs:slab_stonebrick"])
new_slab.description = "uba spawn slab"
new_slab.after_place_node = function(pos, placer, itemstack, pointed_thing)
	local pos = minetest.get_pointed_thing_position(pointed_thing, true)
	uba.action_spawnSlab(pos,"add",placer)
	return itemstack
end
new_slab.after_dig_node = function(pos, oldnode, oldmetadata, digger)
	uba.action_spawnSlab(pos,"remove",digger)
	return itemstack
end
minetest.register_node("uba:spawn_slab",new_slab)

-- register the arena chest node
local new_chest = uba.copy_table(minetest.registered_nodes["default:chest"])
new_chest.description = "uba chest"
new_chest.after_place_node = function(pos, placer, itemstack, pointed_thing)
	uba.action_chest(pos,"add",placer)
	return itemstack
end
new_chest.after_dig_node = function(pos, oldnode, oldmetadata, digger)
	uba.action_chest(pos,"remove",digger)
	return itemstack
end
minetest.register_node("uba:chest",new_chest)
