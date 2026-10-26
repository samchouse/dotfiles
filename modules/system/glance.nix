{
  den.aspects.glance = {
    nixos = {
      services.glance = {
        enable = true;

        settings = {
          server.host = "0.0.0.0";

          pages = [
            {
              name = "Startpage";
              width = "slim";
              "hide-desktop-navigation" = true;
              "center-vertically" = true;

              columns = [
                {
                  size = "full";

                  widgets = [
                    {
                      type = "monitor";
                      cache = "1m";
                      title = "Services";

                      sites = [
                        {
                          title = "FileBrowser";
                          url = "https://sys.xenfo.dev";
                          icon = "di:filebrowser-quantum";
                        }
                        {
                          title = "Home Assistant";
                          url = "https://ha.xenfo.dev";
                          icon = "di:home-assistant";
                        }
                        {
                          title = "AIOMetadata";
                          url = "https://aiom.xenfo.dev";
                          icon = "di:jellyfin";
                        }
                        {
                          title = "Beszel";
                          url = "https://sys.xenfo.dev";
                          icon = "di:beszel";
                        }
                        {
                          title = "Sure";
                          url = "http://desktop:3050";
                          icon = "di:sure";
                        }
                        {
                          title = "Pocket ID";
                          url = "https://id.xenfo.dev";
                          icon = "di:pocket-id";
                        }
                        {
                          title = "copyparty";
                          url = "http://desktop:3923";
                          icon = "di:copyparty";
                        }
                        {
                          title = "Sunshine";
                          url = "http://desktop:47989";
                          icon = "di:sunshine";
                        }
                      ];
                    }
                  ];
                }
              ];
            }
          ];
        };
      };
    };
  };
}
