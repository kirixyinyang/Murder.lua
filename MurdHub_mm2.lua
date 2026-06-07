-- // YinYang: MM2 Hub v4.0 (FIXED UI) - ЧАСТЬ 1
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- Флаги
local ESPPeople, ESPMurderer, ESPSheriff, ESPGun = false, false, false, false
local FlyEnabled, NoClipEnabled, AimbotEnabled, AutoGrabGun, HiddenFling = false, false, false, false, false
local WalkspeedVal, JumpPowerVal = 16, 50
local ShowAimbotCircle, AimbotFOV = true, 120
local FlySpeed = 80

local FlyHeartbeatConn, NoclipConn, AimbotConn, GrabGunConn, FlingThread
local BodyVelocity, BodyGyro, AimbotCircle

-- Цвета
local C = {
    bg = Color3.fromRGB(15, 15, 15),
    bg2 = Color3.fromRGB(25, 25, 25),
    accent = Color3.fromRGB(220, 20, 20),
    text = Color3.fromRGB(240, 240, 240),
    textDim = Color3.fromRGB(150, 150, 150)
}

-- ==========================
-- УТИЛИТЫ И ОПРЕДЕЛЕНИЕ РОЛЕЙ
-- ==========================
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

local function getMyRole()
    if hasKnife(LocalPlayer) then return "MURDERER" end
    if hasGun(LocalPlayer) then return "SHERIFF" end
    return "INNOCENT"
end

-- ==========================
-- СИСТЕМА ESP
-- ==========================
local function addESP(part, color, text)
    if not part or part:FindFirstChild("YY_Highlight") then return end
    local hl = Instance.new("Highlight")
    hl.Name = "YY_Highlight"; hl.FillColor = color; hl.OutlineColor = Color3.new(1,1,1)
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent = part
    
    local head = part:IsA("Model") and part:FindFirstChild("Head") or part
    if head then
        local bbg = Instance.new("BillboardGui", part)
        bbg.Name = "YY_ESP_Gui"; bbg.Adornee = head
        bbg.Size = UDim2.new(0, 150, 0, 20); bbg.StudsOffset = Vector3.new(0, 2.5, 0); bbg.AlwaysOnTop = true
        local tl = Instance.new("TextLabel", bbg)
        tl.Size = UDim2.new(1,0,1,0); tl.BackgroundTransparency = 1
        tl.Text = text; tl.TextColor3 = color; tl.Font = Enum.Font.GothamBold; tl.TextSize = 12
    end
end

local function removeESP(part)
    if not part then return end
    if part:FindFirstChild("YY_Highlight") then part.YY_Highlight:Destroy() end
    if part:FindFirstChild("YY_ESP_Gui") then part.YY_ESP_Gui:Destroy() end
end

local function updateESP(p)
    if p == LocalPlayer or not p.Character then return end
    removeESP(p.Character)
    if hasKnife(p) and ESPMurderer then addESP(p.Character, Color3.fromRGB(255, 30, 30), "Murderer: " .. p.Name)
    elseif hasGun(p) and ESPSheriff then addESP(p.Character, Color3.fromRGB(30, 140, 255), "Sheriff: " .. p.Name)
    elseif ESPPeople then addESP(p.Character, Color3.fromRGB(200, 200, 200), p.Name) end
end

RunService.Heartbeat:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do updateESP(p) end
    local gunDrop = Workspace:FindFirstChild("Normal") and Workspace.Normal:FindFirstChild("GunDrop")
    if gunDrop and ESPGun then addESP(gunDrop, Color3.fromRGB(50, 255, 50), "DROPPED GUN")
    elseif gunDrop and not ESPGun then removeESP(gunDrop) end
end)

Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() task.wait(1); updateESP(p) end) end)

-- ==========================
-- ФУНКЦИИ ЧИТА (Fly, GrabGun, Fling)
-- ==========================
local function safeTeleport(cframe)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = cframe; return true end
    return false
end

function _G.GrabGun()
    local gunDrop = Workspace:FindFirstChild("Normal") and Workspace.Normal:FindFirstChild("GunDrop")
    if gunDrop then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local oldPos = hrp.CFrame
            safeTeleport(gunDrop.CFrame * CFrame.new(0, 1, 0)); task.wait(0.2)
            safeTeleport(oldPos)
        end
    end
end

function _G.ToggleAutoGrabGun(v)
    AutoGrabGun = v
    if GrabGunConn then GrabGunConn:Disconnect(); GrabGunConn = nil end
    if v then GrabGunConn = RunService.Heartbeat:Connect(function()
        local gunDrop = Workspace:FindFirstChild("Normal") and Workspace.Normal:FindFirstChild("GunDrop")
        if gunDrop and not hasGun(LocalPlayer) then _G.GrabGun(); task.wait(0.5) end
    end) end
