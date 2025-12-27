{
  description = "NixOS configuration for UGreen DXP 2800 NAS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, disko }: {
    nixosConfigurations.nixnas = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
         disko.nixosModules.disko
        ./disk-config.nix
        ./configuration.nix
        { hardware.facter.reportPath = ./facter.json; }
      ];
    };
  };
}
