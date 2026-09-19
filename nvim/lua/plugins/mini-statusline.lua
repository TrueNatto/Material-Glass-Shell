return {
  {
    "nvim-mini/mini.statusline",
    version = false,
    event = "VeryLazy",
    config = function()
      local statusline = require("mini.statusline")
      statusline.setup({
        content = {
          active = function()
            local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
            local git           = statusline.section_git({ trunc_width = 75 })
            local diff          = statusline.section_diff({ trunc_width = 75 })
            local diagnostics   = statusline.section_diagnostics({ trunc_width = 75 })
            local filename      = statusline.section_filename({ trunc_width = 140 })
            local fileinfo      = statusline.section_fileinfo({ trunc_width = 120 })
            local location      = string.format(" %d|%d ", vim.fn.line("."), vim.fn.line("$"))

            return statusline.combine_groups({
              { hl = mode_hl,                 strings = { mode } },
              { hl = "MiniStatuslineDevinfo",  strings = { git, diff, diagnostics } },
              "%<",
              { hl = "MiniStatuslineFilename", strings = { filename } },
              "%=",
              { hl = "MiniStatuslineDevinfo",  strings = { fileinfo } },
              { hl = mode_hl,                 strings = { location } },
            })
          end,
        },
      })

      local function hex(c) return c and string.format("#%06x", c) or nil end
      local function get_hl(name)
        local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
        return ok and hl or {}
      end

      local base    = get_hl("StatusLine")
      local keyword = get_hl("Keyword")
      local visual  = get_hl("Visual")
      local search  = get_hl("Search")
      local incsrch = get_hl("IncSearch")
      local err     = get_hl("Error")

      vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "MiniStatuslineInactive", { fg = "#7f849c", bg = "#1e2128" })
      vim.api.nvim_set_hl(0, "MiniStatuslineFilename",  { fg = "#ffffff", bg = "#1e2128", bold = true })
      vim.api.nvim_set_hl(0, "MiniStatuslineDevinfo",   { fg = "#7f849c", bg = "#1e2128" })

      local modes = {
        Normal  = { fg = "#ffffff", bg = "#2d3139" },
        Insert  = { fg = hex(search.fg),  bg = hex(search.bg) },
        Visual  = { fg = hex(base.fg),    bg = hex(visual.bg) },
        Command = { fg = hex(incsrch.fg), bg = hex(incsrch.bg) },
        Replace = { fg = hex(err.fg),     bg = hex(err.fg) },
        Other   = { fg = "#ffffff", bg = "#2d3139" },
      }
      for name, c in pairs(modes) do
        vim.api.nvim_set_hl(0, "MiniStatuslineMode" .. name, { fg = c.fg, bg = c.bg, bold = true })
      end
    end,
  },
}
