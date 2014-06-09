let
  gencert = import ../../pkgs/gencert.nix;
in
{
  systemd.services.gen-temp-certs =
    { wantedBy = [ "multi-user.target" ];
      before   = [ "nginx.service" ];

      script = ''
        if [ ! -d /root/ssl ]; then
          ${gencert}/bin/gencert
        fi
      '';
      serviceConfig.User = "root";
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = true;
    };
}
