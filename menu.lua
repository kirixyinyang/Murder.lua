-- J.A.R.V.I.S | Menu Module

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local StartTime = tick()

local colors = {
    primary = Color3.fromRGB(80, 255, 100),
    dark = Color3.fromRGB(5, 12, 7),
    panel = Color3.fromRGB(8, 18, 10),
    text = Color3.fromRGB(220, 255, 220),
    textDim = Color3.fromRGB(80, 140, 90),
    murderer = Color3.fromRGB(255, 50, 50),
    sheriff = Color3.fromRGB(50, 80, 255),
    innocent = Color3.fromRGB(50, 255, 80),
    gun = Color3.fromRGB(0, 150, 255),
    danger = Color3.fromRGB(255, 30, 30),
    warning = Color3.fromRGB(255, 200, 0)
}

_G.Settings = _G.Settings or {}

local function formatTime(s)
    local m = math.floor((s % 3600) / 60)
    local sec = math.floor(s % 60)
    return string.format("%02d:%02d", m, sec)
end

local function getRole(p)
    if not p then return "Innocent" end
    local char = p.Character
    if not char then return "Innocent" end
    if char:FindFirstChild("Knife") or (p.Backpack and p.Backpack:FindFirstChild("Knife")) then
        return "Murderer"
    end
    if char:FindFirstChild("Gun") or (p.Backpack and p.Backpack:FindFirstChild("Gun")) then
        return "Sheriff"
    end
    return "Innocent"
end

local gui = Instance.new("ScreenGui")
gui.Name = "JARVIS_Menu"
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false
gui.Visible = false

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 340, 0, 450)
main.Position = UDim2.new(0.5, -170, 0.15, 0)
main.BackgroundColor3 = colors.dark
main.BackgroundTransparency = 0.1
main.BorderSizePixel = 0
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = main

local title = Instance.new("Frame")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundColor3 = colors.panel
title.BackgroundTransparency = 0.1
title.Parent = main

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = title

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, 0, 1, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "J.A.R.V.I.S  |  MM2"
titleText.TextColor3 = colors.primary
titleText.TextSize = 18
titleText.Font = Enum.Font.GothamBold
titleText.Parent = title

local drag = false
local dragStart, mainStart

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        drag = true
        dragStart = input.Position
        mainStart = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then drag = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if drag and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(mainStart.X.Scale, mainStart.X.Offset + delta.X, mainStart.Y.Scale, mainStart.Y.Offset + delta.Y)
    end
end)

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 28, 0, 28)
close.Position = UDim2.new(1, -38, 0, 8)
close.BackgroundColor3 = Color3.fromRGB(50, 10, 10)
close.Text = "X"
close.TextColor3 = Color3.fromRGB(255, 80, 80)
close.TextSize = 14
close.Font = Enum.Font.GothamBold
close.Parent = title
close.MouseButton1Click:Connect(function() gui.Visible = false end)

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 100, 1, -45)
sidebar.Position = UDim2.new(0, 0, 0, 45)
sidebar.BackgroundColor3 = Color3.fromRGB(5, 14, 8)
sidebar.BorderSizePixel = 0
sidebar.Parent = main

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -110, 1, -55)
content.Position = UDim2.new(0, 105, 0, 50)
content.BackgroundColor3 = Color3.fromRGB(8, 18, 10)
content.BackgroundTransparency = 0.5
content.BorderSizePixel = 0
content.ScrollBarThickness = 6
content.ScrollBarImageColor3 = colors.primary
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.Parent = main

local contentList = Instance.new("UIListLayout")
contentList.Padding = UDim.new(0, 6)
contentList.SortOrder = Enum.SortOrder.LayoutOrder
contentList.Parent = content

contentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    content.CanvasSize = UDim2.new(0, 0, 0, contentList.AbsoluteContentSize.Y + 10)
end)

local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 8)
pad.PaddingBottom = UDim.new(0, 8)
pad.PaddingLeft = UDim.new(0, 8)
pad.PaddingRight = UDim.new(0, 8)
pad.Parent = content

