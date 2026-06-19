return {
	{
		"mrcjkb/rustaceanvim",
		version = "^5",
		lazy = false,
	},

	{
		"saecki/crates.nvim",
		ft = "toml",
		config = function()
			require("crates").setup()
		end,
	},
}
