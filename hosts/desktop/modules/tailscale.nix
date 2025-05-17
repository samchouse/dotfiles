{
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;

  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  services = {
    tailscale = {
      enable = true;

      openFirewall = true;
      useRoutingFeatures = "both";
      extraSetFlags = [
        "--advertise-exit-node"
        "--ssh"
        "--advertise-routes=10.0.0.0/24"
        "--accept-routes"
      ];
    };

    networkd-dispatcher = {
      enable = true;

      rules."50-tailscale" = {
        onState = [ "routable" ];
        script = ''
          #!/bin/sh
          NETDEV=$(ip -o route get 8.8.8.8 | cut -f 5 -d " ")
          sudo ethtool -K "$NETDEV" rx-udp-gro-forwarding on rx-gro-list off
        '';
      };
    };
  };
}
