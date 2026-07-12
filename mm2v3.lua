--[[
    HoneyLua Clone - Dark Theme GUI for MM2
    Complete UI Clone with all features
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")

-- Variables
local espEnabled = false
local espBoxes = {}
local espLines = {}
local espNames = {}
local espHealth = {}

local aimbotEnabled = false
local aimbotTarget = nil
local aimbotFOV = 100

local silentAimEnabled = false

local triggerbotEnabled = false

local flyEnabled = false
local flySpeed = 50
local flyConnection = nil

local noclipEnabled = false
local noclipConnection = nil

local invisibilityEnabled = false

local speedEnabled = false
local speedAmount = 50

local jumpPowerEnabled = false
local jumpPowerAmount = 100

local infiniteJumpEnabled = false

local walkSpeedEnabled = false
local walkSpeedAmount = 50

local stealGunEnabled = false

local allAnimsEnabled = false

local antiAFKEnabled = false
local antiAFKConnection = nil

local godModeEnabled = false

local espName = true
local espBox = true
local espLine = true
local espHealthBar = true
local espColor = Color3.fromRGB(255, 0, 0)
local espTeamColor = true

local showFPS = false
local fpsLabel = nil

local watermarkEnabled = true

local selectedPreset = "Default"

-- Create Main GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ERROR-HUB"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Frame with HoneyLua style
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 480)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -240)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
mainFrame.BackgroundTransparency = 0.08
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Shadow
local shadow = Instance.new("Frame")
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.Position = UDim2.new(0, -10, 0, -10)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.5
shadow.BorderSizePixel = 0
shadow.Parent = mainFrame

-- Rounded corners
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = mainFrame

-- Gradient for background (red theme like HoneyLua)
local uiGradient = Instance.new("UIGradient")
uiGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 0, 0)),
    ColorSequenceKeypoint.new(0.3, Color3.fromRGB(25, 0, 0)),
    ColorSequenceKeypoint.new(0.7, Color3.fromRGB(15, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 0, 0))
})
uiGradient.Rotation = 90
uiGradient.Parent = mainFrame

-- Title Bar with HoneyLua style
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
titleBar.BackgroundTransparency = 0.2
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

-- Logo
local logo = Instance.new("TextLabel")
logo.Size = UDim2.new(0, 30, 0, 30)
logo.Position = UDim2.new(0, 8, 0, 5)
logo.BackgroundTransparency = 1
logo.Text = "⚠︎"
logo.TextColor3 = Color3.fromRGB(255, 200, 0)
logo.TextScaled = true
logo.Font = Enum.Font.GothamBold
logo.Parent = titleBar

-- Title Text
local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0, 150, 0, 30)
titleText.Position = UDim2.new(0, 45, 0, 5)
titleText.BackgroundTransparency = 1
titleText.Text = "HoneyLua"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextScaled = true
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- Version
local versionText = Instance.new("TextLabel")
versionText.Size = UDim2.new(0, 50, 0, 20)
versionText.Position = UDim2.new(0, 45, 0, 18)
versionText.BackgroundTransparency = 1
versionText.Text = "v2.0.1"
versionText.TextColor3 = Color3.fromRGB(255, 100, 100)
versionText.TextScaled = true
versionText.Font = Enum.Font.Gotham
versionText.TextXAlignment = Enum.TextXAlignment.Left
versionText.Parent = titleBar

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -32, 0, 7)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
closeBtn.BackgroundTransparency = 0.5
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.Gotham
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    screenGui.Enabled = not screenGui.Enabled
end)

-- Minimize Button
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 25, 0, 25)
minBtn.Position = UDim2.new(1, -62, 0, 7)
minBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
minBtn.BackgroundTransparency = 0.5
minBtn.Text = "−"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.TextScaled = true
minBtn.Font = Enum.Font.Gotham
minBtn.BorderSizePixel = 0
minBtn.Parent = titleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(1, 0)
minCorner.Parent = minBtn

