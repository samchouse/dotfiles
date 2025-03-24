{
  projectRootFile = "flake.nix";
  programs = {
    shfmt.enable = true;
    nixfmt.enable = true;
    shellcheck.enable = true;
  };
  settings.on-unmatched = "debug";
}
