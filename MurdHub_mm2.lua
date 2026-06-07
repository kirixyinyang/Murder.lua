-- // YinYang: MM2 Hub v4.0 [ИСПРАВЛЕННЫЙ] - ЧАСТЬ 1
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- Цветовая палитра интерфейса
local C = {
    bg = Color3.fromRGB(8, 8, 8),
    bg2 = Color3.fromRGB(14, 14, 14),
    bg3 = Color3.fromRGB(20, 20, 20),
    red = Color3.fromRGB(200, 0, 0),
    redBright = Color3.fromRGB(255, 30, 30),
    redDark = Color3.fromRGB(60, 0, 0),
    text = Color3.fromRGB(235, 235, 235),
    textDim = Color3.fromRGB(100, 100, 100)
}

-- Переменные состояний (Флаги функций)
local ESPPeople, ESPMurderer, ESPSheriff, ESPGun = false, false, false, false
local FlyEnabled, NoClipEnabled, AimbotEnabled, GodModeEnabled = false, false, false, false
local AntiAFKEnabled, FullBrightEnabled, InstantKillEnabled = false, false, false
local HiddenFling, KillAllEnabled, FarmEnabled, AutoGrabGun = false, false, false, false

local FlingThread = nil
local IgnoreSheriff, IgnoreInnocent = false, false
local AimbotFOV = 120
local ShowAimbotCircle = true
local AimbotCircle = nil

local WalkspeedVal, JumpPowerVal, GravityVal = 16, 50, 196.2
local FarmCooldown = 0.1

local BodyVelocity, BodyGyro, FlyHeartbeatConn
local NoclipConn, AimbotConn, AntiAFKConn, InstantKillConn, FarmConn, KillAllConn, GrabGunConn
local FLY_SPEED = 80

-- Логика определения ролей по оружию
local function hasKnife(p)
    if not p then return false end
    if p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Knife") then return true end
    if p.Character and p.Character:FindFirstChild("Knife") then return true end
    return false
end

local function hasGun(p)
    if not p then return false end
    if p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Gun") then return true end
    if p.Character and p.Character:FindFirstChild("Gun") then return true end
    return false
end

local function getMurderer()
    for _, p in pairs(Players:GetPlayers()) do if hasKnife(p) then return p end end
    return nil
end

local function getSheriff()
    for _, p in pairs(Players:GetPlayers()) do if hasGun(p) then return p end end
    return nil
end

local function getMyRole()
    if hasKnife(LocalPlayer) then return "MURDERER" end
    if hasGun(LocalPlayer) then return "SHERIFF" end
    return "INNOCENT"
end

local function getJoystickVector()
    local s, r = pcall(function()
        local pm = LocalPlayer.PlayerScripts:FindFirstChild("PlayerModule")
        if pm then 
            local cm = pm:FindFirstChild("ControlModule")
            if cm then return require(cm):GetMoveVector() end 
        end
        return Vector3.zero
    end)
    return s and r or Vector3.zero
end

-- СИСТЕМА УМНОГО ESP (Фикс задержек и новых игроков)
local function addESP(part, color, text)
    if not part or part:FindFirstChild("YinYang_Highlight") then return end
    
    local hl = Instance.new("Highlight")
    hl.Name = "YinYang_Highlight"
    hl.FillColor = color
    hl.OutlineColor = Color3.new(1, 1, 1)
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = part
    
    if part:IsA("Model") and part:FindFirstChild("Head") then
        local bbg = Instance.new("BillboardGui")
        bbg.Name = "YinYang_ESP_Gui"
        bbg.Adornee = part.Head
        bbg.Size = UDim2.new(0, 140, 0, 22)
        bbg.StudsOffset = Vector3.new(0, 2.5, 0)
        bbg.AlwaysOnTop = true
        
        local tl = Instance.new("TextLabel")
        tl.Size = UDim2.new(1, 0, 1, 0)
        tl.BackgroundTransparency = 1
        tl.Text = text
        tl.TextColor3 = color
        tl.Font = Enum.Font.GothamBold
        tl.TextSize = 11
        tl.TextScaled = false
        tl.Parent = bbg
        bbg.Parent = part
    end
