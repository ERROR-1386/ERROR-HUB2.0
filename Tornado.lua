-- Сервисы Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Удаление старой панели перед запуском нового кода
if PlayerGui:FindFirstChild("DisasterMenuGui") then
    PlayerGui.DisasterMenuGui:Destroy()
end

-- Создание интерфейса ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DisasterMenuGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Главное меню (Прямоугольное, темно-серое)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 360, 0, 340)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Закругленные края меню
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 14)
UICorner.Parent = MainFrame

-- Зеленый градиент по всему краю (UIStroke + UIGradient)
local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 3.5
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Parent = MainFrame

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 100)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 160, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 0))
})
UIGradient.Parent = UIStroke

-- Заголовок меню
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "🤙 ERROR-HUB | NDS 🌪"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- ПЕРЕМЕННЫЕ НАСТРОЕК СХЕМЫ
local flying = false
local noclipActive = false
local flySpeed = 50

local tornadoActive = false
local tornadoRadius = 50
local tornadoSpeed = 10

-- [1] КНОПКА ПОЛЕТА
local FlyButton = Instance.new("TextButton")
FlyButton.Size = UDim2.new(0, 150, 0, 35)
FlyButton.Position = UDim2.new(0, 20, 0, 60)
FlyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
FlyButton.Text = "Полет: ВЫКЛ"
FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyButton.Font = Enum.Font.SourceSansBold
FlyButton.TextSize = 15
FlyButton.Parent = MainFrame
Instance.new("UICorner", FlyButton).CornerRadius = UDim.new(0, 6)

-- Поле ввода скорости полета
local FlySpeedInput = Instance.new("TextBox")
FlySpeedInput.Size = UDim2.new(0, 150, 0, 30)
FlySpeedInput.Position = UDim2.new(0, 20, 0, 105)
FlySpeedInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
FlySpeedInput.Text = "Скорость полета: 50"
FlySpeedInput.TextColor3 = Color3.fromRGB(200, 200, 200)
FlySpeedInput.Font = Enum.Font.SourceSans
FlySpeedInput.TextSize = 14
FlySpeedInput.Parent = MainFrame
Instance.new("UICorner", FlySpeedInput).CornerRadius = UDim.new(0, 6)

-- КНОПКА НОУКЛИПА
local NoclipButton = Instance.new("TextButton")
NoclipButton.Size = UDim2.new(0, 150, 0, 35)
NoclipButton.Position = UDim2.new(0, 20, 0, 150)
NoclipButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
NoclipButton.Text = "Ноуклип: ВЫКЛ"
NoclipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
NoclipButton.Font = Enum.Font.SourceSansBold
NoclipButton.TextSize = 15
NoclipButton.Parent = MainFrame
Instance.new("UICorner", NoclipButton).CornerRadius = UDim.new(0, 6)

-- [2] КНОПКА ТОРНАДО
local TornadoButton = Instance.new("TextButton")
TornadoButton.Size = UDim2.new(0, 150, 0, 35)
TornadoButton.Position = UDim2.new(0, 190, 0, 60)
TornadoButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TornadoButton.Text = "Торнадо: ВЫКЛ"
TornadoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TornadoButton.Font = Enum.Font.SourceSansBold
TornadoButton.TextSize = 15
TornadoButton.Parent = MainFrame
Instance.new("UICorner", TornadoButton).CornerRadius = UDim.new(0, 6)

-- Поле ввода радиуса торнадо
local TornadoRadiusInput = Instance.new("TextBox")
TornadoRadiusInput.Size = UDim2.new(0, 150, 0, 30)
TornadoRadiusInput.Position = UDim2.new(0, 190, 0, 105)
TornadoRadiusInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TornadoRadiusInput.Text = "Радиус торнадо: 50"
TornadoRadiusInput.TextColor3 = Color3.fromRGB(200, 200, 200)
TornadoRadiusInput.Font = Enum.Font.SourceSans
TornadoRadiusInput.TextSize = 14
TornadoRadiusInput.Parent = MainFrame
Instance.new("UICorner", TornadoRadiusInput).CornerRadius = UDim.new(0, 6)

-- Переменная состояния режима бога
local godModeActive = false

