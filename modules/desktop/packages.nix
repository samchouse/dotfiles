{ den, ... }:
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

    darwin = {
      homebrew = {
        brews = [ "mole" ];
        casks = [
          "loop"
          "codex"
          "t3-code"
          "betterdisplay"
        ];
      };
    };
  };
}