end

local function removeESP(part)
    if not part then return end
    local hl = part:FindFirstChild("YinYang_Highlight")
    local gui = part:FindFirstChild("YinYang_ESP_Gui")
    if hl then hl:Destroy() end
    if gui then gui:Destroy() end
end

-- Автоматическое назначение цвета при обновлении кадра
local function updatePlayerESP(p)
    if p == LocalPlayer or not p.Character then return end
    removeESP(p.Character)
    
    if hasKnife(p) and ESPMurderer then
        addESP(p.Character, Color3.fromRGB(255, 50, 50), "Murderer - " .. p.Name)
    elseif hasGun(p) and ESPSheriff then
        addESP(p.Character, Color3.fromRGB(50, 150, 255), "Sheriff - " .. p.Name)
    elseif ESPPeople then
        addESP(p.Character, Color3.fromRGB(235, 235, 235), p.Name)
    end
end

-- Мониторинг входа новых игроков
Players.PlayerAdded:Connect(function(newPlayer)
    newPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.5) -- Даем прогрузиться хитбоксам
        updatePlayerESP(newPlayer)
    end)
end)

-- Потоковый скан игрового мира (Ищет пистолет на полу и обновляет роли)
RunService.Heartbeat:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then updatePlayerESP(p) end
    end
    
    -- Исправленный поиск пистолета на полу
    local normal = Workspace:FindFirstChild("Normal")
    local gunDrop = normal and normal:FindFirstChild("GunDrop")
    if gunDrop and ESPGun then
        addESP(gunDrop, Color3.fromRGB(50, 255, 50), "Dropped Gun")
    elseif gunDrop and not ESPGun then
        removeESP(gunDrop)
    end
end)
-- // YinYang: MM2 Hub v4.0 [ИСПРАВЛЕННЫЙ] - ЧАСТЬ 2
-- Повторные ссылки для независимых блоков (если делить на файлы)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Безопасный и точный метод телепортации хитбокса
local function safeTeleport(targetCFrame)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = targetCFrame
        return true
    end
    return false
end

-- Починенная функция подбора пистолета (ТП туда и возврат назад)
local function GrabGun()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local normal = Workspace:FindFirstChild("Normal")
    local gunDrop = normal and normal:FindFirstChild("GunDrop")
    
    if gunDrop and hrp then
        local oldCFrame = hrp.CFrame -- Запоминаем, где мы стояли
        
        safeTeleport(gunDrop.CFrame * CFrame.new(0, 1, 0)) -- ТП на пистолет
        task.wait(0.2) -- Задержка, чтобы сервер успел выдать пушку
        safeTeleport(oldCFrame) -- Возвращаемся обратно в укрытие
        
        StarterGui:SetCore("SendNotification", {Title = "YinYang Hub", Text = "Gun Grabbed Successfully!", Duration = 2})
    else
        StarterGui:SetCore("SendNotification", {Title = "YinYang Hub", Text = "No dropped gun found!", Duration = 2})
    end
end

local function ToggleAutoGrabGun(v)
    AutoGrabGun = v
    if GrabGunConn then GrabGunConn:Disconnect(); GrabGunConn = nil end
    
    if v then
        GrabGunConn = RunService.Heartbeat:Connect(function()
            local normal = Workspace:FindFirstChild("Normal")
            local gunDrop = normal and normal:FindFirstChild("GunDrop")
            if gunDrop and not hasGun(LocalPlayer) then
                GrabGun()
                task.wait(0.5) -- Защита от спам-телепортации
            end
        end)
    end
end

