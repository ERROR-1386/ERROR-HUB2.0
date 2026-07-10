local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Удаление старой панели, если она была запущена ранее
if PlayerGui:FindFirstChild("ChatMenuGui") then
    PlayerGui.ChatMenuGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ChatMenuGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- ==================== КНОПКА МЕНЮ (ОТКРЫТЬ/ЗАКРЫТЬ) ====================
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 60, 0, 35)
ToggleButton.Position = UDim2.new(0.5, 185, 0.5, -125) -- Позиция чуть правее главного окна
ToggleButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0) -- Изначально открыто, кнопка красная "ЗАКРЫТЬ"
ToggleButton.Text = "ЗАКРЫТЬ"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 13
ToggleButton.Parent = ScreenGui
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 8)

-- Неоновая обводка для кнопки МЕНЮ
local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Thickness = 2
ToggleStroke.Color = Color3.fromRGB(255, 0, 0)
ToggleStroke.Parent = ToggleButton

-- ==================== ГЛАВНОЕ ОКНО ИНТЕРФЕЙСА ====================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 250)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Active = true
MainFrame.Parent = ScreenGui

-- Скругление углов главного меню
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Зеленый градиент по краю меню (UIStroke)
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
Title.Text = "Chat Control Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- ПЕРЕМЕННЫЕ НАСТРОЕК ФУНКЦИЙ
local readChatActive = false
local spammerActive = false
local spamMessage = "Привет от скрипта!"
local spamDelay = 3 -- Базовая задержка в секундах

-- ==================== КНОПКИ ФУНКЦИЙ ВНУТРИ ОКНА ====================
-- Левая колонка: Чтение чата
local ReadButton = Instance.new("TextButton")
ReadButton.Size = UDim2.new(0, 140, 0, 35)
ReadButton.Position = UDim2.new(0, 20, 0, 60)
ReadButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ReadButton.Text = "Чтение чата: ВЫКЛ"
ReadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ReadButton.Font = Enum.Font.SourceSans
ReadButton.TextSize = 14
ReadButton.Parent = MainFrame
Instance.new("UICorner", ReadButton).CornerRadius = UDim.new(0, 6)

-- Правая колонка: Включение спамера
local SpamButton = Instance.new("TextButton")
SpamButton.Size = UDim2.new(0, 140, 0, 35)
SpamButton.Position = UDim2.new(0, 190, 0, 60)
SpamButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpamButton.Text = "Спамер: ВЫКЛ"
SpamButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpamButton.Font = Enum.Font.SourceSans
SpamButton.TextSize = 14
SpamButton.Parent = MainFrame
Instance.new("UICorner", SpamButton).CornerRadius = UDim.new(0, 6)

-- По центру: Текстовое поле ввода фраз для спама
local SpamTextInput = Instance.new("TextBox")
SpamTextInput.Size = UDim2.new(0, 310, 0, 35)
SpamTextInput.Position = UDim2.new(0, 20, 0, 115)
SpamTextInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SpamTextInput.Text = "Введите текст для спама..."
SpamTextInput.TextColor3 = Color3.fromRGB(200, 200, 200)
SpamTextInput.Font = Enum.Font.SourceSans
SpamTextInput.TextSize = 14
SpamTextInput.Parent = MainFrame
Instance.new("UICorner", SpamTextInput).CornerRadius = UDim.new(0, 6)

-- Текст-инструкция в самом низу меню
local Credits = Instance.new("TextLabel")
Credits.Size = UDim2.new(1, 0, 0, 50)
Credits.Position = UDim2.new(0, 0, 1, -50)
Credits.BackgroundTransparency = 1
Credits.Text = "Зажмите мышку/палец на меню для перемещения\nНажмите Enter в поле ввода, чтобы сохранить текст"
Credits.TextColor3 = Color3.fromRGB(150, 150, 150)
Credits.TextSize = 12
Credits.Font = Enum.Font.SourceSansItalic
Credits.Parent = MainFrame

