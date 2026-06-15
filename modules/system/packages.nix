{
  den.aspects.packages = {
    nixos = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        gh
        jq
        fd
        git
        zip
        eza
        nil
        wget
        tlrc
        nixd
        btop
        socat
        unzip
        devenv
        ffmpeg
        ripgrep
        ethtool
        jujutsu
        rainfrog
        usbutils
        copyparty
        postgresql
        cloudflared
        (pkgs.writeShellScriptBin "dua" "${pkgs.dua}/bin/dua -i /tmp -i /mnt/secondary $@")
        (pkgs.writeShellScriptBin "upnp" ''
          case $1 in
          open)
            sudo nixos-firewall-tool open "$2" "$3"
            ${miniupnpc}/bin/upnpc -a @ "$3" "$3" "$2"
            ;;
          close)
            ${miniupnpc}/bin/upnpc -d "$3" "$2"
            sudo iptables -D nixos-fw -p "$2" --dport "$3" -j nixos-fw-accept
            ;;
          *)
            echo "Invalid argument. Use 'open' or 'close'."
            exit 1
            ;;
          esac
        '')
      ];
    };

    darwin = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        gh
        fd
        git
        eza
        nil
        wget
        nixd
        tlrc
        jujutsu
        ripgrep
      ];
    };
  };
}
