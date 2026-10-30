# DerbyBloom Loader v3

A modular, manifest-driven loader for DerbyBloom.

## Architecture

```text
main.lua                 Minimal bootstrap
loader/core.lua          Manifest, game detection and execution
loader/ui.lua            Pink/white responsive draggable UI
loader/storage.lua       Optional local preferences
loader/diagnostics.lua   Environment and debug diagnostics
manifest/games.json      Remote game registry
```

## Current MM2 setup

Murder Mystery 2 uses only the no-font script:

```json
"script": "games/mm2-2.lua"
```

There is no font detection or font fallback for MM2.

## Add a game

Edit `manifest/games.json`:

```json
{
  "id": "my-game",
  "name": "My Game",
  "version": "1.0.0",
  "enabled": true,
  "placeIds": [123456789],
  "gameIds": [],
  "script": "games/my-game.lua"
}
```

The core gives `PlaceId` priority over `GameId` when both match different entries.

## Manifest controls

- `maintenance`: stops the loader before creating the UI.
- `announcement`: reserved for a future announcement panel.
- `enabled`: disables a game entry without deleting it.
- `version`: shown in the UI.

## Deployment

1. Keep the directory structure unchanged in the `DerbyBloom/DerbyBloom` repository.
2. Commit `main.lua`, `loader/`, and `manifest/` to the `main` branch.
3. Run the public bootstrap:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/DerbyBloom/DerbyBloom/refs/heads/main/main.lua"))()
```

## Design rules

- Do not collect HWID, username, JobId, or other telemetry without explicit user-facing disclosure and consent.
- Use `path`/`script` for games with one implementation.
- Keep alternate variants opt-in and local to the game entry.
- Keep the bootstrap small so the modular files can evolve independently.
