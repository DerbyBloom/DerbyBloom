-- DerbyBloom Universal Loader v2.0.0
-- Add games by editing the GAMES table.
-- Entries with `path` do not perform font detection.
-- The current MM2 entry uses only the no-font variant: games/mm2-2.lua.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local CONFIG = {
    Owner = "DerbyBloom",
    Repository = "DerbyBloom",
    Branch = "main",
    Version = "2.0.0",
    Icon = "rbxassetid://92813401609681",
}

local COLORS = {
    card = Color3.fromRGB(255, 248, 252),
    cardSoft = Color3.fromRGB(255, 238, 247),
    pink = Color3.fromRGB(232, 92, 157),
    pinkLight = Color3.fromRGB(255, 170, 207),
    pinkDark = Color3.fromRGB(139, 43, 91),
    white = Color3.fromRGB(255, 255, 255),
    text = Color3.fromRGB(91, 35, 65),
    muted = Color3.fromRGB(158, 106, 132),
    success = Color3.fromRGB(56, 157, 104),
    warning = Color3.fromRGB(194, 126, 37),
    error = Color3.fromRGB(205, 67, 102),
}

local GAMES = {
    PlaceIds = {
        [142823291] = {
            name = "Murder Mystery 2",
            path = "games/mm2-2.lua",
        },
        [142823292] = {
            name = "Murder Mystery 2",
            path = "games/mm2-2.lua",
        },
    },
    GameIds = {
        [66654135] = {
            name = "Murder Mystery 2",
            path = "games/mm2-2.lua",
        },
        -- Single-script game: no font detection.
        -- [123456789] = { name = "Meu Jogo", path = "games/meu-jogo.lua" },
        -- For an optional two-variant game, define fonted/plain only in that entry.
    },
}

local function rawUrl(path)
    return string.format("https://raw.githubusercontent.com/%s/%s/refs/heads/%s/%s", CONFIG.Owner, CONFIG.Repository, CONFIG.Branch, path)
end

local function getEntry()
    return GAMES.PlaceIds[game.PlaceId] or GAMES.GameIds[game.GameId]
end

local CurrentGame = getEntry()
local PlaceId = tostring(game.PlaceId)
local GameId = tostring(game.GameId)

local function notify(message)
    warn("[DerbyBloom Loader] " .. tostring(message))
end

local function safeCall(fn, ...)
    local ok, result = pcall(fn, ...)
    return ok, result
end

local function destroyOldGui()
    for _, parent in ipairs({ CoreGui, PlayerGui }) do
        local old = parent:FindFirstChild("DerbyBloomLoader")
        if old then old:Destroy() end
    end
end

destroyOldGui()

local LoaderGui = Instance.new("ScreenGui")
LoaderGui.Name = "DerbyBloomLoader"
LoaderGui.ResetOnSpawn = false
LoaderGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
LoaderGui.DisplayOrder = 999
local parented = pcall(function() LoaderGui.Parent = CoreGui end)
if not parented then LoaderGui.Parent = PlayerGui end

local function new(className, props, parent)
    local object = Instance.new(className)
    for key, value in pairs(props or {}) do object[key] = value end
    object.Parent = parent
    return object
end

local function corner(parent, radius)
    return new("UICorner", { CornerRadius = UDim.new(0, radius) }, parent)
end

local function stroke(parent, color, thickness)
    return new("UIStroke", { Color = color, Thickness = thickness or 1 }, parent)
end

