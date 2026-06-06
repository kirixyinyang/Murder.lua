-- // YinYang: MM2 Hub v3.0 - Aimbot Circle [PART 1/4]

local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local UserInputService=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local StarterGui=game:GetService("StarterGui")
local Lighting=game:GetService("Lighting")
local TeleportService=game:GetService("TeleportService")
local Workspace=game:GetService("Workspace")
local LocalPlayer=Players.LocalPlayer
local PlayerGui=LocalPlayer:WaitForChild("PlayerGui")
local Camera=workspace.CurrentCamera

local C={bg=Color3.fromRGB(8,8,8),bg2=Color3.fromRGB(14,14,14),bg3=Color3.fromRGB(20,20,20),
red=Color3.fromRGB(200,0,0),redBright=Color3.fromRGB(255,30,30),redDark=Color3.fromRGB(60,0,0),
text=Color3.fromRGB(235,235,235),textDim=Color3.fromRGB(100,100,100)}

local ESPPlayers,ESPMurderer,ESPSheriff,ESPGun=false,false,false,false
local FlyEnabled,NoClipEnabled,AimbotEnabled,GodModeEnabled=false,false,false,false
local AntiAFKEnabled,FullBrightEnabled,InstantKillEnabled=false,false,false
local FlingEnabled,KillAllEnabled,FarmEnabled=false,false,false
local IgnoreSheriff,IgnoreInnocent=false,false
local AimbotFOV=120
local ShowAimbotCircle=true
local AimbotCircle=nil
local WalkspeedVal,JumpPowerVal,GravityVal=16,50,196.2
local FarmCooldown=0.1
local BodyVelocity,BodyGyro,FlyHeartbeatConn
local NoclipConn,AimbotConn,AntiAFKConn,InstantKillConn,FarmConn,KillAllConn
local FLY_SPEED=80

local function hasKnife(plr)
    if plr.Backpack and plr.Backpack:FindFirstChild("Knife")then return true end
    if plr.Character and plr.Character:FindFirstChild("Knife")then return true end
    return false
end
local function hasGun(plr)
    if plr.Backpack and plr.Backpack:FindFirstChild("Gun")then return true end
    if plr.Character and plr.Character:FindFirstChild("Gun")then return true end
    return false
end
local function getMurderer()
    for _,plr in pairs(Players:GetPlayers())do if hasKnife(plr)then return plr end end;return nil
end
local function getSheriff()
    for _,plr in pairs(Players:GetPlayers())do if hasGun(plr)then return plr end end;return nil
end
local function getMyRole()
    if hasKnife(LocalPlayer)then return"MURDERER"end
    if hasGun(LocalPlayer)then return"SHERIFF"end
    return"INNOCENT"
end
local function getJoystickVector()
    local s,r=pcall(function()
        local pm=LocalPlayer.PlayerScripts:FindFirstChild("PlayerModule")
        if pm then local cm=pm:FindFirstChild("ControlModule")
            if cm then return require(cm):GetMoveVector()end end
        return Vector3.zero
    end);return s and r or Vector3.zero
end

-- GUI компактный
local ScreenGui=Instance.new("ScreenGui")
ScreenGui.Name="MurdMenu";ScreenGui.ResetOnSpawn=false
ScreenGui.IgnoreGuiInset=true;ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;ScreenGui.Parent=PlayerGui

