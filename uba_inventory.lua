
uba.save_player_inventory = function(name)
	local player = minetest.get_player_by_name(name)
	local inv = player:get_inventory()
	local arena_name = uba.players[name]["arena_name"]
	uba.players[name] = {inventory = inv:get_list("main"), arena_name = arena_name}
	print(dump(uba.players))
end

uba.restore_player_inventory = function(name)
	local player = minetest.get_player_by_name(name)
	local inv = player:get_inventory()
	inv:set_list("main",uba.players[name]["inventory"])
end