local function animate(object, duration, props, style, direction)
    local info = TweenInfo.new(duration, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
    local result = TweenService:Create(object, info, props)
    result:Play()
    return result
end

-- Preferências locais: funcionam quando o executor expõe readfile/writefile.
local PREF_FILE = "derbybloom_loader.json"
local prefs = {}
local function loadPrefs()
    pcall(function()
        if type(readfile) == "function" then
            local content = readfile(PREF_FILE)
            prefs = HttpService:JSONDecode(content) or {}
        end
    end)
end
local function savePrefs()
    pcall(function()
        if type(writefile) == "function" then
            writefile(PREF_FILE, HttpService:JSONEncode(prefs))
        end
    end)
end
loadPrefs()

local Backdrop = new("Frame", {
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.fromScale(1, 1),
    Active = false,
}, LoaderGui)

local Card = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 1.3),
    Size = UDim2.fromOffset(560, 360),
    BackgroundColor3 = COLORS.card,
    BorderSizePixel = 0,
}, LoaderGui)
corner(Card, 18)
stroke(Card, COLORS.pinkLight, 2)
new("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, COLORS.white),
        ColorSequenceKeypoint.new(1, COLORS.cardSoft),
    }),
    Rotation = 90,
}, Card)
local CardScale = new("UIScale", { Scale = 1 }, Card)
new("UIPadding", {
    PaddingTop = UDim.new(0, 18), PaddingBottom = UDim.new(0, 18),
    PaddingLeft = UDim.new(0, 22), PaddingRight = UDim.new(0, 22),
}, Card)

local Icon = new("ImageLabel", {
    AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 0),
    Size = UDim2.fromOffset(58, 58), BackgroundColor3 = COLORS.pinkLight,
    BackgroundTransparency = 0.15, BorderSizePixel = 0, Image = CONFIG.Icon,
    ImageColor3 = COLORS.white, ScaleType = Enum.ScaleType.Fit,
}, Card)
corner(Icon, 16)
stroke(Icon, COLORS.pink, 1.5)

local Title = new("TextLabel", {
    BackgroundTransparency = 1, Active = true, Position = UDim2.new(0, 0, 0, 66),
    Size = UDim2.new(1, 0, 0, 34), Font = Enum.Font.GothamBold,
    Text = "DerbyBloom", TextColor3 = COLORS.pinkDark, TextSize = 25,
}, Card)
local Subtitle = new("TextLabel", {
    BackgroundTransparency = 1, TextWrapped = false, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.new(0, 0, 0, 105),
    Size = UDim2.new(1, 0, 0, 24), Font = Enum.Font.Gotham,
    Text = CurrentGame and CurrentGame.name or "Unsupported Game",
    TextColor3 = COLORS.muted, TextSize = 14,
}, Card)
local VersionLabel = new("TextLabel", {
    BackgroundTransparency = 1, TextWrapped = false, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.new(0, 0, 0, 126),
    Size = UDim2.new(1, 0, 0, 16), Font = Enum.Font.Code,
    Text = "Loader v" .. CONFIG.Version, TextColor3 = COLORS.muted, TextSize = 10,
}, Card)
local Status = new("TextLabel", {
    BackgroundTransparency = 1, TextWrapped = false, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.new(0, 0, 0, 150),
    Size = UDim2.new(1, 0, 0, 22), Font = Enum.Font.Gotham,
    Text = CurrentGame and "Ready to load" or "This game is not registered",
    TextColor3 = CurrentGame and COLORS.success or COLORS.error, TextSize = 13,
}, Card)
local GameInfo = new("TextLabel", {
    BackgroundTransparency = 1, TextWrapped = false, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.new(0, 0, 0, 178),
    Size = UDim2.new(1, 0, 0, 18), Font = Enum.Font.Code,
    Text = "PlaceId: " .. PlaceId .. "  |  GameId: " .. GameId,
    TextColor3 = COLORS.muted, TextSize = 11,
}, Card)

local ProgressBack = new("Frame", {
    Position = UDim2.new(0, 0, 0, 207), Size = UDim2.new(1, 0, 0, 6),
    BackgroundColor3 = COLORS.pinkLight, BackgroundTransparency = 0.55, BorderSizePixel = 0,
}, Card)
corner(ProgressBack, 4)
local ProgressFill = new("Frame", {
    Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = COLORS.pink, BorderSizePixel = 0,
}, ProgressBack)
corner(ProgressFill, 4)