-- КНОПКА РЕЖИМА БОГА
local GodModeButton = Instance.new("TextButton")
GodModeButton.Size = UDim2.new(0, 140, 0, 35)
-- Размещаем её чуть ниже кнопки полета
GodModeButton.Position = UDim2.new(0, 20, 0, 150)
GodModeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
GodModeButton.Text = "Режим Бога: ВЫКЛ"
GodModeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
GodModeButton.Font = Enum.Font.SourceSans
GodModeButton.TextSize = 16
GodModeButton.Parent = MainFrame
Instance.new("UICorner", GodModeButton).CornerRadius = UDim.new(0, 6)

-- [3] КНОПКА ТЕЛЕПОРТАЦИИ ВСЕХ ИГРОКОВ К СЕБЕ
local TeleportAllButton = Instance.new("TextButton")
TeleportAllButton.Size = UDim2.new(0, 320, 0, 40)
TeleportAllButton.Position = UDim2.new(0, 20, 0, 210)
TeleportAllButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
TeleportAllButton.Text = "ТЕЛЕПОРТИРОВАТЬ ВСЕХ К СЕБЕ"
TeleportAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportAllButton.Font = Enum.Font.SourceSansBold
TeleportAllButton.TextSize = 16
TeleportAllButton.Parent = MainFrame
Instance.new("UICorner", TeleportAllButton).CornerRadius = UDim.new(0, 8)

-- Сноска-инструкция для мобильных экранов
local MobileCredits = Instance.new("TextLabel")
MobileCredits.Size = UDim2.new(1, 0, 0, 50)
MobileCredits.Position = UDim2.new(0, 0, 1, -55)
MobileCredits.BackgroundTransparency = 1
MobileCredits.Text = "Управление полетом адаптировано под телефон.\nПолет направляется туда, куда смотрит камера.\nНоуклип отключает столкновение со стенами."
MobileCredits.TextColor3 = Color3.fromRGB(140, 140, 140)
MobileCredits.TextSize = 12
MobileCredits.Font = Enum.Font.SourceSansItalic
MobileCredits.Parent = MainFrame


-- ==================== ЛОГИКА ПОЛЕТА И НОУКЛИПА ====================

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

-- Логика переключения режима Ноуклип (Noclip)
NoclipButton.MouseButton1Click:Connect(function()
    noclipActive = not noclipActive
    if noclipActive then
        NoclipButton.Text = "Ноуклип: ВКЛ"
        NoclipButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        NoclipButton.Text = "Ноуклип: ВЫКЛ"
        NoclipButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
end)

