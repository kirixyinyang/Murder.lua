-- // YinYang: MM2 Hub v1.0 - Terminal [PART 1/3]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Состояния
local ESPEnabled = false
local MurderESPEnabled = false
local SheriffESPEnabled = false
local CoinESPEnabled = false
local GunESPEnabled = false
local NoClipEnabled = false
local SpeedHackEnabled = false
local InfiniteJumpEnabled = false
local AimbotEnabled = false
local GodModeEnabled = false
local AntiAFKEnabled = false
local FullBrightEnabled = false
local AutoPickupEnabled = false
local AutoShootEnabled = false
local InstantKillEnabled = false
local FlyEnabled = false
local PanelOpen = false

local ESPObjects = {}
local CoinESPObjects = {}
local NoclipConn, JumpConn, AimbotConn, AntiAFKConn, AutoPickupConn, AutoShootConn, InstantKillConn
local BodyVelocity, BodyGyro, FlyHeartbeatConn
local FLY_SPEED = 80

-- Определение ролей
local function getMurderer()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character and plr.Character:FindFirstChild("Murderer") then return plr end
        if plr.Backpack and plr.Backpack:FindFirstChild("Knife") then return plr end
    end
    return nil
end

local function getSheriff()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character and plr.Character:FindFirstChild("Sheriff") then return plr end
        if plr.Backpack and plr.Backpack:FindFirstChild("Gun") then return plr end
    end
    return nil
end

local function getMyRole()
    if LocalPlayer.Character then
        if LocalPlayer.Character:FindFirstChild("Murderer") then return "MURDERER" end
        if LocalPlayer.Character:FindFirstChild("Sheriff") then return "SHERIFF" end
    end
    if LocalPlayer.Backpack then
        if LocalPlayer.Backpack:FindFirstChild("Knife") then return "MURDERER" end
        if LocalPlayer.Backpack:FindFirstChild("Gun") then return "SHERIFF" end
    end
    return "INNOCENT"
end

local function getJoystickVector()
    local success, result = pcall(function()
        local pm = LocalPlayer.PlayerScripts:FindFirstChild("PlayerModule")
        if pm then
            local cm = pm:FindFirstChild("ControlModule")
            if cm then return require(cm):GetMoveVector() end
        end
        return Vector3.zero
    end)
    return success and result or Vector3.zero
end

-- Плавающая кнопка
local FloatButton = Instance.new("TextButton")
FloatButton.Size = UDim2.new(0, 52, 0, 52)
FloatButton.Position = UDim2.new(0.9, 0, 0.8, 0)
FloatButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
FloatButton.BorderSizePixel = 2
FloatButton.BorderColor3 = Color3.fromRGB(180, 0, 0)
FloatButton.Text = "MM2"
FloatButton.TextColor3 = Color3.fromRGB(180, 0, 0)
FloatButton.TextSize = 13
FloatButton.Font = Enum.Font.GothamBold
FloatButton.Active = true
FloatButton.Draggable = true
FloatButton.Parent = CoreGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = FloatButton

-- Терминальная панель
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2Terminal"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.Enabled = false

local Terminal = Instance.new("Frame")
Terminal.Name = "Terminal"
Terminal.Size = UDim2.new(0, 320, 0, 440)
Terminal.Position = UDim2.new(0.5, -160, 0.5, -220)
Terminal.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Terminal.BorderSizePixel = 1
Terminal.BorderColor3 = Color3.fromRGB(180, 0, 0)
Terminal.Active = true
Terminal.Draggable = true
Terminal.Visible = false
Terminal.Parent = ScreenGui

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Terminal

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -40, 1, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "MM2 Hub v1.0 // Terminal"
TitleText.TextColor3 = Color3.fromRGB(180, 0, 0)
TitleText.TextSize = 13
TitleText.Font = Enum.Font.Code
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Position = UDim2.new(0, 8, 0, 0)
TitleText.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.Code
CloseBtn.Parent = TitleBar
CloseBtn.MouseButton1Click:Connect(function()
    Terminal.Visible = false
    ScreenGui.Enabled = false
    PanelOpen = false
end)

