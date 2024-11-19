# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  age-plugin-op,
  caddy-nixos,
  ...
}@attrs:
let
  flake = "/home/sam/Documents/projects/personal/dotfiles";

  no-kb = pkgs.writeScriptBin "no-kb" ''
    #!/bin/sh

    mv /var/lib/OpenRGB/OpenRGB.json /var/lib/OpenRGB/OpenRGB.json.bak
    ${pkgs.jq}/bin/jq '.Detectors.detectors."Genesis Thor 300" = false | .' /var/lib/OpenRGB/OpenRGB.json.bak > /var/lib/OpenRGB/OpenRGB.json
  '';

  usb-power = pkgs.writeScriptBin "usb-power" ''
    #!/bin/sh

    VENDOR_ID=258a
    PRODUCT_ID=0090
    PIPE="/tmp/usb-power"

    find_usb_device() {
      grep -rl "$VENDOR_ID" /sys/bus/usb/devices/*/idVendor | while read vendor_file; do
        product_file="''${vendor_file%/idVendor}/idProduct"
        if [ -f "$product_file" ] && grep -q "$PRODUCT_ID" "$product_file"; then
          echo "''${vendor_file%/idVendor}"
        fi
      done
    }

    handle() {
      case "$1" in
      on)
        echo on >"$(find_usb_device)/power/control"
        ;;
      off)
        echo auto >"$(find_usb_device)/power/control"
        ;;
      esac
    }

    mkfifo "$PIPE"
    chown sam "$PIPE"
    while read -r line <"$PIPE"; do handle "$line"; done
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

  tlsConf = ''
    tls {
      dns cloudflare {env.CF_API_TOKEN}
    }
  '';
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../secrets
  ];

  programs.nix-ld.enable = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.sessionVariables.FLAKE = flake;

  nix.settings = {
    substituters = [
      "https://devenv.cachix.org"
      "https://nix-community.cachix.org"
      "https://cuda-maintainers.cachix.org"
    ];
    trusted-public-keys = [
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
  };

  services.caddy = {
    enable = true;
    package = caddy-nixos.packages.x86_64-linux.caddy;
    email = "sam@chouse.dev";
    virtualHosts = {
      "ai.xenfo.dev" = {
        extraConfig = ''
          ${tlsConf}
          reverse_proxy :8080
        '';
      };
      "home.xenfo.dev" = {
        extraConfig = ''
          ${tlsConf}
          reverse_proxy :8090
        '';
      };
      "ha.xenfo.dev" = {
        extraConfig = ''
          ${tlsConf}
          reverse_proxy :8123 {
            header_up X-Forwarded-For {header.CF-Connecting-IP}
          }
        '';
      };
    };
  };

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;
  boot.kernel.sysctl."net.core.rmem_max" = 7500000;
  boot.kernel.sysctl."net.core.wmem_max" = 7500000;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  services.printing.enable = true;

  services.glance = {
    enable = true;
    package = (
      pkgs.glance.overrideAttrs (oldAttrs: rec {
        version = "latest";
        src = (
          pkgs.fetchFromGitHub {
            owner = "glanceapp";
            repo = "glance";
            rev = "bacb607d902cd125c1e97d56d4b51ad56474cc54";
            hash = "sha256-LzrnbjljbJ8eCFsZwMp5ylx88IPSx5l3Vsy+2LeIFts=";
          }
        );

        vendorHash = "sha256-i26RD3dIN0pEnfcLAyra2prLhvd/w1Qf1A44rt7L6sc=";
      })
    );

    settings = {
      server = {
        host = "0.0.0.0";
        port = 8090;
      };
      pages = [
        {
          name = "Home";
          columns = [
            {
              size = "small";
              widgets = [
                {
                  type = "calendar";
                }
                {
                  type = "group";
                  widgets = [
                    {
                      title = "ace";
                      type = "repository";
                      repository = "samchouse/ace";
                      token = "\${GLANCE_GH_TOKEN}";
                    }
                    {
                      title = "adrastos";
                      type = "repository";
                      repository = "samchouse/adrastos";
                      token = "\${GLANCE_GH_TOKEN}";
                    }
                  ];
                }
                {
                  type = "markets";
                  markets = [
                    {
                      symbol = "SPY";
                      name = "S&P 500";
                    }
                    {
                      symbol = "NVDA";
                      name = "NVIDIA";
                    }
                    {
                      symbol = "AAPL";
                      name = "Apple";
                    }
                    {
                      symbol = "MSFT";
                      name = "Microsoft";
                    }
                    {
                      symbol = "GOOGL";
                      name = "Google";
                    }
                  ];
                }
              ];
            }
            {
              size = "full";
              widgets = [
                {
                  type = "search";
                  search-engine = "google";
                  new-tab = true;
                }
                {
                  type = "hacker-news";
                }
                {
                  type = "reddit";
                  subreddit = "unixporn";
                }
              ];
            }
            {
              size = "small";
              widgets = [
                {
                  type = "weather";
                  location = "Montreal, Canada";
                }
                {
                  type = "monitor";
                  cache = "1m";
                  title = "Services";
                  sites = [
                    {
                      title = "Open WebUI";
                      url = "https://ai.xenfo.dev";
                      icon = "si:openai";
                    }
                  ];
                }
                {
                  type = "bookmarks";
                  groups = [
                    {
                      title = "General";
                      links = [
                        {
                          title = "Home Assistant";
                          url = "https://ha.xenfo.dev";
                        }
                      ];
                    }
                    {
                      title = "AI";
                      links = [
                        {
                          title = "OpenAI";
                          url = "https://platform.openai.com/usage";
                        }
                        {
                          title = "Anthropic";
                          url = "https://console.anthropic.com/settings/usage";
                        }
                      ];
                    }
                  ];
                }
              ];
            }
          ];
        }
      ];
    };
  };

  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.age.keyFile = "/home/sam/.config/sops/age/keys.txt";
  sops.environment = {
    PATH = "/run/wrappers/bin:/run/current-system/sw/bin";
  };

  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluez-experimental;
    powerOnBoot = true;
  };

  hardware.nvidia-container-toolkit.enable = true;
  services.open-webui = {
    enable = true;

    host = "0.0.0.0";
    environmentFile = config.sops.templates."open-webui.env".path;
  };
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      ollama = {
        image = "ollama/ollama:0.4.2";
        ports = [ "11434:11434" ];
        autoStart = true;
        volumes = [ "ollama:/root/.ollama" ];
        extraOptions = [ "--device=nvidia.com/gpu=all" ];
      };
      open-webui-pipelines = {
        image = "ghcr.io/open-webui/pipelines:git-c98ca76";
        ports = [ "9099:9099" ];
        autoStart = true;
        volumes = [ "pipelines:/app/pipelines" ];
        extraOptions = [ "--add-host=host.docker.internal:host-gateway" ];
      };

      homeassistant = {
        volumes = [
          "home-assistant:/config"
          "${flake}/hosts/desktop/ha-config.yaml:/config/configuration.yaml:rw"
          "/run/dbus:/run/dbus:ro"
        ];
        environment.TZ = "America/Toronto";
        image = "ghcr.io/home-assistant/home-assistant:2024.11.2";
        extraOptions = [ "--network=host" ];
      };
    };
  };
  services.searx = {
    enable = true;
    package = pkgs.searxng;
    redisCreateLocally = true;
    settings = {
      use_default_settings = true;

      server = {
        secret_key = "super-secret-key";
        limiter = false;
        image_proxy = true;
        port = 8888;
        bind_address = "0.0.0.0";
      };

      ui = {
        static_use_hash = true;
      };

      search = {
        safe_search = 0;
        autocomplete = "";
        default_lang = "";
        formats = [
          "html"
          "json"
        ];
      };
    };
    limiterSettings.botdetection.ip_limit.link_token = true;
  };
  services.tika = {
    enable = true;
    enableOcr = true;
  };
  services.cloudflared = {
    enable = true;
    user = "sam";
    tunnels = {
      "f9331601-f962-4b2a-9bbf-0d140f17afbe" = {
        default = "http_status:404";
        credentialsFile = "/home/sam/.cloudflared/f9331601-f962-4b2a-9bbf-0d140f17afbe.json";
        ingress = {
          "ai.xenfo.dev" = {
            service = "https://localhost";
            originRequest = {
              originServerName = "ai.xenfo.dev";
              httpHostHeader = "ai.xenfo.dev";
            };
          };
          "home.xenfo.dev" = {
            service = "https://localhost";
            originRequest = {
              originServerName = "home.xenfo.dev";
              httpHostHeader = "home.xenfo.dev";
            };
          };
          "ha.xenfo.dev" = {
            service = "https://localhost";
            originRequest = {
              originServerName = "ha.xenfo.dev";
              httpHostHeader = "ha.xenfo.dev";
            };
          };
        };
      };
    };
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet -t --time-format '%a, %B %-d, %Y - %-I:%M %p' -r --user-menu --asterisks --power-shutdown 'systemctl poweroff' --power-reboot 'systemctl reboot'";
        # command = "${pkgs.greetd.tuigreet}/bin/tuigreet -t --time-format '%a, %B %-d, %Y - %-I:%M %p' -r --user-menu --asterisks --power-shutdown 'systemctl poweroff' --power-reboot 'systemctl reboot' --cmd '${pkgs.uwsm}/bin/uwsm start hyprland-uwsm.desktop'";
      };
    };
  };
  # programs.uwsm = {
  #   enable = true;
  #   waylandCompositors.hyprland = {
  #     binPath = "${pkgs.hyprland}/bin/Hyprland";
  #     comment = "Hyprland session managed by uwsm";
  #     prettyName = "Hyprland";
  #   };
  # };

  programs.nh = {
    inherit flake;

    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config = {
      common.default = [ "gtk" ];
      hyprland.default = [
        "gtk"
        "hyprland"
      ];
    };

    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  services.gnome.gnome-keyring.enable = true;

  services.fstrim.enable = true;
  services.fwupd.enable = true;
  boot.initrd.luks.devices."luks-68f12c7e-fc53-49de-9b3d-91ab69f6c2a4" = {
    allowDiscards = true;
    bypassWorkqueues = true;
  };

  programs.hyprland = {
    enable = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.open = false;
  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = [ pkgs.nvidia-vaapi-driver ];
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;

  boot.kernelParams = [
    "quiet"
    "loglevel=3"
    "nvidia_drm.fbdev=1"
    "nvidia_uvm"
  ];

  boot.initrd.systemd.enable = true;
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    gfxmodeEfi = "2560x1440x32,auto";
    gfxmodeBios = "2560x1440x32,auto";
    gfxpayloadEfi = "keep";
    gfxpayloadBios = "keep";
    efiSupport = true;
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.tailscale = {
    enable = true;
    extraSetFlags = [
      "--advertise-exit-node"
      "--ssh"
      "--advertise-routes=10.0.0.0/24"
      "--accept-routes"
    ];
    useRoutingFeatures = "both";
  };
  services.networkd-dispatcher = {
    enable = true;

    rules."50-tailscale" = {
      onState = [ "routable" ];
      script = ''
        #!/bin/sh
        NETDEV=$(ip -o route get 8.8.8.8 | cut -f 5 -d " ")
        sudo ethtool -K $NETDEV rx-udp-gro-forwarding on rx-gro-list off
      '';
    };
  };

  security.polkit.enable = true;
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "sam" ];
  };

  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  services.hardware.openrgb.enable = true;
  systemd.services.no-kb = {
    description = "no-kb";
    serviceConfig = {
      ExecStart = "${no-kb}/bin/no-kb";
      Type = "oneshot";
      After = "openrgb.service";
    };
    wantedBy = [ "multi-user.target" ];
  };

  environment.etc."logid.cfg".source = ./logid.cfg;
  systemd.services.logid = {
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

  services.udev.packages = [ pkgs.swayosd ];
  systemd.services.swayosd-libinput-backend = {
    enable = true;

    wantedBy = [ "graphical-session.target" ];

    unitConfig = {
      Description = "SwayOSD LibInput backend for listening to certain keys like CapsLock, ScrollLock, VolumeUp, etc...";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      Documentation = "https://github.com/ErikReider/SwayOSD";
    };

    serviceConfig = {
      Type = "dbus";
      BusName = "org.erikreider.swayosd";
      ExecStart = "${pkgs.swayosd}/bin/swayosd-libinput-backend";
      Restart = "on-failure";
    };
  };

  services.logind = {
    powerKey = "ignore";
    rebootKey = "ignore";
    suspendKey = "ignore";
    hibernateKey = "ignore";

    extraConfig = ''
      PowerKeyIgnoreInhibited=yes
      SuspendKeyIgnoreInhibited=yes
      HibernateKeyIgnoreInhibited=yes
    '';
  };
  systemd.services.usb-power = {
    enable = true;

    wantedBy = [ "graphical.target" ];

    unitConfig = {
      Description = "USB power manager";
    };

    serviceConfig = {
      User = "root";
      Group = "root";
      ExecStart = "${usb-power}/bin/usb-power";
    };
  };

  fonts.packages =
    if attrs ? custom-fonts then
      [
        attrs.custom-fonts.packages.x86_64-linux.default
        pkgs.material-symbols
      ]
    else
      [ pkgs.material-symbols ];

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Bootloader.
  # boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "desktop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sam = {
    isNormalUser = true;
    description = "Samuel Corsi-House";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [ ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    zip
    unzip
    nvidia-vaapi-driver
    polkit_gnome
    socat
    jq
    slack
    logiops
    swayosd
    btop
    ethtool
    cudatoolkit
    age
    ollama
    cloudflared
    (pkgs.sops.overrideAttrs (oldAttrs: rec {
      version = "git";
      src = fetchFromGitHub {
        owner = "samchouse";
        repo = "sops";
        rev = "21878be7fdbc13617ae48f3b63952c10df624d8b";
        hash = "sha256-nAULMxP6IPNyYn4UhhX6X+8nzYwOcPPgLv0RuXOp1WY=";
      };
      vendorHash = "sha256-NS0b25NQEJle///iRHAG3uTC5p6rlGSyHVwEESki3p4=";
    }))
    age-plugin-op.defaultPackage."x86_64-linux"
    usbutils
    # uwsm
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  networking.firewall = {
    # enable the firewall
    enable = true;

    # always allow traffic from your Tailscale network
    trustedInterfaces = [ "tailscale0" ];

    # allow the Tailscale UDP port through the firewall
    allowedUDPPorts = [ config.services.tailscale.port ];

    # allow you to SSH in over the public internet
    # allowedTCPPorts = [ 22 ];

    # printer home-assistant homekit-bridge
    allowedTCPPorts = [
      631
      8123
      21064
      21065
      21066
      21067
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  # Limit the number of generations to keep
  # boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.grub.configurationLimit = 10;

  # Optimize storage
  # You can also manually optimize the store via:
  #    nix-store --optimise
  # Refer to the following link for more details:
  # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
  nix.settings.auto-optimise-store = true;
}
