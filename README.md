# server_stats

If the file `/tmp/ctf_out` exists this mod will write some basic server data to it (in json format) like the current map/match, players online, etc

`/tmp/ctf_out` is created and read from by CTF's website app, using mkfifo