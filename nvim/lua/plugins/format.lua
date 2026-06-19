return {
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo", "FormatDisable", "FormatEnable", "FormatToggle" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				desc = "[F]ormat buffer",
			},
			{ "<leader>tf", "<cmd>FormatToggle<CR>", desc = "[T]oggle Auto-[F]ormat" },
		},
		opts = {
			notify_on_error = false,
			format_on_save = function(bufnr)
				if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
					return
				end
				local disable_filetypes = { c = true, cpp = true }
				if disable_filetypes[vim.bo[bufnr].filetype] then
					return nil
				end
				return { timeout_ms = 2500, lsp_format = "fallback" }
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "isort", "black" },
				javascript = { "prettierd", stop_after_first = true },
				typescript = { "prettierd", stop_after_first = true },
				json = { "prettierd", stop_after_first = true },
				jsonc = { "prettierd", stop_after_first = true },
				yaml = { "prettierd", stop_after_first = true },
				markdown = { "prettierd", stop_after_first = true },
				toml = { "taplo" },
				sh = { "shfmt" },
				zsh = { "shfmt" },
			},
		},
		config = function(_, opts)
			require("conform").setup(opts)
			vim.api.nvim_create_user_command("FormatDisable", function(args)
				if args.bang then
					vim.b.disable_autoformat = true
				else
					vim.g.disable_autoformat = true
				end
			end, { desc = "Disable autoformat-on-save", bang = true })
			vim.api.nvim_create_user_command("FormatEnable", function()
				vim.b.disable_autoformat = false
				vim.g.disable_autoformat = false
			end, { desc = "Re-enable autoformat-on-save" })
			vim.api.nvim_create_user_command("FormatToggle", function()
				vim.g.disable_autoformat = not vim.g.disable_autoformat
				print("Autoformat-on-save: " .. (vim.g.disable_autoformat and "Disabled " or "Enabled "))
			end, { desc = "Toggle autoformat-on-save globally" })
		end,
	},
}
