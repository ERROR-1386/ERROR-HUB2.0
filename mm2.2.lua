--[[
    MM2 Dark GUI with Rounded Corners & Red Gradient
    Features: ESP, Invisibility, Fly, Steal Gun, All Animations, NoClip
    Settings: Gear icon for gradient adjustment & GUI toggle
    Draggable GUI with hide button
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Services for stealing gun
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Variables
local espEnabled = false
local invisibilityEnabled = false
local flyEnabled = false
local flySpeed = 50
local noclipEnabled = false
local animsEnabled = false
local stealGunEnabled = false

local espObjects = {}
local invisibilityConnections = {}
local flyConnection = nil
local noclipConnection = nil

-- Create Main GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MM2DarkGUI"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 420)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BackgroundTransparency = 0.1
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Rounded corners using UICorner
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = mainFrame

-- Gradient for background
local uiGradient = Instance.new("UIGradient")
uiGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 0, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 0, 0))
})
uiGradient.Rotation = 90
uiGradient.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "MM2 DARK"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Drag functionality
local dragging = false
local dragStart = nil
local startPos = nil

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

mainFrame.InputEnded:Connect(function(input)
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

-- Hide/Show Button
local hideButton = Instance.new("ImageButton")
hideButton.Size = UDim2.new(0, 30, 0, 30)
hideButton.Position = UDim2.new(1, -35, 0, 5)
hideButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
hideButton.BackgroundTransparency = 0.3
hideButton.Image = "rbxassetid://6031090156" -- Hamburger icon
hideButton.Parent = mainFrame

local hideCorner = Instance.new("UICorner")
hideCorner.CornerRadius = UDim.new(1, 0)
hideCorner.Parent = hideButton

local guiVisible = true
hideButton.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    mainFrame.Visible = guiVisible
end)

-- Settings Button (Gear)
local settingsButton = Instance.new("ImageButton")
settingsButton.Size = UDim2.new(0, 30, 0, 30)
settingsButton.Position = UDim2.new(1, -75, 0, 5)
settingsButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
settingsButton.BackgroundTransparency = 0.3
settingsButton.Image = "rbxassetid://6031090156" -- Gear icon
settingsButton.Parent = mainFrame

local settingsCorner = Instance.new("UICorner")
settingsCorner.CornerRadius = UDim.new(1, 0)
settingsCorner.Parent = settingsButton

-- Settings Frame
local settingsFrame = Instance.new("Frame")
settingsFrame.Size = UDim2.new(0, 250, 0, 180)
settingsFrame.Position = UDim2.new(0, 25, 0, 35)
settingsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
settingsFrame.BackgroundTransparency = 0.2
settingsFrame.Visible = false
settingsFrame.Parent = mainFrame

local settingsCorner2 = Instance.new("UICorner")
settingsCorner2.CornerRadius = UDim.new(0, 12)
settingsCorner2.Parent = settingsFrame

-- Gradient slider
local gradientLabel = Instance.new("TextLabel")
gradientLabel.Size = UDim2.new(1, 0, 0, 25)
gradientLabel.Position = UDim2.new(0, 10, 0, 10)
gradientLabel.BackgroundTransparency = 1
gradientLabel.Text = "Gradient Rotation: 90"
gradientLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
gradientLabel.TextScaled = true
gradientLabel.Font = Enum.Font.Gotham
gradientLabel.Parent = settingsFrame

local gradientSlider = Instance.new("TextBox")
gradientSlider.Size = UDim2.new(0, 200, 0, 25)
gradientSlider.Position = UDim2.new(0, 10, 0, 40)
gradientSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
gradientSlider.Text = "90"
gradientSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
gradientSlider.Font = Enum.Font.Gotham
gradientSlider.Parent = settingsFrame

local gradientCorner = Instance.new("UICorner")
gradientCorner.CornerRadius = UDim.new(0, 6)
gradientCorner.Parent = gradientSlider

gradientSlider.FocusLost:Connect(function()
    local val = tonumber(gradientSlider.Text)
    if val and val >= 0 and val <= 360 then
        uiGradient.Rotation = val
        gradientLabel.Text = "Gradient Rotation: " .. val
    end
end)