-- Функция полета (Flight)
local function EnableFly()
    if FlyEnabled then return end
    local char = LocalPlayer.Character; if not char then return end
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
        local move = getJoystickVector()
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Vector3.new(0, 0, -1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move + Vector3.new(0, 0, 1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move + Vector3.new(-1, 0, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Vector3.new(1, 0, 0) end
        
        local vertical = 0
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vertical = 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vertical = -1 end
        
        local finalDir = Vector3.new(move.X, vertical, move.Z)
        if finalDir.Magnitude > 0 then 
            BodyVelocity.Velocity = Camera.CFrame:VectorToWorldSpace(finalDir.Unit) * FLY_SPEED
        else 
            BodyVelocity.Velocity = Vector3.zero 
        end
        if BodyGyro then BodyGyro.CFrame = Camera.CFrame end
    end)
end

local function DisableFly()
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
end

-- Прохождение сквозь стены (NoClip)
local function ToggleNoClip(v)
    NoClipEnabled = v
    if v then
        if NoclipConn then NoclipConn:Disconnect() end
        NoclipConn = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character; if not char then return end
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide == true then part.CanCollide = false end
            end
        end)
    else
        if NoclipConn then NoclipConn:Disconnect(); NoclipConn = nil end
    end
end

-- Стабильный Аимбот с FOV кругом
local function CreateAimbotCircle()
    if AimbotCircle then AimbotCircle:Destroy() end
    AimbotCircle = Instance.new("Frame")
    AimbotCircle.Size = UDim2.new(0, AimbotFOV, 0, AimbotFOV)
    AimbotCircle.Position = UDim2.new(0.5, -AimbotFOV/2, 0.5, -AimbotFOV/2)
    AimbotCircle.BackgroundTransparency = 1
    AimbotCircle.BorderSizePixel = 1
    AimbotCircle.BorderColor3 = Color3.fromRGB(255, 50, 50)
    AimbotCircle.ZIndex = 100
    AimbotCircle.Parent = ScreenGui
end

local function UpdateAimbotCircle()
    if not ShowAimbotCircle then if AimbotCircle then AimbotCircle.Visible = false end; return end
    if not AimbotCircle or AimbotCircle.Size ~= UDim2.new(0, AimbotFOV, 0, AimbotFOV) then CreateAimbotCircle() end
    AimbotCircle.Visible = true
end

local function ToggleAimbot(v)
    AimbotEnabled = v
    if v then
        UpdateAimbotCircle()
        AimbotConn = RunService.RenderStepped:Connect(function()
            UpdateAimbotCircle()
            local closest, minDist = nil, math.huge
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                    local targetRole = "INNOCENT"
                    if hasKnife(plr) then targetRole = "MURDERER" elseif hasGun(plr) then targetRole = "SHERIFF" end
                    
                    if IgnoreSheriff and targetRole == "SHERIFF" then continue end
                    if IgnoreInnocent and targetRole == "INNOCENT" then continue end
                    
                    local pos, onScreen = Camera:WorldToScreenPoint(plr.Character.Head.Position)
                    if onScreen then
                        local sc = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        local dist = (Vector2.new(pos.X, pos.Y) - sc).Magnitude
                        if dist < minDist and dist < AimbotFOV / 2 then
                            minDist = dist; closest = plr
                        end
                    end
                end
            end
            if closest and closest.Character and closest.Character:FindFirstChild("Head") then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Character.Head.Position)
            end
        end)
    else
        if AimbotConn then AimbotConn:Disconnect(); AimbotConn = nil end
        if AimbotCircle then AimbotCircle.Visible = false end
    end
end

-- Агрессивный метод атаки (Fling)
local function StartFling(targetFunc)
    if HiddenFling then return end
    HiddenFling = true
    local movel = 0.1
    
    FlingThread = coroutine.create(function()
        while HiddenFling do
            RunService.Heartbeat:Wait()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local target = targetFunc and targetFunc()
            
            if hrp and target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
                hrp.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 1.5, 0)
                hrp.Velocity = Vector3.new(99999, 99999, 99999)
                hrp.RotVelocity = Vector3.new(0, 99999, 0)
            end
        end
    end)
    coroutine.resume(FlingThread)
end

local function StopFling() HiddenFling = false; FlingThread = nil end
local function FlingMurderer() if HiddenFling then StopFling() end StartFling(getMurderer) end
local function FlingSheriff() if HiddenFling then StopFling() end StartFling(getSheriff) end
-- // YinYang: MM2 Hub v4.0 [ИСПРАВЛЕННЫЙ] - ЧАСТЬ 3
-- Инициализация графического каркаса меню
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MurdMenu"; ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true; ScreenGui.Parent = PlayerGui

