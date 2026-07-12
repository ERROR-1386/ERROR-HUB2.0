-- БЕЗОПАСНАЯ ВЕРСИЯ (не вылетает)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

-- Переменные
local Features = {
    AutoFarm = false,
    GodMode = false,
    FlyEnabled = false,
    AntiAFK = false,
    FarmSpeed = 1,
    FlySpeed = 50,
    Platform = nil,
    FlyBodyGyro = nil,
    FlyBodyVelocity = nil
}

-- Простая платформа
local function CreatePlatform()
    pcall(function()
        if Features.Platform then
            Features.Platform:Destroy()
            Features.Platform = nil
        end
        
        if not Features.AutoFarm then return end
        
        local char = LocalPlayer.Character
        if not char then return end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local plat = Instance.new("Part")
        plat.Name = "FarmPlatform"
        plat.Size = Vector3.new(15, 1, 15)
        plat.Anchored = true
        plat.CanCollide = true
        plat.Transparency = 0.5
        plat.BrickColor = BrickColor.new("Bright blue")
        plat.Material = Enum.Material.Neon
        plat.Parent = Workspace
        
        Features.Platform = plat
        
        -- Обновление позиции платформы
        spawn(function()
            while Features.AutoFarm and Features.Platform and plat.Parent do
                task.wait(0.1)
                pcall(function()
                    local currentChar = LocalPlayer.Character
                    if currentChar then
                        local currentRoot = currentChar:FindFirstChild("HumanoidRootPart")
                        if currentRoot and plat and plat.Parent then
                            plat.CFrame = CFrame.new(currentRoot.Position) * CFrame.new(0, -3.5, 0)
                        end
                    end
                end)
            end
        end)
    end)
end

-- Auto Farm (БЕЗОПАСНЫЙ)
local function StartAutoFarm()
    CreatePlatform()
    
    spawn(function()
        while Features.AutoFarm do
            task.wait(0.5 / Features.FarmSpeed)
            pcall(function()
                if not Features.AutoFarm then return end
                
                local char = LocalPlayer.Character
                if not char then return end
                
                local root = char:FindFirstChild("HumanoidRootPart")
                if not root then return end
                
                -- Ищем только 5 ближайших объектов (чтобы не лагало)
                local items = {}
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if not Features.AutoFarm then break end
                    if #items >= 5 then break end
                    
                    if obj:IsA("BasePart") and obj.Parent then
                        local name = obj.Name:lower()
                        if name:find("gold") or name:find("coin") or name:find("chest") then
                            local dist = (obj.Position - root.Position).Magnitude
                            if dist < 50 then
                                table.insert(items, {obj = obj, dist = dist})
                            end
                        end
                    end
                end
                
                -- Телепортируемся к ближайшему
                table.sort(items, function(a, b) return a.dist < b.dist end)
                
                if items[1] and Features.AutoFarm then
                    root.CFrame = items[1].obj.CFrame * CFrame.new(0, 2, 0)
                end
            end)
        end
        
        -- Очистка
        if Features.Platform then
            Features.Platform:Destroy()
            Features.Platform = nil
        end
    end)
end

-- God Mode (БЕЗОПАСНЫЙ)
local function StartGodMode()
    spawn(function()
        while Features.GodMode do
            task.wait(0.5)
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                
                local hum = char:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    hum.Health = hum.MaxHealth
                end
            end)
        end
    end)
end

