return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "j-hui/fidget.nvim", opts = {} },
		},
		config = function()
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			if pcall(require, "blink.cmp") then
				capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
			end

			local server_configs = require("plugins.lsp.servers")

			for name, config in pairs(server_configs) do
				config.capabilities = capabilities
				config.on_attach = require("plugins.lsp.keymaps").on_attach

				vim.lsp.config[name] = config

				vim.lsp.enable(name)
			end
		end,
	},
}
