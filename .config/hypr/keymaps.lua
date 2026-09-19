-- Programs
local programs = {
    terminal = "foot 2>/dev/null",
    fileManager = "foot --app-id=yazi -e yazi",
    textedit    ="foot --app-id=nvim -e nvim",
    menu        = "rofi -show drun -show-icons",
    browser = "brave --process-per-site --renderer-process-limit=4 --disable-dev-shm-usage --enable-features=AutomaticTabDiscarding"
}

local mainMod = "SUPER"

-- Apps
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(programs.terminal), { description = "Open terminal" })
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(programs.fileManager), { description = "Open file manager" })
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(programs.browser), { description = "Open browser" })
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(programs.menu), { description = "App launcher" })
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(programs.textedit), { description = "Open text editor" })

-- Window management
hl.bind(mainMod .. " + A", hl.dsp.window.close(), { description = "Close window" })
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle floating" })
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo(), { description = "Toggle pseudotiling (dwindle)" })

-- Session
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("wlogout -b 2 -c 0 -r 0 -m 0"), { description = "Power menu" })

-- Screenshots
hl.bind("Print", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy -t image/png'), { description = "Screenshot region clipboard" })
hl.bind("SHIFT + Print", hl.dsp.exec_cmd('mkdir -p "$HOME/Pictures/Screenshots" && grim -g "$(slurp)" "$HOME/Pictures/Screenshots/screenshot_$(date +%Y%m%d_%H%M%S).png"'), { description = "Screenshot region save" })

-- Clipboard
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("rofi-clipboard"), { description = "Clipboard history" })

-- Widget
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd("~/.config/quickshell/OpenScripts/ClockWidget.sh"), { description = "Toggle Clock Widget" })
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("~/.config/quickshell/OpenScripts/MediaWidget.sh"), { description = "Toggle Media Widget" })
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("~/.config/quickshell/OpenScripts/CenterWidget.sh"), { description = "Toggle Center Widget" })
-- Focus
hl.bind(mainMod .. " + l",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j",  hl.dsp.focus({ direction = "down" }))

-- Swap / Move window
hl.bind(mainMod .. " + SHIFT + H",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J",  hl.dsp.window.move({ direction = "down" }))

-- Workspaces
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
    end

    -- Scroll workspaces
    hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
    hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

    -- Move/resize
    hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
    hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

    -- Media keys + OSD
    local osd = "~/.config/quickshell/OpenScripts/OSDWidget.sh"
    hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd(osd .. " volume up"),    { locked = true, repeating = true })
    hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd(osd .. " volume down"),  { locked = true, repeating = true })
    hl.bind("XF86AudioMute",         hl.dsp.exec_cmd(osd .. " volume mute"),  { locked = true, repeating = true })
    hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(osd .. " brightness up"),   { locked = true, repeating = true })
    hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(osd .. " brightness down"), { locked = true, repeating = true })

    -- Playerctl
    hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),        { locked = true })
    hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
    hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
    hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),    { locked = true })