local RoleBar = Instance.new("Frame")
RoleBar.Size = UDim2.new(1, 0, 0, 20)
RoleBar.Position = UDim2.new(0, 0, 0, 30)
RoleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
RoleBar.BorderSizePixel = 0
RoleBar.Parent = Terminal

local RoleText = Instance.new("TextLabel")
RoleText.Size = UDim2.new(1, -10, 1, 0)
RoleText.BackgroundTransparency = 1
RoleText.Text = "Role: SCANNING..."
RoleText.TextColor3 = Color3.fromRGB(180, 180, 180)
RoleText.TextSize = 11
RoleText.Font = Enum.Font.Code
RoleText.TextXAlignment = Enum.TextXAlignment.Left
RoleText.Position = UDim2.new(0, 5, 0, 0)
RoleText.Parent = RoleBar

RunService.RenderStepped:Connect(function()
    local role = getMyRole()
    RoleText.Text = "Role: " .. role
    if role == "MURDERER" then
        RoleText.TextColor3 = Color3.fromRGB(255, 50, 50)
    elseif role == "SHERIFF" then
        RoleText.TextColor3 = Color3.fromRGB(50, 100, 255)
    else
        RoleText.TextColor3 = Color3.fromRGB(100, 255, 100)
    end
end)

local StatusBar = Instance.new("Frame")
StatusBar.Size = UDim2.new(1, 0, 0, 20)
StatusBar.Position = UDim2.new(0, 0, 1, -20)
StatusBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
StatusBar.BorderSizePixel = 0
StatusBar.Parent = Terminal

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -10, 1, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "YinYang MM2 | FPS: --"
StatusText.TextColor3 = Color3.fromRGB(140, 140, 140)
StatusText.TextSize = 10
StatusText.Font = Enum.Font.Code
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Position = UDim2.new(0, 5, 0, 0)
StatusText.Parent = StatusBar

RunService.RenderStepped:Connect(function()
    if PanelOpen then
        StatusText.Text = "YinYang MM2 | FPS: " .. math.floor(1 / (RunService.RenderStepped:Wait() + 0.0001))
    end
end)

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -4, 1, -74)
ScrollFrame.Position = UDim2.new(0, 2, 0, 52)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(180, 0, 0)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.Parent = Terminal

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 2)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollFrame

local function AddButton(name, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 30)
    Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Btn.BorderSizePixel = 1
    Btn.BorderColor3 = Color3.fromRGB(60, 0, 0)
    Btn.Text = "> " .. name
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.TextSize = 12
    Btn.Font = Enum.Font.Code
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.TextTruncate = Enum.TextTruncate.None
    Btn.Parent = ScrollFrame
    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(40, 0, 0),
            BorderColor3 = Color3.fromRGB(180, 0, 0),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
    end)
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
            BorderColor3 = Color3.fromRGB(60, 0, 0),
            TextColor3 = Color3.fromRGB(200, 200, 200)
        }):Play()
    end)
    Btn.MouseButton1Click:Connect(callback)
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 5)
    return Btn
end

local function AddSeparator(text)
    local Sep = Instance.new("TextLabel")
    Sep.Size = UDim2.new(1, -10, 0, 20)
    Sep.BackgroundTransparency = 1
    Sep.Text = "-- " .. text .. " --"
    Sep.TextColor3 = Color3.fromRGB(120, 0, 0)
    Sep.TextSize = 10
    Sep.Font = Enum.Font.Code
    Sep.Parent = ScrollFrame
end

-- Плавающая кнопка: открыть/закрыть
FloatButton.MouseButton1Click:Connect(function()
    PanelOpen = not PanelOpen
    Terminal.Visible = PanelOpen
    ScreenGui.Enabled = PanelOpen
end)

