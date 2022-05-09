local worldpath = minetest.get_worldpath()
local gamefile = worldpath.."/api/game.json"

if table.indexof(minetest.get_dir_list(worldpath, true), "api") == -1 then
	minetest.log("[server_stats] /api/ folder not found in world dir, aborting...")
	return
end

local DATA = {}
local function update()
	local file = io.open(gamefile, "w")

	file:write(minetest.write_json(DATA, true))

	file:close()
end

ctf_api.register_on_mode_start(function()
	DATA.current_mode = {
		name = ctf_modebase.current_mode,
		matches = ctf_modebase.current_mode_matches,
	}
end)

ctf_api.register_on_new_match(function()
	DATA.current_map = {name = ctf_map.current_map.name, technical_name = ctf_map.current_map.dirname}
	DATA.current_mode.matches_played = ctf_modebase.current_mode_matches_played

	update()
end)
