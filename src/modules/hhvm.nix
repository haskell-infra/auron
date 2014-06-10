{ config, pkgs, lib, ... }:

with lib;
with import ../res/ids.nix;

let
  cfg = config.services.hhvm;
  php = pkgs.php54;
  stateDir = "/run/hhvm";

  phpIni = pkgs.runCommand "php.ini"
    { options = concatStringsSep "\n" cfg.phpIniOpts;
    } ''
    cat ${php}/etc/php-recommended.ini > $out
    substituteInPlace $out \
      --replace "upload_max_filesize = 2M" \
                "upload_max_filesize = ${cfg.uploadLimit}"
    echo "$options" >> $out
  '';
in
{
  options = {
    services.hhvm = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "If enabled, enable HHVM FastCGI server.";
      };

      debug = mkOption {
        type = types.bool;
        default = false;
        description = "If enabled, start a HHVM Admin Server on port 9001";
      };

      phpIniOpts = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "php.ini configuration options the server";
      };

      uploadLimit = mkOption {
        type = types.str;
        default = "10M";
        description = "Upload file size limit via upload_max_filesize";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.hhvm =
      { wantedBy = [ "multi-user.target" ];
        requires = [ "network.target" ];
        before   = [ "nginx.service" ];

        environment.HHVM_REPO_CENTRAL_PATH = "${stateDir}/.hhvm.hhbc";

        preStart = "mkdir -p ${stateDir}";
        serviceConfig.Restart = "always";
        script = ''
          #!{stdenv.shell}
          chown nginx -R ${stateDir} && cd ${stateDir}
          ${pkgs.hhvm}/bin/hhvm --mode server -c ${phpIni} --user nginx \
            -vServer.Type=fastcgi -vServer.Port=9000 \
            ${optionalString cfg.debug "-vAdminServer.Port=9001"}
        '';
      };
  };
}
