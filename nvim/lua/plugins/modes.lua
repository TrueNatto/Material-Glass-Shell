return {
  "mvllow/modes.nvim",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    line_opacity = 0.35,
    set_cursor = false,
    set_cursorline = true,
    ignore = { "NvimTree", "TelescopePrompt" },
  },
}
