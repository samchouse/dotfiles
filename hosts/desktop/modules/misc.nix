{
  pkgs,
  config,
  lib,
  ...
}:
let
  update-symlinks = pkgs.writeShellScriptBin "update-symlinks" ''
    IS_ATTACH="$1"
    CLIENT_ID="$2"
    SESSION_NAME="$3"

    BASE_DIR="/tmp/tmux/''${SESSION_NAME}"
    BASE_PATH="''${BASE_DIR}/$(basename "''${CLIENT_ID}")"
    AUTH_SOCKET="''${BASE_PATH}-auth_sock"

    mkdir -p "$BASE_DIR"

    if [ "$IS_ATTACH" = "true" ]; then
      ln -sf "$(tmux show-environment SSH_AUTH_SOCK | sed 's/SSH_AUTH_SOCK=//')" "$AUTH_SOCKET"
      [ "$(tmux show-environment SSH_CONNECTION | sed 's/SSH_CONNECTION//' | sed 's/=//')" != "-" ] && touch "''${BASE_PATH}-ssh_tty"
    fi
    ln -sf "$AUTH_SOCKET" "''${BASE_DIR}/auth_sock"
  '';
in
{
  environment = {
    etc = {
      "1password/custom_allowed_browsers" = {
        text = ''
          zen
        '';
        mode = "0755";
      };
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
        set -g allow-passthrough on

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

        set-hook -g session-created 'run-shell "rm -r /tmp/tmux/#{session_name}"'
        set-hook -g client-active 'run-shell "${update-symlinks}/bin/update-symlinks false #{hook_client} #{session_name}"'
        set-hook -g client-attached 'run-shell "${update-symlinks}/bin/update-symlinks true #{hook_client} #{session_name}"'
        set-hook -g client-focus-in 'run-shell "${update-symlinks}/bin/update-symlinks false #{hook_client} #{session_name}"'
        set-hook -g client-session-changed 'run-shell "${update-symlinks}/bin/update-symlinks true #{hook_client} #{session_name}"'
      '';
    };
  };

  services = {
    hardware.openrgb.enable = true;

    nfs.server = {
      enable = true;
      exports = ''
        /home/sam 100.123.34.40(rw,sync,no_subtree_check,insecure,all_squash,anonuid=1000,anongid=100) 100.120.233.96(rw,sync,no_subtree_check,insecure,all_squash,anonuid=1000,anongid=100)
      '';
    };

    udev = {
      packages = [
        (pkgs.writeTextFile {
          name = "xbox-one-elite-2-udev-rules";
          text = ''KERNEL=="hidraw*", TAG+="uaccess"'';
          destination = "/etc/udev/rules.d/60-xbox-elite-2-hid.rules";
        })
      ];
    };

    beszel = {
      hub = {
        enable = true;
        host = "0.0.0.0";
        port = 7463;
      };
      agent = {
        enable = true;
        environment = {
          HUB_URL = "http://localhost:7463";
          DOCKER_HOST = "http://localhost:2375";
          EXTRA_FILESYSTEMS = "/mnt/secondary__Secondary";
          TOKEN = "885fd152-b855-4924-ae54-bac24f36878a";
          KEY = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHpWIT7z6MkRkDOeFLMC9JlBzYbXxM7q+aDOnQiCKdwP";
        };
      };
    };
  };

  systemd.services = {
    openrgb = {
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

    beszel-hub = {
      serviceConfig = {
        ExecStartPre = lib.mkForce [
          "${config.services.beszel.hub.package}/bin/beszel-hub migrate up"
          "${config.services.beszel.hub.package}/bin/beszel-hub migrate history-sync"
        ];
      };
    };
    beszel-agent = {
      path = [ config.hardware.nvidia.package ];
      serviceConfig = {
        DeviceAllow = [
          "/dev/nvidiactl rw"
          "/dev/nvidia0 rw"
        ];
      };
    };
  };

  virtualisation.oci-containers.containers = {
    podman-socket-proxy = {
      image = "tecnativa/docker-socket-proxy:v0.4.2";
      volumes = [ "/run/podman/podman.sock:/var/run/docker.sock:ro" ];
      ports = [ "2375:2375" ];
      environment.CONTAINERS = "1";
    };

    cloudflared = {
      image = "cloudflare/cloudflared:2026.5.2";
      autoStart = false;
      cmd = [
        "tunnel"
        "--no-autoupdate"
        "run"
      ];
    };
  };
}