local ToggleBtn=Instance.new("ImageButton")
ToggleBtn.Size=UDim2.new(0,44,0,44);ToggleBtn.Position=UDim2.new(0,12,1,-70)
ToggleBtn.BackgroundColor3=Color3.fromRGB(0,0,0);ToggleBtn.BorderSizePixel=0
ToggleBtn.Image="";ToggleBtn.ZIndex=30;ToggleBtn.Parent=ScreenGui
Instance.new("UICorner",ToggleBtn).CornerRadius=UDim.new(0,10)
local BtnStroke=Instance.new("UIStroke");BtnStroke.Color=C.red;BtnStroke.Thickness=2;BtnStroke.Parent=ToggleBtn
local BtnLabel=Instance.new("TextLabel");BtnLabel.Size=UDim2.new(1,0,1,0)
BtnLabel.BackgroundTransparency=1;BtnLabel.Text="M";BtnLabel.TextColor3=C.red
BtnLabel.TextSize=18;BtnLabel.Font=Enum.Font.GothamBlack;BtnLabel.ZIndex=31;BtnLabel.Parent=ToggleBtn
TweenService:Create(BtnStroke,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Thickness=3}):Play()

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
    local delta=inp.Position-dragStartPos;local newX=btnStartPos.X.Offset+delta.X;local newY=btnStartPos.Y.Offset+delta.Y
    local vp=workspace.CurrentCamera.ViewportSize
    newX=math.clamp(newX,0,vp.X-44);newY=math.clamp(newY,0,vp.Y-44)
    ToggleBtn.Position=UDim2.new(0,newX,0,newY)
end)

local Overlay=Instance.new("TextButton")
Overlay.Size=UDim2.new(1,0,1,0);Overlay.BackgroundColor3=Color3.fromRGB(0,0,0)
Overlay.BackgroundTransparency=1;Overlay.BorderSizePixel=0;Overlay.Text=""
Overlay.ZIndex=9;Overlay.Visible=false;Overlay.Parent=ScreenGui

local Panel=Instance.new("Frame")
Panel.Size=UDim2.new(1,0,0,340);Panel.Position=UDim2.new(0,0,1,0)
Panel.BackgroundColor3=C.bg;Panel.BorderSizePixel=0;Panel.ZIndex=10;Panel.Visible=false;Panel.Parent=ScreenGui
Instance.new("UICorner",Panel).CornerRadius=UDim.new(0,14)

local TopLine=Instance.new("Frame")
TopLine.Size=UDim2.new(1,0,0,2);TopLine.BackgroundColor3=C.red;TopLine.BorderSizePixel=0;TopLine.ZIndex=11;TopLine.Parent=Panel

local Header=Instance.new("Frame")
Header.Size=UDim2.new(1,0,0,60);Header.Position=UDim2.new(0,0,0,2);Header.BackgroundColor3=C.bg2
Header.BorderSizePixel=0;Header.ZIndex=11;Header.Parent=Panel
local LogoLbl=Instance.new("TextLabel");LogoLbl.Size=UDim2.new(1,0,0,24);LogoLbl.Position=UDim2.new(0,0,0,6)
LogoLbl.BackgroundTransparency=1;LogoLbl.Text="MM2 HUB";LogoLbl.TextColor3=C.red
LogoLbl.TextSize=18;LogoLbl.Font=Enum.Font.GothamBlack;LogoLbl.ZIndex=12;LogoLbl.Parent=Header
local ByLbl=Instance.new("TextLabel");ByLbl.Size=UDim2.new(1,0,0,14);ByLbl.Position=UDim2.new(0,0,0,28)
ByLbl.BackgroundTransparency=1;ByLbl.Text="by MurdScript";ByLbl.TextColor3=C.textDim
ByLbl.TextSize=8;ByLbl.Font=Enum.Font.Gotham;ByLbl.ZIndex=12;ByLbl.Parent=Header
local RoleLabel=Instance.new("TextLabel");RoleLabel.Size=UDim2.new(1,-16,0,14);RoleLabel.Position=UDim2.new(0,8,0,44)
RoleLabel.BackgroundTransparency=1;RoleLabel.Text="Role: --";RoleLabel.TextColor3=C.textDim
RoleLabel.TextSize=9;RoleLabel.Font=Enum.Font.Gotham;RoleLabel.TextXAlignment=Enum.TextXAlignment.Left;RoleLabel.ZIndex=12;RoleLabel.Parent=Header
RunService.RenderStepped:Connect(function()
    local role=getMyRole();RoleLabel.Text="Role: "..role
    if role=="MURDERER"then RoleLabel.TextColor3=Color3.fromRGB(255,50,50)
    elseif role=="SHERIFF"then RoleLabel.TextColor3=Color3.fromRGB(50,100,255)end
end)

