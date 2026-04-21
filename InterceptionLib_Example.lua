-- Example: How to use InterceptionLib
local Library = require("c:\\matcha\\scripts\\InterceptionLib.lua")

-- Create window
local Window = Library:CreateWindow({
    Game = "Example",
})

-- Show hotkey list
Window:_toggleHotkeyList(true)

----------------------------------------------
-- AIMBOT TAB (4 panels)
----------------------------------------------
local Aimbot = Window:AddTab("Aimbot")
local AimLeft = Aimbot:AddSection("Targeting")
local AimRight = Aimbot:AddSection("Settings")

-- Left panel
AimLeft:AddToggle({
    Name = "Aimbot",
    Default = false,
    Keybind = true,
    Mode = "hold",
})

AimLeft:AddSlider({
    Name = "FOV",
    Min = 0, Max = 1000,
    Default = 500,
    Suffix = "px",
})

AimLeft:AddRangeSlider({
    Name = "Smoothing",
    Min = 0, Max = 100,
    DefaultLeft = 20, DefaultRight = 80,
    Suffix = "%",
})

AimLeft:AddSingle({
    Name = "Target",
    Options = {"Head", "Torso", "Nearest"},
    Default = "Head",
    Drop = false,
})

AimLeft:AddSingle({
    Name = "Priority",
    Options = {"Distance", "Health", "Threat Level"},
    Default = "Distance",
    Drop = true,
})

AimLeft:AddToggle({
    Name = "Prediction",
    Default = true,
})

AimLeft:AddSlider({
    Name = "Prediction Factor",
    Min = 0, Max = 100,
    Default = 50,
    Suffix = "%",
    Step = 5,
})

AimLeft:AddSlider({
    Name = "Max Distance",
    Min = 50, Max = 2000,
    Default = 500,
    Suffix = "m",
    Step = 50,
})

-- Right panel
AimRight:AddToggle({
    Name = "Silent Aim",
    Default = false,
    Keybind = true,
    Mode = "toggle",
})

AimRight:AddSlider({
    Name = "Hit Chance",
    Min = 0, Max = 100,
    Default = 100,
    Suffix = "%",
    Step = 5,
})

AimRight:AddToggle({
    Name = "Visible Check",
    Default = true,
})

AimRight:AddToggle({
    Name = "Team Check",
    Default = true,
})

AimRight:AddMulti({
    Name = "Ignore",
    Options = {"Bots", "Friends", "Downed"},
    Default = {"Bots"},
    Drop = false,
})

AimRight:AddColorpicker({
    Name = "FOV Circle",
    Default = Color3.new(1, 1, 1),
})

AimRight:AddToggle({
    Name = "Show FOV",
    Default = false,
})

AimRight:AddColorpicker({
    Name = "Crosshair",
    Default = Color3.new(0, 1, 0),
    Toggle = false,
})

AimRight:AddToggle({
    Name = "Wall Bang",
    Default = false,
})

AimRight:AddSingle({
    Name = "Aim Style",
    Options = {"Smooth", "Snap", "Flick"},
    Default = "Smooth",
    Drop = true,
})

-- Bottom left panel
local AimBotLeft = Aimbot:AddSection("Extra", { Height = 150 })

AimBotLeft:AddToggle({
    Name = "Auto Fire",
    Default = false,
})

AimBotLeft:AddToggle({
    Name = "Rapid Fire",
    Default = false,
})

AimBotLeft:AddLabel({
    Lines = {
        "Supported Weapons:",
        "- Rifle / SMG / Shotgun",
        "- Sniper / Pistol",
        "- Auto / Burst / Semi",
    }
})

-- Bottom right panel
local AimBotRight = Aimbot:AddSection("Advanced", { Height = 150 })

AimBotRight:AddToggle({
    Name = "Resolver",
    Default = false,
})

AimBotRight:AddToggle({
    Name = "Desync",
    Default = false,
})

AimBotRight:AddSlider({
    Name = "Lock Delay",
    Min = 0, Max = 500,
    Default = 0,
    Suffix = "ms",
    Step = 10,
})

AimBotRight:AddToggle({
    Name = "Anti-Aim",
    Default = false,
})

----------------------------------------------
-- VISUALS TAB (4 panels)
----------------------------------------------
local Visuals = Window:AddTab("Visuals")
local VisLeft = Visuals:AddSection("ESP")
local VisRight = Visuals:AddSection("World")

