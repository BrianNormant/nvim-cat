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
					oil-nvim
					mini-nvim
				];
				lsp = with pkgs.vimPlugins; [
					nvim-lspconfig
				];
				git = with pkgs.vimPlugins; [
					vim-fugitive
				];
				lua = with pkgs.vimPlugins; [
					lazydev-nvim
				];
			};
			lspsAndRuntimeDeps = {
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
			environmentVariables = {};
		};

		packagesDefinitions = {
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
				};
			};
		};
	in {
		packages."${system}" = {
			nvim-cat = utils.baseBuilder luaPath {inherit pkgs;} categoryDefinitions packagesDefinitions "nvim-cat";
		};
	};
}