local CloseBtn=Instance.new("TextButton")
CloseBtn.Size=UDim2.new(0,24,0,24);CloseBtn.Position=UDim2.new(1,-32,0,8)
CloseBtn.BackgroundColor3=C.redDark;CloseBtn.BorderSizePixel=0;CloseBtn.Text="X"
CloseBtn.TextColor3=C.text;CloseBtn.TextSize=11;CloseBtn.Font=Enum.Font.GothamBold;CloseBtn.ZIndex=20;CloseBtn.Parent=Panel
Instance.new("UICorner",CloseBtn).CornerRadius=UDim.new(0,6)

local Content=Instance.new("ScrollingFrame")
Content.Size=UDim2.new(1,-16,1,-72);Content.Position=UDim2.new(0,8,0,66)
Content.BackgroundTransparency=1;Content.BorderSizePixel=0;Content.ScrollBarThickness=2
Content.ScrollBarImageColor3=C.red;Content.CanvasSize=UDim2.new(0,0,0,0)
Content.AutomaticCanvasSize=Enum.AutomaticSize.Y;Content.ZIndex=11;Content.Parent=Panel
local List=Instance.new("UIListLayout");List.Padding=UDim.new(0,4);List.Parent=Content

local function MakeToggle(label,desc,callback)
    local row=Instance.new("Frame");row.Size=UDim2.new(1,0,0,42);row.BackgroundColor3=C.bg3
    row.BorderSizePixel=0;row.ZIndex=12;row.Parent=Content
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,6)
    local stroke=Instance.new("UIStroke");stroke.Color=C.redDark;stroke.Thickness=1;stroke.Parent=row
    local nl=Instance.new("TextLabel");nl.Size=UDim2.new(1,-54,0,20);nl.Position=UDim2.new(0,10,0,4)
    nl.BackgroundTransparency=1;nl.Text=label;nl.TextColor3=C.text;nl.TextSize=12
    nl.Font=Enum.Font.GothamBold;nl.TextXAlignment=Enum.TextXAlignment.Left;nl.ZIndex=13;nl.Parent=row
    local dl=Instance.new("TextLabel");dl.Size=UDim2.new(1,-54,0,14);dl.Position=UDim2.new(0,10,0,24)
    dl.BackgroundTransparency=1;dl.Text=desc;dl.TextColor3=C.textDim;dl.TextSize=8
    dl.Font=Enum.Font.Gotham;dl.TextXAlignment=Enum.TextXAlignment.Left;dl.ZIndex=13;dl.Parent=row
    local tg=Instance.new("Frame");tg.Size=UDim2.new(0,36,0,18);tg.Position=UDim2.new(1,-44,0.5,-9)
    tg.BackgroundColor3=C.bg2;tg.BorderSizePixel=0;tg.ZIndex=13;tg.Parent=row
    Instance.new("UICorner",tg).CornerRadius=UDim.new(1,0)
    local dot=Instance.new("Frame");dot.Size=UDim2.new(0,12,0,12);dot.Position=UDim2.new(0,3,0.5,-6)
    dot.BackgroundColor3=C.textDim;dot.BorderSizePixel=0;dot.ZIndex=14;dot.Parent=tg
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    local isOn=false
    local function set(v)
        isOn=v
        TweenService:Create(dot,TweenInfo.new(0.15),{Position=v and UDim2.new(1,-15,0.5,-6)or UDim2.new(0,3,0.5,-6),BackgroundColor3=v and C.redBright or C.textDim}):Play()
        TweenService:Create(tg,TweenInfo.new(0.15),{BackgroundColor3=v and C.redDark or C.bg2}):Play()
        TweenService:Create(stroke,TweenInfo.new(0.15),{Color=v and C.red or C.redDark}):Play()
        if callback then callback(v)end
    end
    local btn=Instance.new("TextButton");btn.Size=UDim2.new(1,0,1,0);btn.BackgroundTransparency=1
    btn.Text="";btn.ZIndex=15;btn.Parent=row;btn.MouseButton1Click:Connect(function()set(not isOn)end)
    return{set=set}
end

