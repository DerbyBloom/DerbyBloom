local SOURCES = {
    fonted = "https://raw.githubusercontent.com/DerbyBloom/DerbyBloom/refs/heads/main/games/mm2-1.lua",
    plain = "https://raw.githubusercontent.com/DerbyBloom/DerbyBloom/refs/heads/main/games/mm2-2.lua",
}

local MM2_PLACE_IDS = {
    [142823291] = true,
    [142823292] = true,
}

local MM2_UNIVERSE_ID = 66654135

local function warnLoader(message)
    warn("[DerbyBloom MM2 Loader] " .. tostring(message))
end

local function stop(message)
    warnLoader(message)
    return
end

local function isMM2()
    local ok, result = pcall(function()
        if MM2_PLACE_IDS[game.PlaceId] then
            return true
        end

        if game.GameId == MM2_UNIVERSE_ID then
            return true
        end

        local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
        local name = string.lower(tostring(info and info.Name or ""))
        return name:find("murder mystery 2", 1, true) ~= nil
    end)

    return ok and result == true
end

local function hasFontSupport()
    local ok, supported = pcall(function()
        if not Enum or not Enum.Font or not Enum.Font.Arcade then
            return false
        end

        if not Font or type(Font.fromEnum) ~= "function" then
            return false
        end

        local face = Font.fromEnum(Enum.Font.Arcade)
        if not face then
            return false
        end

        local label = Instance.new("TextLabel")
        label.FontFace = face
        local result = label.FontFace ~= nil
        label:Destroy()
        return result
    end)

    return ok and supported == true
end

local function isValidUrl(url)
    return type(url) == "string"
        and url ~= ""
        and not url:find("USUARIO", 1, true)
        and not url:find("REPOSITORIO", 1, true)
        and url:match("^https?://") ~= nil
end

local function downloadRaw(url)
    if not isValidUrl(url) then
        return nil, "URL raw não configurada ou ainda contém o placeholder"
    end

    local ok, result = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok or type(result) ~= "string" or #result == 0 then
        return nil, "não foi possível baixar o raw"
    end

    return result
end

local function executeRaw(source, label)
    if type(loadstring) ~= "function" then
        return false, "loadstring não está disponível neste executor"
    end

    local chunk, compileError = loadstring(source, "@DerbyBloom/" .. label)
    if type(chunk) ~= "function" then
        return false, "erro de compilação: " .. tostring(compileError)
    end

    local ok, runtimeError = pcall(chunk)
    if not ok then
        return false, "erro durante a execução: " .. tostring(runtimeError)
    end

    return true
end

if not isMM2() then
    return stop("execução cancelada: este loader só funciona no Murder Mystery 2")
end

local useFont = hasFontSupport()
local primaryUrl = useFont and SOURCES.fonted or SOURCES.plain
local primaryLabel = useFont and "com fonte" or "sem fonte"

warnLoader("MM2 confirmado; carregando variante " .. primaryLabel)

local source, downloadError = downloadRaw(primaryUrl)
if not source then
    warnLoader(downloadError)

    if useFont then
        warnLoader("tentando o raw da variante sem fonte")
        source, downloadError = downloadRaw(SOURCES.plain)
        primaryLabel = "sem fonte (fallback)"
    end
end

if not source then
    return stop(downloadError or "nenhuma fonte raw disponível")
end

local ok, executionError = executeRaw(source, primaryLabel)
if not ok then
    return stop(executionError)
end

warnLoader("script raw carregado com sucesso")