local LoadButton = new("TextButton", {
    AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 1, -55),
    Size = UDim2.new(0.72, 0, 0, 40), AutoButtonColor = false,
    BackgroundColor3 = CurrentGame and COLORS.pink or Color3.fromRGB(190, 175, 184),
    Font = Enum.Font.GothamBold, Text = CurrentGame and "LOAD SCRIPT" or "UNSUPPORTED",
    TextColor3 = COLORS.white, TextSize = 14,
}, Card)
corner(LoadButton, 10)
stroke(LoadButton, COLORS.pinkDark, 1)

local CopyButton = new("TextButton", {
    AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 1, -8),
    Size = UDim2.new(0.52, 0, 0, 24), AutoButtonColor = false,
    BackgroundTransparency = 1, Font = Enum.Font.Gotham,
    Text = "COPY GAME IDS", TextColor3 = COLORS.pinkDark, TextSize = 11,
}, Card)
local CloseButton = new("TextButton", {
    AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0),
    Size = UDim2.fromOffset(28, 28), BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold, Text = "×", TextColor3 = COLORS.pinkDark, TextSize = 22,
}, Card)

local function setProgress(value, message, color)
    ProgressFill.Size = UDim2.new(math.clamp(value, 0, 1), 0, 1, 0)
    if message then Status.Text = message end
    if color then Status.TextColor3 = color end
end

local function copyText(value)
    if type(setclipboard) == "function" then
        local ok = pcall(setclipboard, value)
        return ok
    end
    if type(toclipboard) == "function" then
        local ok = pcall(toclipboard, value)
        return ok
    end
    return false
end

CopyButton.MouseButton1Click:Connect(function()
    local value = "PlaceId: " .. PlaceId .. " | GameId: " .. GameId
    if copyText(value) then
        CopyButton.Text = "COPIED"
        task.delay(1.4, function() if CopyButton.Parent then CopyButton.Text = "COPY GAME IDS" end end)
    else
        CopyButton.Text = "COPY NOT SUPPORTED"
        notify(value)
    end
end)

-- Barra superior inteira arrastável, compatível com mouse e toque.
local dragging, dragStart, startPosition = false, nil, nil
local function beginDrag(input)
    local mouse = input.UserInputType == Enum.UserInputType.MouseButton1
    local touch = input.UserInputType == Enum.UserInputType.Touch
    if not mouse and not touch then return end
    dragging, dragStart, startPosition = true, input.Position, Card.Position
    input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then dragging = false end
    end)
end
Title.InputBegan:Connect(beginDrag)
Icon.InputBegan:Connect(beginDrag)
UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    local mouse = input.UserInputType == Enum.UserInputType.MouseMovement
    local touch = input.UserInputType == Enum.UserInputType.Touch
    if not mouse and not touch then return end
    local delta = input.Position - dragStart
    Card.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
    prefs.x, prefs.y = Card.Position.X.Offset, Card.Position.Y.Offset
end)

CloseButton.MouseButton1Click:Connect(function()
    prefs.x, prefs.y = Card.Position.X.Offset, Card.Position.Y.Offset
    savePrefs()
    LoaderGui:Destroy()
end)

-- Ajuste automático para celular e telas estreitas.
local function fitToScreen()
    local camera = workspace.CurrentCamera
    if not camera then return end
    local viewport = camera.ViewportSize
    local narrow = viewport.X < 700 or viewport.Y < 500
    CardScale.Scale = narrow and 0.82 or 1
    Card.Size = narrow and UDim2.fromOffset(430, 390) or UDim2.fromOffset(560, 360)
    LoadButton.Size = narrow and UDim2.new(0.84, 0, 0, 46) or UDim2.new(0.72, 0, 0, 42)
end
fitToScreen()
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fitToScreen) end

if type(prefs.x) == "number" and type(prefs.y) == "number" then
    Card.Position = UDim2.new(0.5, prefs.x, 0.5, prefs.y)
end