-- ==================== СИСТЕМА СВОРАЧИВАНИЯ (ОТКРЫТЬ/ЗАКРЫТЬ) ====================
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    if MainFrame.Visible then
        ToggleButton.Text = "ЗАКРЫТЬ"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        ToggleButton.UIStroke.Color = Color3.fromRGB(255, 0, 0)
    else
        ToggleButton.Text = "МЕНЮ"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        ToggleButton.UIStroke.Color = Color3.fromRGB(0, 255, 0)
    end
end)

-- ==================== ПЛАВНОЕ ПЕРЕТАСКИВАНИЕ ДЛЯ СЕНСОРА И ПК ====================
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    -- Кнопка "МЕНЮ" аккуратно следует справа от основного окна при его движении
    ToggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X + 360, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
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
        update(input)
    end
end)

-- ==================== ЛОГИКА АНТИ-ЧИТ ОБХОДА И ФУНКЦИЙ ====================

-- Продвинутая функция отправки сообщений (Защита от фильтров и блокировок)
local function SendChatMessage(messageText)
    -- АНТИ-ЧИТ ОБХОД ДУБЛИКАТОВ: Генерируем цепочку невидимых Unicode-символов (Zero-Width Space)
    -- Для анти-чита сообщения становятся уникальными, а люди в чате видят обычный текст
    local invisibleBypass = ""
    for i = 1, math.random(3, 8) do
        invisibleBypass = invisibleBypass .. utf8.char(0x200B)
    end
    
    -- Рандомизация пробелов на конце строки для дополнительной маскировки
    if math.random(1, 2) == 1 then
        messageText = messageText .. " "
    end
    
    local finalMessage = messageText .. invisibleBypass

    -- Запуск отправки через современную систему TextChatService
    local textChannel = TextChatService:FindFirstChild("TextChannels") and TextChatService.TextChannels:FindFirstChild("RBXGeneral")
    if textChannel then
        textChannel:SendAsync(finalMessage)
    else
        -- Запасной алгоритм отправки для старых игровых режимов (Legacy Chat)
        local chatChannel = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
        if chatChannel and chatChannel:FindFirstChild("SayMessageRequest") then
            chatChannel.SayMessageRequest:FireServer(finalMessage, "All")
        end
    end
end

-- Включение / Выключение чтения чата
ReadButton.MouseButton1Click:Connect(function()
    readChatActive = not readChatActive
    if readChatActive then
        ReadButton.Text = "Чтение чата: ВКЛ"
        ReadButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        ReadButton.Text = "Чтение чата: ВЫКЛ"
        ReadButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
end)

-- Перехват чужих сообщений и вывод их в консоль разработчика
TextChatService.MessageReceived:Connect(function(textChatMessage)
    if readChatActive and textChatMessage.TextSource then
        local senderUserId = textChatMessage.TextSource.UserId
        local senderPlayer = Players:GetPlayerByUserId(senderUserId)
        if senderPlayer then
            -- Сообщения выводятся в лог (/console в чате на мобильном или F9 на ПК)
            print("[ЧАТ ЧИТА] " .. senderPlayer.Name .. ": " .. textChatMessage.Text)
        end
    end
end)

-- Включение / Выключение спамера с динамическими задержками
SpamButton.MouseButton1Click:Connect(function()
    spammerActive = not spammerActive
    if spammerActive then
        SpamButton.Text = "Спамер: ВКЛ"
        SpamButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        
        task.spawn(function()
            while spammerActive do
                SendChatMessage(spamMessage)
                
                -- АНТИ-ЧИТ ОБХОД ПО ТАЙМИНГУ:
                -- Разрушаем циклическую отправку. Каждый раз пауза между сообщениями генерируется случайно.
                -- Для серверных проверок это симулирует печать текста человеком.
                local humanDelay = spamDelay + (math.random(-6, 12) / 10)
                if humanDelay < 1.6 then 
                    humanDelay = 1.6 
                end -- Безопасный порог против кика за флуд
                
                task.wait(humanDelay)
            end
        end)
    else
        SpamButton.Text = "Спамер: ВЫКЛ"
        SpamButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
end)

-- Сохранение напечатанного в TextBox текста
SpamTextInput.FocusLost:Connect(function(enterPressed)
    if enterPressed and SpamTextInput.Text ~= "" then
        spamMessage = SpamTextInput.Text
    end
end)
