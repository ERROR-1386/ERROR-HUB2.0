--[[
    🌟 BABFT HACK - ПОЛНАЯ ВЕРСИЯ
    • Keymaster для генерации ключей
    • Supabase для кэширования
    • Auto Farm с платформой
    • God Mode
    • Mobile Fly (как Fly GUI V3)
    • Anti-AFK
    • Админ-панель генерации ключей
]]

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- ============================================
-- КОНФИГУРАЦИЯ (ЗАМЕНИТЕ НА СВОИ ДАННЫЕ!)
-- ============================================
local CONFIG = {
    -- Keymaster API
    Keymaster_URL = "https://keymaster.fun/api",
    Keymaster_AppID = "ВАШ_APP_ID",  -- ID приложения из Keymaster
    Keymaster_SecretKey = "ВАШ_SECRET_KEY",  -- Secret Key из Keymaster
    
    -- Supabase (для кэша ключей)
    Supabase_URL = "https://ВАШ_ПРОЕКТ.supabase.co",
    Supabase_Key = "ВАШ_ANON_KEY",
    
    -- Админ-пароль для генерации ключей
    AdminPassword = "admin123"  -- Смените на свой!
}

-- ============================================
-- ПОЛУЧЕНИЕ HWID
-- ============================================
local function GetHWID()
    local success, hwid = pcall(function()
        return game:GetService("RbxAnalyticsService"):GetClientId()
    end)
    if not success then
        hwid = tostring(LocalPlayer.UserId) .. "-" .. tostring(math.random(1000, 9999))
    end
    return hwid
end

local HWID = GetHWID()
print("🔑 HWID:", HWID)

-- ============================================
-- ФУНКЦИИ KEYMASTER
-- ============================================

-- Генерация ключа через Keymaster API
local function GenerateKeymasterKey(duration_days, key_type)
    local url = CONFIG.Keymaster_URL .. "/generate"
    
    local data = {
        appid = CONFIG.Keymaster_AppID,
        duration = duration_days,
        type = key_type or "premium",
        max_uses = 1,
        hwid_lock = true
    }
    
    local headers = {
        ["Authorization"] = "Bearer " .. CONFIG.Keymaster_SecretKey,
        ["Content-Type"] = "application/json"
    }
    
    local success, response = pcall(function()
        return HttpService:PostAsync(
            url,
            HttpService:JSONEncode(data),
            Enum.HttpContentType.ApplicationJson,
            false,
            headers
        )
    end)
    
    if success then
        local result = HttpService:JSONDecode(response)
        if result.key then
            print("✅ Ключ создан:", result.key)
            return result.key
        else
            print("❌ Ответ Keymaster:", response)
        end
    else
        print("❌ Ошибка запроса к Keymaster")
    end
    
    return nil
end

-- Проверка ключа через Keymaster
local function VerifyKeymasterKey(key)
    print("🔍 Проверка ключа через Keymaster:", key)
    
    local url = CONFIG.Keymaster_URL .. "/verify"
    
    local data = {
        key = key,
        appid = CONFIG.Keymaster_AppID,
        hwid = HWID
    }
    
    local success, response = pcall(function()
        return HttpService:PostAsync(
            url,
            HttpService:JSONEncode(data),
            Enum.HttpContentType.ApplicationJson
        )
    end)
    
    if not success then
        print("❌ Ошибка соединения с Keymaster")
        return false, nil, "Ошибка соединения с сервером!"
    end
    
    local result = HttpService:JSONDecode(response)
    print("📩 Ответ Keymaster:", result.valid and "Верный" or "Неверный")
    
    if result.valid then
        -- Сохраняем в Supabase для кэша
        SaveToSupabase(key, result.expiry)
        return true, result.expiry, "✅ Ключ активирован через Keymaster!"
    else
        return false, nil, result.message or "❌ Неверный ключ!"
    end
end

-- ============================================
-- ФУНКЦИИ SUPABASE (КЭШ)
-- ============================================

-- Сохранение ключа в Supabase
local function SaveToSupabase(key, expiry)
    local url = CONFIG.Supabase_URL .. "/rest/v1/keys"
    
    local data = {
        key = key,
        hwid = HWID,
        user_id = LocalPlayer.UserId,
        username = LocalPlayer.Name,
        expiry = tostring(expiry or (os.time() + 86400)),
        created_at = tostring(os.time()),
        is_active = true
    }
    
    pcall(function()
        HttpService:PostAsync(
            url,
            HttpService:JSONEncode(data),
            Enum.HttpContentType.ApplicationJson,
            false,
            {
                ["apikey"] = CONFIG.Supabase_Key,
                ["Authorization"] = "Bearer " .. CONFIG.Supabase_Key,
                ["Content-Type"] = "application/json",
                ["Prefer"] = "return=minimal"
            }
        )
    end)
end

