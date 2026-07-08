local player = game.Players.LocalPlayer
local humanoid
local runService = game:GetService("RunService")

local function getHumanoid()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("Humanoid")
end

local function getHumanoidSafe()
    if not humanoid or not humanoid.Parent then
        humanoid = getHumanoid()
    end
    return humanoid
end

-- Изначально получаем гуманоид
humanoid = getHumanoid()

-- Флаги функций
local autoFarm = false
local antiAFK = false
local speedActive = false
local megaJumpActive = false
local godModeActive = false

-- Основные функции
local function toggleAutoFarm()
    autoFarm = not autoFarm
    print("Auto Farm: " .. (autoFarm and "ON" or "OFF"))
end

local function toggleAntiAFK()
    antiAFK = not antiAFK
    if antiAFK then
        spawn(function()
            local VirtualUser = game:GetService("VirtualUser")
            while antiAFK do
                wait(300)
                VirtualUser:CaptureController()
                VirtualUser:SetKeyDown(Enum.KeyCode.W)
                wait(0.1)
                VirtualUser:SetKeyUp(Enum.KeyCode.W)
            end
        end)
    end
    print("Anti AFK: " .. (antiAFK and "ON" or "OFF"))
end

local function setWalkSpeed(newSpeed)
    local hum = getHumanoid()
    local steps = 10
    local currentSpeed = hum.WalkSpeed
    local delta = (newSpeed - currentSpeed) / steps
    for i=1, steps do
        hum.WalkSpeed = hum.WalkSpeed + delta
        wait(0.02)
    end
    hum.WalkSpeed = newSpeed
end

local function toggleSpeed()
    local newSpeed = tonumber(prompt("Введите новую скорость", tostring(getHumanoid().WalkSpeed)))
    if newSpeed then
        setWalkSpeed(newSpeed)
    end
end

local function megaJump()
    local hum = getHumanoid()
    hum.JumpPower = 150
    hum.Jump = true
    wait(0.2)
    hum.JumpPower = 50
end

local function toggleGodMode()
    local hum = getHumanoid()
    if not godModeActive then
        hum.MaxHealth = math.huge
        hum.Health = math.huge
        godModeActive = true
        print("Бессмертие ВКЛ")
    else
        hum.MaxHealth = 100
        hum.Health = 100
        godModeActive = false
        print("Бессмертие ВЫКЛ")
    end
end

-- Основной цикл авто-ферма и бессмертия
spawn(function()
    while true do
        wait(0.5)
        -- Обновляем гуманоид
        getHumanoid()
        -- Авто-ферма логика (зависит от игры, тут пример)
        if autoFarm then
            -- Например, автоматическая атака
            -- Здесь можно вставить код, который ищет врагов и атакует
            -- Например, искать врагов поблизости и кликать по ним
        end
        -- Бессмертие
        if godModeActive and humanoid then
            humanoid.Health = humanoid.MaxHealth
        end
    end
end)

-- =========================
-- --- GUI создание ---
-- =========================

local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))

local function createButton(parent, text, size, position, bgColor)
    local btn = Instance.new("TextButton")
    btn.Size = size
    btn.Position = position
    btn.Text = text
    btn.BackgroundColor3 = bgColor
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 14
    btn.Parent = parent
    return btn
end

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

local btnAutoFarm = createButton(mainFrame, "Авто-ферм", UDim2.new(1,-20,0,30), UDim2.new(0,10,0,40), Color3.new(0.3,0.3,0.3))
local btnAntiAFK = createButton(mainFrame, "Анти-Афк", UDim2.new(1,-20,0,30), UDim2.new(0,10,0,80), Color3.new(0.3,0.3,0.3))
local btnSpeed = createButton(mainFrame, "Изменить скорость", UDim2.new(1,-20,0,30), UDim2.new(0,10,0,120), Color3.new(0.3,0.3,0.3))
local btnMegaJump = createButton(mainFrame, "Мега прыжок", UDim2.new(1,-20,0,30), UDim2.new(0,10,0,160), Color3.new(0.3,0.3,0.3))
local btnGodMode = createButton(mainFrame, "Бессмертие", UDim2.new(1,-20,0,30), UDim2.new(0,10,0,200), Color3.new(0.3,0.3,0.3))
local btnClose = createButton(mainFrame, "Закрыть", UDim2.new(1,-20,0,30), UDim2.new(0,10,0,250), Color3.new(0.7,0.2,0.2))

-- Создаем настройки (по шестеренке)
local settingsFrame = Instance.new("Frame", ScreenGui)
settingsFrame.Size = UDim2.new(0, 300, 0, 150)
settingsFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
settingsFrame.BackgroundColor3 = Color3.new(0.2,0.2,0.2)
settingsFrame.BorderSizePixel = 0
settingsFrame.Visible = false

local changeColorBtn = createButton(settingsFrame, "Изменить цвет", UDim2.new(1,-20,0,40), UDim2.new(0,10,0,10), Color3.new(0.5,0.5,0.5))
local closeBtnSettings = createButton(settingsFrame, "Закрыть", UDim2.new(1,-20,0,40), UDim2.new(0,10,0,60), Color3.new(0.7,0.2,0.2))

