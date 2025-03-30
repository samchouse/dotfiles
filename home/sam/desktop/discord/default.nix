{
  pkgs,
  ...
}:
let
  # TODO: waiting on https://github.com/NixOS/nixpkgs/pull/290077
  rev = "890de01dec9555110e93fcd2bb45ae2a140f4ec9";
  krisp-patch = pkgs.fetchFromGitHub {
    inherit rev;
    owner = "sersorrel";
    repo = "sys";
    sha256 = "sha256-fRoGre7i6IwB6Uv0btU0FEQsPReT/kSH93eSSk51kpI=";
  };

  patch-krisp = pkgs.writeShellApplication {
    name = "patch-krisp";
    text = ''
      python ${krisp-patch}/hm/discord/krisp-patcher.py "$HOME/.config/discordcanary/${pkgs.discord-canary.version}/modules/discord_krisp/discord_krisp.node"
    '';

    runtimeInputs = [
      (pkgs.python3.withPackages (python-pkgs: [
        python-pkgs.capstone
        python-pkgs.pyelftools
      ]))
    ];
  };
in
{
  home.packages = with pkgs; [
    patch-krisp
    (discord-canary.override {
      withVencord = true;
      vencord = pkgs.vencord.overrideAttrs (_: {
        patches = [ ./plugins/waylandFix.patch ];
      });
    })
  ];
}
