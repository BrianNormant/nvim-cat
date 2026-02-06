{
# L'idée est venu durant mon stage, puisque je me suis retrouvé forcé à utiliser
# Neovim sans configuration et que je pouvais rien importer. Je me suis rappeler la
# simplicité de lua
	description = "New neovim config (yet again) based on nixcats";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
		nixCats.url = "github:BirdeeHub/nixCats-nvim";
		# For 0.12,
		neovim-nightly-overlay = {
			url = "github:nix-community/neovim-nightly-overlay";
		};
		nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
	};

# devrait remplacer nixvim simple et nixvim normal
# + devrais plus facilement s'integrer avec firenvim

# Meme si copier coller du code depuis mon ancienne config, il faut limite et au mieux
# Prendres inspirations

	outputs = {nixpkgs, ... }@inputs: let
		system = "x86_64-linux";
		melangeOverlay = (next: prev: {
			vimPlugins = prev.vimPlugins.extend (f': p': {
				melange-nvim = p'.melange-nvim.overrideAttrs {
					patches = [
						./patch/melange-nvim.patch
					];
				};
				sibling-swap-nvim = (prev.callPackage ./patch/slibling-swap.nix {});
				spring-boot = (prev.callPackage ./patch/spring-boot.nix {});
			});
		});
		pkgs = import nixpkgs {
			inherit system;
			overlays = [
				inputs.neovim-nightly-overlay.overlays.default
					inputs.nix-vscode-extensions.overlays.default
					melangeOverlay
			];
		};
		inherit (inputs.nixCats) utils;
		luaPath = ./.;
		categoryDefinitions = {pkgs, ...}: {
			startupPlugins = {
				gruvbox = with pkgs.vimPlugins; [
					gruvbox-material-nvim
				];
				melange = with pkgs.vimPlugins; [
					melange-nvim
				];
				builtin = with pkgs.vimPlugins; [
					nvim-nio
					mini-nvim
					auto-hlsearch-nvim
					nvim-spider
					lze
				];
				leap = with pkgs.vimPlugins; [leap-nvim];
				lsp = with pkgs.vimPlugins; [
					nvim-lspconfig
					goto-preview
				];
				dap = with pkgs.vimPlugins; [
					nvim-dap-ui
					nvim-dap
				];
				lint = with pkgs.vimPlugins; [
					nvim-lint
				];
				format = with pkgs.vimPlugins; [
					conform-nvim
				];
				runner = with pkgs.vimPlugins; [
					overseer-nvim
				];
				git = with pkgs.vimPlugins; [
					vim-fugitive
					gitsigns-nvim
				];
				ui = with pkgs.vimPlugins; [
					tabby-nvim
					lualine-nvim
					marks-nvim
					registers-nvim
					hover-nvim
					quicker-nvim
				];
				eyecandy = with pkgs.vimPlugins; [
					lspkind-nvim
					firenvim
				];
				debug = with pkgs.vimPlugins; [
					vim-startuptime
				];
			};
			lspsAndRuntimeDeps = {
				builtin = with pkgs; [
					ripgrep
					fd
					fzf
				];
				lua = with pkgs; [
					lua-language-server
					open-vsx.tomblind.local-lua-debugger-vscode
					stylua
					luajitPackages.luacheck
				];
				nix = with pkgs; [
					nixd
					alejandra
					statix
				];
				java = with pkgs; [
					jdk21_headless
					jdk25_headless
					jdt-language-server
				];
			};
			optionalPlugins = {
				ui = with pkgs.vimPlugins; [
					nvim-origami
				];
				eyecandy = with pkgs.vimPlugins; [
					lsp_signature-nvim
				];
				fzflua = with pkgs.vimPlugins; [
					fzf-lua
				];
				git = with pkgs.vimPlugins; [
					codediff-nvim
				];
				treesitter = with pkgs.vimPlugins; [
					nvim-treesitter-legacy
					(nvim-treesitter.withAllGrammars.overrideAttrs {
						src = pkgs.fetchFromGitHub {
							owner = "nvim-treesitter";
							repo = "nvim-treesitter";
							rev = "master"; # Until Iswap updates
							hash = "sha256-CVs9FTdg3oKtRjz2YqwkMr0W5qYLGfVyxyhE3qnGYbI=";
						};
					})
					treesj
					sibling-swap-nvim
					iswap-nvim
				];
				lua = with pkgs.vimPlugins; [
					lazydev-nvim
				];
				java = with pkgs.vimPlugins; [
					nvim-java
					nvim-java-core
					nvim-java-refactor
					nvim-java-test
					nvim-java-dap
					spring-boot
				];
			};
			environmentVariables = {
				git = {
					VSCODE_DIFF_NO_AUTO_INSTALL = "1";
				};
				melange = {
					FZF_DEFAULT_OPTS = "--color=bg+:#3c3836,bg:#32302f,spinner:#8ec07c,hl:#83a598 --color=fg:#bdae93,header:#83a598,info:#fabd2f,pointer:#8ec07c --color=marker:#8ec07c,fg+:#ebdbb2,prompt:#fabd2f,hl+:#83a598 --color=bg+:#3c3836,bg:#32302f,spinner:#8ec07c,hl:#83a598 --color=fg:#bdae93,header:#83a598,info:#fabd2f,pointer:#8ec07c --color=marker:#8ec07c,fg+:#ebdbb2,prompt:#fabd2f,hl+:#83a598 --color=bg+:#3c3836,bg:#32302f,spinner:#8ec07c,hl:#83a598 --color=fg:#bdae93,header:#83a598,info:#fabd2f,pointer:#8ec07c --color=marker:#8ec07c,fg+:#ebdbb2,prompt:#fabd2f,hl+:#83a598";
				};
			};
		};

		packagesDefinitions = rec {
			nvim = {...}: {
				settings = {
					wrapRc = "NIXCAT_DEBUG";
					configDirName = "nvim-cat";
					suffix-path = true;
					suffix-LD = true;
				};
				categories = {
					melange = false;
					builtin = true;
					treesitter = true;
					leap = true;
					lsp = true;
					dap = true;
					lint = false;
					format = true;
					runner = true;
					lua = true;
					java = true;
					jdk = {
						jdk21 = pkgs.jdk21_headless;
						jdk25 = pkgs.jdk25_headless;
						jdtls = pkgs.jdt-language-server;
					};
					git = true;
					nix = true;
					ui = true;
					eyecandy = true;
					debug = true;
				};
				extra = {
					nixdExtras.nixpkgs = ''import ${pkgs.path}'';
				};
			};
			# Very simple config to edit Todos, notes, ect
			# (try org-mode)
			vim = {...}: {
				categories = {
					melange = true;
					builtin = true;
				};
			};
			vi = {...}: {
				categories = {};
			};
		};
	in rec {
		packages."${system}" = let
			fn = utils.baseBuilder
			luaPath
				{inherit pkgs;}
				categoryDefinitions
				packagesDefinitions;
		in {
			nvim     = fn "nvim";
			vim      = fn "vim";
			vi       = fn "vi";
		};
		overlays.default = final: prev: {
			inherit (packages."${system}") nvim vim vi;
		};
	};
}
