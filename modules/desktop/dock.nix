{
  den.aspects.dock = {
    darwin = {
      system.defaults = {
        dock = {
          persistent-apps = [
            {
              app = "/System/Applications/Apps.app";
            }
            {
              app = "/Applications/Zen Browser.app";
            }
            {
              app = "/System/Applications/Messages.app";
            }
            {
              app = "/System/Applications/Mail.app";
            }
            {
              app = "/System/Applications/Reminders.app";
            }
            {
              app = "/System/Applications/Music.app";
            }
            {
              app = "/Applications/Discord.app";
            }
          ];

          persistent-others = [
            {
              folder = {
                path = "/Users/sam/Downloads";
                arrangement = "date-added";
                showas = "fan";
              };
            }
          ];
        };

        CustomUserPreferences."com.apple.dock"."size-immutable" = true;
      };
    };
  };
}