local function MakeAction(label,desc,callback)
    local row=Instance.new("Frame");row.Size=UDim2.new(1,0,0,42);row.BackgroundColor3=C.bg3
    row.BorderSizePixel=0;row.ZIndex=12;row.Parent=Content
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,6)
    Instance.new("UIStroke",row).Color=C.redDark
    local nl=Instance.new("TextLabel");nl.Size=UDim2.new(1,-36,0,20);nl.Position=UDim2.new(0,10,0,4)
    nl.BackgroundTransparency=1;nl.Text=label;nl.TextColor3=C.text;nl.TextSize=12
    nl.Font=Enum.Font.GothamBold;nl.TextXAlignment=Enum.TextXAlignment.Left;nl.ZIndex=13;nl.Parent=row
    local dl=Instance.new("TextLabel");dl.Size=UDim2.new(1,-36,0,14);dl.Position=UDim2.new(0,10,0,24)
    dl.BackgroundTransparency=1;dl.Text=desc;dl.TextColor3=C.textDim;dl.TextSize=8
    dl.Font=Enum.Font.Gotham;dl.TextXAlignment=Enum.TextXAlignment.Left;dl.ZIndex=13;dl.Parent=row
    local arr=Instance.new("TextLabel");arr.Size=UDim2.new(0,18,1,0);arr.Position=UDim2.new(1,-26,0,0)
    arr.BackgroundTransparency=1;arr.Text=">>";arr.TextColor3=C.red;arr.TextSize=10
    arr.Font=Enum.Font.GothamBold;arr.ZIndex=13;arr.Parent=row
    local btn=Instance.new("TextButton");btn.Size=UDim2.new(1,0,1,0);btn.BackgroundTransparency=1
    btn.Text="";btn.ZIndex=15;btn.Parent=row
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(row,TweenInfo.new(0.06),{BackgroundColor3=C.redDark}):Play()
        task.delay(0.12,function()TweenService:Create(row,TweenInfo.new(0.12),{BackgroundColor3=C.bg3}):Play()end)
        if callback then callback()end
    end)
end

local function MakeSlider(label,desc,min,max,default,callback)
    local row=Instance.new("Frame");row.Size=UDim2.new(1,0,0,56);row.BackgroundColor3=C.bg3
    row.BorderSizePixel=0;row.ZIndex=12;row.Parent=Content
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,6)
    Instance.new("UIStroke",row).Color=C.redDark
    local nl=Instance.new("TextLabel");nl.Size=UDim2.new(1,-16,0,18);nl.Position=UDim2.new(0,10,0,4)
    nl.BackgroundTransparency=1;nl.Text=label..": "..default;nl.TextColor3=C.text;nl.TextSize=12
    nl.Font=Enum.Font.GothamBold;nl.TextXAlignment=Enum.TextXAlignment.Left;nl.ZIndex=13;nl.Parent=row
    local dl=Instance.new("TextLabel");dl.Size=UDim2.new(1,-16,0,12);dl.Position=UDim2.new(0,10,0,22)
    dl.BackgroundTransparency=1;dl.Text=desc;dl.TextColor3=C.textDim;dl.TextSize=8
    dl.Font=Enum.Font.Gotham;dl.TextXAlignment=Enum.TextXAlignment.Left;dl.ZIndex=13;dl.Parent=row
    local btnMinus=Instance.new("TextButton");btnMinus.Size=UDim2.new(0,20,0,18);btnMinus.Position=UDim2.new(0,10,0,36)
    btnMinus.BackgroundColor3=C.redDark;btnMinus.Text="-";btnMinus.TextColor3=C.text;btnMinus.TextSize=12
    btnMinus.Font=Enum.Font.GothamBold;btnMinus.ZIndex=15;btnMinus.Parent=row
    Instance.new("UICorner",btnMinus).CornerRadius=UDim.new(0,4)
    local btnPlus=Instance.new("TextButton");btnPlus.Size=UDim2.new(0,20,0,18);btnPlus.Position=UDim2.new(0,34,0,36)
    btnPlus.BackgroundColor3=C.redDark;btnPlus.Text="+";btnPlus.TextColor3=C.text;btnPlus.TextSize=12
    btnPlus.Font=Enum.Font.GothamBold;btnPlus.ZIndex=15;btnPlus.Parent=row
    Instance.new("UICorner",btnPlus).CornerRadius=UDim.new(0,4)
    local val=default
    local function update()
        val=math.clamp(val,min,max);nl.Text=label..": "..val
        if callback then callback(val)end
    end
    btnMinus.MouseButton1Click:Connect(function()val=val-1;update()end)
    btnPlus.MouseButton1Click:Connect(function()val=val+1;update()end)
    return{set=function(v)val=v;update()end,get=function()return val end}
