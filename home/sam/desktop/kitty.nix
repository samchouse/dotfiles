{ ... }:
{
  programs.kitty = {
    enable = true;

    shellIntegration.enableZshIntegration = true;
    font.name = "MonoLisa Nerd Font";

    settings = {
      enable_audio_bell = false;
    };
  };
}
