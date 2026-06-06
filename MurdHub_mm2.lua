-- // YinYang: MM2 Hub v2.0 - Full [PART 1/4]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

local C = {
    bg=Color3.fromRGB(8,8,8),bg2=Color3.fromRGB(14,14,14),bg3=Color3.fromRGB(20,20,20),
    red=Color3.fromRGB(200,0,0),redBright=Color3.fromRGB(255,30,30),redDark=Color3.fromRGB(60,0,0),
    text=Color3.fromRGB(235,235,235),textDim=Color3.fromRGB(100,100,100),
}

local ESPEnabled, MurderESPEnabled, SheriffESPEnabled, CoinESPEnabled = false,false,false,false
local FlyEnabled, NoClipEnabled, SpeedHackEnabled, InfiniteJumpEnabled = false,false,false,false
local AimbotEnabled, GodModeEnabled, AntiAFKEnabled, FullBrightEnabled = false,false,false,false
local AutoPickupEnabled, AutoShootEnabled, InstantKillEnabled = false,false,false
local FlingEnabled = false
local IgnoreSheriff, IgnoreInnocent = false, false
local ESPObjects, CoinESPObjects = {},{}
local NoclipConn,JumpConn,AimbotConn,AntiAFKConn,AutoPickupConn,AutoShootConn,InstantKillConn
local BodyVelocity,BodyGyro,FlyHeartbeatConn
local FLY_SPEED = 80

local function getMurderer()
    for _,plr in pairs(Players:GetPlayers())do
        if plr.Character and plr.Character:FindFirstChild("Murderer")then return plr end
        if plr.Backpack and plr.Backpack:FindFirstChild("Knife")then return plr end
    end; return nil
end
local function getSheriff()
    for _,plr in pairs(Players:GetPlayers())do
        if plr.Character and plr.Character:FindFirstChild("Sheriff")then return plr end
        if plr.Backpack and plr.Backpack:FindFirstChild("Gun")then return plr end
    end; return nil
end
local function getMyRole()
    if LocalPlayer.Character then
        if LocalPlayer.Character:FindFirstChild("Murderer")then return "MURDERER" end
        if LocalPlayer.Character:FindFirstChild("Sheriff")then return "SHERIFF" end
    end
    if LocalPlayer.Backpack then
        if LocalPlayer.Backpack:FindFirstChild("Knife")then return "MURDERER" end
        if LocalPlayer.Backpack:FindFirstChild("Gun")then return "SHERIFF" end
    end; return "INNOCENT"
end
local function getJoystickVector()
    local s,r=pcall(function()
        local pm=LocalPlayer.PlayerScripts:FindFirstChild("PlayerModule")
        if pm then local cm=pm:FindFirstChild("ControlModule")
            if cm then return require(cm):GetMoveVector()end end
        return Vector3.zero
    end); return s and r or Vector3.zero
end

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name="MurdMenu"; ScreenGui.ResetOnSpawn=false
ScreenGui.IgnoreGuiInset=true; ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
ScreenGui.Parent=PlayerGui

-- Кнопка
local ToggleBtn = Instance.new("ImageButton")
ToggleBtn.Size=UDim2.new(0,54,0,54); ToggleBtn.Position=UDim2.new(0,16,1,-80)
ToggleBtn.BackgroundColor3=Color3.fromRGB(0,0,0); ToggleBtn.BorderSizePixel=0
ToggleBtn.Image=""; ToggleBtn.ZIndex=30; ToggleBtn.Parent=ScreenGui
Instance.new("UICorner",ToggleBtn).CornerRadius=UDim.new(0,12)

local BtnStroke=Instance.new("UIStroke"); BtnStroke.Color=C.red
BtnStroke.Thickness=2; BtnStroke.Parent=ToggleBtn

local BtnLabel=Instance.new("TextLabel"); BtnLabel.Size=UDim2.new(1,0,1,0)
BtnLabel.BackgroundTransparency=1; BtnLabel.Text="M"; BtnLabel.TextColor3=C.red
BtnLabel.TextSize=22; BtnLabel.Font=Enum.Font.GothamBlack; BtnLabel.ZIndex=31; BtnLabel.Parent=ToggleBtn
TweenService:Create(BtnStroke,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Thickness=4}):Play()

-- Перетаскивание
local draggingBtn,dragStartPos,btnStartPos=false,nil,nil
ToggleBtn.InputBegan:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.Touch or inp.UserInputType==Enum.UserInputType.MouseButton1 then
        draggingBtn=true;dragStartPos=inp.Position;btnStartPos=ToggleBtn.Position
    end
end)
ToggleBtn.InputEnded:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.Touch or inp.UserInputType==Enum.UserInputType.MouseButton1 then draggingBtn=false end
end)
UserInputService.InputChanged:Connect(function(inp)
    if not draggingBtn then return end
    if inp.UserInputType~=Enum.UserInputType.Touch and inp.UserInputType~=Enum.UserInputType.MouseMovement then return end
    local delta=inp.Position-dragStartPos
    local newX=btnStartPos.X.Offset+delta.X; local newY=btnStartPos.Y.Offset+delta.Y
    local vp=workspace.CurrentCamera.ViewportSize
    newX=math.clamp(newX,0,vp.X-54); newY=math.clamp(newY,0,vp.Y-54)
    ToggleBtn.Position=UDim2.new(0,newX,0,newY)
end)

