{ pkgs, ... }:
let
  no-kb = pkgs.writeScriptBin "no-kb" ''
    #!/bin/sh

    mv /var/lib/OpenRGB/OpenRGB.json /var/lib/OpenRGB/OpenRGB.json.bak
    ${pkgs.jq}/bin/jq '.Detectors.detectors."Genesis Thor 300" = false | .' /var/lib/OpenRGB/OpenRGB.json.bak > /var/lib/OpenRGB/OpenRGB.json
  '';

  logiops = pkgs.logiops.overrideAttrs (oldAttrs: rec {
    version = "git";
    src = (
      pkgs.fetchFromGitHub {
        owner = "samchouse";
        repo = "logiops";
        rev = "b81261c2f675e8213cede299c9c0f9105ac1ac17";
        hash = "sha256-W3HGXtVXr0hmN9aED47yOmwzjjkDjeVrte4069Ry51o=";
        fetchSubmodules = true;
      }
    );
  });
in
{
  programs = {
    steam.enable = true;

    _1password.enable = true;
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "sam" ];
    };
  };

  services.hardware.openrgb.enable = true;
  environment.systemPackages = [ logiops ];
  environment.etc."logid.cfg".source = ../config/logid.cfg;

  systemd.services = {
    no-kb = {
      description = "no-kb";
      serviceConfig = {
        ExecStart = "${no-kb}/bin/no-kb";
        Type = "oneshot";
        After = "openrgb.service";
      };
      wantedBy = [ "multi-user.target" ];
    };

    logid = {
      wantedBy = [ "multi-user.target" ];
      description = "Logitech Configuration Daemon";
      serviceConfig = {
        User = "root";
        Type = "simple";
        ExecStart = "${pkgs.logiops}/bin/logid -c /etc/logid.cfg";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        Restart = "on-failure";
      };
    };
  };
}
