local _T = _G.TVL2
local State = _T.State
local Config = _T.Config
local SaveConfig = _T.SaveConfig
local SilentAimSettings = _T.SilentAimSettings
local ESPSettings = _T.ESPSettings
local ESPCache = _T.ESPCache
local FriendCache = _T.FriendCache
local WhitelistCache = _T.WhitelistCache
local EnemyCache = _T.EnemyCache
local Connections = _T.Connections
local Players = _T.Players
local LP = _T.LP
local Camera = _T.Camera
local Mouse = _T.Mouse
local UIS = _T.UIS
local RunService = _T.RunService
local TweenService = _T.TweenService
local TeleportService = _T.TeleportService
local CoreGui = _T.CoreGui
local SoundService = _T.SoundService
local ReplicatedStorage = _T.ReplicatedStorage
local Lighting = _T.Lighting
local AbilityActivated = _T.AbilityActivated
local BeginAbility = _T.BeginAbility
local SiphonRemote = _T.SiphonRemote
local AbilitySelected = _T.AbilitySelected
local ClearExpander = _T.ClearExpander
local CreateExpander = _T.CreateExpander
local RemoveESP = _T.RemoveESP
local CreateESP = _T.CreateESP
local PlayNotifySound = _T.PlayNotifySound
local N = _T.N
local C3 = _T.C3
local U2 = _T.U2
local GFB = _T.GFB
local GFM = _T.GFM
local GF = _T.GF
local ETXA = _T.ETXA
local UI = {}
local NotifySoundID = "rbxassetid://4590662766"

if CoreGui:FindFirstChild("TVL2_Hub_Unique") then CoreGui.TVL2_Hub_Unique:Destroy() end

UI.TVL2 = N("ScreenGui", CoreGui)
UI.TVL2.Name = "TVL2_Hub_Unique"
UI.TVL2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local NotifyStack = {}
local NOTIF_W = 280; local NOTIF_H = 75; local NOTIF_GAP = 8; local NOTIF_MARGIN_RIGHT = 12; local NOTIF_MARGIN_BOTTOM = 20

local function RealignNotifications()
    for i, nf in ipairs(NotifyStack) do
        local idx = #NotifyStack - i
        local targetY = 1 - (NOTIF_MARGIN_BOTTOM + (NOTIF_H + NOTIF_GAP) * idx) / (game:GetService("GuiService"):GetGuiInset().Y > 0 and 1 or 1)
        local targetPos = U2(1, -(NOTIF_W + NOTIF_MARGIN_RIGHT), 1, -(NOTIF_MARGIN_BOTTOM + (NOTIF_H + NOTIF_GAP) * idx + NOTIF_H))
        TweenService:Create(nf, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Position = targetPos}):Play()
    end
end

local function Notify(title, text)
    local nFrame = N("Frame", UI.TVL2)
    nFrame.Size = U2(0, NOTIF_W, 0, NOTIF_H)
    local startIdx = #NotifyStack
    nFrame.Position = U2(1, 50, 1, -(NOTIF_MARGIN_BOTTOM + (NOTIF_H + NOTIF_GAP) * startIdx + NOTIF_H))
    nFrame.BackgroundColor3 = C3(15, 15, 20); nFrame.BorderSizePixel = 0; nFrame.ZIndex = 100
    N("UICorner", nFrame).CornerRadius = UDim.new(0, 15)
    local stroke = N("UIStroke", nFrame); stroke.Color = State.ThemeColor; stroke.Thickness = 1.5

    local tl = N("TextLabel", nFrame)
    tl.Text = title; tl.Size = U2(1, -20, 0, 28); tl.Position = U2(0, 12, 0, 7)
    tl.TextColor3 = State.ThemeColor; tl.Font = GFB; tl.TextSize = 14; tl.BackgroundTransparency = 1; tl.TextXAlignment = ETXA.Left; tl.ZIndex = 101

    local ml = N("TextLabel", nFrame)
    ml.Text = text; ml.Size = U2(1, -24, 0, 32); ml.Position = U2(0, 12, 0, 36)
    ml.TextColor3 = C3(220, 220, 220); ml.Font = GF; ml.TextSize = 12
    ml.BackgroundTransparency = 1; ml.TextXAlignment = ETXA.Left; ml.TextWrapped = true; ml.ZIndex = 101

    pcall(function() local s = N("Sound", SoundService); s.SoundId = NotifySoundID; s.Volume = 0.5; s:Play(); game:GetService("Debris"):AddItem(s, 2) end)
    table.insert(NotifyStack, nFrame); RealignNotifications()

    task.delay(3.5, function()
        if nFrame and nFrame.Parent then
            TweenService:Create(nFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = U2(1, 50, nFrame.Position.Y.Scale, nFrame.Position.Y.Offset)}):Play()
            task.wait(0.45)
            for i, nf in ipairs(NotifyStack) do if nf == nFrame then table.remove(NotifyStack, i) break end end
            if nFrame then nFrame:Destroy() end
            RealignNotifications()
        end
    end)
end

UI.Main = N("Frame", UI.TVL2)
UI.Main.Size = U2(0, 791, 0, 531); UI.Main.Position = U2(0.5, -395, 0.5, -265)
UI.Main.BackgroundColor3 = C3(10, 10, 14); UI.Main.BorderSizePixel = 0; UI.Main.ZIndex = 2
N("UICorner", UI.Main).CornerRadius = UDim.new(0, 22)
UI.mainStroke = N("UIStroke", UI.Main); UI.mainStroke.Color = State.ThemeColor; UI.mainStroke.Thickness = 1.2; UI.mainStroke.Transparency = 0.5

UI.Bg = N("ImageLabel", UI.Main)
UI.Bg.Size = U2(1, 0, 1, 0); UI.Bg.Image = "rbxassetid://18430772548"
UI.Bg.ImageTransparency = 0.75; UI.Bg.BackgroundTransparency = 1; UI.Bg.ScaleType = Enum.ScaleType.Crop; UI.Bg.ZIndex = 2
N("UICorner", UI.Bg).CornerRadius = UDim.new(0, 22)

UI.Side = N("Frame", UI.Main)
UI.Side.Size = U2(0, 200, 1, 0); UI.Side.BackgroundColor3 = C3(0, 0, 0); UI.Side.BackgroundTransparency = 0.45; UI.Side.ZIndex = 3
N("UICorner", UI.Side).CornerRadius = UDim.new(0, 22)

UI.T1 = N("TextLabel", UI.Side)
UI.T1.Size = U2(1, 0, 0, 38)
UI.T1.Position = U2(0, 0, 0, 18)
UI.T1.Text = "TVL2 Hub"
UI.T1.TextColor3 = State.ThemeColor
UI.T1.Font = GFB
UI.T1.TextSize = 24
UI.T1.BackgroundTransparency = 1
UI.T1.ZIndex = 4

UI.T2 = N("TextLabel", UI.Side)
UI.T2.Size = U2(1, 0, 0, 18); UI.T2.Position = U2(0, 0, 0, 52)
UI.T2.Text = string.char(98,121,32,68,104,101,114,122)
UI.T2.TextColor3 = C3(170, 170, 170); UI.T2.Font = GFM; UI.T2.TextSize = 12; UI.T2.BackgroundTransparency = 1; UI.T2.ZIndex = 4

UI.Div = N("Frame", UI.Side)
UI.Div.Size = U2(0.8, 0, 0, 1)
UI.Div.Position = U2(0.1, 0, 0, 76)
UI.Div.BackgroundColor3 = State.ThemeColor
UI.Div.BackgroundTransparency = 0.6
UI.Div.BorderSizePixel = 0
UI.Div.ZIndex = 4

UI.ProfileCard = N("Frame", UI.Side)
UI.ProfileCard.Size = U2(0.9, 0, 0, 56); UI.ProfileCard.Position = U2(0.05, 0, 1, -68); UI.ProfileCard.BackgroundTransparency = 1; UI.ProfileCard.ZIndex = 4

UI.AvatarImg = N("ImageLabel", UI.ProfileCard)
UI.AvatarImg.Size = U2(0, 42, 0, 42)
UI.AvatarImg.Position = U2(0, 4, 0.5, -21)
UI.AvatarImg.BackgroundColor3 = C3(30, 30, 35)
UI.AvatarImg.BorderSizePixel = 0
UI.AvatarImg.ZIndex = 5
N("UICorner", UI.AvatarImg).CornerRadius = UDim.new(1, 0)
pcall(function() UI.AvatarImg.Image = Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end)

