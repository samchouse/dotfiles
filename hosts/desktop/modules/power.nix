{
  services = {
    upower.enable = true;
    logind.settings.Login = {
      HandlePowerKey = "ignore";
      HandleRebootKey = "ignore";
      HandleSuspendKey = "ignore";
      HandleHibernateKey = "ignore";
      PowerKeyIgnoreInhibited = true;
      SuspendKeyIgnoreInhibited = true;
      HibernateKeyIgnoreInhibited = true;
    };
  };
}
