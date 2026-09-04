-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

-- ================================
-- MONITORS
-- ================================
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and resolutions possible: hyprctl monitors
-- Optimized for retina-class 2x displays, like 13" 2.8K, 27" 5K, 32" 6K.
hl.env("GDK_SCALE", "1")
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.25 })

-- Good compromise for 27" or 32" 4K monitors (but fractional!)
-- hl.env("GDK_SCALE", "1.75")
-- hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "1.666667" })

-- Straight 1x setup for low-resolution displays like 1080p or 1440p
-- hl.env("GDK_SCALE", "1")
-- hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "1" })

-- Example for Framework 13 w/ 6K XDR Apple display
-- hl.monitor({ output = "DP-5", mode = "6016x3384@60", position = "auto", scale = "2" })
-- hl.monitor({ output = "eDP-1", mode = "2880x1920@120", position = "auto", scale = "2" })

-- Main
hl.monitor({ output = "DP-1", mode = "3440x1440@240", position = "0x0", scale = "1", bitdepth = 10 })
-- Top
hl.monitor({ output = "DP-2", mode = "1920x1080@60", position = "760x-1080", scale = "1" })
-- Right
hl.monitor({ output = "HDMI-A-1", mode = "1920x1200@60", position = "3440x0", scale = "1" })

-- ================================
-- WORKSPACE RULES
-- ================================
-- hl.workspace_rule({ workspace = "1", monitor = "DP-1", default = true }) -- Main
-- hl.workspace_rule({ workspace = "2", monitor = "HDMI-A-1" })            -- Right
-- hl.workspace_rule({ workspace = "3", monitor = "DP-2" })                -- Top
-- hl.workspace_rule({ workspace = "4", monitor = "DP-1" })                -- Main
-- hl.workspace_rule({ workspace = "5", monitor = "DP-1" })                -- Main
-- hl.workspace_rule({ workspace = "6", monitor = "HDMI-A-1" })            -- Right
-- hl.workspace_rule({ workspace = "7", monitor = "HDMI-A-1" })            -- Right
-- hl.workspace_rule({ workspace = "8", monitor = "DP-2" })                -- Top
-- hl.workspace_rule({ workspace = "9", monitor = "DP-2" })                -- Top

hl.workspace_rule({ workspace = "1", monitor = "DP-1", default = true }) -- Main
hl.workspace_rule({ workspace = "2", monitor = "DP-1" }) -- Main
hl.workspace_rule({ workspace = "3", monitor = "DP-1" }) -- Main
hl.workspace_rule({ workspace = "4", monitor = "HDMI-A-1" }) -- Right
hl.workspace_rule({ workspace = "5", monitor = "HDMI-A-1" }) -- Right
hl.workspace_rule({ workspace = "6", monitor = "HDMI-A-1" }) -- Right
hl.workspace_rule({ workspace = "7", monitor = "DP-2" }) -- Top
hl.workspace_rule({ workspace = "8", monitor = "DP-2" }) -- Top
hl.workspace_rule({ workspace = "9", monitor = "DP-2" }) -- Top

-- ================================
-- WINDOW RULES
-- ================================
-- Spotify to Workspace 7 = Right
hl.window_rule({
	name = "windowrule-1",
	match = { class = "(spotify)" },
	workspace = "6",
})

-- WhatsApp to Workspace 6 = Right
hl.window_rule({
	name = "windowrule-2",
	match = { class = "(.*web\\.whatsapp\\.com.*)" },
	workspace = "4",
})

-- KeePassXC to Workspace 5 = Main
hl.window_rule({
	name = "windowrule-3",
	match = { class = "(org.keepassxc.KeePassXC)" },
	workspace = "3",
})

-- Unifi Protect to Workspace 3 = Top
hl.window_rule({
	name = "windowrule-4",
	match = { class = "(.*protect_dashboard.*)" },
	workspace = "7",
})

-- Discord to Workspace 7 = Top
hl.window_rule({
	name = "windowrule-5",
	match = { class = "(.*[Dd]iscord.*)" },
	workspace = "7",
})
