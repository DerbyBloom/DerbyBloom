# DerbyBloom Universal Loader

A lightweight universal loader for the DerbyBloom repository. It detects the current Roblox experience by `PlaceId` or `GameId`, resolves the registered script, and loads it from the repository raw URL.

## Current MM2 configuration

Murder Mystery 2 is configured to use only the no-font version:

```lua
path = "games/mm2-2.lua"
```

The loader does not perform font detection for this entry and never selects `games/mm2-1.lua`.

## Adding a game with one script

Add a `path` entry to `GAMES.PlaceIds` or `GAMES.GameIds`:

```lua
[123456789] = {
    name = "My Game",
    path = "games/my-game.lua",
},
```

Entries with `path` are loaded directly and do not check font support.

## Adding a game with two variants

Only games that explicitly define both `fonted` and `plain` use font detection and variant fallback:

```lua
[123456789] = {
    name = "My Game",
    fonted = "games/my-game-font.lua",
    plain = "games/my-game.lua",
},
```

This behavior is opt-in per game. It does not affect the MM2 entry.

## PlaceId and GameId priority

- `GAMES.PlaceIds` is used for experience-specific entries.
- `GAMES.GameIds` is used for a whole universe.
- When both match, the `PlaceId` entry has priority.

## Raw URL format

With the default repository configuration, this path:

```text
games/mm2-2.lua
```

resolves to:

```text
https://raw.githubusercontent.com/DerbyBloom/DerbyBloom/refs/heads/main/games/mm2-2.lua
```