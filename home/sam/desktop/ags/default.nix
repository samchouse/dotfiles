{astal, pkgs, ...}:
{
  programs.ags = {
    enable = true;

    configDir = ./.;

    extraPackages = with astal.packages.${pkgs.system}; [
      hyprland
      tray
    ];
  };
}