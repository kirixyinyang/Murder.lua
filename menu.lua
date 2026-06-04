-- J.A.R.V.I.S | PART 1/2 (Menu + ESP + AIM)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local StartTime = tick()
local Camera = workspace.CurrentCamera

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
_G.Settings.playerESP = false
_G.Settings.xray = false
_G.Settings.gunESP = false
_G.Settings.aimbot = false
_G.Settings.aimTarget = "Murderer"
_G.Settings.aimFOV = 250
_G.Settings.autoShoot = false
_G.Settings.fly = false
_G.Settings.noclip = false
_G.Settings.godMode = false
_G.Settings.playerSpeed = 16
_G.Settings.autoFarm = false
_G.Settings.farmSpeed = 50
_G.Settings.antiAFK = false

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

local function getHRP(p)
    if p and p.Character then return p.Character:FindFirstChild("HumanoidRootPart") end
    return nil
end

-- ESP
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "JARVIS_ESP"
ESPFolder.Parent = game:GetService("CoreGui")

local function addESP(player)
    if player == LocalPlayer then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = player.Name .. "_ESP"
    highlight.FillTransparency = 0.6
    highlight.OutlineTransparency = 0.1
    highlight.Parent = ESPFolder
    
    local function updateColor()
        local role = getRole(player)
        if role == "Murderer" then
            highlight.FillColor = colors.murderer
        elseif role == "Sheriff" then
            highlight.FillColor = colors.sheriff
        else
            highlight.FillColor = colors.innocent
        end
    end
    
    updateColor()
    if player.Character then highlight.Adornee = player.Character end
    player.CharacterAdded:Connect(function(char) highlight.Adornee = char; updateColor() end)
end

for _, player in pairs(Players:GetPlayers()) do addESP(player) end
Players.PlayerAdded:Connect(addESP)

task.spawn(function()
    while true do
        if _G.Settings.gunESP then
            for _, item in pairs(workspace:GetDescendants()) do
                if item:IsA("Tool") and (item.Name:lower():find("gun") or item.Name:lower():find("pistol")) and not item:FindFirstChild("GunESP") then
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "GunESP"
                    bb.Size = UDim2.new(0, 100, 0, 40)
                    bb.StudsOffset = Vector3.new(0, 2, 0)
                    bb.AlwaysOnTop = true
                    bb.Parent = item
                    local lbl = Instance.new("TextLabel")
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.Text = "GUN"
                    lbl.TextColor3 = colors.gun
                    lbl.TextSize = 14
                    lbl.Font = Enum.Font.GothamBold
                    lbl.Parent = bb
                end
            end
        end
        task.wait(0.5)
    end
end)

-- FOV круг
local fovGui = Instance.new("ScreenGui")
fovGui.Name = "FOVCircle"
fovGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
fovGui.ResetOnSpawn = false

local fovCircle = Instance.new("ImageLabel")
fovCircle.Size = UDim2.new(0, _G.Settings.aimFOV * 2, 0, _G.Settings.aimFOV * 2)
fovCircle.Position = UDim2.new(0.5, -_G.Settings.aimFOV, 0.5, -_G.Settings.aimFOV)
fovCircle.BackgroundTransparency = 1
fovCircle.Image = "rbxassetid://15097438680"
fovCircle.ImageColor3 = colors.primary
fovCircle.ImageTransparency = 0.5
fovCircle.Visible = false
fovCircle.Parent = fovGui

local function updateFOVCircle()
    fovCircle.Size = UDim2.new(0, _G.Settings.aimFOV * 2, 0, _G.Settings.aimFOV * 2)
    fovCircle.Position = UDim2.new(0.5, -_G.Settings.aimFOV, 0.5, -_G.Settings.aimFOV)
end

-- Aimbot
local function isVisible(player)
    if not player or not player.Character then return false end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local origin = Camera.CFrame.Position
    local ray = Ray.new(origin, (hrp.Position - origin).Unit * (origin - hrp.Position).Magnitude)
    local hit = workspace:FindPartOnRay(ray, LocalPlayer.Character)
    if hit then return Players:GetPlayerFromCharacter(hit.Parent) == player end
    return false
end

