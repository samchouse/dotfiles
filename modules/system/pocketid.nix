{ lib, ... }: {
  den.aspects.pocket-id = {
    nixos = { pkgs, config, ... }: {
      services.pocket-id = {
        enable = true;
        package = pkgs.pocket-id;
        settings = {
          EMAILS_VERIFIED = true;
          APP_URL = "https://id.xenfo.dev";
          ALLOW_USER_SIGNUPS = "withToken";
          TRUSTED_PLATFORM = "CF-Connecting-IP";
        };
        credentials = {
          ENCRYPTION_KEY = config.sops.secrets."pocketid_encryption_key".path;
          MAXMIND_LICENSE_KEY = config.sops.secrets."pocketid_maxmind_key".path;
        };
      };

      systemd.services.pocket-id.after = lib.mkForce [ ];
    };
  };
}
