{ pkgs, ... }:
{
  programs.ags = {
    enable = true;
    extraPackages = with pkgs.astal; [
      tray
      mpris
      notifd
      network
      hyprland
      bluetooth
      wireplumber
    ];

    configDir = ./.;
  };
}
