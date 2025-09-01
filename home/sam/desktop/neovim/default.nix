{ pkgs, ... }:
{
  programs.nixvim = {
    enable = true;

    plugins = {
      snacks.enable = true;
      telescope = {
        enable = true;
        keymaps = {
          "<leader><space>" = {
            action = "git_files";
            options = {
              desc = "Telescope Git Files";
            };
          };
          "<leader>tf" = "find_files hidden=true no_ignore=true";
          "<leader>b" = "buffers";
          "<leader>tg" = "live_grep_args live_grep_args";
          "<leader>td" = "git_status";
        };
        extensions = {
          live-grep-args = {
            enable = true;
            settings.mappings = {
              i = {
                "<C-i>" = {
                  __raw = "require(\"telescope-live-grep-args.actions\").quote_prompt({ postfix = \" --iglob \" })";
                };
                "<C-k>" = {
                  __raw = "require(\"telescope-live-grep-args.actions\").quote_prompt()";
                };
                "<C-space>" = {
                  __raw = "require(\"telescope.actions\").to_fuzzy_refine";
                };
              };
            };
          };
        };
      };
      treesitter = {
        enable = true;
        settings.indent.enable = true;
      };
      web-devicons.enable = true;
      typst-preview.enable = true;
      typescript-tools.enable = true;
      copilot-vim.enable = false;
      mini-surround.enable = true;
      autoclose.enable = true;
      hardtime.enable = true;
      blink-cmp = {
        enable = true;
        settings = {
          signature.enabled = true;
          keymap = {
            preset = "super-tab";
          };
          completion.documentation.auto_show = true;
        };
      };
      lualine.enable = true;
      lsp = {
        enable = true;
        servers = {
          nixd.enable = true;
          nil_ls.enable = true;
          tinymist.enable = true;
          basedpyright.enable = true;
          biome.enable = true;
          ruff.enable = true;
        };
      };
      statuscol = {
        enable = true;
        settings.relculright = true;
        settings.segments = [
          {
            click = "v:lua.ScLa";
            condition = [
              true
              {
                __raw = "require('statuscol.builtin').not_empty";
              }
            ];
            text = [
              {
                __raw = "require('statuscol.builtin').lnumfunc";
              }
            ];
          }
          {
            sign = {
              namespace = [ "gitsigns" ];
              colwidth = 1;
              wrap = true;
            };
            click = "v:lua.ScSa";
          }
        ];
      };
      gitsigns = {
        enable = true;
        settings = {
          sign_priority = 0;
          current_line_blame = true;
        };
      };
      oil = {
        enable = true;
      };
    };

    extraPlugins = with pkgs.vimPlugins; [ claudecode-nvim ];
    extraConfigLua = ''
      require("claudecode").setup({})

      function _M.format(async)
        vim.lsp.buf.format({
          filter = function(client)
            local clients = vim.lsp.get_clients({ bufnr = 0 })
            for _, c in ipairs(clients) do
              if c.name == "biome" then
                return client.name == "biome"
              end
            end
            -- fallback: any client that supports formatting
            return client.supports_method("textDocument/formatting")
          end,
          async = async == nil and true or async,
        })
      end
    '';

    colorschemes.kanagawa = {
      enable = true;
      settings.theme = "dragon";
      settings.transparent = true;
    };

    globals.mapleader = " ";
    opts.number = true;
    opts.relativenumber = true;
    opts.showmode = false;
    keymaps = [
      {
        action = "<Nop>";
        key = "<C-k>";
      }
      {
        key = "<leader>f";
        action.__raw = ''function() _M.format() end'';
      }
      {
        key = "<leader>s";
        action = "<cmd>update<cr>";
      }
      {
        key = "<C-d>";
        action = "<C-d>zz";
      }
      {
        key = "<C-u>";
        action = "<C-u>zz";
      }
      {
        key = "n";
        action = "nzzzv";
      }
      {
        key = "N";
        action = "Nzzzv";
      }
      {
        key = "gd";
        action.__raw = ''
          function()
            if vim.lsp.buf.declaration then
              local ok = pcall(vim.lsp.buf.declaration)
              if not ok then
                vim.lsp.buf.definition()
              end
            else
              vim.lsp.buf.definition()
            end
          end
        '';
      }
    ];
    diagnostic.settings.signs = false;
    lsp.inlayHints.enable = true;
    autoCmd = [
      {
        pattern = [ "*" ];
        event = [ "BufWritePre" ];
        callback.__raw = ''function() _M.format(false) end'';
      }
      {
        pattern = [ "*" ];
        event = [
          "BufLeave"
          "FocusLost"
        ];
        callback.__raw = ''
          function() 
            if vim.bo.modified and not vim.bo.readonly and vim.fn.expand("%") ~= "" and vim.bo.buftype == "" then
              vim.api.nvim_command('silent update')
            end
          end
        '';
      }
    ];
    files = {
      "after/ftplugin/typescript.lua" = {
        opts = {
          expandtab = true;
          shiftwidth = 2;
          tabstop = 2;
        };
      };
      "after/ftplugin/nix.lua" = {
        opts = {
          expandtab = true;
          shiftwidth = 2;
          tabstop = 2;
        };
      };
    };

    nixpkgs = {
      config = {
        allowUnfree = true;
      };
    };
  };
}
