--[[
    BABFT Script - Dark GUI with Green Gradient
    Features: Auto Farm, God Mode, Anti-AFK, Teleport, NoClip, Block Spawn
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local rs = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer

-- ═══════════════════════════════════════════════════
-- КОНФИГ
-- ═══════════════════════════════════════════════════

local donateBlocks = {
    "HarpoonDragon", "MegaThruster", "EggCannon",
    "BackWheelCookie", "FrontWheelCookie", "HarpoonDuel",
    "CannonEgg", "DragonEgg", "Bread", "TrophyMaster", "WinterThruster"
}

local buildingParts = rs:WaitForChild("BuildingParts")
local ourInjectedItems = {}

-- ═══════════════════════════════════════════════════
-- ХУК НА МОЛОТОК
-- ═══════════════════════════════════════════════════

local function makeFakeResponse(blockName, cframe)
    local model = buildingParts:FindFirstChild(blockName)
    if not model then return nil end
    local clone = model:Clone()
    clone.Parent = workspace
    if clone:IsA("Model") then
        pcall(function() if cframe then clone:PivotTo(cframe) end end)
        return clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart")
    elseif clone:IsA("BasePart") then
        if cframe then clone.CFrame = cframe end
        return clone
    end
    return clone
end

local function isDonate(name)
    for _, d in ipairs(donateBlocks) do
        if d == name then return true end
    end
    return false
end

local function giveToData(blockName, amount)
    local data = lp:FindFirstChild("Data")
    if not data then return false end
    
    local existing = data:FindFirstChild(blockName)
    if existing then
        existing.Value = amount
    else
        local val = Instance.new("IntValue")
        val.Name = blockName
        val.Value = amount
        val.Parent = data
    end
    ourInjectedItems[blockName] = true
    return true
end

local function clearOurInjections()
    local data = lp:FindFirstChild("Data")
    if not data then return 0 end
    
    local count = 0
    for name, _ in pairs(ourInjectedItems) do
        local existing = data:FindFirstChild(name)
        if existing then
            existing:Destroy()
            count = count + 1
        end
    end
    ourInjectedItems = {}
    return count
end

local hookInstalled = false
local function setupHook()
    if hookInstalled then return true end
    local buildTool = lp.Backpack:FindFirstChild("BuildingTool") 
                   or (lp.Character and lp.Character:FindFirstChild("BuildingTool"))
    if not buildTool then return false end
    local rf = buildTool:FindFirstChild("RF")
    if not rf then return false end
    
    local oldNC
    oldNC = hookmetamethod(game, "__namecall", newcclosure(function(self, a1, a2, a3, a4, a5, a6, a7, a8)
        if typeof(self) ~= "Instance" then 
            return oldNC(self, a1, a2, a3, a4, a5, a6, a7, a8) 
        end
        if getnamecallmethod() == "InvokeServer" and self == rf then
            local realResult = oldNC(self, a1, a2, a3, a4, a5, a6, a7, a8)
            if isDonate(a1) and realResult == nil then
                local fake = makeFakeResponse(a1, a6)
                if fake then return fake end
            end
            return realResult
        end
        return oldNC(self, a1, a2, a3, a4, a5, a6, a7, a8)
    end))
    
    hookInstalled = true
    return true
end

-- ═══════════════════════════════════════════════════
-- АВТОФАРМ С РЕЖИМОМ БОГА И МИКРО-ШАГАМИ
-- ═══════════════════════════════════════════════════

local autoFarmEnabled = false
local teleportEnabled = false
local currentPlatform = nil
local godModeEnabled = false
local antiAFKEnabled = false

-- Режим бога
local function enableGodMode()
    local char = lp.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    pcall(function()
        hum.BreakJointsOnDeath = false
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, true)
        hum.MaxHealth = math.huge
        hum.Health = math.huge
        hum.WalkSpeed = 50
        hum.JumpPower = 100
    end)
end

-- Микро-шаги для анти-АФК
local function antiAFKStep()
    if not antiAFKEnabled then return end
    local char = lp.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    -- Делаем микро-движения
    local randomDir = Vector3.new(
        math.random(-5, 5) / 10,
        0,
        math.random(-5, 5) / 10
    )
    char:SetPrimaryPartCFrame(char.PrimaryPart.CFrame + randomDir)
    hum:MoveTo(char.PrimaryPart.Position + Vector3.new(
        math.random(-3, 3),
        0,
        math.random(-3, 3)
    ))
end

-- Анти-чит киллер
local function killAnticheat()
    local char = lp.Character
    if not char then return end
    for _, name in ipairs({"KillInVoidScript", "ZoneLockLS", "WaterDetector", "FloorMaterialSoundsLS"}) do
        local s = char:FindFirstChild(name)
        if s then pcall(function() s.Disabled = true; s:Destroy() end) end
    end
end

local function noCollide()
    local char = lp.Character
    if not char then return end
    for _, p in pairs(char:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
end

local function getStages()
    local stages = {}
    local boatStages = workspace:FindFirstChild("BoatStages")
    if not boatStages then return stages end
    local normal = boatStages:FindFirstChild("NormalStages")
    if not normal then return stages end
    
    for _, child in pairs(normal:GetChildren()) do
        table.insert(stages, child)
    end
    
    table.sort(stages, function(a, b)
        local na = tonumber(a.Name:match("%d+")) or 999
        local nb = tonumber(b.Name:match("%d+")) or 999
        return na < nb
    end)
    
    return stages
end

local function getStageCenter(stage)
    if not stage then return nil end
    if stage:IsA("Model") then
        local ok, cf = pcall(function() return stage:GetPivot() end)
        if ok and cf then return cf.Position end
    end
    local total = Vector3.new(0, 0, 0)
    local count = 0
    for _, p in pairs(stage:GetDescendants()) do
        if p:IsA("BasePart") then
            total = total + p.Position
            count = count + 1
        end
    end
    if count > 0 then return total / count end
    return nil
end

local function getTreasurePos()
    local paths = {
        {"BoatStages", "NormalStages", "TheEnd", "GoldenChest", "Part"},
        {"Stages", "TheEnd", "GoldenChest"},
    }
    for _, path in ipairs(paths) do
        local current = workspace
        for _, name in ipairs(path) do
            current = current and current:FindFirstChild(name)
            if not current then break end
        end
        if current and current:IsA("BasePart") then return current.Position end
    end
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "GoldenChest" then
            local p = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart")
            if p then return p.Position end
        end
    end
    return nil
end

-- Создание платформы с зеленым свечением
local function createPlatform()
    if currentPlatform then currentPlatform:Destroy() end
    
    local char = lp.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local plat = Instance.new("Part")
    plat.Name = "BABFTPlatform"
    plat.Size = Vector3.new(25, 2, 25)
    plat.Material = Enum.Material.Neon
    plat.Color = Color3.fromRGB(0, 200, 100)
    plat.Anchored = true
    plat.CanCollide = true
    plat.TopSurface = Enum.SurfaceType.Smooth
    plat.BottomSurface = Enum.SurfaceType.Smooth
    plat.CFrame = CFrame.new(hrp.Position - Vector3.new(0, 3.5, 0))
    plat.Parent = workspace
    
    hrp.CFrame = CFrame.new(plat.Position + Vector3.new(0, 4, 0))
    
    local bv = Instance.new("BodyVelocity")
    bv.Name = "BABFTAntiGrav"
    bv.MaxForce = Vector3.new(0, math.huge, 0)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = hrp
    
    -- Анимация свечения
    task.spawn(function()
        while plat.Parent do
            for _, col in ipairs({
                Color3.fromRGB(0, 200, 50),
                Color3.fromRGB(0, 255, 100),
                Color3.fromRGB(0, 150, 100),
            }) do
                if not plat.Parent then break end
                local t = TweenService:Create(plat, TweenInfo.new(1, Enum.EasingStyle.Sine), {Color = col})
                t:Play()
                t.Completed:Wait()
            end
        end
    end)
    
    currentPlatform = plat
    return plat
end

local function destroyPlatform()
    if currentPlatform then 
        currentPlatform:Destroy() 
        currentPlatform = nil
    end

    local char = lp.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bv = hrp:FindFirstChild("BABFTAntiGrav")
            if bv then bv:Destroy() end
        end
    end
end

local function movePlatformTo(targetPos, duration)
    if not currentPlatform then return end
    local char = lp.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local startPos = currentPlatform.Position
    local endPos = targetPos + Vector3.new(0, 5, 0)
    
    local startTime = tick()
    while tick() - startTime < duration do
        if not autoFarmEnabled or not currentPlatform then break end
        if not char.Parent or not char:FindFirstChild("HumanoidRootPart") then break end
        
        local alpha = (tick() - startTime) / duration
        alpha = math.min(alpha, 1)
        alpha = alpha < 0.5 and 2 * alpha * alpha or 1 - math.pow(-2 * alpha + 2, 2) / 2
        
        local newPos = startPos:Lerp(endPos, alpha)
        currentPlatform.Position = newPos
        hrp.CFrame = CFrame.new(newPos + Vector3.new(0, 4, 0)) * CFrame.Angles(0, hrp.Orientation.Y * math.pi/180, 0)
        
        -- Микро-шаг для анти-АФК во время движения
        if antiAFKEnabled then
            antiAFKStep()
        end
        
        RunService.Heartbeat:Wait()
    end
    
    if currentPlatform then currentPlatform.Position = endPos end
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(endPos + Vector3.new(0, 4, 0))
    end
end

local function runPlatformFarm()
    local char = lp.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    killAnticheat()
    
    -- Включаем режим бога если активен
    if godModeEnabled then
        enableGodMode()
    end
    
    pcall(function()
        hum.BreakJointsOnDeath = false
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, true)
        hum.MaxHealth = math.huge
        hum.Health = math.huge
    end)
    
    local stages = getStages()
    if #stages == 0 then 
        print("BABFT: Стадии не найдены!")
        return 
    end
    print("BABFT: Найдено стадий: " .. #stages)
    
    local flightHeight = 100
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local currentXZ = Vector3.new(hrp.Position.X, 0, hrp.Position.Z)
    hrp.CFrame = CFrame.new(currentXZ + Vector3.new(0, flightHeight, 0))
    task.wait(0.3)
    
    if currentPlatform then currentPlatform:Destroy() end
    
    local plat = Instance.new("Part")
    plat.Name = "BABFTPlatform"
    plat.Size = Vector3.new(25, 2, 25)
    plat.Material = Enum.Material.Neon
    plat.Color = Color3.fromRGB(0, 200, 100)
    plat.Anchored = true
    plat.CanCollide = true
    plat.TopSurface = Enum.SurfaceType.Smooth
    plat.BottomSurface = Enum.SurfaceType.Smooth
    plat.CFrame = CFrame.new(hrp.Position - Vector3.new(0, 4, 0))
    plat.Parent = workspace
    
    hrp.CFrame = CFrame.new(plat.Position + Vector3.new(0, 4, 0))
    
    local bv = hrp:FindFirstChild("BABFTAntiGrav")
    if bv then bv:Destroy() end
    bv = Instance.new("BodyVelocity")
    bv.Name = "BABFTAntiGrav"
    bv.MaxForce = Vector3.new(0, math.huge, 0)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = hrp
    
    task.spawn(function()
        while plat.Parent do
            for _, col in ipairs({
                Color3.fromRGB(0, 200, 50),
                Color3.fromRGB(0, 255, 100),
                Color3.fromRGB(0, 150, 100),
            }) do
                if not plat.Parent then break end
                local t = TweenService:Create(plat, TweenInfo.new(1, Enum.EasingStyle.Sine), {Color = col})
                t:Play()
                t.Completed:Wait()
            end
        end
    end)
    
    currentPlatform = plat
    task.wait(0.5)
    killAnticheat()
    
    local function flyTo(targetXZ, duration)
        if not currentPlatform then return end
        local startPos = currentPlatform.Position
        local endPos = Vector3.new(targetXZ.X, flightHeight - 4, targetXZ.Z)
        
        local startTime = tick()
        while tick() - startTime < duration do
            if not autoFarmEnabled or not currentPlatform then break end
            local c = lp.Character
            if not c then break end
            local h = c:FindFirstChild("HumanoidRootPart")
            if not h then break end
            
            local alpha = (tick() - startTime) / duration
            alpha = math.min(alpha, 1)
            alpha = alpha < 0.5 and 2 * alpha * alpha or 1 - math.pow(-2 * alpha + 2, 2) / 2
            
            local newPos = startPos:Lerp(endPos, alpha)
            currentPlatform.Position = newPos
            h.CFrame = CFrame.new(newPos + Vector3.new(0, 4, 0))
            
            -- Микро-шаг для анти-АФК во время полета
            if antiAFKEnabled then
                antiAFKStep()
            end
            
            RunService.Heartbeat:Wait()
        end
        
        if currentPlatform then currentPlatform.Position = endPos end
        local c = lp.Character
        if c and c:FindFirstChild("HumanoidRootPart") then
            c.HumanoidRootPart.CFrame = CFrame.new(endPos + Vector3.new(0, 4, 0))
        end
    end
    
    for i, stage in ipairs(stages) do
        if not autoFarmEnabled then break end
        local pos = getStageCenter(stage)
        if pos then
            print("BABFT: Лечу к стадии " .. stage.Name)
            flyTo(pos, 2.5)
            task.wait(1.2)
            killAnticheat()
            
            -- Анти-АФК микро-движение между стадиями
            if antiAFKEnabled then
                for _ = 1, 3 do
                    antiAFKStep()
                    task.wait(0.5)
                end
            end
        end
    end
    
    if autoFarmEnabled then
        local chestPos = getTreasurePos()
        if chestPos then
            flyTo(chestPos, 2.5)
            task.wait(0.5)
            
            -- Анти-АФК у сундука
            if antiAFKEnabled then
                for _ = 1, 5 do
                    antiAFKStep()
                    task.wait(0.3)
                end
            end
            
            if currentPlatform then
                local startY = currentPlatform.Position.Y
                local endY = chestPos.Y + 2
                local dropDuration = 2
                local dropStart = tick()
                
                while tick() - dropStart < dropDuration do
                    if not autoFarmEnabled then break end
                    local c = lp.Character
                    if not c then break end
                    local h = c:FindFirstChild("HumanoidRootPart")
                    if not h then break end
                    
                    local alpha = (tick() - dropStart) / dropDuration
                    alpha = math.min(alpha, 1)
                    local newY = startY + (endY - startY) * alpha
                    local newPos = Vector3.new(chestPos.X, newY, chestPos.Z)
                    currentPlatform.Position = newPos
                    h.CFrame = CFrame.new(newPos + Vector3.new(0, 4, 0))
                    
                    if antiAFKEnabled then
                        antiAFKStep()
                    end
                    
                    RunService.Heartbeat:Wait()
                end
                task.wait(0.5)
            end
        end
    end
    
    destroyPlatform()
end

-- Основной цикл фарма
task.spawn(function()
    while true do
        task.wait(1)
        if autoFarmEnabled then
            pcall(runPlatformFarm)
            task.wait(3)
            if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then
                lp.CharacterAdded:Wait()
                task.wait(3) 
            end
        end
    end
end)

-- Teleport Loop
task.spawn(function()
    while true do
        task.wait(0.1)
        if teleportEnabled then
            pcall(function()
                noCollide()
                local char = lp.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                local pos = getTreasurePos()
                if pos then
                    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 20, -10))
                    if antiAFKEnabled then
                        antiAFKStep()
                    end
                end
            end)
        end
    end
end)