local order = 0

local function addToggle(text, setting, callback)
    order = order + 1
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = colors.panel
    row.BackgroundTransparency = 0.3
    row.LayoutOrder = order
    row.Parent = content
    
    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 8)
    rowCorner.Parent = row
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.65, 0, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = colors.text
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 40, 0, 20)
    bg.Position = UDim2.new(1, -50, 0.5, -10)
    bg.BackgroundColor3 = setting and colors.primary or Color3.fromRGB(40,40,50)
    bg.Parent = row
    
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(1, 0)
    bgCorner.Parent = bg
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = setting and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.Parent = bg
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
    local val = setting
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = row
    
    btn.MouseButton1Click:Connect(function()
        val = not val
        bg.BackgroundColor3 = val and colors.primary or Color3.fromRGB(40,40,50)
        local goal = val and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
        TweenService:Create(knob, TweenInfo.new(0.2), {Position = goal}):Play()
        callback(val)
        if text == "AIMBOT" and val == false then
            if fovCircle then fovCircle.Visible = false end
        elseif text == "AIMBOT" and val == true then
            if fovCircle then fovCircle.Visible = not _G.Settings.hideFOV end
        end
        if text == "HIDE FOV" then
            if fovCircle then fovCircle.Visible = not val end
        end
    end)
end

local function addButton(text, color, callback)
    order = order + 1
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = color or colors.panel
    btn.BackgroundTransparency = 0.3
    btn.Text = text
    btn.TextColor3 = colors.text
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.LayoutOrder = order
    btn.Parent = content
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
end

local function addSep(text)
    order = order + 1
    local sep = Instance.new("TextLabel")
    sep.Size = UDim2.new(1, 0, 0, 24)
    sep.BackgroundTransparency = 1
    sep.Text = "--- " .. text .. " ---"
    sep.TextColor3 = colors.textDim
    sep.TextSize = 10
    sep.Font = Enum.Font.GothamSemibold
    sep.TextXAlignment = Enum.TextXAlignment.Left
    sep.LayoutOrder = order
    sep.Parent = content
end

local function addInfo(label, value, color)
    order = order + 1
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = colors.panel
    row.BackgroundTransparency = 0.3
    row.LayoutOrder = order
    row.Parent = content
    
    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 8)
    rowCorner.Parent = row
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = colors.textDim
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row
    
    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(0.45, 0, 1, 0)
    val.Position = UDim2.new(0.52, 0, 0, 0)
    val.BackgroundTransparency = 1
    val.Text = value
    val.TextColor3 = color or colors.primary
    val.TextSize = 12
    val.Font = Enum.Font.GothamBold
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.Parent = row
    
    return val
end

