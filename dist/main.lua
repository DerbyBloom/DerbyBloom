local SCRIPTS = {
    {
        name = "Murderer Mystery 2",
        placeIds = { 142823291 },
        raw = "https://raw.githubusercontent.com/DerbyBloom/DerbyBloom/refs/heads/main/dist/init.lua",
    },
}

local function notify(message)
    warn("[DerbyBloom Loader] " .. tostring(message))
end

local function findScriptForPlace(placeId)
    for _, entry in ipairs(SCRIPTS) do
        if type(entry) == "table" and type(entry.placeIds) == "table" then
            for _, id in ipairs(entry.placeIds) do
                if tonumber(id) == tonumber(placeId) then
                    return entry
                end
            end
        end
    end
    return nil
end

local function getRaw(url)
    local ok, result = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok or type(result) ~= "string" or #result == 0 then
        return nil, "não foi possível baixar o raw"
    end

    return result
end

local function executeScript(entry, source)
    if type(loadstring) ~= "function" then
        return false, "loadstring não está disponível neste executor"
    end

    local chunk, compileError = loadstring(source, "@DerbyBloomLoader/" .. tostring(entry.name or "script"))
    if type(chunk) ~= "function" then
        return false, "erro de compilação: " .. tostring(compileError)
    end

    local ok, runtimeError = pcall(chunk)
    if not ok then
        return false, "erro durante a execução: " .. tostring(runtimeError)
    end

    return true
end

local placeId = game.PlaceId
local entry = findScriptForPlace(placeId)

if not entry then
    notify("nenhum script cadastrado para o PlaceId " .. tostring(placeId))
    return
end

if type(entry.raw) ~= "string" or entry.raw == "" or entry.raw:find("COLOQUE", 1, true) then
    notify("o script '" .. tostring(entry.name or "sem nome") .. "' ainda não possui uma URL raw válida")
    return
end

notify("jogo reconhecido: " .. tostring(entry.name or "sem nome") .. " | PlaceId: " .. tostring(placeId))
notify("baixando script...")

local source, downloadError = getRaw(entry.raw)
if not source then
    notify(downloadError)
    return
end

local ok, executionError = executeScript(entry, source)
if not ok then
    notify(executionError)
    return
end

notify("script carregado com sucesso")
