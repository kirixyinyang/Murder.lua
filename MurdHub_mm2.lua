-- MurdMenu.lua
-- LocalScript -> StarterPlayerScripts

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ============================================================
-- ЦВЕТА
-- ============================================================
local C = {
    bg        = Color3.fromRGB(8,   8,   8),
    bg2       = Color3.fromRGB(14,  14,  14),
    bg3       = Color3.fromRGB(20,  20,  20),
    red       = Color3.fromRGB(200,  0,   0),
    redBright = Color3.fromRGB(255, 30,  30),
    redDark   = Color3.fromRGB(80,   0,   0),
    redGlow   = Color3.fromRGB(120,  0,   0),
    text      = Color3.fromRGB(235, 235, 235),
    textDim   = Color3.fromRGB(100, 100, 100),
    black     = Color3.fromRGB(0,    0,   0),
}

-- ============================================================
-- GUI
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MurdMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

-- ============================================================
-- КНОПКА ОТКРЫТИЯ (логотип)
-- ============================================================
local ToggleBtn = Instance.new("ImageButton")
ToggleBtn.Size = UDim2.new(0, 70, 0, 70)
ToggleBtn.Position = UDim2.new(0, 16, 1, -90)
ToggleBtn.BackgroundColor3 = C.black
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Image = "" -- сюда вставь rbxassetid логотипа если загрузишь
ToggleBtn.ZIndex = 30
ToggleBtn.Parent = ScreenGui

-- Красная обводка кнопки
local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = C.red
ToggleStroke.Thickness = 2
ToggleStroke.Parent = ToggleBtn

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 14)
ToggleCorner.Parent = ToggleBtn

-- Текст на кнопке (пока нет картинки)
local ToggleLabel = Instance.new("TextLabel")
ToggleLabel.Size = UDim2.new(1, 0, 1, 0)
ToggleLabel.BackgroundTransparency = 1
ToggleLabel.Text = "M"
ToggleLabel.TextColor3 = C.red
ToggleLabel.TextSize = 28
ToggleLabel.Font = Enum.Font.GothamBlack
ToggleLabel.ZIndex = 31
ToggleLabel.Parent = ToggleBtn

-- Пульсация кнопки
local function pulseBtn()
    TweenService:Create(ToggleStroke, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {Thickness = 4}):Play()
end
pulseBtn()

-- ============================================================
-- ЗАТЕМНЕНИЕ ФОНА
-- ============================================================
local Overlay = Instance.new("Frame")
Overlay.Size = UDim2.new(1, 0, 1, 0)
Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Overlay.BackgroundTransparency = 1
Overlay.ZIndex = 9
Overlay.Visible = false
Overlay.Parent = ScreenGui

-- ============================================================
-- ГЛАВНАЯ ПАНЕЛЬ
-- ============================================================
local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(1, 0, 0, 520)
Panel.Position = UDim2.new(0, 0, 1, 0) -- скрыта снизу
Panel.BackgroundColor3 = C.bg
Panel.BorderSizePixel = 0
Panel.ZIndex = 10
Panel.Visible = false
Panel.Parent = ScreenGui

local PanelCorner = Instance.new("UICorner")
PanelCorner.CornerRadius = UDim.new(0, 20)
PanelCorner.Parent = Panel

-- Верхняя красная полоса
local TopLine = Instance.new("Frame")
TopLine.Size = UDim2.new(1, 0, 0, 3)
TopLine.Position = UDim2.new(0, 0, 0, 0)
TopLine.BackgroundColor3 = C.red
TopLine.BorderSizePixel = 0
TopLine.ZIndex = 11
TopLine.Parent = Panel

-- ============================================================
-- ШАПКА С ЛОГОТИПОМ
-- ============================================================
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 140)
Header.Position = UDim2.new(0, 0, 0, 3)
Header.BackgroundColor3 = C.bg2
Header.BorderSizePixel = 0
Header.ZIndex = 11
Header.Parent = Panel

-- Логотип (ImageLabel)
local Logo = Instance.new("ImageLabel")
Logo.Size = UDim2.new(0, 110, 0, 110)
Logo.Position = UDim2.new(0.5, -55, 0.5, -55)
Logo.BackgroundTransparency = 1
Logo.Image = "" -- rbxassetid://ТВОЙ_ID — загрузи картинку в Roblox и вставь ID
Logo.ZIndex = 12
Logo.Parent = Header