local function clear()
    order = 0
    for _, child in pairs(content:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end
end

local tabsList = {"INFO", "KILLER", "ESP", "AIM", "MOVEMENT", "FARM", "MISC"}
local tabBtns = {}
local current = nil

for i, name in pairs(tabsList) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.Position = UDim2.new(0, 0, 0, (i-1) * 42)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = colors.textDim
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = sidebar
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 3, 0, 25)
    line.Position = UDim2.new(0, 0, 0.5, -12.5)
    line.BackgroundColor3 = colors.primary
    line.BorderSizePixel = 0
    line.Visible = false
    line.Parent = btn
    
    tabBtns[name] = {btn = btn, line = line}
    
    btn.MouseButton1Click:Connect(function()
        for _, tb in pairs(tabBtns) do
            tb.btn.TextColor3 = colors.textDim
            tb.line.Visible = false
        end
        btn.TextColor3 = colors.primary
        line.Visible = true
        current = name
        clear()
        
        if name == "INFO" then
            addInfo("NICK", LocalPlayer.Name, colors.primary)
            local roleVal = addInfo("ROLE", getRole(LocalPlayer), getRole(LocalPlayer) == "Murderer" and colors.murderer or (getRole(LocalPlayer) == "Sheriff" and colors.sheriff or colors.innocent))
            local timeVal = addInfo("TIME", "00:00", colors.primary)
            addInfo("STATUS", "ACTIVE", colors.primary)
            addInfo("RISK", "DANGER!", colors.danger)
            addSep("WARNING")
            local warn = Instance.new("TextLabel")
            warn.Size = UDim2.new(1, 0, 0, 40)
            warn.BackgroundTransparency = 1
            warn.Text = "Using cheats may result in a ban. Use at your own risk!"
            warn.TextColor3 = colors.warning
            warn.TextSize = 10
            warn.Font = Enum.Font.Gotham
            warn.TextWrapped = true
            warn.LayoutOrder = order + 1
            order = order + 1
            warn.Parent = content
            
            task.spawn(function()
                while current == "INFO" do
                    local elapsed = tick() - StartTime
                    if timeVal then timeVal.Text = formatTime(elapsed) end
                    if roleVal then
                        local newRole = getRole(LocalPlayer)
                        roleVal.Text = newRole
                        if newRole == "Murderer" then roleVal.TextColor3 = colors.murderer
                        elseif newRole == "Sheriff" then roleVal.TextColor3 = colors.sheriff
                        else roleVal.TextColor3 = colors.innocent end
                    end
                    task.wait(1)
                end
            end)
            
        elseif name == "KILLER" then
            addSep("MURDERER ACTIONS")
            addButton("KILL ALL", colors.murderer, function() end)
            addButton("KILL SHERIFF", colors.murderer, function() end)
            addButton("TELEPORT TO MURDERER", colors.murderer, function() end)
            addSep("SHERIFF ACTIONS")
            addButton("TELEPORT TO SHERIFF", colors.sheriff, function() end)
            addButton("TELEPORT TO GUN", colors.gun, function() end)
            addButton("AUTO SHOOT", colors.sheriff, function() end)
            
        elseif name == "ESP" then
            addToggle("PLAYER ESP", _G.Settings.playerESP, function(v) _G.Settings.playerESP = v end)
            addToggle("XRAY", _G.Settings.xray, function(v) _G.Settings.xray = v end)
            addToggle("GUN ESP", _G.Settings.gunESP, function(v) _G.Settings.gunESP = v end)
            addSep("INNOCENT COLOR")
            addButton("GREEN", nil, function() _G.Settings.espColor = "Green" end)
            addButton("YELLOW", nil, function() _G.Settings.espColor = "Yellow" end)
            addButton("RED", nil, function() _G.Settings.espColor = "Red" end)
            
        elseif name == "AIM" then
            addToggle("AIMBOT", _G.Settings.aimbot, function(v) _G.Settings.aimbot = v end)
            addSep("TARGET")
            addButton("MURDERER", colors.murderer, function() _G.Settings.aimTarget = "Murderer" end)
            addButton("SHERIFF", colors.sheriff, function() _G.Settings.aimTarget = "Sheriff" end)
            addSep("FOV")
            addButton("FOV 150", nil, function() _G.Settings.aimFOV = 150 end)
            addButton("FOV 250", nil, function() _G.Settings.aimFOV = 250 end)
            addButton("FOV 360", nil, function() _G.Settings.aimFOV = 360 end)
            addToggle("AUTO SHOOT", _G.Settings.autoShoot, function(v) _G.Settings.autoShoot = v end)
            addToggle("HIDE FOV", _G.Settings.hideFOV, function(v) _G.Settings.hideFOV = v end)
            
        elseif name == "MOVEMENT" then
            addToggle("FLY (F KEY)", _G.Settings.fly, function(v) _G.Settings.fly = v end)
            addToggle("NOCLIP", _G.Settings.noclip, function(v) _G.Settings.noclip = v end)
            addToggle("GOD MODE", _G.Settings.godMode, function(v) _G.Settings.godMode = v end)
            addSep("SPEED")
            addButton("SPEED 16", nil, function() _G.Settings.playerSpeed = 16 end)
            addButton("SPEED 32", nil, function() _G.Settings.playerSpeed = 32 end)
            addButton("SPEED 50", nil, function() _G.Settings.playerSpeed = 50 end)
            
        elseif name == "FARM" then
            addToggle("AUTO FARM", _G.Settings.autoFarm, function(v) _G.Settings.autoFarm = v end)
            addSep("FARM SPEED")
            addButton("SPEED 30", nil, function() _G.Settings.farmSpeed = 30 end)
            addButton("SPEED 50", nil, function() _G.Settings.farmSpeed = 50 end)
            addButton("SPEED 80", nil, function() _G.Settings.farmSpeed = 80 end)
            addButton("SPEED 100", nil, function() _G.Settings.farmSpeed = 100 end)
            
        elseif name == "MISC" then
            addToggle("ANTI AFK", _G.Settings.antiAFK, function(v) _G.Settings.antiAFK = v end)
            addSep("VERSION")
            local ver = Instance.new("TextLabel")
            ver.Size = UDim2.new(1, 0, 0, 30)
            ver.BackgroundTransparency = 1
            ver.Text = "J.A.R.V.I.S V8.0"
            ver.TextColor3 = colors.textDim
            ver.TextSize = 11
            ver.Font = Enum.Font.Gotham
            ver.LayoutOrder = order + 1
            order = order + 1
            ver.Parent = content
        end
    end)
