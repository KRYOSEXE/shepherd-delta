-- Shepherd Simulator - Delta Executor Script
-- Template genérico. Lee las notas al final para personalizar auto-farm y redimir códigos.

-- ============================================================
-- 1. Utilidades
-- ============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanRootPart")

-- Buscar instancia por nombre (case-insensitive) dentro de un contenedor
local function findChild(container, name)
    if not container then return end
    for _, v in ipairs(container:GetChildren()) do
        if string.lower(v.Name) == string.lower(name) then
            return v
        end
    end
    return nil
end

-- ============================================================
-- 2. Habilidades de personaje (funcionan sin nombres del juego)
-- ============================================================
local settings = {
    godMode     = false,  -- no recibir daño
    infiniteJump= false,  -- salto infinito
    speedBoost  = false,  -- velocidad extra
    speedValue  = 32,     -- velocidad base habitual; sube este número
}

-- God mode
RunService.Heartbeat:Connect(function()
    if settings.godMode then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
    end
end)

-- Salto infinito
humanoid.JumpPower = 100
local connJump
connJump = humanoid.StateChanged:Connect(function(_, state)
    if settings.infiniteJump and state == Enum.HumanoidStateType.Grounded then
        -- forzar impulso al tocar el suelo
    end
end)

-- Speed
local function setSpeed(on)
    if humanoid then
        humanoid.WalkSpeed = on and settings.speedValue or 16
    end
end

-- ============================================================
-- 3. Teleport a una ubicación (coordenadas)
-- ============================================================
local function teleportTo(x, y, z)
    if rootPart then
        rootPart.CFrame = CFrame.new(x, y, z)
    end
end

-- ============================================================
-- 4. Auto-farm (PERSONALIZAR)
--    Este es el parte que depende del juego. Hay que identificar
--    los RemoteEvents/Nombres reales con la herramienta "Inspect"
--    de Delta (tecla por defecto F9 / botón Inspect Tool).
-- ============================================================
local autoFarm = {
    enabled = false,
    -- Dónde están las "lanas"/recursos (ajustar al nombre real del juego)
    farmPosition = Vector3.new(0, 5, 0),
    interval     = 1,   -- segundos entre acciones
}

local function autoFarmLoop()
    while autoFarm.enabled do
        -- TODO: aquí va la acción real. Ejemplos según cómo esté hecho el juego:
        -- a) Si el juego usa un RemoteEvent para "recoger lana":
        --    local remote = game.ReplicatedStorage:FindFirstChild("WoolCollect")
        --    if remote then remote:FireServer() end
        -- b) Si hay que caminar a un punto y clickear, usa teleportTo + un evento.
        -- c) Si hay un valor de monedas/lana modificable:
        --    game.StarterGui... :FindFirstChild("Coins").Value = game...Value + 1
        task.wait(autoFarm.interval)
    end
end

local function toggleAutoFarm()
    autoFarm.enabled = not autoFarm.enabled
    if autoFarm.enabled then
        spawn(autoFarmLoop)   -- o task.spawn(autoFarmLoop)
    end
end

-- ============================================================
-- 5. Redimir códigos (PERSONALIZAR)
--    Busca un botón "Redeem"/"Codes" y un textbox.
-- ============================================================
local codes = { "SHEEP2026", "FREEWOOL", "SHEPHERD" }  -- pon tus códigos reales

local function redeemAll()
    local gui = player.PlayerGui
    -- Ajusta "Redeem" y "CodeTextbox" a los nombres reales del GUI del juego
    local redeemBtn = findChild(gui, "Redeem")
    local codeBox   = findChild(gui, "CodeTextbox")
    for _, code in ipairs(codes) do
        if codeBox then
            codeBox.Text = code
        end
        if redeemBtn then
            -- Si es un Button:
            if redeemBtn.MouseButton1Click then
                redeemBtn.MouseButton1Click:Wait()
            end
            -- Si es un TextButton con evento FireServer, hay que adaptarlo.
        end
        task.wait(0.5)
    end
end

-- ============================================================
-- 6. Activación con teclas (abre la consola del executor)
-- ============================================================
UserInputService.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.F1 then
        settings.godMode = not settings.godMode
        print("[Shepherd] GodMode: " .. tostring(settings.godMode))
    elseif input.KeyCode == Enum.KeyCode.F2 then
        settings.infiniteJump = not settings.infiniteJump
        print("[Shepherd] InfiniteJump: " .. tostring(settings.infiniteJump))
    elseif input.KeyCode == Enum.KeyCode.F3 then
        setSpeed(settings.speedBoost)
        settings.speedBoost = not settings.speedBoost
        print("[Shepherd] Speed: " .. tostring(settings.speedBoost))
    elseif input.KeyCode == Enum.KeyCode.F4 then
        toggleAutoFarm()
        print("[Shepherd] AutoFarm: " .. tostring(autoFarm.enabled))
    elseif input.KeyCode == Enum.KeyCode.F5 then
        redeemAll()
        print("[Shepherd] Redeem codes executed")
    end
end)

print("[Shepherd] Script cargado. F1 God, F2 Jump, F3 Speed, F4 Farm, F5 Codes")