UI.DisplayName = N("TextLabel", UI.ProfileCard)
UI.DisplayName.Size = U2(1, -56, 0, 20)
UI.DisplayName.Position = U2(0, 52, 0.1, 0)
UI.DisplayName.Text = LP.DisplayName
UI.DisplayName.TextColor3 = C3(255, 255, 255)
UI.DisplayName.Font = GFB
UI.DisplayName.TextSize = 13
UI.DisplayName.BackgroundTransparency = 1
UI.DisplayName.TextXAlignment = ETXA.Left
UI.DisplayName.ZIndex = 5

UI.UserTag = N("TextLabel", UI.ProfileCard)
UI.UserTag.Size = U2(1, -56, 0, 18)
UI.UserTag.Position = U2(0, 52, 0.55, 0)
UI.UserTag.Text = "@" .. LP.Name
UI.UserTag.TextColor3 = C3(140, 140, 140)
UI.UserTag.Font = GFM
UI.UserTag.TextSize = 11
UI.UserTag.BackgroundTransparency = 1
UI.UserTag.TextXAlignment = ETXA.Left
UI.UserTag.ZIndex = 5

UI.Nav = N("ScrollingFrame", UI.Side)
UI.Nav.Size = U2(1, 0, 1, -200)
UI.Nav.Position = U2(0, 0, 0, 92)
UI.Nav.BackgroundTransparency = 1
UI.Nav.ScrollBarThickness = 0
UI.Nav.ZIndex = 4
UI.Nav.CanvasSize = U2(0, 0, 0, 0)
UI.Nav.AutomaticCanvasSize = Enum.AutomaticSize.Y

UI.NavLayout = N("UIListLayout", UI.Nav); UI.NavLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; UI.NavLayout.Padding = UDim.new(0, 7)
UI.NavPad = N("UIPadding", UI.Nav); UI.NavPad.PaddingTop = UDim.new(0, 8)

UI.Container = N("Frame", UI.Main)
UI.Container.Size = U2(1, -225, 1, -30); UI.Container.Position = U2(0, 215, 0, 15); UI.Container.BackgroundTransparency = 1; UI.Container.ZIndex = 3

local Pages = {}
local CurrentTab = nil
local _ActionPanelRef = {}

UI.CloseBtn = N("TextButton", UI.Main)
UI.CloseBtn.Size = U2(0, 28, 0, 28)
UI.CloseBtn.Position = U2(1, -36, 0, 8)
UI.CloseBtn.BackgroundColor3 = C3(200, 50, 50)
UI.CloseBtn.Text = "✕"
UI.CloseBtn.TextColor3 = C3(255,255,255)
UI.CloseBtn.Font = GFB
UI.CloseBtn.TextSize = 13
UI.CloseBtn.BorderSizePixel = 0
UI.CloseBtn.ZIndex = 10
N("UICorner", UI.CloseBtn).CornerRadius = UDim.new(0, 8)
UI.CloseBtn.MouseButton1Click:Connect(function() UI.Main.Visible = false end)

local function MakeRow(parent, ySize)
    local row = N("Frame", parent)
    row.Size = U2(1, -20, 0, ySize or 40); row.BackgroundColor3 = C3(255,255,255); row.BackgroundTransparency = 0.93; row.BorderSizePixel = 0; row.ZIndex = parent.ZIndex + 1
    N("UICorner", row).CornerRadius = UDim.new(0, 10)
    return row
end

local function NewTab(name)
    local b = N("TextButton", UI.Nav)
    b.Size = U2(0.88, 0, 0, 40)
    b.BackgroundColor3 = C3(255,255,255)
    b.BackgroundTransparency = 0.93
    b.Text = name
    b.TextColor3 = C3(200,200,200)
    b.Font = GFM
    b.TextSize = 13
    b.ZIndex = 5
    b.AutoButtonColor = false
    b.TextXAlignment = ETXA.Left
    local btnPad = N("UIPadding", b); btnPad.PaddingLeft = UDim.new(0, 18)
    N("UICorner", b).CornerRadius = UDim.new(0, 11)

    local indicator = N("Frame", b)
    indicator.Size = U2(0, 3, 0.6, 0)
    indicator.Position = U2(0, -4, 0.2, 0)
    indicator.BackgroundColor3 = State.ThemeColor
    indicator.BackgroundTransparency = 1
    indicator.BorderSizePixel = 0
    indicator.ZIndex = 6
    N("UICorner", indicator).CornerRadius = UDim.new(0, 4)

    local p = N("ScrollingFrame", UI.Container)
    p.Size = U2(1, 0, 1, 0)
    p.Visible = false
    p.BackgroundTransparency = 1
    p.ScrollBarThickness = 3
    p.ScrollBarImageColor3 = State.ThemeColor
    p.CanvasSize = U2(0, 0, 0, 0)
    p.AutomaticCanvasSize = Enum.AutomaticSize.Y
    p.ZIndex = 4

    local pL = N("UIListLayout", p); pL.HorizontalAlignment = Enum.HorizontalAlignment.Center; pL.Padding = UDim.new(0, 8)
    local pPad = N("UIPadding", p); pPad.PaddingTop = UDim.new(0, 8); pPad.PaddingBottom = UDim.new(0, 12)

    Pages[name] = {page = p, btn = b, indicator = indicator}

    b.MouseButton1Click:Connect(function()
        for tname, t in pairs(Pages) do
            t.page.Visible = false
            TweenService:Create(t.btn, TweenInfo.new(0.25), {BackgroundTransparency = 0.93, TextColor3 = C3(200,200,200)}):Play()
            TweenService:Create(t.indicator, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
        end
        p.Visible = true
        TweenService:Create(b, TweenInfo.new(0.25), {BackgroundTransparency = 0.78, TextColor3 = State.ThemeColor}):Play()
        TweenService:Create(indicator, TweenInfo.new(0.25), {BackgroundTransparency = 0}):Play()
        CurrentTab = name
        if _ActionPanelRef[1] then _ActionPanelRef[1].Visible = false end
    end)
    return p
end

local function AddLabel(page, text)
    local row = MakeRow(page, 32)
    local lbl = N("TextLabel", row)
    lbl.Size = U2(1, -20, 1, 0)
    lbl.Position = U2(0, 10, 0, 0)
    lbl.Text = text
    lbl.TextColor3 = C3(160,160,160)
    lbl.Font = GFM
    lbl.TextSize = 12
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = ETXA.Left
    lbl.ZIndex = row.ZIndex + 1
    return { Set = function(newText) lbl.Text = newText end, Row = row }
end

local function AddToggle(page, name, default, callback)
    local row = MakeRow(page, 42)
    local lbl = N("TextLabel", row)
    lbl.Size = U2(1, -70, 1, 0)
    lbl.Position = U2(0, 14, 0, 0)
    lbl.Text = name
    lbl.TextColor3 = C3(230,230,230)
    lbl.Font = GFM
    lbl.TextSize = 13
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = ETXA.Left
    lbl.ZIndex = row.ZIndex + 1

    local trackBg = N("Frame", row)
    trackBg.Name = "ThemeToggleBg"
    trackBg.Size = U2(0, 44, 0, 24)
    trackBg.Position = U2(1, -56, 0.5, -12)
    trackBg.BackgroundColor3 = C3(50,50,55)
    trackBg.BorderSizePixel = 0
    trackBg.ZIndex = row.ZIndex + 1
    N("UICorner", trackBg).CornerRadius = UDim.new(1, 0)
    local knob = N("Frame", trackBg)
    knob.Size = U2(0, 18, 0, 18)
    knob.Position = U2(0, 3, 0.5, -9)
    knob.BackgroundColor3 = C3(180,180,180)
    knob.BorderSizePixel = 0
    knob.ZIndex = row.ZIndex + 2
    N("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local state = default or false
    local function SetState(val)
        state = val
        TweenService:Create(trackBg, TweenInfo.new(0.2), {BackgroundColor3 = state and State.ThemeColor or C3(50,50,55)}):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), {Position = state and U2(1, -21, 0.5, -9)
                or U2(0, 3, 0.5, -9), BackgroundColor3 = state and C3(255,255,255) or C3(180,180,180)}):Play()
        if callback then callback(state) end
    end
    SetState(state)

    local btn = N("TextButton", row); btn.Size = U2(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = row.ZIndex + 3
    btn.MouseButton1Click:Connect(function() SetState(not state); Notify(name, name .. ": " .. (state and "ON" or "OFF")) end)
    return { Set = SetState, Get = function() return state end }
end

local function AddButton(page, name, callback)
    local row = MakeRow(page, 40); row.BackgroundTransparency = 0.88
    local lbl = N("TextLabel", row)
    lbl.Name = "ThemeBtnLbl"
    lbl.Size = U2(1, 0, 1, 0)
    lbl.Text = name
    lbl.TextColor3 = State.ThemeColor
    lbl.Font = GFB
    lbl.TextSize = 13
    lbl.BackgroundTransparency = 1
    lbl.ZIndex = row.ZIndex + 1
    local btn = N("TextButton", row); btn.Size = U2(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = row.ZIndex + 2
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.1), {BackgroundColor3 = State.ThemeColor, BackgroundTransparency = 0.7}):Play()
        task.delay(0.15, function() TweenService:Create(row, TweenInfo.new(0.2), {BackgroundColor3 = C3(255,255,255), BackgroundTransparency = 0.88}):Play() end)
        if callback then callback() end
    end)
