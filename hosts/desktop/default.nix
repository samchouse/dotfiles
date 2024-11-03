# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  age-plugin-op,
  ...
}@attrs:
let
  flake = "/home/sam/Documents/projects/dotfiles";

  no-kb = pkgs.writeScriptBin "no-kb" ''
    #!/bin/sh

    mv /var/lib/OpenRGB/OpenRGB.json /var/lib/OpenRGB/OpenRGB.json.bak
    ${pkgs.jq}/bin/jq '.Detectors.detectors."Genesis Thor 300" = false | .' /var/lib/OpenRGB/OpenRGB.json.bak > /var/lib/OpenRGB/OpenRGB.json
  '';

  usb-lock = pkgs.writeScriptBin "usb-lock" ''
    #!/bin/sh

    PIPE="/tmp/usb-lock"

    mkfifo "$PIPE"
    chown sam "$PIPE"
    while read -r line <"$PIPE"; do echo -n "0000:00:14.0" > /sys/bus/pci/drivers/xhci_hcd/unbind; done
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
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../secrets
  ];

  programs.nix-ld.enable = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.sessionVariables.FLAKE = flake;

  nix.settings = {
    substituters = [ "https://devenv.cachix.org" "https://nix-community.cachix.org" "https://cuda-maintainers.cachix.org" ];
    trusted-public-keys = [ "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=" "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E=" ];
  };

  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.age.keyFile = "/home/sam/.config/sops/age/keys.txt";
  sops.environment = {
    PATH = "/run/wrappers/bin:/run/current-system/sw/bin";
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
        image = "ollama/ollama:0.4.0-rc6";
        ports = [ "11434:11434" ];
        autoStart = true;
        volumes = [ "ollama:/root/.ollama" ];
        extraOptions = [ "--device=nvidia.com/gpu=all" ];
      };
      open-webui-pipelines = {
        image = "ghcr.io/open-webui/pipelines:main";
        ports = [ "9099:9099" ];
        autoStart = true;
        volumes = [ "pipelines:/app/pipelines" ];
        extraOptions = [ "--add-host=host.docker.internal:host-gateway" ];
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
      "be8d8946-c30c-410d-81e1-ab345276f4e3" = {
        default = "http_status:404";
        credentialsFile = "/home/sam/.cloudflared/be8d8946-c30c-410d-81e1-ab345276f4e3.json";
        ingress = {
          "ai.xenfo.dev" = {
            service = "http://localhost:8080";
          };
        };
      };
    };
  };

  # services.printing = {
  #   enable = true;
  #   drivers = [ 
  #     pkgs.hplip # — Drivers for HP printers.
  #     pkgs.hplipWithPlugin # — Drivers for HP printers, with the proprietary plugin. Use NIXPKGS_ALLOW_UNFREE=1 nix-shell -p hplipWithPlugin --run 'sudo -E hp-setup' to add the printer, regular CUPS UI doesn't seem to work.
  #   ];
  # };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet -t --time-format '%a, %B %-d, %Y - %-I:%M %p' -r --user-menu --asterisks --power-shutdown 'systemctl poweroff' --power-reboot 'systemctl reboot'";
      };
    };
  };

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
    ];
    useRoutingFeatures = "both";
  };
  services.networkd-dispatcher = {
    enable = true;

    rules."50-tailscale" = {
      onState = ["routable"];
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
  systemd.services.usb-lock = {
    enable = true;

    wantedBy = [ "graphical.target" ];

    unitConfig = {
      Description = "USB lock manager";
    };

    serviceConfig = {
      User = "root";
      Group = "root";
      ExecStart = "${usb-lock}/bin/usb-lock";
    };
  };
  services.acpid = {
    enable = true;

    handlers.power-button = {
      event = "button/power.*";
      action = ''
        handle() {
            echo -n "0000:00:14.0" > /sys/bus/pci/drivers/xhci_hcd/bind
            ${pkgs.su}/bin/su - sam -c "openrgb -p Blue"
            ${pkgs.su}/bin/su - sam -c "HYPRLAND_INSTANCE_SIGNATURE=$(ls -t /run/user/1000/hypr | head -n 1) hyprctl dispatch dpms on"
        }

        vals=($1)
        case "''${vals[1]}" in
            PBTN) handle ;;
            *)    echo "ACPI action undefined: ''${vals[3]}" ;;
        esac
      '';
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
    (pkgs.sops.overrideAttrs
        (oldAttrs: rec {
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
