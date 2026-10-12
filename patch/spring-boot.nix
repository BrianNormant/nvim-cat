{pkgs, ...}:
let
inherit (pkgs) vimUtils fetchFromGitHub;
in  vimUtils.buildVimPlugin {
	name = "spring-boot";
	# version = "23/12/2025";
	src = fetchFromGitHub {
		owner = "JavaHello";
		repo = "spring-boot.nvim";
		rev = "9880be4";
		hash = "sha256-+zgi9Jhh5f3kPr5VC2KZ3x7OEXdTao5gQM48y5NlGo4=";
	};
}
