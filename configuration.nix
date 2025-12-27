{ config, pkgs, ... }:

{
  imports = [ ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nixnas";
  networking.networkmanager.enable = true;

  # Time zone
  time.timeZone = "UTC";

  # Internationalization
  i18n.defaultLocale = "en_US.UTF-8";

  # ZFS services
  services.zfs.autoScrub = {
    enable = true;
    interval = "weekly";
  };

  services.zfs.trim = {
    enable = true;
    interval = "weekly";
  };

  # Enable ZFS auto-snapshot
  services.zfs.autoSnapshot = {
    enable = true;
    frequent = 4;  # Keep 4 15-minute snapshots
    hourly = 24;   # Keep 24 hourly snapshots
    daily = 7;     # Keep 7 daily snapshots
    weekly = 4;    # Keep 4 weekly snapshots
    monthly = 12;  # Keep 12 monthly snapshots
  };

  # Enable SSH for remote management
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  # NFS server for network sharing
  services.nfs.server = {
    enable = true;
    exports = ''
      /tank         *(rw,sync,no_subtree_check,no_root_squash)
    '';
  };

  # Samba server for Windows/macOS sharing
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "NixNAS";
        "netbios name" = "nixnas";
        "security" = "user";
        "hosts allow" = "192.168. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      tank = {
        "path" = "/tank";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
    };
  };

  # Firewall configuration
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22    # SSH
      2049  # NFS
      139   # Samba
      445   # Samba
    ];
    allowedUDPPorts = [
      137   # Samba
      138   # Samba
    ];
  };

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    git
    htop
    tmux
    rsync
    wget
    curl
    zfs
    smartmontools  # Drive health monitoring
    lm_sensors     # Hardware sensors
  ];

  # Enable smartd for drive monitoring
  services.smartd = {
    enable = true;
    autodetect = true;
  };

  # Users configuration
  users.users.admin = {
    isNormalUser = true;
    description = "NAS Administrator";
    extraGroups = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys = [
      # Add your SSH public key here
      # "ssh-ed25519 AAAAC3... user@host"
    ];
  };

  # Enable automatic system upgrades
  system.autoUpgrade = {
    enable = false;  # Set to true if you want automatic updates
    flake = "/etc/nixos";
  };

  # Nix settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  system.stateVersion = "25.11";
}
