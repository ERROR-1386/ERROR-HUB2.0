local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local workspace = game.Workspace

-- Создаем мини UI
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "AutoFarmGUI"

local frame = Instance.new("Frame", ScreenGui)
frame.Size = UDim2.new(0, 220, 0, 130)
frame.Position = UDim2.new(1, -230, 0, 10)
frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
frame.BorderSizePixel = 0
frame.ZIndex = 10
frame.Name = "MainFrame"

local btnToggle = Instance.new("TextButton", frame)
btnToggle.Size = UDim2.new(1, -10, 0, 30)
btnToggle.Position = UDim2.new(0, 5, 0, 5)
btnToggle.Text = "▶ Запустить"
btnToggle.BackgroundColor3 = Color3.new(0.2, 0.5, 0.2)
btnToggle.TextColor3 = Color3.new(1, 1, 1)

local goldLabel = Instance.new("TextLabel", frame)
goldLabel.Size = UDim2.new(1, -10, 0, 20)
goldLabel.Position = UDim2.new(0, 5, 0, 40)
goldLabel.Text = "Золото: 0"
goldLabel.BackgroundTransparency = 1
goldLabel.TextColor3 = Color3.new(1, 1, 0)
goldLabel.TextSize = 14

local timeLabel = Instance.new("TextLabel", frame)
timeLabel.Size = UDim2.new(1, -10, 0, 20)
timeLabel.Position = UDim2.new(0, 5, 0, 65)
timeLabel.Text = "Время: 0 мин"
timeLabel.BackgroundTransparency = 1
timeLabel.TextColor3 = Color3.new(1, 1, 1)
timeLabel.TextSize = 14

-- Для расширяемости
local systems = {}

-- Глобальные переменные
local autoFarm = false
local goldCount = 0
local seconds = 0

-- Функция для запуска/пауз авто-фермы
btnToggle.MouseButton1Click:Connect(function()
    autoFarm = not autoFarm
    if autoFarm then
        btnToggle.Text = "⏸ Пауза"
    else
        btnToggle.Text = "▶ Запустить"
    end
end)

-- Переключатель анти-афк (автомат механика в отдельном потоке)
spawn(function()
    while true do
        wait(1100) -- около 20 минут
        VirtualUser:CaptureController()
        VirtualUser:SetKeyDown(Enum.KeyCode.W)
        wait(0.1)
        VirtualUser:SetKeyUp(Enum.KeyCode.W)
    end
end)

-- Основной цикл: сбор золота + таймер
spawn(function()
    while true do
        wait(1)
        if autoFarm then
            -- Поиск и клик по частям "Gold", "Treasure" или "Collect"
            for _, obj in pairs(workspace:GetChildren()) do
                if obj:IsA("Part") and (string.find(obj.Name, "Gold") or string.find(obj.Name, "Treasure") or string.find(obj.Name, "Collect")) then
                    local detector = obj:FindFirstChildOfClass("ClickDetector")
                    if not detector then
                        detector = Instance.new("ClickDetector", obj)
                    end
                    -- Притворяемся, что кликнули
                    pcall(function()
                        detector:MouseClick()
                    end)
                    wait(0.2)
                end
            end
            -- Обновляем счетчик
            local gained = math.random(1, 3) -- замените на вашу механику
            goldCount = goldCount + gained
            goldLabel.Text = "Золото: " .. goldCount
        end
        -- Таймер
        seconds = seconds + 1
        local mins = math.floor(seconds / 60)
        timeLabel.Text = "Время: " .. mins .. " мин"
    end
end)

-- Расширения для добавления других систем
function systems:autoBuild()
    -- Тут добавляйте код авто строительства
end

function systems:example()
    -- любое расширение
end

-- В будущем можете вызывать компании систем
-- systems:autoBuild()
