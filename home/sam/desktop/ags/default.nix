{ pkgs, ... }:
{
  programs.ags = {
    enable = true;

    configDir = ./.;

    extraPackages = with pkgs.astal; [
      hyprland
      tray
    ];
  };
}
