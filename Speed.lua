local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local coreGui = game:GetService("CoreGui")

-- Защита от дублирования интерфейса
if coreGui:FindFirstChild("MaxSpeedGoldFarmGui") then
    coreGui.MaxSpeedGoldFarmGui:Destroy()
end

local farmActive = false
local totalGoldEarned = 0
local initialGold = nil

-- Предельно точные координаты центров стадий для мгновенной фиксации прохода
local fastStagePoints = {
    Vector3.new(-100, 50, 600),
    Vector3.new(-100, 50, 1400),
    Vector3.new(-100, 50, 2200),
    Vector3.new(-100, 50, 3000),
    Vector3.new(-100, 50, 3800),
    Vector3.new(-100, 50, 4600),
    Vector3.new(-100, 50, 5400),
    Vector3.new(-100, 50, 6200),
    Vector3.new(-100, 50, 7000),
    Vector3.new(-100, 50, 7800),
    Vector3.new(-52, -360, 9490) -- Финальный сундук [8]
}

local goldValue = localPlayer:FindFirstChild("leaderstats") and localPlayer.leaderstats:FindFirstChild("Gold")

-- Логика экстремального авто-фарма
local function startMaxSpeedFarm()
    while farmActive do
        local character = localPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        
        if root and humanoid and humanoid.Health > 0 then
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            
            for i, point in ipairs(fastStagePoints) do
                if not farmActive then break end
                
                root.CFrame = CFrame.new(point)
                
                -- ЭКСТРЕМАЛЬНЫЙ ТАЙМИНГ: 1.6 секунды на зону для разгона до 37к/час [8]
                task.wait(1.6) 
            end
            
            -- Минимальное время на перезагрузку карты сервером [8]
            task.wait(2.5)
        else
            task.wait(0.5)
        end
    end
end

-- ================= ИНТЕРФЕЙС GUI =================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MaxSpeedGoldFarmGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = coreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 160)
mainFrame.Position = UDim2.new(0, 30, 0, 120)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Более темный агрессивный дизайн
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(150, 0, 0) -- Красная обводка режима берсерка

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 10)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🔥 MAX SPEED FARM (37K/h)"
titleLabel.TextColor3 = Color3.fromRGB(255, 75, 75)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 12
titleLabel.Parent = mainFrame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -30, 0, 40)
toggleBtn.Position = UDim2.new(0, 15, 0, 45)
toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
toggleBtn.Text = "РАЗГОН: ВЫКЛ"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 12
toggleBtn.Parent = mainFrame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, -30, 0, 25)
statsLabel.Position = UDim2.new(0, 15, 0, 95)
statsLabel.BackgroundTransparency = 1
statsLabel.Text = "💰 Скорость: +0 золота"
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

-- ================= ЛОГИКА =================

toggleBtn.MouseButton1Click:Connect(function()
    farmActive = not farmActive
    if farmActive then
        toggleBtn.Text = "ФАРМ НА МАКСИМУМЕ"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        
        if goldValue and not initialGold then
            initialGold = goldValue.Value
        end
        
        task.spawn(startMaxSpeedFarm)
    else
        toggleBtn.Text = "РАЗГОН: ВЫКЛ"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
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

-- Встроенная система Anti-AFK
local function initAntiAFK()
    local vu = game:GetService("VirtualUser")
    localPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end
task.spawn(initAntiAFK)

destroyButton.MouseButton1Click:Connect(function()
    farmActive = false
    screenGui:Destroy()
end)
