#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

#define PLUGIN "Valorant Kill Sounds"
#define VERSION "1.0"
#define AUTHOR "Alazul"

// Counter-Strike observer modes (pev_iuser1). These differ from the
// HLSDK constants in hlsdk_const.inc, which are the Half-Life values.
#define CS_OBS_IN_EYE       4
#define CS_OBS_CHASE_LOCKED 5
#define CS_OBS_CHASE_FREE   6

#define MAX_KILLS 5
#define NUM_VARIATIONS 6

new const g_szVariations[NUM_VARIATIONS][] = { "default", "aeris", "neofrontier", "kuronami", "reaver", "mystbloom" }
new const g_szVariationDisplay[NUM_VARIATIONS][] = { "Default", "Aeris", "Neo Frontier", "Kuronami", "Reaver", "Mystbloom" }

new g_iKills[MAX_PLAYERS + 1]
new g_iVariation[MAX_PLAYERS + 1]

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    register_event("DeathMsg", "newkill", "a")
    register_event("HLTV", "round_start", "a", "1=0")

    register_clcmd("say .killsound", "cmd_killsound")
    register_clcmd("say_team .killsound", "cmd_killsound")
    register_clcmd("say .ks", "cmd_killsound")
    register_clcmd("say_team .ks", "cmd_killsound")
}

public plugin_precache()
{
    new soundfile[64]
    for (new v = 0; v < NUM_VARIATIONS; v++)
    {
        for (new i = 1; i <= MAX_KILLS; i++)
        {
            formatex(soundfile, charsmax(soundfile), "alazul/%s/kill%d.wav", g_szVariations[v], i)
            precache_sound(soundfile)
        }
    }
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
    set_task(0.08, "play_kill_sound", killer)
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
    // Sound file picked is the killer's variation preference.
    formatex(
        soundfile, charsmax(soundfile),
        "alazul/%s/kill%d.wav",
        g_szVariations[g_iVariation[killer]], min(g_iKills[killer], MAX_KILLS)
    )

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

public client_putinserver(id)
{
    g_iKills[id] = 0
    g_iVariation[id] = 0 // default
}

public client_disconnected(id)
{
    g_iKills[id] = 0
    g_iVariation[id] = 0
}

public cmd_killsound(id)
{
    show_killsound_menu(id)
    return PLUGIN_HANDLED
}

show_killsound_menu(id)
{
    new menu = menu_create("\ySelect Kill Sound:", "killsound_menu_handler")
    new itemName[32]
    for (new v = 0; v < NUM_VARIATIONS; v++)
    {
        // Mark current selection
        if (v == g_iVariation[id])
            formatex(itemName, charsmax(itemName), "%s \r[Selected]", g_szVariationDisplay[v])
        else
            formatex(itemName, charsmax(itemName), "%s", g_szVariationDisplay[v])
        menu_additem(menu, itemName)
    }
    menu_display(id, menu, 0)
}

public killsound_menu_handler(id, menu, item)
{
    if (item == MENU_EXIT)
    {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }

    if (item < 0 || item >= NUM_VARIATIONS)
    {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }

    g_iVariation[id] = item
    client_print(id, print_chat, "[KillSound] Kill sound set to: %s", g_szVariationDisplay[item])

    menu_destroy(menu)
    return PLUGIN_HANDLED
}
