{ den, ... }: {
  den.hosts.x86_64-linux.desktop.users.sam = { };

  den.aspects.desktop = {
    includes = [
      den.aspects.nh
      den.aspects.hyprland
      den.aspects.packages
      den.aspects.desktopPackages
    ];
  };
}
