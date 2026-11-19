{
  user,
  cfg,
  certDir,
}:
{ lib, pkgs, ... }:
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      mkcert
      nssTools
    ];

    # Generate Root CA and *.test certificates ONCE in /var/lib/ssl (persists across rebuilds)
    systemd.services.devkit-certs-init = {
      description = "Generate persistent mkcert Root CA and local *.test SSL certificates";
      wantedBy = [ "multi-user.target" ];
      before = [ "httpd.service" ];
      unitConfig = {
        ConditionPathExists = "!${certDir}/certs/localhost.crt";
      };
      path = [
        pkgs.mkcert
        pkgs.coreutils
      ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        mkdir -p ${certDir}/ca ${certDir}/certs
        export CAROOT=${certDir}/ca

        mkcert -cert-file ${certDir}/certs/localhost.crt -key-file ${certDir}/certs/localhost.key \
          "*.test" "localhost" "127.0.0.1" "::1"

        mkcert -cert-file ${certDir}/certs/mailpit.crt -key-file ${certDir}/certs/mailpit.key \
          "${cfg.mailpitDomain}" "*.${cfg.mailpitDomain}"

        chown -R ${user.name}:users ${certDir}
        chmod 0775 ${certDir} ${certDir}/ca ${certDir}/certs
        chmod 0640 ${certDir}/certs/*.key ${certDir}/ca/rootCA-key.pem
        chmod 0644 ${certDir}/certs/*.crt ${certDir}/ca/rootCA.pem
      '';
    };

    # Trust the persistent Root CA system-wide (runs on every boot/activation)
    systemd.services.devkit-ca-trust = {
      description = "Install persistent mkcert Root CA into system trust bundle";
      wantedBy = [ "multi-user.target" ];
      after = [ "devkit-certs-init.service" ];
      requires = [ "devkit-certs-init.service" ];
      before = [ "httpd.service" ];
      path = [ pkgs.coreutils ];
      serviceConfig = {
        Type = "oneshot";
      };
      script = ''
        if [ -f "${certDir}/ca/rootCA.pem" ]; then
          mkdir -p /etc/pki/tls/certs /etc/ssl/certs
          cp -f "${certDir}/ca/rootCA.pem" /etc/pki/tls/certs/devkit-rootCA.pem

          # Replace read-only /nix/store symlinks with a combined CA bundle
          rm -f /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-bundle.crt
          cat "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" "${certDir}/ca/rootCA.pem" > /etc/ssl/certs/ca-certificates.crt
          ln -sf /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-bundle.crt
        fi
      '';
    };

    # Also re-apply immediately after /etc is updated during nixos-rebuild switch
    system.activationScripts.devkit-ca-trust = lib.stringAfter [ "etc" ] ''
      if [ -f "${certDir}/ca/rootCA.pem" ]; then
        mkdir -p /etc/pki/tls/certs /etc/ssl/certs
        cp -f "${certDir}/ca/rootCA.pem" /etc/pki/tls/certs/devkit-rootCA.pem

        rm -f /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-bundle.crt
        cat "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" "${certDir}/ca/rootCA.pem" > /etc/ssl/certs/ca-certificates.crt
        ln -sf /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-bundle.crt
      fi
    '';

    services.dnsmasq = {
      enable = true;
      settings = {
        address = [
          "/.test/127.0.0.1"
          "/.test/::1"
        ];
        interface = "lo";
        bind-interfaces = true;
        no-dhcp-interface = "lo";
      };
    };

    networking = {
      nameservers = [
        "127.0.0.1"
        "::1"
      ];
      firewall.allowedTCPPorts = [
        80
        443
        1025
        8025
      ];
    };
  };
}
