{ den, ... }: {
  den.hosts.aarch64-darwin.mini.users.sam = { };

  den.aspects.mini = {
    includes = [
      den.aspects.nh
      den.aspects.dock
      den.aspects.homebrew
      den.aspects.packages
      den.aspects.desktopPackages
    ];
  };
}
