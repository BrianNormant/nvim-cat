do
	-- because we can't run stuff directly on nix, we symlink to
	-- the store directory
	local cache = vim.fn.stdpath('cache')
	local jdtls_path = nixCats.get('jdk').jdtls
	local jdtls_version = '1.54.0'

	require('java').setup {
		jdk = {
			auto_install = false,
			version = '25',
		},
		jdtls = {
			version = jdtls_version
		}
	}

	-- for jdtls,
	if not _G.jdtls_replaced then
		local fmt = [[
		export cache=%s
		export path=%s
		export version=%s
		export jdtls=$cache/nvim-java/packages/jdtls/$version

		# Bin
		if [ ! -L $jdtls/bin ]; then
			rm -rf $jdtls/bin
			ln -s $path/bin $jdtls/bin
		fi

		# Config
		if [ ! -L $jdtls/config_linux ]; then
			rm -rf $jdtls/config_linux
			ln -s $path/share/java/jdtls/config_linux $jdtls/config_linux
		fi

		# Plugins
		if [ ! -L $jdtls/plugins ]; then
			rm -rf $jdtls/plugins
			ln -s $path/share/java/jdtls/plugins $jdtls/plugins
		fi

		# Features
		if [ ! -L $jdtls/features ]; then
			rm -rf $jdtls/features
			ln -s $path/share/java/jdtls/features $jdtls/features
		fi
		]]

		local cmd = string.format(
			fmt,
			cache,
			jdtls_path,
			jdtls_version
		)
		-- vim.notify(cmd)

		os.execute(cmd)
		_G.jdtls_replaced = true
	end

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
