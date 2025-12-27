{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # M.2 SSD - OS installation
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  # ZFS pool for mirrored 4TB drives
  # Note: This assumes the pool is already created. Pool creation happens during initial setup.
  fileSystems."/tank" = {
    device = "tank";
    fsType = "zfs";
  };

  # Swap file on M.2 SSD
  swapDevices = [
    { device = "/swapfile"; size = 8192; } # 8GB swap
  ];

  # Enable ZFS support
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;

  # ZFS requires setting a hostId
  networking.hostId = "8425e349"; # Random 8-digit hex, change if needed

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
