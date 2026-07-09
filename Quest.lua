local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local replicatedStorage = game:GetService("ReplicatedStorage")

-- Расширенный список реальных сундуков и временных блоков
local itemsList = {
    {name = "🧱 Блок Lego (Plastic)", code = "Plastic Block", color = Color3.fromRGB(230, 50, 50)},
    {name = "🎂 Блок-Торт (Cake)", code = "Cake", color = Color3.fromRGB(240, 130, 180)},
    {name = "🍭 Блок-Леденец (Candy)", code = "Candy Cane", color = Color3.fromRGB(210, 70, 70)},
    {name = "🎄 Новогодний Сундук", code = "Christmas Chest", color = Color3.fromRGB(35, 130, 70)},
    {name = "🎃 Хэллоуин Сундук", code = "Halloween Chest", color = Color3.fromRGB(210, 105, 30)},
    {name = "💜 Эпический Сундук", code = "Epic Chest", color = Color3.fromRGB(130, 50, 180)},
    {name = "💛 Легендарный Сундук", code = "Legendary Chest", color = Color3.fromRGB(200, 160, 40)}
}

local currentItemIndex = 1
local purchaseCount = 1 

-- Функция отправки запроса на покупку выбранного предмета
local function buySelectedProduct()
    local selectedItem = itemsList[currentItemIndex]
    local success, err = pcall(function()
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

        if shopEvent and shopEvent:IsA("RemoteEvent") then
            for i = 1, purchaseCount do
                shopEvent:FireServer(selectedItem.code, 1)
                task.wait(0.05) -- Минимальная задержка от флуда
            end
            return true
        end
        return false
    end)
    return success
end

-- ================= ИНТЕРФЕЙС GUI =================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ExtendedShopBuyerGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 230, 0, 230)
mainFrame.Position = UDim2.new(0, 20, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(60, 60, 60)

-- Перетаскивание меню мышкой (Draggable)
local UserInputService = game:GetService("UserInputService")
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
titleLabel.Text = "🛒 РАСШИРЕННЫЙ МАГАЗИН"
titleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 13
titleLabel.Parent = mainFrame

-- Кнопка переключения ТОВАРА
local selectItemBtn = Instance.new("TextButton")
selectItemBtn.Size = UDim2.new(1, -30, 0, 35)
selectItemBtn.Position = UDim2.new(0, 15, 0, 45)
selectItemBtn.BackgroundColor3 = itemsList[currentItemIndex].color
selectItemBtn.Text = "Выбрано: " .. itemsList[currentItemIndex].name
selectItemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
selectItemBtn.Font = Enum.Font.GothamBold
selectItemBtn.TextSize = 12
selectItemBtn.Parent = mainFrame
Instance.new("UICorner", selectItemBtn).CornerRadius = UDim.new(0, 6)

-- Блок выбора количества (Минус)
local minusBtn = Instance.new("TextButton")
minusBtn.Size = UDim2.new(0, 35, 0, 35)
minusBtn.Position = UDim2.new(0, 15, 0, 90)
minusBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
minusBtn.Text = "-"
minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minusBtn.Font = Enum.Font.GothamBold
minusBtn.TextSize = 16
minusBtn.Parent = mainFrame
Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(0, 6)

-- Отображение текущего количества
local countLabel = Instance.new("TextLabel")
countLabel.Size = UDim2.new(1, -120, 0, 35)
countLabel.Position = UDim2.new(0, 55, 0, 90)
countLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
countLabel.Text = tostring(purchaseCount) .. " шт."
countLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
countLabel.Font = Enum.Font.GothamBold
countLabel.TextSize = 14
countLabel.Parent = mainFrame
Instance.new("UICorner", countLabel).CornerRadius = UDim.new(0, 6)
local countStroke = Instance.new("UIStroke", countLabel)
countStroke.Color = Color3.fromRGB(70, 70, 70)

-- Блок выбора количества (Плюс)
local plusBtn = Instance.new("TextButton")
plusBtn.Size = UDim2.new(0, 35, 0, 35)
plusBtn.Position = UDim2.new(1, -50, 0, 90)
plusBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
plusBtn.Text = "+"
plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
plusBtn.Font = Enum.Font.GothamBold
plusBtn.TextSize = 16
plusBtn.Parent = mainFrame
Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(0, 6)

-- Главная кнопка "КУПИТЬ"
local buyBtn = Instance.new("TextButton")
buyBtn.Size = UDim2.new(1, -30, 0, 40)
buyBtn.Position = UDim2.new(0, 15, 0, 135)
buyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
buyBtn.Text = "✅ ПОДТВЕРДИТЬ ПОКУПКУ"
buyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
buyBtn.Font = Enum.Font.GothamBold
buyBtn.TextSize = 12
buyBtn.Parent = mainFrame
Instance.new("UICorner", buyBtn).CornerRadius = UDim.new(0, 6)

-- Кнопка полного закрытия скрипта (UNLOAD)
local destroyButton = Instance.new("TextButton")
destroyButton.Size = UDim2.new(1, -30, 0, 30)
destroyButton.Position = UDim2.new(0, 15, 1, -40)
destroyButton.BackgroundColor3 = Color3.fromRGB(130, 25, 25)
destroyButton.Text = "❌ UNLOAD SCRIPT"
destroyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
destroyButton.Font = Enum.Font.GothamBold
destroyButton.TextSize = 11
destroyButton.Parent = mainFrame
Instance.new("UICorner", destroyButton).CornerRadius = UDim.new(0, 6)


-- ================= ЛОГИКА ИНТЕРФЕЙСА =================

-- Переключение товаров
selectItemBtn.MouseButton1Click:Connect(function()
    currentItemIndex = currentItemIndex + 1
    if currentItemIndex > #itemsList then currentItemIndex = 1 end
    
    local item = itemsList[currentItemIndex]
    selectItemBtn.Text = "Выбрано: " .. item.name
    selectItemBtn.BackgroundColor3 = item.color
end)

-- Изменение количества
minusBtn.MouseButton1Click:Connect(function()
    if purchaseCount > 1 then
        purchaseCount = purchaseCount - 1
        countLabel.Text = tostring(purchaseCount) .. " шт."
    end
end)

plusBtn.MouseButton1Click:Connect(function()
    if purchaseCount < 100 then
        purchaseCount = purchaseCount + 1
        countLabel.Text = tostring(purchaseCount) .. " шт."
    end
end)

-- Логика покупки
buyBtn.MouseButton1Click:Connect(function()
    buyBtn.Active = false
    buyBtn.Text = "⏳ ОТПРАВКА ЗАПРОСОВ..."
    buyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    
    local success = buySelectedProduct()
    
    if success then
        buyBtn.Text = "🎉 КУПЛЕНО УСПЕШНО!"
        buyBtn.BackgroundColor3 = Color3.fromRGB(75, 230, 75)
    else
        buyBtn.Text = "❌ ОШИБКА МАГАЗИНА"
        buyBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    end
    
    task.wait(2)
    buyBtn.Text = "✅ ПОДТВЕРДИТЬ ПОКУПКУ"
    buyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    buyBtn.Active = true
end)

-- Кнопка закрытия
destroyButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)
