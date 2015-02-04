
minetest.register_privilege("uba", "Player can manage uba arenas.")

minetest.register_chatcommand("uba", {
	params = "<cmd> <arena_name>",
	description = "Send text to chat",
	func = function(name,params)
		local cmd = string.split(params," ")
		
		if cmd[1] then
			if cmd[1] == "join" then
				if cmd[2] and uba.arena_exists(cmd[2]) then
					uba.join_game(cmd[2],name)
				else
					minetest.chat_send_player(name,"*Unknown arena !")
				end
			elseif cmd[1] == "vote" then
				local arena_name = uba.players[name]
				uba.vote(arena_name,name)
			elseif cmd[1] == "leave" then
				if uba.players[name] then -- player is in arena
					local player = minetest.get_player_by_name(name)
					player:set_hp(0) -- kill player
				end
			elseif cmd[1] == "disable" then
				if not minetest.check_player_privs(name, {uba=true}) then
					minetest.chat_send_player(name,"*You don't have the privilege to do this !")
				elseif not cmd[2] or not uba.arena_exists(cmd[2]) then
					minetest.chat_send_player(name,"*Unknown arena !")
				else 
					uba.disable_arena(cmd[2],name)
				end
			elseif cmd[1] == "new" then
				if not minetest.check_player_privs(name, {uba=true}) then
					minetest.chat_send_player(name,"*You don't have the privilege to do this !")
				elseif not cmd[2] then
					minetest.chat_send_player(name,"*The new arena needs a name")
				else
					uba.initiate(cmd[2],name)
				end
			elseif cmd[1] == "edit" then
				if not minetest.check_player_privs(name, {uba=true}) then
					minetest.chat_send_player(name,"*You don't have the privilege to do this !")
				elseif not cmd[2] or not uba.arena_exists(cmd[2]) then
				minetest.chat_send_player(name,"*Unknown arena !")
				else 
					uba.edit_arena(cmd[2],name)
				end
			elseif cmd[1] == "save" then
				if not minetest.check_player_privs(name, {uba=true}) then
					minetest.chat_send_player(name,"*You don't have the privilege to do this !")
				else 
					uba.save_arena(name)
				end
			end
		end
		return true
	end,
})