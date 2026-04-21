# Interception UI Library

A Drawing API-based UI library for Matcha. Renders a fully interactive menu with tabs, panels, widgets, configs, and floating info panels — all using the Drawing API.

---

## Getting Started

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Interception-m/Interception-UI/refs/heads/main/InterceptionLib.lua"))()

local Window = Library:CreateWindow({
    Game = "Blade Ball",  -- config subfolder name
})

Window:_toggleHotkeyList(true)

-- Add tabs, sections, widgets here...

-- IMPORTANT: Call Start() LAST after all tabs/widgets are added
Window:Start()
```

**Window title** is hardcoded to `I n t e r c e p t i o n`.
**Config path** is hardcoded to `INTERCEPTION\<Game>\`.
**Menu key** defaults to `End` (VK 35). Changeable via the Config tab's Menu Key keybind.

---

## Tabs & Sections

Each tab supports up to **4 panels** — 2 top (left/right) and 2 bottom sub-panels.

```lua
local Tab = Window:AddTab("Combat")

-- Top panels (sections 1 & 2, always full height)
local Left  = Tab:AddSection("Targeting")
local Right = Tab:AddSection("Settings")

-- Bottom panels (sections 3 & 4, Height = how tall the bottom panel is)
local BotLeft  = Tab:AddSection("Extra", { Height = 150 })
local BotRight = Tab:AddSection("Advanced", { Height = 150 })
```

### Layout

Sections are assigned in order: **1 = top-left, 2 = top-right, 3 = bottom-left, 4 = bottom-right**.

- Sections 1 & 2 are the **top panels** — they start at full height (540px) but shrink automatically if a bottom panel is added below them
- Sections 3 & 4 are the **bottom panels** — the `Height` parameter defines how tall they are
- When `Height = N`, the top panel above it shrinks to `540 - N - 10`px (10px gap between stacked panels)
- If you only use 2 sections (no Height, no bottom panels), both top panels stay at full 540px
- You can have bottom panels on one side only (e.g. 3 sections total)

---

## Widgets

All widgets auto-stack vertically in their section. Every widget returns a controller with `:Get()` and `:Set()` methods. **Every widget supports a `Callback` function** that fires whenever the value changes.

### Toggle

```lua
local myToggle = Section:AddToggle({
    Name = "Aimbot",
    Default = false,
    Callback = function(value) end,  -- optional
    Keybind = true,                  -- optional: adds inline keybind
    Mode = "toggle",                 -- "hold" or "toggle" (for keybind)
})

myToggle:Get()       -- returns bool
myToggle:Set(true)   -- sets value, fires callback
```

### Slider

```lua
local mySlider = Section:AddSlider({
    Name = "FOV",
    Min = 0,
    Max = 1000,
    Default = 500,
    Suffix = "px",       -- optional, displayed after value
    Step = 10,           -- optional, +/- button increment (default 10)
    Callback = function(value) end,
})

mySlider:Get()       -- returns number
mySlider:Set(750)
```

### Range Slider

```lua
local myRange = Section:AddRangeSlider({
    Name = "Smoothing",
    Min = 0,
    Max = 100,
    DefaultLeft = 20,
    DefaultRight = 80,
    Suffix = "%",
    Step = 1,            -- optional (default 1)
    Callback = function(left, right) end,
})

myRange:SetLeft(30)
myRange:SetRight(70)
```

### Keybind

```lua
local myKeybind = Section:AddKeybind({
    Name = "Sprint",
    Default = nil,                  -- VK code or nil
    Mode = "always",                -- "always" | "toggle" | "hold"
    Callback = function(active) end,
})

myKeybind:GetActive()  -- returns true/false based on mode
myKeybind:Get()        -- returns VK code
myKeybind:Set(0x10)    -- set to Shift
```

Right-click any keybind to change its mode (Always On / Toggle / Hold).

### Colorpicker

```lua
-- With toggle checkbox (default)
local myColor = Section:AddColorpicker({
    Name = "ESP Color",
    Default = Color3.new(1, 0, 0),
    Callback = function(color) end,
})

-- Text + color preview only (no checkbox)
Section:AddColorpicker({
    Name = "Accent",
    Default = Color3.fromRGB(130, 80, 255),
    Toggle = false,
    Callback = function(color) end,
})

myColor:GetColor()  -- returns Color3
```

Click the color square to open the HSV picker with copy/paste support.

### Single Select

```lua
-- Dropdown popup (default)
local myDrop = Section:AddSingle({
    Name = "Target",
    Options = {"Head", "Torso", "Nearest"},
    Default = "Head",
    Drop = true,
    Callback = function(value) end,
})

-- Inline list (always visible)
Section:AddSingle({
    Name = "Priority",
    Options = {"Distance", "Health", "Threat"},
    Default = "Distance",
    Drop = false,
    Callback = function(value) end,
})

myDrop:Get()          -- returns string
myDrop:Set("Torso")
```

### Multi Select

```lua
-- Dropdown popup (default)
local myMulti = Section:AddMulti({
    Name = "ESP Info",
    Options = {"Name", "Health", "Distance", "Weapon"},
    Default = {"Name", "Health"},
    Drop = true,
    Callback = function(selected) end,  -- table of selected strings
})

