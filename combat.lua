-- J.A.R.V.I.S | Combat Module

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

_G.Settings = _G.Settings or {}

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
    if p and p.Character then
        return p.Character:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

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

print("J.A.R.V.I.S: Combat Module Loaded")
