_default:
	@just --list

build:
	@nix build .#go
