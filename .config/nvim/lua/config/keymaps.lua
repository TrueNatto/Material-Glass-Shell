local m = vim.keymap.set

-- SPACE: Mode switching
m("n", "<Space>k", "i", { desc = "Insert mode" })
m("n", "<Space>h", "V", { desc = "Visual Line mode" })
m("n", "<Space>l", "v", { desc = "Visual mode" })
m("n", "<Space>j", ":", { desc = "Command-line mode" })

-- ALT: Jump by word (Normal/Visual)
m({ "n", "v" }, "<A-h>", "b", { desc = "Word back" })
m({ "n", "v" }, "<A-l>", "w", { desc = "Word forward" })

-- ALT: Move by character (Insert only)
m("i", "<A-h>", "<Left>", { desc = "Char left" })
m("i", "<A-l>", "<Right>", { desc = "Char right" })

-- ALT: Move by line (Insert only)
m("i", "<A-j>", "<Down>", { desc = "Line down" })
m("i", "<A-k>", "<Up>", { desc = "Line up" })

-- CTRL: Yank / Delete / Put / Remove
m({ "n", "v" }, "<C-k>", "y", { desc = "Yank (copy)" })
m({ "n", "v" }, "<C-j>", "p", { desc = "Put (paste)" })
m({ "n", "v" }, "<C-h>", "d", { desc = "Delete (cut)" })
m({ "n", "v" }, "<C-l>", '"_d', { desc = "Remove (no clipboard)" })

-- Undo / Redo
m("n", "z", "u", { desc = "Undo" })
m("n", "x", "<C-r>", { desc = "Redo" })

-- SHIFT: start/end of line
m({ "n", "v" }, "<S-h>", "^", { desc = "Start of line" })
m({ "n", "v" }, "<S-l>", "$", { desc = "End of line" })
m("i", "<A-S-h>", "<C-o>^", { desc = "Start of line" })
m("i", "<A-S-l>", "<C-o>$", { desc = "End of line" })

-- SHIFT: start/end of file
m({ "n", "v" }, "<S-k>", "gg", { desc = "Start of file" })
m({ "n", "v" }, "<S-j>", "G", { desc = "End of file" })
m("i", "<A-S-k>", "<C-o>gg", { desc = "Start of file" })
m("i", "<A-S-j>", "<C-o>G", { desc = "End of file" })

-- Paste in Insert Mode
m("i", "<C-j>", '<C-r>"', { desc = "Put (paste) at cursor" })