local function hasFontSupport()
    local ok = pcall(function()
        assert(Enum.Font.Arcade)
        assert(Font and type(Font.fromEnum) == "function")
        local label = Instance.new("TextLabel")
        label.FontFace = Font.fromEnum(Enum.Font.Arcade)
        assert(label.FontFace ~= nil)
        label:Destroy()
    end)
    return ok
end

local function getCandidates(entry)
    -- Esta é a regra importante: `path` não testa fonte e não tem fallback de fonte.
    if entry.path then return { { path = entry.path, label = "script" } } end
    local candidates = {}
    if entry.fonted and entry.plain then
        if hasFontSupport() then
            table.insert(candidates, { path = entry.fonted, label = "with font" })
            table.insert(candidates, { path = entry.plain, label = "without font (fallback)" })
        else
            table.insert(candidates, { path = entry.plain, label = "without font" })
            table.insert(candidates, { path = entry.fonted, label = "with font (fallback)" })
        end
    elseif entry.fonted or entry.plain then
        table.insert(candidates, { path = entry.fonted or entry.plain, label = "script" })
    end
    return candidates
end

local function loadCandidate(candidate)
    local url = rawUrl(candidate.path)
    local sourceOk, source = pcall(function() return game:HttpGet(url) end)
    if not sourceOk or type(source) ~= "string" or #source == 0 then
        return false, "download failed: " .. tostring(source)
    end
    if type(loadstring) ~= "function" then return false, "loadstring is not available" end
    local chunk, compileError = loadstring(source, "@DerbyBloom/" .. candidate.path)
    if type(chunk) ~= "function" then return false, "compile error: " .. tostring(compileError) end
    local runOk, runtimeError = pcall(chunk)
    if not runOk then return false, "runtime error: " .. tostring(runtimeError) end
    return true
end

local loading = false
local lastError = nil
local function loadCurrentGame()
    if loading then return end
    if not CurrentGame then
        setProgress(0, "Unsupported game", COLORS.error)
        LoadButton.Text = "UNSUPPORTED"
        notify("Nenhum script cadastrado. " .. GameInfo.Text)
        return
    end
    loading = true
    LoadButton.Active = false
    LoadButton.Text = "LOADING..."
    CopyButton.Visible = false
    local candidates = getCandidates(CurrentGame)
    if #candidates == 0 then
        setProgress(0, "No script path configured", COLORS.error)
        LoadButton.Text, LoadButton.Active, loading = "RETRY", true, false
        return
    end
    for index, candidate in ipairs(candidates) do
        local start = (index - 1) / #candidates
        setProgress(start + 0.08, "Checking " .. candidate.label .. "...", COLORS.warning)
        task.wait(0.12)
        local ok, err = loadCandidate(candidate)
        if ok then
            prefs.lastPath = candidate.path
            savePrefs()
            setProgress(1, "Script loaded successfully", COLORS.success)
            LoadButton.Text = "LOADED"
            notify("Carregado: " .. candidate.path)
            task.wait(0.45)
            LoaderGui:Destroy()
            return
        end
        lastError = err
        notify("Falha em " .. candidate.path .. ": " .. tostring(err))
        setProgress(index / #candidates, "Trying fallback...", COLORS.warning)
    end
    setProgress(0, "Load failed - tap RETRY", COLORS.error)
    LoadButton.Text, LoadButton.Active, loading = "RETRY", true, false
    CopyButton.Visible = true
end

LoadButton.MouseEnter:Connect(function()
    if LoadButton.Active then animate(LoadButton, 0.15, { BackgroundColor3 = COLORS.pinkDark }) end
end)
LoadButton.MouseLeave:Connect(function()
    if LoadButton.Active then animate(LoadButton, 0.15, { BackgroundColor3 = COLORS.pink }) end
end)
LoadButton.MouseButton1Click:Connect(loadCurrentGame)

-- A interface permanece aberta até o usuário carregar ou fechar.
task.spawn(function()
    animate(Card, 0.55, { Position = UDim2.fromScale(0.5, 0.5) }, Enum.EasingStyle.Back)
end)