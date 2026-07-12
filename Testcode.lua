--[[
    BABFT Auto Farm Script with Key System
    Delta Executor Compatible
    Key System: LootLabs + Supabase
]]

-- ============================================
-- КОНФИГУРАЦИЯ
-- ============================================
local CONFIG = {
    -- LootLabs API
    LootLabs_API = "https://api.lootlabs.gg/v1",
    LootLabs_GameID = "YOUR_GAME_ID", -- Замените на ваш ID игры в LootLabs
    LootLabs_APIKey = "YOUR_API_KEY", -- Замените на ваш API ключ
    
    -- Supabase
    Supabase_URL = "https://wfnyprdzwrxeqgvtopqi.supabase.co", -- Замените на ваш URL
    Supabase_Key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndmbnlwcmR6d3J4ZXFndnRvcHFpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM4MDQ0NzgsImV4cCI6MjA5OTM4MDQ3OH0.pZLb8VEczkMHJ5Chfnl6W4wzAFvPrQtxsocfYVfgakE", -- Замените на ваш анонимный ключ
    
    -- Настройки фарма
    AutoFarm_Enabled = false,
    AutoBuild_Enabled = false,
    AutoCollect_Enabled = false,
    FarmSpeed = 1,
    BuildQuality = "Gold", -- Wood, Stone, Iron, Gold, Diamond
    
    -- GUI настройки
    GUISize = UDim2.new(0, 550, 0, 400),
    GUITheme = "Dark"
}

-- ============================================
-- СЕРВИСЫ
-- ============================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- ============================================
-- KEY SYSTEM (LootLabs + Supabase)
-- ============================================
local KeySystem = {}
KeySystem.__index = KeySystem

function KeySystem.new()
    local self = setmetatable({}, KeySystem)
    self.CurrentKey = nil
    self.KeyValid = false
    self.KeyExpiry = nil
    self.HWID = self:GetHWID()
    return self
end

function KeySystem:GetHWID()
    local success, hwid = pcall(function()
        return game:GetService("RbxAnalyticsService"):GetClientId()
    end)
    if not success then
        hwid = tostring(LocalPlayer.UserId) .. "-" .. tostring(math.random(1000, 9999))
    end
    return hwid
end

-- Проверка ключа через LootLabs
function KeySystem:CheckKeyLootLabs(key)
    local url = CONFIG.LootLabs_API .. "/validate"
    local data = {
        key = key,
        gameid = CONFIG.LootLabs_GameID,
        hwid = self.HWID
    }
    
    local success, response = pcall(function()
        return HttpService:PostAsync(url, HttpService:JSONEncode(data), 
            Enum.HttpContentType.ApplicationJson, 
            false, 
            {["x-api-key"] = CONFIG.LootLabs_APIKey})
    end)
    
    if success then
        local decoded = HttpService:JSONDecode(response)
        if decoded.valid then
            self.CurrentKey = key
            self.KeyValid = true
            self.KeyExpiry = decoded.expiry or (os.time() + 86400)
            self:SaveKeyToSupabase(key, decoded.expiry)
            return true, "Ключ активирован через LootLabs!"
        else
            return false, decoded.message or "Неверный ключ!"
        end
    end
    return false, "Ошибка проверки ключа в LootLabs!"
end

-- Сохранение ключа в Supabase
function KeySystem:SaveKeyToSupabase(key, expiry)
    local url = CONFIG.Supabase_URL .. "/rest/v1/keys"
    local data = {
        key = key,
        hwid = self.HWID,
        user_id = LocalPlayer.UserId,
        username = LocalPlayer.Name,
        expiry = tostring(expiry or (os.time() + 86400)),
        created_at = tostring(os.time()),
        is_active = true
    }
    
    pcall(function()
        HttpService:PostAsync(url, HttpService:JSONEncode(data), 
            Enum.HttpContentType.ApplicationJson, 
            false,
            {
                ["apikey"] = CONFIG.Supabase_Key,
                ["Authorization"] = "Bearer " .. CONFIG.Supabase_Key,
                ["Content-Type"] = "application/json",
                ["Prefer"] = "return=minimal"
            })
    end)
