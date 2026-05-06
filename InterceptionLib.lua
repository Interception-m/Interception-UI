local Library = {}

local Mouse = game.Players.LocalPlayer:GetMouse()

-- Helpers
local charW = 5.5 -- character width for current font (Monospace/JetBrains)
local fontCharWidths = {
    [Drawing.Fonts.UI] = 6.5,
    [Drawing.Fonts.System] = 6.2,
    [Drawing.Fonts.SystemBold] = 6.5,
    [Drawing.Fonts.Minecraft] = 6.5,
    [Drawing.Fonts.Monospace] = 5.5,
    [Drawing.Fonts.Pixel] = 6,
    [Drawing.Fonts.Fortnite] = 7,
}
local function rightAlignX(text, panelPos, panelWidth)
    return panelPos.X + panelWidth - (#text * charW) - 10
end

local function hsvToRgb(h, s, v)
    local c = v * s
    local x = c * (1 - math.abs((h / 60) % 2 - 1))
    local m = v - c
    local r, g, b
    if h < 60 then r,g,b = c,x,0
    elseif h < 120 then r,g,b = x,c,0
    elseif h < 180 then r,g,b = 0,c,x
    elseif h < 240 then r,g,b = 0,x,c
    elseif h < 300 then r,g,b = x,0,c
    else r,g,b = c,0,x end
    return (r+m), (g+m), (b+m)
end

local function rgbToHsv(r, g, b)
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local d = max - min
    local h, s, v
    v = max
    if max == 0 then s = 0 else s = d / max end
    if d == 0 then
        h = 0
    elseif max == r then
        h = 60 * (((g - b) / d) % 6)
    elseif max == g then
        h = 60 * (((b - r) / d) + 2)
    else
        h = 60 * (((r - g) / d) + 4)
    end
    return h, s, v
end

local function isInside(mPos, pos, size)
    return mPos.X >= pos.X and mPos.X <= pos.X + size.X and mPos.Y >= pos.Y and mPos.Y <= pos.Y + size.Y
end

local KeyNames = {
    [48] = "0", [49] = "1", [50] = "2", [51] = "3", [52] = "4",
    [53] = "5", [54] = "6", [55] = "7", [56] = "8", [57] = "9",
    [1] = "M1", [2] = "M2", [4] = "M3", [5] = "M4", [6] = "M5",
    [8] = "Backspace", [9] = "Tab", [13] = "Enter",
    [16] = "Shift", [17] = "Ctrl", [18] = "Alt",
    [19] = "Pause", [20] = "CapsLock", [27] = "Esc",
    [32] = "Space", [33] = "PageUp", [34] = "PageDown",
    [35] = "End", [36] = "Home",
    [37] = "Left", [38] = "Up", [39] = "Right", [40] = "Down",
    [45] = "Insert", [46] = "Delete",
    [65] = "A", [66] = "B", [67] = "C", [68] = "D", [69] = "E",
    [70] = "F", [71] = "G", [72] = "H", [73] = "I", [74] = "J",
    [75] = "K", [76] = "L", [77] = "M", [78] = "N", [79] = "O",
    [80] = "P", [81] = "Q", [82] = "R", [83] = "S", [84] = "T",
    [85] = "U", [86] = "V", [87] = "W", [88] = "X", [89] = "Y", [90] = "Z",
    [112] = "F1", [113] = "F2", [114] = "F3", [115] = "F4",
    [116] = "F5", [117] = "F6", [118] = "F7", [119] = "F8",
    [120] = "F9", [121] = "F10", [122] = "F11", [123] = "F12",
}


local modeLabels = {always = "Always On", toggle = "Toggle", hold = "Hold"}

function Library:CreateWindow(opts)
    opts = opts or {}
    local title = "I n t e r c e p t i o n"
    local menuKey = opts.Key or 35
    local configPath = "INTERCEPTION"
    local gameName = opts.Game or ""

    local viewportSize = workspace.CurrentCamera.ViewportSize
    local bgPos = Vector2.new(math.floor((viewportSize.X - 550) / 2), math.floor((viewportSize.Y - 600) / 2))

    -- Text tracking for SetFont
    local allTextDrawings = {}
    local function newText(tag)
        local t = Drawing.new("Text")
        allTextDrawings[#allTextDrawings+1] = {drawing = t, tag = tag or "widget"}
        return t
    end

    -- Glow
    local glowLayers = {}
    local glowSpreads = {}
    for i = 1, 12 do
        local t = i / 12
        local spread = math.floor(20 * t + 0.5)
        local glow = Drawing.new("Square")
        glow.Visible = true; glow.Transparency = 0.018 * (1 - t); glow.ZIndex = 1
        glow.Color = Color3.fromHex("#FFFFFF")
        glow.Position = Vector2.new(bgPos.X - spread, bgPos.Y - spread)
        glow.Size = Vector2.new(550 + spread * 2, 600 + spread * 2)
        glow.Filled = true; glow.Corner = 6 + spread
        glowLayers[i] = glow; glowSpreads[i] = spread
    end

    -- BG
    local BG = Drawing.new("Square")
    BG.Visible = true; BG.Transparency = 1; BG.ZIndex = 10
    BG.Color = Color3.fromHex("#050505"); BG.Position = bgPos
    BG.Size = Vector2.new(550, 600); BG.Filled = true; BG.Corner = 6

    local BG_Border = Drawing.new("Square")
    BG_Border.Visible = true; BG_Border.Transparency = 1; BG_Border.ZIndex = 11
    BG_Border.Color = Color3.fromHex("#282828"); BG_Border.Filled = false; BG_Border.Thickness = 2
    BG_Border.Position = BG.Position; BG_Border.Size = BG.Size; BG_Border.Corner = 6

    -- Title bar
    local Title1 = Drawing.new("Square")
    Title1.Visible = true; Title1.Transparency = 1; Title1.ZIndex = 20
    Title1.Color = Color3.fromHex("#0a0a0a")
    Title1.Position = BG.Position + Vector2.new(2, 2)
    Title1.Size = Vector2.new(546, 30); Title1.Filled = true; Title1.Corner = 6

    local TitleText = newText("title")
    TitleText.Visible = true; TitleText.Transparency = 1; TitleText.ZIndex = 30
    TitleText.Color = Color3.fromHex("#FFFFFF")
    TitleText.Position = Title1.Position + Vector2.new(8, 6)
    TitleText.Text = title; TitleText.Size = 14; TitleText.Center = false
    TitleText.Outline = true; TitleText.Font = Drawing.Fonts.SystemBold

    -- Shared RC Menu
    local RCMenu = Drawing.new("Square")
    RCMenu.Visible = false; RCMenu.Transparency = 1; RCMenu.ZIndex = 600
    RCMenu.Color = Color3.fromHex("#0a0a0a"); RCMenu.Position = Vector2.new(0,0)
    RCMenu.Size = Vector2.new(70, 60); RCMenu.Filled = true; RCMenu.Corner = 6

    local RCMenu_Border = Drawing.new("Square")
    RCMenu_Border.Visible = false; RCMenu_Border.Transparency = 1; RCMenu_Border.ZIndex = 601
    RCMenu_Border.Color = Color3.fromHex("#282828"); RCMenu_Border.Filled = false; RCMenu_Border.Thickness = 1
    RCMenu_Border.Position = Vector2.new(0,0); RCMenu_Border.Size = Vector2.new(70, 60); RCMenu_Border.Corner = 6

    local RCAlways = newText()
    RCAlways.Visible = false; RCAlways.Transparency = 1; RCAlways.ZIndex = 610
    RCAlways.Color = Color3.fromHex("#FFFFFF"); RCAlways.Position = Vector2.new(0,0)
    RCAlways.Text = "Always On"; RCAlways.Size = 12; RCAlways.Center = false
    RCAlways.Outline = true; RCAlways.Font = Drawing.Fonts.Monospace

    local RCToggle = newText()
    RCToggle.Visible = false; RCToggle.Transparency = 1; RCToggle.ZIndex = 610
    RCToggle.Color = Color3.fromHex("#505050"); RCToggle.Position = Vector2.new(0,0)
    RCToggle.Text = "Toggle"; RCToggle.Size = 12; RCToggle.Center = false
    RCToggle.Outline = true; RCToggle.Font = Drawing.Fonts.Monospace

    local RCHold = newText()
    RCHold.Visible = false; RCHold.Transparency = 1; RCHold.ZIndex = 610
    RCHold.Color = Color3.fromHex("#505050"); RCHold.Position = Vector2.new(0,0)
    RCHold.Text = "Hold"; RCHold.Size = 12; RCHold.Center = false
    RCHold.Outline = true; RCHold.Font = Drawing.Fonts.Monospace

    -- Window state
    local menuOpen = true
    local lastMenuKey = false
    local dragging = nil
    local dragStart = nil
    local startBGPos = nil
    local lastMouse1 = false
    local lastMouse2 = false
    local rcMenuOpen = false
    local rcMenuTarget = nil
    local activeTab = 1

    -- All tabs data
    local tabs = {}
    local tabLabels = {}
    local tabXOffsets = {} -- computed dynamically in Start()
    local allKeybinds = {} -- {bindText, panelPos, panelWidth, yPos, keyVar, modeVar, listening, toggleRef, nameText, isStandalone, callback}
    local allColorpickers = {} -- each CP data
    local allSliders = {}
    local allRangeSliders = {}
    local allDropdowns = {}
    local allSelects = {}
    local allMultiDropdowns = {}
    local allMultiSelects = {}
    local allToggles = {}
    local configWidgets = {} -- {name, get, set} for config save/load
    local allInfoPanels = {}

    -- Hotkey list
    local hotkeyListOn = false
    local hkDragging = false
    local hkDragStart = nil
    local hkStartPos = nil
    local Icon = nil
    local iconLoaded = false

    local hkPanelPos = Vector2.new(BG.Position.X - 230, BG.Position.Y)
    local HotkeyBG = Drawing.new("Square")
    HotkeyBG.Visible = false; HotkeyBG.Transparency = 1; HotkeyBG.ZIndex = 700
    HotkeyBG.Color = Color3.fromHex("#050505"); HotkeyBG.Position = hkPanelPos
    HotkeyBG.Size = Vector2.new(220, 32); HotkeyBG.Filled = true; HotkeyBG.Corner = 6

    local HotkeyBG_Border = Drawing.new("Square")
    HotkeyBG_Border.Visible = false; HotkeyBG_Border.Transparency = 1; HotkeyBG_Border.ZIndex = 701
    HotkeyBG_Border.Color = Color3.fromHex("#282828"); HotkeyBG_Border.Filled = false; HotkeyBG_Border.Thickness = 1
    HotkeyBG_Border.Position = hkPanelPos; HotkeyBG_Border.Size = Vector2.new(220, 32); HotkeyBG_Border.Corner = 6

    local HotkeyTitleBG = Drawing.new("Square")
    HotkeyTitleBG.Visible = false; HotkeyTitleBG.Transparency = 1; HotkeyTitleBG.ZIndex = 710
    HotkeyTitleBG.Color = Color3.fromHex("#0a0a0a")
    HotkeyTitleBG.Position = hkPanelPos + Vector2.new(1, 1)
    HotkeyTitleBG.Size = Vector2.new(218, 30); HotkeyTitleBG.Filled = true; HotkeyTitleBG.Corner = 6

    local HotkeyTitle = newText()
    HotkeyTitle.Visible = false; HotkeyTitle.Transparency = 1; HotkeyTitle.ZIndex = 720
    HotkeyTitle.Color = Color3.fromHex("#FFFFFF")
    HotkeyTitle.Position = hkPanelPos + Vector2.new(40, 8)
    HotkeyTitle.Text = "Hotkeys"; HotkeyTitle.Size = 14; HotkeyTitle.Center = false
    HotkeyTitle.Outline = true; HotkeyTitle.Font = Drawing.Fonts.Monospace

    local hkEntries = {} -- {nameDrawing, modeDrawing, getVisible, getActive, getMode, getName}

    local function updateHotkeyList()
        local yOff = 37
        local entryCount = 0
        for _, entry in ipairs(hkEntries) do
            local vis = entry.getVisible()
            entry.nameDrawing.Visible = hotkeyListOn and vis
            entry.modeDrawing.Visible = hotkeyListOn and vis
            if vis then
                local active = entry.getActive()
                local color = active and Color3.fromHex("#FFFFFF") or Color3.fromHex("#505050")
                entry.nameDrawing.Color = color
                entry.modeDrawing.Color = color
                local modeText = "[" .. (modeLabels[entry.getMode()] or "Always On") .. "]"
                entry.modeDrawing.Text = modeText
                entry.nameDrawing.Position = HotkeyBG.Position + Vector2.new(10, yOff)
                entry.modeDrawing.Position = Vector2.new(HotkeyBG.Position.X + 214 - #modeText * 6.7, HotkeyBG.Position.Y + yOff)
                yOff = yOff + 20
                entryCount = entryCount + 1
            end
        end
        local panelH = entryCount > 0 and (30 + entryCount * 20 + 8) or 32
        HotkeyBG.Size = Vector2.new(220, panelH)
        HotkeyBG_Border.Size = Vector2.new(220, panelH)
    end

    local function toggleHotkeyList(show)
        hotkeyListOn = show
        HotkeyBG.Visible = show
        HotkeyBG_Border.Visible = show
        HotkeyTitleBG.Visible = show
        HotkeyTitle.Visible = show
        if show and not iconLoaded then
            iconLoaded = true
            task.spawn(function()
                local ok, data = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/Interception-m/Interception-UI/refs/heads/main/keyboard.png")
                if not ok then
                    warn("[InterceptionLib] icon HttpGet failed:", data)
                    return
                end
                if not data or #data == 0 then
                    warn("[InterceptionLib] icon HttpGet returned empty data")
                    return
                end
                Icon = Drawing.new("Image")
                Icon.Position = HotkeyBG.Position + Vector2.new(10, 7)
                Icon.Size = Vector2.new(18, 18)
                Icon.Transparency = 1
                Icon.ZIndex = 720
                Icon.Data = data
                Icon.Visible = hotkeyListOn
            end)
        end
        if Icon then Icon.Visible = show end
        if show then
            updateHotkeyList()
        else
            for _, entry in ipairs(hkEntries) do
                entry.nameDrawing.Visible = false
                entry.modeDrawing.Visible = false
            end
        end
    end

    local function updateHKPositions()
        HotkeyBG_Border.Position = HotkeyBG.Position
        HotkeyTitleBG.Position = HotkeyBG.Position + Vector2.new(1, 1)
        if Icon then Icon.Position = HotkeyBG.Position + Vector2.new(10, 7) end
        HotkeyTitle.Position = HotkeyBG.Position + Vector2.new(40, 8)
        updateHotkeyList()
    end

    -- RC Menu helpers
    local function showRCMenu(pos, target)
        rcMenuOpen = true; rcMenuTarget = target
        RCMenu.Position = pos; RCMenu_Border.Position = pos
        RCAlways.Position = pos + Vector2.new(7, 7)
        RCToggle.Position = pos + Vector2.new(7, 24)
        RCHold.Position = pos + Vector2.new(7, 41)
        local mode = target.mode
        RCAlways.Color = (mode == "always") and Color3.fromHex("#FFFFFF") or Color3.fromHex("#505050")
        RCToggle.Color = (mode == "toggle") and Color3.fromHex("#FFFFFF") or Color3.fromHex("#505050")
        RCHold.Color = (mode == "hold") and Color3.fromHex("#FFFFFF") or Color3.fromHex("#505050")
        RCMenu.Visible = true; RCMenu_Border.Visible = true
        RCAlways.Visible = true; RCToggle.Visible = true; RCHold.Visible = true
    end

    local function hideRCMenu()
        rcMenuOpen = false; rcMenuTarget = nil
        RCMenu.Visible = false; RCMenu_Border.Visible = false
        RCAlways.Visible = false; RCToggle.Visible = false; RCHold.Visible = false
    end

    -- Colorpicker helpers (shared)
    local openCP = nil

    local function toggleCP(cpData, show)
        if not show and openCP == cpData then openCP = nil end
        if show then
            if openCP and openCP ~= cpData then
                -- close old one
                openCP.toggle(false)
            end
            openCP = cpData
        end
        cpData.toggle(show)
    end

    local function createColorpickerPopup(colorPreview, cpBorder, defaultColor, colorCallback, cpName)
        local cpH, cpS, cpV = rgbToHsv(defaultColor.R, defaultColor.G, defaultColor.B)
        local cpAnchor = colorPreview.Position + Vector2.new(20, 0)

        local CPBG = Drawing.new("Square")
        CPBG.Visible = false; CPBG.Transparency = 1; CPBG.ZIndex = 500
        CPBG.Color = Color3.fromHex("#0a0a0a"); CPBG.Position = cpAnchor
        CPBG.Size = Vector2.new(170, 220); CPBG.Filled = true; CPBG.Corner = 6

        local CPBG_Border = Drawing.new("Square")
        CPBG_Border.Visible = false; CPBG_Border.Transparency = 1; CPBG_Border.ZIndex = 501
        CPBG_Border.Color = Color3.fromHex("#282828"); CPBG_Border.Filled = false; CPBG_Border.Thickness = 1
        CPBG_Border.Position = cpAnchor; CPBG_Border.Size = Vector2.new(170, 220); CPBG_Border.Corner = 6

        local CPTitle = newText("cptitle")
        CPTitle.Visible = false; CPTitle.Transparency = 1; CPTitle.ZIndex = 510
        CPTitle.Color = Color3.fromHex("#FFFFFF")
        CPTitle.Position = cpAnchor + Vector2.new(10, 5)
        CPTitle.Text = cpName or "Color"; CPTitle.Size = 14; CPTitle.Center = false
        CPTitle.Outline = true; CPTitle.Font = Drawing.Fonts.SystemBold

        local SVArea = Drawing.new("Square")
        SVArea.Visible = false; SVArea.Transparency = 1; SVArea.ZIndex = 520
        SVArea.Color = Color3.new(1, 0, 0)
        SVArea.Position = cpAnchor + Vector2.new(10, 25)
        SVArea.Size = Vector2.new(150, 110); SVArea.Filled = true

        local SVArea_Border = Drawing.new("Square")
        SVArea_Border.Visible = false; SVArea_Border.Transparency = 1; SVArea_Border.ZIndex = 523
        SVArea_Border.Color = Color3.fromHex("#282828"); SVArea_Border.Filled = false; SVArea_Border.Thickness = 1
        SVArea_Border.Position = cpAnchor + Vector2.new(10, 25); SVArea_Border.Size = Vector2.new(150, 110)

        local whiteStrips = {}
        for i = 1, 50 do
            local strip = Drawing.new("Square")
            strip.Visible = false; strip.Transparency = 1 - ((i - 1) / 50); strip.ZIndex = 521
            strip.Color = Color3.new(1, 1, 1)
            strip.Position = cpAnchor + Vector2.new(10 + (i - 1) * 3, 25)
            strip.Size = Vector2.new(3, 110); strip.Filled = true
            whiteStrips[i] = strip
        end

        local blackStrips = {}
        for i = 1, 55 do
            local strip = Drawing.new("Square")
            strip.Visible = false; strip.Transparency = i / 55; strip.ZIndex = 522
            strip.Color = Color3.new(0, 0, 0)
            strip.Position = cpAnchor + Vector2.new(10, 25 + (i - 1) * 2)
            strip.Size = Vector2.new(150, 2); strip.Filled = true
            blackStrips[i] = strip
        end

        local HueBG = Drawing.new("Square")
        HueBG.Visible = false; HueBG.Transparency = 1; HueBG.ZIndex = 529
        HueBG.Color = Color3.fromHex("#0a0a0a")
        HueBG.Position = cpAnchor + Vector2.new(10, 145)
        HueBG.Size = Vector2.new(150, 15); HueBG.Filled = true

        local HueBG_Border = Drawing.new("Square")
        HueBG_Border.Visible = false; HueBG_Border.Transparency = 1; HueBG_Border.ZIndex = 531
        HueBG_Border.Color = Color3.fromHex("#282828"); HueBG_Border.Filled = false; HueBG_Border.Thickness = 1
        HueBG_Border.Position = cpAnchor + Vector2.new(10, 145); HueBG_Border.Size = Vector2.new(150, 15)

        local hueSegments = {}
        for i = 1, 150 do
            local seg = Drawing.new("Square")
            seg.Visible = false; seg.Transparency = 1; seg.ZIndex = 530
            local hh = (i - 1) / 149 * 360
            local rr, gg, bb = hsvToRgb(hh, 1, 1)
            seg.Color = Color3.new(rr, gg, bb)
            seg.Position = cpAnchor + Vector2.new(10 + (i - 1), 145)
            seg.Size = Vector2.new(1, 15); seg.Filled = true
            hueSegments[i] = seg
        end

        local BrightBG = Drawing.new("Square")
        BrightBG.Visible = false; BrightBG.Transparency = 1; BrightBG.ZIndex = 539
        BrightBG.Color = Color3.fromHex("#0a0a0a")
        BrightBG.Position = cpAnchor + Vector2.new(10, 170)
        BrightBG.Size = Vector2.new(150, 15); BrightBG.Filled = true

        local BrightBG_Border = Drawing.new("Square")
        BrightBG_Border.Visible = false; BrightBG_Border.Transparency = 1; BrightBG_Border.ZIndex = 541
        BrightBG_Border.Color = Color3.fromHex("#282828"); BrightBG_Border.Filled = false; BrightBG_Border.Thickness = 1
        BrightBG_Border.Position = cpAnchor + Vector2.new(10, 170); BrightBG_Border.Size = Vector2.new(150, 15)

        local brightSegments = {}
        for i = 1, 150 do
            local seg = Drawing.new("Square")
            seg.Visible = false; seg.Transparency = 1; seg.ZIndex = 540
            local vv = (i - 1) / 149
            local rr, gg, bb = hsvToRgb(0, 1, vv)
            seg.Color = Color3.new(rr, gg, bb)
            seg.Position = cpAnchor + Vector2.new(10 + (i - 1), 170)
            seg.Size = Vector2.new(1, 15); seg.Filled = true
            brightSegments[i] = seg
        end

        local SVSelector = Drawing.new("Square")
        SVSelector.Visible = false; SVSelector.Transparency = 1; SVSelector.ZIndex = 560
        SVSelector.Color = Color3.fromHex("#404040"); SVSelector.Position = cpAnchor + Vector2.new(150, 25)
        SVSelector.Size = Vector2.new(10, 10); SVSelector.Filled = false; SVSelector.Thickness = 2; SVSelector.Corner = 2

        local HueSlider = Drawing.new("Square")
        HueSlider.Visible = false; HueSlider.Transparency = 1; HueSlider.ZIndex = 560
        HueSlider.Color = Color3.fromHex("#282828"); HueSlider.Position = cpAnchor + Vector2.new(10, 142)
        HueSlider.Size = Vector2.new(5, 20); HueSlider.Filled = true; HueSlider.Corner = 2

        local BrightSlider = Drawing.new("Square")
        BrightSlider.Visible = false; BrightSlider.Transparency = 1; BrightSlider.ZIndex = 560
        BrightSlider.Color = Color3.fromHex("#282828"); BrightSlider.Position = cpAnchor + Vector2.new(10, 168)
        BrightSlider.Size = Vector2.new(5, 20); BrightSlider.Filled = true; BrightSlider.Corner = 2

        -- Hex input bar (replaces Copy/Paste buttons). Click to focus, type hex,
        -- Enter to commit, Escape to cancel. Live updates color on valid 3/6 hex.
        local HexBG = Drawing.new("Square")
        HexBG.Visible = false; HexBG.Transparency = 1; HexBG.ZIndex = 550
        HexBG.Color = Color3.fromHex("#0a0a0a"); HexBG.Position = cpAnchor + Vector2.new(10, 192)
        HexBG.Size = Vector2.new(150, 20); HexBG.Filled = true; HexBG.Corner = 6

        local HexBG_Border = Drawing.new("Square")
        HexBG_Border.Visible = false; HexBG_Border.Transparency = 1; HexBG_Border.ZIndex = 551
        HexBG_Border.Color = Color3.fromHex("#282828"); HexBG_Border.Filled = false; HexBG_Border.Thickness = 1
        HexBG_Border.Position = cpAnchor + Vector2.new(10, 192); HexBG_Border.Size = Vector2.new(150, 20); HexBG_Border.Corner = 6

        local HexText = newText()
        HexText.Visible = false; HexText.Transparency = 1; HexText.ZIndex = 555
        HexText.Color = Color3.fromHex("#FFFFFF"); HexText.Position = cpAnchor + Vector2.new(15, 194)
        HexText.Text = "#000000"; HexText.Size = 14; HexText.Center = false
        HexText.Outline = true; HexText.Font = Drawing.Fonts.Monospace

        local allCPElements = {CPBG, CPBG_Border, CPTitle, SVArea, SVArea_Border, SVSelector, HueSlider, BrightSlider, HueBG, HueBG_Border, BrightBG, BrightBG_Border, HexBG, HexBG_Border, HexText}

        local function updateCPPositions()
            cpAnchor = colorPreview.Position + Vector2.new(20, 0)
            CPBG.Position = cpAnchor; CPBG_Border.Position = cpAnchor
            CPTitle.Position = cpAnchor + Vector2.new(10, 5)
            SVArea.Position = cpAnchor + Vector2.new(10, 25)
            SVArea_Border.Position = cpAnchor + Vector2.new(10, 25)
            for i = 1, 50 do whiteStrips[i].Position = cpAnchor + Vector2.new(10 + (i - 1) * 3, 25) end
            for i = 1, 55 do blackStrips[i].Position = cpAnchor + Vector2.new(10, 25 + (i - 1) * 2) end
            HueBG.Position = cpAnchor + Vector2.new(10, 145); HueBG_Border.Position = cpAnchor + Vector2.new(10, 145)
            BrightBG.Position = cpAnchor + Vector2.new(10, 170); BrightBG_Border.Position = cpAnchor + Vector2.new(10, 170)
            for i = 1, 150 do
                hueSegments[i].Position = cpAnchor + Vector2.new(10 + (i - 1), 145)
                brightSegments[i].Position = cpAnchor + Vector2.new(10 + (i - 1), 170)
            end
            SVSelector.Position = cpAnchor + Vector2.new(10 + cpS * 140, 25 + (1 - cpV) * 100)
            HueSlider.Position = cpAnchor + Vector2.new(10 + (cpH / 360) * 145, 142)
            BrightSlider.Position = cpAnchor + Vector2.new(10 + cpV * 145, 168)
            HexBG.Position = cpAnchor + Vector2.new(10, 192); HexBG_Border.Position = cpAnchor + Vector2.new(10, 192)
            HexText.Position = cpAnchor + Vector2.new(15, 194)
        end

        local function refreshHexDisplay()
            -- When focused, HexText shows what user is typing; otherwise current color.
            if not cpData or not cpData.hexFocused then
                local fr, fg, fb = hsvToRgb(cpH, cpS, cpV)
                HexText.Text = string.format("#%02X%02X%02X",
                    math.floor(fr*255+0.5), math.floor(fg*255+0.5), math.floor(fb*255+0.5))
            end
        end

        local function updateCPColor(source)
            local r, g, b = hsvToRgb(cpH, 1, 1)
            SVArea.Color = Color3.new(r, g, b)
            for i = 1, 150 do
                local vv = (i - 1) / 149
                local br, bg, bb = hsvToRgb(cpH, 1, vv)
                brightSegments[i].Color = Color3.new(br, bg, bb)
            end
            if source ~= "bright" then
                SVSelector.Position = cpAnchor + Vector2.new(10 + cpS * 140, 25 + (1 - cpV) * 100)
            end
            if source ~= "sv" then
                HueSlider.Position = cpAnchor + Vector2.new(10 + (cpH / 360) * 145, 142)
                BrightSlider.Position = cpAnchor + Vector2.new(10 + cpV * 145, 168)
            end
            local fr, fg, fb = hsvToRgb(cpH, cpS, cpV)
            colorPreview.Color = Color3.new(fr, fg, fb)
            colorCallback(Color3.new(fr, fg, fb))
            refreshHexDisplay()
        end

        local cpData = {
            cpOpen = false, cpDrag = nil, cpH = cpH, cpS = cpS, cpV = cpV,
            colorPreview = colorPreview, cpBorder = cpBorder,
            SVArea = SVArea, hueSegments = hueSegments, brightSegments = brightSegments,
            CPBG = CPBG, HexBG = HexBG, HexBG_Border = HexBG_Border, HexText = HexText,
            hexFocused = false, hexBuffer = "",
            updatePositions = updateCPPositions, updateColor = updateCPColor,
            refreshHex = refreshHexDisplay,
        }

        cpData.setHSV = function(h, s, v)
            cpH = h; cpS = s; cpV = v
            cpData.cpH = h; cpData.cpS = s; cpData.cpV = v
            -- Full visual refresh: SVArea hue gradient, brightness gradient,
            -- SV/hue/brightness selector positions, color preview, callback, hex text.
            updateCPColor()
        end

        cpData.commitHex = function(applyOnly)
            -- Parse cpData.hexBuffer (3 or 6 hex digits, with/without #) and apply.
            -- If applyOnly is false (default), also exits focused mode.
            local s = (cpData.hexBuffer or ""):gsub("^#", "")
            local rr, gg, bb
            if #s == 6 and s:match("^%x%x%x%x%x%x$") then
                rr = tonumber(s:sub(1,2), 16) / 255
                gg = tonumber(s:sub(3,4), 16) / 255
                bb = tonumber(s:sub(5,6), 16) / 255
            elseif #s == 3 and s:match("^%x%x%x$") then
                rr = tonumber(s:sub(1,1):rep(2), 16) / 255
                gg = tonumber(s:sub(2,2):rep(2), 16) / 255
                bb = tonumber(s:sub(3,3):rep(2), 16) / 255
            end
            if rr then
                local h, sa, va = rgbToHsv(rr, gg, bb)
                cpData.setHSV(h, sa, va)
                local fr, fg, fb = hsvToRgb(h, sa, va)
                colorCallback(Color3.new(fr, fg, fb))
            end
            if not applyOnly then
                cpData.hexFocused = false
                cpData.hexBuffer = ""
                HexBG_Border.Color = Color3.fromHex("#282828")
                refreshHexDisplay()
            end
        end

        cpData.toggle = function(show)
            cpData.cpOpen = show
            if not show and cpData.hexFocused then
                cpData.hexFocused = false
                cpData.hexBuffer = ""
                HexBG_Border.Color = Color3.fromHex("#282828")
            end
            for _, el in ipairs(allCPElements) do el.Visible = show end
            for i = 1, 50 do whiteStrips[i].Visible = show end
            for i = 1, 55 do blackStrips[i].Visible = show end
            for i = 1, 150 do hueSegments[i].Visible = show; brightSegments[i].Visible = show end
            if show then updateCPPositions(); updateCPColor() end
        end

        cpData.handleClick = function(mPos, pressed)
            if pressed and isInside(mPos, colorPreview.Position, colorPreview.Size) then
                toggleCP(cpData, not cpData.cpOpen); return true
            end
            if cpData.cpOpen and pressed then
                if isInside(mPos, SVArea.Position, SVArea.Size) then
                    cpData.cpDrag = "sv"
                    cpS = math.clamp((mPos.X - SVArea.Position.X) / 150, 0, 1)
                    cpV = 1 - math.clamp((mPos.Y - SVArea.Position.Y) / 110, 0, 1)
                    cpData.cpS = cpS; cpData.cpV = cpV
                    cpH = cpData.cpH; updateCPColor("sv"); return true
                elseif isInside(mPos, hueSegments[1].Position, Vector2.new(150, 15)) then
                    cpData.cpDrag = "hue"
                    cpH = math.clamp((mPos.X - hueSegments[1].Position.X) / 150, 0, 1) * 360
                    cpData.cpH = cpH; cpS = cpData.cpS; cpV = cpData.cpV; updateCPColor("hue"); return true
                elseif isInside(mPos, brightSegments[1].Position, Vector2.new(150, 15)) then
                    cpData.cpDrag = "bright"
                    cpV = math.clamp((mPos.X - brightSegments[1].Position.X) / 150, 0, 1)
                    cpData.cpV = cpV; cpH = cpData.cpH; cpS = cpData.cpS; updateCPColor("bright"); return true
                elseif isInside(mPos, HexBG.Position, HexBG.Size) then
                    -- Focus hex bar; pre-fill buffer with current color so user can
                    -- edit relative to it instead of starting blank.
                    if not cpData.hexFocused then
                        cpData.hexFocused = true
                        local fr, fg, fb = hsvToRgb(cpData.cpH, cpData.cpS, cpData.cpV)
                        cpData.hexBuffer = string.format("#%02X%02X%02X",
                            math.floor(fr*255+0.5), math.floor(fg*255+0.5), math.floor(fb*255+0.5))
                        HexBG_Border.Color = Color3.fromHex("#FFFFFF")
                        HexText.Text = cpData.hexBuffer .. "_"
                    end
                    return true
                elseif isInside(mPos, CPBG.Position, CPBG.Size) then
                    if cpData.hexFocused then cpData.commitHex(false) end
                    return true
                else
                    if cpData.hexFocused then cpData.commitHex(false) end
                    toggleCP(cpData, false)
                end
            end
            return false
        end

        cpData.handleDrag = function(mPos)
            if cpData.cpDrag == "sv" then
                cpS = math.clamp((mPos.X - SVArea.Position.X) / 150, 0, 1)
                cpV = 1 - math.clamp((mPos.Y - SVArea.Position.Y) / 110, 0, 1)
                cpData.cpS = cpS; cpData.cpV = cpV; cpH = cpData.cpH; updateCPColor("sv")
            elseif cpData.cpDrag == "hue" then
                cpH = math.clamp((mPos.X - hueSegments[1].Position.X) / 150, 0, 1) * 360
                cpData.cpH = cpH; cpS = cpData.cpS; cpV = cpData.cpV; updateCPColor("hue")
            elseif cpData.cpDrag == "bright" then
                cpV = math.clamp((mPos.X - brightSegments[1].Position.X) / 150, 0, 1)
                cpData.cpV = cpV; cpH = cpData.cpH; cpS = cpData.cpS; updateCPColor("bright")
            end
        end

        allColorpickers[#allColorpickers+1] = cpData
        return cpData
    end

    local function closeAllPopups()
        if openCP then toggleCP(openCP, false) end
        if rcMenuOpen then hideRCMenu() end
        for _, dd in ipairs(allDropdowns) do
            if dd.isOpen then dd.setOpen(false) end
        end
        for _, md in ipairs(allMultiDropdowns) do
            if md.isOpen then md.setOpen(false) end
        end
    end

    -- Menu elements list (for show/hide)
    local menuElements = {}
    local function addMenuEl(el) menuElements[#menuElements + 1] = el end

    addMenuEl(BG); addMenuEl(BG_Border); addMenuEl(Title1); addMenuEl(TitleText)
    for _, g in ipairs(glowLayers) do addMenuEl(g) end

    -- Tab switching
    -- Config state (set by AddConfigTab, used by switchTab/mainLoop)
    local cfgState = nil

    local function switchTab(idx)
        activeTab = idx
        for j, tl in ipairs(tabLabels) do
            tl.Color = (j == idx) and Color3.fromHex("#FFFFFF") or Color3.fromHex("#505050")
        end
        for j, tabData in ipairs(tabs) do
            local show = (j == idx)
            for _, el in ipairs(tabData.elements) do
                el.Visible = show
            end
            if show then
                for _, s in ipairs(tabData.sliders) do s.update() end
                for _, rs in ipairs(tabData.rangeSliders) do rs.update() end
            else
                -- hide dropdowns/CPs for hidden tabs
            end
        end
        if not (tabs[idx]) then return end
        closeAllPopups()
        -- Refresh config list to fix entry visibility after tab switch
        if cfgState and idx == cfgState.tabIndex then
            cfgState.refreshList()
            cfgState.updateInputDisplay()
        end
    end

    -- Window object
    local Window = {}
    Window.key = menuKey

    function Window:ToggleHotkeyList(show)
        hotkeyListOn = show
        toggleHotkeyList(show)
    end
    Window._toggleHotkeyList = Window.ToggleHotkeyList

    function Window:CreateInfoPanel(opts)
        opts = opts or {}
        local ipTitle = opts.Title or "Info"
        local charW = 5.5    -- Monospace size 12
        local titleCharW = 6.7 -- Monospace size 14
        local lineH = 18
        local minW = 120
        local MAX_LINES = 20

        -- Calculate initial width from title
        local function calcWidth(lines)
            local maxW = #ipTitle * titleCharW + 50 -- title + icon space + padding
            for _, ln in ipairs(lines) do
                local lineW = (#ln.key + 2 + #ln.value) * charW -- "Key: Value"
                if lineW > maxW then maxW = lineW end
            end
            local w = math.floor(maxW + 20)
            if w < minW then w = minW end
            return w
        end

        local ipLines = {} -- {key, value, labelDraw, valueDraw}
        local ipVisible = false
        local ipW = calcWidth(ipLines)

        -- Position to the left of main window
        local ipPos = Vector2.new(BG.Position.X - ipW - 10, BG.Position.Y + 40)

        -- Background
        local ipBG = Drawing.new("Square")
        ipBG.Visible = false; ipBG.Transparency = 1; ipBG.ZIndex = 700
        ipBG.Color = Color3.fromHex("#050505"); ipBG.Position = ipPos
        ipBG.Size = Vector2.new(ipW, 32); ipBG.Filled = true; ipBG.Corner = 6

        local ipBG_Border = Drawing.new("Square")
        ipBG_Border.Visible = false; ipBG_Border.Transparency = 1; ipBG_Border.ZIndex = 701
        ipBG_Border.Color = Color3.fromHex("#282828"); ipBG_Border.Filled = false; ipBG_Border.Thickness = 1
        ipBG_Border.Position = ipPos; ipBG_Border.Size = Vector2.new(ipW, 32); ipBG_Border.Corner = 6

        -- Title bar
        local ipTitleBG = Drawing.new("Square")
        ipTitleBG.Visible = false; ipTitleBG.Transparency = 1; ipTitleBG.ZIndex = 710
        ipTitleBG.Color = Color3.fromHex("#0a0a0a")
        ipTitleBG.Position = ipPos + Vector2.new(1, 1)
        ipTitleBG.Size = Vector2.new(ipW - 2, 30); ipTitleBG.Filled = true; ipTitleBG.Corner = 6

        local ipTitleText = newText()
        ipTitleText.Visible = false; ipTitleText.Transparency = 1; ipTitleText.ZIndex = 720
        ipTitleText.Color = Color3.fromHex("#FFFFFF")
        ipTitleText.Position = ipPos + Vector2.new(10, 8)
        ipTitleText.Text = ipTitle; ipTitleText.Size = 14; ipTitleText.Center = false
        ipTitleText.Outline = true; ipTitleText.Font = Drawing.Fonts.Monospace

        -- Line drawing pool
        local linePool = {}
        for i = 1, MAX_LINES do
            local lbl = newText()
            lbl.Visible = false; lbl.Transparency = 1; lbl.ZIndex = 720
            lbl.Color = Color3.fromHex("#808080"); lbl.Position = Vector2.new(0, 0)
            lbl.Text = ""; lbl.Size = 12; lbl.Center = false
            lbl.Outline = true; lbl.Font = Drawing.Fonts.Monospace

            local val = newText()
            val.Visible = false; val.Transparency = 1; val.ZIndex = 720
            val.Color = Color3.fromHex("#FFFFFF"); val.Position = Vector2.new(0, 0)
            val.Text = ""; val.Size = 12; val.Center = false
            val.Outline = true; val.Font = Drawing.Fonts.Monospace

            linePool[i] = {labelDraw = lbl, valueDraw = val}
        end

        local ipData = {
            bg = ipBG,
            border = ipBG_Border,
            titleBG = ipTitleBG,
            titleText = ipTitleText,
            lines = ipLines,
            linePool = linePool,
            visible = false,
            dragging = false,
            dragStart = nil,
            startPos = nil,
        }

        -- Update all positions relative to ipBG.Position
        local function updatePositions()
            ipBG_Border.Position = ipBG.Position
            ipTitleBG.Position = ipBG.Position + Vector2.new(1, 1)
            ipTitleText.Position = ipBG.Position + Vector2.new(10, 8)
            local yOff = 37
            for i, ln in ipairs(ipLines) do
                local pool = linePool[i]
                if pool then
                    pool.labelDraw.Position = ipBG.Position + Vector2.new(10, yOff)
                    local labelW = (#ln.key + 2) * charW -- "Key: "
                    pool.valueDraw.Position = ipBG.Position + Vector2.new(10 + math.floor(labelW), yOff)
                    yOff = yOff + lineH
                end
            end
        end
        ipData.updatePositions = updatePositions

        -- Resize panel and reflow
        local function refresh()
            ipW = calcWidth(ipLines)
            local lineCount = #ipLines
            local panelH = lineCount > 0 and (30 + lineCount * lineH + 8) or 32
            ipBG.Size = Vector2.new(ipW, panelH)
            ipBG_Border.Size = Vector2.new(ipW, panelH)
            ipTitleBG.Size = Vector2.new(ipW - 2, 30)

            -- Update pool visibility and text
            for i = 1, MAX_LINES do
                local pool = linePool[i]
                if i <= lineCount then
                    local ln = ipLines[i]
                    pool.labelDraw.Text = ln.key .. ": "
                    pool.valueDraw.Text = ln.value
                    pool.labelDraw.Visible = ipVisible
                    pool.valueDraw.Visible = ipVisible
                else
                    pool.labelDraw.Visible = false
                    pool.valueDraw.Visible = false
                end
            end
            updatePositions()
        end

        -- Set all drawing visibility
        local function setDrawingsVisible(show)
            ipBG.Visible = show
            ipBG_Border.Visible = show
            ipTitleBG.Visible = show
            ipTitleText.Visible = show
            for i = 1, MAX_LINES do
                local pool = linePool[i]
                if i <= #ipLines then
                    pool.labelDraw.Visible = show
                    pool.valueDraw.Visible = show
                else
                    pool.labelDraw.Visible = false
                    pool.valueDraw.Visible = false
                end
            end
        end
        ipData.setDrawingsVisible = setDrawingsVisible

        -- Public API
        local ret = {}

        function ret:SetTitle(text)
            ipTitle = text or "Info"
            ipTitleText.Text = ipTitle
            refresh()
        end

        function ret:SetLine(key, value)
            -- Find existing line with this key
            for _, ln in ipairs(ipLines) do
                if ln.key == key then
                    ln.value = value or ""
                    refresh()
                    return
                end
            end
            -- Add new line
            if #ipLines < MAX_LINES then
                ipLines[#ipLines + 1] = {key = key, value = value or ""}
                refresh()
            end
        end

        function ret:RemoveLine(key)
            for i, ln in ipairs(ipLines) do
                if ln.key == key then
                    table.remove(ipLines, i)
                    refresh()
                    return
                end
            end
        end

        function ret:SetVisible(show)
            ipVisible = show
            ipData.visible = show
            setDrawingsVisible(show)
            if show then refresh() end
        end

        function ret:Destroy()
            pcall(function() ipBG:Remove() end)
            pcall(function() ipBG_Border:Remove() end)
            pcall(function() ipTitleBG:Remove() end)
            pcall(function() ipTitleText:Remove() end)
            for i = 1, MAX_LINES do
                pcall(function() linePool[i].labelDraw:Remove() end)
                pcall(function() linePool[i].valueDraw:Remove() end)
            end
            -- Remove from tracking
            for i, ip in ipairs(allInfoPanels) do
                if ip == ipData then table.remove(allInfoPanels, i); break end
            end
        end

        allInfoPanels[#allInfoPanels + 1] = ipData
        return ret
    end

    function Window:Destroy()
        for _, tabData in ipairs(tabs) do
            for _, el in ipairs(tabData.elements) do pcall(function() el:Remove() end) end
        end
        for _, g in ipairs(glowLayers) do pcall(function() g:Remove() end) end
        pcall(function() BG:Remove() end); pcall(function() BG_Border:Remove() end)
        pcall(function() Title1:Remove() end); pcall(function() TitleText:Remove() end)
        for _, tl in ipairs(tabLabels) do pcall(function() tl:Remove() end) end
        pcall(function() HotkeyBG:Remove() end); pcall(function() HotkeyBG_Border:Remove() end)
        pcall(function() HotkeyTitleBG:Remove() end); pcall(function() HotkeyTitle:Remove() end)
        if Icon then pcall(function() Icon:Remove() end) end
        pcall(function() RCMenu:Remove() end); pcall(function() RCMenu_Border:Remove() end)
        pcall(function() RCAlways:Remove() end); pcall(function() RCToggle:Remove() end); pcall(function() RCHold:Remove() end)
        for _, ip in ipairs(allInfoPanels) do
            pcall(function() ip.bg:Remove() end); pcall(function() ip.border:Remove() end)
            pcall(function() ip.titleBG:Remove() end); pcall(function() ip.titleText:Remove() end)
            for _, pool in ipairs(ip.linePool) do
                pcall(function() pool.labelDraw:Remove() end); pcall(function() pool.valueDraw:Remove() end)
            end
        end
    end

    function Window:GetMenuKeyName()
        return KeyNames[menuKey] or "End"
    end

    function Window:IsOpen()
        return menuOpen
    end

    function Window:SetFont(font, exclude)
        local skip = {}
        if exclude then
            for _, tag in ipairs(exclude) do skip[tag] = true end
        end
        for _, entry in ipairs(allTextDrawings) do
            if not skip[entry.tag] then
                entry.drawing.Font = font
            end
        end
        -- Update charW for right-alignment and hit detection
        charW = fontCharWidths[font] or 6.5
        -- Refresh tab label positions
        local gap = 15
        local rightEdge = 538
        local totalW = 0
        for i = #tabLabels, 1, -1 do
            totalW = totalW + #tabLabels[i].Text * (charW + 0.5)
            if i < #tabLabels then totalW = totalW + gap end
        end
        local x = rightEdge - totalW
        for i, tl in ipairs(tabLabels) do
            tabXOffsets[i] = x
            tl.Position = Title1.Position + Vector2.new(x, 8)
            x = x + #tl.Text * (charW + 0.5) + gap
        end
        -- Refresh keybind text positions
        for _, kb in ipairs(allKeybinds) do
            if not kb.listening then
                kb.bindText.Position = Vector2.new(rightAlignX(kb.bindText.Text, kb.panel.Position, kb.panel.Size.X), kb.panel.Position.Y + kb.yPos)
            end
        end
        -- Refresh slider value positions
        for _, sd in ipairs(allSliders) do
            sd.valueText.Position = Vector2.new(rightAlignX(sd.valueText.Text, sd.panel.Position, sd.panel.Size.X), sd.valueText.Position.Y)
        end
        -- Refresh range slider value positions
        for _, rs in ipairs(allRangeSliders) do
            rs.rightText.Position = Vector2.new(rightAlignX(rs.rightText.Text, rs.panel.Position, rs.panel.Size.X), rs.rightText.Position.Y)
            rs.leftText.Position = Vector2.new(rs.rightText.Position.X - #rs.leftText.Text * charW - 5, rs.leftText.Position.Y)
        end
    end

    function Window:AddTab(name)
        local tabIndex = #tabs + 1
        local tabLabel = newText()
        tabLabel.Visible = true; tabLabel.Transparency = 1; tabLabel.ZIndex = 40 + tabIndex * 10
        tabLabel.Color = (tabIndex == 1) and Color3.fromHex("#FFFFFF") or Color3.fromHex("#505050")
        tabLabel.Position = Title1.Position + Vector2.new(300 + (tabIndex - 1) * 60, 8) -- placeholder, Start() recalculates
        tabLabel.Text = name; tabLabel.Size = 12; tabLabel.Center = false
        tabLabel.Outline = true; tabLabel.Font = Drawing.Fonts.Monospace
        tabLabels[tabIndex] = tabLabel
        addMenuEl(tabLabel)

        -- Panels
        local Panel1 = Drawing.new("Square")
        Panel1.Visible = (tabIndex == 1); Panel1.Transparency = 1; Panel1.ZIndex = 90
        Panel1.Color = Color3.fromHex("#0a0a0a")
        Panel1.Position = BG.Position + Vector2.new(10, 45)
        Panel1.Size = Vector2.new(260, 540); Panel1.Filled = true; Panel1.Corner = 6

        local Panel1_Border = Drawing.new("Square")
        Panel1_Border.Visible = (tabIndex == 1); Panel1_Border.Transparency = 1; Panel1_Border.ZIndex = 91
        Panel1_Border.Color = Color3.fromHex("#282828"); Panel1_Border.Filled = false; Panel1_Border.Thickness = 1
        Panel1_Border.Position = Panel1.Position; Panel1_Border.Size = Panel1.Size; Panel1_Border.Corner = 6

        local Panel2 = Drawing.new("Square")
        Panel2.Visible = (tabIndex == 1); Panel2.Transparency = 1; Panel2.ZIndex = 100
        Panel2.Color = Color3.fromHex("#0a0a0a")
        Panel2.Position = BG.Position + Vector2.new(280, 45)
        Panel2.Size = Vector2.new(260, 540); Panel2.Filled = true; Panel2.Corner = 6

        local Panel2_Border = Drawing.new("Square")
        Panel2_Border.Visible = (tabIndex == 1); Panel2_Border.Transparency = 1; Panel2_Border.ZIndex = 101
        Panel2_Border.Color = Color3.fromHex("#282828"); Panel2_Border.Filled = false; Panel2_Border.Thickness = 1
        Panel2_Border.Position = Panel2.Position; Panel2_Border.Size = Panel2.Size; Panel2_Border.Corner = 6

        -- Panel header texts float ABOVE panels
        local PanelText1 = newText()
        PanelText1.Visible = (tabIndex == 1); PanelText1.Transparency = 1; PanelText1.ZIndex = 110
        PanelText1.Color = Color3.fromHex("#FFFFFF")
        PanelText1.Position = Panel1.Position + Vector2.new(20, -5)
        PanelText1.Text = "PlaceHolder"; PanelText1.Size = 12; PanelText1.Center = false
        PanelText1.Outline = true; PanelText1.Font = Drawing.Fonts.Monospace

        local PanelText2 = newText()
        PanelText2.Visible = (tabIndex == 1); PanelText2.Transparency = 1; PanelText2.ZIndex = 120
        PanelText2.Color = Color3.fromHex("#FFFFFF")
        PanelText2.Position = Panel1.Position + Vector2.new(290, -5)
        PanelText2.Text = "PlaceHolder"; PanelText2.Size = 12; PanelText2.Center = false
        PanelText2.Outline = true; PanelText2.Font = Drawing.Fonts.Monospace

        local tabData = {
            elements = {Panel1, Panel1_Border, Panel2, Panel2_Border, PanelText1, PanelText2},
            sliders = {},
            rangeSliders = {},
            panel1 = Panel1, panel2 = Panel2,
            panel1Border = Panel1_Border, panel2Border = Panel2_Border,
            panelText1 = PanelText1, panelText2 = PanelText2,
            panel1Y = 15, panel2Y = 15,
            panel3 = nil, panel4 = nil,
            panel3Border = nil, panel4Border = nil,
            panelText3 = nil, panelText4 = nil,
            panel3Y = 15, panel4Y = 15,
            panel1Height = 540, panel2Height = 540,
            panel1SubH = nil, panel2SubH = nil,
            sections = {},
        }
        tabs[tabIndex] = tabData

        local Tab = {}

        function Tab:AddSection(name, opts)
            opts = opts or {}
            local sectionIndex = #tabData.sections + 1
            local panel, panelText, panelYKey

            -- Side override: allow 3rd section to go bottom-right
            local forcedSide = opts.Side and opts.Side:lower() or nil
            if sectionIndex == 3 and forcedSide == "right" and (opts.Height or 0) > 0 then
                sectionIndex = 4
                tabData.sections[3] = {} -- placeholder so index 4 is valid
            end

            if sectionIndex == 1 then
                panel = Panel1; panelText = PanelText1; panelYKey = "panel1Y"
            elseif sectionIndex == 2 then
                panel = Panel2; panelText = PanelText2; panelYKey = "panel2Y"
            elseif sectionIndex == 3 then
                -- Sub-panel below Panel1
                local subH = opts.Height or 0
                if subH > 0 then
                    tabData.panel1SubH = subH
                    tabData.panel1Height = 540 - subH - 10
                    Panel1.Size = Vector2.new(260, tabData.panel1Height)
                    Panel1_Border.Size = Panel1.Size
                    local vis3 = (tabIndex == 1)
                    local p3Pos = Panel1.Position + Vector2.new(0, tabData.panel1Height + 10)

                    local Panel3 = Drawing.new("Square")
                    Panel3.Visible = vis3; Panel3.Transparency = 1; Panel3.ZIndex = 92
                    Panel3.Color = Color3.fromHex("#0a0a0a")
                    Panel3.Position = p3Pos
                    Panel3.Size = Vector2.new(260, subH); Panel3.Filled = true; Panel3.Corner = 6

                    local Panel3_Border = Drawing.new("Square")
                    Panel3_Border.Visible = vis3; Panel3_Border.Transparency = 1; Panel3_Border.ZIndex = 93
                    Panel3_Border.Color = Color3.fromHex("#282828"); Panel3_Border.Filled = false; Panel3_Border.Thickness = 1
                    Panel3_Border.Position = p3Pos; Panel3_Border.Size = Panel3.Size; Panel3_Border.Corner = 6

                    local PanelText3 = newText()
                    PanelText3.Visible = vis3; PanelText3.Transparency = 1; PanelText3.ZIndex = 110
                    PanelText3.Color = Color3.fromHex("#FFFFFF")
                    PanelText3.Position = p3Pos + Vector2.new(20, -5)
                    PanelText3.Text = name; PanelText3.Size = 12; PanelText3.Center = false
                    PanelText3.Outline = true; PanelText3.Font = Drawing.Fonts.Monospace

                    tabData.panel3 = Panel3; tabData.panel3Border = Panel3_Border; tabData.panelText3 = PanelText3
                    for _, el in ipairs({Panel3, Panel3_Border, PanelText3}) do
                        tabData.elements[#tabData.elements+1] = el
                    end

                    panel = Panel3; panelText = PanelText3; panelYKey = "panel3Y"
                else
                    -- No Height on left side, fall back to Panel1
                    panel = Panel1; panelText = PanelText1; panelYKey = "panel1Y"
                end
            elseif sectionIndex == 4 then
                -- Sub-panel below Panel2
                local subH = opts.Height or 0
                if subH > 0 then
                    tabData.panel2SubH = subH
                    tabData.panel2Height = 540 - subH - 10
                    Panel2.Size = Vector2.new(260, tabData.panel2Height)
                    Panel2_Border.Size = Panel2.Size

                    local vis4 = (tabIndex == 1)
                    local p4Pos = Panel2.Position + Vector2.new(0, tabData.panel2Height + 10)

                    local Panel4 = Drawing.new("Square")
                    Panel4.Visible = vis4; Panel4.Transparency = 1; Panel4.ZIndex = 102
                    Panel4.Color = Color3.fromHex("#0a0a0a")
                    Panel4.Position = p4Pos
                    Panel4.Size = Vector2.new(260, subH); Panel4.Filled = true; Panel4.Corner = 6

                    local Panel4_Border = Drawing.new("Square")
                    Panel4_Border.Visible = vis4; Panel4_Border.Transparency = 1; Panel4_Border.ZIndex = 103
                    Panel4_Border.Color = Color3.fromHex("#282828"); Panel4_Border.Filled = false; Panel4_Border.Thickness = 1
                    Panel4_Border.Position = p4Pos; Panel4_Border.Size = Panel4.Size; Panel4_Border.Corner = 6

                    local PanelText4 = newText()
                    PanelText4.Visible = vis4; PanelText4.Transparency = 1; PanelText4.ZIndex = 120
                    PanelText4.Color = Color3.fromHex("#FFFFFF")
                    PanelText4.Position = p4Pos + Vector2.new(20, -5)
                    PanelText4.Text = name; PanelText4.Size = 12; PanelText4.Center = false
                    PanelText4.Outline = true; PanelText4.Font = Drawing.Fonts.Monospace

                    tabData.panel4 = Panel4; tabData.panel4Border = Panel4_Border; tabData.panelText4 = PanelText4
                    for _, el in ipairs({Panel4, Panel4_Border, PanelText4}) do
                        tabData.elements[#tabData.elements+1] = el
                    end

                    panel = Panel4; panelText = PanelText4; panelYKey = "panel4Y"
                else
                    -- No Height on right side, fall back to Panel2
                    panel = Panel2; panelText = PanelText2; panelYKey = "panel2Y"
                end
            else
                -- 5+ sections: alternate left/right on main panels
                local isLeft = (sectionIndex % 2 == 1)
                panel = isLeft and Panel1 or Panel2
                panelText = isLeft and PanelText1 or PanelText2
                panelYKey = isLeft and "panel1Y" or "panel2Y"
            end

            panelText.Text = name

            local Section = {}
            Section._panel = panel
            Section._tabData = tabData
            Section._tabIndex = tabIndex

            local function getY()
                return tabData[panelYKey]
            end
            local function advanceY(amount)
                tabData[panelYKey] = tabData[panelYKey] + amount
            end

            function Section:AddLabel(o)
                o = o or {}
                local y = getY()
                local panelPos = panel.Position
                local vis = (tabIndex == activeTab)
                local lines = type(o) == "string" and {o} or (o.Lines or {o.Text or ""})

                for i, line in ipairs(lines) do
                    local t = newText()
                    t.Visible = vis; t.Transparency = 1; t.ZIndex = 140
                    t.Color = Color3.fromHex(line:sub(1, 2) == "- " and "#808080" or "#FFFFFF")
                    t.Position = panelPos + Vector2.new(10, y + (i - 1) * 15)
                    t.Text = line; t.Size = 12; t.Center = false
                    t.Outline = true; t.Font = Drawing.Fonts.Monospace
                    tabData.elements[#tabData.elements+1] = t
                end

                advanceY(#lines * 15 + 5)
            end

            function Section:AddToggle(o)
                o = o or {}
                local y = getY()
                local panelPos = panel.Position
                local panelW = panel.Size.X
                local vis = (tabIndex == activeTab)

                local box = Drawing.new("Square")
                box.Visible = vis; box.Transparency = 1; box.ZIndex = 130
                box.Color = o.Default and Color3.fromHex("#282828") or Color3.fromHex("#0a0a0a")
                box.Position = panelPos + Vector2.new(10, y)
                box.Size = Vector2.new(15, 15); box.Filled = true; box.Corner = o.Corner or 4

                local boxBorder = Drawing.new("Square")
                boxBorder.Visible = vis; boxBorder.Transparency = 1; boxBorder.ZIndex = 131
                boxBorder.Color = Color3.fromHex("#282828"); boxBorder.Filled = false; boxBorder.Thickness = 1
                boxBorder.Position = box.Position; boxBorder.Size = box.Size; boxBorder.Corner = o.Corner or 4

                local nameText = newText()
                nameText.Visible = vis; nameText.Transparency = 1; nameText.ZIndex = 140
                nameText.Color = Color3.fromHex("#FFFFFF")
                nameText.Position = panelPos + Vector2.new(35, y + 1)
                nameText.Text = o.Name or "Toggle"; nameText.Size = 12; nameText.Center = false
                nameText.Outline = true; nameText.Font = Drawing.Fonts.Monospace

                tabData.elements[#tabData.elements+1] = box
                tabData.elements[#tabData.elements+1] = boxBorder
                tabData.elements[#tabData.elements+1] = nameText

                local toggleState = o.Default or false
                local callback = o.Callback or function() end

                local toggleData = {
                    box = box, boxBorder = boxBorder, nameText = nameText,
                    state = toggleState,
                    panel = panel,
                    yOffset = y,
                }

                -- Keybind on same row
                local keybindData = nil
                if o.Keybind then
                    local bindText = newText()
                    bindText.Visible = vis; bindText.Transparency = 1; bindText.ZIndex = 140
                    bindText.Color = Color3.fromHex("#505050")
                    bindText.Text = "[None]"
                    bindText.Position = Vector2.new(rightAlignX(bindText.Text, panelPos, panelW), panelPos.Y + y + 1)
                    bindText.Size = 12; bindText.Center = false
                    bindText.Outline = true; bindText.Font = Drawing.Fonts.Monospace
                    tabData.elements[#tabData.elements+1] = bindText

                    keybindData = {
                        bindText = bindText,
                        key = nil,
                        mode = o.Mode or "always",
                        listening = false,
                        active = false,
                        lastKeyState = false,
                        panel = panel,
                        yPos = y + 1,
                        toggleRef = toggleData,
                        isStandalone = false,
                        rcEnabled = true,
                        callback = o.Callback or function() end,
                    }
                    allKeybinds[#allKeybinds+1] = keybindData

                    -- HK entry
                    local hkName = newText()
                    hkName.Visible = false; hkName.Transparency = 1; hkName.ZIndex = 720
                    hkName.Color = Color3.fromHex("#505050"); hkName.Position = Vector2.new(0,0)
                    hkName.Text = o.Name or "Toggle"; hkName.Size = 14; hkName.Center = false
                    hkName.Outline = true; hkName.Font = Drawing.Fonts.Monospace

                    local hkMode = newText()
                    hkMode.Visible = false; hkMode.Transparency = 1; hkMode.ZIndex = 720
                    hkMode.Color = Color3.fromHex("#505050"); hkMode.Position = Vector2.new(0,0)
                    hkMode.Text = "[Always On]"; hkMode.Size = 14; hkMode.Center = false
                    hkMode.Outline = true; hkMode.Font = Drawing.Fonts.Monospace

                    hkEntries[#hkEntries+1] = {
                        nameDrawing = hkName, modeDrawing = hkMode,
                        getVisible = function() return toggleData.state and (keybindData.key ~= nil) end,
                        getActive = function() return keybindData.active end,
                        getMode = function() return keybindData.mode end,
                        getName = function() return o.Name or "Toggle" end,
                    }
                end

                -- Inline colorpicker on same row
                local cpData = nil
                if o.Colorpicker then
                    local cpColor = o.DefaultColor or Color3.new(1, 0, 0)
                    local cpX = keybindData and 200 or 235

                    local colorPreview = Drawing.new("Square")
                    colorPreview.Visible = vis; colorPreview.Transparency = 1; colorPreview.ZIndex = 350
                    colorPreview.Color = cpColor
                    colorPreview.Position = panelPos + Vector2.new(cpX, y)
                    colorPreview.Size = Vector2.new(15, 15); colorPreview.Filled = true

                    local cpBorderSq = Drawing.new("Square")
                    cpBorderSq.Visible = vis; cpBorderSq.Transparency = 1; cpBorderSq.ZIndex = 351
                    cpBorderSq.Color = Color3.fromHex("#282828"); cpBorderSq.Filled = false; cpBorderSq.Thickness = 1
                    cpBorderSq.Position = colorPreview.Position; cpBorderSq.Size = colorPreview.Size

                    tabData.elements[#tabData.elements+1] = colorPreview
                    tabData.elements[#tabData.elements+1] = cpBorderSq

                    cpData = createColorpickerPopup(colorPreview, cpBorderSq, cpColor, function() end, o.Name)
                    cpData.box = colorPreview
                    cpData.panel = panel
                    cpData.yOffset = y
                end

                toggleData.onClick = function()
                    toggleData.state = not toggleData.state
                    toggleState = toggleData.state
                    box.Color = toggleData.state and Color3.fromHex("#282828") or Color3.fromHex("#0a0a0a")
                    callback(toggleData.state)
                    if hotkeyListOn then updateHotkeyList() end
                end

                allToggles[#allToggles+1] = toggleData
                advanceY(25)

                local ret = {}
                ret.Set = function(_, val)
                    toggleData.state = val
                    box.Color = val and Color3.fromHex("#282828") or Color3.fromHex("#0a0a0a")
                    callback(val)
                    if hotkeyListOn then updateHotkeyList() end
                end
                ret.Get = function() return toggleData.state end
                if keybindData then
                    ret.GetActive = function() return keybindData.active end
                    ret.SetActive = function(_, val) keybindData.active = val end
                else
                    ret.GetActive = function() return toggleData.state end
                    ret.SetActive = function() end
                end
                if cpData then
                    ret.GetColor = function()
                        local rr, gg, bb = hsvToRgb(cpData.cpH, cpData.cpS, cpData.cpV)
                        return Color3.new(rr, gg, bb)
                    end
                end
                if keybindData then
                    local cfgGet = function()
                        local d = {state = toggleData.state, key = keybindData.key, mode = keybindData.mode}
                        if cpData then
                            local rr, gg, bb = hsvToRgb(cpData.cpH, cpData.cpS, cpData.cpV)
                            d.color = {r = math.floor(rr * 255), g = math.floor(gg * 255), b = math.floor(bb * 255)}
                        end
                        return d
                    end
                    local cfgSet = function(v)
                        if type(v) == "table" then
                            ret:Set(v.state)
                            if v.key ~= nil or v.mode ~= nil then
                                keybindData.key = v.key
                                if v.key and KeyNames[v.key] then
                                    keybindData.bindText.Text = "[" .. KeyNames[v.key] .. "]"
                                else
                                    keybindData.bindText.Text = "[None]"
                                end
                                keybindData.bindText.Position = Vector2.new(rightAlignX(keybindData.bindText.Text, panel.Position, panel.Size.X), panel.Position.Y + keybindData.yPos)
                                if v.mode then keybindData.mode = v.mode end
                            end
                            if v.color and cpData then
                                local h, s, val = rgbToHsv(v.color.r / 255, v.color.g / 255, v.color.b / 255)
                                cpData.setHSV(h, s, val)
                            end
                        else
                            ret:Set(v)
                        end
                    end
                    configWidgets[#configWidgets+1] = { name = o.Name or "Toggle", get = cfgGet, set = cfgSet }
                else
                    local cfgGet = function()
                        if cpData then
                            local rr, gg, bb = hsvToRgb(cpData.cpH, cpData.cpS, cpData.cpV)
                            return {state = toggleData.state, color = {r = math.floor(rr * 255), g = math.floor(gg * 255), b = math.floor(bb * 255)}}
                        end
                        return toggleData.state
                    end
                    local cfgSet = function(v)
                        if type(v) == "table" then
                            ret:Set(v.state)
                            if v.color and cpData then
                                local h, s, val = rgbToHsv(v.color.r / 255, v.color.g / 255, v.color.b / 255)
                                cpData.setHSV(h, s, val)
                            end
                        else
                            ret:Set(v)
                        end
                    end
                    configWidgets[#configWidgets+1] = { name = o.Name or "Toggle", get = cfgGet, set = cfgSet }
                end
                return ret
            end

            function Section:AddSlider(o)
                o = o or {}
                local y = getY()
                local panelPos = panel.Position
                local panelW = panel.Size.X
                local vis = (tabIndex == activeTab)
                local sMin = o.Min or 0
                local sMax = o.Max or 100
                local sVal = o.Default or sMin
                local suffix = o.Suffix or ""
                local callback = o.Callback or function() end

                local sliderLabel = newText()
                sliderLabel.Visible = vis; sliderLabel.Transparency = 1; sliderLabel.ZIndex = 140
                sliderLabel.Color = Color3.fromHex("#FFFFFF")
                sliderLabel.Position = panelPos + Vector2.new(10, y)
                sliderLabel.Text = o.Name or "Slider"; sliderLabel.Size = 12; sliderLabel.Center = false
                sliderLabel.Outline = true; sliderLabel.Font = Drawing.Fonts.Monospace

                local valStr = tostring(math.floor(sVal)) .. suffix
                local sliderValue = newText()
                sliderValue.Visible = vis; sliderValue.Transparency = 1; sliderValue.ZIndex = 140
                sliderValue.Color = Color3.fromHex("#FFFFFF")
                sliderValue.Position = Vector2.new(rightAlignX(valStr, panelPos, panelW), panelPos.Y + y)
                sliderValue.Text = valStr; sliderValue.Size = 12; sliderValue.Center = false
                sliderValue.Outline = true; sliderValue.Font = Drawing.Fonts.Monospace

                local sliderBar = Drawing.new("Square")
                sliderBar.Visible = vis; sliderBar.Transparency = 1; sliderBar.ZIndex = 150
                sliderBar.Color = Color3.fromHex("#0a0a0a")
                sliderBar.Position = panelPos + Vector2.new(20, y + 15)
                sliderBar.Size = Vector2.new(215, 15); sliderBar.Filled = true; sliderBar.Corner = 6

                local sliderBarBorder = Drawing.new("Square")
                sliderBarBorder.Visible = vis; sliderBarBorder.Transparency = 1; sliderBarBorder.ZIndex = 151
                sliderBarBorder.Color = Color3.fromHex("#282828"); sliderBarBorder.Filled = false; sliderBarBorder.Thickness = 1
                sliderBarBorder.Position = sliderBar.Position; sliderBarBorder.Size = sliderBar.Size; sliderBarBorder.Corner = 6

                local sliderFill = Drawing.new("Square")
                sliderFill.Visible = vis; sliderFill.Transparency = 1; sliderFill.ZIndex = 160
                sliderFill.Color = Color3.fromHex("#282828")
                sliderFill.Position = sliderBar.Position
                sliderFill.Size = Vector2.new(215, 15); sliderFill.Filled = true; sliderFill.Corner = 6

                local sliderMinus = newText()
                sliderMinus.Visible = vis; sliderMinus.Transparency = 1; sliderMinus.ZIndex = 170
                sliderMinus.Color = Color3.fromHex("#FFFFFF")
                sliderMinus.Position = panelPos + Vector2.new(10, y + 15)
                sliderMinus.Text = "-"; sliderMinus.Size = 14; sliderMinus.Center = false
                sliderMinus.Outline = true; sliderMinus.Font = Drawing.Fonts.Monospace

                local sliderPlus = newText()
                sliderPlus.Visible = vis; sliderPlus.Transparency = 1; sliderPlus.ZIndex = 170
                sliderPlus.Color = Color3.fromHex("#FFFFFF")
                sliderPlus.Position = panelPos + Vector2.new(240, y + 15)
                sliderPlus.Text = "+"; sliderPlus.Size = 14; sliderPlus.Center = false
                sliderPlus.Outline = true; sliderPlus.Font = Drawing.Fonts.Monospace

                for _, el in ipairs({sliderLabel, sliderValue, sliderBar, sliderBarBorder, sliderFill, sliderMinus, sliderPlus}) do
                    tabData.elements[#tabData.elements+1] = el
                end

                local step = o.Step or 10

                local sliderData = {
                    val = sVal, min = sMin, max = sMax, suffix = suffix, step = step,
                    bar = sliderBar, fill = sliderFill, label = sliderLabel, valueText = sliderValue,
                    minus = sliderMinus, plus = sliderPlus, barBorder = sliderBarBorder,
                    panel = panel, yOffset = y, callback = callback,
                }

                sliderData.update = function()
                    local pct = (sliderData.val - sliderData.min) / (sliderData.max - sliderData.min)
                    local w = math.floor(pct * 215)
                    sliderFill.Visible = w > 0 and sliderBar.Visible
                    sliderFill.Size = Vector2.new(w, 15)
                    local vs = tostring(math.floor(sliderData.val)) .. sliderData.suffix
                    sliderValue.Text = vs
                    sliderValue.Position = Vector2.new(rightAlignX(vs, panel.Position, panelW), sliderValue.Position.Y)
                end

                sliderData.update()
                allSliders[#allSliders+1] = sliderData
                tabData.sliders[#tabData.sliders+1] = sliderData
                advanceY(45)

                local ret = {}
                ret.Set = function(_, val)
                    sliderData.val = math.clamp(val, sMin, sMax)
                    sliderData.update()
                end
                ret.Get = function() return sliderData.val end
                configWidgets[#configWidgets+1] = {
                    name = o.Name or "Slider",
                    get = function() return sliderData.val end,
                    set = function(v) ret:Set(v) end,
                }
                return ret
            end

            function Section:AddRangeSlider(o)
                o = o or {}
                local y = getY()
                local panelPos = panel.Position
                local panelW = panel.Size.X
                local vis = (tabIndex == activeTab)
                local sMin = o.Min or 0
                local sMax = o.Max or 100
                local leftVal = o.DefaultLeft or sMin
                local rightVal = o.DefaultRight or sMax
                local suffix = o.Suffix or ""
                local callback = o.Callback or function() end

                local rangeLabel = newText()
                rangeLabel.Visible = vis; rangeLabel.Transparency = 1; rangeLabel.ZIndex = 140
                rangeLabel.Color = Color3.fromHex("#FFFFFF")
                rangeLabel.Position = panelPos + Vector2.new(10, y)
                rangeLabel.Text = o.Name or "Range"; rangeLabel.Size = 12; rangeLabel.Center = false
                rangeLabel.Outline = true; rangeLabel.Font = Drawing.Fonts.Monospace

                local rightStr = tostring(math.floor(rightVal)) .. suffix
                local rightText = newText()
                rightText.Visible = vis; rightText.Transparency = 1; rightText.ZIndex = 140
                rightText.Color = Color3.fromHex("#FFFFFF")
                rightText.Position = Vector2.new(rightAlignX(rightStr, panelPos, panelW), panelPos.Y + y)
                rightText.Text = rightStr; rightText.Size = 12; rightText.Center = false
                rightText.Outline = true; rightText.Font = Drawing.Fonts.Monospace

                local leftStr = tostring(math.floor(leftVal)) .. suffix
                local leftText = newText()
                leftText.Visible = vis; leftText.Transparency = 1; leftText.ZIndex = 140
                leftText.Color = Color3.fromHex("#FFFFFF")
                leftText.Position = Vector2.new(rightText.Position.X - #leftStr * charW - 5, panelPos.Y + y)
                leftText.Text = leftStr; leftText.Size = 12; leftText.Center = false
                leftText.Outline = true; leftText.Font = Drawing.Fonts.Monospace

                local rangeBar = Drawing.new("Square")
                rangeBar.Visible = vis; rangeBar.Transparency = 1; rangeBar.ZIndex = 150
                rangeBar.Color = Color3.fromHex("#0a0a0a")
                rangeBar.Position = panelPos + Vector2.new(20, y + 15)
                rangeBar.Size = Vector2.new(215, 15); rangeBar.Filled = true; rangeBar.Corner = 6

                local rangeBarBorder = Drawing.new("Square")
                rangeBarBorder.Visible = vis; rangeBarBorder.Transparency = 1; rangeBarBorder.ZIndex = 151
                rangeBarBorder.Color = Color3.fromHex("#282828"); rangeBarBorder.Filled = false; rangeBarBorder.Thickness = 1
                rangeBarBorder.Position = rangeBar.Position; rangeBarBorder.Size = rangeBar.Size; rangeBarBorder.Corner = 6

                local rangeFill = Drawing.new("Square")
                rangeFill.Visible = vis; rangeFill.Transparency = 1; rangeFill.ZIndex = 160
                rangeFill.Color = Color3.fromHex("#282828")
                rangeFill.Position = rangeBar.Position
                rangeFill.Size = Vector2.new(215, 15); rangeFill.Filled = true; rangeFill.Corner = 6

                local rangeMinus = newText()
                rangeMinus.Visible = vis; rangeMinus.Transparency = 1; rangeMinus.ZIndex = 170
                rangeMinus.Color = Color3.fromHex("#FFFFFF")
                rangeMinus.Position = panelPos + Vector2.new(10, y + 15)
                rangeMinus.Text = "-"; rangeMinus.Size = 14; rangeMinus.Center = false
                rangeMinus.Outline = true; rangeMinus.Font = Drawing.Fonts.Monospace

                local rangePlus = newText()
                rangePlus.Visible = vis; rangePlus.Transparency = 1; rangePlus.ZIndex = 170
                rangePlus.Color = Color3.fromHex("#FFFFFF")
                rangePlus.Position = panelPos + Vector2.new(240, y + 15)
                rangePlus.Text = "+"; rangePlus.Size = 14; rangePlus.Center = false
                rangePlus.Outline = true; rangePlus.Font = Drawing.Fonts.Monospace

                for _, el in ipairs({rangeLabel, rightText, leftText, rangeBar, rangeBarBorder, rangeFill, rangeMinus, rangePlus}) do
                    tabData.elements[#tabData.elements+1] = el
                end

                local step = o.Step or 1

                local rsData = {
                    left = leftVal, right = rightVal, min = sMin, max = sMax, suffix = suffix, step = step,
                    bar = rangeBar, fill = rangeFill, leftText = leftText, rightText = rightText,
                    label = rangeLabel, minus = rangeMinus, plus = rangePlus, barBorder = rangeBarBorder,
                    panel = panel, yOffset = y, callback = callback,
                }

                rsData.update = function()
                    local pctL = (rsData.left - rsData.min) / (rsData.max - rsData.min)
                    local pctR = (rsData.right - rsData.min) / (rsData.max - rsData.min)
                    local leftX = math.floor(pctL * 215)
                    local rightX = math.floor(pctR * 215)
                    local fillW = math.max(rightX - leftX, 0)
                    rangeFill.Visible = fillW > 0 and rangeBar.Visible
                    rangeFill.Position = rangeBar.Position + Vector2.new(leftX, 0)
                    rangeFill.Size = Vector2.new(fillW, 15)
                    local rs = tostring(math.floor(rsData.right)) .. rsData.suffix
                    local ls = tostring(math.floor(rsData.left)) .. rsData.suffix
                    rightText.Text = rs
                    rightText.Position = Vector2.new(rightAlignX(rs, panel.Position, panelW), rightText.Position.Y)
                    leftText.Text = ls
                    leftText.Position = Vector2.new(rightText.Position.X - #ls * charW - 5, leftText.Position.Y)
                end

                rsData.update()
                allRangeSliders[#allRangeSliders+1] = rsData
                tabData.rangeSliders[#tabData.rangeSliders+1] = rsData
                advanceY(40)

                local ret = {}
                ret.SetLeft = function(_, val) rsData.left = math.clamp(val, sMin, rsData.right - 10); rsData.update() end
                ret.SetRight = function(_, val) rsData.right = math.clamp(val, rsData.left + 10, sMax); rsData.update() end
                configWidgets[#configWidgets+1] = {
                    name = o.Name or "RangeSlider",
                    get = function() return {rsData.left, rsData.right} end,
                    set = function(v) if type(v) == "table" then ret:SetLeft(v[1]); ret:SetRight(v[2]) end end,
                }
                return ret
            end

            function Section:AddKeybind(o)
                o = o or {}
                local y = getY()
                local panelPos = panel.Position
                local panelW = panel.Size.X
                local vis = (tabIndex == activeTab)

                local nameText = newText()
                nameText.Visible = vis; nameText.Transparency = 1; nameText.ZIndex = 140
                nameText.Color = Color3.fromHex("#FFFFFF")
                nameText.Position = panelPos + Vector2.new(10, y)
                nameText.Text = o.Name or "Keybind"; nameText.Size = 12; nameText.Center = false
                nameText.Outline = true; nameText.Font = Drawing.Fonts.Monospace

                local bindText = newText()
                bindText.Visible = vis; bindText.Transparency = 1; bindText.ZIndex = 140
                bindText.Color = Color3.fromHex("#505050")
                bindText.Text = "[None]"
                bindText.Position = Vector2.new(rightAlignX(bindText.Text, panelPos, panelW), panelPos.Y + y)
                bindText.Size = 12; bindText.Center = false
                bindText.Outline = true; bindText.Font = Drawing.Fonts.Monospace

                tabData.elements[#tabData.elements+1] = nameText
                tabData.elements[#tabData.elements+1] = bindText

                local isMenuBind = o.MenuBind == true

                local kbData = {
                    bindText = bindText,
                    key = o.Default or nil,
                    mode = o.Mode or "always",
                    listening = false,
                    active = false,
                    lastKeyState = false,
                    panel = panel,
                    yPos = y,
                    toggleRef = nil,
                    isStandalone = true,
                    rcEnabled = not isMenuBind and (o.RCMenu ~= false),
                    menuBind = isMenuBind,
                    callback = o.Callback or function() end,
                    nameText = nameText,
                }

                -- Set initial text if default key
                if kbData.key and KeyNames[kbData.key] then
                    bindText.Text = "[" .. KeyNames[kbData.key] .. "]"
                    bindText.Position = Vector2.new(rightAlignX(bindText.Text, panelPos, panelW), panelPos.Y + y)
                end

                allKeybinds[#allKeybinds+1] = kbData

                -- HK entry for standalone keybind (skip for menu bind)
                if not isMenuBind then
                    local hkName = newText()
                    hkName.Visible = false; hkName.Transparency = 1; hkName.ZIndex = 720
                    hkName.Color = Color3.fromHex("#505050"); hkName.Position = Vector2.new(0,0)
                    hkName.Text = o.Name or "Keybind"; hkName.Size = 14; hkName.Center = false
                    hkName.Outline = true; hkName.Font = Drawing.Fonts.Monospace

                    local hkMode = newText()
                    hkMode.Visible = false; hkMode.Transparency = 1; hkMode.ZIndex = 720
                    hkMode.Color = Color3.fromHex("#505050"); hkMode.Position = Vector2.new(0,0)
                    hkMode.Text = "[Always On]"; hkMode.Size = 14; hkMode.Center = false
                    hkMode.Outline = true; hkMode.Font = Drawing.Fonts.Monospace

                    hkEntries[#hkEntries+1] = {
                        nameDrawing = hkName, modeDrawing = hkMode,
                        getVisible = function() return kbData.key ~= nil end,
                        getActive = function() return kbData.active end,
                        getMode = function() return kbData.mode end,
                        getName = function() return o.Name or "Keybind" end,
                    }
                end

                advanceY(20)

                local kbRet = {}
                kbRet.GetActive = function() return kbData.active end
                kbRet.Get = function() return kbData.key end
                kbRet.Set = function(_, key)
                    kbData.key = key
                    if key and KeyNames[key] then
                        kbData.bindText.Text = "[" .. KeyNames[key] .. "]"
                    else
                        kbData.bindText.Text = "[None]"
                    end
                    if kbData.menuBind then menuKey = key or 35 end
                    kbData.bindText.Position = Vector2.new(rightAlignX(kbData.bindText.Text, panel.Position, panel.Size.X), panel.Position.Y + y)
                end
                if not o.MenuBind then
                    configWidgets[#configWidgets+1] = {
                        name = o.Name or "Keybind",
                        get = function() return {key = kbData.key, mode = kbData.mode} end,
                        set = function(v) if type(v) == "table" then kbRet:Set(v.key); if v.mode then kbData.mode = v.mode end end end,
                    }
                end
                return kbRet
            end

            function Section:AddColorpicker(o)
                o = o or {}
                local y = getY()
                local panelPos = panel.Position
                local panelW = panel.Size.X
                local vis = (tabIndex == activeTab)
                local callback = o.Callback or function() end
                local defaultColor = o.Default or Color3.new(1, 0, 0)
                local hasToggle = (o.Toggle ~= false)

                -- Toggle checkbox (only if hasToggle)
                local box, boxBorder
                if hasToggle then
                    box = Drawing.new("Square")
                    box.Visible = vis; box.Transparency = 1; box.ZIndex = 130
                    box.Color = Color3.fromHex("#0a0a0a")
                    box.Position = panelPos + Vector2.new(10, y)
                    box.Size = Vector2.new(15, 15); box.Filled = true; box.Corner = 4

                    boxBorder = Drawing.new("Square")
                    boxBorder.Visible = vis; boxBorder.Transparency = 1; boxBorder.ZIndex = 131
                    boxBorder.Color = Color3.fromHex("#282828"); boxBorder.Filled = false; boxBorder.Thickness = 1
                    boxBorder.Position = box.Position; boxBorder.Size = box.Size; boxBorder.Corner = 4
                end

                local nameText = newText()
                nameText.Visible = vis; nameText.Transparency = 1; nameText.ZIndex = 140
                nameText.Color = Color3.fromHex("#FFFFFF")
                nameText.Position = panelPos + Vector2.new(hasToggle and 35 or 10, y + 1)
                nameText.Text = o.Name or "Color"; nameText.Size = 12; nameText.Center = false
                nameText.Outline = true; nameText.Font = Drawing.Fonts.Monospace

                -- Color preview square
                local colorPreview = Drawing.new("Square")
                colorPreview.Visible = vis; colorPreview.Transparency = 1; colorPreview.ZIndex = 350
                colorPreview.Color = defaultColor
                colorPreview.Position = panelPos + Vector2.new(235, y)
                colorPreview.Size = Vector2.new(15, 15); colorPreview.Filled = true

                local cpBorder = Drawing.new("Square")
                cpBorder.Visible = vis; cpBorder.Transparency = 1; cpBorder.ZIndex = 351
                cpBorder.Color = Color3.fromHex("#282828"); cpBorder.Filled = false; cpBorder.Thickness = 1
                cpBorder.Position = colorPreview.Position; cpBorder.Size = colorPreview.Size

                if hasToggle then
                    for _, el in ipairs({box, boxBorder, nameText, colorPreview, cpBorder}) do
                        tabData.elements[#tabData.elements+1] = el
                    end
                else
                    for _, el in ipairs({nameText, colorPreview, cpBorder}) do
                        tabData.elements[#tabData.elements+1] = el
                    end
                end

                local cpData = createColorpickerPopup(colorPreview, cpBorder, defaultColor, callback, o.Name)
                cpData.box = box or colorPreview
                cpData.boxBorder = boxBorder
                cpData.toggleState = false
                cpData.hasToggle = hasToggle
                cpData.panel = panel
                cpData.yOffset = y

                cpData.onClick = function()
                    if not hasToggle then return end
                    cpData.toggleState = not cpData.toggleState
                    box.Color = cpData.toggleState and Color3.fromHex("#282828") or Color3.fromHex("#0a0a0a")
                end

                advanceY(25)

                local ret = {}
                ret.GetColor = function()
                    local rr, gg, bb = hsvToRgb(cpData.cpH, cpData.cpS, cpData.cpV)
                    return Color3.new(rr, gg, bb)
                end
                if hasToggle then
                    ret.Get = function() return cpData.toggleState end
                end
                configWidgets[#configWidgets+1] = {
                    name = o.Name or "Colorpicker",
                    get = function()
                        local rr, gg, bb = hsvToRgb(cpData.cpH, cpData.cpS, cpData.cpV)
                        local d = {r = math.floor(rr * 255), g = math.floor(gg * 255), b = math.floor(bb * 255)}
                        if hasToggle then d.toggle = cpData.toggleState end
                        return d
                    end,
                    set = function(v)
                        if type(v) ~= "table" then return end
                        if v.r then
                            local h, s, val = rgbToHsv(v.r / 255, v.g / 255, v.b / 255)
                            cpData.setHSV(h, s, val)
                        end
                        if v.toggle ~= nil and hasToggle then
                            cpData.toggleState = v.toggle
                            cpData.box.Color = v.toggle and Color3.fromHex("#282828") or Color3.fromHex("#0a0a0a")
                        end
                    end,
                }
                return ret
            end

            function Section:AddSingle(o)
                o = o or {}
                local y = getY()
                local panelPos = panel.Position
                local vis = (tabIndex == activeTab)
                local options = o.Options or {}
                local selected = o.Default or (options[1] or "")
                local callback = o.Callback or function() end
                local isDrop = (o.Drop ~= false)

                if isDrop then
                    -- Dropdown mode (popup)
                    local ddLabel = newText()
                    ddLabel.Visible = vis; ddLabel.Transparency = 1; ddLabel.ZIndex = 360
                    ddLabel.Color = Color3.fromHex("#FFFFFF")
                    ddLabel.Position = panelPos + Vector2.new(10, y)
                    ddLabel.Text = o.Name or "Select"; ddLabel.Size = 12; ddLabel.Center = false
                    ddLabel.Outline = true; ddLabel.Font = Drawing.Fonts.Monospace

                    local ddBar = Drawing.new("Square")
                    ddBar.Visible = vis; ddBar.Transparency = 1; ddBar.ZIndex = 360
                    ddBar.Color = Color3.fromHex("#0a0a0a")
                    ddBar.Position = panelPos + Vector2.new(10, y + 15)
                    ddBar.Size = Vector2.new(240, 20); ddBar.Filled = true; ddBar.Corner = 6

                    local ddBarBorder = Drawing.new("Square")
                    ddBarBorder.Visible = vis; ddBarBorder.Transparency = 1; ddBarBorder.ZIndex = 361
                    ddBarBorder.Color = Color3.fromHex("#282828"); ddBarBorder.Filled = false; ddBarBorder.Thickness = 1
                    ddBarBorder.Position = ddBar.Position; ddBarBorder.Size = ddBar.Size; ddBarBorder.Corner = 6

                    local ddBarText = newText()
                    ddBarText.Visible = vis; ddBarText.Transparency = 1; ddBarText.ZIndex = 370
                    ddBarText.Color = Color3.fromHex("#646464")
                    ddBarText.Position = ddBar.Position + Vector2.new(10, 3)
                    ddBarText.Text = selected; ddBarText.Size = 12; ddBarText.Center = false
                    ddBarText.Outline = true; ddBarText.Font = Drawing.Fonts.Monospace

                    local ddArrow = newText()
                    ddArrow.Visible = vis; ddArrow.Transparency = 1; ddArrow.ZIndex = 370
                    ddArrow.Color = Color3.fromHex("#FFFFFF")
                    ddArrow.Position = ddBar.Position + Vector2.new(225, 3)
                    ddArrow.Text = "V"; ddArrow.Size = 12; ddArrow.Center = false
                    ddArrow.Outline = true; ddArrow.Font = Drawing.Fonts.Monospace

                    local ddDrop = Drawing.new("Square")
                    ddDrop.Visible = false; ddDrop.Transparency = 1; ddDrop.ZIndex = 450
                    ddDrop.Color = Color3.fromHex("#0a0a0a")
                    ddDrop.Position = ddBar.Position + Vector2.new(0, 25)
                    ddDrop.Size = Vector2.new(240, #options * 15 + 15); ddDrop.Filled = true; ddDrop.Corner = 6

                    local ddDropBorder = Drawing.new("Square")
                    ddDropBorder.Visible = false; ddDropBorder.Transparency = 1; ddDropBorder.ZIndex = 451
                    ddDropBorder.Color = Color3.fromHex("#282828"); ddDropBorder.Filled = false; ddDropBorder.Thickness = 1
                    ddDropBorder.Position = ddDrop.Position; ddDropBorder.Size = ddDrop.Size; ddDropBorder.Corner = 6

                    local optTexts = {}
                    for i, optName in ipairs(options) do
                        local ot = newText()
                        ot.Visible = false; ot.Transparency = 1; ot.ZIndex = 460
                        ot.Color = (optName == selected) and Color3.fromHex("#FFFFFF") or Color3.fromHex("#505050")
                        ot.Position = ddDrop.Position + Vector2.new(10, 8 + (i - 1) * 15)
                        ot.Text = optName; ot.Size = 12; ot.Center = false
                        ot.Outline = true; ot.Font = Drawing.Fonts.Monospace
                        optTexts[i] = ot
                    end

                    for _, el in ipairs({ddLabel, ddBar, ddBarBorder, ddBarText, ddArrow}) do
                        tabData.elements[#tabData.elements+1] = el
                    end

                    local ddData = {
                        isOpen = false, selected = selected, options = options,
                        bar = ddBar, drop = ddDrop, dropBorder = ddDropBorder,
                        barText = ddBarText, optTexts = optTexts, arrow = ddArrow,
                        label = ddLabel, barBorder = ddBarBorder,
                        panel = panel, yOffset = y, callback = callback,
                    }

                    ddData.setOpen = function(show)
                        if show then
                            ddDrop.Position = ddBar.Position + Vector2.new(0, 25)
                            ddDropBorder.Position = ddDrop.Position
                            ddDropBorder.Size = ddDrop.Size
                            for i, ot in ipairs(optTexts) do
                                ot.Position = ddDrop.Position + Vector2.new(10, 8 + (i - 1) * 15)
                            end
                        end
                        ddData.isOpen = show
                        ddDrop.Visible = show; ddDropBorder.Visible = show
                        for _, ot in ipairs(optTexts) do ot.Visible = show end
                    end

                    ddData.updateColors = function()
                        for i, ot in ipairs(optTexts) do
                            ot.Color = (options[i] == ddData.selected) and Color3.fromHex("#FFFFFF") or Color3.fromHex("#505050")
                        end
                        ddBarText.Text = ddData.selected
                    end

                    allDropdowns[#allDropdowns+1] = ddData
                    advanceY(40)

                    local ddRet = {}
                    ddRet.Get = function() return ddData.selected end
                    ddRet.Set = function(_, val)
                        ddData.selected = val
                        ddData.updateColors()
                    end
                    configWidgets[#configWidgets+1] = {
                        name = o.Name or "Single",
                        get = function() return ddData.selected end,
                        set = function(v) ddRet:Set(v) end,
                    }
                    return ddRet
                else
                    -- Inline list mode
                    local ssLabel = newText()
                    ssLabel.Visible = vis; ssLabel.Transparency = 1; ssLabel.ZIndex = 360
                    ssLabel.Color = Color3.fromHex("#FFFFFF")
                    ssLabel.Position = panelPos + Vector2.new(10, y)
                    ssLabel.Text = o.Name or "Select"; ssLabel.Size = 12; ssLabel.Center = false
                    ssLabel.Outline = true; ssLabel.Font = Drawing.Fonts.Monospace

                    local ssBox = Drawing.new("Square")
                    ssBox.Visible = vis; ssBox.Transparency = 1; ssBox.ZIndex = 360
                    ssBox.Color = Color3.fromHex("#0a0a0a")
                    ssBox.Position = panelPos + Vector2.new(10, y + 15)
                    ssBox.Size = Vector2.new(240, #options * 15 + 15); ssBox.Filled = true; ssBox.Corner = 6

                    local ssBoxBorder = Drawing.new("Square")
                    ssBoxBorder.Visible = vis; ssBoxBorder.Transparency = 1; ssBoxBorder.ZIndex = 361
                    ssBoxBorder.Color = Color3.fromHex("#282828"); ssBoxBorder.Filled = false; ssBoxBorder.Thickness = 1
                    ssBoxBorder.Position = ssBox.Position; ssBoxBorder.Size = ssBox.Size; ssBoxBorder.Corner = 6

                    local optTexts = {}
                    for i, optName in ipairs(options) do
                        local ot = newText()
                        ot.Visible = vis; ot.Transparency = 1; ot.ZIndex = 370
                        ot.Color = (optName == selected) and Color3.fromHex("#FFFFFF") or Color3.fromHex("#505050")
                        ot.Position = ssBox.Position + Vector2.new(10, 8 + (i - 1) * 15)
                        ot.Text = optName; ot.Size = 12; ot.Center = false
                        ot.Outline = true; ot.Font = Drawing.Fonts.Monospace
                        optTexts[i] = ot
                    end

                    for _, el in ipairs({ssLabel, ssBox, ssBoxBorder}) do
                        tabData.elements[#tabData.elements+1] = el
                    end
                    for _, ot in ipairs(optTexts) do tabData.elements[#tabData.elements+1] = ot end

                    local ssData = {
                        selected = selected, options = options, optTexts = optTexts,
                        box = ssBox, boxBorder = ssBoxBorder, label = ssLabel,
                        panel = panel, yOffset = y, callback = callback,
                    }

                    ssData.updateColors = function()
                        for i, ot in ipairs(optTexts) do
                            ot.Color = (options[i] == ssData.selected) and Color3.fromHex("#FFFFFF") or Color3.fromHex("#505050")
                        end
                    end

                    allSelects[#allSelects+1] = ssData
                    advanceY(#options * 15 + 35 + 5)

                    local ssRet = {}
                    ssRet.Get = function() return ssData.selected end
                    ssRet.Set = function(_, val)
                        ssData.selected = val
                        ssData.updateColors()
                    end
                    configWidgets[#configWidgets+1] = {
                        name = o.Name or "Single",
                        get = function() return ssData.selected end,
                        set = function(v) ssRet:Set(v) end,
                    }
                    return ssRet
                end
            end

            function Section:AddMulti(o)
                o = o or {}
                local y = getY()
                local panelPos = panel.Position
                local vis = (tabIndex == activeTab)
                local options = o.Options or {}
                local selectedMap = {}
                if o.Default then for _, v in ipairs(o.Default) do selectedMap[v] = true end end
                local callback = o.Callback or function() end
                local isDrop = (o.Drop ~= false)

                local function getSelected()
                    local sel = {}
                    for _, optName in ipairs(options) do
                        if selectedMap[optName] then sel[#sel+1] = optName end
                    end
                    return sel
                end

                if isDrop then
                    -- Dropdown mode (popup)
                    local mdLabel = newText()
                    mdLabel.Visible = vis; mdLabel.Transparency = 1; mdLabel.ZIndex = 360
                    mdLabel.Color = Color3.fromHex("#FFFFFF")
                    mdLabel.Position = panelPos + Vector2.new(10, y)
                    mdLabel.Text = o.Name or "MultiSelect"; mdLabel.Size = 12; mdLabel.Center = false
                    mdLabel.Outline = true; mdLabel.Font = Drawing.Fonts.Monospace

                    local mdBar = Drawing.new("Square")
                    mdBar.Visible = vis; mdBar.Transparency = 1; mdBar.ZIndex = 360
                    mdBar.Color = Color3.fromHex("#0a0a0a")
                    mdBar.Position = panelPos + Vector2.new(10, y + 15)
                    mdBar.Size = Vector2.new(240, 20); mdBar.Filled = true; mdBar.Corner = 6

                    local mdBarBorder = Drawing.new("Square")
                    mdBarBorder.Visible = vis; mdBarBorder.Transparency = 1; mdBarBorder.ZIndex = 361
                    mdBarBorder.Color = Color3.fromHex("#282828"); mdBarBorder.Filled = false; mdBarBorder.Thickness = 1
                    mdBarBorder.Position = mdBar.Position; mdBarBorder.Size = mdBar.Size; mdBarBorder.Corner = 6

                    local mdBarText = newText()
                    mdBarText.Visible = vis; mdBarText.Transparency = 1; mdBarText.ZIndex = 370
                    mdBarText.Color = Color3.fromHex("#646464")
                    mdBarText.Position = mdBar.Position + Vector2.new(10, 3)
                    mdBarText.Text = "None"; mdBarText.Size = 12; mdBarText.Center = false
                    mdBarText.Outline = true; mdBarText.Font = Drawing.Fonts.Monospace

                    local mdArrow = newText()
                    mdArrow.Visible = vis; mdArrow.Transparency = 1; mdArrow.ZIndex = 370
                    mdArrow.Color = Color3.fromHex("#FFFFFF")
                    mdArrow.Position = mdBar.Position + Vector2.new(225, 3)
                    mdArrow.Text = "V"; mdArrow.Size = 12; mdArrow.Center = false
                    mdArrow.Outline = true; mdArrow.Font = Drawing.Fonts.Monospace

                    local mdDrop = Drawing.new("Square")
                    mdDrop.Visible = false; mdDrop.Transparency = 1; mdDrop.ZIndex = 450
                    mdDrop.Color = Color3.fromHex("#0a0a0a")
                    mdDrop.Position = mdBar.Position + Vector2.new(0, 25)
                    mdDrop.Size = Vector2.new(240, #options * 15 + 15); mdDrop.Filled = true; mdDrop.Corner = 6

                    local mdDropBorder = Drawing.new("Square")
                    mdDropBorder.Visible = false; mdDropBorder.Transparency = 1; mdDropBorder.ZIndex = 451
                    mdDropBorder.Color = Color3.fromHex("#282828"); mdDropBorder.Filled = false; mdDropBorder.Thickness = 1
                    mdDropBorder.Position = mdDrop.Position; mdDropBorder.Size = mdDrop.Size; mdDropBorder.Corner = 6

                    local optTexts = {}
                    for i, optName in ipairs(options) do
                        local ot = newText()
                        ot.Visible = false; ot.Transparency = 1; ot.ZIndex = 460
                        ot.Color = selectedMap[optName] and Color3.fromHex("#FFFFFF") or Color3.fromHex("#505050")
                        ot.Position = mdDrop.Position + Vector2.new(10, 8 + (i - 1) * 15)
                        ot.Text = optName; ot.Size = 12; ot.Center = false
                        ot.Outline = true; ot.Font = Drawing.Fonts.Monospace
                        optTexts[i] = ot
                    end

                    for _, el in ipairs({mdLabel, mdBar, mdBarBorder, mdBarText, mdArrow}) do
                        tabData.elements[#tabData.elements+1] = el
                    end

                    local mdData = {
                        isOpen = false, selectedMap = selectedMap, options = options,
                        bar = mdBar, drop = mdDrop, dropBorder = mdDropBorder,
                        barText = mdBarText, optTexts = optTexts, arrow = mdArrow,
                        label = mdLabel, barBorder = mdBarBorder,
                        panel = panel, yOffset = y, callback = callback,
                    }

                    mdData.setOpen = function(show)
                        if show then
                            mdDrop.Position = mdBar.Position + Vector2.new(0, 25)
                            mdDropBorder.Position = mdDrop.Position
                            mdDropBorder.Size = mdDrop.Size
                            for i, ot in ipairs(optTexts) do
                                ot.Position = mdDrop.Position + Vector2.new(10, 8 + (i - 1) * 15)
                            end
                        end
                        mdData.isOpen = show
                        mdDrop.Visible = show; mdDropBorder.Visible = show
                        for _, ot in ipairs(optTexts) do ot.Visible = show end
                    end

                    mdData.updateColors = function()
                        for i, ot in ipairs(optTexts) do
                            ot.Color = selectedMap[options[i]] and Color3.fromHex("#FFFFFF") or Color3.fromHex("#505050")
                        end
                    end

                    mdData.updateBarText = function()
                        local names = getSelected()
                        if #names == 0 then mdBarText.Text = "None"
                        else
                            local full = table.concat(names, ", ")
                            if #full > 30 then mdBarText.Text = full:sub(1, 27) .. "..."
                            else mdBarText.Text = full end
                        end
                    end

                    mdData.updateBarText()
                    allMultiDropdowns[#allMultiDropdowns+1] = mdData
                    advanceY(40)

                    local mdRet = {}
                    mdRet.Get = function() return getSelected() end
                    configWidgets[#configWidgets+1] = {
                        name = o.Name or "Multi",
                        get = function() return getSelected() end,
                        set = function(v)
                            if type(v) ~= "table" then return end
                            for _, opt in ipairs(options) do selectedMap[opt] = false end
                            for _, sel in ipairs(v) do selectedMap[sel] = true end
                            mdData.updateColors(); mdData.updateBarText()
                        end,
                    }
                    return mdRet
                else
                    -- Inline multi-select list
                    local msLabel = newText()
                    msLabel.Visible = vis; msLabel.Transparency = 1; msLabel.ZIndex = 360
                    msLabel.Color = Color3.fromHex("#FFFFFF")
                    msLabel.Position = panelPos + Vector2.new(10, y)
                    msLabel.Text = o.Name or "MultiSelect"; msLabel.Size = 12; msLabel.Center = false
                    msLabel.Outline = true; msLabel.Font = Drawing.Fonts.Monospace

                    local msBox = Drawing.new("Square")
                    msBox.Visible = vis; msBox.Transparency = 1; msBox.ZIndex = 360
                    msBox.Color = Color3.fromHex("#0a0a0a")
                    msBox.Position = panelPos + Vector2.new(10, y + 15)
                    msBox.Size = Vector2.new(240, #options * 15 + 15); msBox.Filled = true; msBox.Corner = 6

                    local msBoxBorder = Drawing.new("Square")
                    msBoxBorder.Visible = vis; msBoxBorder.Transparency = 1; msBoxBorder.ZIndex = 361
                    msBoxBorder.Color = Color3.fromHex("#282828"); msBoxBorder.Filled = false; msBoxBorder.Thickness = 1
                    msBoxBorder.Position = msBox.Position; msBoxBorder.Size = msBox.Size; msBoxBorder.Corner = 6

                    local optTexts = {}
                    for i, optName in ipairs(options) do
                        local ot = newText()
                        ot.Visible = vis; ot.Transparency = 1; ot.ZIndex = 370
                        ot.Color = selectedMap[optName] and Color3.fromHex("#FFFFFF") or Color3.fromHex("#505050")
                        ot.Position = msBox.Position + Vector2.new(10, 8 + (i - 1) * 15)
                        ot.Text = optName; ot.Size = 12; ot.Center = false
                        ot.Outline = true; ot.Font = Drawing.Fonts.Monospace
                        optTexts[i] = ot
                    end

                    for _, el in ipairs({msLabel, msBox, msBoxBorder}) do
                        tabData.elements[#tabData.elements+1] = el
                    end
                    for _, ot in ipairs(optTexts) do tabData.elements[#tabData.elements+1] = ot end

                    local msData = {
                        selectedMap = selectedMap, options = options, optTexts = optTexts,
                        box = msBox, boxBorder = msBoxBorder, label = msLabel,
                        panel = panel, yOffset = y, callback = callback,
                    }

                    msData.updateColors = function()
                        for i, ot in ipairs(optTexts) do
                            ot.Color = selectedMap[options[i]] and Color3.fromHex("#FFFFFF") or Color3.fromHex("#505050")
                        end
                    end

                    allMultiSelects[#allMultiSelects+1] = msData
                    advanceY(#options * 15 + 35 + 5)

                    local msRet = {}
                    msRet.Get = function() return getSelected() end
                    configWidgets[#configWidgets+1] = {
                        name = o.Name or "Multi",
                        get = function() return getSelected() end,
                        set = function(v)
                            if type(v) ~= "table" then return end
                            for _, opt in ipairs(options) do selectedMap[opt] = false end
                            for _, sel in ipairs(v) do selectedMap[sel] = true end
                            msData.updateColors()
                        end,
                    }
                    return msRet
                end
            end
            tabData.sections[sectionIndex] = Section
            return Section
        end

        return Tab
    end

    -- Menu Key keybind in right panel of tab 1 (added by user via AddKeybind with RCMenu=false)
    -- Hotkey list toggle in right panel of tab 1
    -- These are added by the user script, not auto-added

    -- Build menuElements after tabs are created
    local function rebuildMenuElements()
        menuElements = {}
        addMenuEl(BG); addMenuEl(BG_Border); addMenuEl(Title1); addMenuEl(TitleText)
        for _, g in ipairs(glowLayers) do addMenuEl(g) end
        for _, tl in ipairs(tabLabels) do addMenuEl(tl) end
        for _, tabData in ipairs(tabs) do
            for _, el in ipairs(tabData.elements) do addMenuEl(el) end
        end
    end

    local function toggleMenu()
        rebuildMenuElements()
        menuOpen = not menuOpen
        for _, el in ipairs(menuElements) do
            el.Visible = menuOpen
        end
        if menuOpen then
            switchTab(activeTab)
            if hotkeyListOn then toggleHotkeyList(true) end
            for _, ip in ipairs(allInfoPanels) do
                if ip.visible then ip.setDrawingsVisible(true) end
            end
        else
            closeAllPopups()
            dragging = nil
        end
    end

    -- Slider drag state
    local sliderDrag = nil
    local sliderDragData = nil

    -- Main loop
    local function mainLoop()
    while true do
        wait(0.01)
        if isrbxactive() then
            local mouse1 = ismouse1pressed()
            local mouse2 = iskeypressed(2)
            local mPos = Vector2.new(Mouse.X, Mouse.Y)
            local pressed = mouse1 and not lastMouse1
            local rightPressed = mouse2 and not lastMouse2

            local menuKeyDown = iskeypressed(menuKey)
            if menuKeyDown and not lastMenuKey then
                toggleMenu()
            end
            lastMenuKey = menuKeyDown

            if menuOpen then

            -- Tab hover + click
            for i, tl in ipairs(tabLabels) do
                if i ~= activeTab then
                    local tp = tl.Position
                    local tw = #tl.Text * (charW + 0.5)
                    if isInside(mPos, tp, Vector2.new(tw, 14)) then
                        tl.Color = Color3.fromHex("#969696")
                        if pressed then switchTab(i) end
                    else
                        tl.Color = Color3.fromHex("#505050")
                    end
                end
            end

            -- Keybind listening (skip when config input is active)
            local cfgInputActive = cfgState and cfgState.getInputActive()
            for _, kb in ipairs(allKeybinds) do
                if kb.listening and not cfgInputActive then
                    for code, name in pairs(KeyNames) do
                        if code ~= 1 and iskeypressed(code) then
                            if code == 27 or code == 8 then
                                kb.key = nil
                                kb.bindText.Text = "[None]"
                            else
                                kb.key = code
                                kb.bindText.Text = "[" .. name .. "]"
                            end
                            if kb.menuBind then
                                menuKey = kb.key or 35
                                lastMenuKey = true -- prevent immediate toggle
                            end
                            kb.bindText.Position = Vector2.new(rightAlignX(kb.bindText.Text, kb.panel.Position, kb.panel.Size.X), kb.panel.Position.Y + kb.yPos)
                            kb.listening = false
                            if hotkeyListOn then updateHotkeyList() end
                            break
                        end
                    end
                end
            end

            -- Colorpicker hex input (only one CP can be focused at a time)
            for _, cp in ipairs(allColorpickers) do
                if cp.hexFocused then
                    local lk = cp._hexKeys or {}
                    cp._hexKeys = lk
                    local function appendChar(c)
                        if #cp.hexBuffer < 7 then  -- "#" + 6 hex
                            cp.hexBuffer = cp.hexBuffer .. c
                            cp.commitHex(true)  -- live update if currently valid
                            cp.HexText.Text = cp.hexBuffer .. "_"
                        end
                    end
                    -- 0-9
                    for code = 48, 57 do
                        local d = iskeypressed(code)
                        if d and not lk[code] then appendChar(string.char(code)) end
                        lk[code] = d
                    end
                    -- A-F
                    for code = 65, 70 do
                        local d = iskeypressed(code)
                        if d and not lk[code] then appendChar(string.char(code)) end
                        lk[code] = d
                    end
                    -- Backspace
                    local bs = iskeypressed(8)
                    if bs and not lk[8] and #cp.hexBuffer > 0 then
                        cp.hexBuffer = cp.hexBuffer:sub(1, -2)
                        cp.commitHex(true)
                        cp.HexText.Text = cp.hexBuffer .. "_"
                    end
                    lk[8] = bs
                    -- Enter
                    local en = iskeypressed(13)
                    if en and not lk[13] then cp.commitHex(false) end
                    lk[13] = en
                    -- Escape: cancel without applying buffer's intermediate state
                    local esc = iskeypressed(27)
                    if esc and not lk[27] then
                        cp.hexFocused = false
                        cp.hexBuffer = ""
                        cp.refreshHex()
                    end
                    lk[27] = esc
                    break  -- only one focused at a time
                end
            end

            -- Config text input
            if cfgState and activeTab == cfgState.tabIndex and cfgState.getInputActive() then
                local lk = cfgState.lastKeys
                -- A-Z
                for code = 65, 90 do
                    local down = iskeypressed(code)
                    if down and not lk[code] then
                        local ch = string.char(code)
                        if not iskeypressed(16) then ch = ch:lower() end
                        cfgState.setInputText(cfgState.getInputText() .. ch)
                        cfgState.updateInputDisplay()
                    end
                    lk[code] = down
                end
                -- 0-9
                for code = 48, 57 do
                    local down = iskeypressed(code)
                    if down and not lk[code] then
                        cfgState.setInputText(cfgState.getInputText() .. string.char(code))
                        cfgState.updateInputDisplay()
                    end
                    lk[code] = down
                end
                -- Space
                local spDown = iskeypressed(32)
                if spDown and not lk[32] then
                    cfgState.setInputText(cfgState.getInputText() .. " ")
                    cfgState.updateInputDisplay()
                end
                lk[32] = spDown
                -- Backspace
                local bsDown = iskeypressed(8)
                if bsDown and not lk[8] then
                    local t = cfgState.getInputText()
                    if #t > 0 then cfgState.setInputText(t:sub(1, -2)); cfgState.updateInputDisplay() end
                end
                lk[8] = bsDown
                -- Enter: create new config
                local enDown = iskeypressed(13)
                if enDown and not lk[13] then
                    local t = cfgState.getInputText()
                    if #t > 0 then
                        cfgState.saveConfig(t)
                        cfgState.setInputText("")
                        cfgState.setInputActive(false)
                        cfgState.refreshList()
                        cfgState.updateInputDisplay()
                    end
                end
                lk[13] = enDown
                -- Escape
                local escDown = iskeypressed(27)
                if escDown and not lk[27] then
                    cfgState.setInputText("")
                    cfgState.setInputActive(false)
                    cfgState.updateInputDisplay()
                end
                lk[27] = escDown
            end

            -- Dropdown hover
            for _, dd in ipairs(allDropdowns) do
                if dd.isOpen and dd.bar.Visible then
                    for i, ot in ipairs(dd.optTexts) do
                        if isInside(mPos, ot.Position, Vector2.new(220, 15)) then
                            if dd.options[i] ~= dd.selected then ot.Color = Color3.fromHex("#969696") end
                        else
                            ot.Color = (dd.options[i] == dd.selected) and Color3.fromHex("#FFFFFF") or Color3.fromHex("#505050")
                        end
                    end
                end
            end

            -- Select hover (only visible)
            for _, ss in ipairs(allSelects) do
                for i, ot in ipairs(ss.optTexts) do
                    if ot.Visible then
                        if isInside(mPos, ot.Position, Vector2.new(220, 15)) then
                            if ss.options[i] ~= ss.selected then ot.Color = Color3.fromHex("#969696") end
                        else
                            ot.Color = (ss.options[i] == ss.selected) and Color3.fromHex("#FFFFFF") or Color3.fromHex("#505050")
                        end
                    end
                end
            end

            -- MultiSelect inline hover (only visible)
            for _, ms in ipairs(allMultiSelects) do
                for i, ot in ipairs(ms.optTexts) do
                    if ot.Visible then
                        if isInside(mPos, ot.Position, Vector2.new(220, 15)) then
                            if not ms.selectedMap[ms.options[i]] then ot.Color = Color3.fromHex("#969696") end
                        else
                            ot.Color = ms.selectedMap[ms.options[i]] and Color3.fromHex("#FFFFFF") or Color3.fromHex("#505050")
                        end
                    end
                end
            end

            -- MultiDropdown hover
            for _, md in ipairs(allMultiDropdowns) do
                if md.isOpen and md.bar.Visible then
                    for i, ot in ipairs(md.optTexts) do
                        if isInside(mPos, ot.Position, Vector2.new(220, 15)) then
                            if not md.selectedMap[md.options[i]] then ot.Color = Color3.fromHex("#969696") end
                        else
                            ot.Color = md.selectedMap[md.options[i]] and Color3.fromHex("#FFFFFF") or Color3.fromHex("#505050")
                        end
                    end
                end
            end

            -- RC menu hover
            if rcMenuOpen then
                local rcOpts = {RCAlways, RCToggle, RCHold}
                local rcModes = {"always", "toggle", "hold"}
                local curMode = rcMenuTarget.mode
                for idx, opt in ipairs(rcOpts) do
                    if isInside(mPos, Vector2.new(RCMenu.Position.X, opt.Position.Y), Vector2.new(70, 14)) then
                        if rcModes[idx] ~= curMode then opt.Color = Color3.fromHex("#969696") end
                    else
                        opt.Color = (rcModes[idx] == curMode) and Color3.fromHex("#FFFFFF") or Color3.fromHex("#505050")
                    end
                end
            end

            -- Config button hover
            if cfgState and activeTab == cfgState.tabIndex then
                local sBtn, sBdr = cfgState.saveBtn, cfgState.saveBtnBorder
                local lBtn, lBdr = cfgState.loadBtn, cfgState.loadBtnBorder
                if isInside(mPos, sBtn.Position, sBtn.Size) then
                    sBtn.Color = Color3.fromHex("#0f0f0f"); sBdr.Color = Color3.fromHex("#3a3a3a")
                else
                    sBtn.Color = Color3.fromHex("#050505"); sBdr.Color = Color3.fromHex("#282828")
                end
                if isInside(mPos, lBtn.Position, lBtn.Size) then
                    lBtn.Color = Color3.fromHex("#0f0f0f"); lBdr.Color = Color3.fromHex("#3a3a3a")
                else
                    lBtn.Color = Color3.fromHex("#050505"); lBdr.Color = Color3.fromHex("#282828")
                end
            end

            -- Right-click detection for keybinds
            if rightPressed then
                local rcHandled = false
                for _, kb in ipairs(allKeybinds) do
                    if kb.rcEnabled and kb.bindText.Visible then
                        local bw = #kb.bindText.Text * (charW + 0.5)
                        if isInside(mPos, kb.bindText.Position, Vector2.new(bw, 14)) then
                            showRCMenu(mPos, kb)
                            rcHandled = true
                            break
                        end
                    end
                end
                if not rcHandled and rcMenuOpen and not isInside(mPos, RCMenu.Position, RCMenu.Size) then
                    hideRCMenu()
                end
            end

            -- CP drag handling
            for _, cp in ipairs(allColorpickers) do
                if cp.cpDrag and mouse1 then
                    cp.handleDrag(mPos)
                end
            end

            -- Slider drag handling
            if sliderDrag and mouse1 then
                if sliderDrag == "slider" then
                    local sd = sliderDragData
                    local sx = math.clamp((mPos.X - sd.bar.Position.X) / 215, 0, 1)
                    sd.val = sd.min + sx * (sd.max - sd.min)
                    sd.update()
                    sd.callback(sd.val)
                elseif sliderDrag == "rangeleft" then
                    local rd = sliderDragData
                    local sx = math.clamp((mPos.X - rd.bar.Position.X) / 215, 0, 1)
                    rd.left = math.clamp(rd.min + sx * (rd.max - rd.min), rd.min, rd.right - 10)
                    rd.update()
                    rd.callback(rd.left, rd.right)
                elseif sliderDrag == "rangeright" then
                    local rd = sliderDragData
                    local sx = math.clamp((mPos.X - rd.bar.Position.X) / 215, 0, 1)
                    rd.right = math.clamp(rd.min + sx * (rd.max - rd.min), rd.left + 10, rd.max)
                    rd.update()
                    rd.callback(rd.left, rd.right)
                end
            end

            if pressed then
                local clickConsumed = false

                -- RC menu click
                if rcMenuOpen then
                    local rcOpts = {RCAlways, RCToggle, RCHold}
                    local rcModes = {"always", "toggle", "hold"}
                    local rcClicked = false
                    for idx, opt in ipairs(rcOpts) do
                        if isInside(mPos, Vector2.new(RCMenu.Position.X, opt.Position.Y), Vector2.new(70, 14)) then
                            rcMenuTarget.mode = rcModes[idx]
                            hideRCMenu()
                            if hotkeyListOn then updateHotkeyList() end
                            rcClicked = true; break
                        end
                    end
                    if not rcClicked and not isInside(mPos, RCMenu.Position, RCMenu.Size) then
                        hideRCMenu()
                    end
                    clickConsumed = true
                end

                -- Colorpicker clicks (only match visible)
                if not clickConsumed then
                    for _, cp in ipairs(allColorpickers) do
                        if cp.box.Visible and cp.handleClick(mPos, true) then
                            clickConsumed = true; break
                        end
                    end
                end

                -- Dropdown clicks (only match visible)
                if not clickConsumed then
                    for _, dd in ipairs(allDropdowns) do
                        if dd.bar.Visible and isInside(mPos, dd.bar.Position, dd.bar.Size) then
                            dd.setOpen(not dd.isOpen)
                            clickConsumed = true; break
                        elseif dd.isOpen then
                            local ddClicked = false
                            for i, ot in ipairs(dd.optTexts) do
                                if isInside(mPos, ot.Position, Vector2.new(220, 15)) then
                                    dd.selected = dd.options[i]
                                    dd.updateColors(); dd.setOpen(false)
                                    dd.callback(dd.selected)
                                    ddClicked = true; clickConsumed = true; break
                                end
                            end
                            if not ddClicked then
                                if isInside(mPos, dd.drop.Position, dd.drop.Size) then
                                    clickConsumed = true
                                else
                                    dd.setOpen(false)
                                end
                            end
                            if ddClicked then break end
                        end
                    end
                end

                -- MultiDropdown clicks (only match visible)
                if not clickConsumed then
                    for _, md in ipairs(allMultiDropdowns) do
                        if md.bar.Visible and isInside(mPos, md.bar.Position, md.bar.Size) then
                            md.setOpen(not md.isOpen)
                            clickConsumed = true; break
                        elseif md.isOpen then
                            local mdClicked = false
                            for i, ot in ipairs(md.optTexts) do
                                if isInside(mPos, ot.Position, Vector2.new(220, 15)) then
                                    md.selectedMap[md.options[i]] = not md.selectedMap[md.options[i]]
                                    md.updateColors(); md.updateBarText()
                                    local sel = {}
                                    for _, optName in ipairs(md.options) do
                                        if md.selectedMap[optName] then sel[#sel+1] = optName end
                                    end
                                    md.callback(sel)
                                    mdClicked = true; clickConsumed = true; break
                                end
                            end
                            if not mdClicked then
                                if isInside(mPos, md.drop.Position, md.drop.Size) then
                                    clickConsumed = true
                                else
                                    md.setOpen(false)
                                end
                            end
                            if mdClicked then break end
                        end
                    end
                end

                if not clickConsumed then
                    -- Keybind clicks (start listening, only match visible)
                    for _, kb in ipairs(allKeybinds) do
                        local bw = #kb.bindText.Text * (charW + 0.5)
                        if kb.bindText.Visible and isInside(mPos, kb.bindText.Position, Vector2.new(bw, 14)) then
                            kb.listening = true
                            kb.bindText.Text = "[...]"
                            kb.bindText.Position = Vector2.new(rightAlignX(kb.bindText.Text, kb.panel.Position, kb.panel.Size.X), kb.panel.Position.Y + kb.yPos)
                        end
                    end

                    -- Toggle clicks (only match visible/active tab)
                    for _, tg in ipairs(allToggles) do
                        if tg.box.Visible and isInside(mPos, tg.box.Position, tg.box.Size) then
                            tg.onClick()
                        end
                    end

                    -- Colorpicker toggle clicks (checkbox part, only match visible)
                    for _, cp in ipairs(allColorpickers) do
                        if cp.hasToggle and cp.box.Visible and isInside(mPos, cp.box.Position, cp.box.Size) then
                            cp.onClick()
                        end
                    end

                    -- Select clicks (only match visible)
                    for _, ss in ipairs(allSelects) do
                        for i, ot in ipairs(ss.optTexts) do
                            if ot.Visible and isInside(mPos, ot.Position, Vector2.new(220, 15)) then
                                ss.selected = ss.options[i]
                                ss.updateColors()
                                ss.callback(ss.selected)
                                break
                            end
                        end
                    end

                    -- MultiSelect inline clicks (only match visible)
                    for _, ms in ipairs(allMultiSelects) do
                        for i, ot in ipairs(ms.optTexts) do
                            if ot.Visible and isInside(mPos, ot.Position, Vector2.new(220, 15)) then
                                ms.selectedMap[ms.options[i]] = not ms.selectedMap[ms.options[i]]
                                ms.updateColors()
                                local sel = {}
                                for _, optName in ipairs(ms.options) do
                                    if ms.selectedMap[optName] then sel[#sel+1] = optName end
                                end
                                ms.callback(sel)
                                break
                            end
                        end
                    end

                    -- Hotkey list panel drag
                    if hotkeyListOn and isInside(mPos, HotkeyTitleBG.Position, HotkeyTitleBG.Size) then
                        hkDragging = true; hkDragStart = mPos; hkStartPos = HotkeyBG.Position
                    end

                    -- Info panel drag
                    for _, ip in ipairs(allInfoPanels) do
                        if ip.visible and isInside(mPos, ip.titleBG.Position, ip.titleBG.Size) then
                            ip.dragging = true; ip.dragStart = mPos; ip.startPos = ip.bg.Position
                        end
                    end

                    -- Slider clicks (only match visible/active tab sliders)
                    for _, sd in ipairs(allSliders) do
                        if sd.bar.Visible then
                            if isInside(mPos, sd.bar.Position, sd.bar.Size) then
                                sliderDrag = "slider"; sliderDragData = sd
                                local sx = math.clamp((mPos.X - sd.bar.Position.X) / 215, 0, 1)
                                sd.val = sd.min + sx * (sd.max - sd.min)
                                sd.update(); sd.callback(sd.val)
                                break
                            elseif isInside(mPos, sd.minus.Position, Vector2.new(10, 14)) then
                                sd.val = math.clamp(sd.val - sd.step, sd.min, sd.max)
                                sd.update(); sd.callback(sd.val)
                                break
                            elseif isInside(mPos, sd.plus.Position, Vector2.new(10, 14)) then
                                sd.val = math.clamp(sd.val + sd.step, sd.min, sd.max)
                                sd.update(); sd.callback(sd.val)
                                break
                            end
                        end
                    end

                    -- Range slider clicks (only match visible/active tab sliders)
                    for _, rd in ipairs(allRangeSliders) do
                        if rd.bar.Visible then
                            if isInside(mPos, rd.bar.Position, rd.bar.Size) then
                                local sx = math.clamp((mPos.X - rd.bar.Position.X) / 215, 0, 1)
                                local clickVal = rd.min + sx * (rd.max - rd.min)
                                if math.abs(clickVal - rd.left) <= math.abs(clickVal - rd.right) then
                                    sliderDrag = "rangeleft"; sliderDragData = rd
                                    rd.left = math.clamp(clickVal, rd.min, rd.right - 10)
                                else
                                    sliderDrag = "rangeright"; sliderDragData = rd
                                    rd.right = math.clamp(clickVal, rd.left + 10, rd.max)
                                end
                                rd.update(); rd.callback(rd.left, rd.right)
                                break
                            elseif isInside(mPos, rd.minus.Position, Vector2.new(10, 14)) then
                                rd.left = math.clamp(rd.left - rd.step, rd.min, rd.right - 10)
                                rd.update(); rd.callback(rd.left, rd.right)
                                break
                            elseif isInside(mPos, rd.plus.Position, Vector2.new(10, 14)) then
                                rd.right = math.clamp(rd.right + rd.step, rd.left + 10, rd.max)
                                rd.update(); rd.callback(rd.left, rd.right)
                                break
                            end
                        end
                    end

                    -- Config tab clicks
                    if cfgState and activeTab == cfgState.tabIndex then
                        if isInside(mPos, cfgState.inputBox.Position, cfgState.inputBox.Size) then
                            cfgState.setInputActive(true)
                            cfgState.updateInputDisplay()
                            clickConsumed = true
                        elseif isInside(mPos, cfgState.saveBtn.Position, cfgState.saveBtn.Size) then
                            local names = cfgState.getNames()
                            local name = names[cfgState.getSelectedIdx()]
                            if name then
                                cfgState.saveConfig(name)
                                local txt = cfgState.saveBtnText
                                txt.Color = Color3.fromRGB(0, 220, 80)
                                task.spawn(function() task.wait(1); txt.Color = Color3.fromHex("#FFFFFF") end)
                            end
                            cfgState.setInputActive(false); cfgState.updateInputDisplay()
                            clickConsumed = true
                        elseif isInside(mPos, cfgState.loadBtn.Position, cfgState.loadBtn.Size) then
                            local names = cfgState.getNames()
                            local name = names[cfgState.getSelectedIdx()]
                            if name then
                                cfgState.loadConfig(name)
                                local txt = cfgState.loadBtnText
                                txt.Color = Color3.fromRGB(0, 220, 80)
                                task.spawn(function() task.wait(1); txt.Color = Color3.fromHex("#FFFFFF") end)
                            end
                            cfgState.setInputActive(false); cfgState.updateInputDisplay()
                            clickConsumed = true
                        elseif isInside(mPos, cfgState.listBox.Position, cfgState.listBox.Size) then
                            -- Check X delete button on selected entry first
                            local selIdx = cfgState.getSelectedIdx()
                            local names = cfgState.getNames()
                            local xClicked = false
                            if selIdx >= 1 and selIdx <= #names and selIdx <= 7 then
                                local xBtn = cfgState.entryPool[selIdx].xBtn
                                if xBtn.Visible and isInside(mPos, xBtn.Position, Vector2.new(12, 14)) then
                                    cfgState.deleteConfig(names[selIdx])
                                    cfgState.refreshList()
                                    xClicked = true
                                end
                            end
                            if not xClicked then
                                local relY = mPos.Y - cfgState.listBox.Position.Y - 5
                                local idx = math.floor(relY / 22) + 1
                                if idx >= 1 and idx <= #names then
                                    cfgState.setSelectedIdx(idx)
                                    cfgState.refreshList()
                                end
                            end
                            cfgState.setInputActive(false); cfgState.updateInputDisplay()
                            clickConsumed = true
                        else
                            if cfgState.getInputActive() then
                                cfgState.setInputActive(false); cfgState.updateInputDisplay()
                            end
                        end
                    end

                    -- Title bar drag
                    if isInside(mPos, Title1.Position, Title1.Size) then
                        closeAllPopups()
                        dragging = BG; dragStart = mPos; startBGPos = BG.Position
                    end
                end -- not clickConsumed
            end -- pressed

            -- Mouse up
            if not mouse1 and lastMouse1 then
                dragging = nil
                sliderDrag = nil; sliderDragData = nil
                hkDragging = false
                for _, ip in ipairs(allInfoPanels) do ip.dragging = false end
                for _, cp in ipairs(allColorpickers) do cp.cpDrag = nil end
            end

            -- Window dragging
            if dragging and mouse1 then
                local delta = mPos - dragStart
                local newPos = startBGPos + delta
                BG.Position = newPos
                BG_Border.Position = newPos
                Title1.Position = newPos + Vector2.new(2, 2)
                TitleText.Position = newPos + Vector2.new(10, 8)

                -- Tab labels
                for i, tl in ipairs(tabLabels) do
                    local xOff = tabXOffsets[i] or 0
                    tl.Position = newPos + Vector2.new(xOff + 2, 10)
                end

                -- Panels and their contents
                for j, tabData in ipairs(tabs) do
                    local p1 = tabData.panel1
                    local p2 = tabData.panel2
                    local oldP1 = p1.Position
                    local newP1 = newPos + Vector2.new(10, 45)
                    local newP2 = newPos + Vector2.new(280, 45)
                    local deltaP1 = newP1 - oldP1
                    local deltaP2 = newP2 - p2.Position

                    p1.Position = newP1
                    p2.Position = newP2
                    tabData.panel1Border.Position = newP1; tabData.panel1Border.Size = p1.Size
                    tabData.panel2Border.Position = newP2; tabData.panel2Border.Size = p2.Size
                    tabData.panelText1.Position = newP1 + Vector2.new(20, -5)
                    tabData.panelText2.Position = newP1 + Vector2.new(290, -5)

                    -- Sub-panels
                    local p3 = tabData.panel3
                    local p4 = tabData.panel4
                    local oldP3, oldP4
                    if p3 then
                        oldP3 = p3.Position
                        local newP3 = newP1 + Vector2.new(0, tabData.panel1Height + 10)
                        p3.Position = newP3
                        tabData.panel3Border.Position = newP3
                        tabData.panelText3.Position = newP3 + Vector2.new(20, -5)
                    end
                    if p4 then
                        oldP4 = p4.Position
                        local newP4 = newP2 + Vector2.new(0, tabData.panel2Height + 10)
                        p4.Position = newP4
                        tabData.panel4Border.Position = newP4
                        tabData.panelText4.Position = newP4 + Vector2.new(20, -5)
                    end

                    -- Move all elements by delta based on which panel they belong to
                    local skipSet = {[p1]=true, [p2]=true, [tabData.panelText1]=true, [tabData.panelText2]=true,
                        [tabData.panel1Border]=true, [tabData.panel2Border]=true}
                    if p3 then skipSet[p3]=true; skipSet[tabData.panel3Border]=true; skipSet[tabData.panelText3]=true end
                    if p4 then skipSet[p4]=true; skipSet[tabData.panel4Border]=true; skipSet[tabData.panelText4]=true end

                    for _, el in ipairs(tabData.elements) do
                        if not skipSet[el] and el.Position then
                            -- Determine which panel this element belongs to by X and Y
                            local isRight = math.abs(el.Position.X - oldP1.X) > math.abs(el.Position.X - (oldP1.X + 270))
                            if isRight then
                                if p4 and oldP4 and el.Position.Y >= oldP4.Y then
                                    el.Position = el.Position + (p4.Position - oldP4)
                                else
                                    el.Position = el.Position + deltaP2
                                end
                            else
                                if p3 and oldP3 and el.Position.Y >= oldP3.Y then
                                    el.Position = el.Position + (p3.Position - oldP3)
                                else
                                    el.Position = el.Position + deltaP1
                                end
                            end
                        end
                    end

                    -- Update slider/range slider positions (only call update for active tab to avoid re-showing hidden fills)
                    local isActive = (j == activeTab)
                    for _, sd in ipairs(tabData.sliders) do
                        sd.bar.Position = sd.panel.Position + Vector2.new(20, sd.yOffset + 15)
                        sd.barBorder.Position = sd.bar.Position
                        sd.fill.Position = sd.bar.Position
                        if isActive then sd.update() end
                    end
                    for _, rd in ipairs(tabData.rangeSliders) do
                        rd.bar.Position = rd.panel.Position + Vector2.new(20, rd.yOffset + 15)
                        rd.barBorder.Position = rd.bar.Position
                        if isActive then rd.update() end
                    end
                end

                -- Update keybind positions
                for _, kb in ipairs(allKeybinds) do
                    kb.bindText.Position = Vector2.new(rightAlignX(kb.bindText.Text, kb.panel.Position, kb.panel.Size.X), kb.panel.Position.Y + kb.yPos)
                end

                -- Update CP positions if open
                if openCP then openCP.updatePositions() end

                -- Glow
                for i = 1, #glowLayers do
                    local s = glowSpreads[i]
                    glowLayers[i].Position = Vector2.new(newPos.X - s, newPos.Y - s)
                end
            end

            -- Hotkey list dragging
            if hkDragging and mouse1 then
                local delta = mPos - hkDragStart
                HotkeyBG.Position = hkStartPos + delta
                updateHKPositions()
            end

            -- Info panel dragging
            for _, ip in ipairs(allInfoPanels) do
                if ip.dragging and mouse1 then
                    local delta = mPos - ip.dragStart
                    ip.bg.Position = ip.startPos + delta
                    ip.updatePositions()
                end
            end

            end -- menuOpen

            -- Keybind active state tracking (runs even when menu closed)
            for _, kb in ipairs(allKeybinds) do
                if kb.key then
                    local keyDown = iskeypressed(kb.key)
                    if not kb.isStandalone and kb.toggleRef and not kb.toggleRef.state then
                        kb.active = false
                    else
                        if kb.mode == "always" then
                            kb.active = true
                        elseif kb.mode == "hold" then
                            kb.active = keyDown
                        elseif kb.mode == "toggle" then
                            if keyDown and not kb.lastKeyState then
                                kb.active = not kb.active
                            end
                        end
                    end
                    kb.lastKeyState = keyDown
                else
                    if not kb.isStandalone and kb.toggleRef then
                        kb.active = kb.toggleRef.state
                    elseif kb.mode == "always" then
                        kb.active = true
                    else
                        kb.active = false
                    end
                end
            end
            if hotkeyListOn then updateHotkeyList() end

            lastMouse1 = mouse1
            lastMouse2 = mouse2
        end
    end
    end
    function Window:AddConfigTab()
        local HttpService = game:GetService("HttpService")
        local Tab = Window:AddTab("Config")
        local CfgLeft = Tab:AddSection("Config")
        local CfgRight = Tab:AddSection("Options")

        -- Config directory
        local configDir = configPath
        if gameName ~= "" then configDir = configDir .. "\\" .. gameName end

        -- Create folders
        pcall(function()
            local parts = {}
            for part in configDir:gmatch("[^\\]+") do parts[#parts+1] = part end
            local path = ""
            for _, part in ipairs(parts) do
                path = path == "" and part or (path .. "\\" .. part)
                if not isfolder(path) then makefolder(path) end
            end
        end)

        -- Left panel: config UI
        local p = CfgLeft._panel
        local td = CfgLeft._tabData
        local ti = CfgLeft._tabIndex
        local vis = (ti == activeTab)
        local baseY = td.panel1Y

        -- Config list box
        local listBox = Drawing.new("Square")
        listBox.Visible = vis; listBox.Transparency = 1; listBox.ZIndex = 130
        listBox.Color = Color3.fromHex("#050505")
        listBox.Position = p.Position + Vector2.new(10, baseY)
        listBox.Size = Vector2.new(240, 160); listBox.Filled = true; listBox.Corner = 6

        local listBoxBorder = Drawing.new("Square")
        listBoxBorder.Visible = vis; listBoxBorder.Transparency = 1; listBoxBorder.ZIndex = 131
        listBoxBorder.Color = Color3.fromHex("#282828"); listBoxBorder.Filled = false; listBoxBorder.Thickness = 1
        listBoxBorder.Position = listBox.Position; listBoxBorder.Size = listBox.Size; listBoxBorder.Corner = 6

        for _, el in ipairs({listBox, listBoxBorder}) do
            td.elements[#td.elements+1] = el
        end

        -- Entry pool (max 7 visible entries)
        local MAX_ENTRIES = 7
        local entryPool = {}
        for i = 1, MAX_ENTRIES do
            local hl = Drawing.new("Square")
            hl.Visible = false; hl.Transparency = 1; hl.ZIndex = 132
            hl.Color = Color3.fromHex("#1a1a1a")
            hl.Size = Vector2.new(230, 20); hl.Filled = true; hl.Corner = 4

            local txt = newText()
            txt.Visible = false; txt.Transparency = 1; txt.ZIndex = 140
            txt.Color = Color3.fromHex("#FFFFFF"); txt.Size = 12; txt.Center = false
            txt.Outline = true; txt.Font = Drawing.Fonts.Monospace

            local xBtn = newText()
            xBtn.Visible = false; xBtn.Transparency = 1; xBtn.ZIndex = 141
            xBtn.Color = Color3.fromHex("#505050"); xBtn.Text = "X"; xBtn.Size = 12
            xBtn.Center = false; xBtn.Outline = true; xBtn.Font = Drawing.Fonts.Monospace

            entryPool[i] = {highlight = hl, text = txt, xBtn = xBtn}
            td.elements[#td.elements+1] = hl
            td.elements[#td.elements+1] = txt
            td.elements[#td.elements+1] = xBtn
        end

        -- Config state
        local cfgNames = {}
        local selectedIdx = 1
        local inputText = ""
        local inputActive = false
        local lastKeys = {}

        -- List configs from disk
        local function getConfigNames()
            local names = {}
            pcall(function()
                if isfolder(configDir) then
                    local files = listfiles(configDir)
                    for _, f in ipairs(files) do
                        local name = f:match("([^\\]+)%.json$")
                        if name then names[#names+1] = name end
                    end
                end
            end)
            table.sort(names)
            return names
        end

        -- Refresh list display
        local function refreshList()
            cfgNames = getConfigNames()
            if selectedIdx > #cfgNames then selectedIdx = #cfgNames end
            if selectedIdx < 1 then selectedIdx = 1 end
            local isVis = (activeTab == ti)
            for i = 1, MAX_ENTRIES do
                local entry = entryPool[i]
                if i <= #cfgNames then
                    local isSel = (i == selectedIdx)
                    entry.highlight.Visible = isVis and isSel
                    entry.highlight.Position = listBox.Position + Vector2.new(5, 5 + (i - 1) * 22)
                    entry.text.Visible = isVis
                    entry.text.Text = cfgNames[i]
                    entry.text.Position = listBox.Position + Vector2.new(10, 7 + (i - 1) * 22)
                    entry.text.Color = isSel and Color3.fromHex("#FFFFFF") or Color3.fromHex("#808080")
                    -- X delete button on selected entry
                    entry.xBtn.Visible = isVis and isSel
                    entry.xBtn.Position = listBox.Position + Vector2.new(224, 7 + (i - 1) * 22)
                    entry.xBtn.Color = Color3.fromHex("#808080")
                else
                    entry.highlight.Visible = false
                    entry.text.Visible = false
                    entry.xBtn.Visible = false
                end
            end
        end

        -- Save config to file
        local function saveConfig(name)
            local data = {}
            for _, w in ipairs(configWidgets) do
                data[w.name] = w.get()
            end
            data["__hkPos"] = {HotkeyBG.Position.X, HotkeyBG.Position.Y}
            for i, ip in ipairs(allInfoPanels) do
                data["__ipPos" .. i] = {ip.bg.Position.X, ip.bg.Position.Y}
            end
            pcall(function()
                writefile(configDir .. "\\" .. name .. ".json", HttpService:JSONEncode(data))
            end)
        end

        local function loadConfig(name)
            local path = configDir .. "\\" .. name .. ".json"
            local ok, data = pcall(function()
                return HttpService:JSONDecode(readfile(path))
            end)
            if not ok or type(data) ~= "table" then return end
            for _, w in ipairs(configWidgets) do
                if data[w.name] ~= nil then
                    pcall(w.set, data[w.name])
                end
            end
            if data["__hkPos"] then
                pcall(function()
                    HotkeyBG.Position = Vector2.new(data["__hkPos"][1], data["__hkPos"][2])
                    updateHKPositions()
                end)
            end
            for i, ip in ipairs(allInfoPanels) do
                if data["__ipPos" .. i] then
                    pcall(function()
                        ip.bg.Position = Vector2.new(data["__ipPos" .. i][1], data["__ipPos" .. i][2])
                        ip.updatePositions()
                    end)
                end
            end
        end

        -- Delete config from disk
        local function deleteConfig(name)
            pcall(function()
                local path = configDir .. "\\" .. name .. ".json"
                if isfile(path) then delfile(path) end
            end)
        end

        -- Input box
        local inputY = baseY + 170
        local inputBox = Drawing.new("Square")
        inputBox.Visible = vis; inputBox.Transparency = 1; inputBox.ZIndex = 130
        inputBox.Color = Color3.fromHex("#050505")
        inputBox.Position = p.Position + Vector2.new(10, inputY)
        inputBox.Size = Vector2.new(240, 25); inputBox.Filled = true; inputBox.Corner = 6

        local inputBoxBorder = Drawing.new("Square")
        inputBoxBorder.Visible = vis; inputBoxBorder.Transparency = 1; inputBoxBorder.ZIndex = 131
        inputBoxBorder.Color = Color3.fromHex("#282828"); inputBoxBorder.Filled = false; inputBoxBorder.Thickness = 1
        inputBoxBorder.Position = inputBox.Position; inputBoxBorder.Size = inputBox.Size; inputBoxBorder.Corner = 6

        local inputDisplay = newText()
        inputDisplay.Visible = vis; inputDisplay.Transparency = 1; inputDisplay.ZIndex = 140
        inputDisplay.Color = Color3.fromHex("#505050")
        inputDisplay.Position = inputBox.Position + Vector2.new(8, 5)
        inputDisplay.Text = "New config..."; inputDisplay.Size = 12; inputDisplay.Center = false
        inputDisplay.Outline = true; inputDisplay.Font = Drawing.Fonts.Monospace

        for _, el in ipairs({inputBox, inputBoxBorder, inputDisplay}) do
            td.elements[#td.elements+1] = el
        end

        local function updateInputDisplay()
            if inputActive then
                if #inputText > 0 then
                    inputDisplay.Text = inputText .. "|"
                    inputDisplay.Color = Color3.fromHex("#FFFFFF")
                else
                    inputDisplay.Text = "|"
                    inputDisplay.Color = Color3.fromHex("#505050")
                end
                inputBoxBorder.Color = Color3.fromHex("#505050")
            else
                if #inputText > 0 then
                    inputDisplay.Text = inputText
                    inputDisplay.Color = Color3.fromHex("#FFFFFF")
                else
                    inputDisplay.Text = "New config..."
                    inputDisplay.Color = Color3.fromHex("#505050")
                end
                inputBoxBorder.Color = Color3.fromHex("#282828")
            end
        end

        -- Save / Load buttons (aligned with input bar)
        local btnY = inputY + 35
        local saveBtn = Drawing.new("Square")
        saveBtn.Visible = vis; saveBtn.Transparency = 1; saveBtn.ZIndex = 130
        saveBtn.Color = Color3.fromHex("#050505")
        saveBtn.Position = p.Position + Vector2.new(10, btnY)
        saveBtn.Size = Vector2.new(117, 25); saveBtn.Filled = true; saveBtn.Corner = 6

        local saveBtnBorder = Drawing.new("Square")
        saveBtnBorder.Visible = vis; saveBtnBorder.Transparency = 1; saveBtnBorder.ZIndex = 131
        saveBtnBorder.Color = Color3.fromHex("#282828"); saveBtnBorder.Filled = false; saveBtnBorder.Thickness = 1
        saveBtnBorder.Position = saveBtn.Position; saveBtnBorder.Size = saveBtn.Size; saveBtnBorder.Corner = 6

        local saveBtnText = newText()
        saveBtnText.Visible = vis; saveBtnText.Transparency = 1; saveBtnText.ZIndex = 140
        saveBtnText.Color = Color3.fromHex("#FFFFFF")
        saveBtnText.Position = saveBtn.Position + Vector2.new(48, 5)
        saveBtnText.Text = "Save"; saveBtnText.Size = 12; saveBtnText.Center = false
        saveBtnText.Outline = true; saveBtnText.Font = Drawing.Fonts.Monospace

        local loadBtn = Drawing.new("Square")
        loadBtn.Visible = vis; loadBtn.Transparency = 1; loadBtn.ZIndex = 130
        loadBtn.Color = Color3.fromHex("#050505")
        loadBtn.Position = p.Position + Vector2.new(133, btnY)
        loadBtn.Size = Vector2.new(117, 25); loadBtn.Filled = true; loadBtn.Corner = 6

        local loadBtnBorder = Drawing.new("Square")
        loadBtnBorder.Visible = vis; loadBtnBorder.Transparency = 1; loadBtnBorder.ZIndex = 131
        loadBtnBorder.Color = Color3.fromHex("#282828"); loadBtnBorder.Filled = false; loadBtnBorder.Thickness = 1
        loadBtnBorder.Position = loadBtn.Position; loadBtnBorder.Size = loadBtn.Size; loadBtnBorder.Corner = 6

        local loadBtnText = newText()
        loadBtnText.Visible = vis; loadBtnText.Transparency = 1; loadBtnText.ZIndex = 140
        loadBtnText.Color = Color3.fromHex("#FFFFFF")
        loadBtnText.Position = loadBtn.Position + Vector2.new(48, 5)
        loadBtnText.Text = "Load"; loadBtnText.Size = 12; loadBtnText.Center = false
        loadBtnText.Outline = true; loadBtnText.Font = Drawing.Fonts.Monospace

        for _, el in ipairs({saveBtn, saveBtnBorder, saveBtnText, loadBtn, loadBtnBorder, loadBtnText}) do
            td.elements[#td.elements+1] = el
        end

        -- Path label below buttons
        local fullPath = configDir
        local pathLabel = newText()
        pathLabel.Visible = vis; pathLabel.Transparency = 1; pathLabel.ZIndex = 140
        pathLabel.Color = Color3.fromHex("#505050")
        pathLabel.Position = p.Position + Vector2.new(10, btnY + 35)
        pathLabel.Text = fullPath; pathLabel.Size = 12; pathLabel.Center = false
        pathLabel.Outline = true; pathLabel.Font = Drawing.Fonts.Monospace
        td.elements[#td.elements+1] = pathLabel

        -- Store config state for main loop access
        cfgState = {
            tabIndex = ti,
            listBox = listBox,
            inputBox = inputBox,
            saveBtn = saveBtn,
            saveBtnBorder = saveBtnBorder,
            saveBtnText = saveBtnText,
            loadBtn = loadBtn,
            loadBtnBorder = loadBtnBorder,
            loadBtnText = loadBtnText,
            refreshList = refreshList,
            saveConfig = saveConfig,
            loadConfig = loadConfig,
            deleteConfig = deleteConfig,
            entryPool = entryPool,
            updateInputDisplay = updateInputDisplay,
            getInputActive = function() return inputActive end,
            setInputActive = function(v) inputActive = v end,
            getInputText = function() return inputText end,
            setInputText = function(v) inputText = v end,
            getSelectedIdx = function() return selectedIdx end,
            setSelectedIdx = function(v) selectedIdx = v end,
            getNames = function() return cfgNames end,
            lastKeys = lastKeys,
        }

        -- Initial list refresh
        refreshList()

        -- Right panel: hardcoded Menu Key + Hotkey List, then return section for user widgets
        CfgRight:AddKeybind({
            Name = "Menu Key",
            Default = 35,
            Mode = "always",
            MenuBind = true,
        })

        CfgRight:AddToggle({
            Name = "Hotkey List",
            Default = true,
            Callback = function(val)
                Window:ToggleHotkeyList(val)
            end
        })

        local ConfigTab = {}
        function ConfigTab:AddToggle(o) return CfgRight:AddToggle(o) end
        function ConfigTab:AddSlider(o) return CfgRight:AddSlider(o) end
        function ConfigTab:AddRangeSlider(o) return CfgRight:AddRangeSlider(o) end
        function ConfigTab:AddKeybind(o) return CfgRight:AddKeybind(o) end
        function ConfigTab:AddColorpicker(o) return CfgRight:AddColorpicker(o) end
        function ConfigTab:AddSingle(o) return CfgRight:AddSingle(o) end
        function ConfigTab:AddMulti(o) return CfgRight:AddMulti(o) end
        function ConfigTab:AddLabel(o) return CfgRight:AddLabel(o) end
        return ConfigTab
    end

    function Window:Start()
        -- Compute tab positions: right-aligned against the right edge of the right panel
        local gap = 15 -- gap between tab labels
        local rightEdge = 538 -- right panel right edge (280 + 260 - 2px)
        local totalW = 0
        for i = #tabLabels, 1, -1 do
            totalW = totalW + #tabLabels[i].Text * (charW + 0.5)
            if i < #tabLabels then totalW = totalW + gap end
        end
        local x = rightEdge - totalW
        for i, tl in ipairs(tabLabels) do
            tabXOffsets[i] = x
            tl.Position = Title1.Position + Vector2.new(x, 8)
            x = x + #tl.Text * (charW + 0.5) + gap
        end
        mainLoop()
    end

    return Window
end

_G.InterceptionLib = Library
return Library
