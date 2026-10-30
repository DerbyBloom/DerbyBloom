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
}

local function rawUrl(path)
    return string.format(
        "https://raw.githubusercontent.com/%s/%s/refs/heads/%s/%s",
        CONFIG.Owner,
        CONFIG.Repository,
        CONFIG.Branch,
        path
    )
end


local GAMES = {
    PlaceIds = {
        [142823291] = {
            name = "Murder Mystery 2",
            fonted = "games/mm2-1.lua",
            plain = "games/mm2-2.lua",
        },
        [142823292] = {
            name = "Murder Mystery 2",
            fonted = "games/mm2-1.lua",
            plain = "games/mm2-2.lua",
        },
    },

    GameIds = {
        [66654135] = {
            name = "Murder Mystery 2",
            fonted = "games/mm2-1.lua",
            plain = "games/mm2-2.lua",
        },
    },
}

local function getGameEntry()
    return GAMES.PlaceIds[game.PlaceId] or GAMES.GameIds[game.GameId]
end

local CurrentGame = getGameEntry()
local CurrentPlaceId = tostring(game.PlaceId)
local CurrentGameId = tostring(game.GameId)

local COLORS = {
    backdrop = Color3.fromRGB(54, 18, 42),
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

local function notify(message)
    warn("[DerbyBloom Loader] " .. tostring(message))
end

local function destroyOldGui()
    for _, parent in ipairs({ CoreGui, PlayerGui }) do
        local old = parent:FindFirstChild("DerbyBloomLoader")
        if old then
            old:Destroy()
        end
    end
end

destroyOldGui()

local LoaderGui = Instance.new("ScreenGui")
LoaderGui.Name = "DerbyBloomLoader"
LoaderGui.ResetOnSpawn = false
LoaderGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
LoaderGui.DisplayOrder = 999

local parented = pcall(function()
    LoaderGui.Parent = CoreGui
end)
if not parented then
    LoaderGui.Parent = PlayerGui
end

local function new(className, properties, parent)
    local object = Instance.new(className)
    for property, value in pairs(properties or {}) do
        object[property] = value
    end
    object.Parent = parent
    return object
end

local function corner(parent, radius)
    return new("UICorner", { CornerRadius = UDim.new(0, radius) }, parent)
end

local function stroke(parent, color, thickness)
    return new("UIStroke", {
        Color = color,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
end

local function tween(object, duration, properties, style, direction)
    local info = TweenInfo.new(
        duration,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    local animation = TweenService:Create(object, info, properties)
    animation:Play()
    return animation
end

local Backdrop = new("Frame", {
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.fromScale(1, 1),
    Active = false,
}, LoaderGui)

local Card = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 1.3),
    Size = UDim2.fromScale(0.38, 0.38),
    BackgroundColor3 = COLORS.card,
    BorderSizePixel = 0,
}, LoaderGui)
corner(Card, 18)
stroke(Card, COLORS.pinkLight, 2)

local Scale = new("UIScale", { Scale = 1 }, Card)
local CardGradient = new("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, COLORS.white),
        ColorSequenceKeypoint.new(1, COLORS.cardSoft),
    }),
    Rotation = 90,
}, Card)

local Padding = new("UIPadding", {
    PaddingTop = UDim.new(0, 18),
    PaddingBottom = UDim.new(0, 18),
    PaddingLeft = UDim.new(0, 22),
    PaddingRight = UDim.new(0, 22),
}, Card)

local Icon = new("ImageLabel", {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 0),
    Size = UDim2.fromOffset(58, 58),
    BackgroundColor3 = COLORS.pinkLight,
    BackgroundTransparency = 0.15,
    BorderSizePixel = 0,
    Image = "rbxassetid://92813401609681",
    ImageColor3 = COLORS.white,
    ScaleType = Enum.ScaleType.Fit,
}, Card)
corner(Icon, 16)
stroke(Icon, COLORS.pink, 1.5)

local Title = new("TextLabel", {
    BackgroundTransparency = 1,
    Active = true,
    Position = UDim2.new(0, 0, 0, 66),
    Size = UDim2.new(1, 0, 0, 34),
    Font = Enum.Font.GothamBold,
    Text = "DerbyBloom",
    TextColor3 = COLORS.pinkDark,
    TextSize = 25,
}, Card)

local Subtitle = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 105),
    Size = UDim2.new(1, 0, 0, 24),
    Font = Enum.Font.Gotham,
    Text = CurrentGame and CurrentGame.name or "Unsupported Game",
    TextColor3 = COLORS.muted,
    TextSize = 14,
}, Card)

