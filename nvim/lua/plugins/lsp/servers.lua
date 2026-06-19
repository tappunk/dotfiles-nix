local binary_names = {
	lua_ls = { "lua-language-server" },
	bashls = { "bash-language-server", "start" },
	jsonls = { "vscode-json-language-server", "--stdio" },
	yamlls = { "yaml-language-server", "--stdio" },
	taplo = { "taplo", "lsp", "stdio" },
	marksman = { "marksman" },
	pyright = { "pyright-langserver", "--stdio" },
	ts_ls = { "typescript-language-server", "--stdio" },
	clangd = { "clangd" },
}

local function make_cmd(name)
	local args = binary_names[name]
	if not args or vim.fn.executable(args[1]) == 0 then
		return nil
	end

	local cmd = { args[1] }
	for i = 2, #args do
		table.insert(cmd, args[i])
	end
	return cmd
end

local raw_configs = {
	lua_ls = {
		settings = {
			Lua = {
				runtime = { version = "LuaJIT" },
				diagnostics = { globals = { "vim" } },
				workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
				completion = { callSnippet = "Replace" },
			},
		},
		filetypes = { "lua" },
	},
	bashls = { filetypes = { "sh", "bash", "zsh" } },
	jsonls = { filetypes = { "json", "jsonc" } },
	yamlls = { filetypes = { "yaml" } },
	taplo = { filetypes = { "toml" } },
	marksman = { filetypes = { "markdown" } },
	pyright = { filetypes = { "python" } },
	ts_ls = { filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" } },
	clangd = { filetypes = { "c", "cpp", "cc", "cxx", "h", "hpp" } },
}

local server_configs = {}

-- Filter profiles dynamically so Neovim only mounts configurations for valid system runtimes
for name, config in pairs(raw_configs) do
	local target_cmd = make_cmd(name)
	if target_cmd then
		config.cmd = target_cmd
		server_configs[name] = config
	end
end

return server_configs
