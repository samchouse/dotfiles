{ den, lib, ... }:
{
  den.aspects.zsh = {
    includes = [
      (den.batteries.user-shell "zsh")
    ];

    homeManager =
      { pkgs, ... }:
      let
        rebuild = pkgs.writeShellScriptBin "rebuild" ''
          set -e

          args=()
          while getopts ":d" opt; do
            case $opt in
            d)
              echo -e "\033[1;34m🔍 Checking for Docker image updates...\033[0m"
              parse_semver_like() {
                IFS='.' read -ra parts <<<"$(echo "$1" | sed -E 's/[^0-9.]+//g')"
                printf "%s\n" "''${parts[@]}"
              }

              make_regex() {
                while IFS=- read -ra parts; do
                  middle_index=$(((''${#parts[@]} - 1) / 2))
                  parts[middle_index]=$(echo "''${parts[middle_index]}" | sed -E -e 's/[a-zA-Z]+/\\w\+/g' -e 's/[0-9]+/\\d+/g' -e 's/\./\\./g')

                  if [[ ''${#parts[@]} -eq "" ]]; then
                    echo "''${parts[0]}"
                    return
                  fi

                  regex=$(
                    IFS=-
                    echo "''${parts[*]}"
                  )
                  if ! echo "$regex" | grep -Pq "\.|-"; then
                    regex="[\\w|\\d]+"
                  fi
                  echo "$regex" | awk '{print "^" $0 "$"}'
                done
              }

              ${pkgs.ripgrep}/bin/rg 'image = "' "$NH_FLAKE" --json | jq -cM 'select(.type | contains("match"))' | ${pkgs.ripgrep}/bin/rg '\s+image =' | while IFS= read -r line; do
                echo "$line" | jq -r .data.lines.text | sed -E 's/.*image = "(.*)".*/\1/' | tr -d '\n' | sed 's/$/\n/' | while IFS=: read -r name version; do
                  echo -e "\n\033[1;34m📦 Checking for updates: \033[1;36m$name\033[0m (\033[33m$version\033[0m)"

                  echo -e "\033[90m→ Fetching available versions...\033[0m"
                  all_versions=$(${pkgs.skopeo}/bin/skopeo list-tags "docker://$name" | jq -r .Tags[] | grep -v sha256 | grep -P "$(echo "$version" | make_regex)")
                  version_count=$(echo "$all_versions" | wc -l)
                  echo -e "\033[90m→ Found $version_count potential version(s) to evaluate\033[0m"

                  best_version=""
                  latest_version=""
                  considered_count=0
                  is_semver=true

                  if [[ $(parse_semver_like "$version" | wc -l) -eq 0 ]]; then
                    is_semver=false
                    echo -e "\033[90m→ Detected non-semantic version format (hash or custom version)\033[0m"
                  fi

                  while IFS= read -r candidate_version; do
                    [[ -z "$candidate_version" || "$candidate_version" == "$version" ]] && continue

                    considered_count=$((considered_count + 1))
                    latest_version="$candidate_version"

                    if [[ "$is_semver" == "false" ]]; then
                      continue
                    fi

                    readarray -t candidate_parts < <(parse_semver_like "$candidate_version")
                    readarray -t current_parts < <(parse_semver_like "$version")

                    if [[ ''${#candidate_parts[@]} -eq 0 ]]; then
                      is_semver=false
                      echo -e "\033[90m→ Switching to non-semantic versioning mode\033[0m"
                      continue
                    fi

                    is_newer=true
                    for i in "''${!candidate_parts[@]}"; do
                      # If we ran out of parts in the current version, the candidate has more parts
                      if [[ -z "''${current_parts[$i]}" ]]; then
                        break
                      fi

                      if [[ $((candidate_parts[i])) -lt $((current_parts[i])) ]]; then
                        is_newer=false
                        break
                      fi

                      if [[ $((candidate_parts[i])) -gt $((current_parts[i])) ]]; then
                        break
                      fi
                    done

                    if [[ "$is_newer" == true ]]; then
                      if [[ -z "$best_version" ]]; then
                        best_version="$candidate_version"
                        echo -e "\033[90m→ Found better version: \033[1;32m$candidate_version\033[0m"
                      else
                        readarray -t best_parts < <(parse_semver_like "$best_version")

                        is_better=false
                        for i in "''${!candidate_parts[@]}"; do
                          if [[ -z "''${best_parts[$i]}" ]]; then
                            is_better=true
                            break
                          fi

                          if [[ $((candidate_parts[i])) -gt $((best_parts[i])) ]]; then
                            is_better=true
                            break
                          fi

                          if [[ $((candidate_parts[i])) -lt $((best_parts[i])) ]]; then
                            break
                          fi
                        done

                        if [[ "$is_better" == true ]]; then
                          echo -e "\033[90m→ Found even better version: \033[1;32m$candidate_version\033[0m (\033[90mprevious best: $best_version\033[0m)"
                          best_version="$candidate_version"
                        fi
                      fi
                    fi
                  done <<<"$all_versions"

                  if [[ "$is_semver" == "false" && -n "$latest_version" ]]; then
                    best_version="$latest_version"
                    echo -e "\033[90m→ Using latest available version: \033[1;32m$latest_version\033[0m"
                  fi

                  if [[ -z "$best_version" ]]; then
                    echo -e "\033[1;33m⚠️  No newer version found for $name\033[0m (evaluated $considered_count versions)"
                    continue
                  fi

                  if [[ "$line" == *"# pinned"* ]]; then
                    echo -e "\033[1;33m⚠️  No newer version found for $name because it's pinned\033[0m (evaluated $considered_count versions)"
                    continue
                  fi

                  echo -e "\033[1;34m✅ Update available: \033[1;36m$name\033[0m \033[90m$version → \033[1;32m$best_version\033[0m"
                  sed -i "s?$name:$version?$name:$best_version?" "$(echo "$line" | jq -r .data.path.text)"
                done
              done
              echo
              ;;
            \?)
              args+=("-$OPTARG")
              ;;
            esac
          done

          shift "$((OPTIND - 1))"
          args+=("$@")

          echo -e "\033[1;34m🔄 Rebuilding NixOS configuration...\033[0m"
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
            c = lib.mkIf pkgs.stdenv.isLinux "code-insiders";
            ts = lib.mkIf pkgs.stdenv.isLinux "tmux-session";
            rb = if pkgs.stdenv.isLinux then "${rebuild}/bin/rebuild" else "nh darwin switch";
          };

          oh-my-zsh = {
            enable = true;
            plugins = [ "git" ];
          };

          initContent = lib.mkMerge [
            (lib.mkIf pkgs.stdenv.isLinux (
              lib.mkBefore ''
                tmux-session() {
                  TMUX_TMPDIR=/run/user/1000 ${pkgs.tmux}/bin/tmux new-session -A -s "$(basename "$PWD")" "$@"
                }

                update_ssh_tty() {
                  if [ -e "/tmp/tmux/$(tmux display-message -p '#S')/$(basename $(tmux display-message -p '#{client_name}'))-ssh_tty" ]; then
                    export SSH_TTY=''${SSH_TTY:-/dev/pts/9999}
                  else
                    unset SSH_TTY
                  fi
                }

                if [ -n "$TMUX" ]; then
                  add-zsh-hook precmd update_ssh_tty
                  export SSH_AUTH_SOCK="/tmp/tmux/$(tmux display-message -p '#S')/auth_sock"
                fi
                export SSH_AUTH_SOCK=''${SSH_AUTH_SOCK:-/home/sam/.1password/agent.sock}

                if [[ "$ZED_TERM" == "true" || "$TERM_PROGRAM" == "vscode" ]]; then
                  while true; do
                    tmux-session
                  done
                fi
              ''
            ))
            (lib.mkBefore ''
              eval "$(${pkgs.atuin}/bin/atuin pty-proxy init zsh)"
            '')

            (lib.mkIf pkgs.stdenv.isLinux ''
              function y() {
                local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
                yazi "$@" --cwd-file="$tmp"
                if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
                  builtin cd -- "$cwd"
                fi
                rm -f -- "$tmp"
              }

              export PATH="$PATH:${pkgs.qt6Packages.qtstyleplugin-kvantum}/bin"

              export ARCCODEX_API_KEY=$(cat /run/secrets/arccodex_api_key)
            '')
            ((lib.mkIf pkgs.stdenv.isDarwin) ''
              if [ -n "''${GHOSTTY_RESOURCES_DIR}" ]; then
                builtin source "''${GHOSTTY_RESOURCES_DIR}/shell-integration/zsh/ghostty-integration"
              fi
            '')
            ''
              export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
              zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
              source <(${pkgs.carapace}/bin/carapace _carapace)
            ''
          ];
        };

        home.packages = with pkgs; [
          carapace
          carapace-bridge
        ];

        programs = {
          zoxide.enable = true;
          starship.enable = true;
          direnv = {
            enable = true;
            nix-direnv.enable = true;
          };
          atuin = {
            enable = true;
            daemon.enable = true;
            settings.enter_accept = true;
          };
        };
      };
  };
}
