.PHONY: iso clean-iso

iso:
	cd iso && nix build

clean-iso:
	rm -rf iso/result