-- ==================== ESP PLAYERS ====================
local function CreatePlayerESP(player)
    if player == LocalPlayer then return end
    if ESPObjects[player] then return end
    local function setupESP()
        if not player.Character or not player.Character:FindFirstChild("Head") then return end
        local Billboard = Instance.new("BillboardGui")
        Billboard.Adornee = player.Character.Head
        Billboard.Size = UDim2.new(0, 200, 0, 25)
        Billboard.StudsOffset = Vector3.new(0, 2, 0)
        Billboard.AlwaysOnTop = true
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, 0, 1, 0)
        Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Frame.BackgroundTransparency = 0.4
        Frame.BorderSizePixel = 1
        Frame.BorderColor3 = Color3.fromRGB(100, 100, 100)
        Frame.Parent = Billboard
        local Text = Instance.new("TextLabel")
        Text.Size = UDim2.new(1, 0, 1, 0)
        Text.BackgroundTransparency = 1
        Text.Text = player.Name
        Text.TextColor3 = Color3.fromRGB(255, 255, 255)
        Text.TextSize = 11
        Text.Font = Enum.Font.Code
        Text.Parent = Frame
        Billboard.Parent = CoreGui
        ESPObjects[player] = {billboard = Billboard, frame = Frame, text = Text, connection = nil}
    end
    if player.Character then setupESP() end
    player.CharacterAdded:Connect(function() task.wait(0.3); setupESP() end)
end

local function EnablePlayerESP()
    ESPEnabled = true
    for _, plr in pairs(Players:GetPlayers()) do CreatePlayerESP(plr) end
    Players.PlayerAdded:Connect(function(plr) if ESPEnabled then CreatePlayerESP(plr) end end)
    Players.PlayerRemoving:Connect(function(plr)
        if ESPObjects[plr] then
            if ESPObjects[plr].connection then ESPObjects[plr].connection:Disconnect() end
            ESPObjects[plr].billboard:Destroy()
            ESPObjects[plr] = nil
        end
    end)
    StarterGui:SetCore("SendNotification", {Title = "ESP", Text = "ON", Duration = 2})
end

local function DisablePlayerESP()
    ESPEnabled = false
    for _, data in pairs(ESPObjects) do
        if data.connection then data.connection:Disconnect() end
        if data.billboard then data.billboard:Destroy() end
    end
    ESPObjects = {}
    StarterGui:SetCore("SendNotification", {Title = "ESP", Text = "OFF", Duration = 2})
end

-- ==================== ESP MURDERER ====================
local function EnableMurderESP()
    MurderESPEnabled = not MurderESPEnabled
    if MurderESPEnabled then
        SheriffESPEnabled = false
        RunService.RenderStepped:Connect(function()
            if not MurderESPEnabled then return end
            local murd = getMurderer()
            for _, data in pairs(ESPObjects) do
                if data.frame and murd and data.text and data.text.Text == murd.Name then
                    data.frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                    data.frame.BorderColor3 = Color3.fromRGB(255, 50, 50)
                    data.text.Text = murd.Name .. " [MURDERER]"
                end
            end
        end)
    end
    StarterGui:SetCore("SendNotification", {Title = "Murder ESP", Text = MurderESPEnabled and "ON" or "OFF", Duration = 2})
end

-- ==================== ESP SHERIFF ====================
local function EnableSheriffESP()
    SheriffESPEnabled = not SheriffESPEnabled
    if SheriffESPEnabled then
        MurderESPEnabled = false
        RunService.RenderStepped:Connect(function()
            if not SheriffESPEnabled then return end
            local sher = getSheriff()
            for _, data in pairs(ESPObjects) do
                if data.frame and sher and data.text and data.text.Text == sher.Name then
                    data.frame.BackgroundColor3 = Color3.fromRGB(0, 50, 255)
                    data.frame.BorderColor3 = Color3.fromRGB(50, 100, 255)
                    data.text.Text = sher.Name .. " [SHERIFF]"
                end
            end
        end)
    end
    StarterGui:SetCore("SendNotification", {Title = "Sheriff ESP", Text = SheriffESPEnabled and "ON" or "OFF", Duration = 2})
