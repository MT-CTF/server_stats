local OUTFILE = "/tmp/ctf_out"

local cache = {}

local function get_player_list()
	local player_names = {}
	for _, player in ipairs(core.get_connected_players()) do
		if not core.check_player_privs(player, {spectate = true}) then
			table.insert(player_names, player:get_player_name())
		end
	end
	return player_names, #player_names
end

local unsafe = core.request_insecure_environment()
local function update(data)
	if unsafe.core.path_exists(OUTFILE) then
		unsafe.core.safe_file_write(OUTFILE, core.write_json(data, true))
	end
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

core.register_on_joinplayer(function()
	local player_names, player_count = get_player_list()
	cache.player_info = {
		players = player_names,
		count = player_count
	}
	update(cache)
end)

core.register_on_leaveplayer(function()
	core.after(0, function()
		local player_names, player_count = get_player_list()
		cache.player_info = {
			players = player_names,
			count = player_count
		}
		update(cache)
	end)
end)

core.register_on_shutdown(function()
	cache = {
		error = 1,
		error_message = "Server has shut down (or is restarting). Try again later",
	}

	update(cache)
end)
