-- Shepherd Simulator - Delta (movil) -- menu con botones grandes y arrastrable
-- Saltar/God/Velocidad funcionan. Farm y Redhir son plantilla.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local settings = { infiniteJump=false, godMode=false, speedBoost=false, speedValue=40 }

-- God mode
RunService.Heartbeat:Connect(function()
    if settings.godMode then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
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

-- Contenedor principal (fondo oscuro)
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 240, 0, 420)
main.Position = UDim2.new(0.5, -120, 1, -440)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
main.BorderSizePixel = 0
main.Parent = screen
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = main

-- Titulo (solo texto, sin hijos)
local title = Instance.new("Label")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 44)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 72)
title.Text = "Pastor Menu"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = main
local tCorner = Instance.new("UICorner")
tCorner.TopRightCorner = true
tCorner.BottomLeftCorner = true
tCorner.Parent = title

-- Contenedor de botones (alto propio, NO recorta)
local container = Instance.new("Frame")
container.Name = "Buttons"
container.Size = UDim2.new(1, -16, 0, 368)
container.Position = UDim2.new(0, 8, 0, 50)
container.BackgroundTransparency = 1
container.Parent = main
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Top
layout.Parent = container

local function makeButton(text, func)
    local btn = Instance.new("TextButton")
    btn.Name = "Btn"
    btn.Size = UDim2.new(1, 0, 0, 50)
    btn.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 17
    btn.Parent = container
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 12)
    c.Parent = btn
    btn.MouseButton1Click:Connect(function() func(btn) end)
    return btn
end

local function setActive(b, on)
    b.BackgroundColor3 = on and Color3.fromRGB(40, 160, 80) or Color3.fromRGB(55, 55, 75)
end

makeButton("God Mode", function(b)
    settings.godMode = not settings.godMode
    setActive(b, settings.godMode)
end)
makeButton("Salto alto", function(b)
    setJump(not settings.infiniteJump)
    setActive(b, settings.infiniteJump)
end)
makeButton("Velocidad", function(b)
    setSpeed(not settings.speedBoost)
    setActive(b, settings.speedBoost)
end)
makeButton("Farm", function(b)
    setActive(b, true)
end)
makeButton("Redimir", function(b)
    setActive(b, true)
end)
makeButton("Cerrar", function(b)
    screen:Destroy()
end)

-- ============================================================
-- Arrastrar con el dedo
-- ============================================================
local dragging=false local dragInput=nil local dragStart=nil local startPos=nil
main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
       or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging=true; dragStart=input.Position; startPos=main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging=false end
        end)
    end
end)
main.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
       or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragInput=input
    end
end)
RunService.Heartbeat:Connect(function()
    if dragging and dragInput then
        local delta = dragInput.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