-- Overlay
local Overlay=Instance.new("TextButton")
Overlay.Size=UDim2.new(1,0,1,0); Overlay.BackgroundColor3=Color3.fromRGB(0,0,0)
Overlay.BackgroundTransparency=1; Overlay.BorderSizePixel=0; Overlay.Text=""
Overlay.ZIndex=9; Overlay.Visible=false; Overlay.Parent=ScreenGui

-- Панель
local Panel=Instance.new("Frame")
Panel.Size=UDim2.new(1,0,0,420); Panel.Position=UDim2.new(0,0,1,0)
Panel.BackgroundColor3=C.bg; Panel.BorderSizePixel=0
Panel.ZIndex=10; Panel.Visible=false; Panel.Parent=ScreenGui
Instance.new("UICorner",Panel).CornerRadius=UDim.new(0,16)

local TopLine=Instance.new("Frame")
TopLine.Size=UDim2.new(1,0,0,2); TopLine.BackgroundColor3=C.red
TopLine.BorderSizePixel=0; TopLine.ZIndex=11; TopLine.Parent=Panel

-- Шапка
local Header=Instance.new("Frame")
Header.Size=UDim2.new(1,0,0,80); Header.Position=UDim2.new(0,0,0,2)
Header.BackgroundColor3=C.bg2; Header.BorderSizePixel=0; Header.ZIndex=11; Header.Parent=Panel

local LogoLbl=Instance.new("TextLabel")
LogoLbl.Size=UDim2.new(1,0,0,30); LogoLbl.Position=UDim2.new(0,0,0,8)
LogoLbl.BackgroundTransparency=1; LogoLbl.Text="MM2 HUB"; LogoLbl.TextColor3=C.red
LogoLbl.TextSize=22; LogoLbl.Font=Enum.Font.GothamBlack; LogoLbl.ZIndex=12; LogoLbl.Parent=Header

local ByLbl=Instance.new("TextLabel")
ByLbl.Size=UDim2.new(1,0,0,16); ByLbl.Position=UDim2.new(0,0,0,36)
ByLbl.BackgroundTransparency=1; ByLbl.Text="by MurdScript"; ByLbl.TextColor3=C.textDim
ByLbl.TextSize=9; ByLbl.Font=Enum.Font.Gotham; ByLbl.ZIndex=12; ByLbl.Parent=Header

local RoleLabel=Instance.new("TextLabel")
RoleLabel.Size=UDim2.new(1,-20,0,16); RoleLabel.Position=UDim2.new(0,10,0,58)
RoleLabel.BackgroundTransparency=1; RoleLabel.Text="Role: --"; RoleLabel.TextColor3=C.textDim
RoleLabel.TextSize=10; RoleLabel.Font=Enum.Font.Gotham; RoleLabel.TextXAlignment=Enum.TextXAlignment.Left
RoleLabel.ZIndex=12; RoleLabel.Parent=Header

RunService.RenderStepped:Connect(function()
    local role=getMyRole(); RoleLabel.Text="Role: "..role
    if role=="MURDERER"then RoleLabel.TextColor3=Color3.fromRGB(255,50,50)
    elseif role=="SHERIFF"then RoleLabel.TextColor3=Color3.fromRGB(50,100,255)
    else RoleLabel.TextColor3=C.textDim end
end)

-- Кнопка закрытия
local CloseBtn=Instance.new("TextButton")
CloseBtn.Size=UDim2.new(0,30,0,30); CloseBtn.Position=UDim2.new(1,-40,0,10)
CloseBtn.BackgroundColor3=C.redDark; CloseBtn.BorderSizePixel=0
CloseBtn.Text="X"; CloseBtn.TextColor3=C.text; CloseBtn.TextSize=13
CloseBtn.Font=Enum.Font.GothamBold; CloseBtn.ZIndex=20; CloseBtn.Parent=Panel
Instance.new("UICorner",CloseBtn).CornerRadius=UDim.new(0,8)

-- Контент
local Content=Instance.new("ScrollingFrame")
Content.Size=UDim2.new(1,-20,1,-92); Content.Position=UDim2.new(0,10,0,86)
Content.BackgroundTransparency=1; Content.BorderSizePixel=0
Content.ScrollBarThickness=2; Content.ScrollBarImageColor3=C.red
Content.CanvasSize=UDim2.new(0,0,0,0); Content.AutomaticCanvasSize=Enum.AutomaticSize.Y
Content.ZIndex=11; Content.Parent=Panel

local List=Instance.new("UIListLayout"); List.Padding=UDim.new(0,6); List.Parent=Content