end

local function AddSlider(page, name, min, max, default, suffix, callback)
    local row = MakeRow(page, 58)
    local lbl = N("TextLabel", row)
    lbl.Size = U2(0.6, 0, 0, 22)
    lbl.Position = U2(0, 14, 0, 6)
    lbl.Text = name
    lbl.TextColor3 = C3(230,230,230)
    lbl.Font = GFM
    lbl.TextSize = 12
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = ETXA.Left
    lbl.ZIndex = row.ZIndex + 1
    local valLbl = N("TextLabel", row)
    valLbl.Size = U2(0.35, 0, 0, 22)
    valLbl.Position = U2(0.62, 0, 0, 6)
    valLbl.Text = tostring(default) .. " " .. (suffix or "")
    valLbl.Name = "ThemeValLbl"
    valLbl.TextColor3 = State.ThemeColor
    valLbl.Font = GFB
    valLbl.TextSize = 12
    valLbl.BackgroundTransparency = 1
    valLbl.TextXAlignment = ETXA.Right
    valLbl.ZIndex = row.ZIndex + 1
    local track = N("Frame", row)
    track.Size = U2(1, -28, 0, 6)
    track.Position = U2(0, 14, 0, 38)
    track.BackgroundColor3 = C3(50,50,55)
    track.BorderSizePixel = 0
    track.ZIndex = row.ZIndex + 1
    N("UICorner", track).CornerRadius = UDim.new(1, 0)
    local fill = N("Frame", track)
    fill.Name = "ThemeFill"
    fill.BackgroundColor3 = State.ThemeColor
    fill.BorderSizePixel = 0
    fill.ZIndex = row.ZIndex + 2
    N("UICorner", fill).CornerRadius = UDim.new(1, 0)
    local knob = N("Frame", track)
    knob.Size = U2(0, 14, 0, 14)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.BackgroundColor3 = C3(255,255,255)
    knob.BorderSizePixel = 0
    knob.ZIndex = row.ZIndex + 3
    N("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local currentVal = math.clamp(default, min, max)
    local function SetVal(v)
        currentVal = math.clamp(v, min, max)
        local pct = (currentVal - min) / (max - min)
        fill.Size = U2(pct, 0, 1, 0); knob.Position = U2(pct, 0, 0.5, 0)
        valLbl.Text = tostring(math.floor(currentVal)) .. " " .. (suffix or "")
        if callback then callback(currentVal) end
    end
    SetVal(currentVal)

    local dragging = false
    local function UpdateFromMouse(x)
        local abs = track.AbsolutePosition.X; local sz = track.AbsoluteSize.X
        local pct = math.clamp((x - abs) / sz, 0, 1)
        SetVal(min + (max - min) * pct)
    end

    local btn = N("TextButton", track); btn.Size = U2(1, 0, 3, -10); btn.Position = U2(0, 0, -1, 5); btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = row.ZIndex + 4
    btn.MouseButton1Down:Connect(function() dragging = true; UpdateFromMouse(UIS:GetMouseLocation().X) end)
    btn.MouseButton1Up:Connect(function() dragging = false end)

    table.insert(Connections, UIS.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then UpdateFromMouse(input.Position.X) end end))
    table.insert(Connections, UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end))
end

local function AddInput(page, name, placeholder, callback)
    local row = MakeRow(page, 52)
    local lbl = N("TextLabel", row)
    lbl.Size = U2(1, -20, 0, 20)
    lbl.Position = U2(0, 14, 0, 6)
    lbl.Text = name
    lbl.TextColor3 = C3(200,200,200)
    lbl.Font = GFM
    lbl.TextSize = 11
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = ETXA.Left
    lbl.ZIndex = row.ZIndex + 1
    local box = N("TextBox", row)
    box.Size = U2(1, -28, 0, 24)
    box.Position = U2(0, 14, 0, 23)
    box.BackgroundColor3 = C3(20,20,25)
    box.BackgroundTransparency = 0.3
    box.TextColor3 = C3(240,240,240)
    box.PlaceholderText = placeholder or ""
    box.PlaceholderColor3 = C3(100,100,100)
    box.Font = GF
    box.TextSize = 12
    box.Text = ""
    box.BorderSizePixel = 0
    box.ZIndex = row.ZIndex + 2
    box.ClearTextOnFocus = false
    N("UICorner", box).CornerRadius = UDim.new(0, 7)
    box:GetPropertyChangedSignal("Text"):Connect(function() if callback then callback(box.Text) end end)
    return { Box = box }
end

