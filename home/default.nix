{ config, pkgs, ... }:

{
  imports = [
    ./zsh.nix
    ./hypr/hyprland.nix
  ];

  # TODO please change the username & home directory to your own
  home.username = "sam";
  home.homeDirectory = "/home/sam";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    kitty
    firefox
    gammastep
    gh
    vscode.fhs
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