-- Функции кнопок
local function MakeToggle(label,desc,callback)
    local row=Instance.new("Frame"); row.Size=UDim2.new(1,0,0,50)
    row.BackgroundColor3=C.bg3; row.BorderSizePixel=0; row.ZIndex=12; row.Parent=Content
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
    local stroke=Instance.new("UIStroke"); stroke.Color=C.redDark; stroke.Thickness=1; stroke.Parent=row
    local nl=Instance.new("TextLabel"); nl.Size=UDim2.new(1,-60,0,24); nl.Position=UDim2.new(0,12,0,5)
    nl.BackgroundTransparency=1; nl.Text=label; nl.TextColor3=C.text; nl.TextSize=14
    nl.Font=Enum.Font.GothamBold; nl.TextXAlignment=Enum.TextXAlignment.Left; nl.ZIndex=13; nl.Parent=row
    local dl=Instance.new("TextLabel"); dl.Size=UDim2.new(1,-60,0,16); dl.Position=UDim2.new(0,12,0,28)
    dl.BackgroundTransparency=1; dl.Text=desc; dl.TextColor3=C.textDim; dl.TextSize=10
    dl.Font=Enum.Font.Gotham; dl.TextXAlignment=Enum.TextXAlignment.Left; dl.ZIndex=13; dl.Parent=row
    local tg=Instance.new("Frame"); tg.Size=UDim2.new(0,42,0,22); tg.Position=UDim2.new(1,-52,0.5,-11)
    tg.BackgroundColor3=C.bg2; tg.BorderSizePixel=0; tg.ZIndex=13; tg.Parent=row
    Instance.new("UICorner",tg).CornerRadius=UDim.new(1,0)
    local dot=Instance.new("Frame"); dot.Size=UDim2.new(0,16,0,16); dot.Position=UDim2.new(0,3,0.5,-8)
    dot.BackgroundColor3=C.textDim; dot.BorderSizePixel=0; dot.ZIndex=14; dot.Parent=tg
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    local isOn=false
    local function set(v)
        isOn=v
        TweenService:Create(dot,TweenInfo.new(0.18),{Position=v and UDim2.new(1,-19,0.5,-8)or UDim2.new(0,3,0.5,-8),BackgroundColor3=v and C.redBright or C.textDim}):Play()
        TweenService:Create(tg,TweenInfo.new(0.18),{BackgroundColor3=v and C.redDark or C.bg2}):Play()
        TweenService:Create(stroke,TweenInfo.new(0.18),{Color=v and C.red or C.redDark}):Play()
        if callback then callback(v)end
    end
    local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,0,1,0)
    btn.BackgroundTransparency=1; btn.Text=""; btn.ZIndex=15; btn.Parent=row
    btn.MouseButton1Click:Connect(function()set(not isOn)end)
    return{set=set}
end

local function MakeAction(label,desc,callback)
    local row=Instance.new("Frame"); row.Size=UDim2.new(1,0,0,50)
    row.BackgroundColor3=C.bg3; row.BorderSizePixel=0; row.ZIndex=12; row.Parent=Content
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
    Instance.new("UIStroke",row).Color=C.redDark
    local nl=Instance.new("TextLabel"); nl.Size=UDim2.new(1,-44,0,24); nl.Position=UDim2.new(0,12,0,5)
    nl.BackgroundTransparency=1; nl.Text=label; nl.TextColor3=C.text; nl.TextSize=14
    nl.Font=Enum.Font.GothamBold; nl.TextXAlignment=Enum.TextXAlignment.Left; nl.ZIndex=13; nl.Parent=row
    local dl=Instance.new("TextLabel"); dl.Size=UDim2.new(1,-44,0,16); dl.Position=UDim2.new(0,12,0,28)
    dl.BackgroundTransparency=1; dl.Text=desc; dl.TextColor3=C.textDim; dl.TextSize=10
    dl.Font=Enum.Font.Gotham; dl.TextXAlignment=Enum.TextXAlignment.Left; dl.ZIndex=13; dl.Parent=row
    local arr=Instance.new("TextLabel"); arr.Size=UDim2.new(0,24,1,0); arr.Position=UDim2.new(1,-34,0,0)
    arr.BackgroundTransparency=1; arr.Text=">>"; arr.TextColor3=C.red; arr.TextSize=13
    arr.Font=Enum.Font.GothamBold; arr.ZIndex=13; arr.Parent=row
    local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,0,1,0)
    btn.BackgroundTransparency=1; btn.Text=""; btn.ZIndex=15; btn.Parent=row
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(row,TweenInfo.new(0.08),{BackgroundColor3=C.redDark}):Play()
        task.delay(0.15,function()TweenService:Create(row,TweenInfo.new(0.15),{BackgroundColor3=C.bg3}):Play()end)
        if callback then callback()end
    end)
end
-- // YinYang: MM2 Hub v2.0 - Fixed [PART 2/4]

