-- ui.lua  (Synth UI Library - Purple Theme)

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local HttpService      = game:GetService("HttpService")

local Library = {}
Library.__index = Library

local GUI_NAME = "SynthUI"
local CFG_DIR = "SynthUI/configs"

local function _safeDestroy(x)
    pcall(function()
        if x and x.Destroy then x:Destroy() end
    end)
end

local function _canFS()
    return typeof(readfile) == "function"
        and typeof(writefile) == "function"
        and typeof(isfile) == "function"
        and typeof(delfile) == "function"
        and typeof(makefolder) == "function"
end

local function _ensureCfgDir()
    if typeof(makefolder) ~= "function" then return end
    pcall(function() makefolder("SynthUI") end)
    pcall(function() makefolder(CFG_DIR) end)
end

local function _sanitizeConfigName(name)
    name = tostring(name or "")
    name = name:gsub("^%s+", ""):gsub("%s+$", "")
    name = name:gsub("[\\/:*?\"<>|]", "_")
    name = name:gsub("%s+", " ")
    if name == "" then name = "default" end
    return name
end

local function safeParent()
    local ok, h = pcall(function() return gethui and gethui() end)
    if ok and h then return h end
    local lp = Players.LocalPlayer
    if lp then
        local ok2, pg = pcall(function() return lp:WaitForChild("PlayerGui",3) end)
        if ok2 and pg then return pg end
    end
    return game:GetService("CoreGui")
end

local function destroyExistingUI()
    local parents = {}
    local seen = {}
    local function add(p)
        if p and not seen[p] then
            seen[p] = true
            table.insert(parents, p)
        end
    end

    add(game:GetService("CoreGui"))
    add(safeParent())
    local ok, h = pcall(function() return gethui and gethui() end)
    if ok and h then add(h) end
    local lp = Players.LocalPlayer
    if lp then
        local pg = lp:FindFirstChildOfClass("PlayerGui")
        if pg then add(pg) end
    end

    for _,p in ipairs(parents) do
        pcall(function()
            for _,ch in ipairs(p:GetChildren()) do
                if ch:IsA("ScreenGui") and ch.Name == GUI_NAME then
                    ch:Destroy()
                end
            end
        end)
    end
end

local function new(cls, props, parent)
    local i = Instance.new(cls)
    for k,v in pairs(props or {}) do i[k]=v end
    if parent then i.Parent=parent end
    return i
end

local function corner(f,r) new("UICorner",{CornerRadius=UDim.new(0,r or 6)},f) end
local function stroke(f,c,t) new("UIStroke",{Color=c or Color3.fromRGB(60,40,80),Thickness=t or 1},f) end
local function pad(f,l,r,t,b)
    new("UIPadding",{
        PaddingLeft=UDim.new(0,l or 0),PaddingRight=UDim.new(0,r or 0),
        PaddingTop=UDim.new(0,t or 0),PaddingBottom=UDim.new(0,b or 0),
    },f)
end

local function onClick(btn,fn)
    if btn and btn.Activated then
        btn.Activated:Connect(fn)
    else
        btn.MouseButton1Down:Connect(fn)
    end
end

local function setTextAlpha(obj, a)
    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
        obj.TextTransparency = a
    end
end

local function setDescendantAlpha(root, a)
    for _,d in ipairs(root:GetDescendants()) do
        if d:IsA("UIStroke") then
            d.Transparency = a
        elseif d:IsA("Frame") then
            d.BackgroundTransparency = a
        elseif d:IsA("ImageLabel") or d:IsA("ImageButton") then
            d.ImageTransparency = a
        else
            setTextAlpha(d, a)
        end
    end
end

-- Dark grey UI with a non-red accent (to match the reference style without red/glow)
local C = {
    bg       = Color3.fromRGB(12,12,12),
    topbar   = Color3.fromRGB(16,16,16),
    sidebar  = Color3.fromRGB(14,14,14),
    section  = Color3.fromRGB(20,20,20),
    panel    = Color3.fromRGB(24,24,24),
    border   = Color3.fromRGB(38,38,38),
    text     = Color3.fromRGB(235,235,235),
    muted    = Color3.fromRGB(150,150,150),
    accent   = Color3.fromRGB(150,110,255),
    accent2  = Color3.fromRGB(110,80,210),
    sliderBg = Color3.fromRGB(30,30,30),
    sliderFg = Color3.fromRGB(150,110,255),
    input    = Color3.fromRGB(18,18,18),
    dropdown = Color3.fromRGB(18,18,18),
    dropItem = Color3.fromRGB(22,22,22),
    btn      = Color3.fromRGB(18,18,18),
    btnHov   = Color3.fromRGB(26,26,26),
    toggleOn = Color3.fromRGB(150,110,255),
    toggleOff= Color3.fromRGB(45,45,45),
    picker   = Color3.fromRGB(18,18,18),
}

local TAB_ICONS = {
    Main = "⌂",
    Misc = "</>",
    Miscellaneous = "</>",
    Combat = "⌖",
    Visuals = "◉",
    Settings = "⚙",
}

local function getScale()
    local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920,1080)
    if vp.X < 500 then return 0.60 elseif vp.X < 900 then return 0.80 else return 1.0 end
end
local function sc(base,s) return math.floor(base*s+0.5) end

local function makeDraggable(handle,frame)
    local drag,sP,oP=false,nil,nil
    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            drag=true; sP=inp.Position; oP=frame.Position
        end
    end)
    handle.InputChanged:Connect(function(inp)
        if not drag then return end
        if inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch then
            local d=inp.Position-sP
            frame.Position=UDim2.new(oP.X.Scale,oP.X.Offset+d.X,oP.Y.Scale,oP.Y.Offset+d.Y)
        end
    end)
    handle.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)
end

local function makeDraggableObject(obj)
    if not obj then return end
    obj.Active = true
    makeDraggable(obj, obj)
end

function Library:_track(conn)
    if typeof(conn) == "RBXScriptConnection" then
        self._conns = self._conns or {}
        table.insert(self._conns, conn)
    end
    return conn
end

function Library:_disconnectAll()
    if not self._conns then return end
    for _,c in ipairs(self._conns) do
        pcall(function() c:Disconnect() end)
    end
    self._conns = {}
end

function Library:_registerControl(key, ctrl)
    if not key or key == "" then return end
    if not ctrl or typeof(ctrl.Get) ~= "function" or typeof(ctrl.Set) ~= "function" then return end
    self._controls = self._controls or {}
    self._controls[key] = ctrl
end

function Library:GetConfigList()
    if typeof(listfiles) ~= "function" then return {} end
    _ensureCfgDir()
    local ok, files = pcall(function() return listfiles(CFG_DIR) end)
    if not ok or typeof(files) ~= "table" then return {} end
    local out = {}
    for _,path in ipairs(files) do
        local name = tostring(path):match("([^/\\]+)%.json$")
        if name and name ~= "" then table.insert(out, name) end
    end
    table.sort(out)
    return out
end

