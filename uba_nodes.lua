
uba.copy_table = function(t)
	local nt = {}
	for k, v in pairs(t) do
		nt[k] = v
	end
	return nt
end

-- register the arena chest node
local new_slab = uba.copy_table(minetest.registered_nodes["stairs:slab_stonebrick"])
new_slab.description = "uba spawn slab"
new_slab.after_place_node = function(pos, placer, itemstack, pointed_thing)
	local name = placer:get_player_name()
	if not uba.action_spawnSlab(pos,"add",name) then
		minetest.remove_node(pos)
		itemstack:clear() -- slab is cleared from inventory
	end
	return itemstack
end
new_slab.can_dig = function(pos, player)
	local name = player:get_player_name()
	if uba.edit[name] then
		return true
	else
		return false
	end
end
new_slab.after_dig_node = function(pos, oldnode, oldmetadata, digger)
	local name = digger:get_player_name()
	uba.action_spawnSlab(pos,"remove",name)
	return itemstack
end
minetest.register_node("uba:spawn_slab",new_slab)

-- register the arena chest node
local new_chest = uba.copy_table(minetest.registered_nodes["default:chest"])
new_chest.description = "uba chest"
new_chest.after_place_node = function(pos, placer, itemstack, pointed_thing)
	local name = placer:get_player_name()
	if not uba.action_chest(pos,"add",name) then
		minetest.remove_node(pos)
		itemstack:clear() -- chest is cleared from inventory
	end
	return itemstack
end
new_chest.can_dig = function(pos, player)
	local name = player:get_player_name()
	local meta = minetest.get_meta(pos)
	local arena_name = meta:get_string("arena_name")
	if uba.edit[name] == arena_name then
		return true
	else
		return false
	end
end
new_chest.after_dig_node = function(pos, oldnode, oldmetadata, digger)
	local name = digger:get_player_name()
	uba.action_chest(pos,"remove",name)
	return itemstack
end
minetest.register_node("uba:chest",new_chest)

-- register the wall_node
local conf_file = Settings(uba.mod_path.."/uba.conf")
local wall_node_base = conf_file:get("wall_node_base")
if not wall_node_base then
	wall_node_base = "default:glass"
	conf_file:set("wall_node_base",wall_node_base)
	conf_file:write()
end
local wall_node = uba.copy_table(minetest.registered_nodes[wall_node_base])
wall_node.description = "uba wall node, only removable with worldedit"
wall_node.groups = {}
minetest.register_node("uba:wall",wall_node)