local function getAimTarget()
    local targetRole = _G.Settings.aimTarget
    local closestDist = _G.Settings.aimFOV
    local closestHRP = nil
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isVisible(player) then
            local role = getRole(player)
            local match = (targetRole == "Murderer" and role == "Murderer") or (targetRole == "Sheriff" and role == "Sheriff")
            if not match then continue end
            local hrp = getHRP(player)
            if not hrp then continue end
            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if not onScreen then continue end
            local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
            if dist < closestDist then
                closestDist = dist
                closestHRP = hrp
            end
        end
    end
    return closestHRP
end

task.spawn(function()
    while true do
        if _G.Settings.aimbot then
            local target = getAimTarget()
            if target then
                pcall(function() Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position) end)
                if _G.Settings.autoShoot then
                    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("ThrowKnife")
                    if remote then pcall(function() remote:FireServer() end) end
                end
            end
        end
        task.wait(0.03)
    end
end)

-- MENU GUI
local gui = Instance.new("ScreenGui")
gui.Name = "JARVIS_Menu"
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false
gui.Visible = false

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 340, 0, 480)
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
        if text == "AIMBOT" then
            fovCircle.Visible = val
        end
        if text == "HIDE FOV" then
            fovCircle.Visible = not val
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

local tabsList = {"INFO", "KILLER", "ESP", "AIM", "MOVEMENT", "FARM"}
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
            warn.Text = "Use at your own risk!"
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
            addToggle("AIMBOT", _G.Settings.aimbot, function(v) 
                _G.Settings.aimbot = v
                fovCircle.Visible = v
            end)
            addSep("TARGET")
            addButton("MURDERER", colors.murderer, function() _G.Settings.aimTarget = "Murderer" end)
            addButton("SHERIFF", colors.sheriff, function() _G.Settings.aimTarget = "Sheriff" end)
            addSep("FOV")
            addButton("FOV 150", nil, function() _G.Settings.aimFOV = 150; updateFOVCircle() end)
            addButton("FOV 250", nil, function() _G.Settings.aimFOV = 250; updateFOVCircle() end)
            addButton("FOV 360", nil, function() _G.Settings.aimFOV = 360; updateFOVCircle() end)
            addToggle("AUTO SHOOT", _G.Settings.autoShoot, function(v) _G.Settings.autoShoot = v end)
            addToggle("HIDE FOV", false, function(v) 
                fovCircle.Visible = not v and _G.Settings.aimbot
            end)
        end
    end)
end

task.wait(0.1)
if tabBtns["INFO"] then
    tabBtns["INFO"].btn.MouseButton1Click:Fire()
end

print("PART 1/2 LOADED")
-- J.A.R.V.I.S | PART 2/2 (MOVEMENT + FARM + Кнопка)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

_G.Settings = _G.Settings or {}

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

local function getHRP(p)
    if p and p.Character then return p.Character:FindFirstChild("HumanoidRootPart") end
    return nil
end

-- KILL ALL и TELEPORT функции
local function killAll()
    local knife = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Knife")
    if not knife then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = getHRP(player)
            if hrp then
                pcall(function()
                    LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame
                    task.wait(0.05)
                end)
            end
        end
    end
end

local function killSheriff()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and getRole(player) == "Sheriff" then
            local hrp = getHRP(player)
            if hrp then
                LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame
            end
            return
        end
    end
end

local function teleportToMurderer()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and getRole(player) == "Murderer" then
            local hrp = getHRP(player)
            if hrp then
                LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame + Vector3.new(3,0,0)
            end
            return
        end
    end
end

local function teleportToSheriff()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and getRole(player) == "Sheriff" then
            local hrp = getHRP(player)
            if hrp then
                LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame + Vector3.new(3,0,0)
            end
            return
        end
    end
end

local function teleportToGun()
    for _, item in pairs(workspace:GetDescendants()) do
        if item:IsA("Tool") and (item.Name:lower():find("gun") or item.Name:lower():find("pistol")) then
            local handle = item:FindFirstChild("Handle") or item:FindFirstChildOfClass("BasePart")
            if handle then
                LocalPlayer.Character.HumanoidRootPart.CFrame = handle.CFrame + Vector3.new(0,3,0)
                return
            end
        end
    end
end

local function autoShoot()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and getRole(player) == "Murderer" then
            local hrp = getHRP(player)
            if hrp then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, hrp.Position)
                local gun = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun")
                if gun then
                    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Shoot")
                    if remote then remote:FireServer(hrp.Position) end
                end
            end
            return
        end
    end
end

-- FLY
local flying = false
local bodyVelocity = nil

