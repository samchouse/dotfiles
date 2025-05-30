let
  constants = import ../constants.nix;
  inherit (constants) flake;
in
{
  virtualisation.oci-containers = {
    containers = {
      homeassistant = {
        image = "ghcr.io/home-assistant/home-assistant:2025.5.3";
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

  services = {
    mosquitto = {
      enable = true;
    };
    zigbee2mqtt = {
      enable = true;

      settings = {
        homeassistant = true;
        mqtt = {
          server = "mqtt://localhost:1883";
        };
        serial = {
          port = "/dev/serial/by-id/usb-SMLIGHT_SMLIGHT_SLZB-06M_eae31ba01c72ef1197593b848fcc3fa0-if00-port0";
          baudrate = 115200;
          adapter = "ember";
        };
        frontend = {
          host = "0.0.0.0";
          port = 8453;
        };
        advanced = {
          homeassistant_legacy_entity_attributes = false;
          homeassistant_legacy_triggers = false;
          legacy_api = false;
          legacy_availability_payload = false;
        };
        device_options = {
          legacy = false;
        };
      };
    };
  };

  systemd.services.zigbee2mqtt.serviceConfig = {
    Environment = [ "Z2M_WATCHDOG=default" ];
    SystemCallFilter = [ "@chown" ];
  };

  networking.firewall = {
    allowedTCPPorts = [ 8123 ];
    allowedTCPPortRanges = [
      {
        from = 21064;
        to = 21067;
      }
    ];
  };
}