-- Если картинка не загружена — показываем текст
local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(1, 0, 1, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text = "MURD\nSCRIPT"
LogoText.TextColor3 = C.red
LogoText.TextSize = 26
LogoText.Font = Enum.Font.GothamBlack
LogoText.LineHeight = 1.1
LogoText.ZIndex = 13
LogoText.Parent = Header

-- Красный градиент под шапкой
local HeaderGrad = Instance.new("UIGradient")
HeaderGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.redDark),
    ColorSequenceKeypoint.new(1, C.bg2),
})
HeaderGrad.Rotation = 90
HeaderGrad.Parent = Header

-- ============================================================
-- КНОПКА ЗАКРЫТЬ
-- ============================================================
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 36, 0, 36)
CloseBtn.Position = UDim2.new(1, -46, 0, 10)
CloseBtn.BackgroundColor3 = C.redDark
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.TextColor3 = C.text
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.ZIndex = 20
CloseBtn.Parent = Panel

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

-- ============================================================
-- КОНТЕНТ — КНОПКИ МЕНЮ
-- ============================================================
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -24, 1, -160)
Content.Position = UDim2.new(0, 12, 0, 148)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 3
Content.ScrollBarImageColor3 = C.red
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.ZIndex = 11
Content.Parent = Panel

local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 8)
ListLayout.Parent = Content

-- ============================================================
-- HELPER: СЕКЦИЯ
-- ============================================================
local function SectionLabel(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = C.redBright
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 12
    lbl.Parent = Content
    return lbl
end

-- ============================================================
-- HELPER: TOGGLE КНОПКА
-- ============================================================
local function ToggleButton(labelText, descText, onToggle)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 58)
    row.BackgroundColor3 = C.bg3
    row.BorderSizePixel = 0
    row.ZIndex = 12
    row.Parent = Content

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 10)
    rowCorner.Parent = row

    local rowStroke = Instance.new("UIStroke")
    rowStroke.Color = C.redDark
    rowStroke.Thickness = 1
    rowStroke.Parent = row

    -- Название
    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, -70, 0, 28)
    name.Position = UDim2.new(0, 14, 0, 6)
    name.BackgroundTransparency = 1
    name.Text = labelText
    name.TextColor3 = C.text
    name.TextSize = 15
    name.Font = Enum.Font.GothamBold
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.ZIndex = 13
    name.Parent = row

    -- Описание
    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -70, 0, 18)
    desc.Position = UDim2.new(0, 14, 0, 34)
    desc.BackgroundTransparency = 1
    desc.Text = descText
    desc.TextColor3 = C.textDim
    desc.TextSize = 11
    desc.Font = Enum.Font.Gotham
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.ZIndex = 13
    desc.Parent = row

    -- Тоггл фон
    local togBg = Instance.new("Frame")
    togBg.Size = UDim2.new(0, 48, 0, 26)
    togBg.Position = UDim2.new(1, -62, 0.5, -13)
    togBg.BackgroundColor3 = C.bg2
    togBg.BorderSizePixel = 0
    togBg.ZIndex = 13
    togBg.Parent = row

    local togBgCorner = Instance.new("UICorner")
    togBgCorner.CornerRadius = UDim.new(1, 0)
    togBgCorner.Parent = togBg

    -- Тоггл точка
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 20, 0, 20)
    dot.Position = UDim2.new(0, 3, 0.5, -10)
    dot.BackgroundColor3 = C.textDim
    dot.BorderSizePixel = 0
    dot.ZIndex = 14
    dot.Parent = togBg

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot

    local isOn = false

    local function setOn(v)
        isOn = v
        TweenService:Create(dot, TweenInfo.new(0.2), {
            Position = v and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10),
            BackgroundColor3 = v and C.redBright or C.textDim,
        }):Play()
        TweenService:Create(togBg, TweenInfo.new(0.2), {
            BackgroundColor3 = v and C.redDark or C.bg2,
        }):Play()
        TweenService:Create(rowStroke, TweenInfo.new(0.2), {
            Color = v and C.red or C.redDark,
        }):Play()
        if onToggle then onToggle(v) end
    end

    -- Кликабельная область
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 15
    btn.Parent = row

    btn.MouseButton1Click:Connect(function()
        setOn(not isOn)
    end)

    return row, function() return isOn end, setOn
