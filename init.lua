local worldpath = minetest.get_worldpath()
local gamefile = worldpath.."/api/game.json"

local player_update_delay = 30 -- globalsteps

local timer = 0

-- data cache --

local name_mode = ''
local matches_mode = ''
local matches_played_mode = ''
local name_map = ''
local technical_name_map = ''
local start_time_map = ''

if table.indexof(minetest.get_dir_list(worldpath, true), "api") == -1 then
	minetest.log("[server_stats] /api/ folder not found in world dir, aborting...")

	return -- Comment out when testing

	minetest.mkdir(worldpath.."/api/")
end

local function get_player_list()
	local player_names = {}
	local players = minetest.get_connected_players()

	for _, player in ipairs(players) do
    	local name = player:get_player_name()
    	table.insert(player_names, name)
	end

	return minetest.write_json(player_names), table.getn(player_names)
end

local function update(data)
	local file = io.open(gamefile, "w")

	file:write(minetest.write_json(data, true))

	file:close()
end

ctf_api.register_on_new_match(function()

	local player_names, player_count = get_player_list()

	name_map = ctf_map.current_map.name
	technical_name_map = ctf_map.current_map.dirname
	start_time_map = os.time() -- Can be converted to local date here https://www.unixtimestamp.com/
	name_mode = ctf_modebase.current_mode
	matches_mode = ctf_modebase.current_mode_matches
	matches_played_mode = ctf_modebase.current_mode_matches_played

	update({
		current_mode = {
			name = name_mode,
			matches = matches_mode,
			matches_played = matches_played_mode,
		},
		current_map = {
			name = name_map,
			technical_name = technical_name_map,
			start_time = start_time_map, 
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
				name = name_mode,
				matches = matches_mode,
				matches_played = matches_played_mode,
			},
			current_map = {
				name = name_map,
				technical_name = technical_name_map,
				start_time = start_time_map, 
			},
			player_info = {
				players = player_names,
				count = player_count
			},
		})
        timer = 0
    end
end)