local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        mainFrame:TweenSize(UDim2.new(0, 320, 0, 40), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    else
        mainFrame:TweenSize(UDim2.new(0, 320, 0, 480), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    end
end)

-- Drag functionality
local dragging = false
local dragStart = nil
local startPos = nil

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Tab System (like HoneyLua)
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, 0, 0, 35)
tabContainer.Position = UDim2.new(0, 0, 0, 40)
tabContainer.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
tabContainer.BackgroundTransparency = 0.3
tabContainer.BorderSizePixel = 0
tabContainer.Parent = mainFrame

local tabs = {"Combat", "Player", "Visuals", "Misc"}
local activeTab = 1
local tabButtons = {}

for i, tabName in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.25, -1, 1, 0)
    btn.Position = UDim2.new((i-1) * 0.25, 0.5, 0, 0)
    btn.BackgroundColor3 = i == 1 and Color3.fromRGB(60, 0, 0) or Color3.fromRGB(30, 0, 0)
    btn.BackgroundTransparency = i == 1 and 0.2 or 0.5
    btn.Text = tabName
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.Gotham
    btn.BorderSizePixel = 0
    btn.Parent = tabContainer
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    tabButtons[i] = btn
    
    btn.MouseButton1Click:Connect(function()
        activeTab = i
        for j, b in ipairs(tabButtons) do
            b.BackgroundColor3 = j == i and Color3.fromRGB(60, 0, 0) or Color3.fromRGB(30, 0, 0)
            b.BackgroundTransparency = j == i and 0.2 or 0.5
        end
        updateTabContent(i)
    end)
end

-- Tab Content Container
local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -10, 1, -90)
contentContainer.Position = UDim2.new(0, 5, 0, 80)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainFrame

-- Scroll Frame
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, 0)
scrollFrame.Position = UDim2.new(0, 0, 0, 0)
scrollFrame.BackgroundTransparency = 1
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 3
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 0, 0)
scrollFrame.BorderSizePixel = 0
scrollFrame.Parent = contentContainer

-- Function to create toggle button (HoneyLua style)
function createToggle(parent, yPos, text, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 30)
    frame.Position = UDim2.new(0, 5, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 40, 0, 22)
    toggle.Position = UDim2.new(1, -45, 0, 4)
    toggle.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
    toggle.Text = "OFF"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.TextScaled = true
    toggle.Font = Enum.Font.Gotham
    toggle.BorderSizePixel = 0
    toggle.Parent = frame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 4)
    toggleCorner.Parent = toggle
    
    local state = false
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.BackgroundColor3 = state and Color3.fromRGB(100, 0, 0) or Color3.fromRGB(30, 0, 0)
        toggle.Text = state and "ON" or "OFF"
        callback(state)
    end)
    
    return frame
end

-- Function to create slider (HoneyLua style)
function createSlider(parent, yPos, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 45)
    frame.Position = UDim2.new(0, 5, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 0.5, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.3, 0, 0.5, 0)
    valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    valueLabel.TextScaled = true
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, 0, 0, 6)
    slider.Position = UDim2.new(0, 0, 1, -6)
    slider.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
    slider.BorderSizePixel = 0
    slider.Parent = frame
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 3)
    sliderCorner.Parent = slider
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    fill.BorderSizePixel = 0
    fill.Parent = slider
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = fill
    
    local drag = Instance.new("TextButton")
    drag.Size = UDim2.new(0, 12, 0, 12)
    drag.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
    drag.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    drag.Text = ""
    drag.BorderSizePixel = 0
    drag.Parent = slider
    
    local dragCorner = Instance.new("UICorner")
    dragCorner.CornerRadius = UDim.new(1, 0)
    dragCorner.Parent = drag
    
    local draggingSlider = false
    drag.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = true
        end
    end)
    
    drag.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = false
        end
    end)
    
    local function updateSlider(position)
        local relative = math.clamp((position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
        local value = min + (max - min) * relative
        value = math.round(value)
        valueLabel.Text = tostring(value)
        fill.Size = UDim2.new(relative, 0, 1, 0)
        drag.Position = UDim2.new(relative, -6, 0.5, -6)
        callback(value)
    end
    
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateSlider(input.Position)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input.Position)
        end
    end)
    
    return frame
