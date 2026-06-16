{ inputs, ... }: {
  den.aspects.homebrew = {
    darwin =
      { pkgs, ... }:
      let
        brewCompletions = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/Homebrew/brew/refs/heads/main/completions/zsh/_brew";
          sha256 = "sha256-pUxzweF5nR2SGoiMS0JFUZ3H7oaoBYpXlfyxwiECXpQ=";
        };
      in
      {
        imports = [
          inputs.nix-homebrew.darwinModules.nix-homebrew
        ];

        homebrew.enable = true;
        nix-homebrew = {
          enable = true;
          user = "sam";
          autoMigrate = true;
        };

        system.activationScripts.postActivation.text = ''
          mkdir -p /opt/homebrew/share/zsh/site-functions
          ln -sfn ${brewCompletions} /opt/homebrew/share/zsh/site-functions/_brew
        '';
      };
  };
}
