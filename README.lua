local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local autoFarmActive = false
local currentPlatform = nil

-- Переменные для статистики
local startTime = 0
local totalSessionTime = 0
local goldEarned = 0
local initialGold = nil
local fpsBoostActive = false

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

-- Функция скрытия элементов тела (чтобы вас точно никто не увидел локально)
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
            -- Включаем режим невидимости (скрываем детали персонажа)
            setCharacterVisibility(false)
            
            for _, cframe in ipairs(farmPoints) do
                if not autoFarmActive then break end
                
                -- Подстраховка: отключаем смерть от падения под карту
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                
                spawnPlatform(cframe)
                rootPart.CFrame = cframe
                task.wait(1)
            end
        end
        removePlatform()
        task.wait(1)
    end
    -- Возвращаем видимость при выключении
    setCharacterVisibility(true)
    removePlatform()
end

-- ================= SYSTEMA ANTI-AFK =================
local function enableAntiAFK()
    local vu = game:GetService("VirtualUser")
    localPlayer.Idled:Connect(function()
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

-- ================= UI MENU & STATS =================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FarmToggleGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 190)
mainFrame.Position = UDim2.new(0, 20, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", mainFrame).Color = Color3.fromRGB(60, 60, 60)

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(1, -20, 0, 40)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.BackgroundColor3 = Color3.fromRGB(230, 75, 75)
toggleButton.Text = "AUTO FARM: OFF"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 13
toggleButton.Parent = mainFrame
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 6)

local boostButton = Instance.new("TextButton")
boostButton.Size = UDim2.new(1, -20, 0, 40)
boostButton.Position = UDim2.new(0, 10, 0, 55)
boostButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
boostButton.Text = "FPS BOOST: OFF"
boostButton.TextColor3 = Color3.fromRGB(255, 255, 255)
boostButton.Font = Enum.Font.GothamBold
boostButton.TextSize = 13
boostButton.Parent = mainFrame
Instance.new("UICorner", boostButton).CornerRadius = UDim.new(0, 6)

local timeLabel = Instance.new("TextLabel")
timeLabel.Size = UDim2.new(1, -20, 0, 30)
timeLabel.Position = UDim2.new(0, 10, 0, 110)
timeLabel.BackgroundTransparency = 1
timeLabel.Text = "⏱ Время: 00:00:00"
timeLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
timeLabel.Font = Enum.Font.Gotham
timeLabel.TextSize = 13
timeLabel.TextXAlignment = Enum.TextXAlignment.Left
timeLabel.Parent = mainFrame

local goldLabel = Instance.new("TextLabel")
goldLabel.Size = UDim2.new(1, -20, 0, 30)
goldLabel.Position = UDim2.new(0, 10, 0, 145)
goldLabel.BackgroundTransparency = 1
goldLabel.Text = "💰 Золото: +0"
goldLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
goldLabel.Font = Enum.Font.GothamBold
goldLabel.TextSize = 13
goldLabel.TextXAlignment = Enum.TextXAlignment.Left
goldLabel.Parent = mainFrame

boostButton.MouseButton1Click:Connect(function()
    if not fpsBoostActive then
        fpsBoostActive = true
        boostButton.Text = "FPS BOOST: ACTIVE"
        boostButton.BackgroundColor3 = Color3.fromRGB(46, 114, 184)
        removeTextures()
    end
end)

if goldValue then
    initialGold = goldValue.Value
    goldValue.Changed:Connect(function(newGold)
        if initialGold then
            goldEarned = newGold - initialGold
            if goldEarned < 0 then goldEarned = 0 end
            goldLabel.Text = "💰 Золото: +" .. tostring(goldEarned)
        end
    end)
else
    goldLabel.Text = "💰 Золото: Ошибка данных"
end

