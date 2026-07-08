local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- =========================
-- --- Основной функционал ---
-- =========================

local humanoid = nil
player.CharacterAdded:Connect(function(char)
    humanoid = char:WaitForChild("Humanoid")
end)
if not humanoid then
    humanoid = player.Character:WaitForChild("Humanoid")
end

local autoFarmActive = false
local antiAFKActive = false
local godMode = false
local currentSpeed = 16 -- по умолчанию

-- Тригеры функций
local function toggleAutoFarm()
    autoFarmActive = not autoFarmActive
    print("Авто-фарм: " .. (autoFarmActive and "включен" or "выключен"))
end

local function startAntiAFK()
    spawn(function()
        local VirtualUser = game:GetService("VirtualUser")
        while antiAFKActive do
            wait(300)
            VirtualUser:CaptureController()
            VirtualUser:SetKeyDown(Enum.KeyCode.W)
            wait(0.1)
            VirtualUser:SetKeyUp(Enum.KeyCode.W)
        end
    end)
end

local function toggleAntiAFK()
    antiAFKActive = not antiAFKActive
    if antiAFKActive then
        startAntiAFK()
        print("Anti-AFK активен")
    else
        print("Anti-AFK отключен")
    end
end

local function setSpeed(newSpeed)
    if humanoid then
        -- плавное изменение
        local startSpeed = humanoid.WalkSpeed
        local steps = 10
        local delta = (newSpeed - startSpeed) / steps
        for i=1,steps do
            humanoid.WalkSpeed = humanoid.WalkSpeed + delta
            wait(0.02)
        end
        humanoid.WalkSpeed = newSpeed
        currentSpeed = newSpeed
    end
end

local function megaJump()
    if humanoid then
        humanoid.JumpPower = 150
        humanoid.Jump = true
        wait(0.2)
        humanoid.JumpPower = 50
    end
end

local function toggleGodMode()
    if humanoid then
        if not godMode then
            humanoid.MaxHealth = math.huge
            humanoid.Health = math.huge
            godMode = true
            print("Бессмертие включено")
        else
            humanoid.MaxHealth = 100
            humanoid.Health = 100
            godMode = false
            print("Бессмертие отключено")
        end
    end
end

-- Основной цикл авто-ферма/бессмертия
spawn(function()
    while true do
        wait(1)
        if autoFarmActive then
            -- тут добавить логику авто-атаки, если нужно
            -- пример
            -- print("Авто-ферминг...")
        end
        if humanoid and godMode then
            humanoid.Health = humanoid.MaxHealth
        end
    end
end)

-- ============================
-- --- Создаем GUI ---
-- ============================

local function createButton(parent, text, size, position, bgColor)
    local btn = Instance.new("TextButton", parent)
    btn.Size = size
    btn.Position = position
    btn.Text = text
    btn.BackgroundColor3 = bgColor
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 14
    return btn
end

local ScreenGui = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))

-- Главное меню
local mainFrame = Instance.new("Frame", ScreenGui)
mainFrame.Size = UDim2.new(0, 400, 0, 350)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.new(0.1,0.1,0.1)
mainFrame.BorderSizePixel = 0

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1,0,0,30)
title.Text = "Функции"
title.BackgroundColor3 = Color3.new(0.2,0.2,0.2)
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16

local btnAutoFarm = createButton(mainFrame, "Авто-фарм", UDim2.new(1,-20,0,30), UDim2.new(0,10,0,40), Color3.new(0.3,0.3,0.3))
local btnAntiAFK = createButton(mainFrame, "Анти-Афк", UDim2.new(1,-20,0,30), UDim2.new(0,10,0,80), Color3.new(0.3,0.3,0.3))
local btnSpeed = createButton(mainFrame, "Изменить скорость", UDim2.new(1,-20,0,30), UDim2.new(0,10,0,120), Color3.new(0.3,0.3,0.3))
local btnMegaJump = createButton(mainFrame, "Мега прыжок", UDim2.new(1,-20,0,30), UDim2.new(0,10,0,160), Color3.new(0.3,0.3,0.3))
local btnGodMode = createButton(mainFrame, "Бессмертие", UDim2.new(1,-20,0,30), UDim2.new(0,10,0,200), Color3.new(0.3,0.3,0.3))

-- Иконка шестерёнки для настроек
local settingsFrame = Instance.new("Frame", ScreenGui)
settingsFrame.Size = UDim2.new(0, 300, 0, 150)
settingsFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
settingsFrame.BackgroundColor3 = Color3.new(0.2,0.2,0.2)
settingsFrame.BorderSizePixel = 0
settingsFrame.Visible = false