-- ESP Players
local function CreatePlayerESP(player)
    if player==LocalPlayer or ESPObjects[player]then return end
    local function setup()
        if not player.Character or not player.Character:FindFirstChild("Head")then return end
        local head=player.Character.Head
        local hl=Instance.new("Highlight");hl.Name="MM2_Highlight";hl.Parent=head
        hl.FillColor=Color3.fromRGB(255,255,255);hl.FillTransparency=0.7
        hl.OutlineColor=Color3.fromRGB(255,255,255);hl.OutlineTransparency=0.3
        local bbg=Instance.new("BillboardGui");bbg.Adornee=head
        bbg.Size=UDim2.new(0,200,0,25);bbg.StudsOffset=Vector3.new(0,2,0);bbg.AlwaysOnTop=true
        local frm=Instance.new("Frame");frm.Size=UDim2.new(1,0,1,0)
        frm.BackgroundColor3=Color3.fromRGB(30,30,30);frm.BackgroundTransparency=0.4
        frm.BorderSizePixel=1;frm.BorderColor3=Color3.fromRGB(100,100,100);frm.Parent=bbg
        local txt=Instance.new("TextLabel");txt.Size=UDim2.new(1,0,1,0)
        txt.BackgroundTransparency=1;txt.Text=player.Name;txt.TextColor3=Color3.fromRGB(255,255,255)
        txt.TextSize=11;txt.Font=Enum.Font.Code;txt.Parent=frm
        bbg.Parent=game:GetService("CoreGui")
        ESPObjects[player]={billboard=bbg,frame=frm,text=txt,highlight=hl,player=player}
    end
    if player.Character then setup()end
    player.CharacterAdded:Connect(function()task.wait(0.3);setup()end)
end
local function EnablePlayerESP()
    ESPEnabled=true
    for _,plr in pairs(Players:GetPlayers())do CreatePlayerESP(plr)end
    Players.PlayerAdded:Connect(function(plr)if ESPEnabled then CreatePlayerESP(plr)end end)
    Players.PlayerRemoving:Connect(function(plr)
        if ESPObjects[plr]then
            if ESPObjects[plr].billboard then ESPObjects[plr].billboard:Destroy()end
            if ESPObjects[plr].highlight then ESPObjects[plr].highlight:Destroy()end
            ESPObjects[plr]=nil
        end
    end)
end
local function DisablePlayerESP()
    ESPEnabled=false
    for _,d in pairs(ESPObjects)do
        if d.billboard then d.billboard:Destroy()end
        if d.highlight then d.highlight:Destroy()end
    end; ESPObjects={}
end

-- ESP Murderer (исправлено)
local MurderESPConnection = nil
local function ToggleMurderESP(v)
    MurderESPEnabled=v
    if v then 
        SheriffESPEnabled=false
        if MurderESPConnection then MurderESPConnection:Disconnect()end
        MurderESPConnection=RunService.RenderStepped:Connect(function()
            if not MurderESPEnabled then return end
            local m=getMurderer()
            for _,d in pairs(ESPObjects)do
                if d.player and m and d.player==m then
                    d.frame.BackgroundColor3=Color3.fromRGB(255,0,0)
                    d.frame.BorderColor3=Color3.fromRGB(255,50,50)
                    d.text.Text=m.Name.." [MURDERER]"
                    d.highlight.FillColor=Color3.fromRGB(255,0,0)
                    d.highlight.OutlineColor=Color3.fromRGB(255,0,0)
                end
            end
        end)
    else
        if MurderESPConnection then MurderESPConnection:Disconnect();MurderESPConnection=nil end
    end
end

-- ESP Sheriff (исправлено)
local SheriffESPConnection = nil
local function ToggleSheriffESP(v)
    SheriffESPEnabled=v
    if v then 
        MurderESPEnabled=false
        if SheriffESPConnection then SheriffESPConnection:Disconnect()end
        SheriffESPConnection=RunService.RenderStepped:Connect(function()
            if not SheriffESPEnabled then return end
            local s=getSheriff()
            for _,d in pairs(ESPObjects)do
                if d.player and s and d.player==s then
                    d.frame.BackgroundColor3=Color3.fromRGB(0,50,255)
                    d.frame.BorderColor3=Color3.fromRGB(50,100,255)
                    d.text.Text=s.Name.." [SHERIFF]"
                    d.highlight.FillColor=Color3.fromRGB(0,50,255)
                    d.highlight.OutlineColor=Color3.fromRGB(0,100,255)
                end
            end
        end)
    else
        if SheriffESPConnection then SheriffESPConnection:Disconnect();SheriffESPConnection=nil end
    end
end