-- Toggle GUI button in settings
local toggleGUIButton = Instance.new("TextButton")
toggleGUIButton.Size = UDim2.new(0, 200, 0, 30)
toggleGUIButton.Position = UDim2.new(0, 10, 0, 80)
toggleGUIButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleGUIButton.Text = "Hide GUI"
toggleGUIButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleGUIButton.Font = Enum.Font.Gotham
toggleGUIButton.Parent = settingsFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 6)
toggleCorner.Parent = toggleGUIButton

toggleGUIButton.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    mainFrame.Visible = guiVisible
    toggleGUIButton.Text = guiVisible and "Hide GUI" or "Show GUI"
end)

settingsButton.MouseButton1Click:Connect(function()
    settingsFrame.Visible = not settingsFrame.Visible
end)

-- Scroll Frame for buttons
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -10, 1, -40)
scrollFrame.Position = UDim2.new(0, 5, 0, 35)
scrollFrame.BackgroundTransparency = 1
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 350)
scrollFrame.ScrollBarThickness = 4
scrollFrame.Parent = mainFrame

local buttonY = 0
local buttonSpacing = 45

-- Function to create toggle buttons
function createToggleButton(text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 270, 0, 35)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.BackgroundTransparency = 0.5
    btn.Text = text .. " [OFF]"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextScaled = true
    btn.Parent = scrollFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    local isOn = false
    btn.MouseButton1Click:Connect(function()
        isOn = not isOn
        btn.Text = text .. (isOn and " [ON]" or " [OFF]")
        btn.BackgroundColor3 = isOn and Color3.fromRGB(100, 0, 0) or Color3.fromRGB(40, 40, 40)
        callback(isOn)
    end)
    
    return btn
end

-- 1. ESP Button
local espBtn = createToggleButton("ESP", buttonY, function(state)
    espEnabled = state
    if state then
        setupESP()
    else
        clearESP()
    end
end)
buttonY = buttonY + buttonSpacing

-- 2. Invisibility Button
local invisBtn = createToggleButton("Invisibility", buttonY, function(state)
    invisibilityEnabled = state
    if state then
        setInvisibility(true)
    else
        setInvisibility(false)
    end
end)
buttonY = buttonY + buttonSpacing

-- 3. Fly Button
local flyBtn = createToggleButton("Fly", buttonY, function(state)
    flyEnabled = state
    if state then
        startFly()
    else
        stopFly()
    end
end)
buttonY = buttonY + buttonSpacing

-- 4. Steal Gun Button
local stealBtn = createToggleButton("Steal Gun", buttonY, function(state)
    stealGunEnabled = state
    if state then
        stealGun()
    end
end)
buttonY = buttonY + buttonSpacing

-- 5. All Animations Button
local animBtn = createToggleButton("All Animations", buttonY, function(state)
    animsEnabled = state
    if state then
        unlockAllAnimations()
    end
end)
buttonY = buttonY + buttonSpacing

-- 6. NoClip Button
local noclipBtn = createToggleButton("NoClip", buttonY, function(state)
    noclipEnabled = state
    if state then
        startNoClip()
    else
        stopNoClip()
    end
end)
buttonY = buttonY + buttonSpacing

scrollFrame.CanvasSize = UDim2.new(0, 0, 0, buttonY + 10)

-- ESP Functions
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
    
    -- Create outline effect using highlight
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineTransparency = 0
    highlight.Parent = character
    
    -- Create name display
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
    
    -- Role detection (simplified)
    local roleLabel = Instance.new("TextLabel")
    roleLabel.Size = UDim2.new(1, 0, 0, 20)
    roleLabel.Position = UDim2.new(0, 0, 1, 0)
    roleLabel.BackgroundTransparency = 1
    roleLabel.Text = getPlayerRole(player)
    roleLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    roleLabel.TextScaled = true
    roleLabel.Font = Enum.Font.Gotham
    roleLabel.Parent = billboard
    
    espObjects[player] = {
        highlight = highlight,
        billboard = billboard,
        nameLabel = nameLabel,
        roleLabel = roleLabel
    }
end

function getPlayerRole(player)
    -- Simple role detection based on character appearance
    local character = player.Character
    if character then
        -- Check for sheriff hat or badge
        if character:FindFirstChild("Hat") or character:FindFirstChild("SheriffBadge") then
            return "Sheriff"
        end
        -- Check for murderer knife
        if character:FindFirstChild("Knife") or character:FindFirstChild("MurdererKnife") then
            return "Murderer"
        end
    end
    return "Innocent"
end