end

-- Проверка ключа в Supabase
function KeySystem:CheckKeySupabase()
    local url = CONFIG.Supabase_URL .. "/rest/v1/keys?hwid=eq." .. self.HWID .. 
                "&is_active=eq.true&order=created_at.desc&limit=1"
    
    local success, response = pcall(function()
        return HttpService:GetAsync(url, false, {
            ["apikey"] = CONFIG.Supabase_Key,
            ["Authorization"] = "Bearer " .. CONFIG.Supabase_Key
        })
    end)
    
    if success then
        local decoded = HttpService:JSONDecode(response)
        if #decoded > 0 then
            local keyData = decoded[1]
            local expiry = tonumber(keyData.expiry)
            if expiry and expiry > os.time() then
                self.CurrentKey = keyData.key
                self.KeyValid = true
                self.KeyExpiry = expiry
                return true
            else
                self:DeactivateKey(keyData.key)
            end
        end
    end
    return false
end

-- Деактивация ключа
function KeySystem:DeactivateKey(key)
    local url = CONFIG.Supabase_URL .. "/rest/v1/keys?key=eq." .. key
    pcall(function()
        HttpService:RequestAsync({
            Url = url,
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

-- Сброс HWID (админ функция)
function KeySystem:ResetHWID(adminKey, targetHWID)
    local url = CONFIG.Supabase_URL .. "/rest/v1/keys?hwid=eq." .. targetHWID
    local success, response = pcall(function()
        return HttpService:GetAsync(url, false, {
            ["apikey"] = CONFIG.Supabase_Key,
            ["Authorization"] = "Bearer " .. CONFIG.Supabase_Key
        })
    end)
    
    if success then
        local decoded = HttpService:JSONDecode(response)
        for _, keyData in ipairs(decoded) do
            self:DeactivateKey(keyData.key)
        end
        return true
    end
    return false
end

-- ============================================
-- GUI
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BABFT_Farm"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = CONFIG.GUISize
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "BABFT Auto Farm | Key System"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 2)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.GothamBold
CloseButton.BorderSizePixel = 0
CloseButton.Parent = TitleBar

-- Tab System
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, 0, 0, 30)
TabFrame.Position = UDim2.new(0, 0, 0, 35)
TabFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TabFrame.BorderSizePixel = 0
TabFrame.Parent = MainFrame

local Tabs = {}
local TabButtons = {}
local TabNames = {"🔑 Key System", "⚙️ Auto Farm", "🏗️ Auto Build", "📦 Collector", "🔧 Settings"}

for i, name in ipairs(TabNames) do
    local Tab = Instance.new("TextButton")
    Tab.Size = UDim2.new(0.2, -2, 1, 0)
    Tab.Position = UDim2.new((i-1)*0.2, 0, 0, 0)
    Tab.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Tab.Text = name
    Tab.TextColor3 = Color3.fromRGB(200, 200, 200)
    Tab.TextSize = 12
    Tab.Font = Enum.Font.Gotham
    Tab.BorderSizePixel = 0
    Tab.Parent = TabFrame
    TabButtons[i] = Tab
    
    -- Content Pages
    local Page = Instance.new("Frame")
    Page.Size = UDim2.new(1, -20, 1, -85)
    Page.Position = UDim2.new(0, 10, 0, 75)
    Page.BackgroundTransparency = 1
    Page.Visible = (i == 1)
    Page.Parent = MainFrame
    Tabs[i] = Page
    
    Tab.MouseButton1Click:Connect(function()
        for j, p in ipairs(Tabs) do
            p.Visible = (j == i)
        end
        for j, btn in ipairs(TabButtons) do
            btn.BackgroundColor3 = (j == i) and Color3.fromRGB(70, 70, 70) or Color3.fromRGB(50, 50, 50)
        end
    end)
end

-- ============================================
-- KEY SYSTEM PAGE
-- ============================================
local KeyPage = Tabs[1]

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(1, -20, 0, 30)
KeyInput.Position = UDim2.new(0, 10, 0, 20)
KeyInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.TextSize = 14
KeyInput.Font = Enum.Font.Gotham
KeyInput.PlaceholderText = "Введите ключ..."
KeyInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
KeyInput.BorderSizePixel = 0
KeyInput.Parent = KeyPage

local KeyStatus = Instance.new("TextLabel")
KeyStatus.Size = UDim2.new(1, -20, 0, 30)
KeyStatus.Position = UDim2.new(0, 10, 0, 60)
KeyStatus.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
KeyStatus.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyStatus.TextSize = 14
KeyStatus.Font = Enum.Font.Gotham
KeyStatus.Text = "Статус: Ожидание ключа"
KeyStatus.BorderSizePixel = 0
KeyStatus.Parent = KeyPage

local ActivateButton = Instance.new("TextButton")
ActivateButton.Size = UDim2.new(0, 150, 0, 35)
ActivateButton.Position = UDim2.new(0.5, -75, 0, 100)
ActivateButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
ActivateButton.Text = "Активировать"
ActivateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ActivateButton.TextSize = 16
ActivateButton.Font = Enum.Font.GothamBold
ActivateButton.BorderSizePixel = 0
ActivateButton.Parent = KeyPage

local ResetHWIDButton = Instance.new("TextButton")
ResetHWIDButton.Size = UDim2.new(0, 150, 0, 35)
ResetHWIDButton.Position = UDim2.new(0.5, -75, 0, 145)
ResetHWIDButton.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
ResetHWIDButton.Text = "Сбросить HWID (Admin)"
ResetHWIDButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetHWIDButton.TextSize = 12
ResetHWIDButton.Font = Enum.Font.Gotham
ResetHWIDButton.BorderSizePixel = 0
ResetHWIDButton.Parent = KeyPage

local KeyInfo = Instance.new("TextLabel")
KeyInfo.Size = UDim2.new(1, -20, 0, 60)
KeyInfo.Position = UDim2.new(0, 10, 0, 190)
KeyInfo.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
KeyInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
KeyInfo.TextSize = 11
KeyInfo.Font = Enum.Font.Gotham
KeyInfo.Text = "Информация о ключе:\n• Ключ действителен 24 часа\n• Привязывается к HWID\n• Для сброса HWID обратитесь к администратору"
KeyInfo.TextXAlignment = Enum.TextXAlignment.Left
KeyInfo.BorderSizePixel = 0
KeyInfo.Parent = KeyPage

-- ============================================
-- AUTO FARM PAGE
-- ============================================
local FarmPage = Tabs[2]

local FarmToggle = Instance.new("TextButton")
FarmToggle.Size = UDim2.new(1, -20, 0, 35)
FarmToggle.Position = UDim2.new(0, 10, 0, 20)
FarmToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
FarmToggle.Text = "Auto Farm: OFF"
FarmToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
FarmToggle.TextSize = 16
FarmToggle.Font = Enum.Font.GothamBold
FarmToggle.BorderSizePixel = 0
FarmToggle.Parent = FarmPage

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, -20, 0, 20)
SpeedLabel.Position = UDim2.new(0, 10, 0, 65)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.TextSize = 14
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.Text = "Скорость фарма: 1x"
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = FarmPage

