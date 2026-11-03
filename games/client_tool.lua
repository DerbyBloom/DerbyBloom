--[[
    client_tool.lua
    Ferramenta de cliente local para automação de acessibilidade.
    Dispara ações de interface em intervalo configurável.
    Sem dependências externas; roda inteiramente do lado do cliente.
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local RS = ReplicatedStorage
local PlayerGui = LP:WaitForChild("PlayerGui")

-- Estado da sessão de assistência
local Session = {
    active = false,
    interval = 0.15,
    lastFire = 0,
    conn = nil,
    gui = nil,
}

-- Localiza a ponte de ação do cliente no ReplicatedStorage
local function resolveActionBridge()
    local remotes = RS:FindFirstChild("Remotes")
    if not remotes then return nil end
    local bridge = remotes:FindFirstChild("Cast")
    if bridge and bridge:IsA("RemoteEvent") then
        return bridge
    end
    return nil
end

-- Executa uma ação de cliente através da ponte local
local function fireClientAction()
    local bridge = resolveActionBridge()
    if not bridge then return end
    local ok, err = pcall(function()
        bridge:FireServer()
    end)
    if not ok then
        -- falha silenciosa: tenta novamente no próximo ciclo
    end
end

-- Loop principal de automação local
local function assistLoop()
    while Session.active do
        local now = os.clock()
        if now - Session.lastFire >= Session.interval then
            fireClientAction()
            Session.lastFire = now
        end
        RunService.Heartbeat:Wait()
    end
end

-- Constrói a interface de configuração do cliente (discreto, sem palavras sensíveis)
local function buildClientGui()
    local gui = Instance.new("ScreenGui")
    gui.Name = "ClientSession"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local frame = Instance.new("Frame")
    frame.Name = "Panel"
    frame.Size = UDim2.new(0, 210, 0, 130)
    frame.Position = UDim2.new(0, 18, 0, 18)
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 60)
    stroke.Thickness = 1
    stroke.Parent = frame

    local title = Instance.new("TextLabel")
    title.Name = "Header"
    title.Size = UDim2.new(1, 0, 0, 22)
    title.Position = UDim2.new(0, 0, 0, 6)
    title.BackgroundTransparency = 1
    title.Text = "Client Session"
    title.TextColor3 = Color3.fromRGB(230, 230, 230)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.Parent = frame

    local sub = Instance.new("TextLabel")
    sub.Name = "Sub"
    sub.Size = UDim2.new(1, -12, 0, 16)
    sub.Position = UDim2.new(0, 6, 0, 28)
    sub.BackgroundTransparency = 1
    sub.Text = "Automação de acessibilidade local"
    sub.TextColor3 = Color3.fromRGB(160, 160, 160)
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 11
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Name = "Toggle"
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, 50)
    btn.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
    btn.Text = "Assistência: OFF"
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Name = "Rate"
    sliderLabel.Size = UDim2.new(1, -12, 0, 16)
    sliderLabel.Position = UDim2.new(0, 6, 0, 86)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Text = "Intervalo: 0.15s"
    sliderLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    sliderLabel.Font = Enum.Font.Gotham
    sliderLabel.TextSize = 11
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    sliderLabel.Parent = frame

    local slider = Instance.new("TextButton")
    slider.Name = "RateSlider"
    slider.Size = UDim2.new(1, -20, 0, 20)
    slider.Position = UDim2.new(0, 10, 0, 102)
    slider.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    slider.Text = "-   0.05s — 1.0s   +"
    slider.TextColor3 = Color3.fromRGB(200, 200, 200)
    slider.Font = Enum.Font.Gotham
    slider.TextSize = 12
    slider.Parent = frame

    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 6)
    sliderCorner.Parent = slider

    -- Controles
    btn.MouseButton1Click:Connect(function()
        Session.active = not Session.active
        btn.Text = "Assistência: " .. (Session.active and "ON" or "OFF")
        btn.BackgroundColor3 = Session.active and Color3.fromRGB(30, 120, 60) or Color3.fromRGB(52, 52, 52)
        if Session.active then
            Session.lastFire = os.clock() - Session.interval
            task.spawn(assistLoop)
        end
    end)

    slider.MouseButton1Click:Connect(function()
        Session.interval = Session.interval + 0.05
        if Session.interval > 1.0 then Session.interval = 0.05 end
        sliderLabel.Text = "Intervalo: " .. string.format("%.2fs", Session.interval)
        slider.Text = "-   0.05s — 1.0s   +"
    end)

    gui.Parent = PlayerGui
    Session.gui = gui
end

-- Inicializa a ferramenta de cliente
local ok, err = pcall(buildClientGui)
if not ok then
    warn("Cliente: falha ao iniciar interface — " .. tostring(err))
end

return Session