end

-- ==================== ESP COINS ====================
local function ToggleCoinESP()
    CoinESPEnabled = not CoinESPEnabled
    if CoinESPEnabled then
        RunService.RenderStepped:Connect(function()
            if not CoinESPEnabled then return end
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name == "Coin" or obj.Name == "Coins" then
                    if not CoinESPObjects[obj] then
                        local Billboard = Instance.new("BillboardGui")
                        Billboard.Adornee = obj
                        Billboard.Size = UDim2.new(0, 60, 0, 20)
                        Billboard.StudsOffset = Vector3.new(0, 2, 0)
                        Billboard.AlwaysOnTop = true
                        local Frame = Instance.new("Frame")
                        Frame.Size = UDim2.new(1, 0, 1, 0)
                        Frame.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
                        Frame.BackgroundTransparency = 0.5
                        Frame.BorderSizePixel = 0
                        Frame.Parent = Billboard
                        local Text = Instance.new("TextLabel")
                        Text.Size = UDim2.new(1, 0, 1, 0)
                        Text.BackgroundTransparency = 1
                        Text.Text = "COIN"
                        Text.TextColor3 = Color3.fromRGB(0, 0, 0)
                        Text.TextSize = 10
                        Text.Font = Enum.Font.Code
                        Text.Parent = Frame
                        Billboard.Parent = CoreGui
                        CoinESPObjects[obj] = Billboard
                    end
                end
            end
        end)
    else
        for obj, billboard in pairs(CoinESPObjects) do
            billboard:Destroy()
        end
        CoinESPObjects = {}
    end
    StarterGui:SetCore("SendNotification", {Title = "Coin ESP", Text = CoinESPEnabled and "ON" or "OFF", Duration = 2})
end

-- ==================== ESP GUN ====================
local function ToggleGunESP()
    GunESPEnabled = not GunESPEnabled
    if GunESPEnabled then
        RunService.RenderStepped:Connect(function()
            if not GunESPEnabled then return end
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name == "Gun" and obj:IsA("BasePart") then
                    local alreadyExists = false
                    for _, billboard in pairs(CoinESPObjects) do
                        if billboard.Adornee == obj then alreadyExists = true break end
                    end
                    if not alreadyExists then
                        local Billboard = Instance.new("BillboardGui")
                        Billboard.Name = "GunESP"
                        Billboard.Adornee = obj
                        Billboard.Size = UDim2.new(0, 60, 0, 20)
                        Billboard.StudsOffset = Vector3.new(0, 2, 0)
                        Billboard.AlwaysOnTop = true
                        local Frame = Instance.new("Frame")
                        Frame.Size = UDim2.new(1, 0, 1, 0)
                        Frame.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
                        Frame.BackgroundTransparency = 0.5
                        Frame.BorderSizePixel = 0
                        Frame.Parent = Billboard
                        local Text = Instance.new("TextLabel")
                        Text.Size = UDim2.new(1, 0, 1, 0)
                        Text.BackgroundTransparency = 1
                        Text.Text = "GUN"
                        Text.TextColor3 = Color3.fromRGB(0, 0, 0)
                        Text.TextSize = 10
                        Text.Font = Enum.Font.Code
                        Text.Parent = Frame
                        Billboard.Parent = CoreGui
                        CoinESPObjects["Gun_" .. obj.Name] = Billboard
                    end
                end
            end
        end)
    else
        for key, billboard in pairs(CoinESPObjects) do
            if key:find("Gun_") then billboard:Destroy() end
        end
    end
    StarterGui:SetCore("SendNotification", {Title = "Gun ESP", Text = GunESPEnabled and "ON" or "OFF", Duration = 2})