task.spawn(function()
    while true do
        if autoFarmActive then
            local elapsed = math.floor(os.time() - startTime) + totalSessionTime
            local hours = math.floor(elapsed / 3600)
            local minutes = math.floor((elapsed % 3600) / 60)
            local seconds = elapsed % 60
            timeLabel.Text = string.format("⏱ Время: %02d:%02d:%02d", hours, minutes, seconds)
        end
        task.wait(1)
    end
end)

toggleButton.MouseButton1Click:Connect(function()
    autoFarmActive = not autoFarmActive
    
    if autoFarmActive then
        toggleButton.Text = "AUTO FARM: ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(46, 184, 114)
        
        if goldValue and not initialGold then
            initialGold = goldValue.Value
        end
        
        startTime = os.time()
        task.spawn(loopAutoFarm)
    else
        toggleButton.Text = "AUTO FARM: OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(230, 75, 75)
        
        totalSessionTime = totalSessionTime + (os.time() - startTime)
        setCharacterVisibility(true)
    end
end)goldLabel.Text = "💰 Золото: +0"
goldLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
goldLabel.Font = Enum.Font.GothamBold
goldLabel.TextSize = 13
goldLabel.TextXAlignment = Enum.TextXAlignment.Left
goldLabel.Parent = mainTabContent

-- КОНТЕНТ «ФУНКЦИИ»
local godModeButton = Instance.new("TextButton")
godModeButton.Size = UDim2.new(1, -20, 0, 35)
godModeButton.Position = UDim2.new(0, 10, 0, 0)
godModeButton.BackgroundColor3 = Color3.fromRGB(230, 75, 75)
godModeButton.Text = "🛡 GOD MODE: OFF"
godModeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
godModeButton.Font = Enum.Font.GothamBold
godModeButton.TextSize = 13
godModeButton.Parent = funcsTabContent
Instance.new("UICorner", godModeButton).CornerRadius = UDim.new(0, 6)

-- Функция для генерации слайдеров
local function createSlider(parent, name, min, max, default, position, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -20, 0, 45)
    sliderFrame.Position = position
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. tostring(default)
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 6)
    track.Position = UDim2.new(0, 0, 0, 25)
    track.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    track.BorderSizePixel = 0
    track.Parent = sliderFrame
    Instance.new("UICorner", track).CornerRadius = UDim.new(0, 3)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(230, 75, 75)
    fill.BorderSizePixel = 0
    fill.Parent = track
    local fillCorner = Instance.new("UICorner", fill)
    fillCorner.CornerRadius = UDim.new(0, 3)

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 14, 0, 14)
    button.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
    button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = ""
    button.Parent = track
    Instance.new("UICorner", button).CornerRadius = UDim.new(1, 0)

    local dragging = false

    local function update(input)
        local inputPosition = input.Position.X
        local trackPosition = track.AbsolutePosition.X
        local trackWidth = track.AbsoluteSize.X
        local percentage = math.clamp((inputPosition - trackPosition) / trackWidth, 0, 1)
        
        button.Position = UDim2.new(percentage, -7, 0.5, -7)
        fill.Size = UDim2.new(percentage, 0, 1, 0)
        
        local value = math.floor(min + (percentage * (max - min)))
        label.Text = name .. ": " .. tostring(value)
        callback(value)
    end

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)

    connections[name .. "InputEnded"] = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    connections[name .. "InputChanged"] = UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    
    return fill
end

-- Создаем ползунок Скорости (Диапазон: 16 - 200)
local speedFill = createSlider(funcsTabContent, "⚡ Скорость", 16, 200, 16, UDim2.new(0, 10, 0, 45), function(value)
    currentWalkSpeed = value
    updateWalkSpeed()
end)

-- Создаем ползунок Гравитации / Прыжка (Диапазон: 20 - 196)
local gravFill = createSlider(funcsTabContent, "🚀 Гравитация", 20, 196, 196, UDim2.new(0, 10, 0, 100), function(value)
    currentGravity = value
    workspace.Gravity = currentGravity
end)


