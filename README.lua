-- Полный готовый скрипт с функциями и GUI

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Humanoid = nil

-- Основное выполнение после появления персонажа
player.CharacterAdded:Connect(function(char)
    Humanoid = char:WaitForChild("Humanoid")
end)

if not Humanoid then
    Humanoid = player.Character:WaitForChild("Humanoid")
end

local RunService = game:GetService("RunService")

-- Вспомогательная функция для проверки, готов ли Humanoid
local function getHumanoid()
    local character = player.Character or player.CharacterAdded:Wait()
    return character:WaitForChild("Humanoid")
end

Humanoid = getHumanoid()

-- === Создаем GUI с анимациями ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MyGameTools"
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Основное окно
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 250)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Иконка настроек (иконка шестерёнки)
local SettingsButton = Instance.new("TextButton")
SettingsButton.Size = UDim2.new(0, 50, 0, 50)
SettingsButton.Position = UDim2.new(1, -55, 0, 5)
SettingsButton.BackgroundColor3 = Color3.new(0.8, 0.8, 0.8)
SettingsButton.Text = "⚙️"
SettingsButton.Font = Enum.Font.SourceSansBold
SettingsButton.TextSize = 24
SettingsButton.Parent = MainFrame

-- Панель настроек (скрыта по умолчанию)
local SettingsFrame = Instance.new("Frame")
 SettingsFrame.Size = UDim2.new(0, 250, 0, 150)
SettingsFrame.Position = UDim2.new(1, 5, 0, 55)
SettingsFrame.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
SettingsFrame.Visible = false
SettingsFrame.BorderSizePixel = 0
SettingsFrame.Parent = MainFrame

-- Кнопка смены цвета фона
local ColorButton = Instance.new("TextButton")
ColorButton.Size = UDim2.new(1, -10, 0, 30)
ColorButton.Position = UDim2.new(0, 5, 0, 5)
ColorButton.Text = "Поменять цвет фона"
ColorButton.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
ColorButton.TextColor3 = Color3.new(1, 1, 1)
ColorButton.Font = Enum.Font.SourceSans
ColorButton.TextSize = 14
ColorButton.Parent = SettingsFrame

-- Метка для ввода скорости
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, -10, 0, 20)
SpeedLabel.Position = UDim2.new(0, 5, 0, 45)
SpeedLabel.Text = "Введите скорость:"
SpeedLabel.TextColor3 = Color3.new(1, 1, 1)
SpeedLabel.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
SpeedLabel.Font = Enum.Font.SourceSans
SpeedLabel.TextSize = 14
SpeedLabel.Parent = SettingsFrame

-- Поле для ввода скорости
local SpeedBox = Instance.new("TextBox")
SpeedBox.Size = UDim2.new(0, 100, 0, 20)
SpeedBox.Position = UDim2.new(0, 5, 0, 70)
SpeedBox.Text = "16"
SpeedBox.BackgroundColor3 = Color3.new(1, 1, 1)
SpeedBox.TextColor3 = Color3.new(0, 0, 0)
SpeedBox.Font = Enum.Font.SourceSans
SpeedBox.TextSize = 14
SpeedBox.ClearTextOnFocus = false
SpeedBox.Parent = SettingsFrame

-- Чекбокс для авто-фарм
local AutoFarmCheckbox = Instance.new("TextButton")
AutoFarmCheckbox.Size = UDim2.new(0, 20, 0, 20)
AutoFarmCheckbox.Position = UDim2.new(0, 5, 0, 100)
AutoFarmCheckbox.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
AutoFarmCheckbox.Text = ""
AutoFarmCheckbox.BorderSizePixel = 1
AutoFarmCheckbox.Parent = SettingsFrame

local AutoFarmLabel = Instance.new("TextLabel")
AutoFarmLabel.Size = UDim2.new(1, -30, 0, 20)
AutoFarmLabel.Position = UDim2.new(0, 30, 0, 100)
AutoFarmLabel.Text = "Авто-фарм"
AutoFarmLabel.TextColor3 = Color3.new(1, 1, 1)
AutoFarmLabel.BackgroundTransparency = 1
AutoFarmLabel.Font = Enum.Font.SourceSans
AutoFarmLabel.TextSize = 14
AutoFarmLabel.Parent = SettingsFrame

-- === Анимация открытия/закрытия настроек ===

local function animateFrameOpen(frame)
    frame.Visible = true
    frame.Position = UDim2.new(1, 5, 0, 55)
    for i = 0, 1, 0.1 do
        frame.Position = UDim2.new(1 - i, 5 * (1 - i), 0, 55)
        wait(0.02)
    end
    frame.Position = UDim2.new(1, 5, 0, 55)
end

local function animateFrameClose(frame)
    for i = 0, 1, 0.1 do
        frame.Position = UDim2.new(i, 5 * i, 0, 55)
        wait(0.02)
    end
    frame.Visible = false
end

-- Обработка кнопки настроек
SettingsButton.MouseButton1Click:Connect(function()
    if SettingsFrame.Visible then
        animateFrameClose(SettingsFrame)
    else
        animateFrameOpen(SettingsFrame)
    end
end)

-- === Анимация смены цвета ===
local function changeColor(target)
    local startColor = MainFrame.BackgroundColor3
    local endColor = Color3.new(math.random(), math.random(), math.random())
    for i = 0, 1, 0.1 do
        MainFrame.BackgroundColor3 = startColor:Lerp(endColor, i)
        wait(0.05)
    end
    MainFrame.BackgroundColor3 = endColor
end

ColorButton.MouseButton1Click:Connect(changeColor)

-- === Обработка изменения скорости с плавной анимацией ===
local function setSpeed(targetSpeed)
    -- Плавное изменение скорости
    local currentSpeed = Humanoid.WalkSpeed
    local steps = 10
    local delta = (targetSpeed - currentSpeed) / steps
    for i = 1, steps do
        Humanoid.WalkSpeed = Humanoid.WalkSpeed + delta
        wait(0.02)
    end
    Humanoid.WalkSpeed = targetSpeed
end

SpeedBox.FocusLost:Connect(function()
    local newSpeed = tonumber(SpeedBox.Text)
    if newSpeed then
        setSpeed(newSpeed)
    end
end)

-- === Обработка авто-фермы ===
local autoFarmActive = false
AutoFarmCheckbox.MouseButton1Click:Connect(function()
    autoFarmActive = not autoFarmActive
    if autoFarmActive then
        AutoFarmCheckbox.BackgroundColor3 = Color3.new(0, 1, 0)
        print("Авто-фарм включён")
    else
        AutoFarmCheckbox.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
        print("Авто-фарм выключен")
    end
end)

-- Основной цикл авто-фермы
spawn(function()
    while true do
        wait(1)
        if autoFarmActive then
            -- Тут добавьте вашу логику авто-ферма
            -- Например, поиск врагов и атака
        end
    end
end)

-- Бессмертие
local function activateGodMode()
    if Humanoid then
        Humanoid.MaxHealth = math.huge
        Humanoid.Health = math.huge
        print("Бессмертие активировано")
    end
end

-- Инициализация
if Humanoid then
    activateGodMode()
    -- Установка начальной скорости
    local startSpeed = tonumber(SpeedBox.Text) or 16
    setSpeed(startSpeed)
end