-- Проверка кэша в Supabase
local function CheckSavedKey()
    local url = CONFIG.Supabase_URL .. "/rest/v1/keys?hwid=eq." .. HWID .. "&is_active=eq.true&order=created_at.desc&limit=1"
    
    local success, response = pcall(function()
        return HttpService:GetAsync(url, false, {
            ["apikey"] = CONFIG.Supabase_Key,
            ["Authorization"] = "Bearer " .. CONFIG.Supabase_Key
        })
    end)
    
    if success then
        local data = HttpService:JSONDecode(response)
        if #data > 0 then
            local keyData = data[1]
            local expiry = tonumber(keyData.expiry)
            
            if expiry and expiry > os.time() then
                return true, keyData.key
            else
                -- Деактивируем просроченный
                pcall(function()
                    HttpService:RequestAsync({
                        Url = CONFIG.Supabase_URL .. "/rest/v1/keys?id=eq." .. keyData.id,
                        Method = "PATCH",
                        Headers = {
                            ["apikey"] = CONFIG.Supabase_Key,
                            ["Authorization"] = "Bearer " .. CONFIG.Supabase_Key,
                            ["Content-Type"] = "application/json",
                            ["Prefer"] = "return=minimal"
                        },
                        Body = HttpService:JSONEncode({is_active = false})
                    })
                end)
            end
        end
    end
    
    return false, nil
end

-- ============================================
-- ПЕРЕМЕННЫЕ ФУНКЦИЙ
-- ============================================
local Features = {
    AutoFarm = false,
    GodMode = false,
    FlyEnabled = false,
    AntiAFK = false,
    FarmSpeed = 1,
    FlySpeed = 50,
    Platform = nil,
    KeyValid = false,
    MobileFlyActive = false
}

-- ============================================
-- ФУНКЦИИ СКРИПТА
-- ============================================

-- Платформа для фарма
local function CreatePlatform()
    if Features.Platform then
        Features.Platform:Destroy()
    end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local platform = Instance.new("Part")
    platform.Name = "FarmPlatform"
    platform.Size = Vector3.new(15, 1, 15)
    platform.Anchored = true
    platform.CanCollide = true
    platform.Transparency = 0.3
    platform.BrickColor = BrickColor.new("Bright blue")
    platform.Material = Enum.Material.Neon
    platform.Parent = Workspace
    
    Features.Platform = platform
    
    spawn(function()
        while Features.AutoFarm and Features.Platform do
            wait()
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and platform then
                    platform.CFrame = CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position) * CFrame.new(0, -3.5, 0)
                end
            end)
        end
        if platform then
            platform:Destroy()
            Features.Platform = nil
        end
    end)
end

-- Авто-фарм
local function AutoFarm()
    CreatePlatform()
    
    spawn(function()
        while Features.AutoFarm do
            wait(0.1 / Features.FarmSpeed)
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if not rootPart then return end
                
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if not Features.AutoFarm then break end
                    
                    if obj:IsA("BasePart") and obj:IsDescendantOf(Workspace) then
                        local name = obj.Name:lower()
                        if name:find("gold") or name:find("coin") or name:find("money") or name:find("chest") or name:find("block") then
                            if (obj.Position - rootPart.Position).Magnitude < 100 then
                                rootPart.CFrame = obj.CFrame * CFrame.new(0, 2, 0)
                                wait(0.05)
                                firetouchinterest(rootPart, obj, 0)
                                firetouchinterest(rootPart, obj, 1)
                            end
                        end
                    end
                end
            end)
        end
        
        if Features.Platform then
            Features.Platform:Destroy()
            Features.Platform = nil
        end
    end)
end

-- God Mode
local function GodMode()
    spawn(function()
        while Features.GodMode do
            wait()
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.Health = humanoid.MaxHealth
                end
                
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)
        end
    end)
end

