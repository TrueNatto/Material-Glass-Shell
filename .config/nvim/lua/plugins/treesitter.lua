return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = "VeryLazy",
  opts = {
    ensure_installed = { "lua", "rust", "css", "bash", "python", "json", "javascript" },
    highlight = { enable = true },
    indent = { enable = true },
  },
}
