-- J.A.R.V.I.S | Bypass Module

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

_G.Settings = _G.Settings or {}
_G.Settings.godMode = false

pcall(function()
    local mt = getrawmetatable(game)
    if mt then
        setreadonly(mt, false)
        local oldIndex = mt.__index
        mt.__index = newcclosure(function(self, key)
            if key == "WalkSpeed" and self == LocalPlayer.Character then
                return 16
            end
            return oldIndex(self, key)
        end)
        setreadonly(mt, true)
    end
end)

local function godModeToggle(state)
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.BreakJointsOnDeath = not state
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if _G.Settings.godMode then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.BreakJointsOnDeath = false end
    end
end)

print("J.A.R.V.I.S: Bypass Module Loaded")
