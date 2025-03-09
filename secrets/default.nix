{
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [
    ./modules
  ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "/home/sam/.config/sops/age/keys.txt";
    environment = {
      PATH = "/run/wrappers/bin:/run/current-system/sw/bin";
    };
  };

  systemd = {
    sockets.sops-secrets = {
      wantedBy = [ "sockets.target" ];
      listenStreams = [ "/run/sops-secrets.sock" ];
    };

    services = {
      sops-secrets = {
        serviceConfig = {
          ExecStart = [ "/bin/sh -c ':'" ];
          RemainAfterExit = "yes";
        };
      };
      sops-install-secrets = {
        wantedBy = [ "graphical.target" ];
        environment = lib.mkForce config.sops.environment;
        serviceConfig = {
          ExecStart = [
            "${pkgs.bash}/bin/bash -c 'while ! ${pkgs.procps}/bin/pgrep -x 1password >/dev/null; do sleep 1; done && ${pkgs.procps}/bin/pgrep -x 1password >/dev/null && sleep 5 && ${config.sops.package}/bin/sops-install-secrets ${config.sops.manifest} && echo installed | /usr/bin/env socat - UNIX-CONNECT:/run/sops-secrets.sock'"
          ];
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    age
    age-plugin-op
    (
      (sops.override {
        buildGo122Module = buildGoModule;
      }).overrideAttrs
      (oldAttrs: rec {
        version = "latest";
        src = fetchFromGitHub {
          owner = "getsops";
          repo = "sops";
          rev = "024b94f67afa967ed758ae17433d7da600e87599";
          hash = "sha256-rNO9+gIxxH4sYoemFbOD8HaKWL48VnbdCOKvQ0FoTgI=";
        };
        vendorHash = "sha256-wdsPuUpYHEBkZ80d7L3iXIbBsnK4to0zDUOOlvOtde4=";

        postPatch = ''
          substituteInPlace go.mod \
            --replace-fail "go 1.22" "go 1.23.0"
        '';
      })
    )
  ];
}