-- Одноразовый ТП
local function teleportToTreasure()
    local char = lp.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    killAnticheat()
    noCollide()
    local pos = getTreasurePos()
    if pos then
        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 20, -10))
        return true
    end
    return false
end

-- ═══════════════════════════════════════════════════
-- GUI - Серовато-тёмный с зеленым градиентом
-- ═══════════════════════════════════════════════════

local function createGUI()
    local old = game:GetService("CoreGui"):FindFirstChild("BABFTUI")
    if old then old:Destroy() end
 
    local gui = Instance.new("ScreenGui")
    gui.Name = "BABFTUI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = game:GetService("CoreGui")
    
    -- Эффект размытия
    local blur = Instance.new("BlurEffect")
    blur.Size = 0
    blur.Parent = Lighting
    local blurIn = TweenService:Create(blur, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {Size = 18})
    blurIn:Play()
    
    -- Главное окно - серовато-темное с зеленым градиентом
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 0, 0, 0)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = Color3.fromRGB(40, 45, 50)
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.BackgroundTransparency = 1
    main.ClipsDescendants = true
    main.Parent = gui
 
    -- Скругленные углы
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = main
 
    -- Зеленый градиент по краям
    local uiGradient = Instance.new("UIGradient")
    uiGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 180, 50)),
        ColorSequenceKeypoint.new(0.3, Color3.fromRGB(0, 120, 30)),
        ColorSequenceKeypoint.new(0.7, Color3.fromRGB(0, 80, 20)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 180, 50))
    })
    uiGradient.Rotation = 45
    uiGradient.Parent = main
    
    -- Обводка
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 200, 80)
    stroke.Thickness = 2
    stroke.Parent = main
    
    -- Фоновый слой
    local bgContainer = Instance.new("Frame")
    bgContainer.Size = UDim2.new(1, 0, 1, 0)
    bgContainer.BackgroundTransparency = 1
    bgContainer.ZIndex = 0
    bgContainer.Parent = main
    
    -- Зеленые частицы на фоне
    local greenColors = {
        Color3.fromRGB(0, 200, 50),
        Color3.fromRGB(0, 150, 80),
        Color3.fromRGB(0, 100, 50),
        Color3.fromRGB(0, 255, 100),
    }
    
    for i = 1, 6 do
        local blob = Instance.new("Frame")
        blob.Size = UDim2.new(0, math.random(80, 150), 0, math.random(80, 150))
        blob.Position = UDim2.new(math.random() * 0.8, 0, math.random() * 0.8, 0)
        blob.BackgroundColor3 = greenColors[math.random(1, #greenColors)]
        blob.BackgroundTransparency = 0.3
        blob.BorderSizePixel = 0
        blob.ZIndex = 0
        blob.Parent = bgContainer
        local blobCorner = Instance.new("UICorner")
        blobCorner.CornerRadius = UDim.new(1, 0)
        blobCorner.Parent = blob
        
        task.spawn(function()
            while blob.Parent do
                local newPos = UDim2.new(math.random() * 0.8 - 0.1, 0, math.random() * 0.8 - 0.1, 0)
                local newColor = greenColors[math.random(1, #greenColors)]
                local dur = math.random(4, 8)
                local moveTween = TweenService:Create(blob, 
                    TweenInfo.new(dur, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                    {Position = newPos, BackgroundColor3 = newColor})
                moveTween:Play()
                moveTween.Completed:Wait()
            end
        end)
    end
    
    -- Затемнение фона
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(30, 35, 40)
    overlay.BackgroundTransparency = 0.3
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 1
    overlay.Parent = main
    
    -- Анимация появления
    local appearTween = TweenService:Create(main, 
        TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 440, 0, 460), BackgroundTransparency = 0})
    appearTween:Play()
    
    task.delay(0.7, function()
        local blurOut = TweenService:Create(blur, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Size = 0})
        blurOut:Play()
        task.wait(0.5)
        blur:Destroy()
    end)
    
    -- Анимация обводки
    task.spawn(function()
        while stroke.Parent do
            for _, col in ipairs({
                Color3.fromRGB(0, 200, 50),
                Color3.fromRGB(0, 255, 100),
                Color3.fromRGB(0, 150, 80),
            }) do
                local t = TweenService:Create(stroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Color = col})
                t:Play()
                t.Completed:Wait()
                if not stroke.Parent then break end
            end
        end
    end)
 
    -- Заголовок
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 48)
    titleBar.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = 2
    titleBar.Parent = main
    
    local titleBarCorner = Instance.new("UICorner")
    titleBarCorner.CornerRadius = UDim.new(0, 15)
    titleBarCorner.Parent = titleBar
    
    local titleBarFix = Instance.new("Frame")
    titleBarFix.Size = UDim2.new(1, 0, 0, 15)
    titleBarFix.Position = UDim2.new(0, 0, 1, -15)
    titleBarFix.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
    titleBarFix.BorderSizePixel = 0
    titleBarFix.ZIndex = 2
    titleBarFix.Parent = titleBar
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -80, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🌿 BABFT"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextYAlignment = Enum.TextYAlignment.Center
    title.ZIndex = 3
    title.Parent = titleBar
    
    -- Анимация заголовка
    task.spawn(function()
        while titleBar.Parent do
            for _, col in ipairs({
                Color3.fromRGB(0, 150, 50),
                Color3.fromRGB(0, 200, 80),
                Color3.fromRGB(0, 120, 40),
            }) do
                local t = TweenService:Create(titleBar, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundColor3 = col})
                local t2 = TweenService:Create(titleBarFix, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundColor3 = col})
                t:Play() t2:Play()
                t.Completed:Wait()
                if not titleBar.Parent then break end
            end
        end
    end)
 
    -- Кнопка закрытия
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -38, 0, 9)
    closeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 20
    closeBtn.ZIndex = 3
    closeBtn.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 5)
    closeCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function() 
        local closeTween = TweenService:Create(main, 
            TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1})
        closeTween:Play()
        closeTween.Completed:Connect(function() gui:Destroy() end)
    end)
    
    -- Ресайз
    local resize = Instance.new("TextButton")
    resize.Size = UDim2.new(0, 20, 0, 20)
    resize.Position = UDim2.new(1, -20, 1, -20)
    resize.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
    resize.BorderSizePixel = 0
    resize.Text = "◢"
    resize.TextColor3 = Color3.new(1, 1, 1)
    resize.Font = Enum.Font.GothamBold
    resize.TextSize = 14
    resize.AutoButtonColor = false
    resize.ZIndex = 5
    resize.Parent = main
    
    local resizeCorner = Instance.new("UICorner")
    resizeCorner.CornerRadius = UDim.new(0, 4)
    resizeCorner.Parent = resize
    
    local resizing = false
    resize.MouseButton1Down:Connect(function()
        resizing = true
        main.Active = false
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
            main.Active = true
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = input.Position
            local mainPos = main.AbsolutePosition
            local newW = math.clamp(mousePos.X - mainPos.X, 350, 900)
            local newH = math.clamp(mousePos.Y - mainPos.Y, 360, 800)
            main.Size = UDim2.new(0, newW, 0, newH)
        end
    end)
 
    -- Вкладки
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, -20, 0, 32)
    tabBar.Position = UDim2.new(0, 10, 0, 58)
    tabBar.BackgroundColor3 = Color3.fromRGB(25, 30, 35)
    tabBar.BackgroundTransparency = 0.2
    tabBar.BorderSizePixel = 0
    tabBar.ZIndex = 2
    tabBar.Parent = main
    local tabBarCorner = Instance.new("UICorner")
    tabBarCorner.CornerRadius = UDim.new(0, 6)
    tabBarCorner.Parent = tabBar
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.Parent = tabBar
    local tabPadding = Instance.new("UIPadding")
    tabPadding.PaddingLeft = UDim.new(0, 4)
    tabPadding.PaddingTop = UDim.new(0, 4)
    tabPadding.Parent = tabBar
 
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -20, 1, -140)
    content.P