end

-- ============================================================
-- HELPER: ОБЫЧНАЯ КНОПКА
-- ============================================================
local function ActionButton(labelText, descText, onClick)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 58)
    row.BackgroundColor3 = C.bg3
    row.BorderSizePixel = 0
    row.ZIndex = 12
    row.Parent = Content

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 10)
    rowCorner.Parent = row

    Instance.new("UIStroke", row).Color = C.redDark

    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, -70, 0, 28)
    name.Position = UDim2.new(0, 14, 0, 6)
    name.BackgroundTransparency = 1
    name.Text = labelText
    name.TextColor3 = C.text
    name.TextSize = 15
    name.Font = Enum.Font.GothamBold
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.ZIndex = 13
    name.Parent = row

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -70, 0, 18)
    desc.Position = UDim2.new(0, 14, 0, 34)
    desc.BackgroundTransparency = 1
    desc.Text = descText
    desc.TextColor3 = C.textDim
    desc.TextSize = 11
    desc.Font = Enum.Font.Gotham
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.ZIndex = 13
    desc.Parent = row

    local arrowLbl = Instance.new("TextLabel")
    arrowLbl.Size = UDim2.new(0, 30, 1, 0)
    arrowLbl.Position = UDim2.new(1, -44, 0, 0)
    arrowLbl.BackgroundTransparency = 1
    arrowLbl.Text = ">>"
    arrowLbl.TextColor3 = C.red
    arrowLbl.TextSize = 16
    arrowLbl.Font = Enum.Font.GothamBold
    arrowLbl.ZIndex = 13
    arrowLbl.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 15
    btn.Parent = row

    btn.MouseButton1Click:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.08), {BackgroundColor3 = C.redDark}):Play()
        task.delay(0.15, function()
            TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = C.bg3}):Play()
        end)
        if onClick then onClick() end
    end)

    return row
end

-- ============================================================
-- НАПОЛНЕНИЕ МЕНЮ
-- ============================================================
SectionLabel("  VISUAL")
local _, getESP, setESP = ToggleButton(
    "ESP",
    "Подсветка игроков синим"
)

SectionLabel("  MOVEMENT")
local _, getFly, setFly = ToggleButton(
    "FLIGHT",
    "Свободный полет / джойстик"
)

SectionLabel("  TELEPORT")
local _, getTP, setTP = ToggleButton(
    "TELEPORT MODE",
    "Включить режим телепорта"
)

ActionButton(
    "TELEPORT TO PLAYER",
    "Выбери игрока и телепортируйся",
    function()
        -- сюда подключи свою функцию телепорта
        print("Teleport pressed")
    end
)

SectionLabel("  INFO")
ActionButton(
    "REFRESH PLAYERS",
    "Обновить список игроков",
    function()
        print("Refresh pressed")
    end
)

-- ============================================================
-- АНИМАЦИЯ ОТКРЫТИЯ / ЗАКРЫТИЯ
-- ============================================================
local menuOpen = false

local function openMenu()
    menuOpen = true
    Panel.Visible = true
    Overlay.Visible = true
    Panel.Position = UDim2.new(0, 0, 1, 0)
    TweenService:Create(Panel, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 1, -520)
    }):Play()
    TweenService:Create(Overlay, TweenInfo.new(0.3), {
        BackgroundTransparency = 0.5
    }):Play()
    TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
        Rotation = 90
    }):Play()
end

local function closeMenu()
    menuOpen = false
    TweenService:Create(Panel, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        Position = UDim2.new(0, 0, 1, 0)
    }):Play()
    TweenService:Create(Overlay, TweenInfo.new(0.25), {
        BackgroundTransparency = 1
    }):Play()
    TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
        Rotation = 0
    }):Play()
    task.delay(0.3, function()
        Panel.Visible = false
        Overlay.Visible = false
    end)
end

ToggleBtn.MouseButton1Click:Connect(function()
    if menuOpen then closeMenu() else openMenu() end
end)

CloseBtn.MouseButton1Click:Connect(closeMenu)

Overlay.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch
    or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        closeMenu()
    end
end)

print("MurdMenu loaded.")