end

-- ESP (Highlight + BillboardGui)
local function addESP(part,color,text)
    if not part then return end
    local hl=Instance.new("Highlight");hl.FillColor=color;hl.OutlineColor=color
    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop;hl.Parent=part
    if part:IsA("Model")and part:FindFirstChild("Head")then
        local bbg=Instance.new("BillboardGui");bbg.Adornee=part.Head
        bbg.Size=UDim2.new(0,200,0,30);bbg.StudsOffset=Vector3.new(0,2,0);bbg.AlwaysOnTop=true
        local tl=Instance.new("TextLabel");tl.Size=UDim2.new(1,0,1,0)
        tl.BackgroundTransparency=1;tl.Text=text;tl.TextColor3=color;tl.TextScaled=true
        tl.Font=Enum.Font.SourceSansBold;tl.Parent=bbg;bbg.Parent=part
    end
end
local function removeESP(part)
    if part then for _,obj in pairs(part:GetChildren())do
        if obj:IsA("Highlight")or obj:IsA("BillboardGui")then obj:Destroy()end
    end end
end

-- ESP People (все игроки белым)
local function checkPeopleESP()
    for _,plr in pairs(Players:GetPlayers())do
        if plr~=LocalPlayer and plr.Character and not hasKnife(plr)and not hasGun(plr)then
            removeESP(plr.Character);addESP(plr.Character,Color3.new(1,1,1),plr.Name)
        end
    end
end
-- ESP Murderer (красный)
local function checkMurdererESP()
    for _,plr in pairs(Players:GetPlayers())do
        if plr~=LocalPlayer and plr.Character and hasKnife(plr)then
            removeESP(plr.Character);addESP(plr.Character,Color3.new(1,0,0),"Murderer - "..plr.Name)
        end
    end
end
-- ESP Sheriff (синий)
local function checkSheriffESP()
    for _,plr in pairs(Players:GetPlayers())do
        if plr~=LocalPlayer and plr.Character and hasGun(plr)then
            removeESP(plr.Character);addESP(plr.Character,Color3.new(0,0,1),"Sheriff - "..plr.Name)
        end
    end
end
-- ESP Gun (зелёный)
local function checkGunESP()
    local gunDrop=Workspace:FindFirstChild("Normal")and Workspace.Normal:FindFirstChild("GunDrop")
    if gunDrop then removeESP(gunDrop);addESP(gunDrop,Color3.new(0,1,0),"Dropped Gun")end
end

RunService.RenderStepped:Connect(function()
    if ESPPlayers then checkPeopleESP()end
    if ESPMurderer then checkMurdererESP()end
    if ESPSheriff then checkSheriffESP()end
    if ESPGun then checkGunESP()end
end)

-- Aimbot Circle (визуальный)
local function CreateAimbotCircle()
    if AimbotCircle then AimbotCircle:Destroy()end
    AimbotCircle=Instance.new("Frame")
    AimbotCircle.Size=UDim2.new(0,AimbotFOV,0,AimbotFOV)
    AimbotCircle.Position=UDim2.new(0.5,-AimbotFOV/2,0.5,-AimbotFOV/2)
    AimbotCircle.BackgroundTransparency=1
    AimbotCircle.BorderSizePixel=1
    AimbotCircle.BorderColor3=Color3.fromRGB(255,0,0)
    AimbotCircle.ZIndex=100
    AimbotCircle.Parent=ScreenGui
    local inner=Instance.new("Frame")
    inner.Size=UDim2.new(1,-4,1,-4);inner.Position=UDim2.new(0,2,0,2)
    inner.BackgroundTransparency=1;inner.BorderSizePixel=1
    inner.BorderColor3=Color3.fromRGB(255,0,0);inner.ZIndex=101;inner.Parent=AimbotCircle
    local dot=Instance.new("Frame")
    dot.Size=UDim2.new(0,4,0,4);dot.Position=UDim2.new(0.5,-2,0.5,-2)
    dot.BackgroundColor3=Color3.fromRGB(255,0,0);dot.BorderSizePixel=0
    dot.ZIndex=102;dot.Parent=AimbotCircle
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
end
local function UpdateAimbotCircle()
    if not ShowAimbotCircle then if AimbotCircle then AimbotCircle.Visible=false end;return end
    if not AimbotCircle or AimbotCircle.Size~=UDim2.new(0,AimbotFOV,0,AimbotFOV)then CreateAimbotCircle()end
    AimbotCircle.Visible=true