end
-- // YinYang: MM2 Hub v1.0 - Terminal [PART 2/3]

-- ==================== NOCLIP ====================
local function ToggleNoClip()
    NoClipEnabled = not NoClipEnabled
    if NoClipEnabled then
        if NoclipConn then NoclipConn:Disconnect() end
        NoclipConn = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide == true then
                    part.CanCollide = false
                end
            end
        end)
    else
        if NoclipConn then NoclipConn:Disconnect(); NoclipConn = nil end
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
    StarterGui:SetCore("SendNotification", {Title = "NoClip", Text = NoClipEnabled and "ON" or "OFF", Duration = 2})
end

-- ==================== SPEED HACK ====================
local function ToggleSpeedHack()
    SpeedHackEnabled = not SpeedHackEnabled
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = SpeedHackEnabled and 100 or 16
    end
    StarterGui:SetCore("SendNotification", {Title = "Speed", Text = SpeedHackEnabled and "100" or "16", Duration = 2})
end

-- ==================== INFINITE JUMP ====================
local function ToggleInfiniteJump()
    InfiniteJumpEnabled = not InfiniteJumpEnabled
    if InfiniteJumpEnabled then
        JumpConn = UserInputService.JumpRequest:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if JumpConn then JumpConn:Disconnect(); JumpConn = nil end
    end
    StarterGui:SetCore("SendNotification", {Title = "InfJump", Text = InfiniteJumpEnabled and "ON" or "OFF", Duration = 2})
end

