{
  den.aspects.importer = {
    homeManager =
      { pkgs, ... }:
      {
        systemd.user.services.importer = {
          Install = {
            WantedBy = [ "default.target" ];
          };

          Service = {
            ExecStart = "${pkgs.uv}/bin/uv run fastapi run --port 3543 --host 0.0.0.0";
            WorkingDirectory = "/home/sam/Documents/projects/personal/dotfiles/modules/system/importer";
            Restart = "on-failure";
          };
        };
      };
  };
}