local ToggleBtn = Instance.new("ImageButton")
ToggleBtn.Size = UDim2.new(0, 42, 0, 42); ToggleBtn.Position = UDim2.new(0, 10, 1, -68)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0); ToggleBtn.BorderSizePixel = 0
ToggleBtn.ZIndex = 30; ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 10)

local BtnStroke = Instance.new("UIStroke"); BtnStroke.Color = C.red; BtnStroke.Thickness = 2; BtnStroke.Parent = ToggleBtn
local BtnLabel = Instance.new("TextLabel"); BtnLabel.Size = UDim2.new(1, 0, 1, 0)
BtnLabel.BackgroundTransparency = 1; BtnLabel.Text = "Y"; BtnLabel.TextColor3 = C.red
BtnLabel.TextSize = 17; BtnLabel.Font = Enum.Font.GothamBlack; BtnLabel.ZIndex = 31; BtnLabel.Parent = ToggleBtn

-- Логика перетаскивания кнопки меню по экрану
local draggingBtn, dragStartPos, btnStartPos = false, nil, nil
ToggleBtn.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingBtn = true; dragStartPos = inp.Position; btnStartPos = ToggleBtn.Position
    end
end)
ToggleBtn.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then draggingBtn = false end
end)
UserInputService.InputChanged:Connect(function(inp)
    if not draggingBtn then return end
    if inp.UserInputType ~= Enum.UserInputType.Touch and inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
    local delta = inp.Position - dragStartPos
    local vp = workspace.CurrentCamera.ViewportSize
    local newX = math.clamp(btnStartPos.X.Offset + delta.X, 0, vp.X - 42)
    local newY = math.clamp(btnStartPos.Y.Offset + delta.Y, 0, vp.Y - 42)
    ToggleBtn.Position = UDim2.new(0, newX, 0, newY)
end)

-- Создание основы панели управления
local Overlay = Instance.new("TextButton")
Overlay.Size = UDim2.new(1, 0, 1, 0); Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Overlay.BackgroundTransparency = 1; Overlay.Text = ""; Overlay.ZIndex = 9; Overlay.Visible = false; Overlay.Parent = ScreenGui

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 280, 0, 320); Panel.Position = UDim2.new(0.5, -140, 1, 0)
Panel.BackgroundColor3 = C.bg; Panel.ZIndex = 10; Panel.Visible = false; Panel.Parent = ScreenGui
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 12)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 48); Header.Position = UDim2.new(0, 0, 0, 2); Header.BackgroundColor3 = C.bg2; Header.Parent = Panel
local LogoLbl = Instance.new("TextLabel"); LogoLbl.Size = UDim2.new(1, 0, 0, 20); LogoLbl.Position = UDim2.new(0, 0, 0, 5)
LogoLbl.BackgroundTransparency = 1; LogoLbl.Text = "YIN-YANG MODS"; LogoLbl.TextColor3 = C.red; LogoLbl.Font = Enum.Font.GothamBlack; LogoLbl.Parent = Header

local RoleLabel = Instance.new("TextLabel"); RoleLabel.Size = UDim2.new(1, -12, 0, 12); RoleLabel.Position = UDim2.new(0, 6, 0, 34)
RoleLabel.BackgroundTransparency = 1; RoleLabel.Text = "Role: Scanning..."; RoleLabel.TextColor3 = C.textDim; RoleLabel.Font = Enum.Font.Gotham; RoleLabel.TextXAlignment = Enum.TextXAlignment.Left; RoleLabel.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 22, 0, 22); CloseBtn.Position = UDim2.new(1, -28, 0, 6)
CloseBtn.BackgroundColor3 = C.redDark; CloseBtn.Text = "X"; CloseBtn.TextColor3 = C.text; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.Parent = Panel
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)

-- Авто-обновление текста роли на панели инфо
RunService.RenderStepped:Connect(function()
    local role = getMyRole()
    RoleLabel.Text = "Role: " .. role
    if role == "MURDERER" then RoleLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    elseif role == "SHERIFF" then RoleLabel.TextColor3 = Color3.fromRGB(50, 100, 255)
    else RoleLabel.TextColor3 = C.textDim end
end)