-- Мобильный Fly (как Fly GUI V3)
local function MobileFly()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return end
    
    -- BodyGyro и BodyVelocity для полёта
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.CFrame = rootPart.CFrame
    bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
    bodyGyro.P = 30000
    bodyGyro.Parent = rootPart
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
    bodyVelocity.P = 30000
    bodyVelocity.Parent = rootPart
    
    -- Поток управления
    spawn(function()
        while Features.FlyEnabled do
            wait()
            if not LocalPlayer.Character or not rootPart or not rootPart.Parent then break end
            
            bodyGyro.CFrame = Workspace.CurrentCamera.CFrame
            
            local velocity = Vector3.new(0, 0, 0)
            
            -- ПК управление
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                velocity = velocity + Workspace.CurrentCamera.CFrame.LookVector * Features.FlySpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                velocity = velocity - Workspace.CurrentCamera.CFrame.LookVector * Features.FlySpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                velocity = velocity - Workspace.CurrentCamera.CFrame.RightVector * Features.FlySpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                velocity = velocity + Workspace.CurrentCamera.CFrame.RightVector * Features.FlySpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                velocity = velocity + Vector3.new(0, Features.FlySpeed, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                velocity = velocity - Vector3.new(0, Features.FlySpeed, 0)
            end
            
            bodyVelocity.Velocity = velocity
        end
        
        bodyGyro:Destroy()
        bodyVelocity:Destroy()
    end)
    
    -- Создание мобильных кнопок (если на телефоне)
    if UserInputService.TouchEnabled then
        CreateMobileFlyButtons(rootPart, bodyVelocity)
    end
end

-- Мобильные кнопки Fly
local function CreateMobileFlyButtons(rootPart, bodyVelocity)
    Features.MobileFlyActive = true
    
    local MobileGui = Instance.new("ScreenGui")
    MobileGui.Name = "MobileFly"
    MobileGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Кнопки направления
    local buttons = {
        {Text = "▲", Pos = UDim2.new(0.5, -30, 0.7, -80), Dir = "Forward", Color = Color3.fromRGB(255, 255, 255)},
        {Text = "▼", Pos = UDim2.new(0.5, -30, 0.7, 50), Dir = "Backward", Color = Color3.fromRGB(255, 255, 255)},
        {Text = "◀", Pos = UDim2.new(0.5, -95, 0.7, -15), Dir = "Left", Color = Color3.fromRGB(255, 255, 255)},
        {Text = "▶", Pos = UDim2.new(0.5, 35, 0.7, -15), Dir = "Right", Color = Color3.fromRGB(255, 255, 255)},
        {Text = "⇧", Pos = UDim2.new(0.8, -35, 0.75, -35), Dir = "Up", Color = Color3.fromRGB(0, 150, 255)},
        {Text = "⇩", Pos = UDim2.new(0.8, -35, 0.85, -35), Dir = "Down", Color = Color3.fromRGB(255, 100, 0)},
    }
    
    local activeButtons = {}
    
    for _, btnData in ipairs(buttons) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 60, 0, 60)
        btn.Position = btnData.Pos
        btn.BackgroundColor3 = btnData.Color
        btn.BackgroundTransparency = 0.7
        btn.Text = btnData.Text
        btn.TextColor3 = Color3.fromRGB(0, 0, 0)
        btn.TextSize = 30
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.Parent = MobileGui
        
        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                activeButtons[btnData.Dir] = true
            end
        end)
        
        btn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                activeButtons[btnData.Dir] = false
            end
        end)
    end
    
    -- Обновление полёта для мобильных кнопок
    spawn(function()
        while Features.FlyEnabled and Features.MobileFlyActive do
            wait()
            if not rootPart or not rootPart.Parent then break end
            
            local velocity = Vector3.new(0, 0, 0)
            
            if activeButtons["Forward"] then
                velocity = velocity + Workspace.CurrentCamera.CFrame.LookVector * Features.FlySpeed
            end
            if activeButtons["Backward"] then
                velocity = velocity - Workspace.CurrentCamera.CFrame.LookVector * Features.FlySpeed
            end
            if activeButtons["Left"] then
                velocity = velocity - Workspace.CurrentCamera.CFrame.RightVector * Features.FlySpeed
            end
            if activeButtons["Right"] then
                velocity = velocity + Workspace.CurrentCamera.CFrame.RightVector * Features.FlySpeed
            end
            if activeButtons["Up"] then
                velocity = velocity + Vector3.new(0, Features.FlySpeed, 0)
            end
            if activeButtons["Down"] then
                velocity = velocity - Vector3.new(0, Features.FlySpeed, 0)
            end
            
            bodyVelocity.Velocity = velocity
        end
        
        Features.MobileFlyActive = false
        MobileGui:Destroy()
    end)
end

-- Анти-АФК
local function AntiAFKSystem()
    spawn(function()
        while Features.AntiAFK do
            wait(5)
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    local originalPos = rootPart.Position
                    local randomDir = Vector3.new(
                        math.random(-100, 100) / 1000,
                        0,
                        math.random(-100, 100) / 1000
                    )
                    
                    rootPart.CFrame = rootPart.CFrame * CFrame.new(randomDir)
                    wait(0.1)
                    rootPart.CFrame = CFrame.new(originalPos)
                end
            end)
        end
    end)
end

