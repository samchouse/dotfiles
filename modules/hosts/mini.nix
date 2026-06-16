{ den, ... }: {
  den.hosts.aarch64-darwin.mini.users.sam = { };

  den.aspects.mini = {
    includes = [
      den.aspects.dock
      den.aspects.desktopPackages
    ];
  };
}
