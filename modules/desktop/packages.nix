{
  den.aspects.desktopPackages = {
    nixos = { pkgs, ... }: {
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
        zen-browser
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
        enable = true;
        brews = [ "mole" ];
        casks = [
          "zen"
          "loop"
          "codex"
          "discord"
          "t3-code"
          "betterdisplay"
        ];
      };
    };
  };
}
