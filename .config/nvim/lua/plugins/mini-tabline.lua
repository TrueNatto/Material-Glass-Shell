return {
  'nvim-mini/mini.tabline',
  version = false,
  event = "VeryLazy",
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  keys = {
    { "<Tab>", "<cmd>bnext<cr>", desc = "Chuyển sang tab tiếp theo" },
    { "<S-Tab>", "<cmd>bprev<cr>", desc = "Quay lại tab trước" },
    { "<C-w>", "<cmd>bdelete!<cr>", mode = "n", desc = "Đóng cưỡng ép tab hiện tại" },
  },
  config = function()
    local mini_tabline = require("mini.tabline")
    local devicons = require("nvim-web-devicons")

    mini_tabline.setup({
      show_icons = true,
      format = function(buf_id, label)
        local name = vim.api.nvim_buf_get_name(buf_id)
        local ext = vim.fn.fnamemodify(name, ":e")
        local icon, _ = devicons.get_icon(name, ext, { default = true })

        local suffix = vim.api.nvim_get_option_value('modified', { buf = buf_id }) and " ●" or ""

        return "  " .. icon .. "  " .. label .. suffix .. "   "
      end,
    })

    local set_hl = function()
      vim.api.nvim_set_hl(0, "TabLineSel", { fg = "#ffffff", bg = "#2d3139", bold = true })
      vim.api.nvim_set_hl(0, "TabLine", { fg = "#7f849c", bg = "NONE" })
      vim.api.nvim_set_hl(0, "TabLineFill", { bg = "NONE" })
    end

    set_hl()
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = set_hl,
    })
  end
}
