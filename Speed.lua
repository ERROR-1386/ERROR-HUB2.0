local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local coreGui = game:GetService("CoreGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")

-- Защита от дублирования интерфейса
if coreGui:FindFirstChild("InstantGoldFarmGui") then
    coreGui.InstantGoldFarmGui:Destroy()
end

local farmActive = false
local totalGoldEarned = 0
local initialGold = nil
local currentPlatform = nil
local isTeleporting = false

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
                scriptHealth:Destroy()
            end
        end
    end
end

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

-- Одиночный быстрый проход по всем стадиям
local function runFarmCycle()
    if isTeleporting or not farmActive then return end
    isTeleporting = true
    
    local character = localPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    
    if root and humanoid and humanoid.Health > 0 then
        applyGodMode()
        
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        
        for i, point in ipairs(fastStagePoints) do
            if not farmActive then break end
            
            spawnPlatform(point)
            root.Velocity = Vector3.new(0,0,0)
            root.CFrame = CFrame.new(point)
            
            task.wait(1.6)
        end
        
        removePlatform()
    end
    
    isTeleporting = false
end

-- МОМЕНТАЛЬНЫЙ ТРИГГЕР: Старт без задержек при спавне
local characterAddedCon = localPlayer.CharacterAdded:Connect(function(char)
    if farmActive then
        local root = char:WaitForChild("HumanoidRootPart", 5)
        if root then
            task.wait(0.1)
            task.spawn(runFarmCycle)
        end
    end
end)

-- ================= ФУНКЦИЯ AUTO-REJOIN (ПЕРЕЗАХОД ПРИ ВЫЛЕТАХ) =================
local function safeRejoin()
    local success, err = pcall(function()
        if #Players:GetPlayers() <= 1 then
            TeleportService:Teleport(game.PlaceId, localPlayer)
        else
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, localPlayer)
        end
    end)
    if not success then
        TeleportService:Teleport(game.PlaceId, localPlayer)
    end
end

GuiService.ErrorMessageChanged:Connect(function()
    task.wait(1)
    safeRejoin()
end)

localPlayer.Idled:Connect(function()
    local coreGuiError = coreGui:FindFirstChild("RobloxPromptGui")
    if coreGuiError and coreGuiError:FindFirstChild("promptOverlay") then
        safeRejoin()
    end
end)

-- ================= УЛЬТРА ANTI-AFK (Микро-шаг вперед и прыжок раз в секунду) =================
task.spawn(function()
    while true do
        if farmActive then
            local character = localPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            
            if humanoid and humanoid.Health > 0 then
                humanoid.Jump = true
                
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
            end
        end
        task.wait(0.95)
    end
end)

-- ================= ИНТЕРФЕЙС GUI =================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InstantGoldFarmGui"
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
mainStroke.Color = Color3.fromRGB(85, 170, 85)

-- Механизм перетаскивания (InputService, dragInput, startPos)
local UIS = game:GetService("UserInputService")
local d, sD, sF
mF.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        d, sD, sF = true, i.Position, mF.Position
        i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then d = false end end)
    end
end)
mF.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then sI = i end
end)
UIS.InputChanged:Connect(function(i)
    if i == sI and d then
        local de = i.Position - sD
        mF.Position = UDim2.new(sF.X.Scale, sF.X.Offset + de.X, sF.Y.Scale, sF.Y.Offset + de.Y)
    end
end)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 10)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🛡️ AUTO-START + INSTANT FARM"
titleLabel.TextColor3 = Color3.fromRGB(100, 210, 100)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 12
titleLabel.Parent = mainFrame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -30, 0, 40)
toggleBtn.Position = UDim2.new(0, 15, 0, 45)
toggleBtn.BackgroundColor3 = Color3.fromRGB(210, 160, 40) -- Желтый цвет для таймера
toggleBtn.Text = "⏳ АВТО-СТАРТ ЧЕРЕЗ: 5"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 10
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

-- ================= СВЯЗКА КНОПОК И ФУНКЦИЯ АКТИВАЦИИ =================

local function activateFarm()
    if farmActive then return end
    farmActive = true
    toggleBtn.Text = "НОЧНОЙ АВТОФАРМ АКТИВЕН"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    
    if goldValue and not initialGold then
        initialGold = goldValue.Value
    end
    
    applyGodMode()
    task.spawn(runFarmCycle)
end

local function deactivateFarm()
    if not farmActive then return end
    farmActive = false
    toggleBtn.Text = "АВТОФАРМ С REJOIN: ВЫКЛ"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    removePlatform()
end

toggleBtn.MouseButton1Click:Connect(function()
    if farmActive then
        deactivateFarm()
    else
        activateFarm()
    end
end)

-- Надежный сборщик статистики (полная замена)
task.spawn(function()
    local p = game:GetService("Players").LocalPlayer
    local stats = p:WaitForChild("leaderstats", 15)
    local gold = stats and stats:WaitForChild("Gold", 15)
    
    if gold then
        initialGold = gold.Value
        gold.Changed:Connect(function(newGold)
            if initialGold then
                totalGoldEarned = newGold - initialGold
                if totalGoldEarned < 0 then totalGoldEarned = 0 end
                -- Жесткое обновление текста на GUI объекте из строки 196
                statsLabel.Text = "💰 Заработано: +" .. tostring(totalGoldEarned) .. " золота"
            end
        end)
    end
end)

destroyButton.MouseButton1Click:Connect(function()
    farmActive = false
    if characterAddedCon then characterAddedCon:Disconnect() end
    removePlatform()
    screenGui:Destroy()
end)

-- ЛОГИКА ТАЙМЕРА АВТО-СТАРТА (5 СЕКУНД)
task.spawn(function()
    for i = 5, 1, -1 do
        if farmActive then break end -- Если пользователь нажал кнопку сам раньше времени
        toggleBtn.Text = "⏳ АВТО-СТАРТ ЧЕРЕЗ: " .. tostring(i)
        task.wait(1)
    end
    if not farmActive then
        activateFarm()
    end
end)