local SpeedSlider = Instance.new("TextButton")
SpeedSlider.Size = UDim2.new(0, 20, 0, 20)
SpeedSlider.Position = UDim2.new(0, 150, 0, 90)
SpeedSlider.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
SpeedSlider.Text = ""
SpeedSlider.BorderSizePixel = 0
SpeedSlider.Parent = FarmPage

-- ============================================
-- AUTO BUILD PAGE
-- ============================================
local BuildPage = Tabs[3]

local BuildToggle = Instance.new("TextButton")
BuildToggle.Size = UDim2.new(1, -20, 0, 35)
BuildToggle.Position = UDim2.new(0, 10, 0, 20)
BuildToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
BuildToggle.Text = "Auto Build: OFF"
BuildToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
BuildToggle.TextSize = 16
BuildToggle.Font = Enum.Font.GothamBold
BuildToggle.BorderSizePixel = 0
BuildToggle.Parent = BuildPage

local QualityButtons = {}
local Qualities = {"Wood", "Stone", "Iron", "Gold", "Diamond"}
for i, quality in ipairs(Qualities) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, 65 + (i-1)*35)
    btn.BackgroundColor3 = (quality == CONFIG.BuildQuality) and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
    btn.Text = quality
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.Gotham
    btn.BorderSizePixel = 0
    btn.Parent = BuildPage
    QualityButtons[i] = btn
