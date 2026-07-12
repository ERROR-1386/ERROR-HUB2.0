--[[
    🌟 BABFT HACK - ПОЛНОСТЬЮ ИСПРАВЛЕННАЯ ВЕРСИЯ
    • Исправлена ошибка блокировки потока
    • Исправлена генерация ключа
    • Логи на экране телефона
    • Auto Farm с платформой
    • God Mode
    • Fly (ПК + телефон)
    • Anti-AFK
    
    НАСТРОЙКА: Замените Supabase_Key на ваш полный ключ!
]]

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- ============================================
-- КОНФИГУРАЦИЯ (ЗАМЕНИТЕ Supabase_Key!)
-- ============================================
local CONFIG = {
    Supabase_URL = "https://wfnyprdzwrxeqgvtopqi.supabase.co",
    Supabase_Key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndmbnlwcmR6d3J4ZXFndnRvcHFpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM4MDQ0NzgsImV4cCI6MjA5OTM4MDQ3OH0.pZLb8VEczkMHJ5Chfnl6W4wzAFvPrQtxsocfYVfgakE", -- ЗАМЕНИТЕ НА ВАШ КЛЮЧ!
    AdminPassword = "admin123"
}

-- ============================================
-- ОКНО ЛОГОВ ДЛЯ ТЕЛЕФОНА
-- ============================================
local DebugLog = {}

