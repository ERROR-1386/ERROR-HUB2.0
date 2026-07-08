-- Укажите здесь свой Telegram-канал (измените текст внутри кавычек)
local myTelegramChannel = "t.me/ERROR_HUB_BABFT"

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
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

-- Anti-AFK
local function enableAntiAFK()
    local vu = game:GetService("VirtualUser")
    localPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end
task.spawn(enableAntiAFK)

-- FPS BOOST
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

-- ================= TG NOTIFICATION (BAGE) =================
local function spawnTgNotification()
    local bageFrame = Instance.new("Frame")
    -- Начальная позиция спрятана за правым краем экрана
    bageFrame.Position = UDim2.new(1, 20, 1, -85)
    bageFrame.Size = UDim2.new(0, 220, 0, 65)
    bageFrame.BackgroundColor3 = Color3.fromRGB(0, 136, 204) -- Фирменный цвет Telegram
    bageFrame.BorderSizePixel = 0
    bageFrame.Parent = screenGui
    
    Instance.new("UICorner", bageFrame).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", bageFrame).Color = Color3.fromRGB(255, 255, 255)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 25)
    title.Position = UDim2.new(0, 0, 0, 8)
    title.BackgroundTransparency = 1
    title.Text = "✈ Наш Telegram канал:"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.Parent = bageFrame
    
    local channelText = Instance.new("TextLabel")
    channelText.Size = UDim2.new(1, 0, 0, 25)
    channelText.Position = UDim2.new(0, 0, 0, 28)
    channelText.BackgroundTransparency = 1
    channelText.Text = myTelegramChannel
    channelText.TextColor3 = Color3.fromRGB(255, 255, 100) -- Подсветим желтым для акцента
    channelText.Font = Enum.Font.GothamBold
    channelText.TextSize = 14
    channelText.Parent = bageFrame

    -- Анимация появления (выплывает справа налево)
    local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local targetPosIn = UDim2.new(1, -240, 1, -85)
    local tweenIn = TweenService:Create(bageFrame, tweenInfo, {Position = targetPosIn})
    tweenIn:Play()
    
    -- Ждем 5 секунд и прячем обратно
    task.wait(5)
    
    local tweenInfoOut = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    local targetPosOut = UDim2.new(1, 20, 1, -85)
    local tweenOut = TweenService:Create(bageFrame, tweenInfoOut, {Position = targetPosOut})
    tweenOut:Play()
    
    tweenOut.Completed:Connect(function()
        bageFrame:Destroy()
    end)
end

-- Сразу запускаем показ уведомления при инжекте
task.spawn(spawnTgNotification)

-- Логика кнопок
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
local seconds = elapsed % 60timeLabel.Text = string.format("⏱ Время: %02d:%02d:%02d", hours, minutes, seconds)endtask.wait(1)endend)toggleButton.MouseButton1Click:Connect(function()autoFarmActive = not autoFarmActiveif autoFarmActive thentoggleButton.Text = "AUTO FARM: ON"toggleButton.BackgroundColor3 = Color3.fromRGB(46, 184, 114)if goldValue and not initialGold theninitialGold = goldValue.ValueendstartTime = os.time()task.spawn(loopAutoFarm)elsetoggleButton.Text = "AUTO FARM: OFF"toggleButton.BackgroundColor3 = Color3.fromRGB(230, 75, 75)totalSessionTime = totalSessionTime + (os.time() - startTime)setCharacterVisibility(true)endend)
