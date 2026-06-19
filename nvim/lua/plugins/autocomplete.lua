return {
	{
		"saghen/blink.cmp",
		version = "1.*",
		dependencies = {
			"saghen/blink.lib",
			{ "L3MON4D3/LuaSnip", version = "2.*" },
		},
		opts = {
			keymap = { preset = "super-tab" },
			appearance = { nerd_font_variant = "mono" },

			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},

			cmdline = {
				enabled = true,
				sources = function()
					local type = vim.fn.getcmdtype()
					if type == "/" or type == "?" then
						return { "buffer" }
					end
					if type == ":" then
						return { "cmdline" }
					end
					return {}
				end,
			},

			snippets = { preset = "luasnip" },
			signature = { enabled = true },
		},
	},
}