-- ================= UI КНОПКА ШЕСТЕРЕНКА (ПРАВЫЙ НИЖНИЙ УГОЛ) =================
local settingsBtn = Instance.new("TextButton")
settingsBtn.Size = UDim2.new(0, 45, 0, 45)
settingsBtn.Position = UDim2.new(1, -65, 1, -65)
settingsBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
settingsBtn.Text = "⚙️"
settingsBtn.TextSize = 22
settingsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
settingsBtn.Font = Enum.Font.GothamBold
settingsBtn.Parent = screenGui
Instance.new("UICorner", settingsBtn).CornerRadius = UDim.new(0, 10)
local settingsBtnStroke = Instance.new("UIStroke", settingsBtn)
settingsBtnStroke.Color = Color3.fromRGB(70, 70, 70)

local settingsFrame = Instance.new("Frame")
settingsFrame.Size = UDim2.new(0, 200, 0, 150)
settingsFrame.Position = UDim2.new(1, -230, 1, -225)
settingsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
settingsFrame.BorderSizePixel = 0
settingsFrame.Visible = false
settingsFrame.Parent = screenGui
local setCorner = Instance.new("UICorner", settingsFrame)
setCorner.CornerRadius = UDim.new(0, 10)
local setStroke = Instance.new("UIStroke", settingsFrame)
setStroke.Color = Color3.fromRGB(60, 60, 60)

local settingsTitle = Instance.new("TextLabel")
settingsTitle.Size = UDim2.new(1, 0, 0, 30)
settingsTitle.Position = UDim2.new(0, 0, 0, 5)
settingsTitle.BackgroundTransparency = 1
settingsTitle.Text = "Настройки"
settingsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
settingsTitle.Font = Enum.Font.GothamBold
settingsTitle.TextSize = 14
settingsTitle.Parent = settingsFrame

local colorThemeBtn = Instance.new("TextButton")
colorThemeBtn.Size = UDim2.new(1, -20, 0, 35)
colorThemeBtn.Position = UDim2.new(0, 10, 0, 40)
colorThemeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
colorThemeBtn.Text = "🎨 Тема: Темная"
colorThemeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
colorThemeBtn.Font = Enum.Font.GothamBold
colorThemeBtn.TextSize = 12
colorThemeBtn.Parent = settingsFrame
Instance.new("UICorner", colorThemeBtn).CornerRadius = UDim.new(0, 6)

local destroyButton = Instance.new("TextButton")
destroyButton.Size = UDim2.new(1, -20, 0, 35)
destroyButton.Position = UDim2.new(0, 10, 0, 85)
destroyButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
destroyButton.Text = "❌ UNLOAD SCRIPT"
destroyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
destroyButton.Font = Enum.Font.GothamBold
destroyButton.TextSize = 12
destroyButton.Parent = settingsFrame
Instance.new("UICorner", destroyButton).CornerRadius = UDim.new(0, 6)


-- ================= ЛОГИКА НАСТРОЕК И ТЕМЫ =================
settingsBtn.MouseButton1Click:Connect(function()
    settingsFrame.Visible = not settingsFrame.Visible
end)

local currentThemeIndex = 1
local themes = {
    {name = "Темная",  bg = Color3.fromRGB(30, 30, 30),  stroke = Color3.fromRGB(60, 60, 60),  accent = Color3.fromRGB(230, 75, 75)},
    {name = "Синяя",   bg = Color3.fromRGB(20, 35, 60),  stroke = Color3.fromRGB(45, 85, 150), accent = Color3.fromRGB(45, 120, 230)},
    {name = "Зеленая", bg = Color3.fromRGB(20, 50, 35),  stroke = Color3.fromRGB(45, 120, 85), accent = Color3.fromRGB(60, 200, 100)},
    {name = "Пурпур",  bg = Color3.fromRGB(45, 20, 55),  stroke = Color3.fromRGB(110, 50, 140),accent = Color3.fromRGB(160, 60, 220)}
}

