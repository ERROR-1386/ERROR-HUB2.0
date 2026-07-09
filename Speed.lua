local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local coreGui = game:GetService("CoreGui")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Защита от дублирования интерфейса
if coreGui:FindFirstChild("UltimateGoldFarmGui") then
    coreGui.UltimateGoldFarmGui:Destroy()
end

local farmActive = false
local totalGoldEarned = 0
local initialGold = nil
local currentPlatform = nil

-- Точные координаты стадий
local fastStagePoints = {
    Vector3.new(-100, 55, 600),
    Vector3.new(-100, 55, 1400),
    Vector3.new(-100, 55, 2200),
    Vector3.new(-100, 55, 3000),
    Vector3.new(-100, 55, 3800),
    Vector3.new(-100, 55, 4600),
    Vector3.new(-100, 55, 5400),
    Vector3.new(-100, 55, 6200),
    Vector3.new(-100, 55, 7000),
    Vector3.new(-100, 55, 7800),
    Vector3.new(-52, -355, 9490) -- Финальный сундук
}

local goldValue = localPlayer:FindFirstChild("leaderstats") and localPlayer.leaderstats:FindFirstChild("Gold")

-- Логика Режима Бога (God Mode)
local function applyGodMode()
    local character = localPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local scriptHealth = character:FindFirstChild("Health")
            if scriptHealth then
                scriptHealth:Destroy() -- Удаляем стандартный скрипт урона / регенерации игры
            end
        end
    end
end

-- Автоматическое переприменение God Mode при каждом респавне
local characterAddedCon = localPlayer.CharacterAdded:Connect(function()
    task.wait(0.3)
    if farmActive then
        applyGodMode()
    end
end)

-- Платформа под ногами
local function removePlatform()
    if currentPlatform then
        currentPlatform:Destroy()
        currentPlatform = nil
    end
end

local function spawnPlatform(pos)
    removePlatform()
    local part = Instance.new("Part")
    part.Size = Vector3.new(6, 1, 6)
    part.Position = pos - Vector3.new(0, 3.5, 0)
    part.Anchored = true
    part.Transparency = 1
    part.Parent = workspace
    currentPlatform = part
end

-- Цикл фарма
local function startMaxSpeedFarm()
    while farmActive do
        local character = localPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        
        if root and humanoid and humanoid.Health > 0 then
            applyGodMode() -- Подстраховка включения God Mode
            
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            
            for i, point in ipairs(fastStagePoints) do
                if not farmActive then break end
                
                spawnPlatform(point)
                root.Velocity = Vector3.new(0,0,0)
                root.CFrame = CFrame.new(point)
                
                task.wait(1.7) 
            end
            
            removePlatform()
            task.wait(2.5)
        else
            removePlatform()
            task.wait(0.5)
        end
    end
    removePlatform()
end

-- ================= УЛЬТРА ANTI-AFK (Микро-шаг вперед и прыжок раз в секунду) =================
task.spawn(function()
    while true do
        if farmActive then
            local character = localPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            
            if humanoid and humanoid.Health > 0 then
                -- 1. Симулируем нажатие прыжка
                humanoid.Jump = true
                
                -- 2. Делаем микро-шаг вперед через зажатие клавиши "W" на 0.05 секунды
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
            end
        end
        task.wait(0.95) -- В сумме с шагом дает ровно 1 секунду интервала
    end
end)

-- ================= ИНТЕРФЕЙС GUI =================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UltimateGoldFarmGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = coreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 160)
mainFrame.Position = UDim2.new(0, 30, 0, 120)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(230, 140, 0) -- Золотисто-оранжевая обводка

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 10)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "👑 GOD + ANTI-AFK FARM"
titleLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 12
titleLabel.Parent = mainFrame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -30, 0, 40)
toggleBtn.Position = UDim2.new(0, 15, 0, 45)
toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
toggleBtn.Text = "ФАРМ: ВЫКЛ"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 12
toggleBtn.Parent = mainFrame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, -30, 0, 25)
statsLabel.Position = UDim2.new(0, 15, 0, 95)
statsLabel.BackgroundTransparency = 1
statsLabel.Text = "💰 Заработано: +0 золота"
statsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
statsLabel.Font = Enum.Font.GothamBold
statsLabel.TextSize = 11
statsLabel.Parent = mainFrame

local destroyButton = Instance.new("TextButton")
destroyButton.Size = UDim2.new(1, -30, 0, 25)
destroyButton.Position = UDim2.new(0, 15, 1, -35)
destroyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
destroyButton.Text = "❌ УБРАТЬ GUI"
destroyButton.TextColor3 = Color3.fromRGB(220, 220, 220)
destroyButton.Font = Enum.Font.GothamBold
destroyButton.TextSize = 10
destroyButton.Parent = mainFrame
Instance.new("UICorner", destroyButton).CornerRadius = UDim.new(0, 6)

-- ================= СВЯЗКА КНОПОК =================

toggleBtn.MouseButton1Click:Connect(function()
    farmActive = not farmActive
    if farmActive then
        toggleBtn.Text = "ФАРМ + ANTI-AFK АКТИВЕН"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        
        if goldValue and not initialGold then
            initialGold = goldValue.Value
        end
        
        applyGodMode()
        task.spawn(startMaxSpeedFarm)
    else
        toggleBtn.Text = "ФАРМ: ВЫКЛ"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        removePlatform()
    end
end)

if goldValue then
    goldValue.Changed:Connect(function(newGold)
        if initialGold then
            totalGoldEarned = newGold - initialGold
            if totalGoldEarned >= 0 then
                statsLabel.Text = "💰 Заработано: +" .. tostring(totalGoldEarned) .. " золота"
            end
        end
    end)
end

destroyButton.MouseButton1Click:Connect(function()
    farmActive = false
    if characterAddedCon then characterAddedCon:Disconnect() end
    removePlatform()
    screenGui:Destroy()
end)
