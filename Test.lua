-- СПЕЦИАЛЬНО ДЛЯ XENO + BABFT
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local Features = {
    AutoFarm = false,
    GodMode = false,
    FlyEnabled = false,
    AntiAFK = false
}

-- Простой Auto Farm без платформы
local function AutoFarm()
    spawn(function()
        while Features.AutoFarm do
            wait(0.5)
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                
                local root = char:FindFirstChild("HumanoidRootPart")
                if not root then return end
                
                for _, obj in ipairs(Workspace:GetChildren()) do
                    if not Features.AutoFarm then break end
                    
                    if obj:IsA("Part") or obj:IsA("MeshPart") then
                        local name = obj.Name:lower()
                        if name:find("gold") or name:find("coin") then
                            if (obj.Position - root.Position).Magnitude < 30 then
                                root.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
                            end
                        end
                    end
                end
            end)
        end
    end)
end

-- God Mode (простой)
local function GodMode()
    spawn(function()
        while Features.GodMode do
            wait(0.5)
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChild("Humanoid")
                    if hum then
                        hum.Health = hum.MaxHealth
                    end
                end
            end)
        end
    end)
end

-- Anti-AFK
local function AntiAFK()
    spawn(function()
        while Features.AntiAFK do
            wait(30)
            pcall(function()
                -- Нажать Esc (открыть меню) чтобы игра не кикнула
                local VirtualInputManager = game:GetService("VirtualInputManager")
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Escape, false, game)
                wait(0.5)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Escape, false, game)
            end)
        end
    end)
end

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BABFT_Hack"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 250)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
Title.Text = "🌟 BABFT HACK (Xeno Fix)"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.BorderSizePixel = 0
Title.Parent = MainFrame

local function MakeButton(text, y, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.Parent = MainFrame
    
    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        btn.Text = text .. ": " .. (enabled and "ON" or "OFF")
        btn.BackgroundColor3 = enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(200, 50, 50)
        callback(enabled)
    end)
    
    return btn
end

MakeButton("⚔️ Auto Farm", 40, function(on)
    Features.AutoFarm = on
    if on then AutoFarm() end
end)

MakeButton("🛡️ God Mode", 85, function(on)
    Features.GodMode = on
    if on then GodMode() end
end)

MakeButton("🤖 Anti-AFK", 130, function(on)
    Features.AntiAFK = on
    if on then AntiAFK() end
end)

-- Закрыть
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(1, -20, 0, 35)
CloseBtn.Position = UDim2.new(0, 10, 0, 195)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Text = "✕ ЗАКРЫТЬ"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = MainFrame

CloseBtn.MouseButton1Click:Connect(function()
    Features.AutoFarm = false
    Features.GodMode = false
    Features.AntiAFK = false
    ScreenGui:Destroy()
end)