-- Inline multi-toggle list
Section:AddMulti({
    Name = "Removals",
    Options = {"Shadows", "Sky", "Arms", "Effects"},
    Default = {},
    Drop = false,
    Callback = function(selected) end,
})

myMulti:Get()  -- returns table of selected strings
```

### Label

```lua
-- Multi-line label
Section:AddLabel({
    Lines = {
        "Supported Weapons:",
        "- Rifle / SMG / Shotgun",   -- lines starting with "- " render grey
        "- Sniper / Pistol",
    }
})

-- Single-line label
Section:AddLabel("v1.0.0")
```

---

## Config Tab

```lua
local ConfigTab = Window:AddConfigTab()
```

The left panel is **hardcoded** with:
- Config list (7 visible slots, click to select, **X** to delete)
- Text input box (click to type, Enter to create, Escape to cancel)
- Save / Load buttons
- Path label showing `INTERCEPTION\<Game>`

The right panel has **hardcoded** Menu Key keybind + Hotkey List toggle, followed by your custom widgets:

```lua
ConfigTab:AddToggle({ Name = "Auto Save", Default = false })
ConfigTab:AddToggle({ Name = "Staff Detector", Default = false })

ConfigTab:AddSingle({
    Name = "Theme",
    Options = {"Dark", "Midnight", "Amoled"},
    Default = "Dark",
    Drop = true,
})

ConfigTab:AddColorpicker({
    Name = "Accent Color",
    Default = Color3.fromRGB(130, 80, 255),
    Toggle = false,
})

ConfigTab:AddLabel("v1.0.0")
```

### Config System

- Every widget **auto-registers** for config save/load — no manual setup needed
- Menu Key keybind is excluded from configs (`MenuBind = true`)
- Configs are saved as JSON to `INTERCEPTION\<Game>\<name>.json`
- Uses: `makefolder`, `writefile`, `readfile`, `isfolder`, `listfiles`, `isfile`, `delfile`

---

## Info Panel

A floating, independently draggable panel with dynamic width. Useful for displaying player info, game state, debug data, etc.

```lua
local panel = Window:CreateInfoPanel({
    Title = "Player",
})

-- Add lines (order preserved)
panel:SetLine("Backpack", "AK-47")
panel:SetLine("Item", "Frag Grenade")
panel:SetLine("Ammo", "30/120")
panel:SetLine("UnderBarrel", "Vertical Grip")
panel:SetLine("Sight", "Holographic Sight")
panel:SetLine("Barrel", "Suppressor")

-- Show/hide
panel:SetVisible(true)

-- Update at runtime
panel:SetTitle("xposn")
panel:SetLine("Ammo", "29/120")

-- Remove a line (remaining lines reflow)
panel:RemoveLine("UnderBarrel")

-- Cleanup
panel:Destroy()
```

### Features
- **Dynamic width** — auto-resizes based on the longest `"Key: Value"` text
- **Minimum width** — 120px
- **Max 20 lines** per panel
- **Draggable** by title bar, independent of the main menu
- **Hides/shows** with the menu toggle
- **Multiple panels** — create as many as you need, each fully independent

### Controlling via Config Tab

```lua
ConfigTab:AddToggle({
    Name = "Player Info",
    Default = true,
    Callback = function(val)
        panel:SetVisible(val)
    end,
})
```

---

## Hotkey List

Auto-populated floating panel showing all active keybinds and their modes.

```lua
Window:_toggleHotkeyList(true)   -- show
Window:_toggleHotkeyList(false)  -- hide
```

- Automatically lists keybinds that have a key assigned
- Shows name + mode (e.g. `Aimbot [Toggle]`)
- White text = active, grey = inactive
- Draggable independently
- Also controllable via the Hotkey List toggle in Config tab

---

## Runtime API Summary

| Widget | Get | Set |
|--------|-----|-----|
| Toggle | `:Get()` → `bool` | `:Set(bool)` |
| Slider | `:Get()` → `number` | `:Set(number)` |
| Range Slider | — | `:SetLeft(n)`, `:SetRight(n)` |
| Keybind | `:Get()` → VK code, `:GetActive()` → `bool` | `:Set(vkCode)` |
| Colorpicker | `:GetColor()` → `Color3` | — |
| Single Select | `:Get()` → `string` | `:Set(string)` |
| Multi Select | `:Get()` → `{strings}` | — |
| Info Panel | — | `:SetLine(k,v)`, `:RemoveLine(k)`, `:SetTitle(s)`, `:SetVisible(b)` |

---

## Cleanup

```lua
Window:Destroy()  -- removes all Drawing objects
```

This cleans up everything: tabs, panels, widgets, hotkey list, info panels, colorpicker popup, and right-click menu.

---

## Full Example

See [InterceptionLib_Example.lua](InterceptionLib_Example.lua) for a complete working example with all widget types, 4-panel tabs, config tab, and info panel.
