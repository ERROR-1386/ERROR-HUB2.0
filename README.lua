local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local autoFarmActive = false
local godModeActive = false
local currentPlatform = nil

-- Настройки ползунков по умолчанию
local currentWalkSpeed = 16
local currentGravity = 196.2

-- Переменные для статистики
local startTime = 0
local totalSessionTime = 0
local goldEarned = 0
local initialGold = nil
local fpsBoostActive = false

-- Хранилище для подключений
local connections = {}

-- Поиск значения золота в данных игрока
local goldValue = localPlayer:FindFirstChild("Data") and localPlayer.Data:FindFirstChild("Gold") or localPlayer:WaitForChild("leaderstats", 5) and localPlayer.leaderstats:FindFirstChild("Gold")

local farmPoints = {
    CFrame.new(-135.058548, 71.5735931, 1389.66492, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    CFrame.new(-121.212387, 94.811821, 2182.42432, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    CFrame.new(-107.262383, 99.8945236, 3749.67578, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    CFrame.new(-113.035942, 90.1609573, 2992.92114, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    CFrame.new(-105.003433, 85.6560287, 4493.32178, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    CFrame.new(-103.476631, 94.9249115, 5260.82812, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    CFrame.new(-104.277824, 86.4904175, 6019.4126, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    CFrame.new(-125.980156, 65.571907, 6894.36279, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    CFrame.new(-116.013321, 39.0258293, 7561.04346, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    CFrame.new(-52.2332153, -361.735779, 9284.8623, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    CFrame.new(-52.9334259, -361.626831, 9489.81543, 1, 0, 0, 0, 1, 0, 0, 0, 1)
}

local function removePlatform()
    if currentPlatform then
        currentPlatform:Destroy()
        currentPlatform = nil
    end
end

local function spawnPlatform(cframe)
    removePlatform()
    local part = Instance.new("Part")
    part.Size = Vector3.new(10, 1, 10)
    part.CFrame = cframe * CFrame.new(0, -3.5, 0)
    part.Anchored = true
    part.Transparency = 0.5
    part.Color = Color3.fromRGB(255, 30, 30)
    part.Material = Enum.Material.Neon
    part.Parent = workspace
    currentPlatform = part
end

local function setCharacterVisibility(visible)
    local character = localPlayer.Character
    if character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                if part.Name ~= "HumanoidRootPart" then
                    part.Transparency = visible and 0 or 1
                end
            end
        end
    end
end

local function loopAutoFarm()
    while autoFarmActive do
        local character = localPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        
        if rootPart and rootPart.Parent and humanoid then
            setCharacterVisibility(false)
            for _, cframe in ipairs(farmPoints) do
                if not autoFarmActive then break end
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                spawnPlatform(cframe)
                rootPart.CFrame = cframe
                task.wait(1)
            end
        end
        removePlatform()
        task.wait(1)
    end
    setCharacterVisibility(true)
    removePlatform()
end

-- ЛОГИКА БЕССМЕРТИЯ
local function applyGodMode()
    if not godModeActive then return end
    local character = localPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local scriptHealth = character:FindFirstChild("Health")
            if scriptHealth then scriptHealth:Destroy() end
        end
    end
end

-- Обновление скорости персонажа
local function updateWalkSpeed()
    local character = localPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = currentWalkSpeed
    end
end

connections.CharacterAdded = localPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if godModeActive then applyGodMode() end
    updateWalkSpeed() -- Возвращаем скорость после смерти
end)

-- Постоянная проверка скорости (защита от сброса игрой)
connections.SpeedLoop = RunService.RenderStepped:Connect(function()
    local character = localPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.WalkSpeed ~= currentWalkSpeed and not autoFarmActive then
        humanoid.WalkSpeed = currentWalkSpeed
    end
end)

-- ================= SYSTEMA ANTI-AFK =================
local function enableAntiAFK()
    local vu = game:GetService("VirtualUser")
    connections.AntiAFK = localPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end
task.spawn(enableAntiAFK)

-- ================= OPTIMIZATION FUNCTION =================
local function removeTextures()
    game:GetService("Lighting").GlobalShadows = false
    for _, effect in ipairs(game:GetService("Lighting"):GetChildren()) do
        if effect:IsA("PostEffect") or effect:IsA("Atmosphere") or effect:IsA("Sky") or effect:IsA("Clouds") then
            effect:Destroy()
        end
    end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj ~= currentPlatform then
            obj.Material = Enum.Material.SmoothPlastic
            obj.Reflectance = 0
            obj.CastShadow = false
        elseif obj:IsA("Texture") or obj:IsA("Decal") then
            obj:Destroy()
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Fire") then
            obj:Destroy()
        end
    end
end

-- ================= UI MENU =================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FarmToggleGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Главный фрейм (Высота увеличена до 270 для размещения слайдеров)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 270)
mainFrame.Position = UDim2.new(0, 20, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0, 10)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(60, 60, 60)

-- ================= КНОПКИ ВКЛАДОК =================
local tabNavFrame = Instance.new("Frame")
tabNavFrame.Size = UDim2.new(1, -20, 0, 30)
tabNavFrame.Position = UDim2.new(0, 10, 0, 10)
tabNavFrame.BackgroundTransparency = 1
tabNavFrame.Parent = mainFrame

local mainTabBtn = Instance.new("TextButton")
mainTabBtn.Size = UDim2.new(0.5, -5, 1, 0)
mainTabBtn.Position = UDim2.new(0, 0, 0, 0)
mainTabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
mainTabBtn.Text = "Главная"
mainTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
mainTabBtn.Font = Enum.Font.GothamBold
mainTabBtn.TextSize = 12
mainTabBtn.Parent = tabNavFrame
Instance.new("UICorner", mainTabBtn).CornerRadius = UDim.new(0, 5)

local funcsTabBtn = Instance.new("TextButton")
funcsTabBtn.Size = UDim2.new(0.5, -5, 1, 0)
funcsTabBtn.Position = UDim2.new(0.5, 5, 0, 0)
funcsTabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
funcsTabBtn.Text = "Функции"
funcsTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
funcsTabBtn.Font = Enum.Font.GothamBold
funcsTabBtn.TextSize = 12
funcsTabBtn.Parent = tabNavFrame
Instance.new("UICorner", funcsTabBtn).CornerRadius = UDim.new(0, 5)

-- ================= КОНТЕНТ ВКЛАДОК =================
local mainTabContent = Instance.new("Frame")
mainTabContent.Size = UDim2.new(1, 0, 1, -50)
mainTabContent.Position = UDim2.new(0, 0, 0, 50)
mainTabContent.BackgroundTransparency = 1
mainTabContent.Parent = mainFrame

local funcsTabContent = Instance.new("Frame")
funcsTabContent.Size = UDim2.new(1, 0, 1, -50)
funcsTabContent.Position = UDim2.new(0, 0, 0, 50)
funcsTabContent.BackgroundTransparency = 1
funcsTabContent.Visible = false
funcsTabContent.Parent = mainFrame

-- КОНТЕНТ «ГЛАВНАЯ»
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(1, -20, 0, 35)
toggleButton.Position = UDim2.new(0, 10, 0, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(230, 75, 75)
toggleButton.Text = "AUTO FARM: OFF"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 13
toggleButton.Parent = mainTabContent
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 6)

local boostButton = Instance.new("TextButton")
boostButton.Size = UDim2.new(1, -20, 0, 35)
boostButton.Position = UDim2.new(0, 10, 0, 45)
boostButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
boostButton.Text = "FPS BOOST: OFF"
boostButton.TextColor3 = Color3.fromRGB(255, 255, 255)
boostButton.Font = Enum.Font.GothamBold
boostButton.TextSize = 13
boostButton.Parent = mainTabContent
Instance.new("UICorner", boostButton).CornerRadius = UDim.new(0, 6)

local timeLabel = Instance.new("TextLabel")
timeLabel.Size = UDim2.new(1, -20, 0, 25)
timeLabel.Position = UDim2.new(0, 10, 0, 90)
timeLabel.BackgroundTransparency = 1
timeLabel.Text = "⏱ Время: 00:00:00"
timeLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
timeLabel.Font = Enum.Font.Gotham
timeLabel.TextSize = 13
timeLabel.TextXAlignment = Enum.TextXAlignment.Left
timeLabel.Parent = mainTabContent

local goldLabel = Instance.new("TextLabel")
goldLabel.Size = UDim2.new(1, -20, 0, 25)
goldLabel.Position = UDim2.new(0, 10, 0, 115)
goldLabel.BackgroundTransparency = 1
