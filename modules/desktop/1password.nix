{
  den.aspects._1password = {
    nixos = {
      programs = {
        _1password.enable = true;
        _1password-gui = {
          enable = true;
          polkitPolicyOwners = [ "sam" ];
        };
      };

      environment = {
        etc = {
          "1password/custom_allowed_browsers" = {
            text = ''
              zen
            '';
            mode = "0755";
          };
        };
      };
    };

    darwin = {
      homebrew.casks = [ "1password" ];
    };
  };
}
