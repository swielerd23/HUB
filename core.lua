local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Camera = workspace.CurrentCamera
local Mouse = LP:GetMouse()

local WHITELIST_URL = "https://gist.githubusercontent.com/broskikroski/5d76122b8e8001b831aa030a24b7ef57/raw/lua?nocache=" .. tostring(os.time())
local WHITELIST = {}

local ok, result = pcall(function() return game:HttpGet(WHITELIST_URL) end)
if ok and result then
    for line in result:gmatch("[^\n\r]+") do
        local id = tonumber(line:match("^%s*(.-)%s*$"))
        if id then WHITELIST[id] = true end
    end
    if not next(WHITELIST) then
        pcall(function()
            local parsed = game:GetService("HttpService"):JSONDecode(result)
            if type(parsed) == "table" then
                local list = (type(parsed[1]) == "number") and parsed or (parsed.whitelist or parsed.ids or parsed.users)
                if list then for _, id in ipairs(list) do WHITELIST[id] = true end end
            end
        end)
    end
end

if not WHITELIST[LP.UserId] then
    LP:Kick("\n[TVL2 Hub] You are not whitelisted to use this script.")
    return
end

local N=Instance.new
local C3=Color3.fromRGB
local U2=UDim2.new
local GFB=Enum.Font.GothamBold
local GFM=Enum.Font.GothamMedium
local GF=Enum.Font.Gotham
local ETXA=Enum.TextXAlignment
local CONFIG_PATH = "TVL2_config.json"
local HttpService = game:GetService("HttpService")

local DefaultConfig = {
    SilentAim = false, PauseWithCtrl = false, UltraIctus = false, NormalIctus = false,
    ESPActive = false, ShowCure = false, ShowStake = false, WhiteOakESP = false,
    AntiFling = false, AutoCompel = false, StunBypass = false,
    ExtraSpeedEnabled = false, FlyEnabled = false, VoidEnabled = false,
    MaxLockDist = 120, ESPTextSize = 16, ScreenBrightness = -1, FOVChanger = 70,
    FreeCamSpeed = 50, ExtraSpeed = 30,
    GUIToggleKey = "Home", StunBypassKey = "Q", FBarBypassKey = "F5", BypassCarryKey = "CapsLock",
    FreeCamKey = "F1", FreeCamTPKey = "F2",
    FlyKey = "F", FlyModeKey = "Toggle", VoidKey = "G",
    SilentAimPauseKey = "LeftControl",
    FriendList = {}, EnemyList = {},
    ESPDefaultColor = {255,255,255}, ESPFriendColor = {0,170,255}, ESPEnemyColor = {255,0,0},
    GUIAccentColor = {180,100,255},
}

local Config = {}

local function LoadConfig()
    local ok, data = pcall(function()
        if not isfile(CONFIG_PATH) then return nil end
        return readfile(CONFIG_PATH)
    end)
    if ok and data and data ~= "" then
        pcall(function() Config = HttpService:JSONDecode(data) end)
        for k, v in pairs(DefaultConfig) do
            if Config[k] == nil then Config[k] = v end
        end
    else
        Config = {}
        for k, v in pairs(DefaultConfig) do Config[k] = v end
    end
end

local ESPCache = {}
local FriendCache = {}
local WhitelistCache = {}
local EnemyCache = {}

local function SaveConfig()
    pcall(function()
        local friends, enemies = {}, {}
        for name, _ in pairs(WhitelistCache) do table.insert(friends, name) end
        for name, _ in pairs(EnemyCache) do table.insert(enemies, name) end
        Config.FriendList = friends
        Config.EnemyList = enemies
        writefile(CONFIG_PATH, HttpService:JSONEncode(Config))
    end)
end

LoadConfig()

local function ApplyPlayerListsFromConfig()
    for _, name in ipairs(Config.FriendList or {}) do WhitelistCache[name] = true end
    for _, name in ipairs(Config.EnemyList or {}) do EnemyCache[name] = true end
