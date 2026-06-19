local function apply_ghostty_theme()
	vim.opt.termguicolors = false

	vim.cmd("highlight clear")
	if vim.fn.exists("syntax_on") == 1 then
		vim.cmd("syntax reset")
	end

	local hl = vim.api.nvim_set_hl

	hl(0, "Normal", { bg = "NONE", fg = "NONE" })
	hl(0, "NormalFloat", { bg = "NONE", fg = "NONE" })
	hl(0, "NormalNC", { bg = "NONE", fg = "NONE" })

	hl(0, "CursorLine", { ctermbg = 0, underline = true, sp = 14 })
	hl(0, "CursorLineNr", { ctermfg = 11, bold = true })
	hl(0, "CursorLineComment", { ctermfg = 7, italic = true })

	hl(0, "LineNr", { ctermfg = 8 })
	hl(0, "WinSeparator", { ctermfg = 8, bold = true })
	hl(0, "SignColumn", { bg = "NONE", ctermfg = 8 })
	hl(0, "ColorColumn", { ctermbg = 8 })
	hl(0, "Visual", { ctermbg = 8 })

	hl(0, "Comment", { ctermfg = 8, italic = true })
	hl(0, "Keyword", { ctermfg = 5, bold = true })
	hl(0, "Statement", { ctermfg = 5, bold = true })
	hl(0, "Operator", { ctermfg = 6 })
	hl(0, "Function", { ctermfg = 4, bold = true })
	hl(0, "Method", { ctermfg = 4, bold = true })
	hl(0, "Type", { ctermfg = 2, bold = true })
	hl(0, "Identifier", { ctermfg = 14 })
	hl(0, "String", { ctermfg = 3 })
	hl(0, "Constant", { ctermfg = 1 })
	hl(0, "Number", { ctermfg = 3 })
	hl(0, "Boolean", { ctermfg = 3, bold = true })
	hl(0, "Special", { ctermfg = 13 })
	hl(0, "Delimiter", { ctermfg = 7 })

	hl(0, "@variable", { ctermfg = 7 })
	hl(0, "@property", { ctermfg = 14 })
	hl(0, "@field", { ctermfg = 14 })
	hl(0, "@parameter", { ctermfg = 14 })
	hl(0, "@constructor", { ctermfg = 4, bold = true })
	hl(0, "@type", { ctermfg = 2, bold = true })
	hl(0, "@function", { ctermfg = 4, bold = true })
	hl(0, "@keyword", { ctermfg = 5, bold = true })
	hl(0, "@string", { ctermfg = 3 })
	hl(0, "@comment", { ctermfg = 8, italic = true })

	hl(0, "DiffAdd", { ctermfg = 2, ctermbg = 0 })
	hl(0, "DiffChange", { ctermfg = 3, ctermbg = 0 })
	hl(0, "DiffDelete", { ctermfg = 1, ctermbg = 0 })
	hl(0, "DiffText", { ctermfg = 4, ctermbg = 8 })

	hl(0, "DiagnosticError", { ctermfg = 1 })
	hl(0, "DiagnosticWarn", { ctermfg = 3 })
	hl(0, "DiagnosticInfo", { ctermfg = 6 })
	hl(0, "DiagnosticHint", { ctermfg = 14 })

	hl(0, "StatusLine", { ctermfg = 7, ctermbg = 8 })
	hl(0, "StatusLineNC", { ctermfg = 8, ctermbg = 0 })
end

vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	callback = apply_ghostty_theme,
})

apply_ghostty_theme()

return {}
