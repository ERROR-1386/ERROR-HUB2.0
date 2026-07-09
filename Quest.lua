local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local replicatedStorage = game:GetService("ReplicatedStorage")

-- Координаты целей для мгновенного выполнения квестов
local questPositions = {
    ["Cloud"]  = Vector3.new(-120, 100, 2180), -- Координаты зоны Облака
    ["Target"] = Vector3.new(-105, 95, 3750),  -- Координаты зоны Мишени
    ["Ramp"]   = Vector3.new(-113, 90, 2990)   -- Координаты зоны Трамплина
}

-- Безопасная функция активации квеста на сервере
local function tryActivateQuest(questName)
    local success, err = pcall(function()
        local remoteEvents = replicatedStorage:FindFirstChild("RemoteEvents")
        if remoteEvents then
            local selectQuest = remoteEvents:FindFirstChild("SelectQuest") or remoteEvents:FindFirstChild("SetQuest")
            if selectQuest and selectQuest:IsA("RemoteEvent") then
                selectQuest:FireServer(questName)
                return true
            end
        end

        local directEvent = replicatedStorage:FindFirstChild("SelectQuest") or replicatedStorage:FindFirstChild("SetQuest")
        if directEvent and directEvent:IsA("RemoteEvent") then
            directEvent:FireServer(questName)
            return true
        end

        for _, obj in ipairs(replicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") and (obj.Name == "SelectQuest" or obj.Name == "SetQuest") then
                obj:FireServer(questName)
                return true
            end
        end
    end)
    return success
end

-- Функция мгновенного телепорта и выполнения квеста
local function teleportToQuest(questName)
    local character = localPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    local targetPos = questPositions[questName]

    if rootPart and targetPos then
        -- Сохраняем твою позицию, чтобы вернуть обратно
        local oldCFrame = rootPart.CFrame
        
        -- Телепортируемся к квесту
        rootPart.CFrame = CFrame.new(targetPos)
        task.wait(1.2) -- Ждем секунду, чтобы игра засчитала выполнение
        
        -- Возвращаемся обратно на спавн/базу
        rootPart.CFrame = oldCFrame
    end
end

-- ================= ИНТЕРФЕЙС GUI =================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoQuestActivator"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 195)
mainFrame.Position = UDim2.new(0, 20, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(60, 60, 60)

-- Функция для генерации кнопок квестов
local function createButton(text, questName, order, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, 15 + (order * 40))
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.Parent = mainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        btn.Text = "⏳ ЗАПУСК И ТЕЛЕПОРТ..."
        task.wait(0.2)
        
        local activated = tryActivateQuest(questName)
        if activated then
            btn.Text = "✨ ВЫПОЛНЯЕТСЯ..."
            btn.BackgroundColor3 = Color3.fromRGB(75, 230, 75)
            
            -- Запускаем авто-телепорт и выполнение
            task.spawn(function()
                teleportToQuest(questName)
            end)
        else
            btn.Text = "❌ ОШИБКА АКТИВАЦИИ"
            btn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        end
        
        task.wait(2)
        btn.Text = text
        btn.BackgroundColor3 = color
    end)
end

-- Создаем кнопки для квестов с авто-телепортом
createButton("☁️ КВЕСТ + АВТО: ОБЛАКО", "Cloud", 0, Color3.fromRGB(70, 130, 180))
createButton("🎯 КВЕСТ + АВТО: МИШЕНЬ", "Target", 1, Color3.fromRGB(180, 70, 70))
createButton("📐 КВЕСТ + АВТО: ТРАМПЛИН", "Ramp", 2, Color3.fromRGB(130, 70, 180))

-- Кнопка полного закрытия (UNLOAD)
local destroyButton = Instance.new("TextButton")
destroyButton.Size = UDim2.new(1, -20, 0, 30)
destroyButton.Position = UDim2.new(0, 10, 1, -40)
destroyButton.BackgroundColor3 = Color3.fromRGB(130, 25, 25)
destroyButton.Text = "❌ UNLOAD SCRIPT"
destroyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
destroyButton.Font = Enum.Font.GothamBold
destroyButton.TextSize = 11
destroyButton.Parent = mainFrame
Instance.new("UICorner", destroyButton).CornerRadius = UDim.new(0, 6)

destroyButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)
