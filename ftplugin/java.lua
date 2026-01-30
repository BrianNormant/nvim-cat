if nixCats('java') and nixCats('lsp') then
	vim.cmd.packadd "vimplugin-spring-boot"
	vim.cmd.packadd "nvim-java-core"
	vim.cmd.packadd "nvim-java-dap"
	vim.cmd.packadd "nvim-java-refactor"
	vim.cmd.packadd "nvim-java-test"
	vim.cmd.packadd "nvim-java"
	-- because we can't run stuff directly on nix, we symlink to
	-- the store directory
	local cache = vim.fn.stdpath('data')
	local jdtls_path = nixCats.get('jdk').jdtls
	local jdtls_version = '1.54.0'

		-- for jdtls,
	if not _G.jdtls_replaced then
		local fmt = [[
		export cache=%s
		export path=%s
		export version=%s
		export jdtls=$cache/nvim-java/packages/jdtls/$version

		# Bin
		if [ ! -L $jdtls/bin ]; then
			rm -r $jdtls/bin 2> ~/.local/state/nvim-cat/java.log
			ln -s $path/bin $jdtls/bin
		fi

		# Config
		if [ ! -L $jdtls/config_linux ]; then
			rm -r $jdtls/config_linux 2> ~/.local/state/nvim-cat/java.log
			ln -s $path/share/java/jdtls/config_linux $jdtls/config_linux
		fi

		# Plugins
		if [ ! -L $jdtls/plugins ]; then
			rm -r $jdtls/plugins 2> ~/.local/state/nvim-cat/java.log
			ln -s $path/share/java/jdtls/plugins $jdtls/plugins
		fi

		# Features
		if [ ! -L $jdtls/features ]; then
			rm -r $jdtls/features 2> ~/.local/state/nvim-cat/java.log
			ln -s $path/share/java/jdtls/features $jdtls/features
		fi
		]]

		local cmd = string.format(
			fmt,
			cache,
			jdtls_path,
			jdtls_version
		)

		local file = vim.fn.tempname()
		local f = io.open(file, "w")
		if f then
			f:write(cmd)
			f:close()
		end
		os.execute("sh " .. file)
		os.remove(file)

		_G.jdtls_replaced = true
	end

	require('java').setup {
		jdk = {
			auto_install = false,
		},
		jdtls = {
			version = jdtls_version
		}
	}

	vim.lsp.config('jdtls', {
		settings = {
			java = {
				configuration = {
					runtimes = {
						{
							name = "JavaSE-25",
							path = nixCats.get('jdk').jdk25 .. "/lib/openjdk",
							default = true,
						},
						{
							name = "JavaSE-21",
							path = nixCats.get('jdk').jdk21 .. "/lib/openjdk",
							default = false,
						},
					},
				},
			},
		},
	})
	vim.lsp.enable('jdtls')
end
