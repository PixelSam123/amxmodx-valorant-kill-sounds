# Amx Mod X Valorant Kill Sounds.

This addon plays Valorant kill sounds for your Counter Strike 1.6 server.

Caches sound files using `precache_sound`.

After the round ends, `round_start` resets the counter for each player and `.wav` starts the counter from zero for the audio file.

## SOUND FILE WARNING

The `.wav` files supplied are placeholder empty files to avoid copyright issues!  
Please supply your own sound files.

## Kill Sound Variations

Sounds are stored under `cstrike/sound/alazul/<variation>/kill<count>.wav` where `<count>` is `1`–`5` (5+ kills reuses `kill5.wav`).

All variations are precached via a loop over the variation array (`alazul/<variation>/kill<1..5>.wav`).

## Player Commands

Players can choose their kill sound variation in-game via chat:

- `.killsound`
- `.ks` (short alias)

Both `say` and `say_team` are supported (case-sensitive).

Typing either command opens a numeric select menu:

```
Select Kill Sound:
1. Default [Selected]
2. Variation 2
3. ...
```

Selection is per-player, in-memory only, and defaults to `default` when a player joins. When a dead player spectates someone (`IN_EYE` / `CHASE_LOCKED` / `CHASE_FREE`), the kill sound played uses the **spectated player's** setting.

## Credits

Credits to Alazul, the original repository creator.
