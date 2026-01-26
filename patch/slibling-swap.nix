{pkgs, ...}:
let
inherit (pkgs) vimUtils fetchFromGitHub;
in  vimUtils.buildVimPlugin {
	name = "sibling-swap.nvim";
	# version = "23/12/2025";
	src = fetchFromGitHub {
		owner = "Wansmer";
		repo = "sibling-swap.nvim";
		rev = "75e696c";
		hash = "sha256-8AGMJePHYAT+XeHgXQb+RkzyTpWI0bo7u223+YxxkVI=";
	};
}