-- Left panel
VisLeft:AddToggle({
    Name = "Player ESP",
    Default = false,
    Keybind = true,
    Mode = "toggle",
})

VisLeft:AddMulti({
    Name = "ESP Info",
    Options = {"Name", "Health", "Distance", "Weapon"},
    Default = {"Name", "Health"},
    Drop = true,
})

VisLeft:AddColorpicker({
    Name = "Ally Color",
    Default = Color3.new(0, 1, 0),
    Toggle = false,
})

VisLeft:AddColorpicker({
    Name = "Enemy Color",
    Default = Color3.new(1, 0, 0),
    Toggle = false,
})

VisLeft:AddSingle({
    Name = "Box Type",
    Options = {"Full", "Corner", "3D"},
    Default = "Full",
    Drop = false,
})

VisLeft:AddToggle({
    Name = "Health Bar",
    Default = true,
})

VisLeft:AddToggle({
    Name = "Tracers",
    Default = false,
})

VisLeft:AddSingle({
    Name = "Tracer Origin",
    Options = {"Bottom", "Center", "Mouse"},
    Default = "Bottom",
    Drop = true,
})

VisLeft:AddToggle({
    Name = "Skeleton",
    Default = false,
})

-- Right panel
VisRight:AddColorpicker({
    Name = "Chams",
    Default = Color3.fromRGB(170, 0, 255),
})

VisRight:AddSlider({
    Name = "Cham Opacity",
    Min = 0, Max = 100,
    Default = 80,
    Suffix = "%",
    Step = 5,
})

VisRight:AddToggle({
    Name = "Fullbright",
    Default = false,
})

VisRight:AddSlider({
    Name = "Ambient",
    Min = 0, Max = 100,
    Default = 50,
    Suffix = "%",
    Step = 5,
})

VisRight:AddToggle({
    Name = "No Fog",
    Default = false,
})

VisRight:AddToggle({
    Name = "No Particles",
    Default = false,
})

VisRight:AddMulti({
    Name = "Removals",
    Options = {"Shadows", "Sky", "Arms", "Effects"},
    Default = {},
    Drop = false,
})

VisRight:AddToggle({
    Name = "Third Person",
    Default = false,
})

-- Bottom panels
local VisBotLeft = Visuals:AddSection("Self", { Height = 200 })
local VisBotRight = Visuals:AddSection("Other", { Height = 200 })

VisBotLeft:AddColorpicker({
    Name = "Self Chams",
    Default = Color3.fromRGB(0, 200, 255),
})

VisBotLeft:AddSlider({
    Name = "Self Opacity",
    Min = 0, Max = 100,
    Default = 50,
    Suffix = "%",
})

VisBotLeft:AddToggle({
    Name = "Viewmodel Chams",
    Default = false,
})

VisBotLeft:AddColorpicker({
    Name = "Hand Chams",
    Default = Color3.fromRGB(255, 100, 200),
})

VisBotLeft:AddToggle({
    Name = "Weapon Chams",
    Default = false,
})

VisBotLeft:AddToggle({
    Name = "Self Glow",
    Default = false,
})

VisBotRight:AddToggle({
    Name = "Bullet Tracers",
    Default = false,
})

VisBotRight:AddColorpicker({
    Name = "Tracer Color",
    Default = Color3.new(1, 0.5, 0),
    Toggle = false,
})

VisBotRight:AddSlider({
    Name = "Tracer Duration",
    Min = 100, Max = 3000,
    Default = 500,
    Suffix = "ms",
    Step = 100,
})

VisBotRight:AddToggle({
    Name = "Hit Markers",
    Default = false,
})

VisBotRight:AddToggle({
    Name = "Hit Sound",
    Default = false,
})

VisBotRight:AddSingle({
    Name = "Kill Effect",
    Options = {"None", "Dissolve", "Explode", "Fade"},
    Default = "None",
    Drop = true,
})

----------------------------------------------
-- MISC TAB (4 panels)
----------------------------------------------
local Misc = Window:AddTab("Misc")
local MiscLeft = Misc:AddSection("Movement")
local MiscRight = Misc:AddSection("Utility")

-- Left panel
MiscLeft:AddToggle({
    Name = "Speed Hack",
    Default = false,
    Keybind = true,
    Mode = "toggle",
})

MiscLeft:AddSlider({
    Name = "Speed",
    Min = 16, Max = 200,
    Default = 16,
})

MiscLeft:AddToggle({
    Name = "Fly",
    Default = false,
    Keybind = true,
    Mode = "toggle",
})

