local Storage = {}

local FILE = "derbybloom_loader_v3.json"
local HttpService = game:GetService("HttpService")

function Storage.load()
    local result = {}
    pcall(function()
        if type(readfile) == "function" then
            local raw = readfile(FILE)
            result = HttpService:JSONDecode(raw) or {}
        end
    end)
    return result
end

function Storage.save(data)
    pcall(function()
        if type(writefile) == "function" then
            writefile(FILE, HttpService:JSONEncode(data or {}))
        end
    end)
end

return Storage
