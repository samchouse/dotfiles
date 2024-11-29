{ flake, ... }:
let
  constants = import ../constants.nix;
  inherit (constants) flake;
in
{
  virtualisation.oci-containers = {
    containers = {
      homeassistant = {
        image = "ghcr.io/home-assistant/home-assistant:2024.11.3";
        volumes = [
          "home-assistant:/config"
          "${flake}/hosts/desktop/config/ha-config.yaml:/config/configuration.yaml:rw"
          "/run/dbus:/run/dbus:ro"
        ];
        environment.TZ = "America/Toronto";
        extraOptions = [ "--network=host" ];
      };
    };
  };

  networking.firewall = {
    enable = true;

    allowedTCPPorts = [ 8123 ];
    allowedTCPPortRanges = [
      {
        from = 21064;
        to = 21067;
      }
    ];
  };
}
