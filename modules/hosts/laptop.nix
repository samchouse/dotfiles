{ den, ... }: {
  den.hosts.aarch64-darwin.laptop.users.sam = { };

  den.aspects.laptop = {
    includes = [
      den.aspects.nh
      den.aspects.dock
      den.aspects.homebrew
      den.aspects.packages
      den.aspects.desktopPackages
    ];
  };
}
