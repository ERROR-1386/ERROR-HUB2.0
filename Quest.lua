local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local replicatedStorage = game:GetService("ReplicatedStorage")

-- Функция поиска и отправки ивента квеста
local function activateQuest(questName)
    local questEvent = replicatedStorage:FindFirstChild("SelectQuest") or replicatedStorage:FindFirstChild("SetQuest")
    
    if replicatedStorage:FindFirstChild("RemoteEvents") then
        local re = replicatedStorage.RemoteEvents
        questEvent = re:FindFirstChild("SelectQuest") or re:FindFirstChild("SetQuest") or questEvent
    end

    if questEvent and questEvent:IsA("RemoteEvent") then
        questEvent:FireServer(questName)
        return true
    else
        for _, obj in ipairs(replicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") and (obj.Name == "SelectQuest" or obj.Name == "SetQuest") then
                obj:FireServer(questName)
                return true
            end
        end
    end
    return false
end

-- ================= ИНТЕРФЕЙС GUI =================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SecretQuestGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 200)
mainFrame.Position = UDim2.new(0, 20, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(60, 60, 60)

-- Функция для быстрого создания кнопок квестов
local function createQuestButton(text, questName, posIndex, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, 15 + (posIndex * 40))
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.Parent = mainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        local success = activateQuest(questName)
        if success then
            btn.Text = "✨ УСПЕШНО ЗАПУЩЕН!"
            btn.BackgroundColor3 = Color3.fromRGB(75, 230, 75)
            task.wait(1.5)
            btn.Text = text
            btn.BackgroundColor3 = color
        else
            btn.Text = "❌ ОШИБКА ИВЕНТА"
            btn.BackgroundColor3 = Color3.fromRGB(230, 75, 75)
            task.wait(1.5)
            btn.Text = text
            btn.BackgroundColor3 = color
        end
    end)
end

-- Создаем кнопки для РАБОЧИХ старых квестов
createQuestButton("☁️ КВЕСТ: ОБЛАКО (CLOUD)", "Cloud", 0, Color3.fromRGB(70, 130, 180))
createQuestButton("🎯 КВЕСТ: МИШЕНЬ (TARGET)", "Target", 1, Color3.fromRGB(180, 70, 70))
createQuestButton("📐 КВЕСТ: ТРАМПЛИН (RAMP)", "Ramp", 2, Color3.fromRGB(130, 70, 180))

-- Кнопка полного закрытия (UNLOAD)
local destroyButton = Instance.new("TextButton")
destroyButton.Size = UDim2.new(1, -20, 0, 30)
destroyButton.Position = UDim2.new(0, 10, 1, -40)
destroyButton.BackgroundColor3 = Color3.fromRGB(120, 20, 20)
destroyButton.Text = "❌ UNLOAD SCRIPT"
destroyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
destroyButton.Font = Enum.Font.GothamBold
destroyButton.TextSize = 11
destroyButton.Parent = mainFrame
Instance.new("UICorner", destroyButton).CornerRadius = UDim.new(0, 6)

destroyButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)
