local UI = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local COLORS = {
    card = Color3.fromRGB(255, 248, 252),
    soft = Color3.fromRGB(255, 238, 247),
    pink = Color3.fromRGB(232, 92, 157),
    light = Color3.fromRGB(255, 170, 207),
    dark = Color3.fromRGB(139, 43, 91),
    text = Color3.fromRGB(91, 35, 65),
    muted = Color3.fromRGB(158, 106, 132),
    success = Color3.fromRGB(56, 157, 104),
    warning = Color3.fromRGB(194, 126, 37),
    error = Color3.fromRGB(205, 67, 102),
    white = Color3.fromRGB(255, 255, 255),
}

local function make(className, props, parent)
    local object = Instance.new(className)
    for key, value in pairs(props or {}) do object[key] = value end
    object.Parent = parent
    return object
end

local function round(parent, radius)
    return make("UICorner", { CornerRadius = UDim.new(0, radius) }, parent)
end

local function outline(parent, color, thickness)
    return make("UIStroke", { Color = color, Thickness = thickness or 1 }, parent)
end

local function animate(object, duration, props, style, direction)
    local info = TweenInfo.new(duration, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
    local tween = TweenService:Create(object, info, props)
    tween:Play()
    return tween
end

function UI.create(context)
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    for _, parent in ipairs({ CoreGui, playerGui }) do
        local old = parent:FindFirstChild("DerbyBloomLoaderV3")
        if old then old:Destroy() end
    end

    local gui = make("ScreenGui", {
        Name = "DerbyBloomLoaderV3",
        ResetOnSpawn = false,
        DisplayOrder = 999,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    local attached = pcall(function() gui.Parent = CoreGui end)
    if not attached then gui.Parent = playerGui end

    local card = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 1.25),
        Size = UDim2.fromOffset(560, 380),
        BackgroundColor3 = COLORS.card,
        BorderSizePixel = 0,
    }, gui)
    round(card, 18)
    outline(card, COLORS.light, 2)
    make("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, COLORS.white),
            ColorSequenceKeypoint.new(1, COLORS.soft),
        }),
        Rotation = 90,
    }, card)
    local scale = make("UIScale", { Scale = 1 }, card)
    make("UIPadding", {
        PaddingTop = UDim.new(0, 18), PaddingBottom = UDim.new(0, 18),
        PaddingLeft = UDim.new(0, 22), PaddingRight = UDim.new(0, 22),
    }, card)

    local icon = make("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 0),
        Size = UDim2.fromOffset(58, 58), BackgroundColor3 = COLORS.light,
        BackgroundTransparency = 0.15, BorderSizePixel = 0,
        Image = "rbxassetid://92813401609681", ImageColor3 = COLORS.white,
        ScaleType = Enum.ScaleType.Fit, Active = true,
    }, card)
    round(icon, 16)
    outline(icon, COLORS.pink, 1.5)

    local title = make("TextLabel", {
        BackgroundTransparency = 1, Active = true, Position = UDim2.new(0, 0, 0, 66),
        Size = UDim2.new(1, 0, 0, 34), Font = Enum.Font.GothamBold,
        Text = "DerbyBloom", TextColor3 = COLORS.dark, TextSize = 25,
    }, card)
    local subtitle = make("TextLabel", {
        BackgroundTransparency = 1, TextWrapped = false, TextTruncate = Enum.TextTruncate.AtEnd,
        Position = UDim2.new(0, 0, 0, 105), Size = UDim2.new(1, 0, 0, 24),
        Font = Enum.Font.Gotham, Text = context.gameName, TextColor3 = COLORS.muted, TextSize = 14,
    }, card)
    local version = make("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 128),
        Size = UDim2.new(1, 0, 0, 16), Font = Enum.Font.Code,
        Text = "Loader v" .. context.loaderVersion .. "  |  Script " .. (context.scriptVersion or "unknown"),
        TextColor3 = COLORS.muted, TextSize = 10,
    }, card)
    local status = make("TextLabel", {
        BackgroundTransparency = 1, TextWrapped = false, TextTruncate = Enum.TextTruncate.AtEnd,
        Position = UDim2.new(0, 0, 0, 151), Size = UDim2.new(1, 0, 0, 22),
        Font = Enum.Font.Gotham, Text = context.supported and "Game detected" or "Unsupported Game",
        TextColor3 = context.supported and COLORS.success or COLORS.error, TextSize = 13,
    }, card)
    local info = make("TextLabel", {
        BackgroundTransparency = 1, TextWrapped = false, TextTruncate = Enum.TextTruncate.AtEnd,
        Position = UDim2.new(0, 0, 0, 178), Size = UDim2.new(1, 0, 0, 18),
        Font = Enum.Font.Code, Text = "PlaceId: " .. context.placeId .. "  |  GameId: " .. context.gameId,
        TextColor3 = COLORS.muted, TextSize = 11,
    }, card)
    local announcement = context.announcement
    local announcementLabel = make("TextLabel", {
        BackgroundTransparency = 1, TextWrapped = false, TextTruncate = Enum.TextTruncate.AtEnd,
        Position = UDim2.new(0, 0, 0, 204), Size = UDim2.new(1, 0, 0, 24),
        Font = Enum.Font.Gotham, Text = announcement and announcement.message or "",
        TextColor3 = COLORS.pink, TextSize = 11, Visible = announcement ~= nil,
    }, card)

    local progressBack = make("Frame", {
        Position = UDim2.new(0, 0, 0, 237), Size = UDim2.new(1, 0, 0, 6),
        BackgroundColor3 = COLORS.light, BackgroundTransparency = 0.55, BorderSizePixel = 0,
    }, card)
    round(progressBack, 4)
    local progress = make("Frame", {
        Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = COLORS.pink, BorderSizePixel = 0,
    }, progressBack)
    round(progress, 4)

    local loadButton = make("TextButton", {
        AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 1, -74),
        Size = UDim2.new(0.72, 0, 0, 42), AutoButtonColor = false,
        BackgroundColor3 = context.supported and COLORS.pink or Color3.fromRGB(190, 175, 184),
        Font = Enum.Font.GothamBold, Text = context.supported and "LOAD SCRIPT" or "UNSUPPORTED",
        TextColor3 = COLORS.white, TextSize = 14,
    }, card)
    round(loadButton, 10)
    outline(loadButton, COLORS.dark, 1)
    local copyButton = make("TextButton", {
        AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 1, -27),
        Size = UDim2.new(0.52, 0, 0, 22), AutoButtonColor = false,
        BackgroundTransparency = 1, Font = Enum.Font.Gotham,
        Text = "COPY GAME IDS", TextColor3 = COLORS.dark, TextSize = 11,
    }, card)
    local closeButton = make("TextButton", {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.fromOffset(28, 28), BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold, Text = "×", TextColor3 = COLORS.dark, TextSize = 22,
    }, card)

    local function resize()
        local camera = workspace.CurrentCamera
        if not camera then return end
        local viewport = camera.ViewportSize
        local narrow = viewport.X < 700 or viewport.Y < 500
        scale.Scale = narrow and 0.82 or 1
        card.Size = narrow and UDim2.fromOffset(430, 400) or UDim2.fromOffset(560, 380)
        loadButton.Size = narrow and UDim2.new(0.84, 0, 0, 46) or UDim2.new(0.72, 0, 0, 42)
    end
    resize()
    if workspace.CurrentCamera then
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize)
    end

    local dragging, dragStart, startPosition = false, nil, nil
    local function beginDrag(input)
        local mouse = input.UserInputType == Enum.UserInputType.MouseButton1
        local touch = input.UserInputType == Enum.UserInputType.Touch
        if not mouse and not touch then return end
        dragging, dragStart, startPosition = true, input.Position, card.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
    title.InputBegan:Connect(beginDrag)
    icon.InputBegan:Connect(beginDrag)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        local mouse = input.UserInputType == Enum.UserInputType.MouseMovement
        local touch = input.UserInputType == Enum.UserInputType.Touch
        if not mouse and not touch then return end
        local delta = input.Position - dragStart
        card.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
        if context.storage then
            context.storage.x, context.storage.y = card.Position.X.Offset, card.Position.Y.Offset
        end
    end)

    if context.storage and context.storage.x and context.storage.y then
        card.Position = UDim2.new(0.5, context.storage.x, 0.5, context.storage.y)
    end

    copyButton.MouseButton1Click:Connect(function()
        local ids = "PlaceId: " .. context.placeId .. " | GameId: " .. context.gameId
        local copied = false
        if type(setclipboard) == "function" then copied = pcall(setclipboard, ids) end
        if type(toclipboard) == "function" and not copied then copied = pcall(toclipboard, ids) end
        copyButton.Text = copied and "COPIED" or "COPY NOT SUPPORTED"
        if not copied then warn("[DerbyBloom] " .. ids) end
        task.delay(1.4, function() if copyButton.Parent then copyButton.Text = "COPY GAME IDS" end end)
    end)
    closeButton.MouseButton1Click:Connect(function()
        if context.onClose then context.onClose(card.Position) end
        gui:Destroy()
    end)
    loadButton.MouseButton1Click:Connect(function()
        if context.onLoad then context.onLoad(function(message, value, color)
            status.Text = message
            status.TextColor3 = color or COLORS.warning
            progress.Size = UDim2.new(math.clamp(value or 0, 0, 1), 0, 1, 0)
        end, loadButton, copyButton) end
    end)

    animate(card, 0.55, { Position = UDim2.fromScale(0.5, 0.5) }, Enum.EasingStyle.Back)
    return { gui = gui, card = card, status = status, progress = progress }
end

return UI
