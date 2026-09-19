-- Misc
hl.config({
    xwayland = {
        enabled = false,
        force_zero_scaling = true,
    },

    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo = true,
    },

    input = {
        accel_profile = "flat",
        sensitivity = 0.7,
    },
})
-- Window rules

local suppressMaximizeRule = hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move  = "20 monitor_h-120",
    float = true,
})
hl.layer_rule({
    match        = { namespace = "logout_dialog|mako|waybar|rofi|quickshell:clock|quickshell:mediaPlayer|quickshell:center|quickshell:osd" },
    blur         = true,
    ignore_alpha = 0.4,
})
hl.layer_rule({
    match = { namespace = "selection" },
              no_anim = true,
})
hl.window_rule({
    match = {class = "imv|mpv"},
    float = true,
    center = true,
    size = { 900, 600 },
})
