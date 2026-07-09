-- Создание основного интерфейса
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

-- Главное окно меню
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 250)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Active = true
MainFrame.Draggable = true -- Перетаскиваемое меню
MainFrame.Parent = ScreenGui

-- Скругление углов меню
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Зеленый градиент по краю (через UIStroke)
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

-- Заголовок меню
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "🤙 ERROR-HUB | NDS 🌪"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- ПЕРЕМЕННЫЕ ДЛЯ ФУНКЦИЙ
local flying = false
local flySpeed = 50
local tornadoActive = false
local tornadoRadius = 50
local tornadoSpeed = 10

-- 1. КНОПКА ПОЛЕТА
local FlyButton = Instance.new("TextButton")
FlyButton.Size = UDim2.new(0, 140, 0, 35)
FlyButton.Position = UDim2.new(0, 20, 0, 60)
FlyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
FlyButton.Text = "Полет: ВЫКЛ"
FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyButton.Font = Enum.Font.SourceSans
FlyButton.TextSize = 16
FlyButton.Parent = MainFrame
Instance.new("UICorner", FlyButton).CornerRadius = UDim.new(0, 6)

-- Поле ввода скорости полета
local FlySpeedInput = Instance.new("TextBox")
FlySpeedInput.Size = UDim2.new(0, 140, 0, 30)
FlySpeedInput.Position = UDim2.new(0, 20, 0, 105)
FlySpeedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FlySpeedInput.Text = "Скорость: 50"
FlySpeedInput.TextColor3 = Color3.fromRGB(200, 200, 200)
FlySpeedInput.Font = Enum.Font.SourceSans
FlySpeedInput.TextSize = 14
FlySpeedInput.Parent = MainFrame
Instance.new("UICorner", FlySpeedInput).CornerRadius = UDim.new(0, 6)

-- 2. КНОПКА ТОРНАДО
local TornadoButton = Instance.new("TextButton")
TornadoButton.Size = UDim2.new(0, 140, 0, 35)
TornadoButton.Position = UDim2.new(0, 190, 0, 60)
TornadoButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TornadoButton.Text = "Торнадо: ВЫКЛ"
TornadoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TornadoButton.Font = Enum.Font.SourceSans
TornadoButton.TextSize = 16
TornadoButton.Parent = MainFrame
Instance.new("UICorner", TornadoButton).CornerRadius = UDim.new(0, 6)

-- Поле ввода радиуса торнадо
local TornadoRadiusInput = Instance.new("TextBox")
TornadoRadiusInput.Size = UDim2.new(0, 140, 0, 30)
TornadoRadiusInput.Position = UDim2.new(0, 190, 0, 105)
TornadoRadiusInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TornadoRadiusInput.Text = "Радиус: 50"
TornadoRadiusInput.TextColor3 = Color3.fromRGB(200, 200, 200)
TornadoRadiusInput.Font = Enum.Font.SourceSans
TornadoRadiusInput.TextSize = 14
TornadoRadiusInput.Parent = MainFrame
Instance.new("UICorner", TornadoRadiusInput).CornerRadius = UDim.new(0, 6)

-- Инструкция снизу меню
local Credits = Instance.new("TextLabel")
Credits.Size = UDim2.new(1, 0, 0, 40)
Credits.Position = UDim2.new(0, 0, 1, -40)
Credits.BackgroundTransparency = 1
Credits.Text = "Управление полетом: W,A,S,D + Мышь\nИзменяйте цифры в полях для регулировки"
Credits.TextColor3 = Color3.fromRGB(150, 150, 150)
Credits.TextSize = 12
Credits.Font = Enum.Font.SourceSansItalic
Credits.Parent = MainFrame

-- ЛОГИКА ПОЛЕТА
local bodyVelocity, bodyGyro
FlyButton.MouseButton1Click:Connect(function()
    flying = not flying
    if flying then
        FlyButton.Text = "Полет: ВКЛ"
        FlyButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")
        
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
            local humanoid = character:WaitForChild("Humanoid")
            while flying do
                RunService.RenderStepped:Wait()
                local moveDirection = humanoid.MoveDirection
                if moveDirection.Magnitude > 0 then
                    bodyVelocity.Velocity = camera.CFrame:VectorToWorldSpace(Vector3.new(moveDirection.X, 0, moveDirection.Z).Unit * flySpeed)
                    -- Добавим подъем на пробел/опускание
                    if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then
                        bodyVelocity.Velocity = bodyVelocity.Velocity + Vector3.new(0, flySpeed, 0)
                    end
                else
                    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                    if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then
                        bodyVelocity.Velocity = Vector3.new(0, flySpeed, 0)
                    end
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

-- Обновление скорости полета при вводе
FlySpeedInput.FocusLost:Connect(function(enterPressed)
    local text = FlySpeedInput.Text:gsub("%D+", "") -- убираем все кроме цифр
    local num = tonumber(text)
    if num then
        flySpeed = num
        FlySpeedInput.Text = "Скорость: " .. num
    else
        FlySpeedInput.Text = "Скорость: " .. flySpeed
    end
end)

-- ЛОГИКА ТОРНАДО (ПРИТЯЖЕНИЕ НЕЗАКРЕПЛЕННЫХ БЛОКОВ)
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
                local center = character.HumanoidRootPart.Position
                
                angle = angle + math.rad(tornadoSpeed)
                
                -- Ищем все блоки на карте
                for _, part in ipairs(Workspace:GetDescendants()) do
                    if part:IsA("BasePart") and not part.Anchored and not part:IsDescendantOf(character) and not part.Parent:FindFirstChild("Humanoid") then
                        local distance = (part.Position - center).Magnitude
                        if distance <= tornadoRadius then
                            -- Проверяем, есть ли права на физику (NetworkOwnership) или симулируем локально
                            -- Рассчитываем позицию по спирали вокруг игрока
                            local targetX = center.X + math.cos(angle + part.Position.Y) * (distance * 0.6)
                            local targetZ = center.Z + math.sin(angle + part.Position.Y) * (distance * 0.6)
                            local targetY = part.Position.Y + 0.5 -- Поднимаем вверх
                            
                            if targetY > center.Y + 30 then targetY = center.Y end -- Сбрасываем высоту
                            
                            -- Плавное перемещение блока силами или скоростью (в зависимости от прав эксплоита)
                            part.Velocity = (Vector3.new(targetX, targetY, targetZ) - part.Position) * 5
                        end
                    end
                end
            end
        end)
    else
        TornadoButton.Text = "Торнадо: ВЫКЛ"
        TornadoButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
end)

-- Обновление радиуса торнадо при вводе
TornadoRadiusInput.FocusLost:Connect(function(enterPressed)
    local text = TornadoRadiusInput.Text:gsub("%D+", "")
    local num = tonumber(text)
    if num then
        tornadoRadius = num
        TornadoRadiusInput.Text = "Радиус: " .. num
    else
        TornadoRadiusInput.Text = "Радиус: " .. tornadoRadius
    end
end)
