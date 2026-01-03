{
  programs.kitty = {
    enable = true;

    themeFile = "mishran";
    enableGitIntegration = true;
    font.name = "MonoLisa Nerd Font";
    shellIntegration.enableZshIntegration = true;

    settings = {
      enable_audio_bell = false;
      background_opacity = 0.8;
    };
  };
}
