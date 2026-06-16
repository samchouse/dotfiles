{ lib, ... }: {
  den.aspects.podman = {
    nixos = { pkgs, ... }: {
      virtualisation = {
        oci-containers.backend = "podman";
        libvirtd = {
          enable = true;
          nss.enable = true;
          qemu.swtpm.enable = true;
        };
      };

      environment.etc."containers/registries.conf".source =
        let
          tomlFormat = pkgs.formats.toml { };
        in
        lib.mkForce (
          tomlFormat.generate "registries.conf" {
            unqualified-search-registries = [
              "docker.io"
              "quay.io"
            ];

            registry = [
              { location = "docker.io"; }
              { location = "quay.io"; }
            ];
          }
        );

      networking.firewall.trustedInterfaces = [ "podman0" ];
    };
  };
}