local function toggleSettings()
    if settingsFrame.Visible then
        -- закрываем
        for i=0,1,0.2 do
            settingsFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
            wait(0.02)
        end
        settingsFrame.Visible = false
    else
        -- открываем
        settingsFrame.Visible = true
        settingsFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
        for i=0,1,0.2 do
            settingsFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
            wait(0.02)
        end
    end
end

-- Обработки кнопок
btnClose.MouseButton1Click:Connect(function()
    -- окно подтверждения
    local confirmFrame = Instance.new("Frame", ScreenGui)
    confirmFrame.Size = UDim2.new(0, 350, 0, 150)
    confirmFrame.Position = UDim2.new(0.5, -175, 0.5, -75)
    confirmFrame.BackgroundColor3 = Color3.new(0.2,0.2,0.2)
    confirmFrame.BorderSizePixel = 0

    local textlbl = Instance.new("TextLabel", confirmFrame)
    textlbl.Size = UDim2.new(1,0,0,50)
    textlbl.Position = UDim2.new(0,0,0,0)
    textlbl.Text = "Вы действительно хотите закрыть скрипт?"
    textlbl.Font = Enum.Font.SourceSansBold
    textlbl.TextSize = 14
    textlbl.TextColor3 = Color3.new(1,1,1)

    local btnYes = createButton(confirmFrame, "Да", UDim2.new(0,100,0,40), UDim2.new(0,50,1,-50), Color3.new(0.7,0.2,0.2))
    local btnNo = createButton(confirmFrame, "Нет", UDim2.new(0,100,0,40), UDim2.new(0,200,1,-50), Color3.new(0.2,0.7,0.2))

    btnYes.MouseButton1Click:Connect(function()
        -- Удаление GUI и выключение функций
        mainFrame:Destroy()
        settingsFrame:Destroy()
        confirmFrame:Destroy()
        -- Можно дополнительно сделать отключение всех флагов
    end)

    btnNo.MouseButton1Click:Connect(function()
        confirmFrame:Destroy()
    end)
end)

-- Обработка "Шестеренки"
createButton(mainFrame, "⚙️", UDim2.new(0,50,0,50), UDim2.new(1,-55,0,5), Color3.new(0.8,0.8,0.8)).MouseButton1Click:Connect(toggleSettings)

-- Внутри функции toggleSettings реализована анимация

-- Обработка кнопок функции
local function bindToggleBtn(btn, flagName)
    btn.MouseButton1Click:Connect(function()
        _G[flagName] = not _G[flagName]
        print(flagName .. ": " .. tostring(_G[flagName]))
        -- Можно добавлять тут код, который именно включает/выключает действия
    end)
end

-- Используйте глобальные переменные или флаги
_G.autoFarm = false
_G.antiAFK = false
_G.godMode = false
_G.speed = 16
_G.megaJump = false

-- Переключатель авто-ферма
local function toggleAutoFarm()
    _G.autoFarm = not _G.autoFarm
    print("AutoFarm = " .. tostring(_G.autoFarm))
end
-- Переключатель анти-афк
local function toggleAntiAFK()
    _G.antiAFK = not _G.antiAFK
    if _G.antiAFK then
        spawn(function()
            local VirtualUser = game:GetService("VirtualUser")
            while _G.antiAFK do
                wait(300)
                VirtualUser:CaptureController()
                VirtualUser:SetKeyDown(Enum.KeyCode.W)
                wait(0.1)
                VirtualUser:SetKeyUp(Enum.KeyCode.W)
            end
        end)
    end
    print("AntiAFK = " .. tostring(_G.antiAFK))
end

-- Обработка кнопки "Изменить скорость"
local function changeSpeed()
    local newSpeed = tonumber(prompt("Введите скорость", tostring(_G.speed)))
    if newSpeed then
        _G.speed = newSpeed
        setWalkSpeed(newSpeed)
    end
end

-- Обработка "Мега прыжка"
local function performMegaJump()
    local hum = getHumanoid()
    hum.JumpPower = 150
    hum.Jump = true
    wait(0.2)
    hum.JumpPower = 50
end

-- Обработка "Бессмертие"
local function toggleGod()
    local hum = getHumanoid()
    if not _G.godMode then
        hum.MaxHealth = math.huge
        hum.Health = math.huge
        _G.godMode = true
        print("Бессмертие ON")
    else
        hum.MaxHealth = 100
        hum.Health = 100
        _G.godMode = false
        print("Бессмертие OFF")
    end
end

-- Обработки кнопок (вызывайте их прямо в коде или через события)
bindToggleBtn(btnAutoFarm, "autoFarm")
bindToggleBtn(btnAntiAFK, "antiAFK")
bindToggleBtn(btnSpeed, "speed")
bindToggleBtn(btnMegaJump, "megaJump")
bindToggleBtn(btnGodMode, "godMode")

-- В основном цикле эти функции используем
spawn(function()
    while true do
        wait(0.5)
        getHumanoid()

        if _G.autoFarm then
            -- тут логика авто-атаки или собирания предметов
        end

        if _G.godMode and humanoid then
            humanoid.Health = humanoid.MaxHealth
        end
    end
end)

-- Следите, чтобы функции реально делали что-то
-- Например, для авто-фермы вставьте сюда код поиска врагов и атаки.
