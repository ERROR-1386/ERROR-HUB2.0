local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Удаление старой панели, если она была
if PlayerGui:FindFirstChild("DisasterMenuGui") then
    PlayerGui.DisasterMenuGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DisasterMenuGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Главное окно меню (увеличено по высоте для новых функций)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 360, 0, 310)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -155)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 14)
UICorner.Parent = MainFrame

-- Зеленый градиент по краю
local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 3
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Parent = MainFrame

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 120, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 100))
})
UIGradient.Parent = UIStroke

-- Заголовок меню
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "NDS God Menu (Mobile)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- ПЕРЕМЕННЫЕ УПРАВЛЕНИЯ
local flying = false
local noclip = false
local flySpeed = 50
local tornadoActive = false
local tornadoRadius = 60
local tornadoSpeed = 15

-- ФУНКЦИЯ ДЛЯ СОЗДАНИЯ КНОПОК И ТЕКСТБОКСОВ (Оптимизация стиля)
local function createButton(text, pos, size)
    local btn = Instance.new("TextButton")
    btn.Size = size or UDim2.new(0, 150, 0, 35)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Parent = MainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local function createTextBox(text, pos, size)
    local box = Instance.new("TextBox")
    box.Size = size or UDim2.new(0, 150, 0, 30)
    box.Position = pos
    box.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    box.Text = text
    box.TextColor3 = Color3.fromRGB(200, 200, 200)
    box.Font = Enum.Font.SourceSans
    box.TextSize = 14
    box.Parent = MainFrame
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
    return box
end

-- СОЗДАНИЕ ЭЛЕМЕНТОВ ИНТЕРФЕЙСА
local FlyButton = createButton("Полет: ВЫКЛ", UDim2.new(0, 20, 0, 50))
local NoclipButton = createButton("Ноуклип: ВЫКЛ", UDim2.new(0, 20, 0, 95))
local FlySpeedInput = createTextBox("Скорость полета: 50", UDim2.new(0, 20, 0, 140))

local TornadoButton = createButton("Торнадо: ВЫКЛ", UDim2.new(0, 190, 0, 50))
local TornadoRadiusInput = createTextBox("Радиус торнадо: 60", UDim2.new(0, 190, 0, 95))

local TeleportAllButton = createButton("ТП Всех к себе 🌀", UDim2.new(0, 190, 0, 140))
TeleportAllButton.BackgroundColor3 = Color3.fromRGB(139, 0, 0) -- Темно-красный для опасной функции

-- Кнопка Скрыть/Показать меню (для удобства на телефонах)
local ToggleGuiBtn = Instance.new("TextButton")
ToggleGuiBtn.Name = "ToggleGuiBtn"
ToggleGuiBtn.Size = UDim2.new(0, 80, 0, 30)
ToggleGuiBtn.Position = UDim2.new(0, 10, 0, 10)
ToggleGuiBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
ToggleGuiBtn.Text = "МЕНЮ"
ToggleGuiBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleGuiBtn.Font = Enum.Font.SourceSansBold
ToggleGuiBtn.TextSize = 14
ToggleGuiBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleGuiBtn).CornerRadius = UDim.new(0, 6)

ToggleGuiBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Инструкция
local Credits = Instance.new("TextLabel")
Credits.Size = UDim2.new(1, 0, 0, 40)
Credits.Position = UDim2.new(0, 0, 1, -45)
Credits.BackgroundTransparency = 1
Credits.Text = "Управление: Мобильный джойстик + Камера\nТорнадо следует за вами автоматически и защищает вас"
Credits.TextColor3 = Color3.fromRGB(150, 150, 150)
Credits.TextSize = 12
Credits.Font = Enum.Font.SourceSansItalic
Credits.Parent = MainFrame


-- 1. ЛОГИКА ПОЛЕТА И НОУКЛИПА
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
        FlyButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
    end
end)

-- Ноуклип переключатель
NoclipButton.MouseButton1Click:Connect(function()
    noclip = not noclip
    if noclip then
        NoclipButton.Text = "Ноуклип: ВКЛ"
        NoclipButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        NoclipButton.Text = "Ноуклип: ВЫКЛ"
        NoclipButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    end
end)

