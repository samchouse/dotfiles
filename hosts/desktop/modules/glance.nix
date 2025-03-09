{ pkgs, ... }:
{
  services.glance = {
    enable = true;

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
                      title = "Beszel";
                      url = "https://sys.xenfo.dev";
                    }
                    {
                      title = "Tracker";
                      url = "https://tracker.xenfo.dev/docs";
                    }
                    {
                      title = "InvokeAI";
                      url = "https://invoke.xenfo.dev";
                    }
                    {
                      title = "LibreChat";
                      url = "https://ai.xenfo.dev";
                      icon = "si:openai";
                    }
                    {
                      title = "LiteLLM";
                      url = "https://lllm.xenfo.dev";
                      icon = "si:openai";
                    }
                    {
                      title = "Home Assistant";
                      url = "https://ha.xenfo.dev";
                      icon = "si:homeassistant";
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
                          title = "Tailscale";
                          url = "https://login.tailscale.com/admin/machines";
                        }
                      ];
                    }
                    {
                      title = "AI";
                      links = [
                        {
                          title = "OpenRouter";
                          url = "https://openrouter.ai/activity";
                        }
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