end
CreateAimbotCircle()
-- // YinYang: MM2 Hub v3.0 - Aimbot Circle [PART 2/4]

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

-- Aimbot с кругом FOV
local function ToggleAimbot(v)
    AimbotEnabled=v
    if v then UpdateAimbotCircle()
        AimbotConn=RunService.RenderStepped:Connect(function()
            UpdateAimbotCircle()
            local closest,minDist=nil,math.huge
            for _,plr in pairs(Players:GetPlayers())do
                if plr~=LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head")then
                    local targetRole="INNOCENT"
                    if hasKnife(plr)then targetRole="MURDERER"elseif hasGun(plr)then targetRole="SHERIFF"end
                    if IgnoreSheriff and targetRole=="SHERIFF"then continue end
                    if IgnoreInnocent and targetRole=="INNOCENT"then continue end
                    local pos,onScreen=Camera:WorldToScreenPoint(plr.Character.Head.Position)
                    if onScreen then
                        local screenCenter=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
                        local dist=(Vector2.new(pos.X,pos.Y)-screenCenter).Magnitude
                        if dist<minDist and dist<AimbotFOV/2 then minDist=dist;closest=plr end
                    end
                end
            end
            if closest and closest.Character and closest.Character:FindFirstChild("Head")then
                Camera.CFrame=CFrame.new(Camera.CFrame.Position,closest.Character.Head.Position)
            end
        end)
    else if AimbotConn then AimbotConn:Disconnect();AimbotConn=nil end
        if LocalPlayer.Character then Camera.CameraSubject=LocalPlayer.Character:FindFirstChild("Humanoid")end
        if AimbotCircle then AimbotCircle.Visible=false end
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

-- Fling
local FlingThread=nil
local function StartFling(targetFunc)
    if FlingEnabled then StopFling()end;FlingEnabled=true;local movel=0.1
    FlingThread=coroutine.create(function()
        while FlingEnabled do RunService.Heartbeat:Wait()
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
    end);coroutine.resume(FlingThread)
end
local function StopFling()FlingEnabled=false;FlingThread=nil end
-- // YinYang: MM2 Hub v3.0 - Aimbot Circle [PART 3/4]