-- Постоянный цикл для Ноуклипа (чтобы не проваливаться и проходить сквозь стены при полёте)
RunService.Stepped:Connect(function()
    if noclip then
        local character = LocalPlayer.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)

FlySpeedInput.FocusLost:Connect(function()
    local text = FlySpeedInput.Text:gsub("%D+", "")
    local num = tonumber(text)
    if num then flySpeed = num FlySpeedInput.Text = "Скорость полета: " .. num else FlySpeedInput.Text = "Скорость полета: " .. flySpeed end
end)


-- 2. УЛУЧШЕННОЕ УМНОЕ ТОРНАДО (СЛЕДУЕТ И НЕ УБИВАЕТ ИГРОКА)
TornadoButton.MouseButton1Click:Connect(function()
    tornadoActive = not tornadoActive
    if tornadoActive then
        TornadoButton.Text = "Торнадо: ВКЛ"
        TornadoButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        
        task.spawn(function()
            local angle = 0
            while tornadoActive do
                RunService.Heartbeat:Wait()
                local character = LocalPlayer.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then continue end
                
                -- Центр торнадо ВСЕГДА привязан к текущей позиции игрока
                local center = character.HumanoidRootPart.Position
                angle = angle + math.rad(tornadoSpeed)
                
                -- Делаем так, чтобы летящие блоки не наносили нам физический урон при соприкосновении
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then part.Velocity = Vector3.new(0, 0, 0) end
                end
                
                for _, part in ipairs(Workspace:GetDescendants()) do
                    -- Захватываем незакрепленные блоки, которые не принадлежат персонажу игрока
                    if part:IsA("BasePart") and not part.Anchored and not part:IsDescendantOf(character) and not part.Parent:FindFirstChild("Humanoid") then
                        local distance = (part.Position - center).Magnitude
                        
                        -- Если блок входит в радиус действия торнадо вокруг игрока
                        if distance <= tornadoRadius then
                            -- Игнорируем блоки слишком близко к телу, чтобы они не застревали в хитбоксе персонажа (защита от урона/багов)
                            if distance < 6 then 
                                -- Отталкиваем их чуть дальше по радиусу
                                part.CFrame = part.CFrame + (part.Position - center).Unit * 5
                                continue 
                            end
                            
-- Вычисление позиций для закручивания блоков по спирали
local targetX = center.X + math.cos(angle + part.Position.Y * 0.1) * (distance * 0.8)
local targetZ = center.Z + math.sin(angle + part.Position.Y * 0.1) * (distance * 0.8)
local targetY = part.Position.Y + 1.2 -- Подъем вверх

-- Завихрение (если взлетели слишком высоко — засасывает обратно в воронку)
if targetY > center.Y + 45 then 
    targetY = center.Y - 5 
end

-- Применяем силу к деталям, чтобы они плавно кружились за вами, где бы вы ни были
part.Velocity = (Vector3.new(targetX, targetY, targetZ) - part.Position) * 7
part.RotVelocity = Vector3.new(0, 10, 0) -- Вращение самого блока вокруг оси
end
end
end
end
end)
else
TornadoButton.Text = "Торнадо: ВЫКЛ"
TornadoButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
end
end)

-- Регулировка радиуса торнадо
TornadoRadiusInput.FocusLost:Connect(function()
local text = TornadoRadiusInput.Text:gsub("%D+", "")
local num = tonumber(text)
if num then 
    tornadoRadius = num 
    TornadoRadiusInput.Text = "Радиус торнадо: " .. num 
else 
    TornadoRadiusInput.Text = "Радиус торнадо: " .. tornadoRadius 
end
end)

-- 3. ФУНКЦИЯ ТЕЛЕПОРТАЦИИ ВСЕХ ИГРОКОВ К СЕБЕ
TeleportAllButton.MouseButton1Click:Connect(function()
local character = LocalPlayer.Character
if not character or not character:FindFirstChild("HumanoidRootPart") then return end
local myPos = character.HumanoidRootPart.CFrame

-- Проходимся по всем игрокам на сервере
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then -- Себя не телепортируем
        local targetChar = player.Character
        if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
            -- Телепортируем чуть выше вас, чтобы они эпично падали в ваше торнадо
            targetChar.HumanoidRootPart.CFrame = myPos + Vector3.new(math.random(-5, 5), 5, math.random(-5, 5))
        end
    end
end
end)
