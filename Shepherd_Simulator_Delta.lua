-- Shepherd Simulator - Delta (movil) -- todo hijo directo de la ScreenGui (sin anidar)
-- Salto/God/Velocidad funcionan. Farm y Redhir son plantilla.

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

local function buildMenu()
    -- destruir menus previos
    for _, g in ipairs(playerGui:GetChildren()) do
        if g.Name == "ShepherdMenu" then g:Destroy() end
    end
    task.wait(1)

    local screen = Instance.new("ScreenGui")
    screen.Name = "ShepherdMenu"
    screen.ResetOnSpawn = false
    screen.DestroyOnSpawn = false
    screen.Parent = playerGui
    task.wait(1)

    -- 1) fondo (crea primero -> detras)
    local bg = Instance.new("Frame")
    bg.Name = "Bg"
    bg.Size = UDim2.new(0, 240, 0, 400)
    bg.Position = UDim2.new(0.5, -120, 1, -400)
    bg.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    bg.BorderSizePixel = 0
    bg.Parent = screen
    local bgc = Instance.new("UICorner"); bgc.CornerRadius = UDim.new(0, 16); bgc.Parent = bg
    task.wait(0.2)

    -- 2) titulo
    local title = Instance.new("Label")
    title.Name = "Title"
    title.Size = UDim2.new(0, 240, 0, 44)
    title.Position = UDim2.new(0.5, -120, 1, -396)
    title.BackgroundColor3 = Color3.fromRGB(50, 50, 72)
    title.Text = "Pastor Menu"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 18
    title.Parent = screen
    task.wait(0.2)

    -- 3) botones (crea ultimo -> delante)
    local labels = {"God Mode", "Salto alto", "Velocidad", "Farm", "Redimir", "Cerrar"}
    local positions = {-348, -296, -244, -192, -140, -88}
    local created = {}

    local function setActive(b, on)
        b.BackgroundColor3 = on and Color3.fromRGB(40, 160, 80) or Color3.fromRGB(55, 55, 75)
    end

    for i = 1, 6 do
        local b = Instance.new("TextButton")
        b.Name = "Btn" .. i
        b.Text = labels[i]
        b.Size = UDim2.new(0, 220, 0, 48)
        b.Position = UDim2.new(0.5, -110, 1, positions[i])
        b.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.Font = Enum.Font.SourceSansBold
        b.TextSize = 17
        b.Parent = screen
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 12); c.Parent = b
        created[i] = b
        task.wait(0.1)
    end

    created[1].MouseButton1Click:Connect(function()
        settings.godMode = not settings.godMode; setActive(created[1], settings.godMode)
    end)
    created[2].MouseButton1Click:Connect(function()
        setJump(not settings.infiniteJump); setActive(created[2], settings.infiniteJump)
    end)
    created[3].MouseButton1Click:Connect(function()
        setSpeed(not settings.speedBoost); setActive(created[3], settings.speedBoost)
    end)
    created[4].MouseButton1Click:Connect(function() setActive(created[4], true) end)
    created[5].MouseButton1Click:Connect(function() setActive(created[5], true) end)
    created[6].MouseButton1Click:Connect(function() screen:Destroy() end)

    -- arrastre: mantén pulsado en el titulo y mueve todo
    local dragging=false local dragStart=nil
    local dragEls = {bg, title, created[1], created[2], created[3], created[4], created[5], created[6]}
    local orig={}
    for _,e in ipairs(dragEls) do orig[e]=e.Position end

    title.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1) then
            dragging=true
            dragStart=input.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging=false end
            end)
        end
    end)
    RunService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1) then
            local delta = input.Position - dragStart
            for e,o in pairs(orig) do
                e.Position = UDim2.new(o.X.Scale, o.X.Offset+delta.X, o.Y.Scale, o.Y.Offset+delta.Y)
            end
        end
    end)

    print("[Shepherd] Menu mostrado.")
end

local ok, err = pcall(buildMenu)
if ok then print("[Shepherd] Menu mostrado.") else print("[Shepherd] ERROR:", err) end