end

-- ============================================
-- COLLECTOR PAGE
-- ============================================
local CollectorPage = Tabs[4]

local CollectorToggle = Instance.new("TextButton")
CollectorToggle.Size = UDim2.new(1, -20, 0, 35)
CollectorToggle.Position = UDim2.new(0, 10, 0, 20)
CollectorToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CollectorToggle.Text = "Auto Collect: OFF"
CollectorToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
CollectorToggle.TextSize = 16
CollectorToggle.Font = Enum.Font.GothamBold
CollectorToggle.BorderSizePixel = 0
CollectorToggle.Parent = CollectorPage

-- ============================================
-- SETTINGS PAGE
-- ============================================
local SettingsPage = Tabs[5]

local HWIDLabel = Instance.new("TextLabel")
HWIDLabel.Size = UDim2.new(1, -20, 0, 30)
HWIDLabel.Position = UDim2.new(0, 10, 0, 20)
HWIDLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
HWIDLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
HWIDLabel.TextSize = 12
HWIDLabel.Font = Enum.Font.Gotham
HWIDLabel.Text = "Ваш HWID: " .. KeySystem:GetHWID()
HWIDLabel.TextXAlignment = Enum.TextXAlignment.Left
HWIDLabel.BorderSizePixel = 0
HWIDLabel.Parent = SettingsPage

-- ============================================
-- ФУНКЦИОНАЛ
-- ============================================

-- Инициализация Key System
local KeySys = KeySystem.new()

-- Проверка сохраненного ключа при запуске
if KeySys:CheckKeySupabase() then
    KeyStatus.Text = "Статус: Ключ активен (из Supabase)"
    KeyStatus.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    ActivateButton.Text = "Ключ активен"
    ActivateButton.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
end