end

-- Function to create dropdown (HoneyLua style)
function createDropdown(parent, yPos, text, options, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 30)
    frame.Position = UDim2.new(0, 5, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.new(0.45, 0, 1, 0)
    dropdown.Position = UDim2.new(0.55, 0, 0, 0)
    dropdown.BackgroundColor3 = Color3.fromRGB(25, 0, 0)
    dropdown.Text = default
    dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdown.TextScaled = true
    dropdown.Font = Enum.Font.Gotham
    dropdown.BorderSizePixel = 0
    dropdown.Parent = frame
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 4)
    dropdownCorner.Parent = dropdown
    
    local isOpen = false
    local dropdownMenu = nil
    
    dropdown.MouseButton1Click:Connect(function()
        if isOpen then
            if dropdownMenu then dropdownMenu:Destroy() end
            isOpen = false
            return
        end
        
        isOpen = true
        dropdownMenu = Instance.new("Frame")
        dropdownMenu.Size = UDim2.new(0.45, 0, 0, #options * 25)
        dropdownMenu.Position = UDim2.new(0.55, 0, 1, 0)
        dropdownMenu.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
        dropdownMenu.BorderSizePixel = 0
        dropdownMenu.Parent = frame
        
        local menuCorner = Instance.new("UICorner")
        menuCorner.CornerRadius = UDim.new(0, 4)
        menuCorner.Parent = dropdownMenu
        
        for i, option in ipairs(options) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 25)
            btn.Position = UDim2.new(0, 0, 0, (i-1) * 25)
            btn.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
            btn.Text = option
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextScaled = true
            btn.Font = Enum.Font.Gotham
            btn.BorderSizePixel = 0
            btn.Parent = dropdownMenu
            
            btn.MouseButton1Click:Connect(function()
                dropdown.Text = option
                callback(option)
                dropdownMenu:Destroy()
                isOpen = false
            end)
        end
    end)
    
    return frame
end