end

function _G.ToggleNoClip(v)
    if NoclipConn then NoclipConn:Disconnect(); NoclipConn = nil end
    if v then NoclipConn = RunService.Stepped:Connect(function()
        if LocalPlayer.Character then
            for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end) end
end

function _G.StartFling(targetRole)
    if HiddenFling then HiddenFling = false; task.wait(0.1) end
    HiddenFling = true
    task.spawn(function()
        while HiddenFling do
            RunService.Heartbeat:Wait()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local targetPlayer
            for _, p in pairs(Players:GetPlayers()) do
                if targetRole == "MURDERER" and hasKnife(p) then targetPlayer = p; break end
                if targetRole == "SHERIFF" and hasGun(p) then targetPlayer = p; break end
            end
            if hrp and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                hrp.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
                hrp.Velocity = Vector3.new(10000, 10000, 10000)
            end
        end
    end)
end
-- // YinYang: MM2 Hub v4.0 (FIXED UI) - ЧАСТЬ 2

-- ==========================
-- СОЗДАНИЕ ИНТЕРФЕЙСА
-- ==========================
local SG = Instance.new("ScreenGui")
SG.Name = "YinYangMenu"; SG.ResetOnSpawn = false; SG.Parent = PlayerGui

-- КНОПКА ОТКРЫТИЯ (Теперь точно по центру слева)
local OpenBtn = Instance.new("TextButton", SG)
OpenBtn.Size = UDim2.new(0, 45, 0, 45); OpenBtn.Position = UDim2.new(0, 20, 0.5, -22)
OpenBtn.BackgroundColor3 = C.bg; OpenBtn.Text = "M"
OpenBtn.TextColor3 = C.accent; OpenBtn.Font = Enum.Font.GothamBlack; OpenBtn.TextSize = 24
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", OpenBtn).Color = C.accent

-- ГЛАВНАЯ ПАНЕЛЬ (Появляется по центру)
local Panel = Instance.new("Frame", SG)
Panel.Size = UDim2.new(0, 300, 0, 350); Panel.Position = UDim2.new(0.5, -150, 0.5, -175)
Panel.BackgroundColor3 = C.bg; Panel.Visible = false; Panel.Active = true; Panel.Draggable = true
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", Panel)
Title.Size = UDim2.new(1, 0, 0, 30); Title.BackgroundTransparency = 1
Title.Text = " YIN-YANG HUB"; Title.TextColor3 = C.accent; Title.Font = Enum.Font.GothamBlack; Title.TextSize = 16; Title.TextXAlignment = Enum.TextXAlignment.Left

local RoleLbl = Instance.new("TextLabel", Panel)
RoleLbl.Size = UDim2.new(1, 0, 0, 20); RoleLbl.Position = UDim2.new(0, 0, 0, 25); RoleLbl.BackgroundTransparency = 1
RoleLbl.Text = "Role: Loading..."; RoleLbl.TextColor3 = C.textDim; RoleLbl.Font = Enum.Font.Gotham; RoleLbl.TextSize = 12

RunService.RenderStepped:Connect(function()
    local r = getMyRole()
    RoleLbl.Text = "  Role: " .. r
    RoleLbl.TextColor3 = (r == "MURDERER" and Color3.new(1,0,0)) or (r == "SHERIFF" and Color3.new(0,0.5,1)) or C.textDim
end)

local CloseBtn = Instance.new("TextButton", Panel)
CloseBtn.Size = UDim2.new(0, 25, 0, 25); CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.BackgroundColor3 = C.bg2; CloseBtn.Text = "X"; CloseBtn.TextColor3 = C.text
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

-- ЛОГИКА ВКЛАДОК
local TabContainer = Instance.new("Frame", Panel)
TabContainer.Size = UDim2.new(1, -20, 1, -80); TabContainer.Position = UDim2.new(0, 10, 0, 70); TabContainer.BackgroundTransparency = 1

local tabs = {}
local function CreateTab(name, posIdx)
    local btn = Instance.new("TextButton", Panel)
    btn.Size = UDim2.new(0, 65, 0, 20); btn.Position = UDim2.new(0, 10 + (posIdx * 70), 0, 45)
    btn.BackgroundColor3 = C.bg2; btn.Text = name; btn.TextColor3 = C.textDim; btn.Font = Enum.Font.GothamBold; btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    local page = Instance.new("ScrollingFrame", TabContainer)
    page.Size = UDim2.new(1, 0, 1, 0); page.BackgroundTransparency = 1; page.Visible = false
    page.ScrollBarThickness = 3; page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 6); layout.SortOrder = Enum.SortOrder.LayoutOrder

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do t.btn.BackgroundColor3 = C.bg2; t.btn.TextColor3 = C.textDim; t.page.Visible = false end
        btn.BackgroundColor3 = C.accent; btn.TextColor3 = Color3.new(1,1,1); page.Visible = true
    end)
    
    table.insert(tabs, {btn = btn, page = page})
    return page
