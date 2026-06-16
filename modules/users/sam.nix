{ den, lib, ... }:
{
  den.aspects.sam = { host, ... }: {
    includes = [
      den.batteries.define-user
      den.batteries.primary-user
      den.batteries.host-aspects

      den.aspects.zsh
      den.aspects.ssh
      den.aspects.age
      den.aspects.git
    ];

    user = {
      description = "Samuel Corsi-House";
    }
    // lib.optionalAttrs (host.class == "nixos") {
      extraGroups = [
        "dialout"
        "libvirtd"
      ];
    };
  };
}
