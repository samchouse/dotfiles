{
  inputs,
  ...
}:
{
  config.flake.lib.mkNixpkgs =
    let
      config = {
        cudaSupport = true;
        allowUnfree = true;
      };

      pkgs-config = system: { inherit system config; };
    in
    {
      inherit config;
      overlays = [
        (
          final: prev:
          let
            system = prev.stdenv.hostPlatform.system;
          in
          {
            astal = inputs.astal.packages.${system};
            niqs = inputs.niqspkgs.packages.${system};
            vicinae = inputs.vicinae.packages.${system}.default;
            zen-browser = inputs.zen-browser.packages.${system}.default;
            age-plugin-op = inputs.age-plugin-op.defaultPackage.${system};
            sunshine = inputs.nixpkgs-sunshine.legacyPackages.${system}.sunshine;

            hyprland = inputs.hyprland.packages.${system}.hyprland;
            xdg-desktop-portal-hyprland = inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland;

            sweet = prev.callPackage ../pkgs/sweet { };

            small = import inputs.nixpkgs-small pkgs-config prev;
            staging = import inputs.nixpkgs-staging pkgs-config prev;
          }
        )
      ];
    };
}
