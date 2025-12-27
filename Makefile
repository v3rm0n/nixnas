.PHONY: iso clean-iso clean-cache hardware-config

# Variables
NAS_HOST ?= nixnas
NAS_USER ?= root

iso:
	docker run --rm -it \
		--platform linux/amd64 \
		-v $(PWD)/iso:/workspace \
		-v nixnas-nix-store:/nix \
		-e NIX_REMOTE="" \
		-w /workspace \
		nixpkgs/nix-flakes:latest \
		sh -c "nix --extra-experimental-features 'nix-command flakes' build --option sandbox false --option filter-syscalls false && cp -L result/iso/*.iso /workspace/"

clean-iso:
	rm -rf iso/result

clean-cache:
	docker volume rm nixnas-nix-store

hardware-config:
	nix run github:nix-community/nixos-anywhere -- --flake '.#nixnas' --generate-hardware-config nixos-facter ./facter.json --target-host $(NAS_USER)@$(NAS_HOST)

install:
	nix run github:nix-community/nixos-anywhere -- --flake '.#nixnas' --target-host $(NAS_USER)@$(NAS_HOST)
