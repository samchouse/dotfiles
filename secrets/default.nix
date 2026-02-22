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
    age = {
      keyFile = "/home/sam/.config/sops/age/keys.txt";
      plugins = with pkgs; [
        age-plugin-op
        _1password-cli
      ];
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
        environment = config.sops.environment // {
          PATH = lib.mkForce (
            "/run/wrappers/bin:"
            + lib.makeBinPath (
              with pkgs;
              [
                bash
                coreutils
                procps
                socat
                age
                age-plugin-op
                sops
              ]
            )
          );
        };
        serviceConfig = {
          Restart = "on-failure";
          ExecStart = [
            "${pkgs.bash}/bin/bash -c 'while ! ${pkgs.procps}/bin/pgrep -x 1password >/dev/null; do sleep 1; done && ${pkgs.procps}/bin/pgrep -x 1password >/dev/null && sleep 5 && ${config.sops.package}/bin/sops-install-secrets ${config.system.build.sops-nix-manifest} && echo installed | socat - UNIX-CONNECT:/run/sops-secrets.sock'"
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