function clearESP()
    for player, data in pairs(espObjects) do
        if data.highlight then data.highlight:Destroy() end
        if data.billboard then data.billboard:Destroy() end
    end
    espObjects = {}
end

-- Invisibility Functions
function setInvisibility(state)
    local character = LocalPlayer.Character
    if not character then return end
    
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            if state then
                part.LocalTransparencyModifier = 0.95
                part.CanCollide = false
            else
                part.LocalTransparencyModifier = 0
                part.CanCollide = true
            end
        end
    end
    
    -- Make character invisible to other players
    if state then
        local highlight = Instance.new("Highlight")
        highlight.FillTransparency = 0.99
        highlight.OutlineTransparency = 0.99
        highlight.Parent = character
        invisibilityConnections[character] = highlight
    else
        if invisibilityConnections[character] then
            invisibilityConnections[character]:Destroy()
            invisibilityConnections[character] = nil
        end
    end
end

-- Fly Functions
function startFly()
    stopFly()
    flyConnection = RunService.Heartbeat:Connect(function()
        if flyEnabled and LocalPlayer.Character then
            local char = LocalPlayer.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local humanoid = char:FindFirstChild("Humanoid")
            if hrp and humanoid then
                -- Enable platform stand for flying effect
                humanoid.PlatformStand = true
                
                -- Get movement input
                local moveDirection = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveDirection = moveDirection + hrp.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDirection = moveDirection - hrp.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDirection = moveDirection - hrp.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDirection = moveDirection + hrp.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveDirection = moveDirection + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    moveDirection = moveDirection - Vector3.new(0, 1, 0)
                end
                
                if moveDirection.Magnitude > 0 then
                    moveDirection = moveDirection.Unit * flySpeed
                end
                
                -- Apply velocity
                hrp.Velocity = moveDirection
                
                -- Keep character upright
                hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, hrp.Orientation.Y, 0)
            end
        end
    end)
end

function stopFly()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
end

-- Steal Gun Function
function stealGun()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character then
                -- Look for gun/tool in player's character
                for _, child in pairs(character:GetDescendants()) do
                    if child:IsA("Tool") and (child.Name:lower():find("gun") or child.Name:lower():find("pistol") or child.Name:lower():find("sheriff")) then
                        -- Move tool to local player
                        child.Parent = LocalPlayer.Character
                        LocalPlayer.Character:FindFirstChild("Humanoid"):EquipTool(child)
                        return
                    end
                end
            end
        end
    end
end

-- All Animations Function
function unlockAllAnimations()
    local player = LocalPlayer
    local animator = player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid:FindFirstChild("Animator")
    
    if animator then
        -- Load all animations from replicated storage
        local animations = ReplicatedStorage:FindFirstChild("Animations")
        if animations then
            for _, anim in pairs(animations:GetChildren()) do
                if anim:IsA("Animation") then
                    local track = animator:LoadAnimation(anim)
                    if track then
                        track:Play()
                    end
                end
            end
        end
        
        -- Also try to load from other sources
        local anims = {}
        for _, child in pairs(game:GetDescendants()) do
            if child:IsA("Animation") and child.Parent ~= animator then
                local track = animator:LoadAnimation(child)
                if track then
                    table.insert(anims, track)
                end
            end
        end
        
        -- Play all animations
        for _, track in pairs(anims) do
            track:Play()
        end
    end
end

-- NoClip Functions
function startNoClip()
    stopNoClip()
    noclipConnection = RunService.Heartbeat:Connect(function()
        if noclipEnabled and LocalPlayer.Character then
            local char = LocalPlayer.Character
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

function stopNoClip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    if LocalPlayer.Character then
        local char = LocalPlayer.Character
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- Mobile support for fly
UserInputService.TouchEnabled:Connect(function()
    -- Mobile fly controls
    local touchStarted = false
    local touchPos = nil
    
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.UserInputType == Enum.UserInputType.Touch then
            touchStarted = true
            touchPos = input.Position
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            touchStarted = false
            touchPos = nil
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if not flyEnabled then return end
        if input.UserInputType == Enum.UserInputType.Touch and touchStarted then
            local delta = input.Position - touchPos
            -- Use delta for mobile fly control
            if LocalPlayer.Character then
                local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local move = Vector3.new(delta.X * 0.1, 0, delta.Y * 0.1)
                    hrp.Velocity = move * 10
                end
            end
        end
    end)
end)

print("MM2 Dark GUI Loaded Successfully!")
