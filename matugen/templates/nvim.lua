local bg = "{{colors.surface.default.hex}}"
local fg = "{{colors.on_surface.default.hex}}"
local fg_variant = "{{colors.on_surface_variant.default.hex}}"
local accent = "{{colors.primary.default.hex}}"
local accent_fg = "{{colors.on_primary.default.hex}}"
local secondary = "{{colors.secondary.default.hex}}"
local secondary_container = "{{colors.secondary_container.default.hex}}"
local on_secondary_container = "{{colors.on_secondary_container.default.hex}}"
local tertiary = "{{colors.tertiary.default.hex}}"
local error = "{{colors.error.default.hex}}"
local on_error = "{{colors.on_error.default.hex}}"
local outline = "{{colors.outline.default.hex}}"
local outline_variant = "{{colors.outline_variant.default.hex}}"
local surface_container = "{{colors.surface_container.default.hex}}"
local surface_variant = "{{colors.surface_variant.default.hex}}"

local function hl(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

vim.o.background = "dark"
vim.o.termguicolors = true
vim.cmd("hi clear")
if vim.fn.exists("syntax_on") then
  vim.cmd("syntax reset")
end

-- === Editor UI ===
hl("Normal", { fg = fg, bg = "none" })
hl("NormalFloat", { fg = fg, bg = "none" })
hl("NormalNC", { fg = fg, bg = "none" })
hl("EndOfBuffer", { bg = "none" })
hl("CursorLine", { bg = "none" })
hl("CursorLineNr", { fg = accent, bold = true })
hl("Visual", { bg = secondary_container })
hl("LineNr", { fg = outline, bg = "none" })
hl("SignColumn", { bg = "none" })
hl("ColorColumn", { bg = surface_container })
hl("VertSplit", { fg = outline })
hl("WinSeparator", { fg = outline })
hl("StatusLine", { fg = fg, bg = surface_container })
hl("StatusLineNC", { fg = outline, bg = surface_container })
hl("Pmenu", { fg = fg, bg = surface_container })
hl("PmenuSel", { fg = accent_fg, bg = accent })
hl("PmenuSbar", { bg = surface_container })
hl("PmenuThumb", { bg = outline })
hl("Search", { fg = accent_fg, bg = accent })
hl("IncSearch", { fg = accent_fg, bg = tertiary })
hl("MatchParen", { fg = tertiary, bold = true })
hl("Directory", { fg = accent })
hl("Title", { fg = accent, bold = true })
hl("Whitespace", { fg = outline })
hl("NonText", { fg = outline })
hl("WinBar", { fg = fg })
hl("WinBarNC", { fg = outline })

-- === Syntax ===
hl("Comment", { fg = outline, italic = true })
hl("Constant", { fg = tertiary })
hl("String", { fg = tertiary })
hl("Character", { fg = tertiary })
hl("Number", { fg = accent })
hl("Boolean", { fg = accent })
hl("Float", { fg = accent })
hl("Identifier", { fg = fg })
hl("Function", { fg = accent, bold = true })
hl("Statement", { fg = secondary, bold = true })
hl("Conditional", { fg = secondary })
hl("Repeat", { fg = secondary })
hl("Label", { fg = secondary })
hl("Operator", { fg = fg_variant })
hl("Keyword", { fg = secondary, bold = true })
hl("Exception", { fg = error })
hl("PreProc", { fg = tertiary })
hl("Include", { fg = tertiary })
hl("Define", { fg = tertiary })
hl("Macro", { fg = tertiary })
hl("Type", { fg = secondary })
hl("StorageClass", { fg = secondary })
hl("Structure", { fg = secondary })
hl("Typedef", { fg = secondary })
hl("Special", { fg = accent })
hl("SpecialChar", { fg = accent })
hl("Tag", { fg = accent })
hl("Delimiter", { fg = fg_variant })
hl("SpecialComment", { fg = outline, italic = true })
hl("Underlined", { underline = true })
hl("Error", { fg = error })
hl("Todo", { fg = accent_fg, bg = tertiary, bold = true })

-- === Treesitter (@ groups) ===
hl("@variable", { fg = fg })
hl("@variable.builtin", { fg = tertiary, italic = true })
hl("@constant", { fg = tertiary })
hl("@constant.builtin", { fg = tertiary, italic = true })
hl("@string", { fg = tertiary })
hl("@string.escape", { fg = accent })
hl("@number", { fg = accent })
hl("@boolean", { fg = accent })
hl("@function", { fg = accent, bold = true })
hl("@function.builtin", { fg = accent, italic = true })
hl("@method", { fg = accent, bold = true })
hl("@keyword", { fg = secondary, bold = true })
hl("@keyword.function", { fg = secondary })
hl("@keyword.return", { fg = secondary })
hl("@conditional", { fg = secondary })
hl("@repeat", { fg = secondary })
hl("@operator", { fg = fg_variant })
hl("@type", { fg = secondary })
hl("@type.builtin", { fg = secondary, italic = true })
hl("@property", { fg = fg })
hl("@field", { fg = fg })
hl("@parameter", { fg = fg_variant, italic = true })
hl("@comment", { fg = outline, italic = true })
hl("@punctuation.bracket", { fg = fg_variant })
hl("@punctuation.delimiter", { fg = fg_variant })
hl("@tag", { fg = accent })
hl("@tag.attribute", { fg = tertiary })

-- === LSP / Diagnostics ===
hl("DiagnosticError", { fg = error })
hl("DiagnosticWarn", { fg = secondary })
hl("DiagnosticInfo", { fg = accent })
hl("DiagnosticHint", { fg = fg_variant })
hl("DiagnosticUnderlineError", { undercurl = true, sp = error })
hl("DiagnosticUnderlineWarn", { undercurl = true, sp = secondary })
hl("DiagnosticUnderlineInfo", { undercurl = true, sp = accent })
hl("DiagnosticUnderlineHint", { undercurl = true, sp = fg_variant })
hl("LspReferenceText", { bg = surface_container })
hl("LspReferenceRead", { bg = surface_container })
hl("LspReferenceWrite", { bg = surface_container })
hl("LspSignatureActiveParameter", { fg = accent, bold = true })

-- === Cmp ===
hl("CmpItemAbbr", { fg = fg })
hl("CmpItemAbbrMatch", { fg = accent, bold = true })
hl("CmpItemKind", { fg = tertiary })
hl("CmpItemMenu", { fg = outline })
hl("CmpDoc", { fg = fg, bg = surface_container })
hl("CmpDocBorder", { fg = outline })

-- === Telescope ===
hl("TelescopeNormal", { fg = fg, bg = "none" })
hl("TelescopeBorder", { fg = outline })
hl("TelescopePromptNormal", { fg = fg, bg = surface_container })
hl("TelescopePromptBorder", { fg = accent })
hl("TelescopeSelection", { fg = accent_fg, bg = secondary_container })
hl("TelescopeMatching", { fg = accent, bold = true })

-- === Gitsigns ===
hl("GitSignsAdd", { fg = accent })
hl("GitSignsChange", { fg = secondary })
hl("GitSignsDelete", { fg = error })

-- === Diff ===
hl("DiffAdd", { fg = accent, bg = "none" })
hl("DiffChange", { fg = secondary, bg = "none" })
hl("DiffDelete", { fg = error, bg = "none" })
hl("DiffText", { fg = on_secondary_container, bg = secondary_container })

hl("BufferLineBufferSelected", { fg = accent, bg = surface_container, bold = true })
hl("BufferLineTabSelected", { fg = accent, bg = surface_container, bold = true })
hl("BufferLineIndicatorSelected", { fg = accent, bg = surface_container })
hl("BufferLineBuffer", { fg = outline, bg = "none" })
hl("BufferLineBackground", { fg = outline, bg = "none" })
hl("BufferLineSeparator", { fg = outline_variant, bg = "none" })
hl("BufferLineSeparatorVisible", { fg = outline_variant, bg = "none" })
hl("BufferLineSeparatorSelected", { fg = outline_variant, bg = surface_container })
hl("BufferLineOffsetSeparator", { fg = outline })
