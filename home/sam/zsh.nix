{ pkgs, ... }:
let
  rebuild = pkgs.writeScriptBin "rebuild" ''
    #!/usr/bin/env bash
    set -e

    args=()
    while getopts ":c" opt; do
      case $opt in
        c)
          hash=$(nix build --expr "fetchTarball { url = \"https://code.visualstudio.com/sha/download?build=insider&os=linux-x64\"; sha256 = \"\"; }" |& grep got: | sed -E 's/\s+got:\s+//')
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

      plugins = [ "git" "direnv" ];
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

      [ -z "$SSH_TTY" ] && [ -n "$SSH_CONNECTION" ] && export SSH_TTY="/dev/pts/9999"
      [ -n "$SSH_CONNECTION" ] && [[ "$TERM_PROGRAM" == "vscode" ]] && export SSH_AUTH_SOCK=$(ls -t /tmp/auth-agent**/* | head -1)
      export SSH_AUTH_SOCK=''${SSH_AUTH_SOCK:-/home/sam/.1password/agent.sock}

      export PATH="$PATH:${pkgs.qt6Packages.qtstyleplugin-kvantum}/bin"
    '';
  };

  programs.starship = {
    enable = true;
  };
}
