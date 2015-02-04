-- uba
-- |-- uba.conf
-- |-- arenas.conf
-- \-- arena_name
--     |-- items.conf
--     |-- arena.uba
--     |-- chest.uba
--     \-- spawn_slab.uba
-- 
-- uba.player[]
-- uba.arenas[]
-- uba.edit[]

uba.initiate = function(arena_name,name)
	local pos1 = worldedit.pos1[name]
	local pos2 = worldedit.pos2[name]

	if not pos1 or not pos2 then
		minetest.chat_send_player(name,"pos1 or pos2 not set !")
		return
	end
	-- save positions to file
	pos1 = vector.round(pos1)
	pos2 = vector.round(pos2)
	local file_name = arena_name.."/arena.uba"

	-- status :
	--  * active (a game is active)
	--  * waiting (players are entering the arena, waiting to start)
	--  * edit (arena is loaded but no one can join, chests/slabs can be edited/removed)

	uba.arenas[arena_name] = {pos1=pos1,pos2=pos2,status="edit",maxplayers=0,nplayers=0,timer=os.time()}
	uba.edit[name] = arena_name

	os.execute("mkdir " .. arena_name)
	local arena_file = io.open(uba.mod_path.."/"..file_name, "w")
	arena_file:write(minetest.serialize(uba.arenas[arena_name]))
	io.close(arena_file)

	-- create walls
	local wall_node = "default:glass"
	uba.createWall(pos1,pos2,wall_node)

	-- give nodes to arena builder
	uba.give_arena_items(name)

	minetest.chat_send_player(name,"*Use /uba save to enable the arena when finished building")

end

uba.action_chest = function(pos,action,name) -- add or remove
	local arena_name = uba.edit[name]
	-- save position of chests
	local chest_positions = uba.arenas[arena_name]["chest_positions"]
	if action == "add" then
		table.insert(chest_positions,pos)
	elseif action == "remove" then
		for i=1,table.getn(chest_positions) do
			if chest_positions[i] == pos then
				table.remove(chest_positions, i) -- remove the position from the table
			end
		end
	end
	uba.arenas[arena_name]["chest_positions"] = chest_positions
end

uba.action_spawnSlab = function(pos,action,name) -- add or remove
	local arena_name = uba.edit[name]
	-- save position of slabs
	local arena_data = uba.arenas[arena_name]
	if action == "add" then
		table.insert(arena_data.slab_positions,pos)
		arena_data.maxplayers = arena_data.maxplayers + 1 -- increment maxplayers
	elseif action == "remove" then
		for i=1,table.getn(arena_data.slab_positions) do
			if arena_data.slab_positions[i] == pos then
				table.remove(arena_data.slab_positions, i) -- remove the position from the table
			end
		end
		arena_data.maxplayers = arena_data.maxplayers - 1 -- decrement maxplayers
	end
	uba.arenas[arena_name] = arena_data
end

uba.createWall = function(pos1,pos2,wall_node)
	-- create a 30 blocks high wall around the arena
	pos1 = vector.round(pos1)
	pos2 = vector.round(pos2)
	local bottom_left = pos1
	local top_right = pos2
	if pos1.z > pos2.z then
		bottom_left.z = pos2.z
		top_right.z = pos1.z
	end
	if pos1.x > pos2.x then
		bottom_left.x = pos2.x
		top_right.x = pos1.x
	end

	bottom_left.y = bottom_left.y - 15
	top_right.y = bottom_left.y + 30

	pos1 = bottom_left
	pos2 = top_right

	local manip = minetest.get_voxel_manip()
	local emerged_pos1, emerged_pos2 = manip:read_from_map(pos1, pos2)
	local area = VoxelArea:new({MinEdge=emerged_pos1, MaxEdge=emerged_pos2})
	local nodes = manip:get_data()
	local wall_id = minetest.get_content_id(wall_node)

	for y=0,30 do
		for z=0,pos2.z-pos1.z do
			--
			-- |  |
			-- |  |
			--
			nodes[area:index(pos1.x, pos1.y+y, pos1.z+z)] = wall_id
			nodes[area:index(pos2.x, pos1.y+y, pos1.z+z)] = wall_id
		end
		for x=0,pos2.x-pos1.x do
			-- _______
			--
			-- _______
			--
			nodes[area:index(pos1.x+x, pos1.y+y, pos1.z)] = wall_id
			nodes[area:index(pos1.x+x, pos1.y+y, pos2.z)] = wall_id
		end
	end

	-- write changes to map
	manip:set_data(nodes)
	manip:write_to_map()
	manip:update_map()

end

uba.give_arena_items = function(name)
	local player = minetest.get_player_by_name(name)
	local inv = player:get_inventory()

	local chest = ItemStack("uba:chest")
	inv:add_item("main", chest)

	local spawn_slab = ItemStack("uba:spawn_slab")
	inv:add_item("main", spawn_slab)
