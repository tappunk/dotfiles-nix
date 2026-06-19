vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = true

vim.g.rustaceanvim = {
	tools = {
		workspace_symbols = true,
		inlay_hints = {
			enable = true,
		},
	},
	server = {
		default_settings = {
			["rust-analyzer"] = {
				cargo = { allFeatures = true },
				checkOnSave = { command = "clippy" },
			},
		},
	},
}

vim.opt.clipboard = "unnamedplus"
-- vim.opt.termguicolors removed to allow Ghostty palette bridging via cterm attributes
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = "│ ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.confirm = true
vim.opt.wrap = true
vim.opt.textwidth = 80
vim.opt.colorcolumn = "80"
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldenable = true
vim.opt.foldlevel = 99

local numbertoggle_group = vim.api.nvim_create_augroup("config-numbertoggle", { clear = true })
vim.api.nvim_create_autocmd("InsertEnter", {
	group = numbertoggle_group,
	desc = "Disable relative numbers in Insert mode",
	callback = function()
		if vim.wo.number then
			vim.wo.relativenumber = false
		end
	end,
})
vim.api.nvim_create_autocmd("InsertLeave", {
	group = numbertoggle_group,
	desc = "Enable relative numbers in Normal mode",
	callback = function()
		if vim.wo.number then
			vim.wo.relativenumber = true
		end
	end,
})

local highlight_yank_group = vim.api.nvim_create_augroup("config-highlight-yank", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	group = highlight_yank_group,
	desc = "Highlight when yanking (copying) text",
	callback = function()
		vim.hl.on_yank()
	end,
})

vim.diagnostic.config({
	update_in_insert = false,
	severity_sort = true,
	float = { border = "rounded", source = "if_many" },
	underline = { severity = { min = vim.diagnostic.severity.WARN } },
	virtual_text = true,
	virtual_lines = false,
	jump = {
		on_jump = function(_diagnostic, bufnr)
			vim.diagnostic.open_float({
				border = "rounded",
				source = "if_many",
				bufnr = bufnr,
			})
		end,
	},
})

return {}