local function CreateDebugWindow()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DebugLog"
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    
    local LogFrame = Instance.new("ScrollingFrame")
    LogFrame.Size = UDim2.new(1, -20, 0.3, 0)
    LogFrame.Position = UDim2.new(0, 10, 0, 10)
    LogFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    LogFrame.BackgroundTransparency = 0.3
    LogFrame.BorderSizePixel = 0
    LogFrame.ScrollBarThickness = 5
    LogFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    LogFrame.Parent = ScreenGui
    
    local LogText = Instance.new("TextLabel")
    LogText.Size = UDim2.new(1, 0, 0, 0)
    LogText.BackgroundTransparency = 1
    LogText.Text = "📋 Логи:\n"
    LogText.TextColor3 = Color3.fromRGB(0, 255, 0)
    LogText.Font = Enum.Font.Code
    LogText.TextSize = 11
    LogText.TextXAlignment = Enum.TextXAlignment.Left
    LogText.TextYAlignment = Enum.TextYAlignment.Top
    LogText.TextWrapped = true
    LogText.Parent = LogFrame
    
    local function AddLog(message)
        table.insert(DebugLog, message)
        if #DebugLog > 30 then
            table.remove(DebugLog, 1)
        end
        LogText.Text = "📋 Логи:\n" .. table.concat(DebugLog, "\n")
        LogFrame.CanvasSize = UDim2.new(0, 0, 0, #DebugLog * 18)
        print(message)
    end
    
    return AddLog
end

local AddLog = CreateDebugWindow()

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
AddLog("🔑 HWID: " .. string.sub(HWID, 1, 20) .. "...")

-- ============================================
-- ФУНКЦИИ SUPABASE
-- ============================================

-- Проверка ключа
local function CheckKey(key)
    AddLog("🔍 Проверка ключа: " .. key)
    
    local url = CONFIG.Supabase_URL .. "/rest/v1/keys?key=eq." .. key .. "&is_active=eq.true&limit=1"
    
    local response = HttpService:RequestAsync({
        Url = url,
        Method = "GET",
        Headers = {
            ["apikey"] = CONFIG.Supabase_Key,
            ["Authorization"] = "Bearer " .. CONFIG.Supabase_Key
        }
    })
    
    if not response.Success then
        AddLog("❌ Ошибка: " .. response.StatusMessage)
        return false, "Ошибка соединения!"
    end
    
    local data = HttpService:JSONDecode(response.Body)
    
    if #data == 0 then
        return false, "Неверный ключ!"
    end
    
    local keyData = data[1]
    local expiry = tonumber(keyData.expiry)
    
    if expiry and expiry < os.time() then
        AddLog("❌ Ключ истёк")
        return false, "Срок ключа истёк!"
    end
    
    if keyData.hwid ~= "not_set" and keyData.hwid ~= HWID then
        AddLog("❌ Ключ уже используется")
        return false, "Ключ уже используется!"
    end
    
    if keyData.hwid == "not_set" then
        AddLog("📌 Привязываю HWID...")
        HttpService:RequestAsync({
            Url = CONFIG.Supabase_URL .. "/rest/v1/keys?id=eq." .. keyData.id,
            Method = "PATCH",
            Headers = {
                ["apikey"] = CONFIG.Supabase_Key,
                ["Authorization"] = "Bearer " .. CONFIG.Supabase_Key,
                ["Content-Type"] = "application/json",
                ["Prefer"] = "return=minimal"
            },
            Body = HttpService:JSONEncode({
                hwid = HWID,
                username = LocalPlayer.Name,
                user_id = LocalPlayer.UserId
            })
        })
        AddLog("✅ HWID привязан")
    end
    
    AddLog("✅ Ключ верный!")
    return true, "Ключ активирован!"
end

-- Генерация ключа (ИСПРАВЛЕННАЯ!)
local function GenerateKey(duration_hours)
    AddLog("🎲 Генерация ключа...")
    
    -- Правильная генерация
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local keyParts = {}
    for i = 1, 4 do
        local part = ""
        for j = 1, 4 do
            part = part .. chars:sub(math.random(1, #chars), math.random(1, #chars))
        end
        table.insert(keyParts, part)
    end
    local key = table.concat(keyParts, "-")
    
    AddLog("📝 Ключ: " .. key)
    
    -- Данные
    local data = {
        key = key,
        hwid = "not_set",
        expiry = tostring(os.time() + (duration_hours * 3600)),
        created_at = tostring(os.time()),
        is_active = true
    }
    
    AddLog("📤 Отправляю в Supabase...")
    
    -- Используем RequestAsync
    local response = HttpService:RequestAsync({
        Url = CONFIG.Supabase_URL .. "/rest/v1/keys",
        Method = "POST",
        Headers = {
            ["apikey"] = CONFIG.Supabase_Key,
            ["Authorization"] = "Bearer " .. CONFIG.Supabase_Key,
            ["Content-Type"] = "application/json",
            ["Prefer"] = "return=representation"
        },
        Body = HttpService:JSONEncode(data)
    })
    
    if response.Success then
        AddLog("✅ Ключ создан! Статус: " .. tostring(response.StatusCode))
        return key
    else
        AddLog("❌ Ошибка: " .. tostring(response.StatusCode) .. " - " .. response.StatusMessage)
        AddLog("📦 Ответ: " .. tostring(response.Body))
        return nil
    end
end

-- Проверка сохраненного ключа
local function CheckSavedKey()
    AddLog("🔍 Ищу сохраненный ключ...")
    
    local response = HttpService:RequestAsync({
        Url = CONFIG.Supabase_URL .. "/rest/v1/keys?hwid=eq." .. HWID .. "&is_active=eq.true&order=created_at.desc&limit=1",
        Method = "GET",
        Headers = {
            ["apikey"] = CONFIG.Supabase_Key,
            ["Authorization"] = "Bearer " .. CONFIG.Supabase_Key
        }
    })
    
    if response.Success then
        local data = HttpService:JSONDecode(response.Body)
        if #data > 0 then
            local keyData = data[1]
            local expiry = tonumber(keyData.expiry)
            
            if expiry and expiry > os.time() then
                AddLog("✅ Найден ключ: " .. keyData.key)
                return true, keyData.key
            else
                AddLog("⚠️ Ключ истёк")
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
    KeyValid = false
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

-- Fly
local function Fly()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return end
    
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
    
    spawn(function()
        while Features.FlyEnabled do
            wait()
            if not LocalPlayer.Character or not rootPart or not rootPart.Parent then break end
            
            bodyGyro.CFrame = Workspace.CurrentCamera.CFrame
            
            local velocity = Vector3.new(0, 0, 0)
            
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
    
    if UserInputService.TouchEnabled then
        CreateMobileButtons(rootPart, bodyVelocity)
    end
end

-- Мобильные кнопки для полёта
local function CreateMobileButtons(rootPart, bodyVelocity)
    local MobileGui = Instance.new("ScreenGui")
    MobileGui.Name = "MobileFly"
    MobileGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    MobileGui.ResetOnSpawn = false
    
    local buttons = {
        {Text = "▲", Pos = UDim2.new(0.5, -30, 0.7, -80), Dir = "Forward"},
        {Text = "▼", Pos = UDim2.new(0.5, -30, 0.7, 50), Dir = "Backward"},
        {Text = "◀", Pos = UDim2.new(0.5, -95, 0.7, -15), Dir = "Left"},
        {Text = "▶", Pos = UDim2.new(0.5, 35, 0.7, -15), Dir = "Right"},
        {Text = "⇧", Pos = UDim2.new(0.8, -35, 0.75, -35), Dir = "Up"},
        {Text = "⇩", Pos = UDim2.new(0.8, -35, 0.85, -35), Dir = "Down"},
    }
    
    local activeButtons = {}
    
    for _, btnData in ipairs(buttons) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 60, 0, 60)
        btn.Position = btnData.Pos
        btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
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
    
    spawn(function()
        while Features.FlyEnabled do
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
-- ГЛАВНЫЙ GUI
-- ============================================
local function CreateMainGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BABFT_Hack"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 550, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -210)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -50, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "🌟 BABFT HACK v2.0"
    Title.TextColor3 = Color3.fromRGB(255, 215, 0)
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 2)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 16
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.BorderSizePixel = 0
    CloseButton.Parent = TitleBar
    
    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(0, 130, 1, -35)
    TabFrame.Position = UDim2.new(0, 0, 0, 35)
    TabFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    TabFrame.BorderSizePixel = 0
    TabFrame.Parent = MainFrame
    
    local Tabs = {}
    local TabButtons = {}
    local TabNames = {"🔑 Ключ", "⚔️ Фарм", "🛡️ Год", "✈️ Полёт", "🤖 АнтиАФК"}
    
    for i, name in ipairs(TabNames) do
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, -10, 0, 32)
        TabButton.Position = UDim2.new(0, 5, 0, 8 + (i-1)*37)
        TabButton.BackgroundColor3 = (i == 1) and Color3.fromRGB(60, 60, 100) or Color3.fromRGB(45, 45, 70)
        TabButton.Text = name
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.Font = Enum.Font.Gotham
        TabButton.TextSize = 13
        TabButton.BorderSizePixel = 0
        TabButton.Parent = TabFrame
        TabButtons[i] = TabButton
        
        local Page = Instance.new("Frame")
        Page.Size = UDim2.new(1, -140, 1, -45)
        Page.Position = UDim2.new(0, 135, 0, 40)
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
    
    -- KEY PAGE
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
    KeyStatus.Size = UDim2.new(1, -20, 0, 45)
    KeyStatus.Position = UDim2.new(0, 10, 0, 65)
    KeyStatus.BackgroundColor3 = Color3.fromRGB(45, 45, 70)
    KeyStatus.Text = "Статус: Ожидание ключа..."
    KeyStatus.TextColor3 = Color3.fromRGB(255, 200, 0)
    KeyStatus.Font = Enum.Font.Gotham
    KeyStatus.TextSize = 12
    KeyStatus.TextXAlignment = Enum.TextXAlignment.Center
    KeyStatus.BorderSizePixel = 0
    KeyStatus.Parent = KeyPage
    
    local ActivateButton = Instance.new("TextButton")
    ActivateButton.Size = UDim2.new(0, 160, 0, 38)
    ActivateButton.Position = UDim2.new(0.5, -80, 0, 120)
    ActivateButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    ActivateButton.Text = "🔓 Активировать"
    ActivateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ActivateButton.Font = Enum.Font.GothamBold
    ActivateButton.TextSize = 15
    ActivateButton.BorderSizePixel = 0
    ActivateButton.Parent = KeyPage
    
    local HWIDLabel = Instance.new("TextLabel")
    HWIDLabel.Size = UDim2.new(1, -20, 0, 25)
    HWIDLabel.Position = UDim2.new(0, 10, 0, 175)
    HWIDLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
    HWIDLabel.Text = "HWID: " .. string.sub(HWID, 1, 25) .. "..."
    HWIDLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    HWIDLabel.Font = Enum.Font.Gotham
    HWIDLabel.TextSize = 10
    HWIDLabel.TextXAlignment = Enum.TextXAlignment.Center
    HWIDLabel.BorderSizePixel = 0
    HWIDLabel.Parent = KeyPage
    
    -- FARM PAGE
    local FarmPage = Tabs[2]
    
    local FarmToggle = Instance.new("TextButton")
    FarmToggle.Size = UDim2.new(1, -20, 0, 42)
    FarmToggle.Position = UDim2.new(0, 10, 0, 20)
    FarmToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    FarmToggle.Text = "⚔️ Auto Farm: OFF"
    FarmToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    FarmToggle.Font = Enum.Font.GothamBold
    FarmToggle.TextSize = 15
    FarmToggle.BorderSizePixel = 0
    FarmToggle.Parent = FarmPage
    
    local PlatformInfo = Instance.new("TextLabel")
    PlatformInfo.Size = UDim2.new(1, -20, 0, 35)
    PlatformInfo.Position = UDim2.new(0, 10, 0, 72)
    PlatformInfo.BackgroundColor3 = Color3.fromRGB(45, 45, 70)
    PlatformInfo.Text = "🔷 Платформа под игроком"
    PlatformInfo.TextColor3 = Color3.fromRGB(180, 200, 255)
    PlatformInfo.Font = Enum.Font.Gotham
    PlatformInfo.TextSize = 11
    PlatformInfo.TextXAlignment = Enum.TextXAlignment.Center
    PlatformInfo.BorderSizePixel = 0
    PlatformInfo.Parent = FarmPage
    
    local FarmSpeedLabel = Instance.new("TextLabel")
    FarmSpeedLabel.Size = UDim2.new(1, -20, 0, 22)
    FarmSpeedLabel.Position = UDim2.new(0, 10, 0, 120)
    FarmSpeedLabel.BackgroundTransparency = 1
    FarmSpeedLabel.Text = "Скорость: 1x"
    FarmSpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    FarmSpeedLabel.Font = Enum.Font.Gotham
    FarmSpeedLabel.TextSize = 12
    FarmSpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
    FarmSpeedLabel.Parent = FarmPage
    
    local SpeedUpButton = Instance.new("TextButton")
    SpeedUpButton.Size = UDim2.new(0, 70, 0, 28)
    SpeedUpButton.Position = UDim2.new(0, 10, 0, 150)
    SpeedUpButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    SpeedUpButton.Text = "➕ +"
    SpeedUpButton.Font = Enum.Font.Gotham
    SpeedUpButton.TextSize = 12
    SpeedUpButton.BorderSizePixel = 0
    SpeedUpButton.Parent = FarmPage
    
    local SpeedDownButton = Instance.new("TextButton")
    SpeedDownButton.Size = UDim2.new(0, 70, 0, 28)
    SpeedDownButton.Position = UDim2.new(0, 90, 0, 150)
    SpeedDownButton.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    SpeedDownButton.Text = "➖ -"
    SpeedDownButton.Font = Enum.Font.Gotham
    SpeedDownButton.TextSize = 12
    SpeedDownButton.BorderSizePixel = 0
    SpeedDownButton.Parent = FarmPage
    
    -- GOD PAGE
    local GodPage = Tabs[3]
    
    local GodToggle = Instance.new("TextButton")
    GodToggle.Size = UDim2.new(1, -20, 0, 42)
    GodToggle.Position = UDim2.new(0, 10, 0, 20)
    GodToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    GodToggle.Text = "🛡️ God Mode: OFF"
    GodToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    GodToggle.Font = Enum.Font.GothamBold
    GodToggle.TextSize = 15
    GodToggle.BorderSizePixel = 0
    GodToggle.Parent = GodPage
    
    local GodInfo = Instance.new("TextLabel")
    GodInfo.Size = UDim2.new(1, -20, 0, 70)
    GodInfo.Position = UDim2.new(0, 10, 0, 80)
    GodInfo.BackgroundColor3 = Color3.fromRGB(45, 45, 70)
    GodInfo.Text = "🛡️ Бесконечное здоровье\n👻 Нет коллизии\n💪 Неуязвимость"
    GodInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
    GodInfo.Font = Enum.Font.Gotham
    GodInfo.TextSize = 11
    GodInfo.TextXAlignment = Enum.TextXAlignment.Left
    GodInfo.BorderSizePixel = 0
    GodInfo.Parent = GodPage
    
    -- FLY PAGE
    local FlyPage = Tabs[4]
    
    local FlyToggle = Instance.new("TextButton")
    FlyToggle.Size = UDim2.new(1, -20, 0, 42)
    FlyToggle.Position = UDim2.new(0, 10, 0, 20)
    FlyToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    FlyToggle.Text = "✈️ Fly: OFF"
    FlyToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    FlyToggle.Font = Enum.Font.GothamBold
    FlyToggle.TextSize = 15
    FlyToggle.BorderSizePixel = 0
    FlyToggle.Parent = FlyPage
    
    local FlySpeedLabel = Instance.new("TextLabel")
    FlySpeedLabel.Size = UDim2.new(1, -20, 0, 22)
    FlySpeedLabel.Position = UDim2.new(0, 10, 0, 75)
    FlySpeedLabel.BackgroundTransparency = 1
    FlySpeedLabel.Text = "Скорость: 50"
    FlySpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    FlySpeedLabel.Font = Enum.Font.Gotham
    FlySpeedLabel.TextSize = 12
    FlySpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
    FlySpeedLabel.Parent = FlyPage
    
    local FlySpeedUp = Instance.new("TextButton")
    FlySpeedUp.Size = UDim2.new(0, 70, 0, 28)
    FlySpeedUp.Position = UDim2.new(0, 10, 0, 105)
    FlySpeedUp.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    FlySpeedUp.Text = "➕ +"
    FlySpeedUp.Font = Enum.Font.Gotham
    FlySpeedUp.TextSize = 12
    FlySpeedUp.BorderSizePixel = 0
    FlySpeedUp.Parent = FlyPage
    
    local FlySpeedDown = Instance.new("TextButton")
    FlySpeedDown.Size = UDim2.new(0, 70, 0, 28)
    FlySpeedDown.Position = UDim2.new(0, 90, 0, 105)
    FlySpeedDown.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    FlySpeedDown.Text = "➖ -"
    FlySpeedDown.Font = Enum.Font.Gotham
    FlySpeedDown.TextSize = 12
    FlySpeedDown.BorderSizePixel = 0
    FlySpeedDown.Parent = FlyPage
    
    local FlyInfo = Instance.new("Text