-- ============================================
-- АДМИН-ПАНЕЛЬ KEYMASTER
-- ============================================
local function CreateAdminPanel()
    local AdminGui = Instance.new("ScreenGui")
    AdminGui.Name = "KeymasterAdmin"
    AdminGui.Parent = game:GetService("CoreGui")
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 320, 0, 350)
    Frame.Position = UDim2.new(0.5, -160, 0.5, -175)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = AdminGui
    
    -- Заголовок
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 35)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    Title.Text = "🔑 Keymaster Key Generator"
    Title.TextColor3 = Color3.fromRGB(255, 215, 0)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.BorderSizePixel = 0
    Title.Parent = Frame
    
    -- Пароль
    local PassInput = Instance.new("TextBox")
    PassInput.Size = UDim2.new(1, -20, 0, 30)
    PassInput.Position = UDim2.new(0, 10, 0, 45)
    PassInput.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    PassInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    PassInput.PlaceholderText = "🔐 Админ-пароль..."
    PassInput.Font = Enum.Font.Gotham
    PassInput.TextSize = 13
    PassInput.BorderSizePixel = 0
    PassInput.Parent = Frame
    
    -- Тип ключа
    local TypeLabel = Instance.new("TextLabel")
    TypeLabel.Size = UDim2.new(1, -20, 0, 20)
    TypeLabel.Position = UDim2.new(0, 10, 0, 85)
    TypeLabel.BackgroundTransparency = 1
    TypeLabel.Text = "📦 Тип ключа:"
    TypeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TypeLabel.Font = Enum.Font.Gotham
    TypeLabel.TextSize = 12
    TypeLabel.TextXAlignment = Enum.TextXAlignment.Left
    TypeLabel.Parent = Frame
    
    local TypeDropdown = Instance.new("TextButton")
    TypeDropdown.Size = UDim2.new(1, -20, 0, 30)
    TypeDropdown.Position = UDim2.new(0, 10, 0, 105)
    TypeDropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    TypeDropdown.Text = "Premium (24 часа)"
    TypeDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    TypeDropdown.Font = Enum.Font.Gotham
    TypeDropdown.TextSize = 13
    TypeDropdown.BorderSizePixel = 0
    TypeDropdown.Parent = Frame
    
    local keyTypes = {
        {name = "Premium (24 часа)", type = "premium", duration = 1},
        {name = "Premium (7 дней)", type = "premium", duration = 7},
        {name = "Premium (30 дней)", type = "premium", duration = 30},
        {name = "Premium (навсегда)", type = "premium", duration = 36500},
        {name = "Trial (1 час)", type = "trial", duration = 0.04},
        {name = "Trial (24 часа)", type = "trial", duration = 1}
    }
    
    local currentType = 1
    
    TypeDropdown.MouseButton1Click:Connect(function()
        currentType = currentType % #keyTypes + 1
        TypeDropdown.Text = keyTypes[currentType].name
    end)
    
    -- Кнопка генерации
    local GenButton = Instance.new("TextButton")
    GenButton.Size = UDim2.new(1, -20, 0, 40)
    GenButton.Position = UDim2.new(0, 10, 0, 150)
    GenButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    GenButton.Text = "🎲 Сгенерировать ключ"
    GenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    GenButton.Font = Enum.Font.GothamBold
    GenButton.TextSize = 14
    GenButton.BorderSizePixel = 0
    GenButton.Parent = Frame
    
    -- Поле с ключом
    local KeyDisplay = Instance.new("TextBox")
    KeyDisplay.Size = UDim2.new(1, -20, 0, 35)
    KeyDisplay.Position = UDim2.new(0, 10, 0, 200)
    KeyDisplay.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    KeyDisplay.TextColor3 = Color3.fromRGB(0, 255, 0)
    KeyDisplay.Text = "Ключ появится здесь..."
    KeyDisplay.Font = Enum.Font.GothamBold
    KeyDisplay.TextSize = 13
    KeyDisplay.BorderSizePixel = 0
    KeyDisplay.ClearTextOnFocus = false
    KeyDisplay.Parent = Frame
    
    -- Статус
    local Status = Instance.new("TextLabel")
    Status.Size = UDim2.new(1, -20, 0, 25)
    Status.Position = UDim2.new(0, 10, 0, 245)
    Status.BackgroundTransparency = 1
    Status.Text = ""
    Status.TextColor3 = Color3.fromRGB(255, 255, 255)
    Status.Font = Enum.Font.Gotham
    Status.TextSize = 12
    Status.Parent = Frame
    
    -- Информация
    local Info = Instance.new("TextLabel")
    Info.Size = UDim2.new(1, -20, 0, 50)
    Info.Position = UDim2.new(0, 10, 0, 275)
    Info.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    Info.Text = "💡 Нажмите на ключ чтобы скопировать\n📋 Ключ сохраняется в Keymaster\n🔒 Привязан к HWID пользователя"
    Info.TextColor3 = Color3.fromRGB(200, 200, 200)
    Info.Font = Enum.Font.Gotham
    Info.TextSize = 11
    Info.BorderSizePixel = 0
    Info.Parent = Frame
    
    -- Кнопка закрыть
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(1, -20, 0, 30)
    CloseBtn.Position = UDim2.new(0, 10, 0, 330)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseBtn.Text = "✕ Закрыть"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 13
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = Frame
    
    -- Копирование при нажатии на ключ
    KeyDisplay.Focused:Connect(function()
        KeyDisplay:ReleaseFocus()
        if KeyDisplay.Text ~= "Ключ появится здесь..." then
            pcall(function()
                setclipboard(KeyDisplay.Text)
                Status.Text = "✅ Ключ скопирован в буфер обмена!"
                Status.TextColor3 = Color3.fromRGB(0, 255, 0)
            end)
        end
    end)
    
    -- Генерация
    GenButton.MouseButton1Click:Connect(function()
        if PassInput.Text ~= CONFIG.AdminPassword then
            Status.Text = "❌ Неверный пароль!"
            Status.TextColor3 = Color3.fromRGB(255, 100, 100)
            return
        end
        
        Status.Text = "⏳ Генерация ключа через Keymaster..."
        Status.TextColor3 = Color3.fromRGB(255, 200, 0)
        
        local selectedType = keyTypes[currentType]
        local key = GenerateKeymasterKey(selectedType.duration, selectedType.type)
        
        if key then
            KeyDisplay.Text = key
            Status.Text = "✅ Ключ создан! Нажмите на него чтобы скопировать"
            Status.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            Status.Text = "❌ Ошибка! Проверьте API ключ в CONFIG"
            Status.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end)
    
    CloseBtn.MouseButton1Click:Connect(function()
        AdminGui:Destroy()
    end)
