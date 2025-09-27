{ pkgs, config, ... }:
let
  no-kb = pkgs.writeScriptBin "no-kb" ''
    #!/bin/sh

    mv /var/lib/OpenRGB/OpenRGB.json /var/lib/OpenRGB/OpenRGB.json.bak
    ${pkgs.jq}/bin/jq '.Detectors.detectors."Genesis Thor 300" = false | .' /var/lib/OpenRGB/OpenRGB.json.bak > /var/lib/OpenRGB/OpenRGB.json
  '';

  logiops = pkgs.logiops.overrideAttrs (oldAttrs: {
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
  environment.etc = {
    "1password/custom_allowed_browsers" = {
      text = ''
        zen
      '';
      mode = "0755";
    };
  };

  programs = {
    zoxide.enable = true;
    steam.enable = true;

    _1password.enable = true;
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "sam" ];
    };

    tmux = {
      enable = true;
      shortcut = "s";
      keyMode = "vi";
      customPaneNavigationAndResize = true;
      plugins = with pkgs.tmuxPlugins; [
        catppuccin
        cpu
      ];
      terminal = "tmux-256color";
      extraConfig = ''
        set-option -g status-position top
        set -g mouse on

        set -g @catppuccin_flavor "mocha"
        set -g @catppuccin_window_status_style "custom"

        set -g @catppuccin_window_left_separator "#[bg=default,fg=#{@thm_surface_0}]#[bg=#{@thm_surface_0},fg=#{@thm_fg}]"
        set -g @catppuccin_window_right_separator "#[bg=default,fg=#{@thm_surface_0}]"
        set -g @catppuccin_window_current_left_separator "#[bg=default,fg=#{@thm_mauve}]#[bg=#{@thm_mauve},fg=#{@thm_bg}]"
        set -g @catppuccin_window_current_middle_separator "#[fg=#{@thm_mauve}]█"
        set -g @catppuccin_window_current_right_separator "#[bg=default,fg=#{@thm_surface_1}]"

        set -g @catppuccin_status_background "none"
        run-shell ${pkgs.tmuxPlugins.catppuccin}/share/tmux-plugins/catppuccin/catppuccin.tmux

        set -g status-right-length 100
        set -g status-left-length 100
        set -g status-left ""
        set -g status-right "#{E:@catppuccin_status_application}"
        set -ag status-right "#{E:@catppuccin_status_directory}"
        set -agF status-right "#{E:@catppuccin_status_cpu}"
        set -ag status-right "#{E:@catppuccin_status_session}"
        run-shell ${pkgs.tmuxPlugins.cpu}/share/tmux-plugins/cpu/cpu.tmux
      '';
    };
  };

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

  services = {
    hardware.openrgb.enable = true;
    udev.packages = [
      (pkgs.writeTextFile {
        name = "xbox-one-elite-2-udev-rules";
        text = ''KERNEL=="hidraw*", TAG+="uaccess"'';
        destination = "/etc/udev/rules.d/60-xbox-elite-2-hid.rules";
      })
    ];

    nfs.server = {
      enable = true;
      exports = ''
        /home/sam 100.123.34.40(rw,sync,no_subtree_check,insecure,all_squash,anonuid=1000,anongid=100)
      '';
    };
  };

  virtualisation.oci-containers = {
    containers = {
      beszel = {
        image = "ghcr.io/henrygd/beszel/beszel:0.12.12";
        ports = [ "7463:8090" ];
        volumes = [ "beszel:/beszel_data" ];
        extraOptions = [ "--add-host=host.docker.internal:host-gateway" ];
      };
    };
  };

  # TODO: remove when https://github.com/NixOS/nixpkgs/pull/380731 is merged
  systemd.services.beszel-agent = {
    description = "Beszel Agent";

    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];

    path = [ config.boot.kernelPackages.nvidiaPackages.stable ];
    environment = {
      KEY = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHpWIT7z6MkRkDOeFLMC9JlBzYbXxM7q+aDOnQiCKdwP";
    };

    serviceConfig = {
      ExecStart = ''
        ${
          pkgs.beszel.overrideAttrs (oldAttrs: rec {
            version = "0.12.6";
            src = (
              pkgs.fetchFromGitHub {
                owner = "henrygd";
                repo = "beszel";
                rev = "v${version}";
                hash = "sha256-OZD8nB2oKaMFvUbDfYNhtq18riaQSdTZASDUJ29TYu8=";
              }
            );

            vendorHash = "sha256-8Sr7MYQnIfNx9hvfjCTYKQOUZIBxpGPbsR75jEB0mbk=";
          })
        }/bin/beszel-agent
      '';

      KeyringMode = "private";
      LockPersonality = "yes";
      NoNewPrivileges = "yes";
      PrivateTmp = "yes";
      ProtectClock = "yes";
      ProtectHome = "read-only";
      ProtectHostname = "yes";
      ProtectKernelLogs = "yes";
      ProtectSystem = "strict";
      RemoveIPC = "yes";
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      DeviceAllow = [
        "/dev/nvidiactl rw"
        "/dev/nvidia0 rw"
      ];
    };
  };
}