function Library:SaveConfig(name)
    if not _canFS() then
        self:Notify({Title=self._title or "Synth", Text="Config save unavailable (no file APIs)."})
        return false
    end

    _ensureCfgDir()
    name = _sanitizeConfigName(name)
    local path = CFG_DIR.."/"..name..".json"

    local values = {}
    for key,ctrl in pairs(self._controls or {}) do
        local ok, v = pcall(function() return ctrl:Get() end)
        if ok then values[key] = v end
    end

    local payload = {
        version = 1,
        title = tostring(self._title or "Synth"),
        savedAt = os.time(),
        values = values,
    }

    local ok, data = pcall(function() return HttpService:JSONEncode(payload) end)
    if not ok then
        self:Notify({Title=self._title or "Synth", Text="Failed to encode config."})
        return false
    end

    local ok2 = pcall(function() writefile(path, data) end)
    if ok2 then
        self:Notify({Title=self._title or "Synth", Text="Saved config: "..name})
        return true
    end

    self:Notify({Title=self._title or "Synth", Text="Failed to write config file."})
    return false
end

function Library:LoadConfig(name)
    if not _canFS() then
        self:Notify({Title=self._title or "Synth", Text="Config load unavailable (no file APIs)."})
        return false
    end

    _ensureCfgDir()
    name = _sanitizeConfigName(name)
    local path = CFG_DIR.."/"..name..".json"
    if not isfile(path) then
        self:Notify({Title=self._title or "Synth", Text="Config not found: "..name})
        return false
    end

    local raw
    local okRead = pcall(function() raw = readfile(path) end)
    if not okRead or typeof(raw) ~= "string" then
        self:Notify({Title=self._title or "Synth", Text="Failed to read config."})
        return false
    end

    local okDec, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
    if not okDec or typeof(decoded) ~= "table" then
        self:Notify({Title=self._title or "Synth", Text="Invalid config file."})
        return false
    end

    local values = decoded.values
    if typeof(values) ~= "table" then values = {} end

    for key,val in pairs(values) do
        local ctrl = (self._controls or {})[key]
        if ctrl and typeof(ctrl.Set) == "function" then
            pcall(function() ctrl:Set(val) end)
        end
    end

    self:Notify({Title=self._title or "Synth", Text="Loaded config: "..name})
    return true
end

function Library:DeleteConfig(name)
    if not _canFS() then
        self:Notify({Title=self._title or "Synth", Text="Config delete unavailable (no file APIs)."})
        return false
    end

    _ensureCfgDir()
    name = _sanitizeConfigName(name)
    local path = CFG_DIR.."/"..name..".json"
    if not isfile(path) then
        self:Notify({Title=self._title or "Synth", Text="Config not found: "..name})
        return false
    end

    local ok = pcall(function() delfile(path) end)
    if ok then
        self:Notify({Title=self._title or "Synth", Text="Deleted config: "..name})
        return true
    end
    self:Notify({Title=self._title or "Synth", Text="Failed to delete config."})
    return false
end

function Library:SetStreamerMode(v)
    self._streamerMode = (v == true)
    local dn = self._profileDisplay
    local un = self._profileUser
    if dn and dn:IsA("TextLabel") then
        dn.Text = self._streamerMode and "Hidden" or tostring(self._lastDisplayName or dn.Text or "")
    end
    if un and un:IsA("TextLabel") then
        un.Text = self._streamerMode and "" or tostring(self._lastUsername or un.Text or "")
    end
end