end

task.wait(0.1)
if tabBtns["INFO"] then
    tabBtns["INFO"].btn.MouseButton1Click:Fire()
end

-- ========== ПЛАВАЮЩАЯ КНОПКА JARVIS ==========

local floatingGui = Instance.new("ScreenGui")
floatingGui.Name = "JarvisButton"
floatingGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
floatingGui.ResetOnSpawn = false

local jarvisBtn = Instance.new("ImageButton")
jarvisBtn.Size = UDim2.new(0, 65, 0, 65)
jarvisBtn.Position = UDim2.new(0.85, 0, 0.82, 0)
jarvisBtn.BackgroundColor3 = Color3.fromRGB(80, 255, 100)
jarvisBtn.BackgroundTransparency = 0.15
jarvisBtn.BorderSizePixel = 0
jarvisBtn.Parent = floatingGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0)
btnCorner.Parent = jarvisBtn

local btnLabel = Instance.new("TextLabel")
btnLabel.Size = UDim2.new(1, 0, 1, 0)
btnLabel.BackgroundTransparency = 1
btnLabel.Text = "JARVIS"
btnLabel.TextSize = 11
btnLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
btnLabel.Font = Enum.Font.GothamBold
btnLabel.TextStrokeTransparency = 0
btnLabel.TextStrokeColor3 = Color3.fromRGB(0, 100, 0)
btnLabel.Parent = jarvisBtn

local pulse = TweenService:Create(jarvisBtn, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true), {BackgroundTransparency = 0.05})
pulse:Play()

local menuVisible = false

jarvisBtn.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    gui.Visible = menuVisible
    jarvisBtn.BackgroundColor3 = menuVisible and Color3.fromRGB(100, 255, 120) or Color3.fromRGB(80, 255, 100)
    task.wait(0.1)
    jarvisBtn.BackgroundColor3 = Color3.fromRGB(80, 255, 100)
end)

local dragActive = false
local dragStartPos, btnStartPos
local btnStartOffset = {X = 0, Y = 0}

jarvisBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragActive = true
        dragStartPos = input.Position
        btnStartOffset.X = jarvisBtn.Position.X.Offset
        btnStartOffset.Y = jarvisBtn.Position.Y.Offset
        btnStartPos = jarvisBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragActive = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragActive and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStartPos
        jarvisBtn.Position = UDim2.new(
            btnStartPos.X.Scale,
            btnStartOffset.X + delta.X,
            btnStartPos.Y.Scale,
            btnStartOffset.Y + delta.Y
        )
    end
end)

print("J.A.R.V.I.S: Menu Module Loaded")
print("Нажми на зелёную кнопку JARVIS для открытия меню")
