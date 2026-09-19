-- Look
hl.config({
    general = {
        gaps_in  = 3.5,
        gaps_out = 6,
        border_size = 2,
        col = {
            active_border = {
                colors = {
                    "rgba(ffffff45)",
                    "rgba(303030aa)",
                },
                angle = 90,
            },

            inactive_border = {
                colors = {
                    "rgba(ffffff45)",
                    "rgba(303030aa)",
                },
                angle = 90,
            },
        },
        resize_on_border = false,
        allow_tearing = false,
        layout = "dwindle",
    },

    decoration = {
        rounding       = 20,
        rounding_power = 3,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled = false,
        },

        blur = {
            enabled           = true,
            size              = 2,
            passes            = 2,
            vibrancy          = 0.5,
            noise             = 0.05,
            xray              = true,
            new_optimizations = true,
            ignore_opacity    = true,
        },
    },
})

-- Layouts
hl.config({
    dwindle = {
        preserve_split = true,
    },
})

hl.config({
    master = {
        new_status = "master",
    },
})

hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
    },
})

-- Monitors
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1.2,
})
