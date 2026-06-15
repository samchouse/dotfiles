{ den, ... }:
{
  den.aspects.sam = {
    includes = [
      den.batteries.define-user
      den.batteries.primary-user

      den.aspects.zsh
    ];
  };
}
