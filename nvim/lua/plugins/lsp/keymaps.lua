local function on_attach(client, bufnr)
	local map = function(keys, func, desc, mode)
		vim.keymap.set(mode or "n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
	end

	map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
	map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })
	map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

	if client and client:supports_method("textDocument/documentHighlight") then
		local highlight_group = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
		vim.api.nvim_clear_autocmds({ buffer = bufnr, group = highlight_group })

		vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
			buffer = bufnr,
			group = highlight_group,
			callback = vim.lsp.buf.document_highlight,
		})
		vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
			buffer = bufnr,
			group = highlight_group,
			callback = vim.lsp.buf.clear_references,
		})
	end

	if client and client:supports_method("textDocument/inlayHint") then
		map("<leader>th", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }))
		end, "[T]oggle Inlay [H]ints")
	end
end

return { on_attach = on_attach }