-- ==================== FLY ====================
function EnableFly()
    if FlyEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    hum.PlatformStand = true
    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.MaxForce = Vector3.new(99999, 99999, 99999)
    BodyVelocity.Velocity = Vector3.zero
    BodyVelocity.Parent = hrp
    BodyGyro = Instance.new("BodyGyro")
    BodyGyro.MaxTorque = Vector3.new(99999, 99999, 99999)
    BodyGyro.P = 12500
    BodyGyro.Parent = hrp
    FlyEnabled = true
    FlyHeartbeatConn = RunService.RenderStepped:Connect(function()
        if not FlyEnabled or not BodyVelocity then return end
        local cam = workspace.CurrentCamera
        local move = getJoystickVector()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Vector3.new(0, 0, -1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move + Vector3.new(0, 0, 1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move + Vector3.new(-1, 0, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Vector3.new(1, 0, 0) end
        local vertical = 0
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) or UserInputService:IsKeyDown(Enum.KeyCode.ButtonA) then vertical = 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.ButtonX) then vertical = -1 end
        local finalDir = Vector3.new(move.X, vertical, move.Z)
        if finalDir.Magnitude > 0 then
            BodyVelocity.Velocity = cam.CFrame:VectorToWorldSpace(finalDir.Unit) * FLY_SPEED
        else
            BodyVelocity.Velocity = Vector3.zero
        end
        if BodyGyro then BodyGyro.CFrame = cam.CFrame end
    end)
    StarterGui:SetCore("SendNotification", {Title = "Fly", Text = "ON", Duration = 2})
end

function DisableFly()
    if not FlyEnabled then return end
    FlyEnabled = false
    if FlyHeartbeatConn then FlyHeartbeatConn:Disconnect(); FlyHeartbeatConn = nil end
    if BodyVelocity then BodyVelocity:Destroy(); BodyVelocity = nil end
    if BodyGyro then BodyGyro:Destroy(); BodyGyro = nil end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
    StarterGui:SetCore("SendNotification", {Title = "Fly", Text = "OFF", Duration = 2})
end

-- ==================== AIMBOT ====================
local function ToggleAimbot()
    AimbotEnabled = not AimbotEnabled
    if AimbotEnabled then
        AimbotConn = RunService.RenderStepped:Connect(function()
            local closest, minDist = nil, math.huge
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                    local pos, onScreen = Camera:WorldToScreenPoint(plr.Character.Head.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                        if dist < minDist then minDist = dist; closest = plr end
                    end
                end
            end
            if closest and closest.Character and closest.Character:FindFirstChild("Head") then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Character.Head.Position)
            end
        end)
    else
        if AimbotConn then AimbotConn:Disconnect(); AimbotConn = nil end
        if LocalPlayer.Character then Camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid") end
    end
    StarterGui:SetCore("SendNotification", {Title = "Aimbot", Text = AimbotEnabled and "ON" or "OFF", Duration = 2})
end

-- ==================== GOD MODE ====================
local function ToggleGodMode()
    GodModeEnabled = not GodModeEnabled
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid
        hum.MaxHealth = GodModeEnabled and math.huge or 100
        hum.Health = GodModeEnabled and math.huge or hum.MaxHealth
    end
    StarterGui:SetCore("SendNotification", {Title = "GodMode", Text = GodModeEnabled and "ON" or "OFF", Duration = 2})
end

-- ==================== AUTO SHOOT ====================
local function ToggleAutoShoot()
    AutoShootEnabled = not AutoShootEnabled
    if AutoShootEnabled then
        AutoShootConn = RunService.Heartbeat:Connect(function()
            local role = getMyRole()
            if role == "SHERIFF" then
                local murd = getMurderer()
                if murd and murd.Character and murd.Character:FindFirstChild("Head") then
                    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if tool and (tool.Name == "Gun" or tool:FindFirstChild("Gun")) then
                        local args = {[1] = murd.Character.Head.Position, [2] = murd.Character.Head}
                        pcall(function() tool.RemoteEvent:FireServer(unpack(args)) end)
                    end
                end
            elseif role == "MURDERER" then
                local sher = getSheriff()
                if sher and sher.Character and sher.Character:FindFirstChild("Head") then
                    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if tool and (tool.Name == "Gun" or tool:FindFirstChild("Gun")) then
                        local args = {[1] = sher.Character.Head.Position, [2] = sher.Character.Head}
                        pcall(function() tool.RemoteEvent:FireServer(unpack(args)) end)
                    end
                end
            end
        end)
    else
        if AutoShootConn then AutoShootConn:Disconnect(); AutoShootConn = nil end
    end
    StarterGui:SetCore("SendNotification", {Title = "Auto Shoot", Text = AutoShootEnabled and "ON" or "OFF", Duration = 2})
end

-- ==================== INSTANT KILL ====================
local function ToggleInstantKill()
    InstantKillEnabled = not InstantKillEnabled
    if InstantKillEnabled then
        InstantKillConn = RunService.Heartbeat:Connect(function()
            local role = getMyRole()
            if role == "MURDERER" then
                local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool and tool.Name == "Knife" then
                    for _, plr in pairs(Players:GetPlayers()) do
                        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                            if dist < 10 then
                                pcall(function() tool.RemoteEvent:FireServer(plr.Character) end)
                            end
                        end
                    end
                end
            end
        end)
    else
        if InstantKillConn then InstantKillConn:Disconnect(); InstantKillConn = nil end
    end
    StarterGui:SetCore("SendNotification", {Title = "Instant Kill", Text = InstantKillEnabled and "ON" or "OFF", Duration = 2})
end

-- ==================== KILL ALL ====================
local function KillAll()
    local role = getMyRole()
    if role ~= "MURDERER" then
        StarterGui:SetCore("SendNotification", {Title = "Kill All", Text = "You are not the murderer!", Duration = 3})
        return
    end
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool or tool.Name ~= "Knife" then
        StarterGui:SetCore("SendNotification", {Title = "Kill All", Text = "No knife equipped!", Duration = 3})
        return
    end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            pcall(function()
                LocalPlayer.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 0)
                task.wait(0.05)
                tool.RemoteEvent:FireServer(plr.Character)
                task.wait(0.05)
            end)
        end
    end
    StarterGui:SetCore("SendNotification", {Title = "Kill All", Text = "Done!", Duration = 3})
