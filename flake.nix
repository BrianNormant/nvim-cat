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
	};

# devrait remplacer nixvim simple et nixvim normal
# + devrais plus facilement s'integrer avec firenvim

# Meme si copier coller du code depuis mon ancienne config, il faut limite et au mieux
# Prendres inspirations

	outputs = { self, nixpkgs, ... }@inputs: let
		system = "x86_64-linux";
		pkgs = import nixpkgs {
			inherit system;
			overlays = [inputs.neovim-nightly-overlay.overlays.default];
		};
		inherit (inputs.nixCats) utils;
		luaPath = ./.;
		categoryDefinitions = {pkgs, settings, ...}@pdef: {
			startupPlugins = {
				gruvbox = with pkgs.vimPlugins; [
					gruvbox-material-nvim
				];
				builtin = with pkgs.vimPlugins; [
					oil-nvim
				];
			};
			lspsAndRuntimeDeps = {};
			optionalPlugins = {};
			environmentVariables = {};
		};

		packagesDefinitions = {
			nvim-cat = {pkgs, ...}: {
				settings = {
					wrapRc = "NIXCAT_DEBUG";
					configDirName = "nvim-cat";
				};
				categories = {
					gruvbox = true;
					builtin = true;
				};
			};
		};
	in {
		packages."${system}" = {
			nvim-cat = utils.baseBuilder luaPath {inherit pkgs;} categoryDefinitions packagesDefinitions "nvim-cat";
		};
	};
}