-- РЕГИСТРАЦИЯ ВКЛАДОК МЕНЮ
local TabButtons = {}
local TabContent = {}
local function CreateTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.22, 0, 0, 22); btn.Position = UDim2.new(0.02 + #TabButtons * 0.24, 0, 0, 52)
    btn.BackgroundColor3 = C.bg3; btn.Text = name; btn.TextColor3 = C.textDim; btn.Font = Enum.Font.GothamBold; btn.TextSize = 9; btn.Parent = Panel
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -12, 1, -84); content.Position = UDim2.new(0, 6, 0, 78)
    content.BackgroundTransparency = 1; content.ScrollBarThickness = 2; content.ScrollBarImageColor3 = C.red
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y; content.Visible = false; content.Parent = Panel
    Instance.new("UIListLayout", content).Padding = UDim.new(0, 3)
    
    btn.MouseButton1Click:Connect(function()
        for _, b in pairs(TabButtons) do b.BackgroundColor3 = C.bg3; b.TextColor3 = C.textDim end
        for _, c in pairs(TabContent) do c.Visible = false end
        btn.BackgroundColor3 = C.redDark; btn.TextColor3 = C.text; content.Visible = true
    end)
    table.insert(TabButtons, btn); table.insert(TabContent, content); return content
end

local TabESP = CreateTab("ESP")
local TabMove = CreateTab("Move")
local TabCombat = CreateTab("Combat")
local TabUtil = CreateTab("Util")
TabButtons[1].BackgroundColor3 = C.redDark; TabButtons[1].TextColor3 = C.text; TabContent[1].Visible = true

-- СБОРКА НАПОЛНЕНИЯ ВКЛАДОК (Коннект функций из Части 2)
MakeToggle(TabESP, "ESP People", function(v) ESPPeople = v end)
MakeToggle(TabESP, "ESP Murderer", function(v) ESPMurderer = v end)
MakeToggle(TabESP, "ESP Sheriff", function(v) ESPSheriff = v end)
MakeToggle(TabESP, "ESP Dropped Gun", function(v) ESPGun = v end)

MakeToggle(TabMove, "Flight Mode", function(v) if v then EnableFly() else DisableFly() end end)
MakeToggle(TabMove, "NoClip walls", ToggleNoClip)
MakeSlider(TabMove, "Speed", 16, 120, 16, function(v) WalkspeedVal = v end)
MakeSlider(TabMove, "Jump", 50, 200, 50, function(v) JumpPowerVal = v end)

MakeToggle(TabCombat, "Aim Assist", ToggleAimbot)
MakeToggle(TabCombat, "Draw FOV", function(v) ShowAimbotCircle = v; UpdateAimbotCircle() end)
MakeAction(TabCombat, "Fling Murderer", FlingMurderer)
MakeAction(TabCombat, "Fling Sheriff", FlingSheriff)

MakeToggle(TabUtil, "Auto Pick Gun", ToggleAutoGrabGun)
MakeAction(TabUtil, "Grab Gun Once", GrabGun)
MakeAction(TabUtil, "Close Cheat System", function() ScreenGui:Destroy() end)

-- Логика Анимации Открытия/Закрытия меню
local menuOpen = false
local function openMenu()
    menuOpen = true; Panel.Visible = true; Overlay.Visible = true
    TweenService:Create(Panel, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Position = UDim2.new(0.5, -140, 1, -320)}):Play()
end
local function closeMenu()
    menuOpen = false
    TweenService:Create(Panel, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {Position = UDim2.new(0.5, -140, 1, 0)}):Play()
    task.delay(0.2, function() Panel.Visible = false; Overlay.Visible = false end)
end

ToggleBtn.MouseButton1Click:Connect(function() if menuOpen then closeMenu() else openMenu() end end)
CloseBtn.MouseButton1Click:Connect(closeMenu)
Overlay.MouseButton1Click:Connect(closeMenu)