local function AddDropdown(page, name, options, callback)
    local row = MakeRow(page, 44)
    local isOpen = false; local selected = options[1] or ""
    local lbl = N("TextLabel", row)
    lbl.Size = U2(0.55, 0, 1, 0)
    lbl.Position = U2(0, 14, 0, 0)
    lbl.Text = name
    lbl.TextColor3 = C3(220,220,220)
    lbl.Font = GFM
    lbl.TextSize = 13
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = ETXA.Left
    lbl.ZIndex = row.ZIndex + 1
    local selLbl = N("TextLabel", row)
    selLbl.Name = "ThemeSelLbl"
    selLbl.Size = U2(0.42, 0, 1, 0)
    selLbl.Position = U2(0.56, 0, 0, 0)
    selLbl.Text = selected
    selLbl.TextColor3 = State.ThemeColor
    selLbl.Font = GFM
    selLbl.TextSize = 12
    selLbl.BackgroundTransparency = 1
    selLbl.TextXAlignment = ETXA.Right
    selLbl.ZIndex = row.ZIndex + 1
    local arrow = N("TextLabel", row)
    arrow.Name = "ThemeArrow"
    arrow.Size = U2(0, 20, 1, 0)
    arrow.Position = U2(1, -24, 0, 0)
    arrow.Text = "▾"
    arrow.TextColor3 = State.ThemeColor
    arrow.Font = GFB
    arrow.TextSize = 14
    arrow.BackgroundTransparency = 1
    arrow.ZIndex = row.ZIndex + 1

    local dropFrame = N("Frame", UI.TVL2)
    dropFrame.BackgroundColor3 = C3(18,18,22)
    dropFrame.BorderSizePixel = 0
    dropFrame.Visible = false
    dropFrame.ZIndex = 50
    N("UICorner", dropFrame).CornerRadius = UDim.new(0, 10)
    local dStroke = N("UIStroke", dropFrame); dStroke.Color = State.ThemeColor; dStroke.Thickness = 1; dStroke.Transparency = 0.5
    local dLayout = N("UIListLayout", dropFrame); dLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; dLayout.Padding = UDim.new(0, 3)
    local dPad = N("UIPadding", dropFrame); dPad.PaddingTop = UDim.new(0, 5); dPad.PaddingBottom = UDim.new(0, 5)

    local currentOptions = {}; local optBtns = {}
    local function RebuildOptions(opts)
        for _, b in pairs(optBtns) do b:Destroy() end
        optBtns = {}; currentOptions = opts
        for _, opt in ipairs(opts) do
            local ob = N("TextButton", dropFrame)
            ob.Size = U2(0.92, 0, 0, 30)
            ob.BackgroundColor3 = C3(255,255,255)
            ob.BackgroundTransparency = 0.95
            ob.Text = opt
            ob.TextColor3 = C3(220,220,220)
            ob.Font = GFM
            ob.TextSize = 12
            ob.BorderSizePixel = 0
            ob.ZIndex = 51
            ob.AutoButtonColor = false
            N("UICorner", ob).CornerRadius = UDim.new(0, 8)
            ob.MouseButton1Click:Connect(function()
                selected = opt; selLbl.Text = opt; isOpen = false; dropFrame.Visible = false; arrow.Text = "▾"
                if callback then callback({opt}) end
            end)
            table.insert(optBtns, ob)
        end
        dropFrame.Size = U2(0, row.AbsoluteSize.X, 0, math.min(#opts * 33 + 14, 160))
    end
    RebuildOptions(options)

    local toggleBtn = N("TextButton", row); toggleBtn.Size = U2(1, 0, 1, 0); toggleBtn.BackgroundTransparency = 1; toggleBtn.Text = ""; toggleBtn.ZIndex = row.ZIndex + 2
    toggleBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            local absPos = row.AbsolutePosition
            dropFrame.Position = U2(0, absPos.X, 0, absPos.Y + row.AbsoluteSize.Y + 4)
            dropFrame.Size = U2(0, row.AbsoluteSize.X, 0, math.min(#currentOptions * 33 + 14, 160))
            arrow.Text = "▴"
        else arrow.Text = "▾" end
        dropFrame.Visible = isOpen
    end)
    return { Refresh = function(newOpts) RebuildOptions(newOpts); if #newOpts > 0 then selected = newOpts[1]; selLbl.Text = newOpts[1]; if callback then callback({newOpts[1]}) end end end }
end

local function AddKeybind(page, name, defaultKey, callback, holdMode, onKeyChanged)
    local row = MakeRow(page, 42); local currentKey = defaultKey; local listening = false
    local lbl = N("TextLabel", row)
    lbl.Size = U2(0.6, 0, 1, 0)
    lbl.Position = U2(0, 14, 0, 0)
    lbl.Text = name
    lbl.TextColor3 = C3(220,220,220)
    lbl.Font = GFM
    lbl.TextSize = 13
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = ETXA.Left
    lbl.ZIndex = row.ZIndex + 1
    local keyBtn = N("TextButton", row)
    keyBtn.Size = U2(0, 70, 0, 26)
    keyBtn.Position = U2(1, -82, 0.5, -13)
    keyBtn.Name = "ThemeKeyBtn"
    keyBtn.BackgroundColor3 = C3(30,30,35)
    keyBtn.Text = currentKey
    keyBtn.TextColor3 = State.ThemeColor
    keyBtn.Font = GFB
    keyBtn.TextSize = 12
    keyBtn.BorderSizePixel = 0
    keyBtn.ZIndex = row.ZIndex + 2
    N("UICorner", keyBtn).CornerRadius = UDim.new(0, 7)

    keyBtn.MouseButton1Click:Connect(function() listening = true; keyBtn.Text = "..."; keyBtn.TextColor3 = C3(255,200,0) end)
    table.insert(Connections, UIS.InputBegan:Connect(function(input, gpe)
        if listening and not gpe then
            listening = false; currentKey = input.KeyCode.Name; keyBtn.Text = currentKey; keyBtn.TextColor3 = State.ThemeColor
            if onKeyChanged then onKeyChanged(currentKey) end
        elseif not gpe and input.KeyCode == Enum.KeyCode[currentKey] then
            if callback then callback(true) end
        end
    end))
    if holdMode then
        table.insert(Connections, UIS.InputEnded:Connect(function(input, gpe)
            if not gpe and input.KeyCode == Enum.KeyCode[currentKey] then if callback then callback(false) end end
        end))
    end
    return { GetKey = function() return currentKey end }
end

local function AddToggleKeybind(page, name, defaultToggle, defaultKey, toggleCallback, keyCallback, holdMode, onKeyChanged)
    local row = MakeRow(page, 42); local currentKey = defaultKey; local listening = false
    local lbl = N("TextLabel", row)
    lbl.Size = U2(1, -130, 1, 0)
    lbl.Position = U2(0, 14, 0, 0)
    lbl.Text = name
    lbl.TextColor3 = C3(230,230,230)
    lbl.Font = GFM
    lbl.TextSize = 13
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = ETXA.Left
    lbl.ZIndex = row.ZIndex + 1
    local trackBg = N("Frame", row)
    trackBg.Name = "ThemeToggleBg"
    trackBg.Size = U2(0, 38, 0, 20)
    trackBg.Position = U2(1, -122, 0.5, -10)
    trackBg.BackgroundColor3 = C3(50,50,55)
    trackBg.BorderSizePixel = 0
    trackBg.ZIndex = row.ZIndex + 1
    N("UICorner", trackBg).CornerRadius = UDim.new(1, 0)
    local knob = N("Frame", trackBg)
    knob.Size = U2(0, 14, 0, 14)
    knob.Position = U2(0, 3, 0.5, -7)
    knob.BackgroundColor3 = C3(180,180,180)
    knob.BorderSizePixel = 0
    knob.ZIndex = row.ZIndex + 2
    N("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local state = defaultToggle or false
    local function SetState(val)
        state = val
        TweenService:Create(trackBg, TweenInfo.new(0.2), {BackgroundColor3 = state and State.ThemeColor or C3(50,50,55)}):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), {Position = state and U2(1, -17, 0.5, -7)
                or U2(0, 3, 0.5, -7), BackgroundColor3 = state and C3(255,255,255) or C3(180,180,180)}):Play()
        if toggleCallback then toggleCallback(state) end
    end
    SetState(state)

    local keyBtn = N("TextButton", row)
    keyBtn.Size = U2(0, 68, 0, 24)
    keyBtn.Position = U2(1, -80, 0.5, -12)
    keyBtn.Name = "ThemeKeyBtn"
    keyBtn.BackgroundColor3 = C3(30,30,35)
    keyBtn.Text = currentKey
    keyBtn.TextColor3 = State.ThemeColor
    keyBtn.Font = GFB
    keyBtn.TextSize = 11
    keyBtn.BorderSizePixel = 0
    keyBtn.ZIndex = row.ZIndex + 3
    N("UICorner", keyBtn).CornerRadius = UDim.new(0, 7)
    local toggleBtn = N("TextButton", row); toggleBtn.Size = U2(1, -88, 1, 0); toggleBtn.BackgroundTransparency = 1; toggleBtn.Text = ""; toggleBtn.ZIndex = row.ZIndex + 4
    toggleBtn.MouseButton1Click:Connect(function() SetState(not state); Notify(name, name .. ": " .. (state and "ON" or "OFF")) end)
    keyBtn.MouseButton1Click:Connect(function() listening = true; keyBtn.Text = "..."; keyBtn.TextColor3 = C3(255,200,0) end)

    table.insert(Connections, UIS.InputBegan:Connect(function(input, gpe)
        if listening and not gpe then
            listening = false; currentKey = input.KeyCode.Name; keyBtn.Text = currentKey; keyBtn.TextColor3 = State.ThemeColor
            if onKeyChanged then onKeyChanged(currentKey) end
        elseif not gpe and input.KeyCode == Enum.KeyCode[currentKey] then
            if keyCallback then keyCallback(true) end
        end
    end))
    if holdMode then
        table.insert(Connections, UIS.InputEnded:Connect(function(input, gpe)
            if not gpe and input.KeyCode == Enum.KeyCode[currentKey] then if keyCallback then keyCallback(false) end end
        end))
    end
    return { Set = SetState, Get = function() return state end, GetKey = function() return currentKey end }
end

local function AddColorPicker(page, name, defaultColor, callback)
    local row = MakeRow(page, 42); local currentColor = defaultColor
    local lbl = N("TextLabel", row)
    lbl.Size = U2(0.7, 0, 1, 0)
    lbl.Position = U2(0, 14, 0, 0)
    lbl.Text = name
    lbl.TextColor3 = C3(220,220,220)
    lbl.Font = GFM
    lbl.TextSize = 12
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = ETXA.Left
    lbl.ZIndex = row.ZIndex + 1
    local swatch = N("Frame", row)
    swatch.Size = U2(0, 30, 0, 24)
    swatch.Position = U2(1, -44, 0.5, -12)
    swatch.BackgroundColor3 = currentColor
    swatch.BorderSizePixel = 0
    swatch.ZIndex = row.ZIndex + 2
    N("UICorner", swatch).CornerRadius = UDim.new(0, 6)

    local colorPresets = { C3(255,255,255), C3(0,170,255), C3(255,0,0), C3(0,255,100), C3(255,200,0), C3(180,100,255) }
    local colorIdx = 1
    local btn = N("TextButton", row); btn.Size = U2(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = row.ZIndex + 3
    btn.MouseButton1Click:Connect(function() colorIdx = colorIdx % #colorPresets + 1
    currentColor = colorPresets[colorIdx]
    swatch.BackgroundColor3 = currentColor
    if callback then callback(currentColor) end end)
end

local TabInfo     = NewTab("Info")
local TabCombat   = NewTab("Combat")
local TabESP      = NewTab("ESP")
local TabPlayers  = NewTab("Players")
local TabMisc     = NewTab("Misc")
local TabSettings = NewTab("Settings")

Pages["Info"].page.Visible = true; Pages["Info"].btn.BackgroundTransparency = 0.78; Pages["Info"].btn.TextColor3 = State.ThemeColor; Pages["Info"].indicator.BackgroundTransparency = 0

local ExecutorName = identifyexecutor and identifyexecutor() or "Unknown"

local infoPlayerLabel = AddLabel(TabInfo, "Player: " .. LP.Name)
StaffLabel = AddLabel(TabInfo, "Staff in Server: None (Clean)")

UI.warnRow = MakeRow(TabInfo, 52)
UI.warnLbl = N("TextLabel", UI.warnRow)
UI.warnLbl.Size = U2(1, -20, 1, 0)
UI.warnLbl.Position = U2(0, 10, 0, 0)
UI.warnLbl.Text = "⚠ This script is undetected, however avoid using risky features while staff are in the server."
UI.warnLbl.TextColor3 = C3(255, 60, 60)
UI.warnLbl.Font = GFM
UI.warnLbl.TextSize = 11
UI.warnLbl.BackgroundTransparency = 1
UI.warnLbl.TextXAlignment = ETXA.Left
UI.warnLbl.TextWrapped = true
UI.warnLbl.ZIndex = UI.warnRow.ZIndex + 1
UI.warnStroke = N("UIStroke", UI.warnRow); UI.warnStroke.Color = C3(200, 40, 40); UI.warnStroke.Thickness = 1; UI.warnStroke.Transparency = 0.3

local SilentAimToggle = AddToggle(TabCombat, "Silent Aim", Config.SilentAim, function(v) SilentAimSettings.Active = v; UpdateUI(); Config.SilentAim = v; SaveConfig() end)
local PauseCtrlToggle = AddToggleKeybind(TabCombat, "Pause Silent Aim", Config.PauseWithCtrl, Config.SilentAimPauseKey or "LeftControl",
    function(v) SilentAimSettings.PauseWithCtrl = v; UpdateUI(); Config.PauseWithCtrl = v; SaveConfig() end,
    nil, false,
    function(k)
        SilentAimSettings.PauseKey = k
        SilentAimSettings.CtrlHeld = false
        Config.SilentAimPauseKey = k; SaveConfig(); UpdateUI()
    end
)
AddToggle(TabCombat, "Friendly Fire", false, function(v) SilentAimSettings.FriendlyFire = v end)
AddSlider(TabCombat, "Max Lock Distance", 10, 1000, Config.MaxLockDist, "Studs", function(v) SilentAimSettings.MaxLockDist = v; Config.MaxLockDist = v; SaveConfig() end)
AddToggle(TabCombat, "Ultra Auto Ictus (RISK)", Config.UltraIctus, function(v) State.UltraIctusRiskActive = v; Config.UltraIctus = v; SaveConfig() end)
AddToggle(TabCombat, "Auto Ictus", Config.NormalIctus, function(v) State.NormalIctusActive = v; Config.NormalIctus = v; SaveConfig() end)

AddToggle(TabESP, "Enable ESP", Config.ESPActive, function(v) ESPSettings.Active = v; Config.ESPActive = v; SaveConfig() end)
AddToggle(TabESP, "Show Cure Holders", Config.ShowCure, function(v) ESPSettings.ShowCure = v; Config.ShowCure = v; SaveConfig() end)
AddToggle(TabESP, "Show Wood Stake Holders", Config.ShowStake, function(v) ESPSettings.ShowStake = v; Config.ShowStake = v; SaveConfig() end)

local function IsInPlayerCharacter(obj) for _, p in pairs(Players:GetPlayers()) do if p.Character and obj:IsDescendantOf(p.Character) then return true end end; return false end
local function IsInPlayerBackpack(obj) for _, p in pairs(Players:GetPlayers()) do local bp = p:FindFirstChild("Backpack"); if bp and obj:IsDescendantOf(bp) then return true end end; return false end
local function IsGroundStake(obj) return not IsInPlayerCharacter(obj) and not IsInPlayerBackpack(obj) end
local function CreateWhiteOakTag(obj)
    if obj:FindFirstChild("WhiteOak_Tag") then return end
    local billboard = N("BillboardGui")
    billboard.Name = "WhiteOak_Tag"
    billboard.AlwaysOnTop = true
    billboard.Size = U2(0, 150, 0, 40)
    billboard.Adornee = obj
    billboard.MaxDistance = 2000
    local label = N("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = U2(1, 0, 1, 0)
    label.Text = "White Oak Stake"
    label.TextColor3 = C3(0, 255, 255)
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = C3(0,0,0)
    label.TextSize = 17
    label.Font = Enum.Font.Antique
    label.Parent = billboard
    billboard.Parent = obj
end
local function ClearAllWhiteOakTags() for _, obj in pairs(workspace:GetDescendants()) do if obj.Name == "WhiteOak_Tag" then pcall(function() obj:Destroy() end) end end end
local function IsStakeName(name) return name == "White Oak Stake" or name == "WoodenStake" or (name:find("White") and name:find("Oak") and name:find("Stake")) end

AddToggle(TabESP, "White Oak Stake ESP", false, function(v)
    State.WhiteOak_Active = v
    if v then
        State.WhiteOak_Loop = task.spawn(function()
            while State.WhiteOak_Active and not State.Unloaded do
                local descendants = workspace:GetDescendants()
                local batchSize = 80
                for i = 1, #descendants, batchSize do
                    if not State.WhiteOak_Active then break end
                    for j = i, math.min(i + batchSize - 1, #descendants) do
                        local obj = descendants[j]
                        if obj and obj.Parent then
                            if obj.Name == "WhiteOak_Tag" then
                                local adornee = obj:IsA("BillboardGui") and obj.Adornee or nil
                                if not adornee or not adornee.Parent or not IsGroundStake(adornee) then pcall(function() obj:Destroy() end) end
                            elseif IsStakeName(obj.Name) then
                                if (obj:IsA("BasePart") or obj:IsA("Tool") or obj:IsA("Model")) and IsGroundStake(obj) then
                                    local part = obj:IsA("BasePart") and obj or (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart"))
                                    if part then CreateWhiteOakTag(part) end
                                end
                            end
                        end
                    end
                    task.wait()
                end
                task.wait(3)
            end
        end)
    else ClearAllWhiteOakTags() end
end)
AddSlider(TabESP, "Name Text Size", 10, 30, 16, "px", function(v) ESPSettings.TextSize = v end)
AddSlider(TabESP, "Screen Brightness", -1, 100, -1, "%", function(v) State.CustomBrightness = v end)
AddSlider(TabESP, "FOV Changer", 70, 120, 70, "FOV", function(v) State.CustomFOV = v end)
AddColorPicker(TabESP, "Default ESP Color", ESPSettings.DefaultColor, function(v) ESPSettings.DefaultColor = v; Config.ESPDefaultColor = Color3ToRGB(v); SaveConfig() end)
AddColorPicker(TabESP, "Whitelist/Friend ESP Color", ESPSettings.FriendColor, function(v) ESPSettings.FriendColor = v; Config.ESPFriendColor = Color3ToRGB(v); SaveConfig() end)
AddColorPicker(TabESP, "Enemy ESP Color", ESPSettings.EnemyColor, function(v) ESPSettings.EnemyColor = v; Config.ESPEnemyColor = Color3ToRGB(v); SaveConfig() end)

local charHierarchy = { ["Hope Mikaelson"] = 6, ["Silas"] = 5, ["Esther"] = 4, ["Marcel"] = 3, ["Mikael"] = 2, ["Klaus"] = 1 }
local function HasItemLocal(player, itemName) local char = player.Character
local backpack = player:FindFirstChild("Backpack")
return (backpack and backpack:FindFirstChild(itemName)) or (char and char:FindFirstChild(itemName)) end

UI.ActionPanel = N("Frame", UI.TVL2)
UI.ActionPanel.Size = U2(0, 130, 0, 112)
UI.ActionPanel.BackgroundColor3 = C3(18, 18, 22)
UI.ActionPanel.BorderSizePixel = 0
UI.ActionPanel.Visible = false
UI.ActionPanel.ZIndex = 60
N("UICorner", UI.ActionPanel).CornerRadius = UDim.new(0, 10)
UI.apStroke = N("UIStroke", UI.ActionPanel); UI.apStroke.Color = State.ThemeColor; UI.apStroke.Thickness = 1; UI.apStroke.Transparency = 0.4; _ActionPanelRef[1] = UI.ActionPanel
UI.apLayout = N("UIListLayout", UI.ActionPanel); UI.apLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; UI.apLayout.Padding = UDim.new(0, 5)
UI.apPad = N("UIPadding", UI.ActionPanel); UI.apPad.PaddingTop = UDim.new(0, 7); UI.apPad.PaddingBottom = UDim.new(0, 7)

local function MakeAPButton(text, color, callback)
    local b = N("TextButton", UI.ActionPanel)
    b.Size = U2(0.9, 0, 0, 26)
    b.BackgroundColor3 = color
    b.BackgroundTransparency = 0.6
    b.Text = text
    b.TextColor3 = C3(255, 255, 255)
    b.Font = GFB
    b.TextSize = 12
    b.BorderSizePixel = 0
    b.ZIndex = 61
    b.AutoButtonColor = false
    N("UICorner", b).CornerRadius = UDim.new(0, 7)
    b.MouseButton1Click:Connect(function() UI.ActionPanel.Visible = false; if callback then callback() end end)
end

local RefreshPlayerDatabase

MakeAPButton("Friend", C3(0, 120, 200), function()
    if State.ManageSelectedPlayer then WhitelistCache[State.ManageSelectedPlayer.Name] = true
    EnemyCache[State.ManageSelectedPlayer.Name] = nil
    SaveConfig()
    pcall(RefreshPlayerDatabase)
    Notify("Status Updated", State.ManageSelectedPlayer.Name .. " is now a Friend.") end
end)
MakeAPButton("Enemy", C3(200, 40, 40), function()
    if State.ManageSelectedPlayer then EnemyCache[State.ManageSelectedPlayer.Name] = true
    WhitelistCache[State.ManageSelectedPlayer.Name] = nil
    SaveConfig()
    pcall(RefreshPlayerDatabase)
    Notify("Status Updated", State.ManageSelectedPlayer.Name .. " is now an Enemy.") end
end)
MakeAPButton("Neutral", C3(100, 100, 100), function()
    if State.ManageSelectedPlayer then EnemyCache[State.ManageSelectedPlayer.Name] = nil
    WhitelistCache[State.ManageSelectedPlayer.Name] = nil
    SaveConfig()
    pcall(RefreshPlayerDatabase)
    Notify("Status Updated", State.ManageSelectedPlayer.Name .. " is now Neutral.") end
end)

UIS.InputBegan:Connect(function(input, gpe) if input.UserInputType == Enum.UserInputType.MouseButton1 then if UI.ActionPanel.Visible then task.wait(0.05) end end end)

local function GetStatusColor(p)
    if WhitelistCache[p.Name] or FriendCache[p] then return C3(0, 170, 255)
    elseif EnemyCache[p.Name] then return C3(220, 60, 60)
    end
    return C3(220, 220, 220) end
local function GetStatusTag(p) if WhitelistCache[p.Name] or FriendCache[p] then return " [F]" elseif EnemyCache[p.Name] then return " [E]" end return "" end

UI.searchInput = AddInput(TabPlayers, "Search Player", "Search name...", function(text) State.PlayerSearchFilter = string.lower(text); RefreshPlayerDatabase() end)

local function BuildPlayerRow(p)
    if State.PlayerRows[p] then State.PlayerRows[p]:Destroy() end
    local cName = p:GetAttribute("CharacterName") or "Unassigned"; local items = {}
    if HasItemLocal(p, "TheCure") or HasItemLocal(p, "QetsiyahCure") then table.insert(items, "Cure") end
    if HasItemLocal(p, "WoodenStake") then table.insert(items, "Stake") end
    local itemStr = #items > 0 and (" | " .. table.concat(items, ", ")) or ""
    local displayText = p.Name .. " (" .. cName .. ")" .. itemStr .. GetStatusTag(p)
    if State.PlayerSearchFilter ~= "" and not string.find(string.lower(displayText), State.PlayerSearchFilter) then return end

    local row = MakeRow(TabPlayers, 40); row.ZIndex = 5
    local nameLbl = N("TextLabel", row)
    nameLbl.Size = U2(1, -16, 1, 0)
    nameLbl.Position = U2(0, 10, 0, 0)
    nameLbl.Text = displayText
    nameLbl.TextColor3 = GetStatusColor(p)
    nameLbl.Font = GFM
    nameLbl.TextSize = 12
    nameLbl.BackgroundTransparency = 1
    nameLbl.TextXAlignment = ETXA.Left
    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
    nameLbl.ZIndex = row.ZIndex + 1
    local btn = N("TextButton", row); btn.Size = U2(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = row.ZIndex + 2
    btn.MouseButton1Click:Connect(function()
        if State.ManageSelectedPlayer and State.PlayerRows[State.ManageSelectedPlayer] then
            TweenService:Create(State.PlayerRows[State.ManageSelectedPlayer], TweenInfo.new(0.15), {BackgroundColor3 = C3(255,255,255), BackgroundTransparency = 0.93}):Play()
        end
        State.ManageSelectedPlayer = p
        TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = State.ThemeColor, BackgroundTransparency = 0.75}):Play()
        local py = row.AbsolutePosition.Y; local px = UI.Main.AbsolutePosition.X + UI.Main.AbsoluteSize.X - 130 - 8
        if py + 112 > UI.Main.AbsolutePosition.Y + UI.Main.AbsoluteSize.Y - 4 then py = UI.Main.AbsolutePosition.Y + UI.Main.AbsoluteSize.Y - 112 - 4 end
        if py < UI.Main.AbsolutePosition.Y + 4 then py = UI.Main.AbsolutePosition.Y + 4 end
        UI.ActionPanel.Position = U2(0, px, 0, py); UI.ActionPanel.Visible = true
    end)
    State.PlayerRows[p] = row
end

RefreshPlayerDatabase = function()
    for p, row in pairs(State.PlayerRows) do if row and row.Parent then row:Destroy() end end; State.PlayerRows = {}
    local sortedPlayers = {}
    for _, p in pairs(Players:GetPlayers()) do if p ~= LP then table.insert(sortedPlayers, p) end end
    table.sort(sortedPlayers, function(a, b)
        local function Score(p)
            local s = 0; if HasItemLocal(p, "TheCure") or HasItemLocal(p, "QetsiyahCure") then s = s + 1000000 end
            local cName = p:GetAttribute("CharacterName") or ""; if charHierarchy[cName] then s = s + (charHierarchy[cName] * 10000) end
            if HasItemLocal(p, "WoodenStake") then s = s + 1000 end; return s
        end
        local aS, bS = Score(a), Score(b); return aS == bS and a.Name:lower() < b.Name:lower() or aS > bS
    end)
    for _, p in ipairs(sortedPlayers) do BuildPlayerRow(p) end
    if State.ManageSelectedPlayer and State.PlayerRows[State.ManageSelectedPlayer] then
        TweenService:Create(State.PlayerRows[State.ManageSelectedPlayer], TweenInfo.new(0.15), {BackgroundColor3 = State.ThemeColor, BackgroundTransparency = 0.75}):Play()
    end
end

task.spawn(function() while not State.Unloaded do task.wait(1); pcall(RefreshPlayerDatabase) end end)
table.insert(Connections, Players.PlayerAdded:Connect(function(p) task.wait(0.5); pcall(RefreshPlayerDatabase) end))
table.insert(Connections, Players.PlayerRemoving:Connect(function(p) if State.PlayerRows[p] then State.PlayerRows[p]:Destroy()
State.PlayerRows[p] = nil end
if State.ManageSelectedPlayer == p then State.ManageSelectedPlayer = nil
UI.ActionPanel.Visible = false end end))
pcall(RefreshPlayerDatabase)

AddToggle(TabMisc, "Anti Fling", false, function(v) _G.AntiFling = v end)
AddToggle(TabMisc, "Auto Compel", false, function(v) State.CompelActive = v end)

local WASD_State = { [Enum.KeyCode.W] = false, [Enum.KeyCode.A] = false, [Enum.KeyCode.S] = false, [Enum.KeyCode.D] = false }
UIS.InputBegan:Connect(function(input, gpe) if WASD_State[input.KeyCode] ~= nil then WASD_State[input.KeyCode] = true end end)
UIS.InputEnded:Connect(function(input, gpe) if WASD_State[input.KeyCode] ~= nil then WASD_State[input.KeyCode] = false end end)
local function isMoving() return WASD_State[Enum.KeyCode.W] or WASD_State[Enum.KeyCode.A] or WASD_State[Enum.KeyCode.S] or WASD_State[Enum.KeyCode.D] end
local escapeConn

AddToggleKeybind(TabMisc, "Stun Bypass", Config.StunBypass, Config.StunBypassKey,
    function(v) State.StunBypassEnabled = v; Config.StunBypass = v; SaveConfig(); if not v then if State.Escaping and escapeConn then escapeConn:Disconnect() end; State.Escaping = false end end,
    function(began)
        if not State.StunBypassEnabled then return end
        if began then
            State.Escaping = true
            local PlayerModule = require(LP.PlayerScripts:WaitForChild("PlayerModule"))
            local Controls = PlayerModule:GetControls()
            escapeConn = RunService.Heartbeat:Connect(function()
                local char = LP.Character
                local hum = char and char:FindFirstChild("Humanoid")
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if hum and root and State.Escaping then
                    if not Controls.enabled then Controls:Enable() end
                    if not isMoving() then hum.WalkToPoint = root.Position else hum.WalkToPoint = Vector3.new(0, 0, 0) end
                end
            end)
        else State.Escaping = false; if escapeConn then escapeConn:Disconnect() end end
    end, true, function(k) Config.StunBypassKey = k; SaveConfig() end
)

AddKeybind(TabMisc, "F Bar Bypass", Config.FBarBypassKey or "F5", function()
    if not SiphonRemote then return end
    if SiphonRemote:IsA("RemoteEvent") then SiphonRemote:FireServer() elseif SiphonRemote:IsA("RemoteFunction") then SiphonRemote:InvokeServer() end
end)

AddKeybind(TabMisc, "Bypass Carry", Config.BypassCarryKey or "CapsLock", function()
    local carryRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CarryService"):WaitForChild("EscapedCarry")
    local carrier = nil
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local myChar = LP.Character
            if myChar and myChar.PrimaryPart then
                local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                local theirRoot = p.Character:FindFirstChild("HumanoidRootPart")
                if myRoot and theirRoot then if (myRoot.Position - theirRoot.Position).Magnitude < 5 then carrier = p; break end end
            end
        end
    end
    if carrier then if carryRemote:IsA("RemoteEvent") then carryRemote:FireServer(carrier) end else if carryRemote:IsA("RemoteEvent") then carryRemote:FireServer(LP) end end
end)

local COLA_PRICE = 5
UI.colaRow = MakeRow(TabMisc, 80)
UI.colaLbl = N("TextLabel", UI.colaRow)
UI.colaLbl.Size = U2(0.55, 0, 0, 20)
UI.colaLbl.Position = U2(0, 14, 0, 5)
UI.colaLbl.Text = "Auto Buy Cola"
UI.colaLbl.TextColor3 = C3(230,230,230)
UI.colaLbl.Font = GFM
UI.colaLbl.TextSize = 12
UI.colaLbl.BackgroundTransparency = 1
UI.colaLbl.TextXAlignment = ETXA.Left
UI.colaLbl.ZIndex = UI.colaRow.ZIndex + 1
UI.colaCoinLbl = N("TextLabel", UI.colaRow)
UI.colaCoinLbl.Size = U2(0.42, 0, 0, 20)
UI.colaCoinLbl.Position = U2(0.56, 0, 0, 5)
UI.colaCoinLbl.Text = "Cost: " .. (State.autoBuyColaCount * COLA_PRICE) .. " coins (" .. COLA_PRICE .. "¢ each)"
UI.colaCoinLbl.TextColor3 = C3(255, 200, 50)
UI.colaCoinLbl.Font = GFM
UI.colaCoinLbl.TextSize = 11
UI.colaCoinLbl.BackgroundTransparency = 1
UI.colaCoinLbl.TextXAlignment = ETXA.Right
UI.colaCoinLbl.ZIndex = UI.colaRow.ZIndex + 1
UI.colaValLbl = N("TextLabel", UI.colaRow)
UI.colaValLbl.Name = "ThemeValLbl"
UI.colaValLbl.Size = U2(0.25, 0, 0, 22)
UI.colaValLbl.Position = U2(0.36, 0, 0, 29)
UI.colaValLbl.Text = "x1"
UI.colaValLbl.TextColor3 = State.ThemeColor
UI.colaValLbl.Font = GFB
UI.colaValLbl.TextSize = 13
UI.colaValLbl.BackgroundTransparency = 1
UI.colaValLbl.TextXAlignment = ETXA.Center
UI.colaValLbl.ZIndex = UI.colaRow.ZIndex + 1

local function UpdateColaDisplay() UI.colaValLbl.Text = "x" .. State.autoBuyColaCount
UI.colaCoinLbl.Text = "Cost: " .. (State.autoBuyColaCount * COLA_PRICE) .. " coins (" .. COLA_PRICE .. "c each)" end

UI.colaMinus = N("TextButton", UI.colaRow)
UI.colaMinus.Size = U2(0, 26, 0, 26)
UI.colaMinus.Position = U2(0, 14, 0, 30)
UI.colaMinus.BackgroundColor3 = C3(50,50,55)
UI.colaMinus.Text = "-"
UI.colaMinus.TextColor3 = C3(255,255,255)
UI.colaMinus.Font = GFB
UI.colaMinus.TextSize = 16
UI.colaMinus.BorderSizePixel = 0
UI.colaMinus.ZIndex = UI.colaRow.ZIndex + 2
N("UICorner", UI.colaMinus).CornerRadius = UDim.new(0, 7)
UI.colaMinus.MouseButton1Click:Connect(function() State.autoBuyColaCount = math.max(1, State.autoBuyColaCount - 1); UpdateColaDisplay() end)
UI.colaPlus = N("TextButton", UI.colaRow)
UI.colaPlus.Size = U2(0, 26, 0, 26)
UI.colaPlus.Position = U2(0, 44, 0, 30)
UI.colaPlus.BackgroundColor3 = C3(50,50,55)
UI.colaPlus.Text = "+"
UI.colaPlus.TextColor3 = C3(255,255,255)
UI.colaPlus.Font = GFB
UI.colaPlus.TextSize = 16
UI.colaPlus.BorderSizePixel = 0
UI.colaPlus.ZIndex = UI.colaRow.ZIndex + 2
N("UICorner", UI.colaPlus).CornerRadius = UDim.new(0, 7)
UI.colaPlus.MouseButton1Click:Connect(function() State.autoBuyColaCount = State.autoBuyColaCount + 1; UpdateColaDisplay() end)

UI.colaInputBox = N("TextBox", UI.colaRow)
UI.colaInputBox.Size = U2(0, 52, 0, 22)
UI.colaInputBox.Position = U2(0, 74, 0, 33)
UI.colaInputBox.BackgroundColor3 = C3(30,30,35)
UI.colaInputBox.BackgroundTransparency = 0.2
UI.colaInputBox.TextColor3 = C3(240,240,240)
UI.colaInputBox.PlaceholderText = "Qty"
UI.colaInputBox.PlaceholderColor3 = C3(100,100,100)
UI.colaInputBox.Font = GFB
UI.colaInputBox.TextSize = 12
UI.colaInputBox.Text = ""
UI.colaInputBox.BorderSizePixel = 0
UI.colaInputBox.ZIndex = UI.colaRow.ZIndex + 3
UI.colaInputBox.ClearTextOnFocus = true
N("UICorner", UI.colaInputBox).CornerRadius = UDim.new(0, 6)
UI.colaInputBox.FocusLost:Connect(function() local num = tonumber(UI.colaInputBox.Text)
if num and num >= 1 then State.autoBuyColaCount = math.floor(num)
UpdateColaDisplay() end
UI.colaInputBox.Text = "" end)

UI.colaConfirm = N("TextButton", UI.colaRow)
UI.colaConfirm.Size = U2(0, 80, 0, 26)
UI.colaConfirm.Position = U2(1, -94, 0, 27)
UI.colaConfirm.BackgroundColor3 = State.ThemeColor
UI.colaConfirm.Text = "Confirm"
UI.colaConfirm.TextColor3 = C3(255,255,255)
UI.colaConfirm.Font = GFB
UI.colaConfirm.TextSize = 12
UI.colaConfirm.BorderSizePixel = 0
UI.colaConfirm.ZIndex = UI.colaRow.ZIndex + 2
N("UICorner", UI.colaConfirm).CornerRadius = UDim.new(0, 7)
UI.colaConfirm.MouseButton1Click:Connect(function()
    local count = State.autoBuyColaCount; Notify("Auto Buy Cola", "Buying " .. count .. " Cola(s)...")
    task.spawn(function()
        local npcFolder = workspace:FindFirstChild("NonPlayerCharacters"); local npc = npcFolder and npcFolder:FindFirstChild("MysticGrillWaitressNicholeCane")
        if not npc then Notify("Auto Buy Cola", "NPC not found in this server!"); return end
        local hrp = npc:FindFirstChild("HumanoidRootPart")
        if not hrp then Notify("Auto Buy Cola", "NPC not ready, try again!"); return end
        for i = 1, count do
            if State.Unloaded then break end
            pcall(function() ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("NPCService"):WaitForChild("ToServer"):WaitForChild("ReturnResponse_"):InvokeServer(hrp, "BuyColaServer") end)
            task.wait(1/3)
        end
        Notify("Auto Buy Cola", "Done! Bought " .. count .. " Cola(s).")
    end)
end)

AddToggle(TabSettings, "Hide Profile", false, function(v) State.HideProfile_Enabled = v
UI.ProfileCard.Visible = not v
if infoPlayerLabel and infoPlayerLabel.Row then infoPlayerLabel.Row.Visible = not v end end)
AddSlider(TabSettings, "GUI Width", 600, 960, 791, "px", function(v) UI.Main.Size = U2(0, v, 0, UI.Main.AbsoluteSize.Y)
UI.Main.Position = U2(0.5, -v/2, 0.5, -UI.Main.AbsoluteSize.Y/2) end)
AddSlider(TabSettings, "GUI Height", 380, 620, 531, "px", function(v) UI.Main.Size = U2(0, UI.Main.AbsoluteSize.X, 0, v)
UI.Main.Position = U2(0.5, -UI.Main.AbsoluteSize.X/2, 0.5, -v/2) end)

UI.guiKeyRow = MakeRow(TabSettings, 42)
UI.guiKeyLbl = N("TextLabel", UI.guiKeyRow)
UI.guiKeyLbl.Size = U2(0.6, 0, 1, 0)
UI.guiKeyLbl.Position = U2(0, 14, 0, 0)
UI.guiKeyLbl.Text = "GUI Toggle Key"
UI.guiKeyLbl.TextColor3 = C3(220,220,220)
UI.guiKeyLbl.Font = GFM
UI.guiKeyLbl.TextSize = 13
UI.guiKeyLbl.BackgroundTransparency = 1
UI.guiKeyLbl.TextXAlignment = ETXA.Left
UI.guiKeyLbl.ZIndex = UI.guiKeyRow.ZIndex + 1
UI.guiKeyBtn = N("TextButton", UI.guiKeyRow)
UI.guiKeyBtn.Size = U2(0, 80, 0, 26)
UI.guiKeyBtn.Position = U2(1, -92, 0.5, -13)
UI.guiKeyBtn.BackgroundColor3 = C3(30,30,35)
UI.guiKeyBtn.Text = State.GUI_ToggleKey
UI.guiKeyBtn.TextColor3 = State.ThemeColor
UI.guiKeyBtn.Font = GFB
UI.guiKeyBtn.TextSize = 12
UI.guiKeyBtn.BorderSizePixel = 0
UI.guiKeyBtn.ZIndex = UI.guiKeyRow.ZIndex + 2
N("UICorner", UI.guiKeyBtn).CornerRadius = UDim.new(0, 7)
UI.guiKeyBtn.MouseButton1Click:Connect(function() State.GUI_ListeningForKey = true; UI.guiKeyBtn.Text = "..."; UI.guiKeyBtn.TextColor3 = C3(255,200,0) end)
table.insert(Connections, UIS.InputBegan:Connect(function(input, gpe)
    if State.GUI_ListeningForKey and not gpe then State.GUI_ListeningForKey = false
    State.GUI_ToggleKey = input.KeyCode.Name
    UI.guiKeyBtn.Text = State.GUI_ToggleKey
    UI.guiKeyBtn.TextColor3 = State.ThemeColor end
end))

AddSlider(TabSettings, "FPS Cap", 0, 1000, 0, "fps", function(v)
    if v == 0 then if settings then pcall(function() settings().Rendering.FrameRateManager = 0 end) end
    pcall(function() setfpscap(0) end) else pcall(function() setfpscap(v) end)
    if settings then pcall(function() settings().Rendering.FrameRateManager = v end) end end
end)

AddColorPicker(TabSettings, "GUI Accent Color", State.ThemeColor, function(v)
    State.ThemeColor = v; Config.GUIAccentColor = Color3ToRGB(v); SaveConfig()
    UI.mainStroke.Color = v; UI.T1.TextColor3 = v; UI.Div.BackgroundColor3 = v; UI.guiKeyBtn.TextColor3 = v; UI.apStroke.Color = v
    for tname, t in pairs(Pages) do
        t.page.ScrollBarImageColor3 = v; t.indicator.BackgroundColor3 = v
        if tname == CurrentTab then t.btn.TextColor3 = v end
    end
    for _, obj in pairs(UI.TVL2:GetDescendants()) do
        pcall(function()
            local n = obj.Name
            if obj:IsA("UIStroke") then obj.Color = v
            elseif n == "ThemeFill" then obj.BackgroundColor3 = v
            elseif n == "ThemeValLbl" then obj.TextColor3 = v
            elseif n == "ThemeToggleBg" then if obj.BackgroundColor3 ~= C3(50,50,55) then obj.BackgroundColor3 = v end
            elseif n == "ThemeSelLbl" or n == "ThemeArrow" then obj.TextColor3 = v
            elseif n == "ThemeKeyBtn" then if obj.Text ~= "..." then obj.TextColor3 = v end
            elseif n == "ThemeBtnLbl" then obj.TextColor3 = v end
        end)
    end
end)

AddButton(TabSettings, "Rejoin Server", function() if #Players:GetPlayers() <= 1 then LP:Kick("\nRejoining...")
task.wait()
TeleportService:Teleport(game.PlaceId, LP) else TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP) end end)

AddButton(TabSettings, "Delete Script", function()
    State.Unloaded = true; _G.AntiFling = false; State.WhiteOak_Active = false; ClearAllWhiteOakTags()
    State.CustomBrightness = -1; Camera.FieldOfView = 70
    for _, conn in ipairs(Connections) do if conn then pcall(function() conn:Disconnect() end) end end
    Connections = {}
    for _, p in pairs(Players:GetPlayers()) do RemoveESP(p) end; ClearExpander()
    if IndicatorGui then pcall(function() IndicatorGui:Destroy() end) end
    if UI.ActionPanel then pcall(function() UI.ActionPanel:Destroy() end) end
    pcall(function() UI.TVL2:Destroy() end)
    _G.AntiFling = nil
end)

local dragging, dragInput, dragStart, startPos
UI.Main.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and UIS:GetFocusedTextBox() == nil then
        dragging = true; dragStart = input.Position; startPos = UI.Main.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
UI.Main.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
UIS.InputChanged:Connect(function(input) if input == dragInput and dragging then local delta = input.Position - dragStart
UI.Main.Position = U2(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)

table.insert(Connections, UIS.InputBegan:Connect(function(k, gp)
    if gp or State.GUI_ListeningForKey then return end
    local ok, keyEnum = pcall(function() return Enum.KeyCode[State.GUI_ToggleKey] end)
    if ok and k.KeyCode == keyEnum then UI.Main.Visible = not UI.Main.Visible end
end))

local function UpdateStaffLabel()
    local count = 0; local txt = "Staff in Server:\n"
    for name, role in pairs(State.StaffInServer) do count = count + 1; txt = txt .. name .. " (" .. role .. ")\n" end
    if count == 0 then StaffLabel.Set("Staff in Server: None (Clean)") else StaffLabel.Set(txt) end
end
local function SendAdminAlert(playerName, roleName) Notify("WARNING: STAFF DETECTED!", playerName .. " is in the game! Rank: " .. roleName) end
local function CheckPlayerForAdmin(player)
    pcall(function()
        local rankID = player:GetRankInGroup(State.GroupID)
        if rankID >= State.MinDangerRank then
            local roleName = player:GetRoleInGroup(State.GroupID); State.StaffInServer[player.Name] = roleName; UpdateStaffLabel(); SendAdminAlert(player.Name, roleName)
        end
    end)
end
for _, player in pairs(Players:GetPlayers()) do if player ~= LP then CheckPlayerForAdmin(player) end end
table.insert(Connections, Players.PlayerAdded:Connect(function(player) CheckPlayerForAdmin(player) end))
table.insert(Connections, Players.PlayerRemoving:Connect(function(player) if State.StaffInServer[player.Name] then State.StaffInServer[player.Name] = nil; UpdateStaffLabel() end end))

PlayNotifySound(); Notify("TVL2 Hub", "Successfully loaded, have fun!")