-- Shepherd Simulator - Delta Executor (con ventana de botones)
-- Salto alto repetitivo, God mode y velocidad ya funcionan.
-- Farm y Redimir son plantilla (avisa cuando pongamos los nombres reales del juego).

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- ============================================================
-- Configuracion
-- ============================================================
local settings = {
    infiniteJump = false,
    godMode      = false,
    speedBoost   = false,
    speedValue   = 40,
}

-- God mode (no recibe daño)
RunService.Heartbeat:Connect(function()
    if settings.godMode then
        humanoid.MaxHealth = math.huge
        humanoid.Health      = math.huge
    end
end)

-- Salto alto repetitivo (solo cuando toca el suelo)
local JumpConn
local function setJump(on)
    settings.infiniteJump = on
    if on then
        humanoid.JumpPower = 200
        JumpConn = RunService.Heartbeat:Connect(function()
            if humanoid.Health > 0 and humanoid.FloorMaterial ~= Enum.Material.Null then
                humanoid:Jump()
            end
        end)
    elseif JumpConn then
        JumpConn:Disconnect()
        JumpConn = nil
    end
end

-- Velocidad
local function setSpeed(on)
    settings.speedBoost = on
    humanoid.WalkSpeed = on and settings.speedValue or 16
end

-- ============================================================
-- Crear la ventana (si ya existe, la recrea)
-- ============================================================
if playerGui:FindFirstChild("ShepherdMenu") then
    playerGui.ShepherdMenu:Destroy()
end

local screen = Instance.new("ScreenGui")
screen.Name = "ShepherdMenu"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.Parent = playerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 240, 0, 360)
main.Position = UDim2.new(0.5, -120, 0.5, -180)
main.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
main.BorderSizePixel = 0
main.Parent = screen
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = main

local title = Instance.new("Label")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
title.Text = "\240Pastor - Menu"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = main
local tCorner = Instance.new("UICorner")
tCorner.Parent = title

local status = Instance.new("Label")
status.Name = "Status"
status.Size = UDim2.new(1, -16, 0, 20)
status.Position = UDim2.new(0, 8, 0, 346)
status.BackgroundTransparency = 0.6
status.Text = "Listo."
status.TextColor3 = Color3.fromRGB(180, 180, 180)
status.Font = Enum.Font.SourceSans
status.TextSize = 13
status.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Top
layout.Parent = title

local function makeButton(text, func)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.Parent = title
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 9)
    c.Parent = btn
    btn.MouseButton1Click:Connect(function()
        func(btn)
    end)
    return btn
end

local function setStatus(txt)
    status.Text = txt
end

-- ============================================================
-- Botones
-- ============================================================
local btnGod = makeButton("God Mode: OFF", function(b)
    settings.godMode = not settings.godMode
    b.Text = "God Mode: " .. (settings.godMode and "ON" or "OFF")
    b.BackgroundColor3 = settings.godMode and Color3.fromRGB(60, 140, 80) or Color3.fromRGB(45, 45, 58)
    setStatus("God Mode: " .. (settings.godMode and "ON" or "OFF"))
end)

local btnJump = makeButton("Saltar: OFF", function(b)
    setJump(not settings.infiniteJump)
    b.Text = "Saltar: " .. (settings.infiniteJump and "ON" or "OFF")
    b.BackgroundColor3 = settings.infiniteJump and Color3.fromRGB(60, 140, 80) or Color3.fromRGB(45, 45, 58)
    setStatus("Saltar alto: " .. (settings.infiniteJump and "activado" or "desactivado"))
end)

local btnSpeed = makeButton("Velocidad: OFF", function(b)
    setSpeed(not settings.speedBoost)
    b.Text = "Velocidad: " .. (settings.speedBoost and "ON" or "OFF")
    b.BackgroundColor3 = settings.speedBoost and Color3.fromRGB(60, 140, 80) or Color3.fromRGB(45, 45, 58)
    setStatus("Velocidad: " .. (settings.speedBoost and "ON" or "OFF"))
end)

local btnFarm = makeButton("Farm: OFF", function(b)
    -- PLANTILLA: aun no sabemos como el juego guarda la lana
    b.BackgroundColor3 = Color3.fromRGB(120, 90, 30)
    setStatus("Farm: en prueba (pendiente de nombres del juego)")
end)

local btnRedeem = makeButton("Redimir", function(b)
    -- PLANTILLA: redimir codes
    setStatus("Redimir: en prueba (pendiente de nombres del juego)")
end)

local btnClose = makeButton("Cerrar", function(b)
    screen:Destroy()
    setStatus("Menu cerrado")
end)
