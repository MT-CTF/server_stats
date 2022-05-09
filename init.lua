local worldpath = minetest.get_worldpath()
local gamefile = worldpath.."/api/game.json"

if table.indexof(minetest.get_dir_list(worldpath, true), "api") == -1 then
	minetest.log("[server_stats] /api/ folder not found in world dir, aborting...")

	return -- Comment out when testing

	minetest.mkdir(worldpath.."/api/")
end

local function update(data)
	local file = io.open(gamefile, "w")

	file:write(minetest.write_json(data, true))

	file:close()
end

ctf_api.register_on_new_match(function()
	update({
		current_mode = {
			name = ctf_modebase.current_mode,
			matches = ctf_modebase.current_mode_matches,
			matches_played = ctf_modebase.current_mode_matches_played,
		},
		current_map = {
			name = ctf_map.current_map.name,
			technical_name = ctf_map.current_map.dirname,
			start_time = os.time(), -- Can be converted to local date here https://www.unixtimestamp.com/
		},
	})
end)
