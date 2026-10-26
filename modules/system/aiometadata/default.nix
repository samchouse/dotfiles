{
  den.aspects.aiometadata = {
    nixos = { pkgs, config, ... }: {
      virtualisation.oci-containers.containers = {
        aiometadata_redis = {
          image = "redis:latest";
          volumes = [ "aiometadata-redis:/data" ];
          extraOptions = [ "--network=aiometadata-net" ];

          cmd = [
            "redis-server"
            "--appendonly"
            "yes"
            "--save"
            "3600"
            "1"
          ];
        };

        aiometadata = {
          autoStart = false;
          image = "aiometadata:latest";
          ports = [ "3232:3232" ];
          dependsOn = [ "aiometadata_redis" ];
          volumes = [ "aiometadata:/app/addon/data" ];

          environmentFiles = [
            ./.env
            config.sops.templates."aiometadata.env".path
          ];

          extraOptions = [
            "--network=aiometadata-net"
            "--init"
            "--tty"
          ];
        };
      };

      systemd.services = {
        init-aiometadata-network = {
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = "${pkgs.podman}/bin/podman network create --ignore aiometadata-net";
          };
        };

        build-aiometadata = {
          wantedBy = [ "multi-user.target" ];
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];

          path = with pkgs; [
            git
            podman
            systemd
            coreutils
          ];

          serviceConfig = {
            Type = "oneshot";
            WorkingDirectory = "/tmp";
          };

          script = ''
            set -euo pipefail

            TMP_DIR=$(mktemp -d /tmp/aiometadata-build.XXXXXX)
            trap 'rm -rf "$TMP_DIR"' EXIT

            git clone --depth=1 https://github.com/samchouse/aiometadata.git "$TMP_DIR"
            cd "$TMP_DIR"

            COMMIT=$(git rev-parse --short HEAD)
            TAGGED_IMAGE="aiometadata:$COMMIT"

            if podman image exists "$TAGGED_IMAGE"; then
              echo "Image $TAGGED_IMAGE already exists. Skipping build."
              exit 0
            fi

            echo "Building image $TAGGED_IMAGE..."
            podman build \
              -t "$TAGGED_IMAGE" \
              -t aiometadata:latest \
              .

            echo "Successfully built $TAGGED_IMAGE."

            if systemctl is-active --quiet podman-aiometadata.service; then
              echo "Restarting podman-aiometadata.service with new build..."
              systemctl restart --no-block podman-aiometadata.service
            fi
          '';
        };

        podman-aiometadata = {
          after = [
            "build-aiometadata.service"
            "init-aiometadata-network.service"
          ];
          requires = [
            "build-aiometadata.service"
            "init-aiometadata-network.service"
          ];
        };

        podman-aiometadata_redis = {
          after = [ "init-aiometadata-network.service" ];
          requires = [ "init-aiometadata-network.service" ];
        };
      };
    };
  };
}
