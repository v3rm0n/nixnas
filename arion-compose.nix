{ pkgs, ... }:

{
  project.name = "nixnas";

  services = {
    # Jellyfin media server
    jellyfin.service = {
      image = "jellyfin/jellyfin:latest";
      container_name = "jellyfin";
      restart = "unless-stopped";
      ports = [
        "8096:8096"  # HTTP web interface
        "8920:8920"  # HTTPS web interface (optional)
      ];
      volumes = [
        "/tank/jellyfin/config:/config"
        "/tank/jellyfin/cache:/cache"
        "/tank/media:/media:ro"
      ];
      environment = {
        PUID = "1000";
        PGID = "100";
        TZ = "UTC";
      };
      # Hardware acceleration (if available)
      devices = [
        "/dev/dri:/dev/dri"
      ];
    };

    # Immich photo management - Main server
    immich-server.service = {
      image = "ghcr.io/immich-app/immich-server:release";
      container_name = "immich-server";
      restart = "unless-stopped";
      ports = [
        "2283:2283"
      ];
      volumes = [
        "/tank/immich/upload:/usr/src/app/upload"
        "/tank/immich/library:/usr/src/app/library:ro"
        "/etc/localtime:/etc/localtime:ro"
      ];
      environment = {
        DB_HOSTNAME = "immich-postgres";
        DB_USERNAME = "immich";
        DB_PASSWORD = "immich";
        DB_DATABASE_NAME = "immich";
        REDIS_HOSTNAME = "immich-redis";
        UPLOAD_LOCATION = "/usr/src/app/upload";
      };
      depends_on = [
        "immich-postgres"
        "immich-redis"
      ];
    };

    # Immich machine learning
    immich-machine-learning.service = {
      image = "ghcr.io/immich-app/immich-machine-learning:release";
      container_name = "immich-machine-learning";
      restart = "unless-stopped";
      volumes = [
        "/tank/immich/model-cache:/cache"
      ];
    };

    # PostgreSQL database for Immich
    immich-postgres.service = {
      image = "tensorchord/pgvecto-rs:pg14-v0.2.0";
      container_name = "immich-postgres";
      restart = "unless-stopped";
      environment = {
        POSTGRES_USER = "immich";
        POSTGRES_PASSWORD = "immich";
        POSTGRES_DB = "immich";
      };
      volumes = [
        "/tank/immich/postgres:/var/lib/postgresql/data"
      ];
    };

    # Redis cache for Immich
    immich-redis.service = {
      image = "redis:7.4-alpine";
      container_name = "immich-redis";
      restart = "unless-stopped";
      volumes = [
        "/tank/immich/redis:/data"
      ];
    };
  };
}
