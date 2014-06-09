{ config, pkgs, lib, ... }:

with lib;
with import ../res/ids.nix;

let
  cfg = config.services.phabricator;
  php = pkgs.php54;
  gencert = import ../pkgs/gencert.nix;

  # APC 3.1.13 is recommended for Phabricator
  pecl = import <nixpkgs/pkgs/build-support/build-pecl.nix> {
    inherit php;
    inherit (pkgs) stdenv autoreconfHook;
  };
  phab-apc = pecl rec {
    name = "phab-apc-${version}";
    version = "3.1.13";
    src = pkgs.fetchurl {
      url = "http://pecl.php.net/get/apc-${version}.tgz";
      sha256 = "1gcsh9iar5qa1yzpjki9bb5rivcb6yjp45lmjmp98wlyf83vmy2y";
    };
  };

  phab-suhosin = pecl rec {
    name = "phab-suhosin-${version}";
    version = "0.9.35";
    src = pkgs.fetchurl {
      url = "http://download.suhosin.org/suhosin-${version}.tgz";
      sha256 = "088gk2wh2md56wplhsinm9avs56cvc129fqqvagx02q6nsqjxphr";
    };
  };

  phpIni = pkgs.runCommand "php.ini" {} ''
    cat ${php}/etc/php-recommended.ini > $out

    echo "extension=${phab-apc}/lib/php/extensions/apc.so" >> $out
    echo "extension=${phab-suhosin}/lib/php/extensions/suhosin.so" >> $out
    echo "apc.stat = '0'" >> $out
    substituteInPlace $out \
      --replace ";upload_max_filesize = 2M" \
                "upload_max_filesize = ${cfg.uploadLimit}"
  '';

  # Useful administration package for Phabricator
  phab-admin = pkgs.stdenv.mkDerivation rec {
    name = "phab-admin";

    phases = "installPhase";
    installPhase = ''
      mkdir -p $out/sbin

      cat > $out/sbin/phab-upgrade <<EOF
      #!/usr/bin/env bash
      set -e

      if [ -z "\$1" ]; then
        echo "err: argument must be mysql pass or '--nopass'"
        exit 1
      fi

      ROOT=/var/lib/phab
      PHUTIL=\$ROOT/libphutil
      ARC=\$ROOT/arcanist
      PHAB=\$ROOT/phabricator

      echo -n "msg: stopping phabricator systemd services... "
      systemctl stop nginx
      systemctl stop phpfpm
      \$PHAB/bin/phd     stop > /dev/null 2>&1
      \$PHAB/bin/aphlict stop > /dev/null 2>&1
      echo OK

      echo -n "msg: upgrading code... "
      (cd \$PHUTIL && git checkout master && git pull origin master) > \
        /dev/null 2>&1
      (cd \$ARC && git checkout master && git pull origin master) > \
        /dev/null 2>&1
      (cd \$PHAB && git checkout master && git pull origin master) > \
        /dev/null 2>&1
      echo OK

      if [ "\$1"="--nopass" ]; then
        PASS=
      else
        PASS=--password \$1
      fi

      echo -n "msg: upgrading database... "
      \$PHAB/bin/storage upgrade --force --user root \$PASS > /dev/null 2>&1
      echo OK

      echo -n "msg: restarting phabricator systemd services... "
      \$PHAB/bin/aphlict start > /dev/null 2>&1
      \$PHAB/bin/phd     start > /dev/null 2>&1
      systemctl start phpfpm
      systemctl start nginx
      echo OK
      EOF

      cat > $out/sbin/phab-config <<EOF
      #!/bin/sh
      cd /var/lib/phab/phabricator
      exec ./bin/config \$@
      chown -R phab:phab /var/lib/phab # Set proper permissions
      EOF

      cat > $out/sbin/phab-phd <<EOF
      #!/bin/sh
      cd /var/lib/phab/phabricator
      exec ./bin/phd \$@
      EOF

      chmod +x $out/sbin/phab-upgrade
      chmod +x $out/sbin/phab-config
      chmod +x $out/sbin/phab-phd
    '';
  };
in
{
  options = {
    services.phabricator = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "If enabled, enable Phabricator with php-fpm.";
      };

      src = mkOption {
        type = types.attrsOf types.str;
        description = "Location of Phabricator source repositories.";
        default = {
          libphutil   = "git://github.com/phacility/libphutil.git";
          arcanist    = "git://github.com/phacility/arcanist.git";
          phabricator = "git://github.com/phacility/phabricator.git";
        };
      };

      uploadLimit = mkOption {
        type = types.str;
        default = "10M";
        description = "Upload file size limit for Phabricator/phpfpm";
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
        before   = [ "nginx.service" ];

        path = [ php ];
        script = ''
          cd /var/lib/phab
          if [ ! -d libphutil ]; then
            ${pkgs.git}/bin/git clone ${cfg.src.libphutil}
          fi
          if [ ! -d arcanist ]; then
            ${pkgs.git}/bin/git clone ${cfg.src.arcanist}
          fi
          if [ ! -d phabricator ]; then
            ${pkgs.git}/bin/git clone ${cfg.src.phabricator}
          fi

          if [ ! -d /root/ssl ]; then
            ${gencert}/bin/gencert
          fi
          mkdir -p /var/repo
          ${phab-admin}/sbin/phab-config set mysql.port 3306
          ${phab-admin}/sbin/phab-config set storage.mysql-engine.max-size 0
          ${phab-admin}/sbin/phab-config set storage.upload-size-limit \
            ${cfg.uploadLimit}
          ${phab-admin}/sbin/phab-config set phabricator.timezone \
            ${config.time.timeZone}
          ${phab-admin}/sbin/phab-config set environment.append-paths \
            '["/run/current-system/sw/bin","/run/current-system/sw/sbin"]'
          chown -R phab:phab /var/lib/phab /var/repo
        '';

        serviceConfig.User = "root";
        serviceConfig.Type = "oneshot";
        serviceConfig.RemainAfterExit = true;
      };

    systemd.services.phpfpm.environment = { PHPRC = phpIni; };
    systemd.services.phpfpm.path = [ pkgs.ssmtp ];
    services.phpfpm.phpPackage = php;
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

    environment.systemPackages = with pkgs;
      [ php phab-admin nodejs which ];
  };
}
