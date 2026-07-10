-- Подключение сервисов
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Удаление старого GUI, если оно запущено
if PlayerGui:FindFirstChild("MM2MenuGui") then
    PlayerGui.MM2MenuGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2MenuGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Главное окно меню
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 360, 0, 270)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -135)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Скругление углов
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Зеленый градиент по краю
local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 3
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Parent = MainFrame

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 150, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 100))
})
UIGradient.Parent = UIStroke

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "MM2 Premium Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- ПЕРЕМЕННЫЕ СОСТОЯНИЯ
local espActive = false
local farmActive = false
local flying = false
local flySpeed = 40
local noclip = false

-- Функция создания шаблона кнопок
local function createButton(name, text, pos)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0, 150, 0, 35)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 15
    btn.Parent = MainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

-- Создание кнопок и полей ввода
local EspButton = createButton("EspButton", "ESP (Рентген): ВЫКЛ", UDim2.new(0, 20, 0, 55))
local FarmButton = createButton("FarmButton", "Авто-сбор монет: ВЫКЛ", UDim2.new(0, 190, 0, 55))
local FlyButton = createButton("FlyButton", "Полет: ВЫКЛ", UDim2.new(0, 20, 0, 105))

local FlySpeedInput = Instance.new("TextBox")
FlySpeedInput.Size = UDim2.new(0, 150, 0, 30)
FlySpeedInput.Position = UDim2.new(0, 20, 0, 150)
FlySpeedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FlySpeedInput.Text = "Скорость полета: 40"
FlySpeedInput.TextColor3 = Color3.fromRGB(200, 200, 200)
FlySpeedInput.Font = Enum.Font.SourceSans
FlySpeedInput.TextSize = 13
FlySpeedInput.Parent = MainFrame
Instance.new("UICorner", FlySpeedInput).CornerRadius = UDim.new(0, 6)

local NoclipButton = createButton("NoclipButton", "Ноуклип: ВЫКЛ", UDim2.new(0, 190, 0, 105))
local GunButton = createButton("GunButton", "ТП к пистолету", UDim2.new(0, 190, 0, 150))

-- Подпись снизу
local Credits = Instance.new("TextLabel")
Credits.Size = UDim2.new(1, 0, 0, 40)
Credits.Position = UDim2.new(0, 0, 1, -45)
Credits.BackgroundTransparency = 1
Credits.Text = "Управление полетом адаптировано под мобильный джойстик.\nESP подсвечивает роли: Красный — Убийца, Синий — Шериф."
Credits.TextColor3 = Color3.fromRGB(160, 160, 160)
Credits.TextSize = 11
Credits.Font = Enum.Font.SourceSansItalic
Credits.Parent = MainFrame

-- ==================== ЛОГИКА 1. ESP (РЕНТГЕН РОЛЕЙ) ====================
local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local char = player.Character
            local hrp = char.HumanoidRootPart
            
            -- Удаляем старую подсветку
            if hrp:FindFirstChild("RoleHighlight") then hrp.RoleHighlight:Destroy() end
            
            if espActive then
                local highlight = Instance.new("BoxHandleAdornment")
                highlight.Name = "RoleHighlight"
                highlight.Size = Vector3.new(2, 4.5, 2)
                highlight.AlwaysOnTop = true
                highlight.ZIndex = 5
                highlight.Adornee = hrp
                highlight.Parent = hrp
                
                -- Определение роли по оружию в инвентаре/руках
                local isMurder = player.Backpack:FindFirstChild("Knife") or char:FindFirstChild("Knife")
                local isSheriff = player.Backpack:FindFirstChild("Gun") or char:FindFirstChild("Gun")
                
                if isMurder then
                    highlight.Color3 = Color3.fromRGB(255, 0, 0) -- Красный для Убийцы
                elseif isSheriff then
                    highlight.Color3 = Color3.fromRGB(0, 100, 255) -- Синий для Шерифа
                else
                    highlight.Color3 = Color3.fromRGB(255, 255, 255) -- Белый для Мирных
                end
            end
        end
    end
end

EspButton.MouseButton1Click:Connect(function()
    espActive = not espActive
    if espActive then
        EspButton.Text = "ESP (Рентген): ВКЛ"
        EspButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        EspButton.Text = "ESP (Рентген): ВЫКЛ"
        EspButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
    updateESP()
end)
RunService.Heartbeat:Connect(function() if espActive then updateESP() end end)