end

-- ==================== TELEPORT TO PLAYER ====================
local function TeleportToPlayer()
    local closest, minDist = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToScreenPoint(plr.Character.HumanoidRootPart.Position)
            if onScreen then
                local mousePos = UserInputService:GetMouseLocation()
                local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if dist < minDist then minDist = dist; closest = plr end
            end
        end
    end
    if closest and minDist < 200 then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = closest.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        end
    end
    StarterGui:SetCore("SendNotification", {Title = "TP", Text = closest and "Teleported to " .. closest.Name or "No target", Duration = 2})
end

-- ==================== SERVER HOP ====================
local function ServerHop()
    local servers = {}
    local HttpService = game:GetService("HttpService")
    pcall(function()
        local data = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"))
        for _, server in pairs(data.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                table.insert(servers, server.id)
            end
        end
    end)
    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)])
    else
        StarterGui:SetCore("SendNotification", {Title = "Server Hop", Text = "No servers found", Duration = 3})
    end
end

-- ==================== ANTI AFK ====================
local function ToggleAntiAFK()
    AntiAFKEnabled = not AntiAFKEnabled
    if AntiAFKEnabled then
        local VU = game:GetService("VirtualUser")
        AntiAFKConn = RunService.Heartbeat:Connect(function()
            pcall(function()
                VU:CaptureController()
                VU:Button2Down(Vector2.new(0, 0), Camera.CFrame)
                task.wait(0.5)
                VU:Button2Up(Vector2.new(0, 0), Camera.CFrame)
            end)
        end)
    else
        if AntiAFKConn then AntiAFKConn:Disconnect(); AntiAFKConn = nil end
    end
    StarterGui:SetCore("SendNotification", {Title = "AntiAFK", Text = AntiAFKEnabled and "ON" or "OFF", Duration = 2})
end

-- ==================== FULL BRIGHT ====================
local function ToggleFullBright()
    FullBrightEnabled = not FullBrightEnabled
    if FullBrightEnabled then
        local fb = Instance.new("ColorCorrectionEffect")
        fb.Name = "YinYang_Brightness"
        fb.Brightness = 0.4
        fb.Contrast = 0.3
        fb.Saturation = -0.5
        fb.TintColor = Color3.fromRGB(255, 255, 255)
        fb.Parent = Lighting
    else
        if Lighting:FindFirstChild("YinYang_Brightness") then
            Lighting.YinYang_Brightness:Destroy()
        end
    end
    StarterGui:SetCore("SendNotification", {Title = "FullBright", Text = FullBrightEnabled and "ON" or "OFF", Duration = 2})
end

-- ==================== FPS BOOST ====================
local function FPSBoost()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Material == Enum.Material.Grass or obj.Material == Enum.Material.Fabric) then
            obj.Material = Enum.Material.SmoothPlastic
        end
    end
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 99999
    pcall(function() settings().Rendering.QualityLevel = 1 end)
    StarterGui:SetCore("SendNotification", {Title = "FPS Boost", Text = "Applied", Duration = 2})
end

-- ==================== AUTO PICKUP COINS ====================
local function ToggleAutoPickup()
    AutoPickupEnabled = not AutoPickupEnabled
    if AutoPickupEnabled then
        AutoPickupConn = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            local hrp = char.HumanoidRootPart
            for _, obj in pairs(workspace:GetDescendants()) do
                if (obj.Name == "Coin" or obj.Name == "Coins") and obj:IsA("BasePart") then
                    local dist = (hrp.Position - obj.Position).Magnitude
                    if dist < 10 then
                        firetouchinterest(hrp, obj, 0)
                        firetouchinterest(hrp, obj, 1)
                    end
                end
            end
        end)
    else
        if AutoPickupConn then AutoPickupConn:Disconnect(); AutoPickupConn = nil end
    end
    StarterGui:SetCore("SendNotification", {Title = "Auto Pickup", Text = AutoPickupEnabled and "ON" or "OFF", Duration = 2})
