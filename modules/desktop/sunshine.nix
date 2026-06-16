{
  flake-file.inputs.nixpkgs-sunshine.url = "github:NixOS/nixpkgs/refs/pull/521906/head";

  den.aspects.sunshine = {
    nixos = {
      services = {
        sunshine = {
          enable = true;
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
                do = "sh -c \"hyprctl keyword monitor VIRT-1,\${SUNSHINE_CLIENT_WIDTH}x\${SUNSHINE_CLIENT_HEIGHT}@\${SUNSHINE_CLIENT_FPS},5120x0,1\"";
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
