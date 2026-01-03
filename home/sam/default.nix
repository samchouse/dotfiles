{
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
    jdk25
    prismlauncher
    bibata-cursors
    playerctl
    grim
    niqs.bibata-hyprcursor
    kora-icon-theme
    wayfreeze
    slurp
    wl-clipboard
    yazi
    qview
    devenv
    rainfrog
    cider-2
    thunderbird
    r2modman
    lumafly
    libreoffice
    gtrash
    (pkgs.writeShellScriptBin "upnp" ''
      case $1 in
      open)
        sudo nixos-firewall-tool open "$2" "$3"
        upnpc -a @ "$3" "$3" "$2"
        ;;
      close)
        upnpc -d "$3" "$2"
        sudo iptables -D nixos-fw -p "$2" --dport "$3" -j nixos-fw-accept
        ;;
      *)
        echo "Invalid argument. Use 'open' or 'close'."
        exit 1
        ;;
      esac
    '')
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
