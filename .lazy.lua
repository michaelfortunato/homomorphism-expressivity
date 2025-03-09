vim.api.nvim_create_autocmd({ "FileType" }, {
	pattern = { "typst" },
	callback = function(ev)
		Snacks.toggle.option("spell", { name = "Spelling" }):set(false)
	end,
})
return {}