-- Fly
function EnableFly()
    if FlyEnabled then return end
    local char=LocalPlayer.Character;if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart");local hum=char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end;hum.PlatformStand=true
    BodyVelocity=Instance.new("BodyVelocity");BodyVelocity.MaxForce=Vector3.new(99999,99999,99999)
    BodyVelocity.Velocity=Vector3.zero;BodyVelocity.Parent=hrp
    BodyGyro=Instance.new("BodyGyro");BodyGyro.MaxTorque=Vector3.new(99999,99999,99999)
    BodyGyro.P=12500;BodyGyro.Parent=hrp;FlyEnabled=true
    FlyHeartbeatConn=RunService.RenderStepped:Connect(function()
        if not FlyEnabled or not BodyVelocity then return end
        local cam=workspace.CurrentCamera;local move=getJoystickVector()
        if UserInputService:IsKeyDown(Enum.KeyCode.W)then move=move+Vector3.new(0,0,-1)end
        if UserInputService:IsKeyDown(Enum.KeyCode.S)then move=move+Vector3.new(0,0,1)end
        if UserInputService:IsKeyDown(Enum.KeyCode.A)then move=move+Vector3.new(-1,0,0)end
        if UserInputService:IsKeyDown(Enum.KeyCode.D)then move=move+Vector3.new(1,0,0)end
        local vertical=0
        if UserInputService:IsKeyDown(Enum.KeyCode.Space)or UserInputService:IsKeyDown(Enum.KeyCode.ButtonA)then vertical=1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)or UserInputService:IsKeyDown(Enum.KeyCode.ButtonX)then vertical=-1 end
        local finalDir=Vector3.new(move.X,vertical,move.Z)
        if finalDir.Magnitude>0 then BodyVelocity.Velocity=cam.CFrame:VectorToWorldSpace(finalDir.Unit)*FLY_SPEED
        else BodyVelocity.Velocity=Vector3.zero end
        if BodyGyro then BodyGyro.CFrame=cam.CFrame end
    end)
end
function DisableFly()
    if not FlyEnabled then return end;FlyEnabled=false
    if FlyHeartbeatConn then FlyHeartbeatConn:Disconnect();FlyHeartbeatConn=nil end
    if BodyVelocity then BodyVelocity:Destroy();BodyVelocity=nil end
    if BodyGyro then BodyGyro:Destroy();BodyGyro=nil end
    local char=LocalPlayer.Character
    if char then local hum=char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand=false end end
end

-- NoClip
local function ToggleNoClip(v)
    NoClipEnabled=v
    if v then if NoclipConn then NoclipConn:Disconnect()end
        NoclipConn=RunService.Stepped:Connect(function()
            local char=LocalPlayer.Character;if not char then return end
            for _,part in pairs(char:GetDescendants())do
                if part:IsA("BasePart")and part.CanCollide==true then part.CanCollide=false end
            end
        end)
    else if NoclipConn then NoclipConn:Disconnect();NoclipConn=nil end
        local char=LocalPlayer.Character
        if char then for _,part in pairs(char:GetDescendants())do
            if part:IsA("BasePart")then part.CanCollide=true end end
        end
    end
end

-- Speed Hack
local function ToggleSpeedHack(v)
    SpeedHackEnabled=v
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")then
        LocalPlayer.Character.Humanoid.WalkSpeed=v and 100 or 16
    end
end

-- Infinite Jump
local function ToggleInfiniteJump(v)
    InfiniteJumpEnabled=v
    if v then JumpConn=UserInputService.JumpRequest:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")then
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)else if JumpConn then JumpConn:Disconnect();JumpConn=nil end end
end

-- Aimbot
local function ToggleAimbot(v)
    AimbotEnabled=v
    if v then AimbotConn=RunService.RenderStepped:Connect(function()
        local closest,minDist=nil,math.huge
        for _,plr in pairs(Players:GetPlayers())do
            if plr~=LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head")then
                local targetRole="INNOCENT"
                if plr.Character:FindFirstChild("Murderer")or(plr.Backpack and plr.Backpack:FindFirstChild("Knife"))then targetRole="MURDERER"
                elseif plr.Character:FindFirstChild("Sheriff")or(plr.Backpack and plr.Backpack:FindFirstChild("Gun"))then targetRole="SHERIFF"end
                if IgnoreSheriff and targetRole=="SHERIFF"then continue end
                if IgnoreInnocent and targetRole=="INNOCENT"then continue end
                local pos,onScreen=Camera:WorldToScreenPoint(plr.Character.Head.Position)
                if onScreen then local dist=(Vector2.new(pos.X,pos.Y)-Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)).Magnitude
                    if dist<minDist then minDist=dist;closest=plr end
                end
            end
        end
        if closest and closest.Character and closest.Character:FindFirstChild("Head")then
            Camera.CFrame=CFrame.new(Camera.CFrame.Position,closest.Character.Head.Position)
        end
    end)else if AimbotConn then AimbotConn:Disconnect();AimbotConn=nil end
        if LocalPlayer.Character then Camera.CameraSubject=LocalPlayer.Character:FindFirstChild("Humanoid")end
    end
end

-- God Mode
local function ToggleGodMode(v)
    GodModeEnabled=v
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")then
        local hum=LocalPlayer.Character.Humanoid
        hum.MaxHealth=v and math.huge or 100;hum.Health=v and math.huge or hum.MaxHealth
    end
end

-- Anti AFK
local function ToggleAntiAFK(v)
    AntiAFKEnabled=v
    if v then local VU=game:GetService("VirtualUser")
        AntiAFKConn=RunService.Heartbeat:Connect(function()
            pcall(function()VU:CaptureController();VU:Button2Down(Vector2.new(0,0),Camera.CFrame)
                task.wait(0.5);VU:Button2Up(Vector2.new(0,0),Camera.CFrame)end)
        end)
    else if AntiAFKConn then AntiAFKConn:Disconnect();AntiAFKConn=nil end end
end