-- Create content for each tab
function updateTabContent(tabIndex)
    -- Clear existing content
    for _, child in pairs(scrollFrame:GetChildren()) do
        child:Destroy()
    end
    
    local yPos = 5
    
    if tabIndex == 1 then -- Combat
        createToggle(scrollFrame, yPos, "Aimbot", function(state)
            aimbotEnabled = state
        end)
        yPos = yPos + 35
        
        createSlider(scrollFrame, yPos, "Aimbot FOV", 10, 360, 100, function(value)
            aimbotFOV = value
        end)
        yPos = yPos + 50
        
        createToggle(scrollFrame, yPos, "Silent Aim", function(state)
            silentAimEnabled = state
        end)
        yPos = yPos + 35
        
        createToggle(scrollFrame, yPos, "Triggerbot", function(state)
            triggerbotEnabled = state
        end)
        yPos = yPos + 35
        
        createToggle(scrollFrame, yPos, "Steal Gun", function(state)
            stealGunEnabled = state
            if state then
                stealGun()
            end
        end)
        yPos = yPos + 35
        
        createToggle(scrollFrame, yPos, "God Mode", function(state)
            godModeEnabled = state
            if state then
                -- God mode logic
                LocalPlayer.Character.Humanoid.Health = 100
            end
        end)
        yPos = yPos + 35
        
    elseif tabIndex == 2 then -- Player
        createToggle(scrollFrame, yPos, "Fly", function(state)
            flyEnabled = state
            if state then
                startFly()
            else
                stopFly()
            end
        end)
        yPos = yPos + 35
        
        createSlider(scrollFrame, yPos, "Fly Speed", 10, 200, 50, function(value)
            flySpeed = value
        end)
        yPos = yPos + 50
        
        createToggle(scrollFrame, yPos, "NoClip", function(state)
            noclipEnabled = state
            if state then
                startNoClip()
            else
                stopNoClip()
            end
        end)
        yPos = yPos + 35
        
        createToggle(scrollFrame, yPos, "Invisibility", function(state)
            invisibilityEnabled = state
            setInvisibility(state)
        end)
        yPos = yPos + 35
        
        createToggle(scrollFrame, yPos, "Speed Hack", function(state)
            speedEnabled = state
        end)
        yPos = yPos + 35
        
        createSlider(scrollFrame, yPos, "Speed Amount", 16, 200, 50, function(value)
            speedAmount = value
            if speedEnabled then
                LocalPlayer.Character.Humanoid.WalkSpeed = value
            end
        end)
        yPos = yPos + 50
        
        createToggle(scrollFrame, yPos, "Jump Power", function(state)
            jumpPowerEnabled = state
        end)
        yPos = yPos + 35
        
        createSlider(scrollFrame, yPos, "Jump Power Amount", 50, 500, 100, function(value)
            jumpPowerAmount = value
            if jumpPowerEnabled then
                LocalPlayer.Character.Humanoid.JumpPower = value
            end
        end)
        yPos = yPos + 50
        
        createToggle(scrollFrame, yPos, "Infinite Jump", function(state)
            infiniteJumpEnabled = state
        end)
        yPos = yPos + 35
        
        createToggle(scrollFrame, yPos, "All Animations", function(state)
            allAnimsEnabled = state
            if state then
                unlockAllAnimations()
            end
        end)
        yPos = yPos + 35
        
    elseif tabIndex == 3 then -- Visuals
        createToggle(scrollFrame, yPos, "ESP", function(state)
            espEnabled = state
            if state then
                setupESP()
            else
                clearESP()
            end
        end)
        yPos = yPos + 35
        
        createToggle(scrollFrame, yPos, "ESP Names", function(state)
            espName = state
            if espEnabled then
                setupESP()
            end
        end)
        yPos = yPos + 35
        
        createToggle(scrollFrame, yPos, "ESP Boxes", function(state)
            espBox = state
            if espEnabled then
                setupESP()
            end
        end)
        yPos = yPos + 35
        
        createToggle(scrollFrame, yPos, "ESP Lines", function(state)
            espLine = state
            if espEnabled then
                setupESP()
            end
        end)
        yPos = yPos + 35
        
        createToggle(scrollFrame, yPos, "ESP Health", function(state)
            espHealthBar = state
            if espEnabled then
                setupESP()
            end
        end)
        yPos = yPos + 35
        
        createToggle(scrollFrame, yPos, "Team Colors", function(state)
            espTeamColor = state
            if espEnabled then
                setupESP()
            end
        end)
        yPos = yPos + 35
        
        createToggle(scrollFrame, yPos, "Show FPS", function(state)
            showFPS = state
            if state then
                createFPSLabel()
            elseif fpsLabel then
                fpsLabel:Destroy()
                fpsLabel = nil
            end
        end)
        yPos = yPos + 35
        
        createToggle(scrollFrame, yPos, "Watermark", function(state)
            watermarkEnabled = state
        end)
        yPos = yPos + 35
        
    elseif tabIndex == 4 then -- Misc
        createToggle(scrollFrame, yPos, "Anti-AFK", function(state)
            antiAFKEnabled = state
            if state then
                startAntiAFK()
            else
                stopAntiAFK()
            end
        end)
        yPos = yPos + 35
        
        createToggle(scrollFrame, yPos, "Auto-Farm", function(state)
            if state then
                -- Auto-farm logic
            end
        end)
        yPos = yPos + 35
        
        createDropdown(scrollFrame, yPos, "Presets", {"Default", "Legit", "Rage", "Ghost"}, "Default", function(value)
            selectedPreset = value
            applyPreset(value)
        end)
        yPos = yPos + 35
        
        -- Keybinds button
        local keybindBtn = Instance.new("TextButton")
        keybindBtn.Size = UDim2.new(1, -10, 0, 30)
        keybindBtn.Position = UDim2.new(0, 5, 0, yPos)
        keybindBtn.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
        keybindBtn.Text = "Keybinds"
        keybindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        keybindBtn.TextScaled = true
        keybindBtn.Font = Enum.Font.Gotham
        keybindBtn.BorderSizePixel = 0
        keybindBtn.Parent = scrollFrame
        
        local keybindCorner = Instance.new("UICorner")
        keybindCorner.CornerRadius = UDim.new(0, 4)
        keybindCorner.Parent = keybindBtn
        
        keybindBtn.MouseButton1Click:Connect(function()
            -- Keybind setup
        end)
        yPos = yPos + 35
        
        -- Rejoin button
        local rejoinBtn = Instance.new("TextButton")
        rejoinBtn.Size = UDim2.new(1, -10, 0, 30)
        rejoinBtn.Position = UDim2.new(0, 5, 0, yPos)
        rejoinBtn.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
        rejoinBtn.Text = "Rejoin"
        rejoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        rejoinBtn.TextScaled = true
        rejoinBtn.Font = Enum.Font.Gotham
        rejoinBtn.BorderSizePixel = 0
        rejoinBtn.Parent = scrollFrame
        
        local rejoinCorner = Instance.new("UICorner")
        rejoinCorner.CornerRadius = UDim.new(0, 4)
        rejoinCorner.Parent = rejoinBtn
        
        rejoinBtn.MouseButton1Click:Connect(function()
            TeleportService:Teleport(game.PlaceId)
        end)
        yPos = yPos + 35
        
        -- Unload button
        local unloadBtn = Instance.new("TextButton")
        unloadBtn.Size = UDim2.new(1, -10, 0, 30)
        unloadBtn.Position = UDim2.new(0, 5, 0, yPos)
        unloadBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
        unloadBtn.Text = "Unload"
        unloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        unloadBtn.TextScaled = true
        unloadBtn.Font = Enum.Font.Gotham
        unloadBtn.BorderSizePixel = 0
        unloadBtn.Parent = scrollFrame
        
        local unloadCorner = Instance.new("UICorner")
        unloadCorner.CornerRadius = UDim.new(0, 4)
        unloadCorner.Parent = unloadBtn
        
        unloadBtn.MouseButton1Click:Connect(function()
            screenGui:Destroy()
        end)
        yPos = yPos + 35
    end
    
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPos + 10)
end

