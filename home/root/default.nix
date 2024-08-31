{ config, pkgs, ... }:

{
  imports = [
    ../ssh.nix
  ];

  home.username = "root";
  home.homeDirectory = "/root";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [];

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
