{pkgs, ...}:
let
inherit (pkgs) vimUtils fetchFromGitHub;
in  vimUtils.buildVimPlugin {
	name = "spring-boot";
	# version = "23/12/2025";
	src = fetchFromGitHub {
		owner = "JavaHello";
		repo = "spring-boot.nvim";
		rev = "affc5d1";
		hash = "sha256-/N+jLmL5YC+8Rp7rwRcRF+aFn6bWbiFEsJJ7Q7u8Wq8=";
	};
}
