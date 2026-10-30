local Diagnostics = {}

Diagnostics.version = "3.0.0"
Diagnostics.debug = false
Diagnostics.events = {}

function Diagnostics.log(message)
    local line = "[DerbyBloom] " .. tostring(message)
    table.insert(Diagnostics.events, line)
    if Diagnostics.debug then
        warn(line)
    end
end

function Diagnostics.environment()
    return {
        http = type(game.HttpGet) == "function",
        loadstring = type(loadstring) == "function",
        placeId = game.PlaceId,
        gameId = game.GameId,
    }
end

function Diagnostics.snapshot(entry, path)
    local env = Diagnostics.environment()
    return {
        loaderVersion = Diagnostics.version,
        placeId = env.placeId,
        gameId = env.gameId,
        gameName = entry and entry.name or "Unsupported Game",
        script = path or "None",
        http = env.http,
        loadstring = env.loadstring,
    }
end

return Diagnostics
