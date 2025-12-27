{
  disko.devices = {
    disk = {
      # NVMe SSD - System disk
      nvme = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };

      # First 4TB HDD - Data pool member 1
      sda = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "tank";
              };
            };
          };
        };
      };

      # Second 4TB HDD - Data pool member 2
      sdb = {
        type = "disk";
        device = "/dev/sdb";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "tank";
              };
            };
          };
        };
      };
    };

    zpool = {
      # Mirrored ZFS pool for data storage
      tank = {
        type = "zpool";
        mode = "mirror";
        rootFsOptions = {
          compression = "lz4";
          atime = "off";
          xattr = "sa";
          acltype = "posixacl";
          "com.sun:auto-snapshot" = "true";
        };
        options = {
          ashift = "12";
          autotrim = "on";
        };

        datasets = {
          # Root dataset for the pool
          "root" = {
            type = "zfs_fs";
            mountpoint = "/tank";
            options = {
              compression = "lz4";
              "com.sun:auto-snapshot" = "true";
            };
          };

          # Dataset for shared data
          "root/data" = {
            type = "zfs_fs";
            mountpoint = "/tank/data";
            options = {
              compression = "lz4";
              "com.sun:auto-snapshot" = "true";
            };
          };

          # Dataset for media files (lower compression for already compressed media)
          "root/media" = {
            type = "zfs_fs";
            mountpoint = "/tank/media";
            options = {
              compression = "lz4";
              "com.sun:auto-snapshot" = "true";
            };
          };

          # Dataset for backups
          "root/backups" = {
            type = "zfs_fs";
            mountpoint = "/tank/backups";
            options = {
              compression = "lz4";
              "com.sun:auto-snapshot" = "true";
            };
          };

          # Dataset for Time Machine backups
          "root/timemachine" = {
            type = "zfs_fs";
            mountpoint = "/tank/timemachine";
            options = {
              compression = "lz4";
              "com.sun:auto-snapshot" = "false";
            };
          };

          # Dataset for Docker volumes
          "root/docker" = {
            type = "zfs_fs";
            mountpoint = "/tank/docker";
            options = {
              compression = "lz4";
              "com.sun:auto-snapshot" = "true";
            };
          };

          # Dataset for Jellyfin data
          "root/jellyfin" = {
            type = "zfs_fs";
            mountpoint = "/tank/jellyfin";
            options = {
              compression = "lz4";
              "com.sun:auto-snapshot" = "true";
            };
          };

          # Dataset for Immich data
          "root/immich" = {
            type = "zfs_fs";
            mountpoint = "/tank/immich";
            options = {
              compression = "lz4";
              "com.sun:auto-snapshot" = "true";
            };
          };
        };
      };
    };
  };
}
