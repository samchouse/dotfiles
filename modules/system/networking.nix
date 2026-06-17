{
  den.aspects.networking = {
    nixos = { pkgs, ... }: {
      networking = {
        networkmanager.enable = true;

        firewall = {
          enable = true;

          trustedInterfaces = [ "enp5s0" ];
          interfaces.wlp6s0.allowedTCPPorts = [ 8081 ];

          # https://github.com/miniupnp/miniupnp/tree/master/miniupnpc#readme
          extraCommands = ''
            ${pkgs.ipset}/bin/ipset create upnp hash:ip,port timeout 3
            iptables -A OUTPUT -d 239.255.255.250/32 -p udp -m udp --dport 1900 -j SET --add-set upnp src,src --exist
            iptables -A INPUT -p udp -m set --match-set upnp dst,dst -j ACCEPT
            iptables -A INPUT -d 239.255.255.250/32 -p udp -m udp --dport 1900 -j ACCEPT

            ${pkgs.ipset}/bin/ipset create upnp6 hash:ip,port timeout 3 family inet6
            ip6tables -A OUTPUT -d ff02::c/128 -p udp -m udp --dport 1900 -j SET --add-set upnp6 src,src --exist
            ip6tables -A OUTPUT -d ff05::c/128 -p udp -m udp --dport 1900 -j SET --add-set upnp6 src,src --exist
            ip6tables -A INPUT -p udp -m set --match-set upnp6 dst,dst -j ACCEPT
            ip6tables -A INPUT -d ff02::c/128 -p udp -m udp --dport 1900 -j ACCEPT
            ip6tables -A INPUT -d ff05::c/128 -p udp -m udp --dport 1900 -j ACCEPT
          '';
        };
      };

      services.avahi = {
        enable = true;

        nssmdns4 = true;
        openFirewall = true;
      };

      virtualisation.oci-containers.containers = {
        cloudflared = {
          image = "cloudflare/cloudflared:2026.6.0";
          autoStart = false;
          cmd = [
            "tunnel"
            "--no-autoupdate"
            "run"
          ];
        };
      };
    };
  };
}
