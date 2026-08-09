{
  systems = [
    "x86_64-linux"
    "aarch64-darwin"
  ];

  perSystem =
    {
      pkgs,
      ...
    }:
    {
      formatter = pkgs.treefmt;
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          git
          nil
          nixd
          biome
          shfmt
          nixfmt
          stylua
          treefmt
          shellcheck
          typescript
          nodejs_latest
        ];
      };
    };
}
