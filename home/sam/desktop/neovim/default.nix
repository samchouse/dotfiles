{
  programs.nixvim = {
    enable = true;

    plugins = {
      telescope.enable = true;
      treesitter.enable = true;
      web-devicons.enable = true;
      typst-preview.enable = true;
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings.sources = [
          { name = "nvim_lsp"; }
          { name = "path"; }
          { name = "buffer"; }
        ];
      };

      lsp = {
        enable = true;
        servers = {
          nixd.enable = true;
          ts_ls.enable = true;
          nil_ls.enable = true;
          tinymist.enable = true;
        };
      };
    };

    colorschemes.kanagawa = {
      enable = true;
      settings.theme = "dragon";
      settings.transparent = true;
    };
  };
}