-- Full Bright
local function ToggleFullBright(v)
    FullBrightEnabled=v
    if v then local fb=Instance.new("ColorCorrectionEffect");fb.Name="MM2_Brightness"
        fb.Brightness=0.4;fb.Contrast=0.3;fb.Saturation=-0.5
        fb.TintColor=Color3.fromRGB(255,255,255);fb.Parent=Lighting
    else if Lighting:FindFirstChild("MM2_Brightness")then Lighting.MM2_Brightness:Destroy()end end
end

-- FPS Boost
local function FPSBoost()
    for _,obj in pairs(workspace:GetDescendants())do
        if obj:IsA("BasePart")and(obj.Material==Enum.Material.Grass or obj.Material==Enum.Material.Fabric)then
            obj.Material=Enum.Material.SmoothPlastic
        end
    end;Lighting.GlobalShadows=false;Lighting.FogEnd=99999
    pcall(function()settings().Rendering.QualityLevel=1 end)
end

-- Fling (исправлено)
local FlingThread = nil
local function StartFling(targetFunc)
    if not ReplicatedStorage:FindFirstChild("MM2_Fling")then
        local d=Instance.new("Decal");d.Name="MM2_Fling";d.Parent=ReplicatedStorage
    end
    StopFling()
    FlingEnabled=true;local movel=0.1
    FlingThread=coroutine.create(function()
        while FlingEnabled do 
            RunService.Heartbeat:Wait()
            local char=LocalPlayer.Character;local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            local target=targetFunc and targetFunc()
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")then
                hrp.CFrame=target.Character.HumanoidRootPart.CFrame+Vector3.new(0,2,0)
            end
            local vel=hrp.Velocity;hrp.Velocity=vel*10000+Vector3.new(0,10000,0)
            RunService.RenderStepped:Wait();hrp.Velocity=vel
            RunService.Stepped:Wait();hrp.Velocity=vel+Vector3.new(0,movel,0);movel=-movel
        end
    end)
    coroutine.resume(FlingThread)
end
local function StopFling()
    FlingEnabled=false;FlingThread=nil
end
-- // YinYang: MM2 Hub v2.0 - Fixed [PART 3/4]

-- Auto Pickup
local function ToggleAutoPickup(v)
    AutoPickupEnabled=v
    if v then AutoPickupConn=RunService.Stepped:Connect(function()
        local char=LocalPlayer.Character;if not char or not char:FindFirstChild("HumanoidRootPart")then return end
        local hrp=char.HumanoidRootPart
        for _,obj in pairs(workspace:GetDescendants())do
            if(obj.Name=="Coin"or obj.Name=="Coins")and obj:IsA("BasePart")then
                if(hrp.Position-obj.Position).Magnitude<10 then
                    firetouchinterest(hrp,obj,0);firetouchinterest(hrp,obj,1)
                end
            end
        end
    end)else if AutoPickupConn then AutoPickupConn:Disconnect();AutoPickupConn=nil end end
end

-- Auto Shoot
local function ToggleAutoShoot(v)
    AutoShootEnabled=v
    if v then AutoShootConn=RunService.Heartbeat:Connect(function()
        local role=getMyRole()
        if role=="SHERIFF"then local murd=getMurderer()
            if murd and murd.Character and murd.Character:FindFirstChild("Head")then
                local tool=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool and(tool.Name=="Gun"or tool:FindFirstChild("Gun"))then
                    pcall(function()tool.RemoteEvent:FireServer(murd.Character.Head.Position,murd.Character.Head)end)
                end
            end
        elseif role=="MURDERER"then local sher=getSheriff()
            if sher and sher.Character and sher.Character:FindFirstChild("Head")then
                local tool=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool and(tool.Name=="Gun"or tool:FindFirstChild("Gun"))then
                    pcall(function()tool.RemoteEvent:FireServer(sher.Character.Head.Position,sher.Character.Head)end)
                end
            end
        end
    end)else if AutoShootConn then AutoShootConn:Disconnect();AutoShootConn=nil end end
end

-- Instant Kill
local function ToggleInstantKill(v)
    InstantKillEnabled=v
    if v then InstantKillConn=RunService.Heartbeat:Connect(function()
        if getMyRole()=="MURDERER"then
            local tool=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool and tool.Name=="Knife"then
                for _,plr in pairs(Players:GetPlayers())do
                    if plr~=LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")then
                        if(LocalPlayer.Character.HumanoidRootPart.Position-plr.Character.HumanoidRootPart.Position).Magnitude<10 then
                            pcall(function()tool.RemoteEvent:FireServer(plr.Character)end)
                        end
                    end
                end
            end
        end
    end)else if InstantKillConn then InstantKillConn:Disconnect();InstantKillConn=nil end end
end

-- Kill All
local function KillAll()
    if getMyRole()~="MURDERER"then return end
    local tool=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool or tool.Name~="Knife"then return end
    for _,plr in pairs(Players:GetPlayers())do
        if plr~=LocalPlayer and plr.Character then pcall(function()
            LocalPlayer.Character.HumanoidRootPart.CFrame=plr.Character.HumanoidRootPart.CFrame+Vector3.new(0,2,0)
            task.wait(0.05);tool.RemoteEvent:FireServer(plr.Character);task.wait(0.05)
        end)end
    end
