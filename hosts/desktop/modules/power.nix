{
  pkgs,
  ...
}:
let
  usb-power = pkgs.writeShellScriptBin "usb-power" ''
    VENDOR_ID=258a
    PRODUCT_ID=0090
    PIPE="/tmp/usb-power"

    find_usb_device() {
      grep -rl "$VENDOR_ID" /sys/bus/usb/devices/*/idVendor | while read vendor_file; do
        product_file="''${vendor_file%/idVendor}/idProduct"
        if [ -f "$product_file" ] && grep -q "$PRODUCT_ID" "$product_file"; then
          echo "''${vendor_file%/idVendor}"
        fi
      done
    }

    handle() {
      case "$1" in
      on)
        echo on >"$(find_usb_device)/power/control"
        ;;
      off)
        echo auto >"$(find_usb_device)/power/control"
        ;;
      esac
    }

    mkfifo "$PIPE"
    chown sam "$PIPE"
    while read -r line <"$PIPE"; do handle "$line"; done
  '';
in
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

  systemd.services.usb-power = {
    enable = true;

    wantedBy = [ "graphical.target" ];

    unitConfig = {
      Description = "USB power manager";
    };

    serviceConfig = {
      User = "root";
      Group = "root";
      ExecStart = "${usb-power}/bin/usb-power";
    };
  };
}
