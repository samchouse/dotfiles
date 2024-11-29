{ config, ... }:
{
  boot.kernelParams = [ "nvidia_uvm" ];

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware = {
    graphics.enable = true;

    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.stable;

      open = false;
      modesetting.enable = true;
    };
  };
}
