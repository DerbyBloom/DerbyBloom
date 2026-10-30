-- DerbyBloom Loader v3 bootstrap
-- This file only loads the modular core.

local OWNER = "DerbyBloom"
local REPOSITORY = "DerbyBloom"
local BRANCH = "main"
local BASE = string.format("https://raw.githubusercontent.com/%s/%s/refs/heads/%s/", OWNER, REPOSITORY, BRANCH)

local function loadRemote(path)
    local source = game:HttpGet(BASE .. path)
    local chunk, compileError = loadstring(source, "@DerbyBloom/" .. path)
    assert(type(chunk) == "function", compileError)
    return chunk
end

local ok, err = pcall(function()
    loadRemote("loader/core.lua")({ base = BASE })
end)

if not ok then
    warn("[DerbyBloom] Bootstrap failed: " .. tostring(err))
end
