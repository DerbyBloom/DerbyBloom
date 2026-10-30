# Manifest

`games.json` is the remote registry consumed by `loader/core.lua`.

The MM2 entry intentionally uses a single `script` property pointing to `games/mm2-2.lua`. Do not add font detection to the global core; alternate variants must be explicit in the individual entry and implemented only if a future game needs them.
