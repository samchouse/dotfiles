{ den, ... }: {
  den.hosts.aarch64-darwin.laptop.users.sam = { };

  den.aspects.laptop = {
    includes = [
      den.aspects.dock
      den.aspects.desktopPackages
    ];
  };
}