end

uba.protect_nodes = function(arena_name,pos1,pos2)
	--
end

uba.fill_chests = function(arena_name)
	local chest_positions = uba.arenas[arena_name]["chest_positions"]

	local items = Settings(uba.mod_path.."/"..arena_name.."/items.conf")
	local items_table = items:to_table()
	if not items_table then
		minetest.log("error","["..uba.mod_name.."] Items file is empty.")
		return false
	end
	local indexed_items = {}
	for k,v in pairs(items_table) do
		table.insert(indexed_items,{name=k,count=v})
	end

	math.randomseed(os.time())
	while indexed_items ~= {} do
		local chest_index = math.random(1,table.getn(chest_positions))
		local item_index = math.random(1,table.getn(indexed_items))
		local meta = minetest.get_meta(chest_positions[chest_index])
		local inv = meta:get_inventory()
		local itemstring = indexed_items[item_index].name
		if minetest.registered_tools[itemstring] then
			inv:add_item('main', itemstring)
			indexed_items[item_index].count = indexed_items[item_index].count - 1 -- we decrement the item count
			if indexed_items[item_index].count < 1 then
				table.remove(indexed_items,item_index) -- the item is removed from table if count = 0
			end
		else
			table.remove(indexed_items,item_index) -- the item is removed from table if not a known tool
		end
	end
end

uba.put_player_in_arena = function(arena_name,name)
	local player = minetest.get_player_by_name(name)
	uba.player_move(name,"freeze")
	uba.players[name] = arena_name -- put the player in the active players table
	uba.arenas[arena_name]["nplayers"] = uba.arenas[arena_name]["nplayers"] + 1 -- increment n players
	if uba.arenas[arena_name]["nplayers"] >= uba.arenas[arena_name]["maxplayers"] then
		uba.start_game(arena_name)
	end
end

uba.start_game = function(arena_name)
	local arena_data = uba.arenas[arena_name]
	arena_data.status = "active"

	-- unfreeze players
	-- playername => arena_name
	for k,v in pairs(uba.players) do
		if v == arena_name then
			uba.player_move(k,"unfreeze")
			minetest.chat_send_player(k,"!!! Fight to the death !!!")
		end
	end
	-- the fight can begin !
end

uba.player_move = function(name,action) -- freeze or unfreeze
	local player = minetest.get_player_by_name(name)
	if action == "freeze" then
		player:set_physics_override({speed = 0})
	elseif action == "unfreeze" then
		player:set_physics_override({speed = 1})
	end
end

uba.join_game = function(arena_name,name)
	if uba.arenas[arena_name]["nplayers"] <= uba.arenas[arena_name][maxplayers] or
		uba.arenas[arena_name]["status"] ~= "waiting" then
		minetest.chat_send_player(name,"Arena is busy, retry in a moment")
		return false
	end
	uba.put_player_in_arena(arena_name,name)
	minetest.chat_send_all(name.." joined "..arena_name)
end

uba.disable_arena = function(arena_name,name)
	for k,v in pairs(uba.players) do -- Kill ALL players mouhahaha :D
		if v == arena_name then
			local player = get_player_by_name(k)
			player:set_hp(0) -- kill player, will respawn in lobby
		end
	end
	uba.arenas[arena_name] = nil -- memory is freed
	Settings(uba.mod_path"/arena.conf"):set_key(arena_name,"disabled")
	minetest.chat_send_all("Arena "..arena_name.." has been disabled !")
end

uba.load_arenas = function()
	local conf_file = Settings(uba.mod_path.."/arenas.conf")
	local arenas_table = conf_file:to_table()
	for arena_name,v in pairs(arenas_table) do
		if v == "enabled" then
			uba.load_arena(arena_name)
		else
			minetest.log("info","[uba] Arena "..arena_name.." not loaded, as set in arenas.conf")
		end
	end
end

