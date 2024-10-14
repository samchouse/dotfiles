{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;

    plugins = [
      {
        name = "fast-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zdharma-continuum";
          repo = "fast-syntax-highlighting";
          rev = "cf318e06a9b7c9f2219d78f41b46fa6e06011fd9";
          sha256 = "sha256-RVX9ZSzjBW3LpFs2W86lKI6vtcvDWP6EPxzeTcRZua4=";
        };
      }
    ];

    shellAliases = {
      c = "code-insiders";
      rb = "nh os switch";
    };

    oh-my-zsh = {
      enable = true;

      plugins = [ "git" ];
    };
  };

  programs.starship = {
    enable = true;
  };
}
