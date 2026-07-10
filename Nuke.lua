local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Полная очистка старых версий интерфейса перед перезапуском
if PlayerGui:FindFirstChild("NukeMergeGui") then
    PlayerGui.NukeMergeGui:Destroy()
end

-- Создание корневого контейнера ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NukeMergeGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- ==================== КНОПКА ОТКРЫТИЯ/ЗАКРЫТИЯ МЕНЮ ====================
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 90, 0, 35)
ToggleButton.Position = UDim2.new(0.5, 170, 0.5, -130)
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 120, 20)
ToggleButton.Text = "ЗАКРЫТЬ" -- Изначально открыто
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 14
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Thickness = 2
ToggleStroke.Color = Color3.fromRGB(100, 255, 100)
ToggleStroke.Parent = ToggleButton

-- ==================== ГЛАВНОЕ ОКНО ИНТЕРФЕЙСА ====================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 260)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- Белый для корректного наложения градиента
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Фирменный зеленый градиент (Сверху вниз)
local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 60, 15)),   -- Темно-зеленый сверху
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 130, 30))   -- Ярко-зеленый снизу
})
MainGradient.Rotation = 90
MainGradient.Parent = MainFrame

-- Яркая неоновая рамка по краям
local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 3
MainStroke.Color = Color3.fromRGB(100, 255, 100)
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame

-- Заголовок меню
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "☢️ NUKE MERGE SYSTEM ☢️"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- Таблица состояний для автоматических функций (флаги)
local AutoSettings = {
    Merge = false,
    Upgrade = false,
    Nuke = false
}

-- ==================== ФУНКЦИЯ СОЗДАНИЯ КНОПОК УПРАВЛЕНИЯ ====================
local function createMenuButton(text, position, flagName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -40, 0, 42)
    btn.Position = position
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = text .. ": ВЫКЛ"
    btn.TextColor3 = Color3.fromRGB(255, 100, 100)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Parent = MainFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Thickness = 1.5
    btnStroke.Color = Color3.fromRGB(80, 80, 80)
    btnStroke.Parent = btn

    -- Логика переключения визуального стиля и флага
    btn.MouseButton1Click:Connect(function()
        AutoSettings[flagName] = not AutoSettings[flagName]
        if AutoSettings[flagName] then
            btn.Text = text .. ": ВКЛ"
            btn.TextColor3 = Color3.fromRGB(100, 255, 100)
            btn.BackgroundColor3 = Color3.fromRGB(20, 50, 20)
            btnStroke.Color = Color3.fromRGB(100, 255, 100)
        else
            btn.Text = text .. ": ВЫКЛ"
            btn.TextColor3 = Color3.fromRGB(255, 100, 100)
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            btnStroke.Color = Color3.fromRGB(80, 80, 80)
        end
    end)
    
    return btn
end

-- Создание трех функциональных кнопок с отступами
local MergeButton = createMenuButton("Авто Соединение Бомб", UDim2.new(0, 20, 0, 60), "Merge")
local UpgradeButton = createMenuButton("Авто Прокачка Бомб", UDim2.new(0, 20, 0, 120), "Upgrade")
local NukeButton = createMenuButton("Авто Нюке (Запуск)", UDim2.new(0, 20, 0, 180), "Nuke")

-- ==================== ЛОГИКА ИНТЕРФЕЙСА (ДВИЖЕНИЕ И УКРЫТИЕ) ====================

-- Переключатель видимости панели (Скрыть / Показать)
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    if MainFrame.Visible then
        ToggleButton.Text = "ЗАКРЫТЬ"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(150, 20, 20)
        ToggleStroke.Color = Color3.fromRGB(255, 100, 100)
    else
        ToggleButton.Text = "МЕНЮ"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 120, 20)
        ToggleStroke.Color = Color3.fromRGB(100, 255, 100)
    end
end)

-- Плавное и стабильное перетаскивание мышей или пальцем
local dragging, dragInput, dragStart, startPos

local function updatePosition(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    ToggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X + 330, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updatePosition(input)
    end
end)

-- ==================== ИЗОЛИРОВАННЫЕ ИСПОЛНИТЕЛЬНЫЕ ЦИКЛЫ ====================

-- 1. Цикл для функции "Авто Соединение"
task.spawn(function()
    while true do
        task.wait(0.5) -- Задержка проверки полсекунды
        if AutoSettings.Merge then
            local success, err = pcall(function()
                -- [Место для кода слияния]: Поиск бомб одинакового уровня на игровом поле
            end)
            if not success then warn("Ошибка авто-соединения: " .. tostring(err)) end
        end
    end
end)

-- 2. Цикл для функции "Авто Прокачка"
task.spawn(function()
    while true do
        task.wait(1) -- Задержка проверки 1 секунда
        if AutoSettings.Upgrade then
            local success, err = pcall(function()
                -- [Место для кода прокачки]: Запрос к серверу на покупку улучшений или апгрейд уровня дропперов
            end)
            if not success then warn("Ошибка авто-прокачки: " .. tostring(err)) end
        end
    end
end)

-- 3. Цикл для функции "Авто Нюке"
task.spawn(function()
    while true do
        task.wait(2) -- Задержка проверки 2 секунды
        if AutoSettings.Nuke then
            local success, err = pcall(function()
                -- [Место для кода запуска]: Автоматический сброс бомбы максимального уровня на цель
            end)
            if not success then warn("Ошибка авто-запуска: " .. tostring(err)) end
        end
    end
end)

print("[Nuke Merge UI]: Интерфейс успешно инициализирован и готов к интеграции с механикой симулятора.")