end
ApplyPlayerListsFromConfig()

local State = {
    Unloaded = false,
    BypassActive = true,
    CompelActive = false,
    UltraIctusRiskActive = Config.UltraIctus,
    NormalIctusActive = Config.NormalIctus,
    NormalIctusTracking = false,
    IgnoredSkills = {"blood heal", "blood", "heal"},
    CustomFOV = 70,
    CustomBrightness = -1,

    GroupID = 6723824, MinDangerRank = 6, StaffInServer = {},
    GUI_ToggleKey = Config.GUIToggleKey or "Home", GUI_ListeningForKey = false,
    ThemeColor = Config.GUIAccentColor and C3(Config.GUIAccentColor[1], Config.GUIAccentColor[2], Config.GUIAccentColor[3]) or C3(180, 100, 255),

    WhiteOak_Active = false, WhiteOak_Loop = nil,
    PlayerSearchFilter = "", ManageSelectedPlayer = nil, PlayerRows = {},
    StunBypassEnabled = Config.StunBypass, Escaping = false,
    autoBuyColaCount = 1,
    HideProfile_Enabled = false,
}

local Connections = {}

task.spawn(function()
    pcall(function()
        local PlayerModule = LP:WaitForChild("PlayerScripts", 10):WaitForChild("PlayerModule", 10)
        if not PlayerModule then return end

        local PopperModule = PlayerModule:WaitForChild("CameraModule", 10)
            :WaitForChild("ZoomController", 10)
            :WaitForChild("Popper", 10)
        if not PopperModule then return end

        local Popper = require(PopperModule)
        if not Popper then return end

        for k, v in pairs(Popper) do
            if type(v) == "function" then
                Popper[k] = function(...)
                    local args = {...}
                    for _, arg in ipairs(args) do
                        if arg == nil then return end
                    end
                    local ok, r1, r2 = pcall(v, ...)
                    if ok then return r1, r2 end
                end
            end
        end
    end)

    pcall(function()
        local PlayerModule = LP:WaitForChild("PlayerScripts", 10):WaitForChild("PlayerModule", 10)
        if not PlayerModule then return end
        local ZCModule = PlayerModule:WaitForChild("CameraModule", 10):WaitForChild("ZoomController", 10)
        if not ZCModule then return end
        local ZC = require(ZCModule)
        if ZC and type(ZC.Update) == "function" then
            local origUpdate = ZC.Update
            ZC.Update = function(...)
                local ok, r = pcall(origUpdate, ...)
                if ok then return r end
            end
        end
    end)
end)
local AbilityActivated, BeginAbility, SiphonRemote, AbilitySelected
pcall(function()
    local ToServer = ReplicatedStorage:WaitForChild("Remotes", 10)
        :WaitForChild("AbilityService", 10)
        :WaitForChild("ToServer", 10)
    if not ToServer then return end
    AbilityActivated = ToServer:WaitForChild("AbilityActivated____", 10)
    BeginAbility     = ToServer:WaitForChild("BeginAbility", 10)
    SiphonRemote     = ToServer:WaitForChild("SiphonEscape", 10)
    AbilitySelected  = ToServer:WaitForChild("AbilitySelected", 10)
end)

_G.AntiFling = Config.AntiFling or false

local SilentAimSettings = {
    Active = Config.SilentAim, PauseWithCtrl = Config.PauseWithCtrl, Target = nil,
    FOV = 800, MaxLockDist = Config.MaxLockDist, SleepDist = 500, Predict = 0.12, FrontOffset = 3,
    IgnoredUserIds = {[10166700114] = true}, CtrlHeld = false,
    PauseKey = Config.SilentAimPauseKey or "LeftControl",
    FriendlyFire = false  -- When true, friends are included as valid targets
}

local fakeHitbox = nil

local targetGuiParent = pcall(function() return CoreGui.Name end) and CoreGui or LP:WaitForChild("PlayerGui")
if targetGuiParent:FindFirstChild("TVL2Indicator") then targetGuiParent.TVL2Indicator:Destroy() end

