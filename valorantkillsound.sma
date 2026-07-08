#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

#define PLUGIN "Valorant Kill Sounds"
#define VERSION "1.0"
#define AUTHOR "Alazul"

#define MAX_KILLS 5

// Counter-Strike observer modes (pev_iuser1). These differ from the
// HLSDK constants in hlsdk_const.inc, which are the Half-Life values.
#define CS_OBS_IN_EYE       4
#define CS_OBS_CHASE_LOCKED 5
#define CS_OBS_CHASE_FREE   6

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
    set_task(0.1, "play_kill_sound", killer)
}

// Returns the player being spectated by `id`, or 0 if `id` is not following
// a specific player (alive, free-roaming, or in death/free cam).
get_spectator_target(id)
{
    if (is_user_alive(id)) return 0

    new mode = pev(id, pev_iuser1)
    if (mode != CS_OBS_IN_EYE && mode != CS_OBS_CHASE_LOCKED && mode != CS_OBS_CHASE_FREE)
        return 0

    return pev(id, pev_iuser2)
}

public play_kill_sound(killer)
{
    if (!is_user_connected(killer)) return

    new soundfile[64]
    // Create the audio file name
    format(soundfile, charsmax(soundfile), "alazul/kill%d.wav", min(g_iKills[killer], MAX_KILLS))

    // Play the audio file to the killer and to anyone spectating them.
    for (new id = 1; id <= MAX_PLAYERS; id++)
    {
        if (!is_user_connected(id)) continue
        if (id != killer && get_spectator_target(id) != killer) continue

        client_cmd(id, "spk %s", soundfile)
    }
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
