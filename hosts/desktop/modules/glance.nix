{ pkgs, ... }:
{
  services.glance = {
    enable = true;
    package = (
      pkgs.glance.overrideAttrs (oldAttrs: rec {
        version = "latest";
        src = (
          pkgs.fetchFromGitHub {
            owner = "glanceapp";
            repo = "glance";
            rev = "bacb607d902cd125c1e97d56d4b51ad56474cc54";
            hash = "sha256-LzrnbjljbJ8eCFsZwMp5ylx88IPSx5l3Vsy+2LeIFts=";
          }
        );

        vendorHash = "sha256-i26RD3dIN0pEnfcLAyra2prLhvd/w1Qf1A44rt7L6sc=";
      })
    );

    settings = {
      server = {
        host = "0.0.0.0";
        port = 8090;
      };
      pages = [
        {
          name = "Home";
          columns = [
            {
              size = "small";
              widgets = [
                {
                  type = "calendar";
                }
                {
                  type = "group";
                  widgets = [
                    {
                      title = "ace";
                      type = "repository";
                      repository = "samchouse/ace";
                      token = "\${GLANCE_GH_TOKEN}";
                    }
                    {
                      title = "adrastos";
                      type = "repository";
                      repository = "samchouse/adrastos";
                      token = "\${GLANCE_GH_TOKEN}";
                    }
                  ];
                }
                {
                  type = "markets";
                  markets = [
                    {
                      symbol = "SPY";
                      name = "S&P 500";
                    }
                    {
                      symbol = "NVDA";
                      name = "NVIDIA";
                    }
                    {
                      symbol = "AAPL";
                      name = "Apple";
                    }
                    {
                      symbol = "MSFT";
                      name = "Microsoft";
                    }
                    {
                      symbol = "GOOGL";
                      name = "Google";
                    }
                  ];
                }
              ];
            }
            {
              size = "full";
              widgets = [
                {
                  type = "search";
                  search-engine = "google";
                  autofocus = true;
                  bangs = [
                    {
                      title = "MyNixOS";
                      shortcut = "!n";
                      url = "https://mynixos.com/search?q={QUERY}";
                    }
                  ];
                }
                {
                  type = "hacker-news";
                }
                {
                  type = "reddit";
                  subreddit = "unixporn";
                }
              ];
            }
            {
              size = "small";
              widgets = [
                {
                  type = "weather";
                  location = "Montreal, Canada";
                }
                {
                  type = "monitor";
                  cache = "1m";
                  title = "Services";
                  sites = [
                    {
                      title = "Open WebUI";
                      url = "https://ai.xenfo.dev";
                      icon = "si:openai";
                    }
                  ];
                }
                {
                  type = "bookmarks";
                  groups = [
                    {
                      title = "General";
                      links = [
                        {
                          title = "Home Assistant";
                          url = "https://ha.xenfo.dev";
                        }
                        {
                          title = "Tailscale";
                          url = "https://login.tailscale.com/admin/machines";
                        }
                      ];
                    }
                    {
                      title = "AI";
                      links = [
                        {
                          title = "OpenAI";
                          url = "https://platform.openai.com/usage";
                        }
                        {
                          title = "Anthropic";
                          url = "https://console.anthropic.com/settings/usage";
                        }
                      ];
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
}