end

-- TP to Murderer
local function TPMurderer()
    local murd=getMurderer()
    if murd and murd.Character and murd.Character:FindFirstChild("HumanoidRootPart")and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")then
        LocalPlayer.Character.HumanoidRootPart.CFrame=murd.Character.HumanoidRootPart.CFrame+Vector3.new(0,2,0)
        StarterGui:SetCore("SendNotification",{Title="TP",Text="Teleported to "..murd.Name,Duration=2})
    else StarterGui:SetCore("SendNotification",{Title="TP",Text="Murderer not found",Duration=2})end
end

-- TP to Sheriff
local function TPSheriff()
    local sher=getSheriff()
    if sher and sher.Character and sher.Character:FindFirstChild("HumanoidRootPart")and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")then
        LocalPlayer.Character.HumanoidRootPart.CFrame=sher.Character.HumanoidRootPart.CFrame+Vector3.new(0,2,0)
        StarterGui:SetCore("SendNotification",{Title="TP",Text="Teleported to "..sher.Name,Duration=2})
    else StarterGui:SetCore("SendNotification",{Title="TP",Text="Sheriff not found",Duration=2})end
end

-- TP to Gun + Auto Equip
local function TPGun()
    for _,obj in pairs(workspace:GetDescendants())do
        if obj.Name=="Gun"and obj:IsA("BasePart")then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")then
                LocalPlayer.Character.HumanoidRootPart.CFrame=obj.CFrame+Vector3.new(0,3,0)
                task.wait(0.1)
                firetouchinterest(LocalPlayer.Character.HumanoidRootPart,obj,0)
                firetouchinterest(LocalPlayer.Character.HumanoidRootPart,obj,1)
                StarterGui:SetCore("SendNotification",{Title="TP Gun",Text="Teleported & Equipped!",Duration=2})
                return
            end
        end
    end; StarterGui:SetCore("SendNotification",{Title="TP Gun",Text="Gun not found",Duration=2})
end

-- TP to Player
local function TeleportToPlayer()
    local closest,minDist=nil,math.huge
    for _,plr in pairs(Players:GetPlayers())do
        if plr~=LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")then
            local pos,onScreen=Camera:WorldToScreenPoint(plr.Character.HumanoidRootPart.Position)
            if onScreen then local mousePos=UserInputService:GetMouseLocation()
                local dist=(Vector2.new(pos.X,pos.Y)-mousePos).Magnitude
                if dist<minDist then minDist=dist;closest=plr end
            end
        end
    end
    if closest and minDist<200 and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")then
        LocalPlayer.Character.HumanoidRootPart.CFrame=closest.Character.HumanoidRootPart.CFrame+Vector3.new(0,3,0)
    end
end

-- TP to Murderer + Auto Shoot
local function TPMurderAndShoot()
    local murd=getMurderer()
    if not murd or not murd.Character or not murd.Character:FindFirstChild("HumanoidRootPart")then
        StarterGui:SetCore("SendNotification",{Title="TP+Shoot",Text="Murderer not found",Duration=2});return
    end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")then
        LocalPlayer.Character.HumanoidRootPart.CFrame=murd.Character.HumanoidRootPart.CFrame+Vector3.new(0,2,0)
        task.wait(0.15)
        local tool=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and(tool.Name=="Gun"or tool:FindFirstChild("Gun"))and murd.Character:FindFirstChild("Head")then
            pcall(function()tool.RemoteEvent:FireServer(murd.Character.Head.Position,murd.Character.Head)end)
            StarterGui:SetCore("SendNotification",{Title="TP+Shoot",Text="Shot fired at "..murd.Name,Duration=2})
        end
    end
end

-- Fling Murderer (исправлено)
local function FlingMurderer()
    StartFling(getMurderer)
    StarterGui:SetCore("SendNotification",{Title="Fling",Text="Flinging to Murderer",Duration=2})
end

-- Fling Sheriff (исправлено)
local function FlingSheriff()
    StartFling(getSheriff)
    StarterGui:SetCore("SendNotification",{Title="Fling",Text="Flinging to Sheriff",Duration=2})
end

-- Server Hop
local function ServerHop()
    local HttpService=game:GetService("HttpService");local servers={}
    pcall(function()
        local data=HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100"))
        for _,server in pairs(data.data)do
            if server.playing<server.maxPlayers and server.id~=game.JobId then table.insert(servers,server.id)end
        end
    end)
    if #servers>0 then TeleportService:TeleportToPlaceInstance(game.PlaceId,servers[math.random(1,#servers)])end
end

-- Cleanup
local function CleanupAll()
    DisablePlayerESP()
    if MurderESPConnection then MurderESPConnection:Disconnect()end
    if SheriffESPConnection then SheriffESPConnection:Disconnect()end
    ToggleNoClip(false);ToggleSpeedHack(false)
    ToggleInfiniteJump(false);ToggleAimbot(false);ToggleGodMode(false);ToggleAntiAFK(false)
    ToggleFullBright(false);ToggleAutoPickup(false);ToggleAutoShoot(false);ToggleInstantKill(false)
    if FlyEnabled then DisableFly()end;if FlingEnabled then StopFling()end
    if Lighting:FindFirstChild("MM2_Brightness")then Lighting.MM2_Brightness:Destroy()end
