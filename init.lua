-- global mod namespace
uba = {}

uba.mod_name = minetest.get_current_modname()
uba.mod_path = minetest.get_modpath(uba.mod_name)

local mod_name = uba.mod_name
local mod_path = uba.mod_path

local loadmodule = function(path)
	local file = io.open(path)
	if not file then
		minetest.log("error","["..mod_name.."] Unable to load "..path)
		return false
	end
	file:close()
	return dofile(path)
end

loadmodule(mod_path .. "/uba_core.lua")
loadmodule(mod_path .. "/uba_nodes.lua")
loadmodule(mod_path .. "/uba_register.lua")

uba.arenas = {}
uba.players = {}
uba.edit = {}

uba.load_arenas()

minetest.log("info","["..mod_name.."] Arenas enabled")