local Status = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 137),
    Size = UDim2.new(1, 0, 0, 22),
    Font = Enum.Font.Gotham,
    Text = CurrentGame and "Ready to load" or "This game is not registered",
    TextColor3 = CurrentGame and COLORS.success or COLORS.error,
    TextSize = 13,
}, Card)

local GameInfo = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 164),
    Size = UDim2.new(1, 0, 0, 18),
    Font = Enum.Font.Code,
    Text = "PlaceId: " .. CurrentPlaceId .. "  |  GameId: " .. CurrentGameId,
    TextColor3 = COLORS.muted,
    TextSize = 11,
}, Card)

local LoadButton = new("TextButton", {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 1, -58),
    Size = UDim2.new(0.72, 0, 0, 42),
    AutoButtonColor = false,
    BackgroundColor3 = CurrentGame and COLORS.pink or Color3.fromRGB(190, 175, 184),
    Font = Enum.Font.GothamBold,
    Text = CurrentGame and "LOAD SCRIPT" or "UNSUPPORTED",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
}, Card)
corner(LoadButton, 10)
stroke(LoadButton, COLORS.pinkDark, 1)

local CloseButton = new("TextButton", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, 0, 0, 0),
    Size = UDim2.fromOffset(28, 28),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    Text = "×",
    TextColor3 = COLORS.pinkDark,
    TextSize = 22,
}, Card)

local dragging = false
local dragStart
local startPosition

Title.InputBegan:Connect(function(input)
    local isMouse = input.UserInputType == Enum.UserInputType.MouseButton1
    local isTouch = input.UserInputType == Enum.UserInputType.Touch
    if not isMouse and not isTouch then return end

    dragging = true
    dragStart = input.Position
    startPosition = Card.Position

    input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
            dragging = false
        end
    end)
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    local isMouse = input.UserInputType == Enum.UserInputType.MouseMovement
    local isTouch = input.UserInputType == Enum.UserInputType.Touch
    if not isMouse and not isTouch then return end

    local delta = input.Position - dragStart
    Card.Position = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,
        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y
    )
end)

CloseButton.MouseButton1Click:Connect(function()
    LoaderGui:Destroy()
end)

CloseButton.MouseEnter:Connect(function()
    CloseButton.TextColor3 = COLORS.pink
end)
CloseButton.MouseLeave:Connect(function()
    CloseButton.TextColor3 = COLORS.pinkDark
end)

local function getFontSupport()
    local ok = pcall(function()
        assert(Enum.Font.Arcade)
        assert(Font)
        assert(type(Font.fromEnum) == "function")
        local label = Instance.new("TextLabel")
        label.FontFace = Font.fromEnum(Enum.Font.Arcade)
        assert(label.FontFace ~= nil)
        label:Destroy()
    end)
    return ok
end

local function getSourceUrl(entry)
    if entry.path then
        return rawUrl(entry.path), entry.path
    end

    local path = getFontSupport() and entry.fonted or entry.plain
    if not path then
        path = entry.fonted or entry.plain
    end
    return path and rawUrl(path), path
end

local loading = false
local function loadCurrentGame()
    if loading or not CurrentGame then return end
    loading = true
    LoadButton.Active = false
    LoadButton.Text = "LOADING..."
    Status.Text = "Downloading script..."
    Status.TextColor3 = COLORS.warning

    local url, path = getSourceUrl(CurrentGame)
    if not url then
        Status.Text = "No script path configured"
        Status.TextColor3 = COLORS.error
        LoadButton.Text = "LOAD FAILED"
        notify("Nenhum caminho foi configurado para este jogo")
        return
    end

    local ok, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)

    if not ok then
        Status.Text = "Load failed - check console"
        Status.TextColor3 = COLORS.error
        LoadButton.Text = "RETRY"
        LoadButton.Active = true
        loading = false
        notify("Falha ao carregar " .. tostring(path) .. ": " .. tostring(result))
        return
    end

    Status.Text = "Script loaded successfully"
    Status.TextColor3 = COLORS.success
    notify("Carregado: " .. tostring(path))
    task.wait(0.35)
    LoaderGui:Destroy()
end

LoadButton.MouseEnter:Connect(function()
    if LoadButton.Active then
        tween(LoadButton, 0.15, { BackgroundColor3 = COLORS.pinkDark })
    end
end)
LoadButton.MouseLeave:Connect(function()
    if LoadButton.Active then
        tween(LoadButton, 0.15, { BackgroundColor3 = COLORS.pink })
    end
end)
LoadButton.MouseButton1Click:Connect(loadCurrentGame)

-- Entrada com animação simples, no mesmo estilo do loader de referência.
task.spawn(function()
    tween(Card, 0.55, {
        Position = UDim2.fromScale(0.5, 0.5),
    }, Enum.EasingStyle.Back)
end)