-- Постоянная проверка коллизий для работы ноуклипа
RunService.Stepped:Connect(function()
    if noclipActive then
        local character = LocalPlayer.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- Обновление переменной скорости при вводе в текстовое поле
FlySpeedInput.FocusLost:Connect(function()
    local text = FlySpeedInput.Text:gsub("%D+", "")
    local num = tonumber(text)
    if num then
        flySpeed = num
        FlySpeedInput.Text = "Скорость полета: " .. num
    else
        FlySpeedInput.Text = "Скорость полета: " .. flySpeed
    end
end)


-- ==================== ЛОГИКА СМЕРТОНОСНОГО ТОРНАДО ====================

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
                
                angle = angle + math.rad(tornadoSpeed * 2)
                
                for _, part in ipairs(Workspace:GetDescendants()) do
                    if part:IsA("BasePart") and not part.Anchored then
                        
                        -- Полная защита вашего персонажа от затягивания
                        if part:IsDescendantOf(character) then 
                            continue 
                        end
                        
                        local directionToPart = part.Position - center
                        local distance = directionToPart.Magnitude
                        
                        if distance <= tornadoRadius then
                            -- Математический конус (расширение воронки кверху)
                            local relativeY = part.Position.Y - center.Y
                            local currentRadius = (distance * 0.3) + (relativeY * 0.15)
                            if currentRadius < 5 then currentRadius = 5 end
                            
                            -- Расчет математической спирали с турбулентностью
                            local turbulence = math.sin(tick() * 5 + part.Position.Y) * 2
                            local targetX = center.X + math.cos(angle + part.Position.Y * 0.08) * currentRadius + turbulence
                            local targetZ = center.Z + math.sin(angle + part.Position.Y * 0.08) * currentRadius + turbulence
                            local targetY = part.Position.Y + 0.9 -- Подъем блоков вверх
                            
                            -- Если деталь взлетела выше 45 блоков, возвращаем ее вниз воронки
                            if relativeY > 45 then
                                targetY = center.Y + math.random(-2, 4)
                            end
                            
                            -- Сильный срыв анкера (Отрываем даже намертво закрепленные дома)
                            if part.Anchored then
                                part.Anchored = false
                            end
                            
                            -- Принудительное движение через CFrame (работает без NetworkOwnership)
                            local targetPos = Vector3.new(targetX, targetY, targetZ)
                            part.CFrame = CFrame.new(part.Position:Lerp(targetPos, 0.25)) -- Плавное притяжение
                            
                                                        -- =======================================================
                            -- АКТИВАЦИЯ ЭФФЕКТА FLING (УБИЙСТВЕННЫЙ ИМПУЛЬС СМЕРТИ)
                            -- =======================================================
                            -- Задаем блокам экстремально высокое хаотичное вращение. 
                            -- Движок Roblox передает этот импульс любому, кто коснется блока.
                            part.RotVelocity = Vector3.new(9999, 9999, 9999)
                            
                            -- Дополнительно толкаем блок в сторону цели с огромной силой,
                            -- если рядом есть другие игроки (для точечного уничтожения)
                            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                                if player ~= game:GetService("Players").LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                    local playerPos = player.Character.HumanoidRootPart.Position
                                    -- Если чужой игрок подошел близко к летящему блоку
                                    if (part.Position - playerPos).Magnitude < 15 then
                                        -- Направляем блок прямо в него на бешеной скорости
                                        part.Velocity = (playerPos - part.Position).Unit * 500
                                    end
                                end
                            end
                            -- Если игроков рядом нет, сохраняем стандартную круговую скорость
                            if part.Velocity.Magnitude < 100 then
                                part.Velocity = Vector3.new(math.random(-50, 50), 80, math.random(-50, 50))
                            end
                            -- =======================================================

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

-- Обновление радиуса торнадо при потере фокуса ввода
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

-- ==================== ФУНКЦИЯ ТЕЛЕПОРТАЦИИ ВСЕХ ====================
TeleportAllButton.MouseButton1Click:Connect(function()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local myPos = character.HumanoidRootPart.CFrame
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local targetChar = player.Character
            if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                -- Телепортируем игроков чуть выше вас в эпицентр кружения блоков
                targetChar.HumanoidRootPart.CFrame = myPos + Vector3.new(math.random(-5, 5), 8, math.random(-5, 5))
            end
        end
    end
end)
-- ЛОГИКА РЕЖИМА БОГА
GodModeButton.MouseButton1Click:Connect(function()
    godModeActive = not godModeActive
    if godModeActive then
        GodModeButton.Text = "Режим Бога: ВКЛ"
        GodModeButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        
        -- Запуск бесконечного цикла проверки здоровья и защиты
        task.spawn(function()
            while godModeActive do
                RunService.Heartbeat:Wait()
                local character = LocalPlayer.Character
                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        -- 1. Мгновенное лечение до максимума
                        if humanoid.Health < humanoid.MaxHealth then
                            humanoid.Health = humanoid.MaxHealth
                        end
                        
                        -- 2. Защита от смерти при падении здоровья до 0 (Анти-смерть)
                        humanoid.MaxHealth = 1000000
                        humanoid.Health = 1000000
                    end
                    
                    -- 3. Удаление опасных локальных скриптов и эффектов (огня, кислоты, заморозки)
                    for _, object in ipairs(character:GetDescendants()) do
                        if object:IsA("Fire") or object:IsA("Smoke") or object.Name == "BurnScript" then
                            object:Destroy()
                        end
                    end
                end
            end
        end)
    else
        GodModeButton.Text = "Режим Бога: ВЫКЛ"
        GodModeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        
        -- Возвращаем стандартные параметры при выключении
        local character = LocalPlayer.Character
        if character and character:FindFirstChildOfClass("Humanoid") then
            character:FindFirstChildOfClass("Humanoid").MaxHealth = 100
            character:FindFirstChildOfClass("Humanoid").Health = 100
        end
    end
end)

-- Автоматическое перевключение режима бога после респавна (если ты его не выключал)
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    if godModeActive then
        task.wait(1) -- Ждем полной загрузки персонажа
        local humanoid = newCharacter:WaitForChild("Humanoid")
        humanoid.MaxHealth = 1000000
        humanoid.Health = 1000000
    end
end)