local IndicatorGui = N("ScreenGui", targetGuiParent)
IndicatorGui.Name = "TVL2Indicator"
local StatusLabel = N("TextLabel", IndicatorGui)
StatusLabel.Size = U2(0, 180, 0, 30); StatusLabel.Position = U2(1, -20, 1, -20)
StatusLabel.AnchorPoint = Vector2.new(1, 1); StatusLabel.BackgroundColor3 = C3(25, 25, 25)
StatusLabel.BackgroundTransparency = 0.2; StatusLabel.TextColor3 = C3(0, 255, 0)
StatusLabel.Text = "SILENT AIM: ON"; StatusLabel.Font = GFB
StatusLabel.TextSize = 14; StatusLabel.BorderSizePixel = 0; StatusLabel.Visible = false
N("UICorner", StatusLabel).CornerRadius = UDim.new(0, 4)

local function UpdateUI()
    if not SilentAimSettings.Active or not SilentAimSettings.PauseWithCtrl then
        StatusLabel.Visible = false; return
    end
    StatusLabel.Visible = true
    if SilentAimSettings.CtrlHeld then
        StatusLabel.Text = "SILENT AIM: PAUSED"; StatusLabel.TextColor3 = C3(255, 150, 0)
    else
        StatusLabel.Text = "SILENT AIM: ON (" .. SilentAimSettings.PauseKey .. ")"; StatusLabel.TextColor3 = C3(0, 255, 0)
    end
end

local function RGBToColor3(t) return C3(t[1] or 255, t[2] or 255, t[3] or 255) end
local function Color3ToRGB(c) return {math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255)} end

local ESPSettings = {
    Active = Config.ESPActive or false,
    TextSize = Config.ESPTextSize or 16,
    HeightOffset = 25, MaxDistance = 30000,
    DefaultColor = RGBToColor3(Config.ESPDefaultColor),
    FriendColor  = RGBToColor3(Config.ESPFriendColor),
    EnemyColor   = RGBToColor3(Config.ESPEnemyColor),
    ShowCure = Config.ShowCure or false,
    ShowStake = Config.ShowStake or false
}

local StaffLabel -- Placeholder

local function PlayNotifySound()
    local sound = N("Sound", workspace)
    sound.SoundId = "rbxassetid://4590657391"
    sound.Volume = 2; sound:Play(); game.Debris:AddItem(sound, 3)
end

local function HasItem(player, itemName)
    local char = player.Character
    local backpack = player:FindFirstChild("Backpack")
    return (backpack and backpack:FindFirstChild(itemName)) or (char and char:FindFirstChild(itemName))
end