-- Fly (БЕЗОПАСНЫЙ)
local function StartFly()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        -- Удаляем старые если есть
        if Features.FlyBodyGyro then
            Features.FlyBodyGyro:Destroy()
        end
        if Features.FlyBodyVelocity then
            Features.FlyBodyVelocity:Destroy()
        end
        
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
        bodyGyro.P = 30000
        bodyGyro.Parent = root
        Features.FlyBodyGyro = bodyGyro
        
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
        bodyVelocity.P = 30000
        bodyVelocity.Parent = root
        Features.FlyBodyVelocity = bodyVelocity
        
        spawn(function()
            while Features.FlyEnabled do
                task.wait()
                pcall(function()
                    if not root.Parent then return end
                    
                    bodyGyro.CFrame = Workspace.CurrentCamera.CFrame
                    
                    local vel = Vector3.zero
                    local speed = Features.FlySpeed
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel += Workspace.CurrentCamera.CFrame.LookVector * speed end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel -= Workspace.CurrentCamera.CFrame.LookVector * speed end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel -= Workspace.CurrentCamera.CFrame.RightVector * speed end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel += Workspace.CurrentCamera.CFrame.RightVector * speed end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel += Vector3.new(0, speed, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vel -= Vector3.new(0, speed, 0) end
                    
                    bodyVelocity.Velocity = vel
                end)
            end
            
            -- Очистка
            if Features.FlyBodyGyro then Features.FlyBodyGyro:Destroy() end
            if Features.FlyBodyVelocity then Features.FlyBodyVelocity:Destroy() end
        end)
    end)
end

-- Anti-AFK (БЕЗОПАСНЫЙ)
local function StartAntiAFK()
    spawn(function()
        while Features.AntiAFK do
            task.wait(10)
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    -- Маленькое движение
                    root.CFrame = root.CFrame * CFrame.new(math.random(-1, 1), 0, math.random(-1, 1))
                end
            end)
        end
    end)
end

-- ============================================
-- СОЗДАНИЕ GUI
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BABFT_Hack"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
Title.Text = "🌟 BABFT HACK"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.BorderSizePixel = 0
Title.Parent = MainFrame

-- Функция создания кнопки
local function CreateButton(text, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.Parent = MainFrame
    return btn
end

-- Кнопки
local FarmBtn = CreateButton("⚔️ Auto Farm", 40)
local GodBtn = CreateButton("🛡️ God Mode", 90)
local FlyBtn = CreateButton("✈️ Fly", 140)
local AFKBtn = CreateButton("🤖 Anti-AFK", 190)

-- Кнопка закрыть
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(1, -20, 0, 35)
CloseBtn.Position = UDim2.new(0, 10, 0, 250)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Text = "✕ ЗАКРЫТЬ"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = MainFrame

-- Обработчики кнопок
FarmBtn.MouseButton1Click:Connect(function()
    Features.AutoFarm = not Features.AutoFarm
    FarmBtn.Text = "⚔️ Auto Farm: " .. (Features.AutoFarm and "ON" or "OFF")
    FarmBtn.BackgroundColor3 = Features.AutoFarm and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(200, 50, 50)
    
    if Features.AutoFarm then
        StartAutoFarm()
    end
end)

GodBtn.MouseButton1Click:Connect(function()
    Features.GodMode = not Features.GodMode
    GodBtn.Text = "🛡️ God Mode: " .. (Features.GodMode and "ON" or "OFF")
    GodBtn.BackgroundColor3 = Features.GodMode and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(200, 50, 50)
    
    if Features.GodMode then
        StartGodMode()
    end
end)

FlyBtn.MouseButton1Click:Connect(function()
    Features.FlyEnabled = not Features.FlyEnabled
    FlyBtn.Text = "✈️ Fly: " .. (Features.FlyEnabled and "ON" or "OFF")
    FlyBtn.BackgroundColor3 = Features.FlyEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(200, 50, 50)
    
    if Features.FlyEnabled then
        StartFly()
    end
end)

AFKBtn.MouseButton1Click:Connect(function()
    Features.AntiAFK = not Features.AntiAFK
    AFKBtn.Text = "🤖 Anti-AFK: " .. (Features.AntiAFK and "ON" or "OFF")
    AFKBtn.BackgroundColor3 = Features.AntiAFK and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(200, 50, 50)
    
    if Features.AntiAFK then
        StartAntiAFK()
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    -- Выключаем всё
    Features.AutoFarm = false
    Features.GodMode = false
    Features.FlyEnabled = false
    Features.AntiAFK = false
    
    -- Очистка
    if Features.Platform then
        Features.Platform:Destroy()
    end
    if Features.FlyBodyGyro then
        Features.FlyBodyGyro:Destroy()
    end
    if Features.FlyBodyVelocity then
        Features.FlyBodyVelocity:Destroy()
    end
    
    ScreenGui:Destroy()
end)

print("✅ BABFT HACK загружен! Безопасная версия")
