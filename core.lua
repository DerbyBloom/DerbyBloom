return function(options)
    local base = options.base
    local HttpService = game:GetService("HttpService")

    local function fetch(path)
        local ok, result = pcall(function() return game:HttpGet(base .. path) end)
        if not ok or type(result) ~= "string" or #result == 0 then
            return nil, "Unable to download " .. path .. ": " .. tostring(result)
        end
        return result
    end

    local function loadModule(path)
        local source, err = fetch(path)
        if not source then return nil, err end
        local chunk, compileError = loadstring(source, "@DerbyBloom/" .. path)
        if type(chunk) ~= "function" then return nil, "Module compile error: " .. tostring(compileError) end
        local ok, result = pcall(chunk)
        if not ok then return nil, "Module runtime error: " .. tostring(result) end
        return result
    end

    local diagnostics, diagnosticsError = loadModule("loader/diagnostics.lua")
    if not diagnostics then warn("[DerbyBloom] " .. diagnosticsError) return end
    local storage, storageError = loadModule("loader/storage.lua")
    if not storage then warn("[DerbyBloom] " .. storageError) return end
    local ui, uiError = loadModule("loader/ui.lua")
    if not ui then warn("[DerbyBloom] " .. uiError) return end

    local saved = storage.load()
    local manifestSource, manifestError = fetch("manifest/games.json")
    local manifest
    if manifestSource then
        local ok, decoded = pcall(HttpService.JSONDecode, HttpService, manifestSource)
        if ok then manifest = decoded end
    end
    manifest = manifest or { loaderVersion = diagnostics.version, games = {} }
    if manifest.maintenance then
        warn("[DerbyBloom] Loader is currently under maintenance")
        return
    end

    local entry
    for _, candidate in ipairs(manifest.games or {}) do
        if candidate.enabled ~= false then
            for _, id in ipairs(candidate.placeIds or {}) do
                if tonumber(id) == tonumber(game.PlaceId) then entry = candidate break end
            end
            if not entry then
                for _, id in ipairs(candidate.gameIds or {}) do
                    if tonumber(id) == tonumber(game.GameId) then entry = candidate break end
                end
            end
        end
        if entry then break end
    end

    local context = {
        base = base,
        loaderVersion = manifest.loaderVersion or diagnostics.version,
        gameName = entry and entry.name or "Unsupported Game",
        scriptVersion = entry and entry.version or "unknown",
        announcement = manifest.announcement and manifest.announcement.enabled and manifest.announcement or nil,
        supported = entry ~= nil,
        placeId = tostring(game.PlaceId),
        gameId = tostring(game.GameId),
        storage = saved,
    }

    local function execute(entryToLoad, update)
        if type(loadstring) ~= "function" then return false, "loadstring is not available" end
        update("Downloading script...", 0.25)
        local source, err = fetch(entryToLoad.script)
        if not source then return false, err end
        update("Compiling script...", 0.65)
        local chunk, compileError = loadstring(source, "@DerbyBloom/" .. entryToLoad.script)
        if type(chunk) ~= "function" then return false, "Compile error: " .. tostring(compileError) end
        update("Launching script...", 0.85)
        local ok, runtimeError = pcall(chunk)
        if not ok then return false, "Runtime error: " .. tostring(runtimeError) end
        return true
    end

    context.onClose = function(position)
        saved.x, saved.y = position.X.Offset, position.Y.Offset
        storage.save(saved)
    end
    context.onLoad = function(update, loadButton, copyButton)
        if not entry then
            update("This game is not registered", 0, Color3.fromRGB(205, 67, 102))
            return
        end
        loadButton.Active = false
        loadButton.Text = "LOADING..."
        copyButton.Visible = false
        local ok, err = execute(entry, function(message, value)
            update(message, value, Color3.fromRGB(194, 126, 37))
        end)
        if ok then
            saved.lastScript = entry.script
            storage.save(saved)
            update("Script loaded successfully", 1, Color3.fromRGB(56, 157, 104))
            loadButton.Text = "LOADED"
            task.wait(0.45)
            local gui = loadButton:FindFirstAncestorOfClass("ScreenGui")
            if gui then gui:Destroy() end
        else
            diagnostics.log(err)
            update("Load failed - tap RETRY", 0, Color3.fromRGB(205, 67, 102))
            loadButton.Text = "RETRY"
            loadButton.Active = true
            copyButton.Visible = true
            warn("[DerbyBloom] " .. tostring(err))
        end
    end

    ui.create(context)
end