MiscLeft:AddSlider({
    Name = "Fly Speed",
    Min = 10, Max = 500,
    Default = 50,
})

MiscLeft:AddToggle({
    Name = "Infinite Jump",
    Default = false,
})

MiscLeft:AddToggle({
    Name = "No Clip",
    Default = false,
    Keybind = true,
    Mode = "hold",
})

MiscLeft:AddSlider({
    Name = "Jump Power",
    Min = 50, Max = 500,
    Default = 50,
})

MiscLeft:AddToggle({
    Name = "Teleport",
    Default = false,
    Keybind = true,
    Mode = "toggle",
})

MiscLeft:AddSlider({
    Name = "TP Distance",
    Min = 10, Max = 500,
    Default = 50,
    Suffix = "m",
})

-- Right panel
MiscRight:AddToggle({
    Name = "Auto Rejoin",
    Default = false,
})

MiscRight:AddToggle({
    Name = "Anti AFK",
    Default = true,
})

MiscRight:AddToggle({
    Name = "FPS Unlock",
    Default = false,
})

MiscRight:AddSlider({
    Name = "FPS Cap",
    Min = 30, Max = 360,
    Default = 60,
    Suffix = " fps",
    Step = 30,
})

MiscRight:AddSingle({
    Name = "Spoof Region",
    Options = {"None", "US East", "US West", "Europe", "Asia"},
    Default = "None",
    Drop = true,
})

MiscRight:AddMulti({
    Name = "Notifications",
    Options = {"Kills", "Deaths", "Chat", "Joins"},
    Default = {"Kills"},
    Drop = true,
})

MiscRight:AddToggle({
    Name = "Streamer Mode",
    Default = false,
})

MiscRight:AddToggle({
    Name = "Chat Logger",
    Default = false,
})

MiscRight:AddToggle({
    Name = "Watermark",
    Default = false,
})

-- Bottom panels
local MiscBotLeft = Misc:AddSection("Automation", { Height = 200 })
local MiscBotRight = Misc:AddSection("Server", { Height = 200 })

MiscBotLeft:AddToggle({
    Name = "Auto Farm",
    Default = false,
})

MiscBotLeft:AddToggle({
    Name = "Auto Collect",
    Default = false,
})

MiscBotLeft:AddSlider({
    Name = "Farm Range",
    Min = 10, Max = 200,
    Default = 50,
    Suffix = "m",
})

MiscBotLeft:AddRangeSlider({
    Name = "Farm Delay",
    Min = 0, Max = 1000,
    DefaultLeft = 100, DefaultRight = 500,
    Suffix = "ms",
})

MiscBotLeft:AddToggle({
    Name = "Auto Heal",
    Default = false,
})

MiscBotLeft:AddToggle({
    Name = "Auto Quest",
    Default = false,
})

MiscBotRight:AddToggle({
    Name = "Server Hop",
    Default = false,
})

MiscBotRight:AddSlider({
    Name = "Min Players",
    Min = 1, Max = 20,
    Default = 5,
    Step = 1,
})

MiscBotRight:AddSlider({
    Name = "Max Players",
    Min = 5, Max = 50,
    Default = 30,
    Step = 1,
})

MiscBotRight:AddLabel({
    Lines = {
        "Server Info:",
        "- Region: US East",
        "- Players: 12/30",
    }
})

----------------------------------------------
-- CONFIG TAB (fully hardcoded)
----------------------------------------------
local ConfigTab = Window:AddConfigTab()

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

----------------------------------------------
-- INFO PANELS (floating, dynamic width)
----------------------------------------------
local PlayerInfo = Window:CreateInfoPanel({
    Title = "Player",
})

PlayerInfo:SetLine("Backpack", "AK-47")
PlayerInfo:SetLine("Item", "Frag Grenade")
PlayerInfo:SetLine("Ammo", "30/120")
PlayerInfo:SetLine("UnderBarrel", "Vertical Grip")
PlayerInfo:SetLine("Sight", "Holographic Sight")
PlayerInfo:SetLine("Barrel", "Suppressor")
PlayerInfo:SetVisible(true)

-- Toggle in config tab to control it
ConfigTab:AddToggle({
    Name = "Player Info",
    Default = true,
    Callback = function(val)
        PlayerInfo:SetVisible(val)
    end,
})

-- IMPORTANT: Call Start() LAST after all tabs/widgets are added
Window:Start()
