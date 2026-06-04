-- J.A.R.V.I.S | Main Loader

local repo = "https://raw.githubusercontent.com/kirixyinyang/Murder.lua/refs/heads/main/"

local modules = {"bypass", "esp", "combat", "movement", "farm", "menu"}

for _, name in pairs(modules) do
    local url = repo .. name .. ".lua"
    local success, content = pcall(function() return game:HttpGet(url) end)
    if success then
        local func, err = loadstring(content)
        if func then func() else warn("Error in " .. name .. ": " .. err) end
    else
        warn("Failed load " .. name .. ": " .. content)
    end
    task.wait(0.3)
end

print("J.A.R.V.I.S: ALL MODULES LOADED")
