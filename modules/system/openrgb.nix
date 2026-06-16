{lib, ...}:{
  den.aspects.openrgb = {
    nixos = {pkgs, ...}:{
      services.hardware.openrgb.enable = true;
      systemd.services.openrgb = {
        serviceConfig = {
          Type = "oneshot";
          Restart = lib.mkForce "on-failure";
          ExecStart = lib.mkForce (
            lib.escapeShellArgs [
              (lib.getExe pkgs.openrgb)
              "--profile"
              "Black"
            ]
          );
        };
      };
    };
  };
}
