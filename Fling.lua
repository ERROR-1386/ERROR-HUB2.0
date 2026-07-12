--[[
    🌟 ERROR-HUB
    • Крутилка (супер быстрая)
    • Полёт "Супермен"
    • Анимация загрузки с логотипом
    • Кнопка открыть/закрыть
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

-- ============================================
-- НАСТРОЙКИ
-- ============================================
local LOGO_URL = "https://i.ibb.co/mV4JzqC6/error-hub-logo.png"
local HUB_NAME = "ERROR-HUB"
local VERSION = "v2.0"

local Colors = {
    Primary = Color3.fromRGB(255, 50, 50),
    Secondary = Color3.fromRGB(25, 25, 35),
    Accent = Color3.fromRGB(255, 215, 0),
    Text = Color3.fromRGB(255, 255, 255),
    Green = Color3.fromRGB(0, 255, 100),
}

-- ============================================
-- АНИМАЦИИ
-- ============================================
local function createTween(obj, props, time)
    local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, tweenInfo, props)
    tween:Play()
    return tween
end

-- ============================================
-- ЭКРАН ЗАГРУЗКИ
-- ============================================
local function CreateLoadingScreen()
    local LoadGui = Instance.new("ScreenGui")
    LoadGui.Name = "LoadingScreen"
    LoadGui.Parent = CoreGui
    
    local Background = Instance.new("Frame")
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Background.BackgroundTransparency = 1
    Background.Parent = LoadGui
    
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0, 350, 0, 280)
    Container.Position = UDim2.new(0.5, -175, 0.5, -140)
    Container.BackgroundColor3 = Colors.Secondary
    Container.BorderSizePixel = 0
    Container.BackgroundTransparency = 1
    Container.Parent = LoadGui
    
    local Logo = Instance.new("ImageLabel")
    Logo.Size = UDim2.new(0, 100, 0, 100)
    Logo.Position = UDim2.new(0.5, -50, 0, 20)
    Logo.BackgroundTransparency = 1
    Logo.Image = LOGO_URL
    Logo.ImageTransparency = 1
    Logo.Parent = Container
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 130)
    Title.BackgroundTransparency = 1
    Title.Text = HUB_NAME
    Title.TextColor3 = Colors.Primary
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 36
    Title.TextTransparency = 1
    Title.Parent = Container
    
    local Version = Instance.new("TextLabel")
    Version.Size = UDim2.new(1, 0, 0, 20)
    Version.Position = UDim2.new(0, 0, 0, 170)
    Version.BackgroundTransparency = 1
    Version.Text = VERSION
    Version.TextColor3 = Colors.Accent
    Version.Font = Enum.Font.Gotham
    Version.TextSize = 14
    Version.TextTransparency = 1
    Version.Parent = Container
    
    local ProgressBg = Instance.new("Frame")
    ProgressBg.Size = UDim2.new(0, 250, 0, 6)
    ProgressBg.Position = UDim2.new(0.5, -125, 0, 210)
    ProgressBg.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    ProgressBg.BorderSizePixel = 0
    ProgressBg.BackgroundTransparency = 1
    ProgressBg.Parent = Container
    
    local ProgressFill = Instance.new("Frame")
    ProgressFill.Size = UDim2.new(0, 0, 1, 0)
    ProgressFill.BackgroundColor3 = Colors.Primary
    ProgressFill.BorderSizePixel = 0
    ProgressFill.Parent = ProgressBg
    
    local Status = Instance.new("TextLabel")
    Status.Size = UDim2.new(1, 0, 0, 20)
    Status.Position = UDim2.new(0, 0, 0, 230)
    Status.BackgroundTransparency = 1
    Status.Text = "Загрузка..."
    Status.TextColor3 = Colors.Text
    Status.Font = Enum.Font.Gotham
    Status.TextSize = 12
    Status.TextTransparency = 1
    Status.Parent = Container
    
    createTween(Background, {BackgroundTransparency = 0.5}, 0.3)
    wait(0.2)
    createTween(Container, {BackgroundTransparency = 0}, 0.5)
    wait(0.1)
    createTween(Logo, {ImageTransparency = 0}, 0.5, Enum.EasingStyle.Back)
    wait(0.2)
    createTween(Title, {TextTransparency = 0}, 0.4)
    createTween(Version, {TextTransparency = 0}, 0.4)
    wait(0.1)
    createTween(ProgressBg, {BackgroundTransparency = 0}, 0.3)
    createTween(Status, {TextTransparency = 0}, 0.3)
    
    local msgs = {"Загрузка системы...", "Подключение...", "Загрузка функций...", "Готово!"}
    for i = 1, 100 do
        ProgressFill.Size = UDim2.new(i/100, 0, 1, 0)
        if i == 25 then Status.Text = msgs[1]
        elseif i == 50 then Status.Text = msgs[2]
        elseif i == 75 then Status.Text = msgs[3]
        elseif i == 95 then Status.Text = msgs[4] end
        wait(0.015)
    end
    
    wait(0.3)
    createTween(LoadGui, {Enabled = false}, 0.5)
