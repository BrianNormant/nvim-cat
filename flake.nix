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

	outputs = { self, nixpkgs, ... }@inputs: let
		system = "x86_64-linux";
		melangeOverlay = (next: prev: {
			vimPlugins = prev.vimPlugins.extend (f': p': {
				melange-nvim = p'.melange-nvim.overrideAttrs {
					patches = [
						./patch/melange-nvim.patch
					];
				};
				sibling-swap-nvim = (prev.callPackage ./patch/slibling-swap.nix {});
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
		categoryDefinitions = {pkgs, settings, ...}@pdef: {
			startupPlugins = {
				gruvbox = with pkgs.vimPlugins; [
					gruvbox-material-nvim
				];
				melange = with pkgs.vimPlugins; [
					melange-nvim
				];
				builtin = with pkgs.vimPlugins; [
					oil-nvim # replace netwr
					mini-nvim
					fzf-lua
					auto-hlsearch-nvim
					leap-nvim
					nvim-spider
					(nvim-treesitter.withAllGrammars.overrideAttrs {
						src = pkgs.fetchFromGitHub {
							owner = "nvim-treesitter";
							repo = "nvim-treesitter";
							rev = "master"; # Until Iswap updates
							hash = "sha256-CVs9FTdg3oKtRjz2YqwkMr0W5qYLGfVyxyhE3qnGYbI=";
						};
					})
					treesj
					iswap-nvim
					sibling-swap-nvim
				];
				lsp = with pkgs.vimPlugins; [
					nvim-lspconfig
					goto-preview
				];
				git = with pkgs.vimPlugins; [
					vim-fugitive
					gitsigns-nvim
					codediff-nvim
				];
				lua = with pkgs.vimPlugins; [
					lazydev-nvim
				];
				ui = with pkgs.vimPlugins; [
					tabby-nvim
					lualine-nvim
					marks-nvim
					registers-nvim
					hover-nvim
				];
				eyecandy = with pkgs.vimPlugins; [
					lspkind-nvim
					lsp_signature-nvim
					firenvim
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
				];
			};
			optionalPlugins = {};
			environmentVariables = {
				git = {
					VSCODE_DIFF_NO_AUTO_INSTALL = "1";
				};
			};
		};

		packagesDefinitions = rec {
			nvim = nvim-cat;
			nvim-cat = {pkgs, ...}: {
				settings = {
					wrapRc = "NIXCAT_DEBUG";
					configDirName = "nvim-cat";
					suffix-path = true;
					suffix-LD = true;
				};
				categories = {
					melange = true;
					builtin = true;
					lsp = true;
					lua = true;
					git = true;
					nix = true;
					ui = true;
					eyecandy = true;
				};
			};
		};
	in {
		packages."${system}" = {
			nvim-cat = utils.baseBuilder luaPath {inherit pkgs;} categoryDefinitions packagesDefinitions "nvim-cat";
			nvim = utils.baseBuilder luaPath {inherit pkgs;} categoryDefinitions packagesDefinitions "nvim";
		};
	};
}
