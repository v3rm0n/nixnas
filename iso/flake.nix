{
  description = "NixOS NAS installer";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.default = self.nixosConfigurations.nasIso.config.system.build.isoImage;
    nixosConfigurations = {
      nasIso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({ pkgs, modulesPath, lib, ... }: {
            imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];

            # Locale settings
            i18n.defaultLocale = "en_US.UTF-8";

            # Enable programs
            programs.zsh.enable = true;
            services.openssh.enable = true;

            # Root user configuration
            users.users.root = {
              openssh.authorizedKeys.keys = [
                "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBDW1VjVj96qNdJwJ5DrQUpTO760STvWDiFpnx6lkYzBowlGEW/xss2yGCPO77TfP31Y87X9OTSmon4Vz6UqopbU= maidok@maibook"
              ];
            };

            environment.systemPackages = with pkgs; [
              neovim
              git
              rsync
              wget
              curl
            ];
          })
        ];
      };
    };
  };
}
