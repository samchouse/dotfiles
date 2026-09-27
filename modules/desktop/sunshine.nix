{
  den.aspects.sunshine = {
    nixos = { pkgs, ... }: {
      services = {
        sunshine = {
          enable = true;
          package = pkgs.callPackage ../../pkgs/sunshine { };
          capSysAdmin = true;
          openFirewall = true;
          applications = {
            env = {
              PATH = "$(PATH):$(HOME)/.local/bin";
            };
            apps = [
              {
                name = "Desktop";
                image-path = "desktop.png";
              }
            ];
          };
          settings = {
            output_name = "0";
            global_prep_cmd = builtins.toJSON [
              {
                do =
                  let
                    setup-monitor = pkgs.writeShellScriptBin "setup-monitor" ''
                      hyprctl eval "hl.monitor({ output = 'VIRT-1', mode = \"''${SUNSHINE_CLIENT_WIDTH}x''${SUNSHINE_CLIENT_HEIGHT}@''${SUNSHINE_CLIENT_FPS}\" })"
                    '';
                  in
                  "${setup-monitor}/bin/setup-monitor";
              }
              {
                do = "bash -c \"pkill gjs || true; ags run & disown\"";
              }
              {
                do = "sh -c \"pkill -USR1 hyprlock || true\"";
                undo = "/home/sam/.config/hypr/scripts/lock.sh";
              }
            ];
          };
        };
      };
    };
  };
}