colorThemeBtn.MouseButton1Click:Connect(function()
    currentThemeIndex = currentThemeIndex + 1
    if currentThemeIndex > #themes then currentThemeIndex = 1 end
    local theme = themes[currentThemeIndex]
    
    colorThemeBtn.Text = "🎨 Тема: " .. theme.name
    mainFrame.BackgroundColor3 = theme.bg
    mainStroke.Color = theme.stroke
    settingsFrame.BackgroundColor3 = theme.bg
    setStroke.Color = theme.stroke
    settingsBtn.BackgroundColor3 = theme.bg
    settingsBtnStroke.Color = theme.stroke
    
    speedFill.BackgroundColor3 = theme.accent
    gravFill.BackgroundColor3 = theme.accent
end)


-- ================= ЛОГИКА ПЕРЕКЛЮЧЕНИЯ ВКЛАДОК МЕНЮ =================
mainTabBtn.MouseButton1Click:Connect(function()
    mainTabContent.Visible = true
    funcsTabContent.Visible = false
    mainTabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    mainTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    funcsTabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    funcsTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
end)

funcsTabBtn.MouseButton1Click:Connect(function()
    mainTabContent.Visible = false
    funcsTabContent.Visible = true
    funcsTabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    funcsTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    mainTabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    mainTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
end)


-- ================= ЛОГИКА КНОПОК ФУНКЦИОНАЛА =================
godModeButton.MouseButton1Click:Connect(function()
    godModeActive = not godModeActive
    if godModeActive then
        godModeButton.Text = "🛡 GOD MODE: ON"
        godModeButton.BackgroundColor3 = Color3.fromRGB(75, 230, 75)
        applyGodMode()
    else
        godModeButton.Text = "🛡 GOD MODE: OFF"
        godModeButton.BackgroundColor3 = Color3.fromRGB(230, 75, 75)
        local character = localPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.Health = 0 end
    end
end)

toggleButton.MouseButton1Click:Connect(function()
    autoFarmActive = not autoFarmActive
    if autoFarmActive then
        toggleButton.Text = "AUTO FARM: ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(75, 230, 75)
        startTime = os.time()
        task.spawn(loopAutoFarm)
    else
        toggleButton.Text = "AUTO FARM: OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(230, 75, 75)
        totalSessionTime = totalSessionTime + (os.time() - startTime)
    end
end)

boostButton.MouseButton1Click:Connect(function()
    if not fpsBoostActive then
        fpsBoostActive = true
        boostButton.Text = "FPS BOOST: ACTIVE"
        boostButton.BackgroundColor3 = Color3.fromRGB(46, 114, 184)
        removeTextures()
    end
end)

if goldValue then
    initialGold = goldValue.Value
    connections.GoldChanged = goldValue.Changed:Connect(function(newGold)
        if initialGold then
            goldEarned = newGold - initialGold
            if goldEarned < 0 then goldEarned = 0 end
            goldLabel.Text = "💰 Золото: +" .. tostring(goldEarned)
        end
    end)
else
    goldLabel.Text = "💰 Золото: Ошибка данных"
end

-- Поток обновления таймера
local timerRunning = true
task.spawn(function()
    while timerRunning do
        if autoFarmActive then
            local elapsed = math.floor(os.time() - startTime) + totalSessionTime
            local hours = math.floor(elapsed / 3600)
            local minutes = math.floor((elapsed % 3600) / 60)
            local seconds = elapsed % 60
            timeLabel.Text = string.format("⏱ Время: %02d:%02d:%02d", hours, minutes, seconds)
        end
        task.wait(1)
    end
end)

-- ЛОГИКА ПОЛНОГО ЗАКРЫТИЯ (UNLOAD)
destroyButton.MouseButton1Click:Connect(function()
    autoFarmActive = false
    godModeActive = false
    timerRunning = false
    
    workspace.Gravity = 196.2
    currentWalkSpeed = 16
    updateWalkSpeed()
    
    for _, connection in pairs(connections) do
        if connection then connection:Disconnect() end
    end
    
    setCharacterVisibility(true)
    removePlatform()
    screenGui:Destroy()
end)
