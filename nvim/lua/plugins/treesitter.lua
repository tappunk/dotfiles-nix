return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		-- lazy.nvim automatically passes this table to the plugin's internal setup
		opts = {
			ensure_installed = {
				"bash",
				"c",
				"diff",
				"html",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"query",
				"vim",
				"vimdoc",
				"rust",
				"ron",
				"toml",
			},
			highlight = {
				enable = true,
			},
		},
	},
}