local changeColorBtn = createButton(settingsFrame, "Изменить цвет", UDim2.new(1,-20,0,40), UDim2.new(0,10,0,10), Color3.new(0.5,0.5,0.5))
local closeBtn = createButton(settingsFrame, "Закрыть", UDim2.new(1,-20,0,40), UDim2.new(0,10,0,60), Color3.new(0.7,0.2,0.2))

-- Шаги для эффекта
local function toggleSettings()
    if settingsFrame.Visible then
        -- закрываем
        for i=0,1,0.2 do
            settingsFrame.Position = UDim2.new(0.5, 0):Lerp(UDim2.new(0.5, -150, 0.5, -75), i)
            wait(0.02)
        end
        settingsFrame.Visible = false
    else
        -- открываем
        settingsFrame.Visible = true
        settingsFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
        for i=0,1,0.2 do
            settingsFrame.Position = UDim2.new(0.5, -150, 0.5, -75):Lerp(UDim2.new(0.5, -150, 0.5, -75), i)
            wait(0.02)
        end
    end
end

local gearButton = Instance.new("TextButton", mainFrame)
gearButton.Size = UDim2.new(0,50,0,50)
gearButton.Position = UDim2.new(1, -55, 0, 5)
gearButton.Text = "⚙️"
gearButton.Font = Enum.Font.SourceSansBold
gearButton.TextSize = 24
gearButton.BackgroundColor3 = Color3.new(0.8,0.8,0.8)
gearButton.MouseButton1Click:Connect(toggleSettings)

-- ============================
-- События on кнопки
-- ============================

btnAutoFarm.MouseButton1Click:Connect(function()
    autoFarmActive = not autoFarmActive
    print("Авто-ферминг: "..(autoFarmActive and "включен" or "выключен"))
end)

btnAntiAFK.MouseButton1Click:Connect(function()
    antiAFKActive = not antiAFKActive
    if antiAFKActive then
        spawn(function()
            local VirtualUser = game:GetService("VirtualUser")
            while antiAFKActive do
                wait(300)
                VirtualUser:CaptureController()
                VirtualUser:SetKeyDown(Enum.KeyCode.W)
                wait(0.1)
                VirtualUser:SetKeyUp(Enum.KeyCode.W)
            end
        end)
        print("Anti-AFK активен")
    else
        print("Anti-AFK отключен")
    end
end)

btnSpeed.MouseButton1Click:Connect(function()
    local newSpeed = tonumber(prompt("Введите скорость", tostring(humanoid.WalkSpeed)))
    if newSpeed then
        setSpeed(newSpeed)
    end
end)

btnMegaJump.MouseButton1Click:Connect(function()
    megaJump()
end)

btnGodMode.MouseButton1Click:Connect(function()
    toggleGodMode()
end)

-- При нажатии "Закрыть" вызывается окно подтверждения
local function createConfirmationWindow()
    local confirmFrame = Instance.new("Frame", ScreenGui)
    confirmFrame.Size = UDim2.new(0, 350, 0, 150)
    confirmFrame.Position = UDim2.new(0.5, -175, 0.5, -75)
    confirmFrame.BackgroundColor3 = Color3.new(0.2,0.2,0.2)
    confirmFrame.BorderSizePixel = 0

    local confirmText = Instance.new("TextLabel", confirmFrame)
    confirmText.Size = UDim2.new(1,0,0,50)
    confirmText.Position = UDim2.new(0,0,0,0)
    confirmText.Text = "Вы действительно хотите закрыть скрипт?"
    confirmText.Font = Enum.Font.SourceSansBold
    confirmText.TextSize = 14
    confirmText.TextColor3 = Color3.new(1,1,1)

    local btnYes = createButton(confirmFrame, "ДА", UDim2.new(0,100,0,40), UDim2.new(0,50,1,-50), Color3.new(0.7,0.2,0.2))
    local btnNo = createButton(confirmFrame, "НЕТ", UDim2.new(0,100,0,40), UDim2.new(0,200,1,-50), Color3.new(0.2,0.7,0.2))

    btnYes.MouseButton1Click:Connect(function()
        -- Закрываем все GUI и останавливаем скрипт
        confirmFrame:Destroy()
        mainFrame:Destroy()
        settingsFrame:Destroy()
        -- здесь можно дополнительно отключать все функции или делать выход
        -- например, ставим флаг или останавливаем цикл
    end)

    btnNo.MouseButton1Click:Connect(function()
        -- просто закрываем окно подтверждения
        confirmFrame:Destroy()
    end)

    return confirmFrame
end

-- Обработка "Закрыть"
mainFrame:FindFirstChild("Закрыть").MouseButton1Click:Connect(function()
    createConfirmationWindow()
end)
