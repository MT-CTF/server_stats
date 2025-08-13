local worldpath = minetest.get_worldpath()
local gamefile = worldpath .. "/api/game.json"

local http = minetest.request_http_api()

local cache = {}

if table.indexof(minetest.get_dir_list(worldpath, true), "api") == -1 then
	minetest.log("[server_stats] /api/ folder not found in world dir, aborting...")

	return -- Comment out when testing

		minetest.mkdir(worldpath .. "/api/")
end

local function get_player_list()
	local player_names = {}
	for _, player in ipairs(minetest.get_connected_players()) do
		if not core.check_player_privs(player, {spectate = true}) then
			table.insert(player_names, player:get_player_name())
		end
	end
	return player_names, #player_names
end

local function update(data)
	local file = io.open(gamefile, "w")

	file:write(minetest.write_json(data, true))

	if http then
		http.fetch_async({
			url = "http://localhost:80/api",
			timeout = 10,
			method = "PUT",
			extra_headers = { "Content-Type: application/json" },
			data = minetest.write_json(data),
		})
	end

	file:close()
end

ctf_api.register_on_new_match(function()
	cache.current_map = {
		name = ctf_map.current_map.name,
		technical_name = ctf_map.current_map.dirname,
		start_time = os.time(), -- Can be converted to local date here https://www.unixtimestamp.com/
	}
	cache.current_mode = {
		name = ctf_modebase.current_mode,
		matches = ctf_modebase.current_mode_matches,
		matches_played = ctf_modebase.current_mode_matches_played,
	}
	update(cache)
end)

minetest.register_on_joinplayer(function()
	local player_names, player_count = get_player_list()
	cache.player_info = {
		players = player_names,
		count = player_count
	}
	update(cache)
end)

minetest.register_on_leaveplayer(function()
	minetest.after(0, function()
		local player_names, player_count = get_player_list()
		cache.player_info = {
			players = player_names,
			count = player_count
		}
		update(cache)
	end)
end)

minetest.register_on_shutdown(function()
	cache = {
		error = 1,
		error_message = "Server has shut down (or is restarting). Try again later",
	}

	update(cache)
end)
