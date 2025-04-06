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
    sops
    age-plugin-op
  ];
}
