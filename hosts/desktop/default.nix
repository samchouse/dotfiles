{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix

    ./modules
    ../../secrets
  ];

  security = {
    rtkit.enable = true;
    polkit.enable = true;
  };

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

  networking = {
    hostName = "desktop";
    networkmanager.enable = true;

    firewall = {
      enable = true;

      trustedInterfaces = [
        "enp5s0"
        "podman0"
      ];
      interfaces.wlp6s0.allowedTCPPorts = [
        8081
      ];

      # https://github.com/miniupnp/miniupnp/tree/master/miniupnpc#readme
      extraCommands = ''
        ${pkgs.ipset}/bin/ipset create upnp hash:ip,port timeout 3
        iptables -A OUTPUT -d 239.255.255.250/32 -p udp -m udp --dport 1900 -j SET --add-set upnp src,src --exist
        iptables -A INPUT -p udp -m set --match-set upnp dst,dst -j ACCEPT
        iptables -A INPUT -d 239.255.255.250/32 -p udp -m udp --dport 1900 -j ACCEPT

        ${pkgs.ipset}/bin/ipset create upnp6 hash:ip,port timeout 3 family inet6
        ip6tables -A OUTPUT -d ff02::c/128 -p udp -m udp --dport 1900 -j SET --add-set upnp6 src,src --exist
        ip6tables -A OUTPUT -d ff05::c/128 -p udp -m udp --dport 1900 -j SET --add-set upnp6 src,src --exist
        ip6tables -A INPUT -p udp -m set --match-set upnp6 dst,dst -j ACCEPT
        ip6tables -A INPUT -d ff02::c/128 -p udp -m udp --dport 1900 -j ACCEPT
        ip6tables -A INPUT -d ff05::c/128 -p udp -m udp --dport 1900 -j ACCEPT
      '';
    };
  };

  programs = {
    zsh.enable = true;
    nix-ld.enable = true;
  };

  services = {
    fwupd.enable = true;
    fstrim.enable = true;
    xserver.xkb = {
      layout = "us";
      variant = "";
    };

    avahi = {
      enable = true;

      nssmdns4 = true;
      openFirewall = true;
    };

    pipewire = {
      enable = true;

      pulse.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
    };
  };

  boot = {
    kernelPackages = pkgs.linuxPackagesFor pkgs.linux_latest;
    kernelModules = [ "hid_microsoft" ];
    kernelParams = [
      "quiet"
      "loglevel=3"
    ];

    initrd = {
      systemd.enable = true;
      luks.devices."luks-68f12c7e-fc53-49de-9b3d-91ab69f6c2a4" = {
        allowDiscards = true;
        bypassWorkqueues = true;
      };
    };

    loader = {
      efi.canTouchEfiVariables = true;

      systemd-boot.enable = false;
      grub = {
        enable = true;

        device = "nodev";
        gfxmodeEfi = "2560x1440x32,auto";
        gfxmodeBios = "2560x1440x32,auto";
        gfxpayloadEfi = "keep";
        gfxpayloadBios = "keep";
        efiSupport = true;

        configurationLimit = 10;
      };
    };

    tmp.useTmpfs = true;
  };

  users = {
    defaultUserShell = pkgs.zsh;
    users.sam = {
      isNormalUser = true;
      description = "Samuel Corsi-House";
      extraGroups = [
        "networkmanager"
        "wheel"
        "dialout"
        "libvirtd"
      ];
    };
  };

  time.timeZone = "America/Toronto";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
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
  };

  nix.settings = {
    trusted-substituters = [ "https://hyprland.cachix.org" ];
    substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos-cuda.org"
      "https://cache.flox.dev"
      "https://devenv.cachix.org"
      "https://vicinae.cachix.org"
      "https://hyprland.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