-- ══════════════════════════════════════════════════════════════
-- CreateWindow
-- ══════════════════════════════════════════════════════════════
function Library:CreateWindow(cfg)
    cfg=cfg or {}
    destroyExistingUI()
    local title1 = tostring(cfg.Title1 or cfg.Title or "Synth")
    local title2
    if cfg.Title2 ~= nil then
        title2 = tostring(cfg.Title2)
    elseif cfg.Suffix ~= nil then
        title2 = tostring(cfg.Suffix)
    else
        if title1:lower():match("%.gg$") then
            title2 = ""
        else
            title2 = ""
        end
    end
    local s=getScale()
    local title2Offset = tonumber(cfg.Title2Offset) or sc(4,s)
    local TH = sc(44,s)
    local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920,1080)
    local W = sc(760,s)
    local H = sc(540,s)
    W = math.min(W, math.max(320, math.floor(vp.X*0.92)))
    H = math.min(H, math.max(260, math.floor(vp.Y*0.90)))
    local SW = sc(155,s)
    SW = math.min(SW, math.max(sc(120,s), math.floor(W*0.34)))
    local profileH = sc(64,s)
    local tabsLift = tonumber(cfg.TabsLift or cfg.TabLift or cfg.ContentLift) or sc(24,s)

    local win

    local gui=new("ScreenGui",{
        Name=GUI_NAME,ResetOnSpawn=false,
        ZIndexBehavior=Enum.ZIndexBehavior.Sibling,IgnoreGuiInset=true,
    },safeParent())

    local root=new("Frame",{
        Name="Root",Size=UDim2.fromOffset(W,H),
        Position=UDim2.fromScale(0.5,0.5),AnchorPoint=Vector2.new(0.5,0.5),
        BackgroundColor3=C.bg,BorderSizePixel=0,ClipsDescendants=true,
    },gui)
    corner(root,8); stroke(root,C.border,1)

    local topbar=new("Frame",{
        Name="TopBar",Size=UDim2.new(1,0,0,TH),
        BackgroundColor3=C.topbar,BorderSizePixel=0,
    },root)
    corner(topbar,8)
    new("Frame",{Size=UDim2.new(1,0,0,10),Position=UDim2.new(0,0,1,-10),BackgroundColor3=C.topbar,BorderSizePixel=0},topbar)
    new("Frame",{BackgroundColor3=C.border,BorderSizePixel=0,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0)},topbar)
    local titleWrap=new("Frame",{
        BackgroundTransparency=1,
        Size=UDim2.new(1,-(SW+sc(24,s)),1,0),
        Position=UDim2.fromOffset(SW+sc(12,s),0),
    },topbar)
    local titleMain=new("TextLabel",{
        BackgroundTransparency=1,
        AutomaticSize=Enum.AutomaticSize.X,
        Size=UDim2.new(0,0,1,0),
        Position=UDim2.fromOffset(0,0),
        Font=Enum.Font.GothamBold,
        Text=title1,
        TextSize=sc(20,s),
        TextXAlignment=Enum.TextXAlignment.Left,
        TextColor3=C.text,
    },titleWrap)
    local titleSuf=new("TextLabel",{
        BackgroundTransparency=1,
        AutomaticSize=Enum.AutomaticSize.X,
        Size=UDim2.new(0,0,1,0),
        Position=UDim2.new(0,0,0,0),
        Font=Enum.Font.GothamBold,
        Text=title2,
        TextSize=sc(20,s),
        TextXAlignment=Enum.TextXAlignment.Left,
        TextColor3=C.accent,
    },titleWrap)
    local function layoutTitle()
        if titleMain and titleSuf then
            titleSuf.Position = UDim2.fromOffset(titleMain.TextBounds.X + title2Offset, 0)
        end
    end
    layoutTitle()
    titleMain:GetPropertyChangedSignal("Text"):Connect(layoutTitle)
    titleMain:GetPropertyChangedSignal("TextSize"):Connect(layoutTitle)
    titleMain:GetPropertyChangedSignal("Font"):Connect(layoutTitle)
    makeDraggable(topbar,root)

    local sidebar=new("ScrollingFrame",{
        Name="Sidebar",
        Size=UDim2.new(0,SW,1,-(TH+profileH-tabsLift)),
        Position=UDim2.fromOffset(0,TH-tabsLift),
        BackgroundColor3=C.sidebar,BorderSizePixel=0,
        ScrollBarThickness=0,CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,ClipsDescendants=true,
    },root)
    new("Frame",{BackgroundColor3=C.border,BorderSizePixel=0,Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,0,0,0)},sidebar)

    local profile=new("Frame",{
        Name="Profile",
        Size=UDim2.new(0,SW,0,profileH),
        Position=UDim2.new(0,0,1,-profileH),
        BackgroundColor3=C.sidebar,
        BorderSizePixel=0,
        ClipsDescendants=true,
    },root)
    new("Frame",{BackgroundColor3=C.border,BorderSizePixel=0,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,0,0)},profile)
    new("Frame",{BackgroundColor3=C.border,BorderSizePixel=0,Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,0,0,0)},profile)

    local avatarSz = sc(40,s)
    local padX = sc(10,s)
    local avatar=new("ImageLabel",{
        Name="Avatar",
        Size=UDim2.fromOffset(avatarSz,avatarSz),
        Position=UDim2.fromOffset(padX, math.floor((profileH-avatarSz)/2)),
        BackgroundColor3=C.panel,
        BorderSizePixel=0,
        Image="",
        ScaleType=Enum.ScaleType.Crop,
    },profile)
    corner(avatar, math.floor(avatarSz/2))
    stroke(avatar, C.border, 1)

    local textX = padX + avatarSz + sc(10,s)
    local displayLbl=new("TextLabel",{
        Name="DisplayName",
        BackgroundTransparency=1,
        Size=UDim2.new(1,-(textX+padX),0,sc(18,s)),
        Position=UDim2.fromOffset(textX, sc(14,s)),
        Font=Enum.Font.GothamBold,
        Text="",
        TextSize=sc(12,s),
        TextXAlignment=Enum.TextXAlignment.Left,
        TextColor3=C.text,
    },profile)
    local userLbl=new("TextLabel",{
        Name="Username",
        BackgroundTransparency=1,
        Size=UDim2.new(1,-(textX+padX),0,sc(16,s)),
        Position=UDim2.fromOffset(textX, sc(30,s)),
        Font=Enum.Font.Gotham,
        Text="",
        TextSize=sc(11,s),
        TextXAlignment=Enum.TextXAlignment.Left,
        TextColor3=C.muted,
    },profile)

    local lastDisplayName = ""
    local lastUsername = ""
    task.spawn(function()
        local lp = Players.LocalPlayer
        if not lp then return end

        local function refreshText()
            local dn = tostring(lp.DisplayName or lp.Name or "")
            local un = tostring(lp.Name or "")
            lastDisplayName = dn
            lastUsername = (un ~= "" and ("@"..un) or "")
            displayLbl.Text = dn
            userLbl.Text = (un ~= "" and ("@"..un) or "")
            if win and win._streamerMode == true then win:SetStreamerMode(true) end
        end

        refreshText()
        pcall(function()
            local conn = lp:GetPropertyChangedSignal("DisplayName"):Connect(refreshText)
            if win then win:_track(conn) end
        end)

        pcall(function()
            local img = Players:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            if typeof(img) == "string" and img ~= "" then
                avatar.Image = img
            end
        end)
    end)

    local tabList=new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},sidebar)
    new("UIListLayout",{FillDirection=Enum.FillDirection.Vertical,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,sc(2,s))},tabList)
    pad(tabList,sc(6,s),sc(6,s),0,sc(4,s))

    local pagesArea=new("ScrollingFrame",{
        Name="Pages",
        Size=UDim2.new(1,-(SW+sc(2,s)),1,-TH),
        Position=UDim2.fromOffset(SW+sc(2,s),TH),
        BackgroundTransparency=1,
        ClipsDescendants=true,ScrollBarThickness=sc(3,s),
        ScrollBarImageColor3=C.border,
        CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.None,
        BorderSizePixel=0,
    },root)

    -- optional: small top padding so first section isn't tight against the top
    local pagesPadTop = tonumber(cfg.PagesPaddingTop) or sc(12,s)
    local pagesPadBottom = tonumber(cfg.PagesPaddingBottom) or sc(12,s)
    new("UIPadding",{
        PaddingTop = UDim.new(0, math.max(0, pagesPadTop)),
        PaddingLeft = UDim.new(0, 0),
        PaddingRight = UDim.new(0, 0),
        PaddingBottom = UDim.new(0, math.max(0, pagesPadBottom)),
    }, pagesArea)

    -- Open/Close button: plain text, top-right of screen, no symbols
    local closeSz=tonumber(cfg.ToggleButtonSize) or sc(52,s)
    local closeBtn=new("TextButton",{
        Name="CloseBtn",
        Size=UDim2.fromOffset(closeSz,closeSz),
        AnchorPoint=Vector2.new(1,0),
        Position=UDim2.new(1,-sc(8,s),0,sc(8,s)),
        BackgroundColor3=C.panel,
        Text="",Font=Enum.Font.GothamBold,
        TextSize=sc(12,s),TextColor3=C.accent,
        AutoButtonColor=false,ZIndex=100,BorderSizePixel=0,
    },gui)
    corner(closeBtn,6); stroke(closeBtn,C.border,1)

    local toggleImg = tostring(cfg.ToggleButtonImage or "")
    local icon=new("ImageLabel",{
        Name="Icon",
        BackgroundTransparency=1,
        AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.fromScale(0.5,0.5),
        Size=UDim2.fromOffset(sc(22,s),sc(22,s)),
        Image=(toggleImg ~= "" and toggleImg or "rbxassetid://103676972502936"),
        ImageColor3=C.accent,
        ScaleType=Enum.ScaleType.Fit,
        ZIndex=101,
    },closeBtn)
    if toggleImg == "" then
        -- default to Roblox UI icon sheet "menu" glyph
        icon.ImageRectOffset = Vector2.new(564, 364)
        icon.ImageRectSize = Vector2.new(36, 36)
    end

    makeDraggableObject(closeBtn)

    local uiOpen=true
    onClick(closeBtn,function()
        uiOpen=not uiOpen
        root.Visible=uiOpen
        icon.ImageColor3=uiOpen and C.accent or C.muted
    end)

    -- Notifications (toasts)
    local notifW = sc(280,s)
    local notifHost=new("Frame",{
        Name="Notifications",
        BackgroundTransparency=1,
        AnchorPoint=Vector2.new(1,0),
        Position=UDim2.new(1,-sc(8,s),0,sc(54,s)),
        Size=UDim2.fromOffset(notifW,0),
        AutomaticSize=Enum.AutomaticSize.Y,
        ZIndex=200,
        ClipsDescendants=false,
    },gui)
    local notifList=new("UIListLayout",{
        FillDirection=Enum.FillDirection.Vertical,
        SortOrder=Enum.SortOrder.LayoutOrder,
        Padding=UDim.new(0,sc(8,s)),
        HorizontalAlignment=Enum.HorizontalAlignment.Right,
        VerticalAlignment=Enum.VerticalAlignment.Top,
    },notifHost)

    win=setmetatable({
        _gui=gui,_root=root,_tabList=tabList,_pages=pagesArea,
        _tabs={},_active=nil,_s=s,
        _title=title1,
        _tabIcons=cfg.TabIcons or {},
        _tabIconsEnabled = (cfg.TabIconsEnabled == true) and (cfg.DisableTabIcons ~= true),
        _notifyHost=notifHost,
        _notifyList=notifList,
        _notifyEnabled=true,
        _notifySeq=0,
        _conns={},
        _controls={},
        _alive=true,
        _streamerMode=false,
        _profileDisplay=displayLbl,
        _profileUser=userLbl,
        _lastDisplayName=lastDisplayName,
        _lastUsername=lastUsername,
        _pagesPadTop = pagesPadTop,
        _pagesPadBottom = pagesPadBottom,
    },Library)

    -- Default Settings tab
    if cfg.DisableSettingsTab ~= true then
        task.defer(function()
            if win and win._alive then
                pcall(function() win:_ensureSettingsTab() end)
            end
        end)
    end
    return win
