#include <amxmodx>
#include <amxmisc>

#define PLUGIN "Valorant Kill Sounds"
#define VERSION "1.0"
#define AUTHOR "Alazul"

#define MAX_KILLS 5

new g_iKills[MAX_PLAYERS + 1]

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    register_event("DeathMsg", "newkill", "a")
    register_event("HLTV", "round_start", "a", "1=0") 
}

public plugin_precache()
{
    // Caching audio files
    precache_sound("alazul/kill1.wav")
    precache_sound("alazul/kill2.wav")
    precache_sound("alazul/kill3.wav")
    precache_sound("alazul/kill4.wav")
    precache_sound("alazul/kill5.wav")
}

public newkill()
{
    new killer = read_data(1)
    new victim = read_data(2)

    // Check if you are a valid player
    if (!is_user_connected(killer) || !is_user_connected(victim)) return

    // Reset dead player's kill counter
    g_iKills[victim] = 0

    if (killer == victim) return

    g_iKills[killer]++

    // Delay so the streak sound doesn't get cut off by the victim's
    // death sound playing on the same CHAN_VOICE channel.
    // Using killer as the task id replaces any pending task, so rapid
    // multi-kills only play the latest streak sound.
    set_task(0.3, "play_kill_sound", killer)
}

public play_kill_sound(killer)
{
    if (!is_user_connected(killer)) return

    new soundfile[64]
    // Create the audio file name
    format(soundfile, charsmax(soundfile), "alazul/kill%d.wav", min(g_iKills[killer], MAX_KILLS))

    // Play the audio file
    client_cmd(killer, "spk %s", soundfile)
}

public round_start()
{
    // Reset the kill counter for each player
    for (new id = 1; id <= MAX_PLAYERS; id++)
    {
        g_iKills[id] = 0
    }
}

public client_disconnected(id)
{
    g_iKills[id] = 0
}