local function startFly()
    flying = true
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.PlatformStand = true end
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1,1,1) * 100000
    bodyVelocity.Parent = hrp
end

local function stopFly()
    flying = false
    if bodyVelocity then bodyVelocity:Destroy() end
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.PlatformStand = false end
    end
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F then
        _G.Settings.fly = not _G.Settings.fly
        if _G.Settings.fly then startFly() else stopFly() end
    end
end)

RunService.RenderStepped:Connect(function()
    if flying then
        local dir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Vector3.new(0,0,-1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir + Vector3.new(0,0,1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir + Vector3.new(-1,0,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Vector3.new(1,0,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir + Vector3.new(0,-1,0) end
        dir = (Camera.CFrame.RightVector * dir.X + Camera.CFrame.UpVector * dir.Y + Camera.CFrame.LookVector * dir.Z) * 50
        if bodyVelocity then bodyVelocity.Velocity = dir end
    end
end)

-- GOD MODE, NOCLIP, SPEED
local function applySettings()
    local char = LocalPlayer.Character
    if not char then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = _G.Settings.playerSpeed
        if _G.Settings.godMode then
            humanoid.BreakJointsOnDeath = false
        else
            humanoid.BreakJointsOnDeath = true
        end
    end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CanCollide = not _G.Settings.noclip
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    applySettings()
end)

task.spawn(function()
    while true do
        applySettings()
        task.wait(0.5)
    end
end)

-- FARM
local farmConnection = nil

local function getCoins()
    local coins = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("gem")) then
            table.insert(coins, obj)
        end
    end
    return coins
end

local function startFarm()
    if farmConnection then farmConnection:Disconnect() end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.PlatformStand = true end
    
    farmConnection = RunService.Heartbeat:Connect(function()
        if not _G.Settings.autoFarm then
            if humanoid then humanoid.PlatformStand = false end
            if farmConnection then farmConnection:Disconnect(); farmConnection = nil end
            return
        end
        local coins = getCoins()
        if #coins == 0 then return end
        local nearest, nearDist
        for _, c in ipairs(coins) do
            local d = (hrp.Position - c.Position).Magnitude
            if not nearDist or d < nearDist then
                nearDist = d
                nearest = c
            end
        end
        if nearest then
            local dir = (nearest.Position - hrp.Position).Unit
            hrp.CFrame = hrp.CFrame + dir * (_G.Settings.farmSpeed * 0.016)
        end
    end)
end

local function stopFarm()
    if farmConnection then farmConnection:Disconnect(); farmConnection = nil end
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.PlatformStand = false end
    end
end

-- ANTI AFK
local function startAntiAFK()
    pcall(function()
        local vu = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            if _G.Settings.antiAFK then
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end
        end)
    end)
end

-- ПОДКЛЮЧЕНИЕ КНОПОК К МЕНЮ
task.wait(1)
local gui = LocalPlayer.PlayerGui:FindFirstChild("JARVIS_Menu")
if gui then
    for _, btn in pairs(gui:GetDescendants()) do
        if btn:IsA("TextButton") then
            if btn.Text == "KILL ALL" then
                btn.MouseButton1Click:Connect(killAll)
            elseif btn.Text == "KILL SHERIFF" then
                btn.MouseButton1Click:Connect(killSheriff)
            elseif btn.Text == "TELEPORT TO MURDERER" then
                btn.MouseButton1Click:Connect(teleportToMurderer)
            elseif btn.Text == "TELEPORT TO SHERIFF" then
                btn.MouseButton1Click:Connect(teleportToSheriff)
            elseif btn.Text == "TELEPORT TO GUN" then
                btn.MouseButton1Click:Connect(teleportToGun)
            elseif btn.Text == "AUTO SHOOT" then
                btn.MouseButton1Click:Connect(autoShoot)
            end
        end
    end
end

-- FARM триггер
task.spawn(function()
    while true do
        if _G.Settings.autoFarm then
            startFarm()
        else
            stopFarm()
        end
        task.wait(0.5)
    end
end)

-- ANTI AFK триггер
if _G.Settings.antiAFK then
    startAntiAFK()
end

-- ПЛАВАЮЩАЯ КНОПКА JARVIS
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
local mainMenu = gui

jarvisBtn.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    if mainMenu then mainMenu.Visible = menuVisible end
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

print("PART 2/2 LOADED - Кнопка JARVIS активна")