end

-- ==========================
-- ФУНКЦИИ СОЗДАНИЯ ЭЛЕМЕНТОВ МЕНЮ
-- ==========================
local function AddToggle(parent, name, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -10, 0, 30); btn.BackgroundColor3 = C.bg2; btn.Text = "  " .. name
    btn.TextColor3 = C.text; btn.Font = Enum.Font.Gotham; btn.TextSize = 13; btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    local indicator = Instance.new("Frame", btn)
    indicator.Size = UDim2.new(0, 16, 0, 16); indicator.Position = UDim2.new(1, -22, 0.5, -8); indicator.BackgroundColor3 = C.bg
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(0, 4)
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        indicator.BackgroundColor3 = state and C.accent or C.bg
        callback(state)
    end)
end

local function AddButton(parent, name, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -10, 0, 30); btn.BackgroundColor3 = C.bg2; btn.Text = name
    btn.TextColor3 = C.text; btn.Font = Enum.Font.GothamBold; btn.TextSize = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(callback)
end

-- ==========================
-- ЗАПОЛНЕНИЕ МЕНЮ
-- ==========================
local ESPPage = CreateTab("ESP", 0)
local MovePage = CreateTab("Move", 1)
local CombatPage = CreateTab("Combat", 2)
local UtilPage = CreateTab("Util", 3)

AddToggle(ESPPage, "ESP Players", function(v) ESPPeople = v end)
AddToggle(ESPPage, "ESP Murderer", function(v) ESPMurderer = v end)
AddToggle(ESPPage, "ESP Sheriff", function(v) ESPSheriff = v end)
AddToggle(ESPPage, "ESP Gun (Drop)", function(v) ESPGun = v end)

AddToggle(MovePage, "NoClip", function(v) _G.ToggleNoClip(v) end)

AddButton(CombatPage, "Fling Murderer", function() _G.StartFling("MURDERER") end)
AddButton(CombatPage, "Fling Sheriff", function() _G.StartFling("SHERIFF") end)
AddButton(CombatPage, "Stop Fling", function() HiddenFling = false end)

AddToggle(UtilPage, "Auto Grab Gun", function(v) _G.ToggleAutoGrabGun(v) end)
AddButton(UtilPage, "Grab Gun (Once)", function() _G.GrabGun() end)
AddButton(UtilPage, "Destroy Cheat", function() SG:Destroy() end)

-- Открываем первую вкладку по умолчанию
tabs[1].btn.BackgroundColor3 = C.accent; tabs[1].btn.TextColor3 = Color3.new(1,1,1); tabs[1].page.Visible = true

-- Открытие/Закрытие по кнопке
OpenBtn.MouseButton1Click:Connect(function() Panel.Visible = not Panel.Visible end)
CloseBtn.MouseButton1Click:Connect(function() Panel.Visible = false end)
-- // YinYang: MM2 Hub v4.0 [ИСПРАВЛЕННЫЙ] - ЧАСТЬ 3
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MurdMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

-- КНОПКА ОТКРЫТИЯ (Теперь с буквой M)
local ToggleBtn = Instance.new("ImageButton")
ToggleBtn.Size = UDim2.new(0, 42, 0, 42)
ToggleBtn.Position = UDim2.new(0, 10, 1, -68)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.ZIndex = 30
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 10)

local BtnStroke = Instance.new("UIStroke")
BtnStroke.Color = C.red
BtnStroke.Thickness = 2
BtnStroke.Parent = ToggleBtn

local BtnLabel = Instance.new("TextLabel")
BtnLabel.Size = UDim2.new(1, 0, 1, 0)
BtnLabel.BackgroundTransparency = 1
BtnLabel.Text = "M" -- Исправлено на M
BtnLabel.TextColor3 = C.red
BtnLabel.TextSize = 20
BtnLabel.Font = Enum.Font.GothamBlack
BtnLabel.ZIndex = 31
BtnLabel.Parent = ToggleBtn

-- Логика перетаскивания кнопки
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

-- ОСНОВА ПАНЕЛИ
local Overlay = Instance.new("TextButton")
Overlay.Size = UDim2.new(1, 0, 1, 0); Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Overlay.BackgroundTransparency = 1; Overlay.Text = ""; Overlay.ZIndex = 9; Overlay.Visible = false; Overlay.Parent = ScreenGui

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 280, 0, 320); Panel.Position = UDim2.new(0.5, -140, 1, 0)
Panel.BackgroundColor3 = C.bg; Panel.ZIndex = 10; Panel.Visible = false; Panel.Parent = ScreenGui
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 12)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 48); Header.Position = UDim2.new(0, 0, 0, 2); Header.BackgroundColor3 = C.bg2; Header.Parent = Panel