-- ==================== ЛОГИКА 2. АВТО-СБОР МОНЕТ ====================
FarmButton.MouseButton1Click:Connect(function()
    farmActive = not farmActive
    if farmActive then
        FarmButton.Text = "Авто-сбор монет: ВКЛ"
        FarmButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        
        task.spawn(function()
            while farmActive do
                task.wait(0.2)
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    -- Ищем контейнер с монетами на карте MM2
                    local coinContainer = Workspace:FindFirstChild("Normal") or Workspace:FindFirstChild("CoinContainer")
                    if coinContainer then
                        for _, coin in ipairs(coinContainer:GetDescendants()) do
                            if coin:IsA("BasePart") and (coin.Name == "Coin_Sub" or coin.Name == "GoldCoin") then
                                -- ТП к монете
                                char.HumanoidRootPart.CFrame = coin.CFrame
                                task.wait(0.1) -- Задержка против кика за скорость
                                if not farmActive then break end
                            end
                        end
                    end
                end
            end
        end)
    else
        FarmButton.Text = "Авто-сбор монет: ВЫКЛ"
        FarmButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
end)

-- ==================== ЛОГИКА 3. УЛУЧШЕННЫЙ ПОЛЕТ ДЛЯ МОБИЛЬНЫХ ====================
local bodyVelocity, bodyGyro
FlyButton.MouseButton1Click:Connect(function()
    flying = not flying
    if flying then
        FlyButton.Text = "Полет: ВКЛ"
        FlyButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")
        local humanoid = character:WaitForChild("Humanoid")
        
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = rootPart
        
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        bodyGyro.CFrame = rootPart.CFrame
        bodyGyro.Parent = rootPart
        
        task.spawn(function()
            local camera = Workspace.CurrentCamera
            while flying do
                RunService.RenderStepped:Wait()
                local moveDir = humanoid.MoveDirection
                
                if moveDir.Magnitude > 0 then
                    local lookVector = camera.CFrame.LookVector
                    local flyVector = camera.CFrame:VectorToWorldSpace(Vector3.new(moveDir.X, 0, moveDir.Z))
                    
                    if moveDir:Dot(camera.CFrame.LookVector) > 0 then
                        bodyVelocity.Velocity = lookVector * flySpeed
                    else
                        bodyVelocity.Velocity = flyVector.Unit * flySpeed
                    end
                else
                    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                end
                bodyGyro.CFrame = camera.CFrame
            end
        end)
    else
        FlyButton.Text = "Полет: ВЫКЛ"
        FlyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
    end
end)

FlySpeedInput.FocusLost:Connect(function()
    local text = FlySpeedInput.Text:gsub("%D+", "")
    local num = tonumber(text)
    if num then flySpeed = num FlySpeedInput.Text = "Скорость полета: " .. num
    else FlySpeedInput.Text = "Скорость полета: " .. flySpeed end
end)

-- ==================== ЛОГИКА 4. НОУКЛИП ====================
NoclipButton.MouseButton1Click:Connect(function()
    noclip = not noclip
    if noclip then
        NoclipButton.Text = "Ноуклип: ВКЛ"
        NoclipButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        -- Сброс текста и цвета кнопки ноуклипа при выключении
        NoclipButton.Text = "Ноуклип: ВЫКЛ"
        NoclipButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
end)

-- Постоянное отключение коллизий во время шагов физики (RunService)
RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- ==================== ЛОГИКА 5. ТЕЛЕПОРТ К ОРУЖИЮ ШЕРИФА ====================
GunButton.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        -- Быстрый поиск упавшего пистолета на карте
        local droppedGun = Workspace:FindFirstChild("GunDrop") or Workspace:FindFirstChild("Gun")
        
        if droppedGun and droppedGun:IsA("BasePart") then
            char.HumanoidRootPart.CFrame = droppedGun.CFrame + Vector3.new(0, 2, 0)
        else
            -- Глубокий альтернативный поиск по названию в дебрях карты
            local found = false
            for _, object in ipairs(Workspace:GetDescendants()) do
                if object.Name == "GunDrop" and object:IsA("BasePart") then
                    char.HumanoidRootPart.CFrame = object.CFrame + Vector3.new(0, 2, 0)
                    found = true
                    break
                end
            end
            
            if not found then
                -- Визуальный отклик на кнопке, если шериф еще жив или пистолет не выпал
                local originalText = GunButton.Text
                GunButton.Text = "Пистолет не найден"
                task.wait(1)
                GunButton.Text = originalText
            end
        end
    end
end)
