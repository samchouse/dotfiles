{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./desktop
    ./zsh.nix
    ./git.nix
    ./projects.nix
    ../ssh.nix
  ];

  xdg.configFile."sops/age/keys.txt".source = ../age-identity.txt;

  home.username = "sam";
  home.homeDirectory = "/home/sam";

  home.packages = with pkgs; [
    firefox
    zen-browser
    gammastep
    gh
    prismlauncher
    bibata-cursors
    vesktop
    playerctl
    kdePackages.xwaylandvideobridge
    grim
    niqs.bibata-hyprcursor
    kora-icon-theme
    wayfreeze
    slurp
    wl-clipboard
    yazi
    qview
    clipse
    devenv
    direnv
    rainfrog
    cider-2
    slack
    thunderbird
    google-chrome
    r2modman
    lumafly
    libreoffice
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
}
