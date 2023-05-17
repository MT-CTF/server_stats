local worldpath = minetest.get_worldpath()
local gamefile = worldpath.."/api/game.json"

local player_update_delay = 30 -- globalsteps

local timer = 0

-- data cache --

local cache = {}

if table.indexof(minetest.get_dir_list(worldpath, true), "api") == -1 then
	minetest.log("[server_stats] /api/ folder not found in world dir, aborting...")

	return -- Comment out when testing

	minetest.mkdir(worldpath.."/api/")
end

local function get_player_list()
	local player_names = {}
	for _, player in ipairs(minetest.get_connected_players()) do
    	table.insert(player_names, player:get_player_name())
	end
	return player_names, #player_names
end

local function update(data)
	local file = io.open(gamefile, "w")

	file:write(minetest.write_json(data, true))

	file:close()
end

ctf_api.register_on_new_match(function()
	local player_names, player_count = get_player_list()
	cache[0] = ctf_modebase.current_mode
	cache[1] = ctf_modebase.current_mode_matches
	cache[2] = ctf_modebase.current_mode_matches_played
	cache[3] = ctf_map.current_map.name
	cache[4] = ctf_map.current_map.dirname
	cache[5] = os.time() -- Can be converted to local date here https://www.unixtimestamp.com/
	update({
		current_mode = {
			name = cache[0],
			matches = cache[1],
			matches_played = cache[2],
		},
		current_map = {
			name = cache[3],
			technical_name = cache[4],
			start_time = cache[5], 
		},
		player_info = {
			players = player_names,
			count = player_count
		},
	})
end)

minetest.register_globalstep(function(dtime)
    -- Add the elapsed time to the timer
    timer = timer + dtime
    
    if timer >= player_update_delay then
		local player_names, player_count = get_player_list()
        update({
			current_mode = {
				name = cache[0],
				matches = cache[1],
				matches_played = cache[2],
			},
			current_map = {
				name = cache[3],
				technical_name = cache[4],
				start_time = cache[5], 
			},
			player_info = {
				players = player_names,
				count = player_count
			},
		})
        timer = 0
    end
end)