-- Initialize with first tab
updateTabContent(1)

-- ESP Functions (HoneyLua style)
function setupESP()
    clearESP()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                createESPForPlayer(player)
            end
        end
    end
    
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            if espEnabled then
                createESPForPlayer(player)
            end
        end)
    end)
end

function createESPForPlayer(player)
    local character = player.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Adornee = character
    highlight.FillColor = espColor
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = espColor
    highlight.OutlineTransparency = 0
    highlight.Parent = character
    
    -- Name Billboard
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.Adornee = hrp
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = character
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Parent = billboard
    
    -- Role detection
    local roleLabel = Instance.new("TextLabel")
    roleLabel.Size = UDim2.new(1, 0, 0, 20)
    roleLabel.Position = UDim2.new(0, 0, 1, 0)
    roleLabel.BackgroundTransparency = 1
    roleLabel.Text = getPlayerRole(player)
    roleLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    roleLabel.TextScaled = true
    roleLabel.Font = Enum.Font.Gotham
    roleLabel.Parent = billboard
    
    espBoxes[player] = highlight
    espNames[player] = billboard
end

function getPlayerRole(player)
    local character = player.Character
    if character then
        if character:FindFirstChild("Hat") or character:FindFirstChild("SheriffBadge") then
            return "Sheriff"
        end
        if character:FindFirstChild("Knife") or character:FindFirstChild("MurdererKnife") then
            return "Murderer"
        end
    end
    return "Innocent"
end

function clearESP()
    for player, highlight in pairs(espBoxes) do
        highlight:Destroy()
    end
    for player, billboard in pairs(espNames) do
        billboard:Destroy()
    end
    espBoxes = {}
    espNames = {}
end

-- Fly Functions
function startFly()
    stopFly()
    flyConnection = RunService.Heartbeat:Connect(function()
        if flyEnabled and LocalPlayer.Character then
            local char = LocalPlayer.Character