end
-- // YinYang: MM2 Hub v1.0 - Terminal [PART 3/3]

-- ==================== CLEANUP ====================
function CleanupAll()
    if ESPEnabled then DisablePlayerESP() end
    if CoinESPEnabled then ToggleCoinESP() end
    if GunESPEnabled then ToggleGunESP() end
    if NoClipEnabled then ToggleNoClip() end
    if SpeedHackEnabled then ToggleSpeedHack() end
    if InfiniteJumpEnabled then ToggleInfiniteJump() end
    if AimbotEnabled then ToggleAimbot() end
    if GodModeEnabled then ToggleGodMode() end
    if AntiAFKEnabled then ToggleAntiAFK() end
    if FullBrightEnabled then ToggleFullBright() end
    if AutoPickupEnabled then ToggleAutoPickup() end
    if AutoShootEnabled then ToggleAutoShoot() end
    if InstantKillEnabled then ToggleInstantKill() end
    if FlyEnabled then DisableFly() end
    if Lighting:FindFirstChild("YinYang_Brightness") then Lighting.YinYang_Brightness:Destroy() end
end

-- ==================== RESPAWN HANDLER ====================
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.3)
    if NoClipEnabled then NoClipEnabled = false; task.wait(0.1); ToggleNoClip() end
    if GodModeEnabled then
        local hum = char:WaitForChild("Humanoid", 3)
        if hum then hum.MaxHealth = math.huge; hum.Health = math.huge end
    end
    if FlyEnabled then FlyEnabled = false; task.wait(0.1); EnableFly() end
    if AutoShootEnabled then AutoShootEnabled = false; task.wait(0.2); ToggleAutoShoot() end
    if InstantKillEnabled then InstantKillEnabled = false; task.wait(0.2); ToggleInstantKill() end
    if AutoPickupEnabled then AutoPickupEnabled = false; task.wait(0.2); ToggleAutoPickup() end
end)

-- ==================== BUTTONS ====================
AddSeparator("ESP")
AddButton("ESP PLAYERS", function() if ESPEnabled then DisablePlayerESP() else EnablePlayerESP() end end)
AddButton("ESP MURDERER", EnableMurderESP)
AddButton("ESP SHERIFF", EnableSheriffESP)
AddButton("ESP COINS", ToggleCoinESP)
AddButton("ESP GUN", ToggleGunESP)

AddSeparator("MOVEMENT")
AddButton("FLY", function() if FlyEnabled then DisableFly() else EnableFly() end end)
AddButton("NOCLIP", ToggleNoClip)
AddButton("SPEED HACK", ToggleSpeedHack)
AddButton("INFINITE JUMP", ToggleInfiniteJump)

AddSeparator("COMBAT")
AddButton("AIMBOT", ToggleAimbot)
AddButton("AUTO SHOOT", ToggleAutoShoot)
AddButton("INSTANT KILL", ToggleInstantKill)
AddButton("KILL ALL", KillAll)
AddButton("GOD MODE", ToggleGodMode)

AddSeparator("UTILITY")
AddButton("AUTO PICKUP COINS", ToggleAutoPickup)
AddButton("TELEPORT TO PLAYER", TeleportToPlayer)
AddButton("SERVER HOP", ServerHop)
AddButton("ANTI AFK", ToggleAntiAFK)
AddButton("FULL BRIGHT", ToggleFullBright)
AddButton("FPS BOOST", FPSBoost)

AddSeparator("EXIT")
AddButton("CLOSE HUB", function() CleanupAll(); Terminal.Visible = false; ScreenGui.Enabled = false; PanelOpen = false end)

AddSeparator("YinYang MM2 Active")
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)

StarterGui:SetCore("SendNotification", {Title = "MM2 Hub v1.0", Text = "Floating button ready. Tap to open.", Duration = 5})

print("// YinYang: MM2 Hub v1.0 загружен.")
