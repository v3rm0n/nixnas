{ config, pkgs, lib, ... }:

{
  imports = [ ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nixnas";
  networking.hostId = "8425e349";  # Required for ZFS
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
        # Time Machine support
        "vfs objects" = "catia fruit streams_xattr";
        "fruit:metadata" = "stream";
        "fruit:model" = "MacSamba";
        "fruit:posix_rename" = "yes";
        "fruit:veto_appledouble" = "no";
        "fruit:wipe_intentionally_left_blank_rfork" = "yes";
        "fruit:delete_empty_adfiles" = "yes";
      };
      tank = {
        "path" = "/tank";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
      # Time Machine backup share
      timemachine = {
        "path" = "/tank/timemachine";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0600";
        "directory mask" = "0700";
        "fruit:time machine" = "yes";
        "fruit:time machine max size" = "500G";
      };
    };
  };

  # Avahi/mDNS for Time Machine discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
    extraServiceFiles = {
      smb = ''
        <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name replace-wildcards="yes">%h</name>
          <service>
            <type>_smb._tcp</type>
            <port>445</port>
          </service>
          <service>
            <type>_device-info._tcp</type>
            <port>9</port>
            <txt-record>model=TimeCapsule8,119</txt-record>
          </service>
          <service>
            <type>_adisk._tcp</type>
            <port>9</port>
            <txt-record>dk0=adVN=timemachine,adVF=0x82</txt-record>
            <txt-record>sys=waMA=0,adVF=0x100</txt-record>
          </service>
        </service-group>
      '';
    };
  };

  # Docker configuration
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    storageDriver = "overlay2";
    # Use ZFS dataset for Docker data
    daemon.settings = {
      data-root = "/tank/docker";
    };
  };

  # Arion configuration for Docker Compose management
  # The arion-compose.nix file defines the containers
  # After deployment, run: arion up -d
  environment.etc."arion/nixnas/arion-compose.nix".source = ./arion-compose.nix;
  environment.etc."arion/nixnas/arion-pkgs.nix".source = ./arion-pkgs.nix;

  # Firewall configuration
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22    # SSH
      2049  # NFS
      139   # Samba
      445   # Samba
      5353  # Avahi/mDNS
      8096  # Jellyfin HTTP
      8920  # Jellyfin HTTPS
      2283  # Immich
    ];
    allowedUDPPorts = [
      137   # Samba
      138   # Samba
      5353  # Avahi/mDNS
    ];
  };

  # System packages
  environment.systemPackages = with pkgs; [
    neovim
    git
    htop
    tmux
    rsync
    wget
    curl
    zfs
    smartmontools  # Drive health monitoring
    lm_sensors     # Hardware sensors
    docker-compose # Docker Compose CLI
    arion          # Declarative Docker Compose
  ];

  # Enable smartd for drive monitoring
  services.smartd = {
    enable = true;
    autodetect = true;
  };

  # Users configuration
  users.users.maidok = {
    isNormalUser = true;
    description = "NAS Administrator";
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    openssh.authorizedKeys.keys = [
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBDW1VjVj96qNdJwJ5DrQUpTO760STvWDiFpnx6lkYzBowlGEW/xss2yGCPO77TfP31Y87X9OTSmon4Vz6UqopbU= maidok@maibook"
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