end

function Library:SetNotificationsEnabled(v)
    self._notifyEnabled = (v == true)
end

function Library:Notify(opts)
    if not self._notifyHost then return end
    if self._notifyEnabled == false then return end

    opts = opts or {}
    local text = tostring(opts.Text or opts.Message or "")
    if text == "" then return end

    local s = self._s or 1
    local duration = tonumber(opts.Duration) or 3
    duration = math.max(0, duration)
    local title = tostring(opts.Title or self._title or "Synth")

    self._notifySeq = (self._notifySeq or 0) + 1
    local seq = self._notifySeq

    local toast=new("TextButton",{
        Name="Toast"..tostring(seq),
        BackgroundColor3=C.panel,
        BackgroundTransparency=1,
        BorderSizePixel=0,
        AutoButtonColor=false,
        Text="",
        ZIndex=201,
        Size=UDim2.new(1,0,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,
        LayoutOrder=seq,
    },self._notifyHost)
    corner(toast,6)
    local st = new("UIStroke",{Color=C.border,Thickness=1,Transparency=1},toast)
    pad(toast,sc(10,s),sc(10,s),sc(8,s),sc(8,s))

    local tLbl=new("TextLabel",{
        BackgroundTransparency=1,
        Size=UDim2.new(1,0,0,sc(16,s)),
        Font=Enum.Font.GothamBold,
        Text=title,
        TextSize=sc(12,s),
        TextXAlignment=Enum.TextXAlignment.Left,
        TextColor3=C.accent,
        TextTransparency=1,
        ZIndex=202,
    },toast)

    local bLbl=new("TextLabel",{
        BackgroundTransparency=1,
        Size=UDim2.new(1,0,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,
        Position=UDim2.fromOffset(0,sc(18,s)),
        Font=Enum.Font.Gotham,
        Text=text,
        TextSize=sc(12,s),
        TextWrapped=true,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextYAlignment=Enum.TextYAlignment.Top,
        TextColor3=C.text,
        TextTransparency=1,
        ZIndex=202,
    },toast)

    local barBg=new("Frame",{
        BackgroundColor3=C.border,
        BackgroundTransparency=0.55,
        BorderSizePixel=0,
        AnchorPoint=Vector2.new(0,1),
        Position=UDim2.new(0,0,1,0),
        Size=UDim2.new(1,0,0,sc(2,s)),
        ZIndex=202,
    },toast)
    local bar=new("Frame",{
        BackgroundColor3=C.accent,
        BorderSizePixel=0,
        Size=UDim2.new(1,0,1,0),
        ZIndex=203,
    },barBg)

    local closing = false
    local function close()
        if closing then return end
        closing = true
        local ti = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        TweenService:Create(toast, ti, {BackgroundTransparency=1}):Play()
        TweenService:Create(st, ti, {Transparency=1}):Play()
        TweenService:Create(tLbl, ti, {TextTransparency=1}):Play()
        TweenService:Create(bLbl, ti, {TextTransparency=1}):Play()
        task.delay(0.2, function()
            if toast then toast:Destroy() end
        end)
    end

    toast.MouseButton1Click:Connect(close)

    -- Fade in
    local tiIn = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(toast, tiIn, {BackgroundTransparency=0}):Play()
    TweenService:Create(st, tiIn, {Transparency=0}):Play()
    TweenService:Create(tLbl, tiIn, {TextTransparency=0}):Play()
    TweenService:Create(bLbl, tiIn, {TextTransparency=0}):Play()

    -- Progress + auto close
    if duration > 0 then
        TweenService:Create(bar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size=UDim2.new(0,0,1,0)}):Play()
        task.delay(duration, close)
    else
        barBg.Visible = false
    end
end

function Library:Destroy()
    self._alive = false
    self:_disconnectAll()
    if self._gui then self._gui:Destroy() end
end

-- ══════════════════════════════════════════════════════════════
-- AddTab
-- ══════════════════════════════════════════════════════════════
function Library:AddTab(name)
    local tabCfg
    if typeof(name) == "table" then
        tabCfg = name
        name = tabCfg.Name or tabCfg.Title or tabCfg.Text or "Tab"
    end
    name=tostring(name or "Tab")
    local s=self._s; local idx=#self._tabs+1; local win=self

    local btn=new("TextButton",{
        Name=name.."Tab",
        BackgroundColor3=C.panel,
        BackgroundTransparency=0.6,
        Size=UDim2.new(1,0,0,sc(36,s)),
        Font=Enum.Font.GothamMedium,
        Text="",
        TextSize=sc(12,s),
        TextXAlignment=Enum.TextXAlignment.Left,
        TextColor3=C.muted,
        AutoButtonColor=false,
        LayoutOrder=idx,
    },self._tabList)
    corner(btn,5)

    local indicator=new("Frame",{
        Name="Indicator",
        BackgroundColor3=C.accent,
        BorderSizePixel=0,
        Size=UDim2.new(0,sc(3,s),1,0),
        BackgroundTransparency=1,
    },btn)
    corner(indicator,5)

    if win._tabIconsEnabled == true then
        local iconSpec
        if tabCfg and tabCfg.Icon ~= nil then
            iconSpec = tabCfg.Icon
        elseif win._tabIcons and win._tabIcons[name] ~= nil then
            iconSpec = win._tabIcons[name]
        else
            iconSpec = TAB_ICONS[name] or TAB_ICONS[name:gsub("%s+","")]
        end

        local iconHost=new("Frame",{
            Name="IconHost",
            BackgroundTransparency=1,
            Size=UDim2.fromOffset(sc(22,s),sc(36,s)),
            Position=UDim2.fromOffset(sc(8,s),0),
        },btn)

        if typeof(iconSpec) == "string" and (iconSpec:find("rbxassetid://") == 1 or iconSpec:match("^%d+$")) then
            local img = iconSpec
            if img:match("^%d+$") then img = "rbxassetid://"..img end
            new("ImageLabel",{
                Name="Icon",
                BackgroundTransparency=1,
                Size=UDim2.fromOffset(sc(16,s),sc(16,s)),
                Position=UDim2.fromScale(0.5,0.5),
                AnchorPoint=Vector2.new(0.5,0.5),
                Image=img,
                ImageColor3=C.muted,
                ScaleType=Enum.ScaleType.Fit,
            },iconHost)
        else
            new("TextLabel",{
                Name="Icon",
                BackgroundTransparency=1,
                Size=UDim2.fromScale(1,1),
                Position=UDim2.new(0,0,0,0),
                Font=Enum.Font.GothamBold,
                Text=tostring(iconSpec or ""),
                TextSize=sc(14,s),
                TextColor3=C.muted,
                TextXAlignment=Enum.TextXAlignment.Left,
            },iconHost)
        end
    end

    local text=new("TextLabel",{
        Name="Label",
        BackgroundTransparency=1,
        Size=UDim2.new(1,-sc(44,s),1,0),
        Position=UDim2.fromOffset(win._tabIconsEnabled and sc(32,s) or sc(12,s),0),
        Font=Enum.Font.Gotham,
        Text=name,
        TextSize=sc(13,s),
        TextXAlignment=Enum.TextXAlignment.Left,
        TextColor3=C.muted,
    },btn)

    local page=new("Frame",{
        Name=name.."Page",BackgroundTransparency=1,
        Size=UDim2.new(1,0,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,
        Visible=false,
    },self._pages)

    local cols=new("Frame",{BackgroundTransparency=1,
        Size=UDim2.new(1,-sc(16,s),0,0),Position=UDim2.fromOffset(sc(8,s),0),
        AutomaticSize=Enum.AutomaticSize.Y},page)

    local leftCol=new("Frame",{Name="Left",BackgroundTransparency=1,
        Size=UDim2.new(0.5,-sc(6,s),0,0),AutomaticSize=Enum.AutomaticSize.Y},cols)
    new("UIListLayout",{FillDirection=Enum.FillDirection.Vertical,
        SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,sc(10,s))},leftCol)

    local rightCol=new("Frame",{Name="Right",BackgroundTransparency=1,
        AnchorPoint=Vector2.new(1,0),Size=UDim2.new(0.5,-sc(6,s),0,0),
        Position=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},cols)
    new("UIListLayout",{FillDirection=Enum.FillDirection.Vertical,
        SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,sc(10,s))},rightCol)

    local tab={Name=name,Button=btn,Page=page,Left=leftCol,Right=rightCol,Window=win}

    local function refreshCanvas()
        if win._active ~= tab then return end
        task.defer(function()
            if not win._pages or not page or not win._alive then return end
            local padT = tonumber(win._pagesPadTop) or 0
            local padB = tonumber(win._pagesPadBottom) or 0
            local h = page.AbsoluteSize.Y
            win._pages.CanvasSize = UDim2.new(0,0,0, math.max(0, h + padT + padB))
        end)
    end
    win:_track(page:GetPropertyChangedSignal("AbsoluteSize"):Connect(refreshCanvas))

    function tab:Select()
        for _,t in ipairs(win._tabs) do
            local a=(t==self)
            t.Page.Visible=a
            TweenService:Create(t.Button,TweenInfo.new(0.15),{
                BackgroundTransparency=a and 0.35 or 0.6,
            }):Play()

            local ind=t.Button:FindFirstChild("Indicator")
            if ind then
                TweenService:Create(ind,TweenInfo.new(0.15),{BackgroundTransparency=a and 0 or 1}):Play()
            end
            if win._tabIconsEnabled == true then
                local host = t.Button:FindFirstChild("IconHost")
                local ic = host and host:FindFirstChild("Icon")
                if ic and ic:IsA("TextLabel") then
                    TweenService:Create(ic,TweenInfo.new(0.15),{TextColor3=a and C.accent or C.muted}):Play()
                elseif ic and ic:IsA("ImageLabel") then
                    TweenService:Create(ic,TweenInfo.new(0.15),{ImageColor3=a and C.accent or C.muted}):Play()
                end
            end
            local tl=t.Button:FindFirstChild("Label")
            if tl and tl:IsA("TextLabel") then
                TweenService:Create(tl,TweenInfo.new(0.15),{TextColor3=a and C.text or C.muted}):Play()
            end
        end
        win._active=self
        refreshCanvas()
    end

    -- ── AddSection ──────────────────────────────────────────────
    function tab:AddSection(sTitle,side)
        local col=(side=="Right" or side=="right") and rightCol or leftCol

        local sec=new("Frame",{BackgroundColor3=C.section,BorderSizePixel=0,
            Size=UDim2.new(1,0,0,sc(40,s)),AutomaticSize=Enum.AutomaticSize.Y},col)
        corner(sec,6); stroke(sec,C.border,1)

        local hdr=new("Frame",{BackgroundColor3=C.panel,BackgroundTransparency=0.2,BorderSizePixel=0,Size=UDim2.new(1,0,0,sc(30,s))},sec)
        corner(hdr,6)
        new("Frame",{BackgroundColor3=C.panel,BorderSizePixel=0,Size=UDim2.new(1,0,0,8),Position=UDim2.new(0,0,1,-8)},hdr)
        new("TextLabel",{BackgroundTransparency=1,
            Size=UDim2.new(1,-sc(16,s),1,0),Position=UDim2.fromOffset(sc(8,s),0),
            Font=Enum.Font.GothamBold,Text=tostring(sTitle or "Section"),
            TextSize=sc(12,s),TextXAlignment=Enum.TextXAlignment.Center,
            TextColor3=C.muted},hdr)

        new("Frame",{BackgroundColor3=C.border,BorderSizePixel=0,
            Size=UDim2.new(1,-sc(16,s),0,1),Position=UDim2.fromOffset(sc(8,s),sc(30,s))},sec)

        local cont=new("Frame",{Name="Container",BackgroundTransparency=1,
            Size=UDim2.new(1,-sc(16,s),0,0),Position=UDim2.fromOffset(sc(8,s),sc(36,s)),
            AutomaticSize=Enum.AutomaticSize.Y},sec)
        new("UIListLayout",{FillDirection=Enum.FillDirection.Vertical,
            SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,sc(6,s))},cont)
        pad(cont,0,0,sc(4,s),sc(8,s))

        local api={_cont=cont,_s=s,_win=win,_tabName=name,_sectionTitle=tostring(sTitle or "Section")}

        -- Toggle (switch style)
        function api:AddToggle(opts)
            opts=opts or {}
            local lbl=tostring(opts.Name or "Toggle")
            local state=opts.Default==true
            local showBind=opts.ShowBind==true
            local cb=opts.Callback
            local flag=tostring(opts.Flag or opts.Key or opts.Id or (api._tabName.."."..api._sectionTitle.."."..lbl))

            local row=new("Frame",{BackgroundTransparency=1,
                Size=UDim2.new(1,0,0,sc(26,s)),LayoutOrder=#cont:GetChildren()},cont)

            new("TextLabel",{BackgroundTransparency=1,
                Size=UDim2.new(1,-(sc(66,s)+(showBind and sc(66,s) or 0)),1,0),
                Position=UDim2.fromOffset(0,0),
                Font=Enum.Font.Gotham,Text=lbl,TextSize=sc(13,s),
                TextXAlignment=Enum.TextXAlignment.Left,TextColor3=C.text},row)

            local swW, swH = sc(44,s), sc(18,s)
            local sw=new("TextButton",{
                Name="Switch",
                AnchorPoint=Vector2.new(1,0.5),
                Position=UDim2.new(1, showBind and -sc(66,s) or 0, 0.5, 0),
                Size=UDim2.fromOffset(swW, swH),
                BackgroundColor3=state and C.toggleOn or C.toggleOff,
                BorderSizePixel=0,
                Text="",
                AutoButtonColor=false,
            },row)
            corner(sw, math.floor(swH/2))

            local knobSz = swH - sc(4,s)
            local knob=new("Frame",{
                Name="Knob",
                BackgroundColor3=Color3.fromRGB(240,240,240),
                BorderSizePixel=0,
                Size=UDim2.fromOffset(knobSz, knobSz),
                AnchorPoint=Vector2.new(0,0.5),
                Position=UDim2.new(state and 1 or 0, state and -(knobSz+sc(2,s)) or sc(2,s), 0.5, 0),
            },sw)
            corner(knob, math.floor(knobSz/2))

            local boundKey,waitBind=nil,false
            if showBind then
                local bb=new("TextButton",{BackgroundColor3=C.panel,BorderSizePixel=0,
                    AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,0,0.5,0),
                    Size=UDim2.fromOffset(sc(60,s),sc(20,s)),Text="",AutoButtonColor=false},row)
                corner(bb,4); stroke(bb,C.border,1)
                local bl=new("TextLabel",{BackgroundTransparency=1,Size=UDim2.fromScale(1,1),
                    Font=Enum.Font.Gotham,Text="NONE",TextSize=sc(11,s),TextColor3=C.muted},bb)
                onClick(bb,function() waitBind=true; bl.Text="..."; bl.TextColor3=C.text end)
                win:_track(UserInputService.InputBegan:Connect(function(inp,gp)
                    if gp then return end
                    if waitBind and inp.KeyCode~=Enum.KeyCode.Unknown then
                        boundKey=inp.KeyCode
                        bl.Text=inp.KeyCode.Name:upper()
                        bl.TextColor3=C.muted; waitBind=false
                    end
                    if boundKey and inp.KeyCode==boundKey then
                        state=not state
                        TweenService:Create(sw,TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundColor3=state and C.toggleOn or C.toggleOff}):Play()
                        TweenService:Create(knob,TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=UDim2.new(state and 1 or 0, state and -(knobSz+sc(2,s)) or sc(2,s), 0.5, 0)}):Play()
                        if typeof(cb)=="function" then task.spawn(cb,state) end
                    end
                end))
            end

            local function setState(v)
                state=v==true
                TweenService:Create(sw,TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundColor3=state and C.toggleOn or C.toggleOff}):Play()
                TweenService:Create(knob,TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=UDim2.new(state and 1 or 0, state and -(knobSz+sc(2,s)) or sc(2,s), 0.5, 0)}):Play()
                if typeof(cb)=="function" then task.spawn(cb,state) end
            end
            onClick(sw,function() setState(not state) end)

            local t={}
            function t:Set(v) setState(v) end
            function t:Get() return state end
            t.Flag = flag
            if opts.NoConfig ~= true then win:_registerControl(flag, t) end
            return t
        end

        -- Slider: instant snap, no tween on fill
        function api:AddSlider(opts)
            opts=opts or {}
            local lbl=tostring(opts.Name or "Slider")
            local min,max=opts.Min or 0,opts.Max or 100
            local val=math.clamp(opts.Default or min,min,max)
            local suffix=opts.Suffix or ""
            local cb=opts.Callback
            local flag=tostring(opts.Flag or opts.Key or opts.Id or (api._tabName.."."..api._sectionTitle.."."..lbl))

            local row=new("Frame",{BackgroundTransparency=1,
                Size=UDim2.new(1,0,0,sc(40,s)),LayoutOrder=#cont:GetChildren()},cont)

            new("TextLabel",{BackgroundTransparency=1,
                Size=UDim2.new(1,-sc(54,s),0,sc(16,s)),Font=Enum.Font.Gotham,
                Text=lbl,TextSize=sc(12,s),TextXAlignment=Enum.TextXAlignment.Left,
                TextColor3=C.text},row)

            local vLbl=new("TextLabel",{BackgroundTransparency=1,
                AnchorPoint=Vector2.new(1,0),Size=UDim2.fromOffset(sc(52,s),sc(16,s)),
                Position=UDim2.new(1,0,0,0),Font=Enum.Font.GothamMedium,
                Text=tostring(math.floor(val))..suffix,TextSize=sc(11,s),
                TextXAlignment=Enum.TextXAlignment.Right,TextColor3=C.accent},row)

            local track=new("TextButton",{BackgroundColor3=C.sliderBg,BorderSizePixel=0,
                Size=UDim2.new(1,0,0,sc(7,s)),Position=UDim2.fromOffset(0,sc(24,s)),
                AutoButtonColor=false,Text=""},row)
            corner(track,4); stroke(track,C.border,1)

            local pct0=(val-min)/(max-min)
            local fill=new("Frame",{BackgroundColor3=C.sliderFg,BorderSizePixel=0,
                Size=UDim2.new(pct0,0,1,0)},track)
            corner(fill,4)

            -- small round end cap (no drag circle, just a visual tip)
            local cap=new("Frame",{BackgroundColor3=C.sliderFg,BorderSizePixel=0,
                AnchorPoint=Vector2.new(0.5,0.5),
                Size=UDim2.fromOffset(sc(12,s),sc(12,s)),
                Position=UDim2.new(pct0,0,0.5,0)},track)
            corner(cap,sc(12,s))

            local dragging=false
            local function updateVal(absX)
                local pct=math.clamp((absX-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
                val=min+(max-min)*pct
                local r=math.floor(val+0.5)
                vLbl.Text=tostring(r)..suffix
                -- instant, no tween
                fill.Size=UDim2.new(pct,0,1,0)
                cap.Position=UDim2.new(pct,0,0.5,0)
                if typeof(cb)=="function" then task.spawn(cb,r) end
            end

            track.InputBegan:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                    dragging=true; updateVal(inp.Position.X)
                end
            end)
            track.InputChanged:Connect(function(inp)
                if not dragging then return end
                if inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch then
                    updateVal(inp.Position.X)
                end
            end)
            win:_track(UserInputService.InputChanged:Connect(function(inp)
                if not dragging then return end
                if inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch then
                    updateVal(inp.Position.X)
                end
            end))
            win:_track(UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                    dragging=false
                end
            end))

            local a={}
            function a:Set(v)
                val=math.clamp(v,min,max)
                local pct=(val-min)/(max-min)
                vLbl.Text=tostring(math.floor(val+0.5))..suffix
                fill.Size=UDim2.new(pct,0,1,0)
                cap.Position=UDim2.new(pct,0,0.5,0)
                if typeof(cb)=="function" then task.spawn(cb,math.floor(val+0.5)) end
            end
            function a:Get() return math.floor(val+0.5) end
            a.Flag = flag
            if opts.NoConfig ~= true then win:_registerControl(flag, a) end
            return a
        end

        -- Button
        function api:AddButton(opts)
            opts=opts or {}
            local lbl=tostring(opts.Name or "Button")
            local cb=opts.Callback

            local btn2=new("TextButton",{BackgroundColor3=C.btn,BorderSizePixel=0,
                Size=UDim2.new(1,0,0,sc(28,s)),Font=Enum.Font.GothamMedium,
                Text=lbl,TextSize=sc(12,s),TextColor3=C.text,AutoButtonColor=false,
                LayoutOrder=#cont:GetChildren()},cont)
            corner(btn2,5); stroke(btn2,C.border,1)

            onClick(btn2,function()
                TweenService:Create(btn2,TweenInfo.new(0.08),{BackgroundColor3=C.btnHov}):Play()
                task.delay(0.18,function()
                    TweenService:Create(btn2,TweenInfo.new(0.12),{BackgroundColor3=C.btn}):Play()
                end)
                if typeof(cb)=="function" then task.spawn(cb) end
            end)

            local a={}; function a:SetText(t) btn2.Text=t end; return a
        end

        -- TextBox
        function api:AddTextBox(opts)
            opts=opts or {}
            local lbl=tostring(opts.Name or "Input")
            local ph=tostring(opts.Placeholder or "Enter text...")
            local cb=opts.Callback
            local flag=tostring(opts.Flag or opts.Key or opts.Id or (api._tabName.."."..api._sectionTitle.."."..lbl))

            local row=new("Frame",{BackgroundTransparency=1,
                Size=UDim2.new(1,0,0,sc(46,s)),LayoutOrder=#cont:GetChildren()},cont)

            new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,sc(16,s)),
                Font=Enum.Font.Gotham,Text=lbl,TextSize=sc(12,s),
                TextXAlignment=Enum.TextXAlignment.Left,TextColor3=C.text},row)

            local box2=new("TextBox",{BackgroundColor3=C.input,BorderSizePixel=0,
                Size=UDim2.new(1,0,0,sc(26,s)),Position=UDim2.fromOffset(0,sc(18,s)),
                Font=Enum.Font.Gotham,PlaceholderText=ph,PlaceholderColor3=C.muted,
                Text=opts.Default or "",TextSize=sc(12,s),
                TextXAlignment=Enum.TextXAlignment.Left,TextColor3=C.text,
                ClearTextOnFocus=opts.ClearOnFocus~=false},row)
            corner(box2,4); stroke(box2,C.border,1); pad(box2,sc(8,s),sc(8,s),0,0)

            box2.FocusLost:Connect(function(enter)
                if enter and typeof(cb)=="function" then task.spawn(cb,box2.Text) end
            end)

            local a={}
            function a:Get() return box2.Text end
            function a:Set(t)
                box2.Text=tostring(t or "")
                if typeof(cb)=="function" then task.spawn(cb,box2.Text) end
            end
            a.Flag = flag
            if opts.NoConfig ~= true then win:_registerControl(flag, a) end
            return a
        end

        -- Label
        function api:AddLabel(opts)
            opts=opts or {}
            local lbl=new("TextLabel",{BackgroundTransparency=1,
                Size=UDim2.new(1,0,0,sc(18,s)),Font=Enum.Font.Gotham,
                Text=tostring(opts.Text or ""),TextSize=sc(12,s),
                TextXAlignment=Enum.TextXAlignment.Left,TextColor3=C.muted,
                LayoutOrder=#cont:GetChildren()},cont)

            local conn
            if typeof(opts.AutoUpdate)=="function" then
                local elapsed,interval=0,opts.Interval or 1
                conn=win:_track(RunService.Heartbeat:Connect(function(dt)
                    elapsed=elapsed+dt
                    if elapsed>=interval then elapsed=0
                        local ok,res=pcall(opts.AutoUpdate)
                        if ok then lbl.Text=tostring(res) end
                    end
                end))
            end

            local a={}
            function a:Set(t) lbl.Text=t end
            function a:Get() return lbl.Text end
            function a:StopAutoUpdate() if conn then conn:Disconnect() end end
            return a
        end

        -- Dropdown: click-only selection (no auto-pick while scrolling)
        function api:AddDropdown(opts)
            opts=opts or {}
            local lbl=tostring(opts.Name or "Dropdown")
            local items=opts.Items or {}
            local cb=opts.Callback
            local autoR=opts.AutoRefresh
            local sel=opts.Default or (items[1] or "None")
            local flag=tostring(opts.Flag or opts.Key or opts.Id or (api._tabName.."."..api._sectionTitle.."."..lbl))

            local wrapper=new("Frame",{BackgroundTransparency=1,
                Size=UDim2.new(1,0,0,sc(46,s)),
                ClipsDescendants=false,
                LayoutOrder=#cont:GetChildren(),ZIndex=5},cont)

            new("TextLabel",{BackgroundTransparency=1,
                Size=UDim2.new(1,0,0,sc(16,s)),
                Font=Enum.Font.Gotham,Text=lbl,TextSize=sc(12,s),
                TextXAlignment=Enum.TextXAlignment.Left,TextColor3=C.text,ZIndex=5},wrapper)

            -- dropdown field (older look: grey, no purple backgrounds)
            local db=new("TextButton",{BackgroundColor3=C.panel,BorderSizePixel=0,
                Position=UDim2.fromOffset(0,sc(18,s)),
                Size=UDim2.new(1,0,0,sc(26,s)),Font=Enum.Font.Gotham,
                Text=tostring(sel),TextSize=sc(12,s),
                TextXAlignment=Enum.TextXAlignment.Left,
                TextColor3=C.text,AutoButtonColor=false,ZIndex=5,ClipsDescendants=false},wrapper)
            corner(db,4); stroke(db,C.border,1)
            pad(db,sc(8,s),sc(28,s),0,0)

            -- up/down arrows (text)
            local arrows=new("Frame",{BackgroundTransparency=1,
                AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-sc(6,s),0.5,0),
                Size=UDim2.fromOffset(sc(16,s),sc(18,s)),ZIndex=6},db)
            local arrowUp=new("TextLabel",{BackgroundTransparency=1,
                Size=UDim2.new(1,0,0.5,0),Position=UDim2.new(0,0,0,-1),
                Font=Enum.Font.Gotham,Text="˄",TextSize=sc(12,s),
                TextColor3=C.muted,ZIndex=7,TextXAlignment=Enum.TextXAlignment.Center},arrows)
            local arrowDown=new("TextLabel",{BackgroundTransparency=1,
                Size=UDim2.new(1,0,0.5,0),Position=UDim2.new(0,0,0.5,-1),
                Font=Enum.Font.Gotham,Text="˅",TextSize=sc(12,s),
                TextColor3=C.muted,ZIndex=7,TextXAlignment=Enum.TextXAlignment.Center},arrows)

            local MAX_VIS=5
            local itemH=sc(26,s)
            local listScroll=new("ScrollingFrame",{
                Name="DropdownList",
                BackgroundColor3=C.input,BorderSizePixel=0,
                Position=UDim2.fromOffset(0,0),
                Size=UDim2.fromOffset(0,0),
                Visible=false,
                ZIndex=250,
                ClipsDescendants=true,
                ScrollBarThickness=sc(3,s),
                ScrollBarImageColor3=C.border,
                CanvasSize=UDim2.new(0,0,0,0),
                AutomaticCanvasSize=Enum.AutomaticSize.Y,
            },win._gui)
            corner(listScroll,4); stroke(listScroll,C.border,1)

            local ll=new("UIListLayout",{FillDirection=Enum.FillDirection.Vertical,
                SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,1)},listScroll)
            pad(listScroll,0,0,sc(2,s),sc(2,s))

            local open=false
            local rsConn
            local outsideConn

            local function pointIn(obj, x, y)
                if not obj or not obj.AbsoluteSize then return false end
                local p=obj.AbsolutePosition
                local sz=obj.AbsoluteSize
                return x>=p.X and x<=p.X+sz.X and y>=p.Y and y<=p.Y+sz.Y
            end

            local function closeDrop()
                if not open then return end
                open=false
                arrowUp.TextColor3=C.muted
                arrowDown.TextColor3=C.muted
                if rsConn then rsConn:Disconnect(); rsConn=nil end
                if outsideConn then outsideConn:Disconnect(); outsideConn=nil end
                TweenService:Create(listScroll,TweenInfo.new(0.15,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
                    {Size=UDim2.fromOffset(listScroll.AbsoluteSize.X,0)}):Play()
                task.delay(0.17,function() if listScroll then listScroll.Visible=false end end)
            end

            local function positionList()
                if not listScroll or not db then return end
                local pos=db.AbsolutePosition
                local size=db.AbsoluteSize
                listScroll.Position=UDim2.fromOffset(pos.X, pos.Y + size.Y + sc(4,s))
                listScroll.Size=UDim2.fromOffset(size.X, listScroll.AbsoluteSize.Y)
            end

            local function buildList(arr)
                for _,ch in ipairs(listScroll:GetChildren()) do
                    if ch:IsA("GuiObject") then ch:Destroy() end
                end
                for i,item in ipairs(arr) do
                    local ib=new("TextButton",{
                        BackgroundColor3=item==sel and C.btnHov or C.dropItem,
                        BackgroundTransparency=0,
                        BorderSizePixel=0,Size=UDim2.new(1,0,0,itemH),
                        Font=Enum.Font.Gotham,
                        Text=tostring(item),TextSize=sc(12,s),
                        TextXAlignment=Enum.TextXAlignment.Left,
                        TextColor3=C.text,
                        AutoButtonColor=false,ZIndex=251,LayoutOrder=i},listScroll)
                    pad(ib,sc(8,s),0,0,0)
                    -- Click-only select (matches sev.lua behavior)
                    onClick(ib,function()
                        sel=item
                        db.Text=tostring(sel)
                        closeDrop()
                        if typeof(cb)=="function" then task.spawn(cb,sel) end
                        buildList(arr)
                    end)
                end
            end

            local function toggleDrop()
                if open then
                    closeDrop()
                    return
                end

                open=true
                listScroll.Visible=true
                buildList(items)

                positionList()
                arrowUp.TextColor3=C.text
                arrowDown.TextColor3=C.muted

                task.defer(function()
                    local h2=math.min(ll.AbsoluteContentSize.Y,itemH*MAX_VIS+sc(6,s))
                    listScroll.Size=UDim2.fromOffset(db.AbsoluteSize.X,0)
                    TweenService:Create(listScroll,TweenInfo.new(0.15,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
                        {Size=UDim2.fromOffset(db.AbsoluteSize.X,h2)}):Play()
                end)

                rsConn = RunService.RenderStepped:Connect(function()
                    if open then positionList() end
                end)

                outsideConn = UserInputService.InputBegan:Connect(function(inp,gp)
                    if gp then return end
                    local pos = inp.Position
                    local x,y = pos.X,pos.Y
                    if pointIn(db,x,y) or pointIn(listScroll,x,y) then return end
                    closeDrop()
                end)
                win:_track(rsConn)
                win:_track(outsideConn)
            end
            onClick(db,toggleDrop)
            buildList(items)

            if typeof(autoR)=="function" then
                task.spawn(function()
                    while win._alive and task.wait(1) do
                        local ok,ni=pcall(autoR)
                        if ok and ni and typeof(ni)=="table" then 
                            items=ni
                            buildList(items)
                        end
                    end
                end)
            end

            local a={}
            function a:Get() return sel end
            function a:Set(v)
                sel=v
                db.Text=tostring(v)
                buildList(items)
                if typeof(cb)=="function" then task.spawn(cb,sel) end
            end
            function a:SetItems(t) items=t; buildList(items) end
            a.Flag = flag
            if opts.NoConfig ~= true then win:_registerControl(flag, a) end
            return a
        end

        return api
    end -- AddSection

    onClick(btn,function() tab:Select() end)
    table.insert(win._tabs,tab)
    if not win._active then tab:Select() end
    return tab
end

function Library:_ensureSettingsTab()
    if self._settingsTabCreated then return end
    self._settingsTabCreated = true

    local tab = self:AddTab({Name="Settings"})

    local prefs = tab:AddSection("Preferences", "Left")
    prefs:AddToggle({
        Name = "Streamer Mode",
        Default = false,
        Flag = "Settings.StreamerMode",
        Callback = function(v)
            self:SetStreamerMode(v)
        end,
    })

    local cfgSec = tab:AddSection("Configs", "Left")
    local nameBox = cfgSec:AddTextBox({
        Name = "Config Name",
        Default = "",
        Placeholder = "default",
        NoConfig = true,
    })

    local cfgDrop = cfgSec:AddDropdown({
        Name = "Saved Configs",
        Items = self:GetConfigList(),
        AutoRefresh = function() return self:GetConfigList() end,
        Default = (self:GetConfigList()[1] or "None"),
        NoConfig = true,
    })

    local function getSaveName()
        return _sanitizeConfigName(nameBox:Get())
    end

    local function getLoadName()
        local d = tostring(cfgDrop:Get() or "")
        if d ~= "" and d:lower() ~= "none" then
            return _sanitizeConfigName(d)
        end
        return _sanitizeConfigName(nameBox:Get())
    end

    cfgSec:AddButton({
        Name = "Save Config",
        Callback = function()
            self:SaveConfig(getSaveName())
            cfgDrop:SetItems(self:GetConfigList())
        end,
    })

    cfgSec:AddButton({
        Name = "Load Config",
        Callback = function()
            self:LoadConfig(getLoadName())
        end,
    })

    cfgSec:AddButton({
        Name = "Delete Config",
        Callback = function()
            self:DeleteConfig(getLoadName())
            cfgDrop:SetItems(self:GetConfigList())
        end,
    })
end

return Library
