--[[
    ERROR-HUB - ПОЛНАЯ ВЕРСИЯ
    - Бинд на правый Shift для открытия меню
    - Крутилка (супер быстрая)
    - Полёт Супермен с анимацией
    - Settings с выбором цвета
    - Close Script
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")

-- ============================================
-- НАСТРОЙКИ
-- ============================================
local LOGO_URL = "https://i.ibb.co/mV4JzqC6/error-hub-logo.png"
local HUB_NAME = "ERROR-HUB"
local VERSION = "v2.0"

-- Текущая тема
local Theme = {}

-- Все темы
local Themes = {
    Red = {
        Primary = Color3.fromRGB(255, 50, 50),
        Secondary = Color3.fromRGB(25, 25, 35),
        Accent = Color3.fromRGB(255, 215, 0),
        Text = Color3.fromRGB(255, 255, 255),
        Green = Color3.fromRGB(0, 255, 100),
    },
    Blue = {
        Primary = Color3.fromRGB(50, 100, 255),
        Secondary = Color3.fromRGB(20, 25, 40),
        Accent = Color3.fromRGB(100, 200, 255),
        Text = Color3.fromRGB(255, 255, 255),
        Green = Color3.fromRGB(0, 255, 100),
    },
    Purple = {
        Primary = Color3.fromRGB(150, 50, 255),
        Secondary = Color3.fromRGB(30, 20, 45),
        Accent = Color3.fromRGB(255, 100, 255),
        Text = Color3.fromRGB(255, 255, 255),
        Green = Color3.fromRGB(0, 255, 100),
    },
    Green = {
        Primary = Color3.fromRGB(50, 255, 100),
        Secondary = Color3.fromRGB(20, 35, 25),
        Accent = Color3.fromRGB(255, 255, 100),
        Text = Color3.fromRGB(255, 255, 255),
        Green = Color3.fromRGB(0, 200, 50),
    },
    White = {
        Primary = Color3.fromRGB(255, 255, 255),
        Secondary = Color3.fromRGB(35, 35, 45),
        Accent = Color3.fromRGB(255, 50, 50),
        Text = Color3.fromRGB(0, 0, 0),
        Green = Color3.fromRGB(0, 200, 50),
    },
}

-- Устанавливаем тему по умолчанию
Theme = Themes.Red

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
-- ПОЛУЧЕНИЕ ЧАСТЕЙ ПЕРСОНАЖА
-- ============================================
local function getChar(plr)
    if plr then return plr.Character end
end

local function getRoot(char)
    if char then
        return char:FindFirstChild("HumanoidRootPart") 
            or char:FindFirstChild("Torso") 
            or char:FindFirstChild("UpperTorso")
    end
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
    Container.BackgroundColor3 = Theme.Secondary
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
    Title.TextColor3 = Theme.Primary
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 36
    Title.TextTransparency = 1
    Title.Parent = Container
    
    local Version = Instance.new("TextLabel")
    Version.Size = UDim2.new(1, 0, 0, 20)
    Version.Position = UDim2.new(0, 0, 0, 170)
    Version.BackgroundTransparency = 1
    Version.Text = VERSION
    Version.TextColor3 = Theme.Accent
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
    ProgressFill.BackgroundColor3 = Theme.Primary
    ProgressFill.BorderSizePixel = 0
    ProgressFill.Parent = ProgressBg
    
    local Status = Instance.new("TextLabel")
    Status.Size = UDim2.new(1, 0, 0, 20)
    Status.Position = UDim2.new(0, 0, 0, 230)
    Status.BackgroundTransparency = 1
    Status.Text = "Loading..."
    Status.TextColor3 = Theme.Text
    Status.Font = Enum.Font.Gotham
    Status.TextSize = 12
    Status.TextTransparency = 1
    Status.Parent = Container
    
    createTween(Background, {BackgroundTransparency = 0.5}, 0.3)
    wait(0.2)
    createTween(Container, {BackgroundTransparency = 0}, 0.5)
    wait(0.1)
    createTween(Logo, {ImageTransparency = 0}, 0.5)
    wait(0.2)
    createTween(Title, {TextTransparency = 0}, 0.4)
    createTween(Version, {TextTransparency = 0}, 0.4)
    wait(0.1)
    createTween(ProgressBg, {BackgroundTransparency = 0}, 0.3)
    createTween(Status, {TextTransparency = 0}, 0.3)
    
    local msgs = {"Loading system...", "Connecting...", "Loading functions...", "Ready!"}
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
-- КРУТИЛКА
-- ============================================
local SpinnerEnabled = false
local SpinPower = 200
local SpinRadius = 50
local SelectedPlayer = nil

local function flingPlayer(target)
    pcall(function()
        local tChar = getChar(target)
        if not tChar then return end
        local tRoot = getRoot(tChar)
        if not tRoot then return end
        
        local mChar = LocalPlayer.Character
        if not mChar then return end
        local mRoot = getRoot(mChar)
        if not mRoot then return end
        
        local dir = (tRoot.Position - mRoot.Position).Unit
        if dir.Magnitude == 0 then
            dir = Vector3.new(math.random(), 0.5, math.random()).Unit
        end
        
        dir = Vector3.new(dir.X, math.abs(dir.Y) + 0.3, dir.Z).Unit
        
        tRoot.Velocity = dir * SpinPower
        tRoot.AssemblyLinearVelocity = dir * SpinPower
        
        spawn(function()
            for i = 1, 5 do
                task.wait(0.05)
                if tRoot and tRoot.Parent then
                    tRoot.Velocity = dir * (SpinPower * (1 - i/10))
                end
            end
        end)
    end)
end

local function startSpinner()
    spawn(function()
        while SpinnerEnabled do
            task.wait(0.05)
            
            pcall(function()
                local mChar = LocalPlayer.Character
                if not mChar then return end
                local mRoot = getRoot(mChar)
                if not mRoot then return end
                
                if SelectedPlayer then
                    local tChar = getChar(SelectedPlayer)
                    if tChar then
                        local tRoot = getRoot(tChar)
                        if tRoot then
                            mRoot.CFrame = tRoot.CFrame * CFrame.new(0, 3, 0)
                        end
                    end
                end
                
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
-- ПОЛЁТ СУПЕРМЕН
-- ============================================
local FlyEnabled = false
local FlySpeed = 150
local FlyBodyGyro = nil
local FlyBodyVelocity = nil
local FlyAnimTrack = nil

local function startSupermanFly()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local root = getRoot(char)
        if not root then return end
        local humanoid = char:FindFirstChild("Humanoid")
        
        if FlyBodyGyro then FlyBodyGyro:Destroy() end
        if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
        if FlyAnimTrack then FlyAnimTrack:Stop() FlyAnimTrack:Destroy() end
        
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
        bodyGyro.P = 30000
        bodyGyro.Parent = root
        FlyBodyGyro = bodyGyro
        
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
        bodyVelocity.P = 30000
        bodyVelocity.Parent = root
        FlyBodyVelocity = bodyVelocity
        
        -- Анимация полёта
        if humanoid then
            local animator = humanoid:WaitForChild("Animator")
            local animIds = {
                "rbxassetid://507766666",
                "rbxassetid://507766388",
                "rbxassetid://1545017676",
            }
            
            for _, id in ipairs(animIds) do
                local success, result = pcall(function()
                    local anim = Instance.new("Animation")
                    anim.AnimationId = id
                    FlyAnimTrack = animator:LoadAnimation(anim)
                    FlyAnimTrack:Play()
                    FlyAnimTrack.Looped = true
                    FlyAnimTrack:AdjustSpeed(1.5)
                end)
                if success then break end
            end
        end
        
        spawn(function()
            while FlyEnabled do
                task.wait()
                pcall(function()
                    if not root or not root.Parent then return end
                    
                    local vel = Vector3.zero
                    local cam = Workspace.CurrentCamera.CFrame
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel += cam.LookVector * FlySpeed end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel -= cam.LookVector * FlySpeed end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel -= cam.RightVector * FlySpeed end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel += cam.RightVector * FlySpeed end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel += Vector3.new(0, FlySpeed, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vel -= Vector3.new(0, FlySpeed, 0) end
                    
                    bodyVelocity.Velocity = vel
                    
                    if vel.Magnitude > 1 then
                        bodyGyro.CFrame = CFrame.lookAt(root.Position, root.Position + vel.Unit)
                    end
                end)
            end
            
            if FlyAnimTrack then FlyAnimTrack:Stop() FlyAnimTrack:Destroy() FlyAnimTrack = nil end
            if FlyBodyGyro then FlyBodyGyro:Destroy() FlyBodyGyro = nil end
            if FlyBodyVelocity then FlyBodyVelocity:Destroy() FlyBodyVelocity = nil end
        end)
    end)
end

-- ============================================
-- ОКНО НАСТРОЕК
-- ============================================
local function CreateSettingsWindow(parentGui)
    local SettingsFrame = Instance.new("Frame")
    SettingsFrame.Size = UDim2.new(0, 250, 0, 200)
    SettingsFrame.Position = UDim2.new(0.5, -125, 0.5, -100)
    SettingsFrame.BackgroundColor3 = Theme.Secondary
    SettingsFrame.BorderSizePixel = 0
    SettingsFrame.ZIndex = 100
    SettingsFrame.Parent = parentGui
    
    local SettingsTitle = Instance.new("TextLabel")
    SettingsTitle.Size = UDim2.new(1, 0, 0, 35)
    SettingsTitle.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    SettingsTitle.Text = "Settings"
    SettingsTitle.TextColor3 = Theme.Primary
    SettingsTitle.Font = Enum.Font.GothamBold
    SettingsTitle.TextSize = 16
    SettingsTitle.BorderSizePixel = 0
    SettingsTitle.ZIndex = 101
    SettingsTitle.Parent = SettingsFrame
    
    local ColorLabel = Instance.new("TextLabel")
    ColorLabel.Size = UDim2.new(1, -20, 0, 22)
    ColorLabel.Position = UDim2.new(0, 10, 0, 45)
    ColorLabel.BackgroundTransparency = 1
    ColorLabel.Text = "GUI Color:"
    ColorLabel.TextColor3 = Theme.Text
    ColorLabel.Font = Enum.Font.Gotham
    ColorLabel.TextSize = 13
    ColorLabel.TextXAlignment = Enum.TextXAlignment.Left
    ColorLabel.ZIndex = 101
    ColorLabel.Parent = SettingsFrame
    
    local colorNames = {"Red", "Blue", "Purple", "Green", "White"}
    local colorValues = {
        Color3.fromRGB(255, 50, 50),
        Color3.fromRGB(50, 100, 255),
        Color3.fromRGB(150, 50, 255),
        Color3.fromRGB(50, 255, 100),
        Color3.fromRGB(200, 200, 200),
    }
    
    for i, name in ipairs(colorNames) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 42, 0, 30)
        btn.Position = UDim2.new(0, 10 + (i-1)*46, 0, 72)
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 10
        btn.BorderSizePixel = 0
        btn.BackgroundColor3 = colorValues[i]
        btn.ZIndex = 101
        btn.Parent = SettingsFrame
        
        btn.MouseButton1Click:Connect(function()
            Theme = Themes[name]
            SettingsFrame:Destroy()
            if parentGui:FindFirstChild("MainFrame") then
                parentGui.MainFrame:Destroy()
            end
            CreateMainContent(parentGui)
        end)
    end
    
    local CloseScriptBtn = Instance.new("TextButton")
    CloseScriptBtn.Size = UDim2.new(1, -20, 0, 35)
    CloseScriptBtn.Position = UDim2.new(0, 10, 0, 115)
    CloseScriptBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseScriptBtn.Text = "Close Script"
    CloseScriptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseScriptBtn.Font = Enum.Font.GothamBold
    CloseScriptBtn.TextSize = 14
    CloseScriptBtn.BorderSizePixel = 0
    CloseScriptBtn.ZIndex = 101
    CloseScriptBtn.Parent = SettingsFrame
    
    CloseScriptBtn.MouseButton1Click:Connect(function()
        SpinnerEnabled = false
        FlyEnabled = false
        if FlyBodyGyro then FlyBodyGyro:Destroy() end
        if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
        if FlyAnimTrack then FlyAnimTrack:Stop() FlyAnimTrack:Destroy() end
        parentGui:Destroy()
    end)
    
    local CloseSettings = Instance.new("TextButton")
    CloseSettings.Size = UDim2.new(1, -20, 0, 30)
    CloseSettings.Position = UDim2.new(0, 10, 0, 160)
    CloseSettings.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    CloseSettings.Text = "Close Settings"
    CloseSettings.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseSettings.Font = Enum.Font.Gotham
    CloseSettings.TextSize = 13
    CloseSettings.BorderSizePixel = 0
    CloseSettings.ZIndex = 101
    CloseSettings.Parent = SettingsFrame
    
    CloseSettings.MouseButton1Click:Connect(function()
        SettingsFrame:Destroy()
    end)
end

-- ============================================
-- ГЛАВНОЕ МЕНЮ
-- ============================================
local function CreateMainContent(ScreenGui)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 400, 0, 380)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -190)
    MainFrame.BackgroundColor3 = Theme.Secondary
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    
    -- Header
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
    HeaderTitle.TextColor3 = Theme.Primary
    HeaderTitle.Font = Enum.Font.GothamBold
    HeaderTitle.TextSize = 20
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderTitle.Parent = Header
    
    local HeaderVer = Instance.new("TextLabel")
    HeaderVer.Size = UDim2.new(0, 50, 0, 18)
    HeaderVer.Position = UDim2.new(0, 50, 0, 33)
    HeaderVer.BackgroundTransparency = 1
    HeaderVer.Text = VERSION
    HeaderVer.TextColor3 = Theme.Accent
    HeaderVer.Font = Enum.Font.Gotham
    HeaderVer.TextSize = 10
    HeaderVer.TextXAlignment = Enum.TextXAlignment.Left
    HeaderVer.Parent = Header
    
    -- Settings button (S)
    local SettingsBtn = Instance.new("TextButton")
    SettingsBtn.Size = UDim2.new(0, 30, 0, 30)
    SettingsBtn.Position = UDim2.new(1, -70, 0, 12)
    SettingsBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    SettingsBtn.Text = "S"
    SettingsBtn.TextColor3 = Theme.Text
    SettingsBtn.Font = Enum.Font.GothamBold
    SettingsBtn.TextSize = 16
    SettingsBtn.BorderSizePixel = 0
    SettingsBtn.Parent = Header
    
    SettingsBtn.MouseButton1Click:Connect(function()
        CreateSettingsWindow(ScreenGui)
    end)
    
    -- Close button (X)
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 12)
    CloseBtn.BackgroundColor3 = Theme.Primary
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Theme.Text
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 16
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = Header
    
    CloseBtn.MouseButton1Click:Connect(function()
        SpinnerEnabled = false
        FlyEnabled = false
        if FlyBodyGyro then FlyBodyGyro:Destroy() end
        if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
        if FlyAnimTrack then FlyAnimTrack:Stop() FlyAnimTrack:Destroy() end
        createTween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.3)
        wait(0.3)
        ScreenGui:Destroy()
    end)
    
    -- Tabs
    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(0, 130, 1, -55)
    TabFrame.Position = UDim2.new(0, 0, 0, 55)
    TabFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    TabFrame.BorderSizePixel = 0
    TabFrame.Parent = MainFrame
    
    local Tabs = {}
    local TabBtns = {}
    local TabNames = {"Spinner", "Fly"}
    
    for i, name in ipairs(TabNames) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 35)
        btn.Position = UDim2.new(0, 5, 0, 10 + (i-1)*42)
        btn.BackgroundColor3 = i == 1 and Theme.Primary or Color3.fromRGB(50, 50, 70)
        btn.Text = name
        btn.TextColor3 = Theme.Text
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
                b.BackgroundColor3 = j == i and Theme.Primary or Color3.fromRGB(50, 50, 70)
            end
        end)
    end
    
    -- ========== SPINNER PAGE ==========
    local SpinPage = Tabs[1]
    
    local SpinToggle = Instance.new("TextButton")
    SpinToggle.Size = UDim2.new(1, -20, 0, 45)
    SpinToggle.Position = UDim2.new(0, 10, 0, 10)
    SpinToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    SpinToggle.Text = "SPINNER: OFF"
    SpinToggle.TextColor3 = Theme.Text
    SpinToggle.Font = Enum.Font.GothamBold
    SpinToggle.TextSize = 16
    SpinToggle.BorderSizePixel = 0
    SpinToggle.Parent = SpinPage
    
    SpinToggle.MouseButton1Click:Connect(function()
        SpinnerEnabled = not SpinnerEnabled
        SpinToggle.Text = "SPINNER: " .. (SpinnerEnabled and "ON" or "OFF")
        SpinToggle.BackgroundColor3 = SpinnerEnabled and Theme.Green or Color3.fromRGB(200, 50, 50)
        if SpinnerEnabled then startSpinner() end
    end)
    
    local PowerLabel = Instance.new("TextLabel")
    PowerLabel.Size = UDim2.new(1, -20, 0, 22)
    PowerLabel.Position = UDim2.new(0, 10, 0, 65)
    PowerLabel.BackgroundTransparency = 1
    PowerLabel.Text = "Power: " .. SpinPower
    PowerLabel.TextColor3 = Theme.Text
    PowerLabel.Font = Enum.Font.Gotham
    PowerLabel.TextSize = 13
    PowerLabel.TextXAlignment = Enum.TextXAlignment.Left
    PowerLabel.Parent = SpinPage
    
    local PowerUp = Instance.new("TextButton")
    PowerUp.Size = UDim2.new(0, 60, 0, 28)
    PowerUp.Position = UDim2.new(1, -70, 0, 63)
    PowerUp.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    PowerUp.Text = "+50"
    PowerUp.TextColor3 = Theme.Text
    PowerUp.Font = Enum.Font.GothamBold
    PowerUp.TextSize = 11
    PowerUp.BorderSizePixel = 0
    PowerUp.Parent = SpinPage
    
    local PowerDown = Instance.new("TextButton")
    PowerDown.Size = UDim2.new(0, 60, 0, 28)
    PowerDown.Position = UDim2.new(1, -70, 0, 95)
    PowerDown.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    PowerDown.Text = "-50"
    PowerDown.TextColor3 = Theme.Text
    PowerDown.Font = Enum.Font.GothamBold
    PowerDown.TextSize = 11
    PowerDown.BorderSizePixel = 0
    PowerDown.Parent = SpinPage
    
    PowerUp.MouseButton1Click:Connect(function()
        SpinPower = math.min(SpinPower + 50, 1000)
        PowerLabel.Text = "Power: " .. SpinPower
    end)
    
    PowerDown.MouseButton1Click:Connect(function()
        SpinPower = math.max(SpinPower - 50, 50)
        PowerLabel.Text = "Power: " .. SpinPower
    end)
    
    local RadiusLabel = Instance.new("TextLabel")
    RadiusLabel.Size = UDim2.new(1, -20, 0, 22)
    RadiusLabel.Position = UDim2.new(0, 10, 0, 135)
    RadiusLabel.BackgroundTransparency = 1
    RadiusLabel.Text = "Radius: " .. SpinRadius
    RadiusLabel.TextColor3 = Theme.Text
    RadiusLabel.Font = Enum.Font.Gotham
    RadiusLabel.TextSize = 13
    RadiusLabel.TextXAlignment = Enum.TextXAlignment.Left
    RadiusLabel.Parent = SpinPage
    
    local RadiusUp = Instance.new("TextButton")
    RadiusUp.Size = UDim2.new(0, 60, 0, 28)
    RadiusUp.Position = UDim2.new(1, -70, 0, 133)
    RadiusUp.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    RadiusUp.Text = "+10"
    RadiusUp.TextColor3 = Theme.Text
    RadiusUp.Font = Enum.Font.GothamBold
    RadiusUp.TextSize = 11
    RadiusUp.BorderSizePixel = 0
    RadiusUp.Parent = SpinPage
    
    local RadiusDown = Instance.new("TextButton")
    RadiusDown.Size = UDim2.new(0, 60, 0, 28)
    RadiusDown.Position = UDim2.new(1, -70, 0, 165)
    RadiusDown.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    RadiusDown.Text = "-10"
    RadiusDown.TextColor3 = Theme.Text
    RadiusDown.Font = Enum.Font.GothamBold
    RadiusDown.TextSize = 11
    RadiusDown.BorderSizePixel = 0
    RadiusDown.Parent = SpinPage
    
    RadiusUp.MouseButton1Click:Connect(function()
        SpinRadius = math.min(SpinRadius + 10, 300)
        RadiusLabel.Text = "Radius: " .. SpinRadius
    end)
    
    RadiusDown.MouseButton1Click:Connect(function()
        SpinRadius = math.max(SpinRadius - 10, 10)
        RadiusLabel.Text = "Radius: " .. SpinRadius
    end)
    
    local PlayerListLabel = Instance.new("TextLabel")
    PlayerListLabel.Size = UDim2.new(1, -20, 0, 22)
    PlayerListLabel.Position = UDim2.new(0, 10, 0, 205)
    PlayerListLabel.BackgroundTransparency = 1
    PlayerListLabel.Text = "Target (click to select):"
    PlayerListLabel.TextColor3 = Theme.Accent
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
                btn.BackgroundColor3 = SelectedPlayer == plr and Theme.Primary or Color3.fromRGB(60, 60, 80)
                btn.Text = plr.Name
                btn.TextColor3 = Theme.Text
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
        while task.wait(2) do
            pcall(updatePlayerList)
        end
    end)
    
    local ResetTarget = Instance.new("TextButton")
    ResetTarget.Size = UDim2.new(1, -20, 0, 25)
    ResetTarget.Position = UDim2.new(0, 10, 0, 335)
    ResetTarget.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    ResetTarget.Text = "All Players"
    ResetTarget.TextColor3 = Theme.Text
    ResetTarget.Font = Enum.Font.GothamBold
    ResetTarget.TextSize = 11
    ResetTarget.BorderSizePixel = 0
    ResetTarget.Parent = SpinPage
    
    ResetTarget.MouseButton1Click:Connect(function()
        SelectedPlayer = nil
        updatePlayerList()
    end)
    
    -- ========== FLY PAGE ==========
    local FlyPage = Tabs[2]
    
    local FlyToggle = Instance.new("TextButton")
    FlyToggle.Size = UDim2.new(1, -20, 0, 45)
    FlyToggle.Position = UDim2.new(0, 10, 0, 10)
    FlyToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    FlyToggle.Text = "SUPERMAN: OFF"
    FlyToggle.TextColor3 = Theme.Text
    FlyToggle.Font = Enum.Font.GothamBold
    FlyToggle.TextSize = 16
    FlyToggle.BorderSizePixel = 0
    FlyToggle.Parent = FlyPage
    
    FlyToggle.MouseButton1Click:Connect(function()
        FlyEnabled = not FlyEnabled
        FlyToggle.Text = "SUPERMAN: " .. (FlyEnabled and "ON" or "OFF")
        FlyToggle.BackgroundColor3 = FlyEnabled and Theme.Green or Color3.fromRGB(200, 50, 50)
        if FlyEnabled then startSupermanFly() end
    end)
    
    local FlySpeedLabel = Instance.new("TextLabel")
    FlySpeedLabel.Size = UDim2.new(1, -20, 0, 22)
    FlySpeedLabel.Position = UDim2.new(0, 10, 0, 65)
    FlySpeedLabel.BackgroundTransparency = 1
    FlySpeedLabel.Text = "Speed: " .. FlySpeed
    FlySpeedLabel.TextColor3 = Theme.Text
    FlySpeedLabel.Font = Enum.Font.Gotham
    FlySpeedLabel.TextSize = 13
    FlySpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
    FlySpeedLabel.Parent = FlyPage
    
    local FlySpeedUp = Instance.new("TextButton")
    FlySpeedUp.Size = UDim2.new(0, 60, 0, 28)
    FlySpeedUp.Position = UDim2.new(1, -70, 0, 63)
    FlySpeedUp.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    FlySpeedUp.Text = "+25"
    FlySpeedUp.TextColor3 = Theme.Text
    FlySpeedUp.Font = Enum.Font.GothamBold
    FlySpeedUp.TextSize = 11
    FlySpeedUp.BorderSizePixel = 0
    FlySpeedUp.Parent = FlyPage
    
    local FlySpeedDown = Instance.new("TextButton")
    FlySpeedDown.Size = UDim2.new(0, 60, 0, 28)
    FlySpeedDown.Position = UDim2.new(1, -70, 0, 95)
    FlySpeedDown.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    FlySpeedDown.Text = "-25"
    FlySpeedDown.TextColor3 = Theme.Text
    FlySpeedDown.Font = Enum.Font.GothamBold
    FlySpeedDown.TextSize = 11
    FlySpeedDown.BorderSizePixel = 0
    FlySpeedDown.Parent = FlyPage
    
    FlySpeedUp.MouseButton1Click:Connect(function()
        FlySpeed = math.min(FlySpeed + 25, 500)
        FlySpeedLabel.Text = "Speed: " .. FlySpeed
    end)
    
    FlySpeedDown.MouseButton1Click:Connect(function()
        FlySpeed = math.max(FlySpeed - 25, 25)
        FlySpeedLabel.Text = "Speed: " .. FlySpeed
    end)
    
    local FlyInfo = Instance.new("TextLabel")
    FlyInfo.Size = UDim2.new(1, -20, 0, 80)
    FlyInfo.Position = UDim2.new(0, 10, 0, 140)
    FlyInfo.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    FlyInfo.Text = "Controls:\nWASD - Move\nSpace - Up\nShift - Down\n(Fly like Superman!)"
    FlyInfo.TextColor3 = Theme.Text
    FlyInfo.Font = Enum.Font.Gotham
    FlyInfo.TextSize = 11
    FlyInfo.TextXAlignment = Enum.TextXAlignment.Left
    FlyInfo.BorderSizePixel = 0
    FlyInfo.Parent = FlyPage
    
    return MainFrame