local LogoLbl = Instance.new("TextLabel")
LogoLbl.Size = UDim2.new(1, 0, 0, 20); LogoLbl.Position = UDim2.new(0, 0, 0, 5)
LogoLbl.BackgroundTransparency = 1; LogoLbl.Text = "YIN-YANG MODS"; LogoLbl.TextColor3 = C.red; LogoLbl.Font = Enum.Font.GothamBlack; LogoLbl.Parent = Header

local RoleLabel = Instance.new("TextLabel")
RoleLabel.Size = UDim2.new(1, -12, 0, 12); RoleLabel.Position = UDim2.new(0, 6, 0, 34)
RoleLabel.BackgroundTransparency = 1; RoleLabel.Text = "Role: Scanning..."; RoleLabel.TextColor3 = C.textDim; RoleLabel.Font = Enum.Font.Gotham; RoleLabel.TextXAlignment = Enum.TextXAlignment.Left; RoleLabel.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 22, 0, 22); CloseBtn.Position = UDim2.new(1, -28, 0, 6)
CloseBtn.BackgroundColor3 = C.redDark; CloseBtn.Text = "X"; CloseBtn.TextColor3 = C.text; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.Parent = Panel
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)

RunService.RenderStepped:Connect(function()
    local role = getMyRole()
    RoleLabel.Text = "Role: " .. role
    if role == "MURDERER" then RoleLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    elseif role == "SHERIFF" then RoleLabel.TextColor3 = Color3.fromRGB(50, 100, 255)
    else RoleLabel.TextColor3 = C.textDim end
end)

-- РЕГИСТРАЦИЯ ВКЛАДОК
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
    local layout = Instance.new("UIListLayout", content)
    layout.Padding = UDim.new(0, 5)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    btn.MouseButton1Click:Connect(function()
        for _, b in pairs(TabButtons) do b.BackgroundColor3 = C.bg3; b.TextColor3 = C.textDim end
        for _, c in pairs(TabContent) do c.Visible = false end
        btn.BackgroundColor3 = C.redDark; btn.TextColor3 = C.text; content.Visible = true
    end)
    table.insert(TabButtons, btn); table.insert(TabContent, content); return content
end

-- ВАЖНО: ДОБАВЛЕННЫЕ ФУНКЦИИ ДЛЯ СОЗДАНИЯ UI ЭЛЕМЕНТОВ
local function MakeToggle(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30); btn.BackgroundColor3 = C.bg2; btn.Text = "  " .. text
    btn.TextColor3 = C.textDim; btn.Font = Enum.Font.Gotham; btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left; btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    local status = Instance.new("Frame")
    status.Size = UDim2.new(0, 14, 0, 14); status.Position = UDim2.new(1, -20, 0.5, -7)
    status.BackgroundColor3 = C.bg3; status.Parent = btn
    Instance.new("UICorner", status).CornerRadius = UDim.new(0, 4)

    local toggled = false
    btn.MouseButton1Click:Connect(function()
        toggled = not toggled
        status.BackgroundColor3 = toggled and C.red or C.bg3
        btn.TextColor3 = toggled and C.text or C.textDim
        callback(toggled)
    end)
end

local function MakeAction(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30); btn.BackgroundColor3 = C.bg2
    btn.Text = text; btn.TextColor3 = C.text; btn.Font = Enum.Font.Gotham; btn.TextSize = 12; btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(callback)
end

local function MakeSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40); frame.BackgroundColor3 = C.bg2; frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 20); label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1; label.Text = text .. ": " .. tostring(default)
    label.TextColor3 = C.textDim; label.Font = Enum.Font.Gotham; label.TextSize = 12; label.TextXAlignment = Enum.TextXAlignment.Left; label.Parent = frame

    local track = Instance.new("TextButton")
    track.Size = UDim2.new(1, -10, 0, 6); track.Position = UDim2.new(0, 5, 0, 26)
    track.BackgroundColor3 = C.bg3; track.Text = ""; track.Parent = frame
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = C.red; fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local function update(input)
        local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        local val = math.floor(min + (max - min) * pos)
        label.Text = text .. ": " .. tostring(val)
        callback(val)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end
    end)
end

-- СОЗДАНИЕ ВКЛАДОК
local TabESP = CreateTab("ESP")
local TabMove = CreateTab("Move")
local TabCombat = CreateTab("Combat")
local TabUtil = CreateTab("Util")
TabButtons[1].BackgroundColor3 = C.redDark; TabButtons[1].TextColor3 = C.text; TabContent[1].Visible = true

-- НАПОЛНЕНИЕ ВКЛАДОК
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

-- ЛОГИКА ОТКРЫТИЯ/ЗАКРЫТИЯ
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
