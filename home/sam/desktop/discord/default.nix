{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    (discord-canary.override {
      withVencord = true;
      vencord = pkgs.vencord.overrideAttrs (old: {
        patches = old.patches ++ [ ./plugins/waylandFix.patch ];
      });
    })
  ];
}
