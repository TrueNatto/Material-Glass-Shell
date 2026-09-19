-- Autostart

hl.on("hyprland.start", function()
hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
hl.exec_cmd("waybar")
hl.exec_cmd("fcitx5")
hl.exec_cmd("hyprctl setcursor BreezeX-RosePine-Linux 26")
hl.exec_cmd("wl-paste --watch cliphist store")
hl.exec_cmd("awww-daemon")
hl.exec_cmd("mako")
hl.exec_cmd("mpv --no-video ~/.config/sound/welcome.mp3")

-- Env
hl.env("XCURSOR_THEME", "BreezeX-RosePine-Linux")
hl.env("XCURSOR_SIZE", "26")
hl.env("HYPRCURSOR_THEME", "BreezeX-RosePine-Linux")
hl.env("HYPRCURSOR_SIZE", "26")

-- Env Input Method (fcitx)
hl.env("QT_IM_MODULE", "fcitx")
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("GTK_IM_MODULE", "fcitx")
hl.env("INPUT_METHOD", "fcitx")

-- Env Theme
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("QT_QPA_PLATFORM", "wayland")

-- Input
hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = true,
        },
    },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})
end)