-- Instant Kill
local function ToggleInstantKill(v)
    InstantKillEnabled=v
    if v then InstantKillConn=RunService.Heartbeat:Connect(function()
        if getMyRole()=="MURDERER"then local tool=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool and tool.Name=="Knife"and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")then
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
    KillAllEnabled=true
    local function killLoop()
        while KillAllEnabled do
            for _,plr in pairs(Players:GetPlayers())do
                if plr~=LocalPlayer and plr:GetAttribute("Alive")==true and plr.Character then
                    LocalPlayer.Character:SetPrimaryPartCFrame(plr.Character.PrimaryPart.CFrame)
                    task.wait(0.3)
                end
            end;task.wait(0.5)
        end
    end
    coroutine.wrap(killLoop)()
end
local function StopKillAll()KillAllEnabled=false end

-- Coin Farm
local function ToggleFarm(v)
    FarmEnabled=v
    if v then FarmConn=RunService.Heartbeat:Connect(function()
        local CoinContainer=Workspace:FindFirstChild("Normal")and Workspace.Normal:FindFirstChild("CoinContainer")
        if CoinContainer and LocalPlayer.Character then
            for _,coin in pairs(CoinContainer:GetChildren())do
                LocalPlayer.Character:SetPrimaryPartCFrame(coin.CFrame);task.wait(FarmCooldown)
            end
        end
    end)else if FarmConn then FarmConn:Disconnect();FarmConn=nil end end
end

-- TP функции
local function TPMurderer()
    local murd=getMurderer()
    if murd and murd.Character then
        LocalPlayer.Character:SetPrimaryPartCFrame(murd.Character.PrimaryPart.CFrame)
        StarterGui:SetCore("SendNotification",{Title="TP",Text="Murderer: "..murd.Name,Duration=2})
    end
end
local function TPSheriff()
    local sher=getSheriff()
    if sher and sher.Character then
        LocalPlayer.Character:SetPrimaryPartCFrame(sher.Character.PrimaryPart.CFrame)
        StarterGui:SetCore("SendNotification",{Title="TP",Text="Sheriff: "..sher.Name,Duration=2})
    end
end
local function TPGun()
    local gunDrop=Workspace:FindFirstChild("Normal")and Workspace.Normal:FindFirstChild("GunDrop")
    if gunDrop and LocalPlayer.Character then
        LocalPlayer.Character:SetPrimaryPartCFrame(gunDrop.CFrame)
        task.wait(0.1);firetouchinterest(LocalPlayer.Character.HumanoidRootPart,gunDrop,0)
        firetouchinterest(LocalPlayer.Character.HumanoidRootPart,gunDrop,1)
        StarterGui:SetCore("SendNotification",{Title="TP Gun",Text="Equipped!",Duration=2})
    end
end
local function TPPlayer()
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
    if closest and minDist<200 then LocalPlayer.Character:SetPrimaryPartCFrame(closest.Character.PrimaryPart.CFrame)end
end
local function FlingMurderer()StartFling(getMurderer)end
local function FlingSheriff()StartFling(getSheriff)end

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

-- Gravity / Walkspeed / JumpPower
local function SetGravity(v)Workspace.Gravity=v end
local function SetWalkspeed(v)
    local hum=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed=v end;WalkspeedVal=v
end
local function SetJumpPower(v)
    local hum=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then hum.JumpPower=v end;JumpPowerVal=v
end
RunService.Heartbeat:Connect(function()
    if WalkspeedVal~=16 then SetWalkspeed(WalkspeedVal)end
    if JumpPowerVal~=50 then SetJumpPower(JumpPowerVal)end
end)

-- Cleanup
local function CleanupAll()
    ESPPlayers,ESPMurderer,ESPSheriff,ESPGun=false,false,false,false
    ToggleNoClip(false);ToggleAimbot(false);ToggleGodMode(false);ToggleAntiAFK(false)
    ToggleFullBright(false);ToggleInstantKill(false)
    ToggleFarm(false);StopKillAll()
    if FlyEnabled then DisableFly()end;if FlingEnabled then StopFling()end
    if AimbotCircle then AimbotCircle:Destroy();AimbotCircle=nil end
    if Lighting:FindFirstChild("MM2_Brightness")then Lighting.MM2_Brightness:Destroy()end
end

-- Respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.3)
    if NoClipEnabled then NoClipEnabled=false;task.wait(0.1);ToggleNoClip(true)end
    if GodModeEnabled then local hum=char:WaitForChild("Humanoid",3);if hum then hum.MaxHealth=math.huge;hum.Health=math.huge end end
    if FlyEnabled then FlyEnabled=false;task.wait(0.1);EnableFly()end
    if InstantKillEnabled then InstantKillEnabled=false;task.wait(0.2);ToggleInstantKill(true)end
end)
-- // YinYang: MM2 Hub v3.0 - Aimbot Circle [PART 4/4]