end

-- ============================================
-- 💨 СУПЕР КРУТИЛКА
-- ============================================
local SpinnerEnabled = false
local SpinPower = 200
local SpinRadius = 50
local SelectedPlayer = nil

local function getChar(plr)
    return plr.Character
end

local function getRoot(char)
    if char then
        return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
    end
end

local function flingPlayer(target)
    local tChar = getChar(target)
    if not tChar then return end
    local tRoot = getRoot(tChar)
    if not tRoot then return end
    
    local mChar = LocalPlayer.Character
    if not mChar then return end
    local mRoot = getRoot(mChar)
    if not mRoot then return end
    
    -- Супер быстрое откидывание
    local dir = (tRoot.Position - mRoot.Position).Unit
    dir = Vector3.new(dir.X, 0.3, dir.Z).Unit
    
    -- Мгновенный импульс
    tRoot.Velocity = dir * SpinPower
    tRoot.RotVelocity = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
    
    -- Дополнительные толчки для дальности
    spawn(function()
        for i = 1, 10 do
            wait(0.05)
            if tRoot and tRoot.Parent then
                tRoot.Velocity = dir * (SpinPower * (1 - i/15))
            end
        end
    end)
end

local function startSpinner()
    spawn(function()
        while SpinnerEnabled do
            wait(0.05) -- Супер быстрый тик
            
            pcall(function()
                local mChar = LocalPlayer.Character
                if not mChar then return end
                local mRoot = getRoot(mChar)
                if not mRoot then return end
                
                -- Если выбрана цель - телепорт к ней
                if SelectedPlayer then
                    local tChar = getChar(SelectedPlayer)
                    if tChar then
                        local tRoot = getRoot(tChar)
                        if tRoot then
                            mRoot.CFrame = tRoot.CFrame * CFrame.new(0, 3, 0)
                        end
                    end
                end
                
                -- Откидываем всех в радиусе
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer then
                        local tChar = getChar(plr)
                        if tChar then
                            local tRoot = getRoot(tChar)
                            if tRoot then
                                local dist = (tRoot.Position - mRoot.Position).Magnitude
                                if dist < SpinRadius then
                                    flingPlayer(plr)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
end

-- ============================================
-- ✈️ ПОЛЁТ "СУПЕРМЕН"
-- ============================================
local FlyEnabled = false
local FlySpeed = 150
local FlyBodyGyro = nil
local FlyBodyVelocity = nil

local function startSupermanFly()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local root = getRoot(char)
        if not root then return end
        
        if FlyBodyGyro then FlyBodyGyro:Destroy() end
        if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
        
        -- Основной гироскоп
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.P = 50000
        bodyGyro.Parent = root
        FlyBodyGyro = bodyGyro
        
        -- Основная скорость
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.P = 50000
        bodyVelocity.Parent = root
        FlyBodyVelocity = bodyVelocity
        
        -- Анимация Супермена (руки вперёд)
        local animate = Instance.new("Animation")
        animate.AnimationId = "rbxassetid://1545017676" -- Fly animation
        
        spawn(function()
            while FlyEnabled do
                task.wait()
                pcall(function()
                    if not root or not root.Parent then return end
                    
                    -- Наклоняем персонажа вперёд (поза супермена)
                    local cameraDir = Workspace.CurrentCamera.CFrame.LookVector
                    local horizontalDir = Vector3.new(cameraDir.X, 0, cameraDir.Z).Unit
                    
                    -- Создаём CFrame для позы супермена
                    local lookCFrame = CFrame.lookAt(root.Position, root.Position + horizontalDir)
                    local supermanCFrame = lookCFrame * CFrame.Angles(-math.rad(15), 0, 0) -- Наклон вперёд
                    
                    bodyGyro.CFrame = supermanCFrame
                    
                    -- Скорость
                    local vel = Vector3.zero
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        vel += horizontalDir * FlySpeed
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        vel -= horizontalDir * FlySpeed
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        vel -= Workspace.CurrentCamera.CFrame.RightVector * FlySpeed
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        vel += Workspace.CurrentCamera.CFrame.RightVector * FlySpeed
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        vel += Vector3.new(0, FlySpeed, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        vel -= Vector3.new(0, FlySpeed, 0)
                    end
                    
                    bodyVelocity.Velocity = vel
                    
                    -- Эффект скорости (particles)
                    if vel.Magnitude > 10 then
                        -- Создаём частицы позади игрока
                        pcall(function()
                            local trail = Instance.new("Part")
                            trail.Size = Vector3.new(0.5, 0.5, 0.5)
                            trail.Position = root.Position - horizontalDir * 3
                            trail.Anchored = true
                            trail.CanCollide = false
                            trail.Material = Enum.Material.Neon
                            trail.BrickColor = BrickColor.new("Bright red")
                            trail.Transparency = 0.5
                            trail.Parent = Workspace
                            Debris:AddItem(trail, 0.5)
                        end)
                    end
                end)
            end
            
            if FlyBodyGyro then FlyBodyGyro:Destroy() end
            if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
        end)
    end)
end

-- ============================================
-- ГЛАВНОЕ МЕНЮ
-- ============================================
local function CreateMainGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ErrorHub"
    ScreenGui.Parent = CoreGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 400, 0, 380)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -190)
    MainFrame.BackgroundColor3 = Colors.Secondary
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    
    -- Заголовок
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 55)
    Header.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame
    
    local LogoSmall = Instance.new("ImageLabel")
    LogoSmall.Size = UDim2.new(0, 35, 0, 35)
    LogoSmall.Position = UDim2.new(0, 10, 0, 10)
    LogoSmall.BackgroundTransparency = 1
    LogoSmall.Image = LOGO_URL
    LogoSmall.Parent = Header
    
    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Size = UDim2.new(0, 200, 0, 30)
    HeaderTitle.Position = UDim2.new(0, 50, 0, 8)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Text = HUB_NAME
    HeaderTitle.TextColor3 = Colors.Primary
    HeaderTitle.Font = Enum.Font.GothamBold
    HeaderTitle.TextSize = 20
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderTitle.Parent = Header
    
    local HeaderVer = Instance.new("TextLabel")
    HeaderVer.Size = UDim2.new(0, 50, 0, 18)
    HeaderVer.Position = UDim2.new(0, 50, 0, 33)
    HeaderVer.BackgroundTransparency = 1
    HeaderVer.Text = VERSION
    HeaderVer.TextColor3 = Colors.Accent
    HeaderVer.Font = Enum.Font.Gotham
    HeaderVer.TextSize = 10
    HeaderVer.TextXAlignment = Enum.TextXAlignment.Left
    HeaderVer.Parent = Header
    
    -- Вкладки
    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(0, 130, 1, -55)
    TabFrame.Position = UDim2.new(0, 0, 0, 55)
    TabFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    TabFrame.BorderSizePixel = 0
    TabFrame.Parent = MainFrame
    
    local Tabs = {}
    local TabBtns = {}
    local TabNames = {"💨 Крутилка", "✈️ Супермен"}
    
    for i, name in ipairs(TabNames) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 35)
        btn.Position = UDim2.new(0, 5, 0, 10 + (i-1)*42)
        btn.BackgroundColor3 = i == 1 and Colors.Primary or Color3.fromRGB(50, 50, 70)
        btn.Text = name
        btn.TextColor3 = Colors.Text
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.BorderSizePixel = 0
        btn.Parent = TabFrame
        TabBtns[i] = btn
        
        local page = Instance.new("Frame")
        page.Size = UDim2.new(1, -140, 1, -65)
        page.Position = UDim2.new(0, 135, 0, 60)
        page.BackgroundTransparency = 1
        page.Visible = i == 1
        page.Parent = MainFrame
        Tabs[i] = page
        
        btn.MouseButton1Click:Connect(function()
            for j, p in ipairs(Tabs) do p.Visible = j == i end
            for j, b in ipairs(TabBtns) do
                b.BackgroundColor3 = j == i and Colors.Primary or Color3.fromRGB(50, 50, 70)
            end
        end)
    end
    
    -- ========== СТРАНИЦА КРУТИЛКИ ==========
    local SpinPage = Tabs[1]
    
    -- Главный переключатель
    local SpinToggle = Instance.new("TextButton")
    SpinToggle.Size = UDim2.new(1, -20, 0, 45)
    SpinToggle.Position = UDim2.new(0, 10, 0, 10)
    SpinToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    SpinToggle.Text = "💨 КРУТИЛКА: OFF"
    SpinToggle.TextColor3 = Colors.Text
    SpinToggle.Font = Enum.Font.GothamBold
    SpinToggle.TextSize = 16
    SpinToggle.BorderSizePixel = 0
    SpinToggle.Parent = SpinPage
    
    SpinToggle.MouseButton1Click:Connect(function()
        SpinnerEnabled = not SpinnerEnabled
        SpinToggle.Text = "💨 КРУТИЛКА: " .. (SpinnerEnabled and "ON" or "OFF")
        SpinToggle.BackgroundColor3 = SpinnerEnabled and Colors.Green or Color3.fromRGB(200, 50, 50)
        if SpinnerEnabled then startSpinner() end
    end)
    
    -- Сила
    local PowerLabel = Instance.new("TextLabel")
    PowerLabel.Size = UDim2.new(1, -20, 0, 22)
    PowerLabel.Position = UDim2.new(0, 10, 0, 65)
    PowerLabel.BackgroundTransparency = 1
    PowerLabel.Text = "💪 Сила: " .. SpinPower
    PowerLabel.TextColor3 = Colors.Text
    PowerLabel.Font = Enum.Font.Gotham
    PowerLabel.TextSize = 13
    PowerLabel.TextXAlignment = Enum.TextXAlignment.Left
    PowerLabel.Parent = SpinPage
    
    local PowerUp = Instance.new("TextButton")
    PowerUp.Size = UDim2.new(0, 60, 0, 28)
    PowerUp.Position = UDim2.new(1, -70, 0, 63)
    PowerUp.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    PowerUp.Text = "➕ +50"
    PowerUp.TextColor3 = Colors.Text
    PowerUp.Font = Enum.Font.GothamBold
    PowerUp.TextSize = 10
    PowerUp.BorderSizePixel = 0
    PowerUp.Parent = SpinPage
    
    local PowerDown = Instance.new("TextButton")
    PowerDown.Size = UDim2.new(0, 60, 0, 28)
    PowerDown.Position = UDim2.new(1, -70, 0, 95)
    PowerDown.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    PowerDown.Text = "➖ -50"
    PowerDown.TextColor3 = Colors.Text
    PowerDown.Font = Enum.Font.GothamBold
    PowerDown.TextSize = 10
    PowerDown.BorderSizePixel = 0
    PowerDown.Parent = SpinPage
    
    PowerUp.MouseButton1Click:Connect(function()
        SpinPower = math.min(SpinPower + 50, 1000)
        PowerLabel.Text = "💪 Сила: " .. SpinPower
    end)
    
    PowerDown.MouseButton1Click:Connect(function()
        SpinPower = math.max(SpinPower - 50, 50)
        PowerLabel.Text = "💪 Сила: " .. SpinPower
    end)
    
    -- Радиус
    local RadiusLabel = Instance.new("TextLabel")
    RadiusLabel.Size = UDim2.new(1, -20, 0, 22)
    RadiusLabel.Position = UDim2.new(0, 10, 0, 135)
    RadiusLabel.BackgroundTransparency = 1
    RadiusLabel.Text = "📡 Радиус: " .. SpinRadius
    RadiusLabel.TextColor3 = Colors.Text
    RadiusLabel.Font = Enum.Font.Gotham
    RadiusLabel.TextSize = 13
    RadiusLabel.TextXAlignment = Enum.TextXAlignment.Left
    RadiusLabel.Parent = SpinPage
    
    local RadiusUp = Instance.new("TextButton")
    RadiusUp.Size = UDim2.new(0, 60, 0, 28)
    RadiusUp.Position = UDim2.new(1, -70, 0, 133)
    RadiusUp.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    RadiusUp.Text = "➕ +10"
    RadiusUp.TextColor3 = Colors.Text
    RadiusUp.Font = Enum.Font.GothamBold
    RadiusUp.TextSize = 10
    RadiusUp.BorderSizePixel = 0
    RadiusUp.Parent = SpinPage
    
    local RadiusDown = Instance.new("TextButton")
    RadiusDown.Size = UDim2.new(0, 60, 0, 28)
    RadiusDown.Position = UDim2.new(1, -70, 0, 165)
    RadiusDown.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    RadiusDown.Text = "➖ -10"
    RadiusDown.TextColor3 = Colors.Text
    RadiusDown.Font = Enum.Font.GothamBold
    RadiusDown.TextSize = 10
    RadiusDown.BorderSizePixel = 0
    RadiusDown.Parent = SpinPage
    
    RadiusUp.MouseButton1Click:Connect(function()
        SpinRadius = math.min(SpinRadius + 10, 300)
        RadiusLabel.Text = "📡 Радиус: " .. SpinRadius
    end)
    
    RadiusDown.MouseButton1Click:Connect(function()
        SpinRadius = math.max(SpinRadius - 10, 10)
        RadiusLabel.Text = "📡 Радиус: " .. SpinRadius
    end)
    
    -- Список игроков
    local PlayerListLabel = Instance.new("TextLabel")
    PlayerListLabel.Size = UDim2.new(1, -20, 0, 22)
    PlayerListLabel.Position = UDim2.new(0, 10, 0, 205)
    PlayerListLabel.BackgroundTransparency = 1
    PlayerListLabel.Text = "🎯 Цель (нажми для выбора):"
    PlayerListLabel.TextColor3 = Colors.Accent
    PlayerListLabel.Font = Enum.Font.Gotham
    PlayerListLabel.TextSize = 12
    PlayerListLabel.TextXAlignment = Enum.TextXAlignment.Left
    PlayerListLabel.Parent = SpinPage
    
    local PlayerList = Instance.new("ScrollingFrame")
    PlayerList.Size = UDim2.new(1, -20, 0, 100)
    PlayerList.Position = UDim2.new(0, 10, 0, 228)
    PlayerList.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    PlayerList.BorderSizePixel = 0
    PlayerList.ScrollBarThickness = 4
    PlayerList.CanvasSize = UDim2.new(0, 0, 0, 0)
    PlayerList.Parent = SpinPage
    
    local function updatePlayerList()
        for _, child in ipairs(PlayerList:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        
        local yPos = 0
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -5, 0, 24)
                btn.Position = UDim2.new(0, 0, 0, yPos)
                btn.BackgroundColor3 = SelectedPlayer == plr and Colors.Primary or Color3.fromRGB(60, 60, 80)
                btn.Text = plr.Name
                btn.TextColor3 = Colors.Text
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 11
                btn.BorderSizePixel = 0
                btn.Parent = PlayerList
                
                btn.MouseButton1Click:Connect(function()
                    SelectedPlayer = plr
                    updatePlayerList()
                end)
                
                yPos += 26
            end
        end
        
        PlayerList.CanvasSize = UDim2.new(0, 0, 0, yPos)
    end
    
    spawn(function()
        while wait(2) do
            pcall(updatePlayerList)
        end
    end)
    
    local ResetTarget = Instance.new("TextButton")
    ResetTarget.Size = UDim2.new(1, -20, 0, 25)
    ResetTarget.Position = UDim2.new(0, 10, 0, 335)
    ResetTarget.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    ResetTarget.Text = "🔄 Все игроки"
    ResetTarget.TextColor3 = Colors.Text
    ResetTarget.Font = Enum.Font.GothamBold
    ResetTarget.TextSize = 11
    ResetTarget.BorderSizePixel = 0
    ResetTarget.Parent = SpinPage
    
    ResetTarget.MouseButton1Click:Connect(function()
        SelectedPlayer = nil
        updatePlayerList()
    end)
    
    -- ========== СТРАНИЦА СУПЕРМЕНА ==========
    local FlyPage = Tabs[2]
    
    local FlyToggle = Instance.new("TextButton")
    FlyToggle.Size = UDim2.new(1, -20, 0, 45)
    FlyToggle.Position = UDim2.new(0, 10, 0, 10)
    FlyToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    FlyToggle.Text = "✈️ СУПЕРМЕН: OFF"
    FlyToggle.TextColor3 = Colors.Text
    FlyToggle.Font = Enum.Font.GothamBold
    FlyToggle.TextSize = 16
    FlyToggle.BorderSizePixel = 0
    FlyToggle.Parent = FlyPage
    
    FlyToggle.MouseButton1Click:Connect(function()
        FlyEnabled = not FlyEnabled
        FlyToggle.Text = "✈️ СУПЕРМЕН: " .. (FlyEnabled and "ON" or "OFF")
        FlyToggle.BackgroundColor3 = FlyEnabled and Colors.Green or Color3.fromRGB(200, 50, 50)
        if FlyEnabled then startSupermanFly() end
    end)
    
    local FlySpeedLabel = Instance.new("TextLabel")
    FlySpeedLabel.Size = UDim2.new(1, -20, 0, 22)
    FlySpeedLabel.Position = UDim2.new(0, 10, 0, 65)
    FlySpeedLabel.BackgroundTransparency = 1
    FlySpeedLabel.Text = "⚡ Скорость: " .. FlySpeed
    FlySpeedLabel.TextColor3 = Colors.Text
    FlySpeedLabel.Font = Enum.Font.Gotham
    FlySpeedLabel.TextSize = 13
    FlySpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
    FlySpeedLabel.Parent = FlyPage
    
    local FlySpeedUp = Instance.new("TextButton")
    FlySpeedUp.Size = UDim2.new(0, 60, 0, 28)
    FlySpeedUp.Position = UDim2.new(1, -70, 0, 63)
    FlySpeedUp.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    FlySpeedUp.Text = "➕ +25"
    FlySpeedUp.TextColor3 = Colors.Text
    FlySpeedUp.Font = Enum.Font.GothamBold
    FlySpeedUp.TextSize = 10
    FlySpeedUp.BorderSizePixel = 0
    FlySpeedUp.Parent = FlyPage
    
    local FlySpeedDown = Instance.new("TextButton")
    FlySpeedDown.Size = UDim2.new(0, 60, 0, 28)
    FlySpeedDown.Position = UDim2.new(1, -70, 0, 95)
    FlySpeedDown.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    FlySpeedDown.Text = "➖ -25"
    FlySpeedDown.TextColor3 = Colors.Text
    FlySpeedDown.Font = Enum.Font.GothamBold
    FlySpeedDown.TextSize = 10
    FlySpeedDown.BorderSizePixel = 0
    FlySpeedDown.Parent = FlyPage
    
    FlySpeedUp.MouseButton1Click:Connect(function()
        FlySpeed = math.min(FlySpeed + 25, 500)
        FlySpeedLabel.Text = "⚡ Скорость: " .. FlySpeed
    end)
    
    FlySpeedDown.MouseButton1Click:Connect(function()
        FlySpeed = math.max(FlySpeed - 25, 25)
        FlySpeedLabel.Text = "⚡ Скорость: " .. FlySpeed
    end)
    
    local FlyInfo = Instance.new("TextLabel")
    FlyInfo.Size = UDim2.new(1, -20, 0, 80)
    FlyInfo.Position = UDim2.new(0, 10, 0, 140)
    FlyInfo.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    FlyInfo.Text = "🦸 Управление:\nWASD - движение\nSpace - вверх\nShift - вниз\n(Летаешь как Супермен!)"
    FlyInfo.TextColor3 = Colors.Text
    FlyInfo.Font = Enum.Font.Gotham
    FlyInfo.TextSize = 11
    FlyInfo.TextXAlignment = Enum.TextXAlignment.Left
    FlyInfo.BorderSizePixel = 0
    FlyInfo.Parent = FlyPage
    
    -- Кнопка закрыть
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 5)
    CloseBtn.BackgroundColor3 = Colors.Primary
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Colors.Text
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 16
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = Header
    
    CloseBtn.MouseButton1Click:Connect(function()
        SpinnerEnabled = false
        FlyEnabled = false
        if FlyBodyGyro then FlyBodyGyro:Destroy() end
        if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
        createTween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.3)
        wait(0.3)
        ScreenGui:Destroy()
    end)
    
    return ScreenGui, MainFrame
