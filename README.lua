local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- ================= НАСТРОЙКА ТЕЛЕГРАМ БОТА =================
local BOT_TOKEN = "8256880007:AAF5a55OKdA2QuNHCi9mpxu8-w90dVgc-jA" -- Токен от @BotFather
local CHAT_ID = "7901967306"      -- Твой Telegram ID (цифры)
-- ==========================================================

local autoFarmActive = false
local currentPlatform = nil

-- Статистика
local startTime = 0
local totalSessionTime = 0
local goldEarned = 0
local initialGold = nil
local fpsBoostActive = false

-- Генерация случайного ключа для текущей сессии
local function generateRandomKey()
    local chars = "ABCDEFGHJKLMNOPQRSTUVWXYZ123456789"
    local length = 8
    local key = "KEY-"
    for i = 1, length do
        local rand = math.random(1, #chars)
        key = key .. string.sub(chars, rand, rand)
    end
    return key
end

local CORRECT_KEY = generateRandomKey()

-- Функция отправки сообщения в Telegram
local function sendKeyToTelegram()
    local message = string.format(
        "🔔 *Новый запрос ключа!*\n\n👤 Игрок: `%s`\n🔑 Ключ для него: `%s`",
        localPlayer.Name,
        CORRECT_KEY
    )
    
    local url = "https://api.telegram.org/bot" .. BOT_TOKEN .. "/sendMessage"
    local payload = HttpService:JSONEncode({
        chat_id = CHAT_ID,
        text = message,
        parse_mode = "Markdown"
    })
    
    -- Выполняем скрытый HTTP-запрос (поддерживается большинством инжекторов)
    pcall(function()
        if syn and syn.request then
            syn.request({Url = url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = payload})
        elseif http and http.request then
            http.request({Url = url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = payload})
        elseif fluxus and fluxus.request then
            fluxus.request({Url = url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = payload})
        else
            -- Стандартный способ для некоторых эксплойтов
            local request = request or http_request
            if request then
                request({Url = url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = payload})
            end
        end
    end)
end

-- Отправляем ключ создателю сразу при старте скрипта
task.spawn(sendKeyToTelegram)

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

-- Anti-AFK
task.spawn(function()
    local vu = game:GetService("VirtualUser")
    localPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end)

-- Оптимизация текстур
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
        elseif obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("ParticleEmitter") then
            obj:Destroy()
        end
    end
end

-- ================= СОЗДАНИЕ ГЛАВНОГО МЕНЮ (Изначально скрыто) =================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FarmToggleGui"
screenGui.ResetOnSpawn = false

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
if goldValue and not initialGold then initialGold = goldValue.Value endstartTime = os.time()task.spawn(loopAutoFarm)elsetoggleButton.Text = "AUTO FARM: OFF"toggleButton.BackgroundColor3 = Color3.fromRGB(230, 75, 75)totalSessionTime = totalSessionTime + (os.time() - startTime)setCharacterVisibility(true)endend)-- ================= ОКНО КЛЮЧ-СИСТЕМЫ (KEY SYSTEM UI) =================local keyGui = Instance.new("ScreenGui")keyGui.Name = "KeySystemGui"keyGui.ResetOnSpawn = falsekeyGui.Parent = playerGuilocal keyFrame = Instance.new("Frame")keyFrame.Size = UDim2.new(0, 240, 0, 130)keyFrame.Position = UDim2.new(0.5, -120, 0.4, -65)keyFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)keyFrame.BorderSizePixel = 0keyFrame.Parent = keyGuiInstance.new("UICorner", keyFrame).CornerRadius = UDim.new(0, 8)Instance.new("UIStroke", keyFrame).Color = Color3.fromRGB(80, 80, 80)local keyTitle = Instance.new("TextLabel")keyTitle.Size = UDim2.new(1, 0, 0, 35)keyTitle.BackgroundTransparency = 1keyTitle.Text = "🔑 Введите Ключ Доступа"keyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)keyTitle.Font = Enum.Font.GothamBoldkeyTitle.TextSize = 13keyTitle.Parent = keyFramelocal keyInput = Instance.new("TextBox")keyInput.Size = UDim2.new(1, -30, 0, 35)keyInput.Position = UDim2.new(0, 15, 0, 40)keyInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)keyInput.Text = ""keyInput.PlaceholderText = "Вставьте ключ сюда..."keyInput.TextColor3 = Color3.fromRGB(255, 255, 255)keyInput.Font = Enum.Font.GothamkeyInput.TextSize = 12keyInput.Parent = keyFrameInstance.new("UICorner", keyInput).CornerRadius = UDim.new(0, 5)local checkButton = Instance.new("TextButton")checkButton.Size = UDim2.new(1, -30, 0, 35)checkButton.Position = UDim2.new(0, 15, 0, 85)checkButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)checkButton.Text = "ПРОВЕРИТЬ КЛЮЧ"checkButton.TextColor3 = Color3.fromRGB(255, 255, 255)checkButton.Font = Enum.Font.GothamBoldcheckButton.TextSize = 12checkButton.Parent = keyFrameInstance.new("UICorner", checkButton).CornerRadius = UDim.new(0, 5)-- Проверка введенного значенияcheckButton.MouseButton1Click:Connect(function()if keyInput.Text == CORRECT_KEY thenkeyGui:Destroy() -- Удаляем окно ключаscreenGui.Parent = playerGui -- Показываем основное меню читаelsekeyInput.Text = ""keyInput.PlaceholderText = "❌ НЕВЕРНЫЙ КЛЮЧ!"keyFrame.UIStroke.Color = Color3.fromRGB(255, 50, 50)task.wait(1.5)keyInput.PlaceholderText = "Вставьте ключ сюда..."keyFrame.UIStroke.Color = Color3.fromRGB(80, 80, 80)endend)