uba.load_arena = function(arena_name)
	-- load arena_data
	local arena_file = io.open(uba.mod_path.."/"..arena_name.."/arena.uba", "r")
	if not arena_file then
		minetest.log("error","[uba] Missing file "..arena_name.."/arena.uba")
		minetest.log("error","[uba] "..arena_name.." not enabled !")
		return false
	end
	local arena_data = minetest.deserialize(arena_file:read("*all"))
	if not arena_data or arena_data == {} then
		minetest.log("error","[uba] Empty file "..arena_name.."/arena.uba")
		minetest.log("error","[uba] "..arena_name.." not enabled !")
		return false
	end
	io.close(arena_file)
	arena_data.timer = os.time()
	arena_data.votes = 0

	-- load chest_positions
	local chest_file = io.open(uba.mod_path.."/"..arena_name.."/chest.uba", "r")
	if not chest_file then
		minetest.log("error","[uba] Missing file "..arena_name.."/chest.uba")
		minetest.log("error","[uba] "..arena_name.." not enabled !")
		return false
	end
	local chest_positions = minetest.deserialize(chest_file:read("*all"))
	if not chest_positions or chest_positions == {} then
		minetest.log("error","[uba] Empty file "..arena_name.."/chest.uba")
		minetest.log("error","[uba] "..arena_name.." not enabled !")
		return false
	end
	io.close(chest_file)
	arena_data["chest_positions"] = chest_positions

	-- load spawn slabs positions
	local slab_file = io.open(uba.mod_path.."/"..arena_name.."/spawn_slab.uba", "r")
	if not slab_file then
		minetest.log("error","[uba] Missing file "..arena_name.."/spawn_slab.uba")
		minetest.log("error","[uba] "..arena_name.." not enabled !")
		return false
	end
	local slab_positions = minetest.deserialize(chest_file:read("*all"))
	if not chest_positions or chest_positions == {} then
		minetest.log("error","[uba] Empty file "..arena_name.."/spawn_slab.uba")
		minetest.log("error","[uba] "..arena_name.." not enabled !")
		return false
	end
	io.close(slab_file)
	arena_data["slab_positions"] = slab_positions

	uba.arenas[arena_name] = arena_data
	-- arena is fully loaded in memory
end

uba.arena_exists = function(arena_name)
	for k,_ in pairs(uba.arenas) do
		if k == arena_name then
			return true
		end
	end
	return false
end

uba.player_died = function(name)
	local player = minetest.get_player_by_name(name)
	local arena_name = uba.players[name]
	local inv = player:get_inventory()
	inv:set_list("Main", {}) -- empty inventory
	uba.players[name] = nil -- memory is freed
	uba.arenas[arena_name][nplayers] = uba.arenas[arena_name][nplayers] - 1 -- decrement n players
	if nplayers <= 1 then
		uba.end_game(arena_name)
	end
end

uba.save_arena = function(name)
	local arena_name = uba.edit[name]
	uba.edit[name] = nil 
	local arena_file = io.open(uba.mod_path.."/"..arena_name.."/arena.uba","w")
	uba.arenas[arena_name]["status"] = "waiting"
	local arena_data = uba.arenas[arena_name]
	arena_file:write(minetest.serialize(arena_data))
	io.close(arena_file)
	minetest.chat_send_player(name,"Arena "..arena_name.." saved with maxplayers = "..arena_data.maxplayers)
end

uba.vote = function(arena_name,name)
	local timediff = os.time() - uba.arenas[arena_name][timer]
	local votes = uba.arenas[arena_name]["votes"]
	local nplayers = uba.arenas[arena_name]["nplayers"]
	if uba.arenas[arena_name]["status"] == "active" then
		minetest.chat_send_player(name,arena_name.." : Game has already started")
	elseif timediff < 60 or uba.arenas[arena_name][nplayers] == 1 then
		minetest.chat_send_player(name,arena_name.." : Waiting for more players to join")
	else
		votes = votes + 1
		uba.arenas[arena_name]["votes"] = votes
		minetest.chat_send_all(arena_name.." : vote is "..votes.."/"..nplayers)
	end
	if votes >= nplayers then
		uba.start_game(arena_name)
	end
end

uba.end_game = function(arena_name)
	-- we have a winner ! game must be ended
	local lastplayer = " "
	for k,v in pairs(uba.players) do
		if v == arena_name then
			lastplayer = k
			break
		end
	end
	minetest.chat_send_all(lastplayer.." won the game in arena "..arena_name)
	minetest.get_player_by_name(lastplayer):set_hp(0) -- kill the last player
	uba.arenas[arena_name]["status"] = "waiting" -- arena is waiting for new players
	uba.arenas[arena_name]["votes"] = 0 -- reset the votes
	uba.arenas[arena_name][timer] = os.time()
end

uba.edit_arena = function(arena_name,name)
	if not uba.arenas[arena_name] then -- arena was disabled
		if not uba.load_arena(arena_name) then
			minetest.chat_send_player(name,"*Error while loading arena, check debug.txt !")
			return false
		end
		Settings(uba.mod_path"/arena.conf"):set_key(arena_name,"enabled")
	end
	if uba.arenas[arena_name]["status"] ~= "edit" then
		for k,v in pairs(uba.players) do -- Kill ALL players mouhahaha :D
			if v == arena_name then
				local player = get_player_by_name(k)
				player:set_hp(0) -- kill player, will respawn in lobby
			end
		end
		uba.arenas[arena_name]["status"] = "edit"
	end
	uba.give_arena_items(name)
	minetest.chat_send_player(name,"*Use /uba save to enable the arena when finished building")
end

uba.copy_table = function(t)
	local nt = {}
	for k, v in pairs(t) do
		nt[k] = v
	end
	return nt
end