end

-- Respawn Handler
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.3)
    if NoClipEnabled then NoClipEnabled=false;task.wait(0.1);ToggleNoClip(true)end
    if GodModeEnabled then local hum=char:WaitForChild("Humanoid",3);if hum then hum.MaxHealth=math.huge;hum.Health=math.huge end end
    if FlyEnabled then FlyEnabled=false;task.wait(0.1);EnableFly()end
    if AutoShootEnabled then AutoShootEnabled=false;task.wait(0.2);ToggleAutoShoot(true)end
    if InstantKillEnabled then InstantKillEnabled=false;task.wait(0.2);ToggleInstantKill(true)end
    if AutoPickupEnabled then AutoPickupEnabled=false;task.wait(0.2);ToggleAutoPickup(true)end
    if FlingEnabled then StopFling()end
end)
-- // YinYang: MM2 Hub v2.0 - Fixed [PART 4/4]

-- BUTTONS (без ESP Coins)
MakeToggle("ESP Players","Подсветка всех игроков",function(v)if v then EnablePlayerESP()else DisablePlayerESP()end end)
MakeToggle("ESP Murderer","Подсветка убийцы красным",ToggleMurderESP)
MakeToggle("ESP Sheriff","Подсветка шерифа синим",ToggleSheriffESP)
MakeToggle("Flight","Свободный полёт",function(v)if v then EnableFly()else DisableFly()end end)
MakeToggle("NoClip","Проход сквозь стены",ToggleNoClip)
MakeToggle("Speed Hack","Быстрый бег",ToggleSpeedHack)
MakeToggle("Inf Jump","Бесконечный прыжок",ToggleInfiniteJump)
MakeToggle("Aimbot","Автонаводка",ToggleAimbot)
MakeToggle("Ignore Sheriff","Аимбот не целится в шерифа",function(v)IgnoreSheriff=v end)
MakeToggle("Ignore Innocent","Аимбот не целится в невинных",function(v)IgnoreInnocent=v end)
MakeToggle("Auto Shoot","Автострельба",ToggleAutoShoot)
MakeToggle("Instant Kill","Мгновенный удар ножом",ToggleInstantKill)
MakeToggle("God Mode","Бессмертие",ToggleGodMode)
MakeToggle("Auto Pickup","Автосбор монеток",ToggleAutoPickup)
MakeToggle("Anti AFK","Защита от кика",ToggleAntiAFK)
MakeToggle("Full Bright","Яркое освещение",ToggleFullBright)

MakeAction("Kill All","Убить всех (Murderer)",KillAll)
MakeAction("TP to Murderer","Телепорт к убийце",TPMurderer)
MakeAction("TP to Sheriff","Телепорт к шерифу",TPSheriff)
MakeAction("TP to Gun","Телепорт к пистолету + взять",TPGun)
MakeAction("TP + Shoot Murderer","Телепорт к убийце и выстрел",TPMurderAndShoot)
MakeAction("Fling Murderer","Флинг к убийце",FlingMurderer)
MakeAction("Fling Sheriff","Флинг к шерифу",FlingSheriff)
MakeAction("TP to Player","Телепорт к ближайшему",TeleportToPlayer)
MakeAction("Server Hop","Смена сервера",ServerHop)
MakeAction("FPS Boost","Повышение FPS",FPSBoost)
MakeAction("Close Hub","Закрыть панель",function()CleanupAll();closeMenu()end)

-- ANIMATION
local menuOpen=false
function openMenu()
    menuOpen=true;Panel.Visible=true;Overlay.Visible=true
    Panel.Position=UDim2.new(0,0,1,0)
    TweenService:Create(Panel,TweenInfo.new(0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(0,0,1,-420)}):Play()
    TweenService:Create(Overlay,TweenInfo.new(0.25),{BackgroundTransparency=0.55}):Play()
end
function closeMenu()
    menuOpen=false
    TweenService:Create(Panel,TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Position=UDim2.new(0,0,1,0)}):Play()
    TweenService:Create(Overlay,TweenInfo.new(0.2),{BackgroundTransparency=1}):Play()
    task.delay(0.25,function()Panel.Visible=false;Overlay.Visible=false end)
end

local btnTapMoved=false
ToggleBtn.InputBegan:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.Touch or inp.UserInputType==Enum.UserInputType.MouseButton1 then btnTapMoved=false end
end)
UserInputService.InputChanged:Connect(function(inp)if draggingBtn then btnTapMoved=true end end)
ToggleBtn.InputEnded:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.Touch or inp.UserInputType==Enum.UserInputType.MouseButton1 then
        if not btnTapMoved then if menuOpen then closeMenu()else openMenu()end end
        draggingBtn=false
    end
end)
CloseBtn.MouseButton1Click:Connect(closeMenu)
Overlay.MouseButton1Click:Connect(closeMenu)

print("MM2 Hub v2.0 - MurdMenu by MurdScript loaded.")
