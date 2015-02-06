
minetest.register_privilege("uba", "Player can manage uba arenas.")

minetest.register_chatcommand("uba", {
	params = "<cmd> <arena_name> or additem <arena_name> <itemstring> <count> or rmitem <arena_name> <itemstring>",
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
				if not arena_name then
					minetest.chat_send_player(name,"*You are not in an arena")
					return
				end
				uba.vote(arena_name,name)
			elseif cmd[1] == "leave" then
				if uba.players[name] then -- player is in arena
					local player = minetest.get_player_by_name(name)
					player:set_hp(0) -- kill player
				else
					minetest.chat_send_player(name,"*You have not joined any game")
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
					local arena_name = uba.sanitize_string(cmd[2])
					uba.initiate(arena_name,name)
				end
			elseif cmd[1] == "edit" then
				if not minetest.check_player_privs(name, {uba=true}) then
					minetest.chat_send_player(name,"*You don't have the privilege to do this !")
				elseif not cmd[2] then
					minetest.chat_send_player(name,"*Missing arena name!")
				else 
					uba.edit_arena(cmd[2],name)
				end
			elseif cmd[1] == "save" then
				if not minetest.check_player_privs(name, {uba=true}) then
					minetest.chat_send_player(name,"*You don't have the privilege to do this !")
				else 
					uba.save_arena(name)
				end
			elseif cmd[1] == "list" then
					uba.list_arenas(name)
			elseif cmd[1] == "additem" then
				if not minetest.check_player_privs(name, {uba=true}) then
					minetest.chat_send_player(name,"*You don't have the privilege to do this !")
				elseif not cmd[2] or not cmd[3] or not cmd[4] then
					minetest.chat_send_player(name,"*Missing parameters")
				elseif not uba.arena_exists(cmd[2]) then
					minetest.chat_send_player(name,"*Unknown arena !")
				elseif not tonumber(cmd[4]) or tonumber(cmd[4]) < 0 then
					minetest.chat_send_player(name,"*Count is not a valid number")
				else
					uba.add_item_conf(cmd[2],name,cmd[3],cmd[4]) -- arena_name,name,itemstring,count
				end
			elseif cmd[1] == "rmitem" then
				if not minetest.check_player_privs(name, {uba=true}) then
					minetest.chat_send_player(name,"*You don't have the privilege to do this !")
				elseif not cmd[2] or not cmd[3] then
					minetest.chat_send_player(name,"*Missing parameters")
				elseif not uba.arena_exists(cmd[2]) then
					minetest.chat_send_player(name,"*Unknown arena !")
				else 
					uba.remove_item_conf(cmd[2],name,cmd[3]) -- arena_name,name,itemstring
				end
			end
		end
		return true
	end,
})

minetest.register_on_dieplayer(function(player)
	local name = player:get_player_name()
	uba.player_died(name)
end)