end

-- ============================================
-- КНОПКА ОТКРЫТЬ/ЗАКРЫТЬ + БИНД НА ПРАВЫЙ SHIFT
-- ============================================
local function CreateToggleButton()
    local ToggleGui = Instance.new("ScreenGui")
    ToggleGui.Name = "ToggleButton"
    ToggleGui.Parent = CoreGui
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
    ToggleBtn.Position = UDim2.new(0, 10, 0.5, -25)
    ToggleBtn.BackgroundColor3 = Theme.Primary
    ToggleBtn.Text = "E"
    ToggleBtn.TextColor3 = Theme.Text
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextSize = 22
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Parent = ToggleGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(1, 0)
    Corner.Parent = ToggleBtn
    
    local MainGui = nil
    local MainFrame = nil
    local isOpen = false
    
    local function OpenMenu()
        if not isOpen then
            ToggleBtn.Text = "X"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            MainGui = Instance.new("ScreenGui")
            MainGui.Name = "ErrorHub"
            MainGui.Parent = CoreGui
            MainFrame = CreateMainContent(MainGui)
            isOpen = true
        end
    end
    
    local function CloseMenu()
        if isOpen then
            if MainFrame then
                createTween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.3)
                wait(0.3)
            end
            if MainGui then MainGui:Destroy() end
            MainGui = nil
            MainFrame = nil
            isOpen = false
            ToggleBtn.Text = "E"
            ToggleBtn.BackgroundColor3 = Theme.Primary
        end
    end
    
    local function ToggleMenu()
        if isOpen then
            CloseMenu()
        else
            OpenMenu()
        end
    end
    
    -- Кнопка на экране
    ToggleBtn.MouseButton1Click:Connect(ToggleMenu)
    
    -- Бинд на ПРАВЫЙ Shift
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.RightShift then
            ToggleMenu()
        end
    end)
    
    -- Подсказка о бинде
    local HintLabel = Instance.new("TextLabel")
    HintLabel.Size = UDim2.new(0, 150, 0, 20)
    HintLabel.Position = UDim2.new(0, 65, 0.5, -10)
    HintLabel.BackgroundTransparency = 1
    HintLabel.Text = "[Right Shift]"
    HintLabel.TextColor3 = Theme.Accent
    HintLabel.Font = Enum.Font.Gotham
    HintLabel.TextSize = 11
    HintLabel.TextXAlignment = Enum.TextXAlignment.Left
    HintLabel.Parent = ToggleGui
    
    -- Мигание подсказки
    spawn(function()
        while task.wait(0.5) do
            if not HintLabel.Parent then break end
            HintLabel.TextTransparency = isOpen and 1 or 0
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
