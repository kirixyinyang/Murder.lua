-- J.A.R.V.I.S | Movement Module

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

_G.Settings = _G.Settings or {}
_G.Settings.fly = false
_G.Settings.playerSpeed = 16
_G.Settings.noclip = false

local flying = false
local bodyVelocity = nil

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

print("J.A.R.V.I.S: Movement Module Loaded")