end

-- ============================================
-- КНОПКА ОТКРЫТЬ/ЗАКРЫТЬ
-- ============================================
local function CreateToggleButton()
    local ToggleGui = Instance.new("ScreenGui")
    ToggleGui.Name = "ToggleButton"
    ToggleGui.Parent = CoreGui
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
    ToggleBtn.Position = UDim2.new(0, 10, 0.5, -25)
    ToggleBtn.BackgroundColor3 = Colors.Primary
    ToggleBtn.Text = "🌟"
    ToggleBtn.TextColor3 = Colors.Text
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextSize = 20
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Parent = ToggleGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(1, 0)
    Corner.Parent = ToggleBtn
    
    local MainGui = nil
    local MainFrame = nil
    local isOpen = false
    
    ToggleBtn.MouseButton1Click:Connect(function()
        if isOpen then
            if MainFrame then
                createTween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.3)
                wait(0.3)
            end
            if MainGui then MainGui:Destroy() end
            MainGui = nil
            isOpen = false
            ToggleBtn.Text = "🌟"
            ToggleBtn.BackgroundColor3 = Colors.Primary
        else
            ToggleBtn.Text = "✕"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            MainGui, MainFrame = CreateMainGUI()
            isOpen = true
        end
    end)
end

-- ============================================
-- ЗАПУСК
-- ============================================
spawn(function()
    CreateLoadingScreen()
end)

wait(5.5)
CreateToggleButton()