end

-- ============================================
-- ГЛАВНЫЙ GUI
-- ============================================
local function CreateMainGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BABFT_Hack"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 600, 0, 480)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -240)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -50, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "🌟 BABFT HACK | Keymaster + Supabase"
    Title.TextColor3 = Color3.fromRGB(255, 215, 0)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 16
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.BorderSizePixel = 0
    CloseButton.Parent = TitleBar
    
    -- Tab Buttons
    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(0, 140, 1, -40)
    TabFrame.Position = UDim2.new(0, 0, 0, 40)
    TabFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    TabFrame.BorderSizePixel = 0
    TabFrame.Parent = MainFrame
    
    local Tabs = {}
    local TabButtons = {}
    local TabNames = {"🔑 Key", "⚔️ Farm", "🛡️ God", "✈️ Fly", "🤖 AntiAFK"}
    
    for i, name in ipairs(TabNames) do
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, -10, 0, 35)
        TabButton.Position = UDim2.new(0, 5, 0, 10 + (i-1)*40)
        TabButton.BackgroundColor3 = (i == 1) and Color3.fromRGB(60, 60, 100) or Color3.fromRGB(45, 45, 70)
        TabButton.Text = name
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.TextSize = 14
        TabButton.Font = Enum.Font.Gotham
        TabButton.BorderSizePixel = 0
        TabButton.Parent = TabFrame
        TabButtons[i] = TabButton
        
        local Page = Instance.new("Frame")
        Page.Size = UDim2.new(1, -150, 1, -50)
        Page.Position = UDim2.new(0, 145, 0, 45)
        Page.BackgroundTransparency = 1
        Page.Visible = (i == 1)
        Page.Parent = MainFrame
        Tabs[i] = Page
        
        TabButton.MouseButton1Click:Connect(function()
            for j, p in ipairs(Tabs) do
                p.Visible = (j == i)
            end
            for j, btn in ipairs(TabButtons) do
                btn.BackgroundColor3 = (j == i) and Color3.fromRGB(60, 60, 100) or Color3.fromRGB(45, 45, 70)
            end
        end)
    end
    
    -- ========== KEY PAGE ==========
    local KeyPage = Tabs[1]
    
    local KeyInput = Instance.new("TextBox")
    KeyInput.Size = UDim2.new(1, -20, 0, 35)
    KeyInput.Position = UDim2.new(0, 10, 0, 20)
    KeyInput.BackgroundColor3 = Color3.fromRGB(45, 45, 70)
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.PlaceholderText = "Введите ключ..."
    KeyInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    KeyInput.Font = Enum.Font.Gotham
    KeyInput.TextSize = 14
    KeyInput.BorderSizePixel = 0
    KeyInput.Parent = KeyPage
    
    local KeyStatus = Instance.new("TextLabel")
    KeyStatus.Size = UDim2.new(1, -20, 0, 50)
    KeyStatus.Position = UDim2.new(0, 10, 0, 65)
    KeyStatus.BackgroundColor3 = Color3.fromRGB(45, 45, 70)
    KeyStatus.Text = "Статус: Ожидание ключа..."
    KeyStatus.TextColor3 = Color3.fromRGB(255, 200, 0)
    KeyStatus.Font = Enum.Font.Gotham
    KeyStatus.TextSize = 13
    KeyStatus.TextXAlignment = Enum.TextXAlignment.Center
    KeyStatus.BorderSizePixel = 0
    KeyStatus.Parent = KeyPage
    
    local ActivateButton = Instance.new("TextButton")
    ActivateButton.Size = UDim2.new(0, 180, 0, 40)
    ActivateButton.Position = UDim2.new(0.5, -90, 0, 130)
    ActivateButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    ActivateButton.Text = "🔓 Активировать"
    ActivateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ActivateButton.Font = Enum.Font.GothamBold
    ActivateButton.TextSize = 16
    ActivateButton.BorderSizePixel = 0
    ActivateButton.Parent = KeyPage
    
    local HWIDLabel = Instance.new("TextLabel")
    HWIDLabel.Size = UDim2.new(1, -20, 0, 30)
    HWIDLabel.Position = UDim2.new(0, 10, 0, 190)
    HWIDLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
    HWIDLabel.Text = "HWID: " .. HWID
    HWIDLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    HWIDLabel.Font = Enum.Font.Gotham
    HWIDLabel.TextSize = 11
    HWIDLabel.TextXAlignment = Enum.TextXAlignment.Center
    HWIDLabel.BorderSizePixel = 0
    HWIDLabel.Parent = KeyPage
    
    -- ========== FARM PAGE ==========
    local FarmPage = Tabs[2]
    
    local FarmToggle = Instance.new("TextButton")
    FarmToggle.Size = UDim2.new(1, -20, 0, 45)
    FarmToggle.Position = UDim2.new(0, 10, 0, 20)
    FarmToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    FarmToggle.Text = "⚔️ Auto Farm: OFF"
    FarmToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    FarmToggle.Font = Enum.Font.GothamBold
    FarmToggle.TextSize = 16
    FarmToggle.BorderSizePixel = 0
    FarmToggle.Parent = FarmPage
    
    local PlatformInfo = Instance.new("TextLabel")
    PlatformInfo.Size = UDim2.new(1, -20, 0, 40)
    PlatformInfo.Position = UDim2.new(0, 10, 0, 75)
    PlatformInfo.BackgroundColor3 = Color3.fromRGB(45, 45, 70)
    PlatformInfo.Text = "🔷 Платформа под игроком\n   (автоматически при фарме)"
    PlatformInfo.TextColor3 = Color3.fromRGB(180, 200, 255)
    PlatformInfo.Font = Enum.Font.Gotham
    PlatformInfo.TextSize = 12
    PlatformInfo.TextXAlignment = Enum.TextXAlignment.Left
    PlatformInfo.BorderSizePixel = 0
    PlatformInfo.Parent = FarmPage
    
    local FarmSpeedLabel = Instance.new("TextLabel")
    FarmSpeedLabel.Size = UDim2.new(1, -20, 0, 25)
    FarmSpeedLabel.Position = UDim2.new(0, 10, 0, 130)
    FarmSpeedLabel.BackgroundTransparency = 1
    FarmSpeedLabel.Text = "Скорость фарма: 1x"
    FarmSpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    FarmSpeedLabel.Font = Enum.Font.Gotham
    FarmSpeedLabel.TextSize = 13
    FarmSpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
    FarmSpeedLabel.Parent = FarmPage
    
    local SpeedUpButton = Instance.new("TextButton")
    SpeedUpButton.Size = UDim2.new(0, 80, 0, 30)
    SpeedUpButton.Position = UDim2.new(0, 10, 0, 165)
    SpeedUpButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    SpeedUpButton.Text = "➕ Speed+"
    SpeedUpButton.Font = Enum.Font.Gotham
    SpeedUpButton.TextSize = 12
    SpeedUpButton.BorderSizePixel = 0
    SpeedUpButton.Parent = FarmPage
    
    local SpeedDownButton = Instance.new("TextButton")
    SpeedDownButton.Size = UDim2.new(0, 80, 0, 30)
    SpeedDownButton.Position = UDim2.new(0, 100, 0, 165)
    SpeedDownButton.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    SpeedDownButton.Text = "➖ Speed-"
    SpeedDownButton.Font = Enum.Font.Gotham
    SpeedDownButton.TextSize = 12
    SpeedDownButton.BorderSizePixel = 0
    SpeedDownButton.Parent = FarmPage
    
    -- ========== GOD PAGE ==========
    local GodPage = Tabs[3]
    
    local GodToggle = Instance.new("TextButton")
    GodToggle.Size = UDim2.new(1, -20, 0, 45)
    GodToggle.Position = UDim2.new(0, 10, 0, 20)
    GodToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    GodToggle.Text = "🛡️ God Mode: OFF"
    GodToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    GodToggle.Font = Enum.Font.GothamBold
    GodToggle.TextSize = 16
    GodToggle.BorderSizePixel = 0
    GodToggle.Parent = GodPage
    
    local GodInfo = Instance.new("TextLabel")
    GodInfo.Size = UDim2.new(1, -20, 0, 80)
    GodInfo.Position = UDim2.new(0, 10, 0, 85)
    GodInfo.BackgroundColor3 = Color3.fromRGB(45, 45, 70)
    GodInfo.Text = "🛡️ Бесконечное здоровье\n👻 Нет коллизии с объектами\n💪 Вы неуязвимы!\n🔄 Авто-восстановление HP"
    GodInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
    GodInfo.Font = Enum.Font.Gotham
    GodInfo.TextSize = 12
    GodInfo.TextXAlignment = Enum.TextXAlignment.Left
    GodInfo.BorderSizePixel = 0
    GodInfo.Parent = GodPage
    
    -- ========== FLY PAGE ==========
    local FlyPage = Tabs[4]
    
    local FlyToggle = Instance.new("TextButton")
    FlyToggle.Size = UDim2.new(1, -20, 0, 45)
    FlyToggle.Position = UDim2.new(0, 10, 0, 20)
    FlyToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    FlyToggle.Text = "✈️ Fly: OFF"
    FlyToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    FlyToggle.Font = Enum.Font.GothamBold
    FlyToggle.TextSize = 16
    FlyToggle.BorderSizePixel = 0
    FlyToggle.Parent = FlyPage
    
    local FlySpeedLabel = Instance.new("TextLabel")
    FlySpeedLabel.Size = UDim2.new(1, -20, 0, 25)
    FlySpeedLabel.Position = UDim2.new(0, 10, 0, 80)
    FlySpeedLabel.BackgroundTransparency = 1
    FlySpeedLabel.Text = "Скорость полёта: 50"
    FlySpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    FlySpeedLabel.Font = Enum.Font.Gotham
    FlySpeedLabel.TextSize = 13
    FlySpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
    FlySpeedLabel.Parent = FlyPage
    
    local FlySpeedUp = Instance.new("TextButton")
    FlySpeedUp.Size = UDim2.new(0, 80, 0, 30)
    FlySpeedUp.Position = UDim2.new(0, 10, 0, 115)
    FlySpeedUp.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    FlySpeedUp.Text = "➕ Speed+"
    FlySpeedUp.Font = Enum.Font.Gotham
    FlySpeedUp.TextSize = 12
    FlySpeedUp.BorderSizePixel = 0
    FlySpeedUp.Parent = FlyPage
    
    local FlySpeedDown = Instance.new("TextButton")
    FlySpeedDown.Size = UDim2.new(0, 80, 0, 30)
    FlySpeedDown.Position = UDim2.new(0, 100, 0, 115)
    FlySpeedDown.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    FlySpeedDown.Text = "➖ Speed-"
    FlySpeedDown.Font = Enum.Font.Gotham
    FlySpeedDown.TextSize = 12
    FlySpeedDown.BorderSizePixel = 0
    FlySpeedDown.Parent = FlyPage
    
    local FlyControls = Instance.new("TextLabel")
    FlyControls.Size = UDim2.new(1, -20, 0, 80)
    FlyControls.Position = UDim2.new(0, 10, 0, 160)
    FlyControls.BackgroundColor3 = Color3.fromRGB(45, 45, 70)
    FlyControls.Text = "🎮 ПК: WASD + Space/Shift\n📱 Телефон: кнопки на экране\n⚡ Плавное управление как в Fly GUI V3"
    FlyControls.TextColor3 = Color3.fromRGB(255, 255, 255)
    FlyControls.Font = Enum.Font.Gotham
    FlyControls.TextSize = 12
    FlyControls.TextXAlignment = Enum.TextXAlignment.Left
    FlyControls.BorderSizePixel = 0
    FlyControls.Parent = FlyPage
    
    -- ========== ANTI-AFK PAGE ==========
    local AntiAFKPage = Tabs[5]
    
    local AntiAFKToggle = Instance.new("TextButton")
    AntiAFKToggle.Size = UDim2.new(1, -20, 0, 45)
    AntiAFKToggle.Position = UDim2.new(0, 10, 0, 20)
    AntiAFKToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    AntiAFKToggle.Text = "🤖 Anti-AFK: OFF"
    AntiAFKToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    AntiAFKToggle.Font = Enum.Font.GothamBold
    AntiAFKToggle.TextSize = 16
    AntiAFKToggle.BorderSizePixel = 0
    AntiAFKToggle.Parent = AntiAFKPage
    
    local AntiAFKInfo = Instance.new("TextLabel")
    AntiAFKInfo.Size = UDim2.new(1, -20, 0, 100)
    AntiAFKInfo.Position = UDim2.new(0, 10, 0, 85)
    AntiAFKInfo.BackgroundColor3 = Color3.fromRGB(45, 45, 70)
    AntiAFKInfo.Text = "🤖 Анти-АФК система:\n\n• Микро-шаг каждые 5 секунд\n• Случайное направление\n• Возврат на место\n• Защита от кика за бездействие\n• Работает вместе с Auto Farm"
    AntiAFKInfo.TextColor3 = Color3.fromRGB(200, 255, 200)
    AntiAFKInfo.Font = Enum.Font.Gotham
    AntiAFKInfo.TextSize = 12
    AntiAFKInfo.TextXAlignment = Enum.TextXAlignment.Left
    AntiAFKInfo.BorderSizePixel = 0
    AntiAFKInfo.Parent = AntiAFKPage
    
    -- ========== BUTTON HANDLERS ==========
    
    CloseButton.MouseButton1Click:Connect(function()
        Features.AutoFarm = false
        Features.GodMode = false
        Features.FlyEnabled = false
        Features.AntiAFK = false
        Features.MobileFlyActive = false
        
        if Features.Platform then
            Features.Platform:Destroy()
        end
        
        ScreenGui:Destroy()
    end)
    
    ActivateButton.MouseButton1Click:Connect(function()
        local key = KeyInput.Text
        if key == "" then
            KeyStatus.Text = "❌ Введите ключ!"
            KeyStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
            return
        end
        
        KeyStatus.Text = "⏳ Проверка ключа через Keymaster..."
        KeyStatus.TextColor3 = Color3.fromRGB(255, 200, 0)
        
        local valid, expiry, message = VerifyKeymasterKey(key)
        
        if valid then
            Features.KeyValid = true
            KeyStatus.Text = message
            KeyStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
            ActivateButton.Text = "✅ Активирован"
            ActivateButton.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
        else
            KeyStatus.Text = message
            KeyStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end)
    
    FarmToggle.MouseButton1Click:Connect(function()
        if not Features.KeyValid then
            KeyStatus.Text = "❌ Сначала активируйте ключ!"
            return
        end
        
        Features.AutoFarm = not Features.AutoFarm
        FarmToggle.Text = "⚔️ Auto Farm: " .. (Features.AutoFarm and "ON" or "OFF")
        FarmToggle.BackgroundColor3 = Features.AutoFarm and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(200, 50, 50)
        
        if Features.AutoFarm then
            AutoFarm()
        end
    end)
    
    SpeedUpButton.MouseButton1Click:Connect(function()
        if Features.FarmSpeed < 10 then
            Features.FarmSpeed = Features.FarmSpeed + 1
            FarmSpeedLabel.Text = "Скорость фарма: " .. Features.FarmSpeed .. "x"
        end
    end)
    
    SpeedDownButton.MouseButton1Click:Connect(function()
        if Features.FarmSpeed > 1 then
            Features.FarmSpeed = Features.FarmSpeed - 1
            FarmSpeedLabel.Text = "Скорость фарма: " .. Features.FarmSpeed .. "x"
        end
    end)
    
    GodToggle.MouseButton1Click:Connect(function()
        if not Features.KeyValid then
            KeyStatus.Text = "❌ Сначала активируйте ключ!"
            return
        end
        
        Features.GodMode = not Features.GodMode
        GodToggle.Text = "🛡️ God Mode: " .. (Features.GodMode and "ON" or "OFF")
        GodToggle.BackgroundColor3 = Features.GodMode and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(200, 50, 50)
        
        if Features.GodMode then
            GodMode()
        end
    end)
    
    FlyToggle.MouseButton1Click:Connect(function()
        if not Features.KeyValid then
            KeyStatus.Text = "❌ Сначала активируйте ключ!"
            return
        end
        
        Features.FlyEnabled = not Features.FlyEnabled
        FlyToggle.Text = "✈️ Fly: " .. (Features.FlyEnabled and "ON" or "OFF")
        FlyToggle.BackgroundColor3 = Features.FlyEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(200, 50, 50)
        
        if Features.FlyEnabled then
            MobileFly()
        else
            Features.MobileFlyActive = false
        end
    end)
    
    FlySpeedUp.MouseButton1Click:Connect(function()
        Features.FlySpeed = math.min(Features.FlySpeed + 10, 200)
        FlySpeedLabel.Text = "Скорость полёта: " .. Features.FlySpeed
    end)
    
    FlySpeedDown.MouseButton1Click:Connect(function()
        Features.FlySpeed = math.max(Features.FlySpeed - 10, 10)
        FlySpeedLabel.Text = "Скорость полёта: " .. Features.FlySpeed
    end)
    
    AntiAFKToggle.MouseButton1Click:Connect(function()
        if not Features.KeyValid then
            KeyStatus.Text = "❌ Сначала активируйте ключ!"
            return
        end
        
        Features.AntiAFK = not Features.AntiAFK
        AntiAFKToggle.Text = "🤖 Anti-AFK: " .. (Features.AntiAFK and "ON" or "OFF")
        AntiAFKToggle.BackgroundColor3 = Features.AntiAFK and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(200, 50, 50)
        
        if Features.AntiAFK then
            AntiAFKSystem()
        end
    end)
    
    -- Кнопка админ-панели
    local AdminBtn = Instance.new("TextButton")
    AdminBtn.Size = UDim2.new(0, 160, 0, 25)
    AdminBtn.Position = UDim2.new(1, -170, 0, 10)
    AdminBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    AdminBtn.BackgroundTransparency = 0.5
    AdminBtn.Text = "🔑 Keymaster Admin"
    AdminBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
    AdminBtn.Font = Enum.Font.GothamBold
    AdminBtn.TextSize = 11
    AdminBtn.BorderSizePixel = 0
    AdminBtn.Parent = ScreenGui
    
    AdminBtn.MouseButton1Click:Connect(function()
        CreateAdminPanel()
    end)
    
    -- Авто-проверка сохраненного ключа
    spawn(function()
        local valid, savedKey = CheckSavedKey()
        if valid and savedKey then
            Features.KeyValid = true
            KeyStatus.Text = "✅ Ключ активен (авто-вход)"
            KeyStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
            ActivateButton.Text = "✅ Активирован"
            ActivateButton.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
            KeyInput.Text = savedKey
        end
    end)
    
    return ScreenGui
end

-- ============================================
-- ЗАПУСК
-- ============================================
print("🌟 BABFT HACK загружен!")
print("🔑 HWID:", HWID)
print("📋 Keymaster App ID:", CONFIG.Keymaster_AppID)
print("💾 Supabase:", CONFIG.Supabase_URL ~= "https://ВАШ_ПРОЕКТ.supabase.co" and "Настроен" or "Требуется настройка")

CreateMainGUI()
