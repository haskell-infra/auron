{ config, pkgs, lib, ... }:

with lib;
with import ../res/ids.nix;

let
  cfg = config.services.phabricator;
  php = pkgs.php54;

  libphutil = {
    url = git://github.com/haskell-infra/libphutil.git;
    rev = "7e75bf271c669b61eb6e6e2ea312a36e64b80a4a";
  };

  arcanist = {
    url = git://github.com/haskell-infra/arcanist.git;
    rev = "bec13cfea898b93460e83531a82c241c634e4c1b";
  };

  phabricator = {
    url = git://github.com/haskell-infra/phabricator.git;
    rev = "a0c9869111fa98ee780c2fdcd5d5c6dd1b58fd2e";
  };

  phab-admin = pkgs.stdenv.mkDerivation rec {
    name = "phab-admin";

    phases = "installPhase";
    installPhase = ''
      mkdir -p $out/sbin

      cat > $out/sbin/phab-upgrade <<EOF
      #!/usr/bin/env bash
      set -e

      if [ -z "\$1" ]; then
        echo "err: argument must be mysql root password for phabricator upgrade"
        exit 1
      fi

      ROOT=/var/lib/phab
      PHUTIL=\$ROOT/libphutil
      ARC=\$ROOT/arcanist
      PHAB=\$ROOT/phabricator

      echo -n "msg: stopping phabricator systemd services... "
      systemctl stop nginx
      systemctl stop nginx
      systemctl stop phabricator-gc
      systemctl stop phabricator-pull
      systemctl stop phabricator-taskmaster1
      systemctl stop phabricator-aphlict
      echo OK

      echo -n "msg: upgrading code... "
      (cd \$PHUTIL && git checkout master && git pull origin master) > \
        /dev/null 2>&1
      (cd \$ARC && git checkout master && git pull origin master) > \
        /dev/null 2>&1
      echo OK

      echo -n "msg: upgrading database... "
      \$PHAB/bin/storage upgrade --force --user root \
        --password \$1 > /dev/null 2>&1
      echo OK

      echo -n "msg: restarting phabricator systemd services... "
      systemctl start phabricator-aphlict
      systemctl start phabricator-taskmaster1
      systemctl start phabricator-pull
      systemctl start phabricator-gc
      systemctl start phpfpm
      systemctl start nginx
      echo OK
      EOF

      cat > $out/sbin/phab-config <<EOF
      #!/bin/sh
      cd /var/lib/phab/phabricator
      exec ./bin/config \$@
      EOF

      chmod +x $out/sbin/phab-upgrade
      chmod +x $out/sbin/phab-config
    '';
  };
in
{
  options = {
    services.phabricator = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          If enabled, enable Phabricator with php-fpm
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    users.extraUsers.phab = {
      description = "Phabricator User";
      home = "/var/lib/phab";
      createHome = true;
      uid  = with import ../res/ids.nix; uids.phab;
      group = "phab";
      useDefaultShell = true;
    };

    users.extraGroups.phab = {
      name = "phab";
      gid = with import ../res/ids.nix; gids.phab;
    };

    systemd.services."phabricator-init" =
      { wantedBy = [ "multi-user.target" ];
        requires = [ "network.target" ];

        path = [ php ];
        script = ''
          cd /var/lib/phab
          if [ ! -d libphutil ]; then
            ${pkgs.git}/bin/git clone ${libphutil.url}
            cd libphutil && ${pkgs.git}/bin/git checkout ${libphutil.rev}
            cd ..
          fi
          if [ ! -d arcanist ]; then
            ${pkgs.git}/bin/git clone ${arcanist.url}
            cd arcanist && ${pkgs.git}/bin/git checkout ${arcanist.rev}
            cd ..
          fi
          if [ ! -d phabricator ]; then
            ${pkgs.git}/bin/git clone ${phabricator.url}
            cd phabricator && ${pkgs.git}/bin/git checkout ${phabricator.rev}
            cd ..
          fi

          mkdir -p /var/repo
          chown -R phab:phab /var/lib/phab /var/repo
          ${phab-admin}/sbin/phab-config set storage.upload-size-limit 50M
          ${phab-admin}/sbin/phab-config set phabricator.timezone \
            ${config.time.timeZone}
          ${phab-admin}/sbin/phab-config set environment.append-paths \
            '["/run/current-system/sw/bin","/run/current-system/sw/sbin"]'

        '';

        serviceConfig.Type = "oneshot";
        serviceConfig.RemainAfterExit = true;
      };

    systemd.services."phabricator-aphlict" =
      { wantedBy = [ "multi-user.target" ];
        requires = [ "phabricator-init.service" ];

        path = [ pkgs.nodejs php pkgs.which ];
        serviceConfig.Restart = "always";
        serviceConfig.ExecStart =
          "${php}/bin/php /var/lib/phab/phabricator/bin/aphlict debug";
      };

    /*
    systemd.services."phabricator-bot" =
      { wantedBy = [ "multi-user.target" ];
        requires = [ "phabricator-init.service" ];

        path = [ php ];
        serviceConfig.User    = "phab";
        serviceConfig.Restart = "always";
      };
    */

    systemd.services."phabricator-gc" =
      { wantedBy = [ "multi-user.target" ];
        requires = [ "phabricator-init.service" ];

        path = [ php ];
        serviceConfig.User    = "phab";
        serviceConfig.Restart = "always";
        serviceConfig.ExecStart =
          "${php}/bin/php /var/lib/phab/phabricator/bin/phd debug " +
          "PhabricatorGarbageCollectorDaemon";
      };

    systemd.services."phabricator-taskmaster1" =
      { wantedBy = [ "multi-user.target" ];
        requires = [ "phabricator-init.service" ];

        path = [ php ];
        serviceConfig.User    = "phab";
        serviceConfig.Restart = "always";
        serviceConfig.ExecStart =
          "${php}/bin/php /var/lib/phab/phabricator/bin/phd debug " +
          "PhabricatorTaskmasterDaemon";
      };

    systemd.services."phabricator-pull" =
      { wantedBy = [ "multi-user.target" ];
        requires = [ "phabricator-init.service" ];

        path = [ php ];
        serviceConfig.User    = "phab";
        serviceConfig.Restart = "always";
        serviceConfig.ExecStart =
          "${php}/bin/php /var/lib/phab/phabricator/bin/phd debug " +
          "PhabricatorRepositoryPullLocalDaemon";
      };

    services.phpfpm.poolConfigs =
      { phabricator = ''
          listen = /run/phpfpm/phabricator.sock
          user = phab
          pm = dynamic
          pm.max_children = 75
          pm.start_servers = 10
          pm.min_spare_servers = 5
          pm.max_spare_servers = 20
          pm.max_requests = 500
        '';
      };

    environment.systemPackages =
      [ php phab-admin pkgs.nodejs pkgs.php_apc pkgs.which
        pkgs.ssmtp
      ];
  };
}