-- Активация ключа
ActivateButton.MouseButton1Click:Connect(function()
    local key = KeyInput.Text
    if key == "" then
        KeyStatus.Text = "Статус: Введите ключ!"
        KeyStatus.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        return
    end
    
    KeyStatus.Text = "Статус: Проверка ключа..."
    KeyStatus.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
    
    -- Проверка через LootLabs
    local success, message = KeySys:CheckKeyLootLabs(key)
    
    if success then
        KeyStatus.Text = "Статус: " .. message
        KeyStatus.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        ActivateButton.Text = "Ключ активен"
        ActivateButton.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        EnableFeatures()
    else
        KeyStatus.Text = "Статус: " .. message
        KeyStatus.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

-- Сброс HWID (админ панель)
ResetHWIDButton.MouseButton1Click:Connect(function()
    local adminKey = KeyInput.Text
    local targetHWID = HWIDLabel.Text:gsub("Ваш HWID: ", "")
    
    if KeySys:ResetHWID(adminKey, targetHWID) then
        KeyStatus.Text = "Статус: HWID сброшен"
        KeyStatus.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    else
        KeyStatus.Text = "Статус: Ошибка сброса HWID"
        KeyStatus.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

-- Включение функций после активации
function EnableFeatures()
    CONFIG.AutoFarm_Enabled = true
    CONFIG.AutoBuild_Enabled = true
    CONFIG.AutoCollect_Enabled = true
end

-- Auto Farm
FarmToggle.MouseButton1Click:Connect(function()
    if not KeySys.KeyValid then
        KeyStatus.Text = "Статус: Требуется активация ключа!"
        KeyStatus.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        return
    end
    
    CONFIG.AutoFarm_Enabled = not CONFIG.AutoFarm_Enabled
    FarmToggle.Text = "Auto Farm: " .. (CONFIG.AutoFarm_Enabled and "ON" or "OFF")
    FarmToggle.BackgroundColor3 = CONFIG.AutoFarm_Enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(200, 50, 50)
end)

-- Auto Build
BuildToggle.MouseButton1Click:Connect(function()
    if not KeySys.KeyValid then
        KeyStatus.Text = "Статус: Требуется активация ключа!"
        KeyStatus.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        return
    end
    
    CONFIG.AutoBuild_Enabled = not CONFIG.AutoBuild_Enabled
    BuildToggle.Text = "Auto Build: " .. (CONFIG.AutoBuild_Enabled and "ON" or "OFF")
    BuildToggle.BackgroundColor3 = CONFIG.AutoBuild_Enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(200, 50, 50)
end)

-- Auto Collect
CollectorToggle.MouseButton1Click:Connect(function()
    if not KeySys.KeyValid then
        KeyStatus.Text = "Статус: Требуется активация ключа!"
        KeyStatus.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        return
    end
    
    CONFIG.AutoCollect_Enabled = not CONFIG.AutoCollect_Enabled
    CollectorToggle.Text = "Auto Collect: " .. (CONFIG.AutoCollect_Enabled and "ON" or "OFF")
    CollectorToggle.BackgroundColor3 = CONFIG.AutoCollect_Enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(200, 50, 50)
end)

-- Качество построек
for i, btn in ipairs(QualityButtons) do
    btn.MouseButton1Click:Connect(function()
        if not KeySys.KeyValid then
            KeyStatus.Text = "Статус: Требуется активация ключа!"
            KeyStatus.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            return
        end
        
        CONFIG.BuildQuality = Qualities[i]
        for j, qbtn in ipairs(QualityButtons) do
            qbtn.BackgroundColor3 = (j == i) and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
        end
    end)
end

-- Закрытие GUI
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ============================================
-- АВТОМАТИЧЕСКАЯ ПРОВЕРКА КЛЮЧА
-- ============================================
spawn(function()
    while wait(300) do -- Проверка каждые 5 минут
        if KeySys.KeyValid then
            if KeySys.KeyExpiry and KeySys.KeyExpiry < os.time() then
                KeySys.KeyValid = false
                KeyStatus.Text = "Статус: Срок ключа истек!"
                KeyStatus.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                ActivateButton.Text = "Активировать"
                ActivateButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
                
                -- Отключение функций
                CONFIG.AutoFarm_Enabled = false
                CONFIG.AutoBuild_Enabled = false
                CONFIG.AutoCollect_Enabled = false
                FarmToggle.Text = "Auto Farm: OFF"
                FarmToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                BuildToggle.Text = "Auto Build: OFF"
                BuildToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                CollectorToggle.Text = "Auto Collect: OFF"
                CollectorToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            end
        end
    end
end)

-- ============================================
-- LOOTLABS УВЕДОМЛЕНИЕ
-- ============================================
local LootLabsFrame = Instance.new("Frame")
LootLabsFrame.Size = UDim2.new(0, 200, 0, 25)
LootLabsFrame.Position = UDim2.new(1, -210, 0, 10)
LootLabsFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LootLabsFrame.BackgroundTransparency = 0.5
LootLabsFrame.BorderSizePixel = 0
LootLabsFrame.Parent = ScreenGui

local LootLabsLabel = Instance.new("TextLabel")
LootLabsLabel.Size = UDim2.new(1, 0, 1, 0)
LootLabsLabel.BackgroundTransparency = 1
LootLabsLabel.Text = "Protected by LootLabs"
LootLabsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
LootLabsLabel.TextSize = 12
LootLabsLabel.Font = Enum.Font.Gotham
LootLabsLabel.Parent = LootLabsFrame

print("BABFT Script with LootLabs + Supabase Key System loaded!")
print("HWID:", KeySystem:GetHWID())