-- Toggles
MakeToggle("ESP People","Белая подсветка невинных",function(v)ESPPlayers=v end)
MakeToggle("ESP Murderer","Красная подсветка убийцы",function(v)ESPMurderer=v end)
MakeToggle("ESP Sheriff","Синяя подсветка шерифа",function(v)ESPSheriff=v end)
MakeToggle("ESP Gun","Зелёная подсветка пистолета",function(v)ESPGun=v end)
MakeToggle("Flight","Свободный полёт",function(v)if v then EnableFly()else DisableFly()end end)
MakeToggle("NoClip","Проход сквозь стены",ToggleNoClip)
MakeToggle("Aimbot","Автонаводка",ToggleAimbot)
MakeToggle("Show Circle","Показать круг аимбота",function(v)ShowAimbotCircle=v;if v then UpdateAimbotCircle()else if AimbotCircle then AimbotCircle.Visible=false end end end)
MakeToggle("Ignore Sheriff","Не целиться в шерифа",function(v)IgnoreSheriff=v end)
MakeToggle("Ignore Innocent","Не целиться в невинных",function(v)IgnoreInnocent=v end)
MakeToggle("Instant Kill","Мгновенный удар",ToggleInstantKill)
MakeToggle("God Mode","Бессмертие",ToggleGodMode)
MakeToggle("Anti AFK","Защита от кика",ToggleAntiAFK)
MakeToggle("Full Bright","Яркое освещение",ToggleFullBright)
MakeToggle("Coin Farm","Автосбор монет",ToggleFarm)

-- Sliders
MakeSlider("Aimbot FOV","Размер круга (50-360)",50,360,120,function(v)AimbotFOV=v;UpdateAimbotCircle()end)
MakeSlider("Walkspeed","Скорость ходьбы",16,200,16,SetWalkspeed)
MakeSlider("Jump Power","Высота прыжка",50,500,50,SetJumpPower)
MakeSlider("Gravity","Гравитация",50,400,196,SetGravity)
MakeSlider("Farm CD","Задержка фарма (сек)",0.05,1,0.1,function(v)FarmCooldown=v end)

-- Actions
MakeAction("Kill All","Убить всех (Murderer)",KillAll)
MakeAction("Stop Kill All","Остановить Kill All",StopKillAll)
MakeAction("TP to Murderer","Телепорт к убийце",TPMurderer)
MakeAction("TP to Sheriff","Телепорт к шерифу",TPSheriff)
MakeAction("TP to Gun","Телепорт к пистолету",TPGun)
MakeAction("Fling Murderer","Флинг к убийце",FlingMurderer)
MakeAction("Fling Sheriff","Флинг к шерифу",FlingSheriff)
MakeAction("TP to Player","Телепорт к ближайшему",TPPlayer)
MakeAction("Server Hop","Смена сервера",ServerHop)
MakeAction("FPS Boost","Повышение FPS",FPSBoost)
MakeAction("Close Hub","Закрыть панель",function()CleanupAll();closeMenu()end)

-- Animation
local menuOpen=false
function openMenu()
    menuOpen=true;Panel.Visible=true;Overlay.Visible=true;Panel.Position=UDim2.new(0,0,1,0)
    TweenService:Create(Panel,TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(0,0,1,-340)}):Play()
    TweenService:Create(Overlay,TweenInfo.new(0.2),{BackgroundTransparency=0.55}):Play()
end
function closeMenu()
    menuOpen=false
    TweenService:Create(Panel,TweenInfo.new(0.2,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Position=UDim2.new(0,0,1,0)}):Play()
    TweenService:Create(Overlay,TweenInfo.new(0.15),{BackgroundTransparency=1}):Play()
    task.delay(0.2,function()Panel.Visible=false;Overlay.Visible=false end)
end

local btnTapMoved=false
ToggleBtn.InputBegan:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.Touch or inp.UserInputType==Enum.UserInputType.MouseButton1 then btnTapMoved=false end
end)
UserInputService.InputChanged:Connect(function(inp)if draggingBtn then btnTapMoved=true end end)
ToggleBtn.InputEnded:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.Touch or inp.UserInputType==Enum.UserInputType.MouseButton1 then
        if not btnTapMoved then if menuOpen then closeMenu()else openMenu()end end;draggingBtn=false
    end
end)
CloseBtn.MouseButton1Click:Connect(closeMenu)
Overlay.MouseButton1Click:Connect(closeMenu)

print("MM2 Hub v3.0 - Aimbot Circle loaded.")
