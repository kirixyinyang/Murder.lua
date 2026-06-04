-- J.A.R.V.I.S | ESP Module

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

_G.Settings = _G.Settings or {}
_G.Settings.playerESP = true
_G.Settings.xray = true
_G.Settings.gunESP = true

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "JARVIS_ESP"
ESPFolder.Parent = game:GetService("CoreGui")

local function getPlayerRole(player)
    if player == LocalPlayer then return nil end
    local char = player.Character
    if not char then return "Innocent" end
    if char:FindFirstChild("Knife") or (player.Backpack and player.Backpack:FindFirstChild("Knife")) then
        return "Murderer"
    end
    if char:FindFirstChild("Gun") or (player.Backpack and player.Backpack:FindFirstChild("Gun")) then
        return "Sheriff"
    end
    return "Innocent"
end

local function addESP(player)
    if player == LocalPlayer then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = player.Name .. "_ESP"
    highlight.FillTransparency = _G.Settings.xray and 0.35 or 0.6
    highlight.OutlineTransparency = 0.1
    highlight.DepthMode = _G.Settings.xray and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
    highlight.Parent = ESPFolder
    
    local function updateColor()
        local role = getPlayerRole(player)
        if role == "Murderer" then
            highlight.FillColor = Color3.fromRGB(255, 50, 50)
        elseif role == "Sheriff" then
            highlight.FillColor = Color3.fromRGB(50, 80, 255)
        else
            highlight.FillColor = Color3.fromRGB(50, 255, 80)
        end
        highlight.OutlineColor = highlight.FillColor
    end
    
    updateColor()
    
    if player.Character then
        highlight.Adornee = player.Character
    end
    
    player.CharacterAdded:Connect(function(char)
        highlight.Adornee = char
        updateColor()
    end)
end

for _, player in pairs(Players:GetPlayers()) do
    addESP(player)
end

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
                    lbl.Text = "🔫 GUN"
                    lbl.TextColor3 = Color3.fromRGB(0, 150, 255)
                    lbl.TextSize = 14
                    lbl.Font = Enum.Font.GothamBold
                    lbl.Parent = bb
                end
            end
        end
        task.wait(0.5)
    end
end)

print("J.A.R.V.I.S: ESP Module Loaded")
