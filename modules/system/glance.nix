{
  den.aspects.glance = {
    nixos = { pkgs, ... }: {
      services.glance = {
        enable = true;
        package = pkgs.glance.overrideAttrs (
          old: final: {
            version = "0.8.6";

            src = pkgs.fetchFromGitHub {
              owner = "glanceapp";
              repo = "glance";
              tag = "v${final.version}";
              hash = "sha256-2WFX1Gca7ign9i1zOQ9lRdtOSGq9QG33vIA5QTnq9E8=";
            };

            vendorHash = "sha256-a92V/duqvrWEb8QSJLA5rHYYZCcJ4fBC962SEr4FJDA=";
          }
        );

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
