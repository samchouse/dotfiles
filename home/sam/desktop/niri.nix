{
  programs.niri.settings = {
    binds = {
      "Mod+Q" = {
        action.close-window = { };
      };
      "Mod+Shift+E" = {
        action.quit = { };
      };
      "Mod+T" = {
        action.spawn = "kitty";
        repeat = false;
      };
      "Mod+Space" = {
        action.spawn-sh = "vicinae toggle";
        repeat = false;
      };
      "Mod+Shift+P" = {
        action.power-off-monitors = { };
      };
      "Mod+Shift+Slash" = {
        action.show-hotkey-overlay = { };
      };
    }
    //
      # workspaces
      # binds Mod + [Shift +] {1–0} to [move to] workspace {1..10}
      builtins.listToAttrs (
        builtins.concatLists (
          builtins.genList (
            x:
            let
              wsNum = x + 1;
              key = if wsNum == 10 then "0" else builtins.toString wsNum;
            in
            [
              {
                name = "Mod+${key}";
                value = {
                  action.focus-workspace = wsNum;
                };
              }
              {
                name = "Mod+Shift+${key}";
                value = {
                  action.move-column-to-workspace = wsNum;
                };
              }
            ]
          ) 10
        )
      );

    spawn-at-startup = [
      {
        argv = [
          "gammastep"
          "-O"
          "4000"
        ];
      }
    ];
  };
}
