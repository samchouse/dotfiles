{ pkgs, ... }:
{
  programs.ags = {
    enable = true;
    extraPackages = with pkgs.astal; [
      tray
      hyprland
    ];

    configDir = ./.;
  };
}
