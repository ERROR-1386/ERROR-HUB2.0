-- =======================
-- Автоматическая система для Build a Boat For Treasure
-- =======================

local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")

-- =======================
-- Создаем мини-UI
-- =======================
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))

local frame = Instance.new("Frame", ScreenGui)
frame.Size = UDim2.new(0, 220, 0, 130)
frame.Position = UDim2.new(1, -230, 0, 10)
frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
frame.BorderSizePixel = 0
frame.ZIndex = 10

local btnToggle = Instance.new("TextButton", frame)
btnToggle.Size = UDim2.new(1, -10, 0, 30)
btnToggle.Position = UDim2.new(0, 5, 0, 5)
btnToggle.Text = "▶ Запустить"
btnToggle.BackgroundColor3 = Color3.new(0.2, 0.5, 0.2)
btnToggle.TextColor3 = Color3.new(1, 1, 1)

local goldText = Instance.new("TextLabel", frame)
goldText.Size = UDim2.new(1, -10, 0, 20)
goldText.Position = UDim2.new(0, 5, 0, 40)
goldText.Text = "Золото: 0"
goldText.BackgroundTransparency = 1
goldText.TextColor3 = Color3.new(1, 1, 0)
goldText.TextSize = 14

local timeText = Instance.new("TextLabel", frame)
timeText.Size = UDim2.new(1, -10, 0, 20)
timeText.Position = UDim2.new(0, 5, 0, 65)
timeText.Text = "Время: 0 мин"
timeText.BackgroundTransparency = 1
timeText.TextColor3 = Color3.new(1, 1, 1)
timeText.TextSize = 14

-- =======================
-- Переменные
-- =======================
local autoFarm = false
local goldCount = 0
local secondsElapsed = 0

-- =======================
-- Включение/выключение авто-фермы
-- =======================
btnToggle.MouseButton1Click:Connect(function()
    autoFarm = not autoFarm
    if autoFarm then
        btnToggle.Text = "⏸ Пауза"
    else
        btnToggle.Text = "▶ Запустить"
    end
end)

-- =======================
-- Таймер и сбор золота
-- =======================
spawn(function()
    while true do
        wait(1)
        if autoFarm then
            -- Автоматическая добыча
            -- Замените этот блок на ваш механизм поиска и клика по золоту
            for _, obj in pairs(workspace:GetChildren()) do
                if obj:IsA("Part") and (string.find(obj.Name, "Gold") or string.find(obj.Name, "Treasure") or string.find(obj.Name, "Collect")) then
                    -- Создает ClickDetector, если нет
                    local detector = obj:FindFirstChildOfClass("ClickDetector")
                    if not detector then
                        detector = Instance.new("ClickDetector", obj)
                    end
                    -- Имитируем клик
                    pcall(function()
                        detector:MouseClick()
                    end)
                    wait(0.2) -- задержка, чтобы не мешать другим
                end
            end
            -- Подсчет
            goldCount = goldCount + math.random(1, 3) -- симуляция, замените на вашу механику
            goldText.Text = "Золото: " .. goldCount
        end

        -- Обновление времени
        secondsElapsed = secondsElapsed + 1
        local minutes = math.floor(secondsElapsed / 60)
        timeText.Text = "Время: " .. minutes .. " мин"
    end
end)

-- =======================
-- Анти-афк система
-- =======================
spawn(function()
    while true do
        wait(1100) -- чуть менее 20 минут
        VirtualUser:CaptureController()
        VirtualUser:SetKeyDown(Enum.KeyCode.W)
        wait(0.1)
        VirtualUser:SetKeyUp(Enum.KeyCode.W)
    end
end)

-- =======================
-- Расширяемость
-- Здесь можно добавлять новые системы
-- =======================

local systems = {}

function systems:autoBuild()
    -- пример: автоматическое строительство
    -- вставляйте сюда свой код
end

function systems:anotherSystem()
    -- пример: другая система
end

-- Вызов системы (например, по условию или кнопке)
-- systems:autoBuild()

-- =======================
-- Конец скрипта
-- =======================