local function GetClosestPlayerToMouse()
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    local closest, closestDist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChild("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < closestDist then closestDist = dist; closest = p end
                end
            end
        end
    end
    return closest
end

local function ClearExpander()
    if fakeHitbox then
        pcall(function() fakeHitbox:Destroy() end)
        fakeHitbox = nil
    end
end

local function CreateExpander(targetChar)
    ClearExpander()
    if not targetChar or not targetChar.Parent then return end
    local ok = pcall(function()
        fakeHitbox = N("Part")
        fakeHitbox.Name = "GhostWall"; fakeHitbox.Size = Vector3.new(1000, 1000, 1)
        fakeHitbox.Transparency = 1; fakeHitbox.CanCollide = false
        fakeHitbox.CanQuery = true; fakeHitbox.Anchored = true
        fakeHitbox.Parent = targetChar
    end)
    if not ok then fakeHitbox = nil end
end

local function GetBestTarget()
    if not SilentAimSettings.Active or (SilentAimSettings.PauseWithCtrl and SilentAimSettings.CtrlHeld) then return nil, false end
    local closestTarget = nil
    local shortestMouseDist = SilentAimSettings.FOV
    local anyoneNearby = false

    for _, p in pairs(Players:GetPlayers()) do
        local isProtected = (not SilentAimSettings.FriendlyFire) and (FriendCache[p] or WhitelistCache[p.Name])
        if p ~= LP and not SilentAimSettings.IgnoredUserIds[p.UserId] and not isProtected and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local root = p.Character.HumanoidRootPart
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local distToMe = (LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"))
                    and (root.Position - LP.Character.HumanoidRootPart.Position).Magnitude or (root.Position - Camera.CFrame.Position).Magnitude
                if distToMe <= SilentAimSettings.SleepDist then anyoneNearby = true end
                if distToMe <= SilentAimSettings.MaxLockDist then
                    local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    if onScreen then
                        local mouseDist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                        if mouseDist < shortestMouseDist then
                            shortestMouseDist = mouseDist; closestTarget = p
                        end
                    end
                end
            end
        end
    end
    return closestTarget, anyoneNearby
end

local function CheckFriendStatus(p)
    if p == LP then return end
    pcall(function() FriendCache[p] = LP:IsFriendsWith(p.UserId) end)
end

local function RemoveESP(p)
    if ESPCache[p] then
        for _, obj in pairs(ESPCache[p]) do pcall(function() obj:Remove() end) end
        ESPCache[p] = nil
    end
    FriendCache[p] = nil
end

local function CreateESP(p)
    if p == LP then return end
    RemoveESP(p)
    CheckFriendStatus(p)
    local group = {
        CharText = Drawing.new("Text"), PlayerText = Drawing.new("Text"),
        CureText = Drawing.new("Text"), StakeText = Drawing.new("Text")
    }
    for _, v in pairs(group) do v.Visible = false; v.Outline = true; v.Center = true; v.Font = 0 end
    ESPCache[p] = group
end

local function IsFriendly(char)
    if not char then return false end
    for _, item in pairs(char:GetChildren()) do
        if item:IsA("Tool") or item:IsA("Model") then
            local name = string.lower(item.Name)
            for _, word in pairs(State.IgnoredSkills) do
                if string.find(name, word) then return true end
            end
        end
    end
    return false
end

local function InstantFire()
    if not State.UltraIctusRiskActive or State.Unloaded or not AbilitySelected then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not IsFriendly(player.Character) then pcall(function() AbilitySelected:FireServer("Ictus") end); return end
        end
    end
end

local function WaitAndFireNormal()
    if State.NormalIctusTracking or not AbilitySelected then return end
    State.NormalIctusTracking = true
    local timeout = 2; local startTime = os.clock(); local trackingConnection
    trackingConnection = RunService.Heartbeat:Connect(function()
        if not State.NormalIctusActive or State.Unloaded or (os.clock() - startTime) > timeout then
            if trackingConnection then trackingConnection:Disconnect() end
            State.NormalIctusTracking = false; return
        end
        local myChar = LP.Character
        if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
        local myPos = myChar.HumanoidRootPart.Position
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LP and player.Character and player.Character.Parent then
                local enemyChar = player.Character
                local enemyHRP = enemyChar:FindFirstChild("HumanoidRootPart")
                if not enemyHRP or not enemyHRP.Parent then continue end
                if not IsFriendly(enemyChar) then
                    local dist = (enemyHRP.Position - myPos).Magnitude
                    local speed = enemyHRP.AssemblyLinearVelocity.Magnitude
                    local triggerDistance = (speed > 35) and 14 or 4.5
                    if dist <= triggerDistance then
                        pcall(function() AbilitySelected:FireServer("Ictus") end)
                        if trackingConnection then trackingConnection:Disconnect() end
                        task.spawn(function() task.wait(1); State.NormalIctusTracking = false end)
                        break
                    end
                end
            end
        end
    end)
    table.insert(Connections, trackingConnection)
end

table.insert(Connections, Players.PlayerAdded:Connect(CreateESP))
table.insert(Connections, Players.PlayerRemoving:Connect(RemoveESP))
for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
local oldIndex = mt.__index
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    if State.Unloaded then return oldNamecall(self, ...) end
    local method = getnamecallmethod(); local args = {...}

   local selfName = ""
pcall(function()
    if typeof(self) == "Instance" and self.Parent then
        selfName = self.Name
    end
end)

    if not checkcaller() and State.BypassActive and selfName == "AutoclickerDetected" then return end
    if not checkcaller() and State.CompelActive and AbilityActivated and self == AbilityActivated and method == "FireServer" then
        local result = oldNamecall(self, unpack(args))
        local targetModel = args[1]
        local targetPlayer = nil
        pcall(function()
            targetPlayer = targetModel and targetModel:IsA("Model") and Players:GetPlayerFromCharacter(targetModel) or nil
        end)
        if targetPlayer and BeginAbility then
            task.spawn(function()
                task.wait(0.12)
                for i = 1, 8 do
                    if not State.CompelActive or State.Unloaded then break end
                    pcall(function() BeginAbility:FireServer(targetPlayer, "Follow me") end)
                    task.wait(0.08)
                end
            end)
        end
        return result
    end

    if not checkcaller() and method == "FireServer" then
        if selfName == "ToolStateChanged" or selfName == "AbilityStateChanged" then
            local isFirstToolRemote = (selfName == "ToolStateChanged" and #args == 0)
            local isFirstAbilityRemote = (selfName == "AbilityStateChanged" and args[1] == false)
            if State.UltraIctusRiskActive and AbilitySelected then task.spawn(InstantFire) end
            if State.NormalIctusActive and AbilitySelected and (isFirstToolRemote or isFirstAbilityRemote) then WaitAndFireNormal() end
        end
    end

    local isAimPaused = (SilentAimSettings.PauseWithCtrl and SilentAimSettings.CtrlHeld)
    if SilentAimSettings.Active and not isAimPaused and SilentAimSettings.Target and not checkcaller() and (method == "ScreenPointToRay" or method == "ViewportPointToRay") then
        local target = SilentAimSettings.Target
        if target and target.Parent then  -- player still in game
            local char = target.Character
            if char and char.Parent then  -- character exists and is parented (not mid-respawn)
                local Root = char:FindFirstChild("HumanoidRootPart")
                if Root and Root.Parent then
                    local ok, ray = pcall(function()
                        local vel = Root.AssemblyLinearVelocity
                        local pos = Root.Position
                        if not pos or not vel then return nil end
                        local TPos = pos + (vel * SilentAimSettings.Predict)
                        local Dir = (TPos - Camera.CFrame.Position).Unit
                        return Ray.new(Camera.CFrame.Position, Dir * 1000)
                    end)
                    if ok and ray then return ray end
                else
                    SilentAimSettings.Target = nil
                end
            else
                SilentAimSettings.Target = nil
            end
        else
            SilentAimSettings.Target = nil
        end
    end

    return oldNamecall(self, ...)
end)

mt.__index = newcclosure(function(self, key)
    if State.Unloaded then return oldIndex(self, key) end
    local isAimPaused = (SilentAimSettings.PauseWithCtrl and SilentAimSettings.CtrlHeld)
    if SilentAimSettings.Active and not isAimPaused and SilentAimSettings.Target and not checkcaller() and self == Mouse then
        local target = SilentAimSettings.Target
        if target and target.Parent then
            local char = target.Character
            if char and char.Parent then
                local Root = char:FindFirstChild("HumanoidRootPart")
                if Root and Root.Parent then
                    if key == "Target" or key == "target" then
                        if fakeHitbox and fakeHitbox.Parent then return fakeHitbox else return Root end
                    end
                    if key == "Hit" or key == "hit" then
                        local ok, cf = pcall(function()
                            local vel = Root.AssemblyLinearVelocity
                            local pos = Root.Position
                            if not pos or not vel then return nil end
                            return CFrame.new(pos + (vel * SilentAimSettings.Predict))
                        end)
                        if ok and cf then return cf end
                    end
                else
                    SilentAimSettings.Target = nil
                end
            else
                SilentAimSettings.Target = nil
            end
        else
            SilentAimSettings.Target = nil
        end
    end
    return oldIndex(self, key)
end)
setreadonly(mt, true)

table.insert(Connections, UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    local ok, pauseEnum = pcall(function() return Enum.KeyCode[SilentAimSettings.PauseKey] end)
    if ok and input.KeyCode == pauseEnum then
        SilentAimSettings.CtrlHeld = true; UpdateUI()
    end
end))

table.insert(Connections, UIS.InputEnded:Connect(function(input, processed)
    local ok, pauseEnum = pcall(function() return Enum.KeyCode[SilentAimSettings.PauseKey] end)
    if ok and input.KeyCode == pauseEnum then
        SilentAimSettings.CtrlHeld = false; UpdateUI()
    end
end))

table.insert(Connections, RunService.Stepped:Connect(function()
    if not _G.AntiFling then return end
    pcall(function()
        local myChar = LP.Character
        if myChar then
            for _, part in pairs(myChar:GetChildren()) do if part:IsA("BasePart") then part.CanCollide = false end end
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LP and player.Character then
                    for _, otherPart in pairs(player.Character:GetChildren()) do if otherPart:IsA("BasePart") then otherPart.CanCollide = false end end
                end
            end
        end
    end)
end))

table.insert(Connections, RunService.RenderStepped:Connect(function(deltaTime)
    if State.CustomBrightness >= 0 then
        Lighting.Brightness = 2 + (State.CustomBrightness / 10); Lighting.GlobalShadows = (State.CustomBrightness <= 50)
    end
    if State.CustomFOV ~= 70 then Camera.FieldOfView = State.CustomFOV end

    if not ESPSettings.Active then
        for _, esp in pairs(ESPCache) do
            esp.CharText.Visible = false; esp.PlayerText.Visible = false
            esp.CureText.Visible = false; esp.StakeText.Visible = false
        end
    else
        for p, esp in pairs(ESPCache) do
            local char = p.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")

            if hrp and hum and hum.Health > 0 then
                local distToMe = (Camera.CFrame.Position - hrp.Position).Magnitude
                local headPosition = hrp.Position + Vector3.new(0, 3, 0)
                local pos, onScreen = Camera:WorldToViewportPoint(headPosition)

                if onScreen and distToMe <= ESPSettings.MaxDistance then
                    local charName = p:GetAttribute("CharacterName") or "Not Selected"
                    local isFriend = FriendCache[p] or WhitelistCache[p.Name]
                    local isEnemy = EnemyCache[p.Name]

                    local activeColor = ESPSettings.DefaultColor
                    if isFriend then activeColor = ESPSettings.FriendColor elseif isEnemy then activeColor = ESPSettings.EnemyColor end

                    local scaleFactor = math.clamp(100 / math.max(10, distToMe), 0.85, 1)
                    local currentTextSize = math.max(14, math.floor(ESPSettings.TextSize * scaleFactor))
                    local currentY = pos.Y - ESPSettings.HeightOffset

                    esp.CharText.Visible = true
                    esp.CharText.Text = charName
                    esp.CharText.Color = activeColor
                    esp.CharText.Size = currentTextSize
                    esp.CharText.Position = Vector2.new(pos.X, currentY)
                    currentY = currentY + (currentTextSize * 0.8)

                    local prefix = isFriend and "* " or ""
                    local suffix = isFriend and " *" or ""
                    esp.PlayerText.Visible = true
                    esp.PlayerText.Text = prefix .. p.Name .. suffix
                    esp.PlayerText.Color = activeColor
                    esp.PlayerText.Size = currentTextSize + 2
                    esp.PlayerText.Position = Vector2.new(pos.X, currentY)

                    local hasCure = ESPSettings.ShowCure and (HasItem(p, "TheCure") or HasItem(p, "QetsiyahCure")) or false
                    local hasStake = ESPSettings.ShowStake and HasItem(p, "WoodenStake") or false

                    local charBounds = esp.CharText.TextBounds
                    local rightX = pos.X + (charBounds.X / 2) + 6

                    if hasCure then
                        esp.CureText.Visible = true
                        esp.CureText.Text = "*"
                        esp.CureText.Color = C3(138, 0, 0)
                        esp.CureText.Size = currentTextSize + 6
                        esp.CureText.Position = Vector2.new(rightX, pos.Y - ESPSettings.HeightOffset + 2)
                        pcall(function() rightX = rightX + esp.CureText.TextBounds.X + 2 end)
                    else esp.CureText.Visible = false end

                    if hasStake then
                        esp.StakeText.Visible = true
                        esp.StakeText.Text = "*"
                        esp.StakeText.Color = C3(101, 67, 33)
                        esp.StakeText.Size = currentTextSize + 6
                        esp.StakeText.Position = Vector2.new(rightX, pos.Y - ESPSettings.HeightOffset + 2)
                    else esp.StakeText.Visible = false end
                else
                    esp.CharText.Visible = false; esp.PlayerText.Visible = false; esp.CureText.Visible = false; esp.StakeText.Visible = false
                end
            else
                esp.CharText.Visible = false; esp.PlayerText.Visible = false; esp.CureText.Visible = false; esp.StakeText.Visible = false
            end
        end
    end

    local isAimPaused = (SilentAimSettings.PauseWithCtrl and SilentAimSettings.CtrlHeld)
    if not SilentAimSettings.Active or isAimPaused then
        SilentAimSettings.Target = nil; ClearExpander(); Mouse.TargetFilter = nil; return
    end

    local best, nearby = GetBestTarget()
    if not nearby then SilentAimSettings.Target = nil; ClearExpander(); return end

    if best then
        if SilentAimSettings.Target ~= best then
            if best.Character and best.Character.Parent then
                SilentAimSettings.Target = best; CreateExpander(best.Character)
            end
        end
        if fakeHitbox and fakeHitbox.Parent then
            local myPos = LP.Character and LP.Character.PrimaryPart and LP.Character.PrimaryPart.Position or Camera.CFrame.Position
            local dist = (Camera.CFrame.Position - myPos).Magnitude + SilentAimSettings.FrontOffset
            pcall(function()
                fakeHitbox.CFrame = Camera.CFrame * CFrame.new(0, 0, -dist)
                fakeHitbox.Transparency = 1
                Mouse.TargetFilter = fakeHitbox
            end)
        elseif fakeHitbox and not fakeHitbox.Parent then
            fakeHitbox = nil
            SilentAimSettings.Target = nil
            Mouse.TargetFilter = nil
        end
    else
        SilentAimSettings.Target = nil; ClearExpander(); Mouse.TargetFilter = nil
    end
end))

-- GUI için global export
_G.TVL2 = {
    State = State,
    Config = Config,
    SaveConfig = SaveConfig,
    SilentAimSettings = SilentAimSettings,
    ESPSettings = ESPSettings,
    ESPCache = ESPCache,
    FriendCache = FriendCache,
    WhitelistCache = WhitelistCache,
    EnemyCache = EnemyCache,
    Connections = Connections,
    Players = Players,
    LP = LP,
    Camera = Camera,
    Mouse = Mouse,
    UIS = UIS,
    RunService = RunService,
    TweenService = TweenService,
    TeleportService = TeleportService,
    CoreGui = CoreGui,
    SoundService = SoundService,
    ReplicatedStorage = ReplicatedStorage,
    Lighting = Lighting,
    AbilityActivated = AbilityActivated,
    BeginAbility = BeginAbility,
    SiphonRemote = SiphonRemote,
    AbilitySelected = AbilitySelected,
    ClearExpander = ClearExpander,
    CreateExpander = CreateExpander,
    RemoveESP = RemoveESP,
    CreateESP = CreateESP,
    PlayNotifySound = PlayNotifySound,
    N = N, C3 = C3, U2 = U2,
    GFB = GFB, GFM = GFM, GF = GF, ETXA = ETXA,
}
