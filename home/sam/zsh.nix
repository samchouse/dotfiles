{ pkgs, ... }:
let 
  rebuild = pkgs.writeScriptBin "rebuild" ''
  #!/usr/bin/env bash
  set -e

  args=()
  while getopts ":c" opt; do
    case $opt in
      c)
        hash=$(nix-prefetch-url --unpack "https://code.visualstudio.com/sha/download?build=insider&os=linux-x64" --name vscode-insiders-latest)
        sed -i -r "s/(sha256 = \").+(\";)/\1$hash\2/" $FLAKE/home/sam/desktop/vscode.nix
        ;;
      \?)
        args+=("-$OPTARG")
        ;;
    esac
  done

  shift "$((OPTIND - 1))"
  args+=("$@")

  nh os switch "''${args[@]}"
  '';
in
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
      rb = "${rebuild}/bin/rebuild";
    };

    oh-my-zsh = {
      enable = true;

      plugins = [ "git" ];
    };

    initExtra = ''
      function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
          builtin cd -- "$cwd"
        fi
        rm -f -- "$tmp"
      }
    '';
  };

  programs.starship = {
    enable = true;
  };
}
