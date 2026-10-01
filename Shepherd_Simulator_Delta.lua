-- Shepherd Simulator - Delta (menu para MOVIL)
-- Panel arrastrable, botones grandes. Saltar/God/Velocidad funcionan.
-- Farm y Redimir son plantilla (pendiente de nombres reales del juego).

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local settings = {
    infiniteJump = false,
    godMode      = false,
    speedBoost   = false,
    speedValue   = 40,
}

-- God mode
RunService.Heartbeat:Connect(function()
    if settings.godMode then
        humanoid.MaxHealth = math.huge
        humanoid.Health      = math.huge
    end
end)

-- Salto alto repetitivo
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

local function setSpeed(on)
    settings.speedBoost = on
    humanoid.WalkSpeed = on and settings.speedValue or 16
end

-- ============================================================
-- Crear menu (si ya existe, lo recrea)
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
main.Size = UDim2.new(0, 220, 0, 300)
main.Position = UDim2.new(0.5, 0, 1, -320)   -- abajo, centrado
main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
main.BorderSizePixel = 0
main.Parent = screen
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = main

-- Borde sutil
local border = Instance.new("UIStroke")
border.Color = Color3.fromRGB(80, 80, 110)
border.Thickness = 2
border.Parent = main

-- Cabecera (asa para arrastrar)
local header = Instance.new("TextLabel")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 44)
header.BackgroundColor3 = Color3.fromRGB(50, 50, 72)
header.Text = "\240Pastor Simulator  \u270E"
header.TextXAlignment = Enum.TextXAlignment.Left
header.TextColor3 = Color3.fromRGB(255, 255, 255)
header.Font = Enum.Font.SourceSansBold
header.TextSize = 17
header.Parent = main
local hCorner = Instance.new("UICorner")
hCorner.TopRightCorner = true
hCorner.Parent = header

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Top
layout.Parent = header

-- Botones
local function makeButton(text, func)
    local btn = Instance.new("TextButton")
    btn.Name = "Btn"
    btn.Size = UDim2.new(1, -20, 0, 46)
    btn.Position = UDim2.new(0, 10, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 17
    btn.Parent = main
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 12)
    c.Parent = btn
    btn.MouseButton1Click:Connect(function()
        func(btn)
    end)
    return btn
end

local function setActive(b, on)
    b.BackgroundColor3 = on and Color3.fromRGB(40, 160, 80) or Color3.fromRGB(55, 55, 75)
end

makeButton("\u26A1 God Mode", function(b)
    settings.godMode = not settings.godMode
    setActive(b, settings.godMode)
end)

makeButton("\uD83D\uDC59 Salto alto", function(b)
    setJump(not settings.infiniteJump)
    setActive(b, settings.infiniteJump)
end)

makeButton("\uD83C\uDFC3 Velocidad", function(b)
    setSpeed(not settings.speedBoost)
    setActive(b, settings.speedBoost)
end)

makeButton("\uD83D\uDC31 Farm", function(b)
    setActive(b, true)
end)

makeButton("\uD83C\uDF8F Redimir", function(b)
    setActive(b, true)
end)

makeButton("\u274C Cerrar", function(b)
    screen:Destroy()
end)

-- ============================================================
-- Arrastrar el menu con el dedo (movil) o mouse
-- ============================================================
local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil

main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
       or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

main.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
       or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragInput = input
    end
end)

RunService.Heartbeat:Connect(function()
    if dragging and dragInput then
        local delta = dragInput.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)
