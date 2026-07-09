local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- Защищенная зона для гарантированного вывода меню на экран
local coreGui = game:GetService("CoreGui")

-- Удаляем старую копию скрипта перед запуском новой, чтобы GUI не двоилось
if coreGui:FindFirstChild("TreeBuyerGui") then
    coreGui.TreeBuyerGui:Destroy()
end

-- Системное имя ёлки в магазине Build a Boat
local itemName = "Pine Tree"

-- Функция отправки запроса на покупку ёлки за 50 золота
local function buyChristmasTree()
    local success, err = pcall(function()
        -- Динамический поиск ивента магазина в файлах игры
        local shopEvent = replicatedStorage:FindFirstChild("ShopBuy") 
            or (replicatedStorage:FindFirstChild("RemoteEvents") and replicatedStorage.RemoteEvents:FindFirstChild("ShopBuy"))
            or (replicatedStorage:FindFirstChild("RemoteEvents") and replicatedStorage.RemoteEvents:FindFirstChild("BuyItem"))

        if not shopEvent then
            for _, obj in ipairs(replicatedStorage:GetDescendants()) do
                if obj:IsA("RemoteEvent") and (obj.Name == "ShopBuy" or obj.Name == "BuyItem") then
                    shopEvent = obj
                    break
                end
            end
        end

        -- Отправляем запрос на покупку одной штуки
        if shopEvent and shopEvent:IsA("RemoteEvent") then
            shopEvent:FireServer(itemName, 1)
            return true
        end
        return false
    end)
    return success
end

-- ================= ИНТЕРФЕЙС GUI =================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TreeBuyerGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = coreGui

-- Небольшое компактное окно
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 210, 0, 140)
mainFrame.Position = UDim2.new(0, 30, 0, 120)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(60, 60, 60)

-- Возможность перетаскивать меню зажатием мышки
local dragging, dragInput, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Заголовок меню
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 10)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🌲 МАГАЗИН ЁЛОК"
titleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 13
titleLabel.Parent = mainFrame

-- Главная кнопка "КУПИТЬ ЁЛКУ (50g)"
local buyBtn = Instance.new("TextButton")
buyBtn.Size = UDim2.new(1, -30, 0, 40)
buyBtn.Position = UDim2.new(0, 15, 0, 45)
buyBtn.BackgroundColor3 = Color3.fromRGB(34, 139, 34) -- Лесной зеленый цвет
buyBtn.Text = "🛒 КУПИТЬ ЁЛКУ (50g)"
buyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
buyBtn.Font = Enum.Font.GothamBold
buyBtn.TextSize = 12
buyBtn.Parent = mainFrame
Instance.new("UICorner", buyBtn).CornerRadius = UDim.new(0, 6)

-- Кнопка "Убрать GUI" (UNLOAD)
local destroyButton = Instance.new("TextButton")
destroyButton.Size = UDim2.new(1, -30, 0, 30)
destroyButton.Position = UDim2.new(0, 15, 1, -40)
destroyButton.BackgroundColor3 = Color3.fromRGB(130, 25, 25)
destroyButton.Text = "❌ УБРАТЬ GUI"
destroyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
destroyButton.Font = Enum.Font.GothamBold
destroyButton.TextSize = 11
destroyButton.Parent = mainFrame
Instance.new("UICorner", destroyButton).CornerRadius = UDim.new(0, 6)


-- ================= ЛОГИКА НАЖАТИЙ =================

buyBtn.MouseButton1Click:Connect(function()
    buyBtn.Active = false
    buyBtn.Text = "⏳ ПОКУПКА..."
    buyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    
    local success = buyChristmasTree()
    
    if success then
        buyBtn.Text = "🎉 ЁЛКА КУПЛЕНА!"
        buyBtn.BackgroundColor3 = Color3.fromRGB(75, 230, 75)
    else
        buyBtn.Text = "❌ ОШИБКА СЕРВЕРА"
        buyBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    end
    
    task.wait(1)
    buyBtn.Text = "🛒 КУПИТЬ ЁЛКУ (50g)"
    buyBtn.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
    buyBtn.Active = true
end)

destroyButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)
