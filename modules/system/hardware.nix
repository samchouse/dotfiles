{
  den.aspects.hardware = {
    nixos = { pkgs, ... }: {
      # NVIDIA
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware = {
        graphics.enable = true;
        nvidia.open = true;
        nvidia-container-toolkit.enable = true;
      };

      # POWER
      services = {
        upower.enable = true;
        logind.settings.Login = {
          HandlePowerKey = "ignore";
          HandleRebootKey = "ignore";
          HandleSuspendKey = "ignore";
          HandleHibernateKey = "ignore";
          PowerKeyIgnoreInhibited = true;
          SuspendKeyIgnoreInhibited = true;
          HibernateKeyIgnoreInhibited = true;
        };
      };

      # GENERAL
      services = {
        fwupd.enable = true;
        fstrim.enable = true;
        xserver.xkb = {
          layout = "us";
          variant = "";
        };
        pipewire = {
          enable = true;

          pulse.enable = true;
          alsa = {
            enable = true;
            support32Bit = true;
          };
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
      };

      boot = {
        kernelPackages = pkgs.linuxPackagesFor pkgs.linux_latest;
        kernelModules = [ "hid_microsoft" ];
        kernelParams = [
          "quiet"
          "loglevel=3"
          "nvidia_uvm"
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
    };
  };
}
