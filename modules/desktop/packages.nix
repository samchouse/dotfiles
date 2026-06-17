{ den, lib, ... }:
{
  den.aspects.desktopPackages = {
    includes = [
      den.aspects.ags
      den.aspects.zen
      den.aspects.fonts
      den.aspects.discord
      den.aspects.terminal
      den.aspects.packages
      den.aspects._1password
    ];

    nixos = { pkgs, ... }: {
      programs.steam.enable = true;

      environment.systemPackages = with pkgs; [
        yazi
        grim
        slurp
        t3code
        lumafly
        gparted
        quickemu
        r2modman
        wayfreeze
        wl-clipboard
        polkit_gnome
        lunar-client
        hyprshutdown
        virt-manager
        prismlauncher
        bibata-cursors
        kora-icon-theme
        niqs.bibata-hyprcursor
      ];
    };

    darwin = { host, ... }: {
      homebrew = {
        brews = [ "mole" ];
        taps = [ "xykong/tap" ];
        masApps = {
          Noir = 1592917505;
          Xcode = 497799835;
          Mapper = 1589391989;
          # Sequel = 1630746993; https://github.com/mas-cli/mas/issues/321
          Dropover = 1355679052;
          "Wipr 2" = 1662217862;
          Notability = 360593530;
          "Refined GitHub" = 1519867270;
          "1Password for Safari" = 1569813296;
        };
        casks = [
          "zed"
          "loop"
          "codex"
          "shottr"
          "alcove"
          "t3-code"
          "firefox"
          "thaw@beta"
          "sf-symbols"
          "google-chrome"
          "betterdisplay"
          "flux-markdown"
          "microsoft-word"
          "keepingyouawake"
          "microsoft-excel"
          "microsoft-powerpoint"
          "homebrew/cask/onedrive"
          "visual-studio-code@insiders"
          (lib.mkIf (host.name == "mini") "logi-options+")
        ];
      };

      nix-homebrew.trust.casks = [ "xykong/tap/flux-markdown" ];
    };
  };
}
