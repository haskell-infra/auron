{ config, pkgs, lib, ... }:

with lib;
with import ../res/ids.nix;

let
  cfg = config.services.phabricator;
  php = pkgs.php54;

  pecl = import <nixpkgs/pkgs/build-support/build-pecl.nix> {
    inherit php; inherit (pkgs) stdenv autoreconfHook fetchurl;
  };
  phab-apc = pecl rec {
    # APC 3.1.13 is recommended for Phabricator
    name = "apc-3.1.13";
    sha256 = "1gcsh9iar5qa1yzpjki9bb5rivcb6yjp45lmjmp98wlyf83vmy2y";
  };
  phab-scrypt = pecl rec {
    name = "scrypt-1.2";
    sha256 = "1yan3ya84bnjzspbfg46xw0whzj4f9zrmhl1c10f3m7mplr9n25m";
  };

  phpIni = pkgs.runCommand "php.ini" {} ''
    cat ${php}/etc/php-recommended.ini > $out

    echo "extension=${phab-apc}/lib/php/extensions/apc.so" >> $out
    echo "extension=${phab-scrypt}/lib/php/extensions/scrypt.so" >> $out
    echo "apc.stat = '0'" >> $out
    substituteInPlace $out \
      --replace "upload_max_filesize = 2M" \
                "upload_max_filesize = ${cfg.uploadLimit}"
    substituteInPlace $out \
      --replace "post_max_size = 8M" \
                "post_max_size = ${cfg.uploadLimit}"
  '';

  # Useful administration package for Phabricator
  phab-admin = pkgs.stdenv.mkDerivation rec {
    name = "phab-admin";
    buildInputs = [ pkgs.makeWrapper ];

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

      ROOT=/var/lib/phabricator
      PHUTIL=\$ROOT/libphutil
      ARC=\$ROOT/arcanist
      PHAB=\$ROOT/phabricator
      PHUTILHASK=\$ROOT/libphutil-haskell
      PHUTILRACK=\$ROOT/libphutil-rackspace
      PHUTILSCRYPT=\$ROOT/libphutil-scrypt

      echo -n "msg: stopping phabricator systemd services... "
      systemctl stop nginx
      systemctl stop phpfpm
      \$PHAB/bin/phd     stop > /dev/null 2>&1
      \$PHAB/bin/aphlict stop > /dev/null 2>&1
      echo OK

      echo -n "msg: upgrading code... "
      (cd \$PHUTIL && git checkout master && git pull origin master) > \
        /dev/null 2>&1
      (cd \$PHUTILHASK && git checkout master && git pull origin master) > \
        /dev/null 2>&1
      (cd \$PHUTILRACK && git checkout master && git pull origin master) > \
        /dev/null 2>&1
      (cd \$PHUTILSCRYPT && git checkout master && git pull origin master) > \
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
      chmod +x $out/sbin/phab-upgrade

      cat > $out/sbin/phab-config <<EOF
      #!/bin/sh
      cd /var/lib/phabricator/phabricator && exec ./bin/config \$@
      chown -R phabricator:phabricator /var/lib/phabricator ${cfg.localStoragePath}
      EOF
      chmod +x $out/sbin/phab-config

      cat > $out/sbin/phab-run <<EOF
      #!/bin/sh
      NAME=\$1
      shift
      cd /var/lib/phabricator/phabricator && exec ./bin/\$NAME \$@
      EOF
      chmod +x $out/sbin/phab-run

      PAPPS="accountadmin aphlict audit auth cache celerity commit-hook diviner drydock fact feed files harbormaster hunks i18n lipsum mail phd policy remove repository search sms ssh-auth ssh-auth-key ssh-connect ssh-exec storage"

      for x in $PAPPS; do
        makeWrapper $out/sbin/phab-run $out/sbin/phab-$x --add-flags "$x"
      done

      for x in $PAPPS; do
        chmod +x $out/sbin/phab-$x
      done

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
          libphutil        = "git://github.com/haskell-infra/libphutil.git";
          arcanist         = "git://github.com/haskell-infra/arcanist.git";
          phabricator      = "git://github.com/haskell-infra/phabricator.git";
          libphutil-hask   = "git://github.com/haskell-infra/libphutil-haskell.git";
          libphutil-rack   = "git://github.com/haskell-infra/libphutil-rackspace.git";
          libphutil-scrypt = "git://github.com/haskell-infra/libphutil-scrypt.git";
        };
      };

      uploadLimit = mkOption {
        type = types.str;
        default = "10M";
        description = "Upload file size limit for Phabricator/phpfpm";
      };

      localStoragePath = mkOption {
        type = types.nullOr types.str;
        default = "/var/lib/phabricator/data";
        description = "Path to store local files for Phabricator";
      };
    };
  };

  config = mkIf cfg.enable {
    users.extraUsers.phabricator = {
      description = "Phabricator User";
      home = "/var/lib/phabricator";
      createHome = true;
      uid  = with import ../res/ids.nix; uids.phabricator;
      group = "phabricator";
      useDefaultShell = true;
    };

    users.extraGroups.phabricator = {
      name = "phabricator";
      gid = with import ../res/ids.nix; gids.phabricator;
    };

    systemd.services."phabricator-init" =
      { wantedBy = [ "multi-user.target" ];
        requires = [ "network.target" ];
        before   = [ "nginx.service" ];

        path = [ php ];
        script = ''
          cd /var/lib/phabricator
          if [ ! -d libphutil ]; then
            ${pkgs.git}/bin/git clone ${cfg.src.libphutil}
          fi
          if [ ! -d libphutil-haskell ]; then
            ${pkgs.git}/bin/git clone ${cfg.src.libphutil-hask}
          fi
          if [ ! -d libphutil-rackspace ]; then
            ${pkgs.git}/bin/git clone ${cfg.src.libphutil-rack}
          fi
          if [ ! -d libphutil-scrypt ]; then
            ${pkgs.git}/bin/git clone ${cfg.src.libphutil-scrypt}
          fi
          if [ ! -d arcanist ]; then
            ${pkgs.git}/bin/git clone ${cfg.src.arcanist}
          fi
          if [ ! -d phabricator ]; then
            ${pkgs.git}/bin/git clone ${cfg.src.phabricator}
          fi

          mkdir -p /var/repo /var/tmp/phd ${cfg.localStoragePath}
          ${phab-admin}/sbin/phab-config set mysql.port 3306
          ${optionalString (cfg.localStoragePath != null) ''
            ${phab-admin}/sbin/phab-config set storage.local-disk.path \
              ${cfg.localStoragePath}
          ''}
          ${phab-admin}/sbin/phab-config set files.enable-imagemagick true
          ${phab-admin}/sbin/phab-config set storage.mysql-engine.max-size 0
          ${phab-admin}/sbin/phab-config set storage.upload-size-limit \
            ${cfg.uploadLimit}
          ${phab-admin}/sbin/phab-config set phabricator.timezone \
            ${config.time.timeZone}
          ${phab-admin}/sbin/phab-config set environment.append-paths \
            '["/run/current-system/sw/bin","/run/current-system/sw/sbin"]'
          chown -R phabricator:phabricator /var/lib/phabricator /var/repo /var/tmp/phd ${cfg.localStoragePath}
        '';

        serviceConfig.User = "root";
        serviceConfig.Type = "oneshot";
        serviceConfig.RemainAfterExit = true;
      };

    services.phpfpm.phpPackage = php;
    services.phpfpm.phpIni = phpIni;
    services.phpfpm.poolConfigs =
      { phabricator = ''
          listen = /run/phpfpm/phabricator.sock
          listen.owner = nginx
          listen.group = nginx
          user = phabricator
          pm = dynamic
          pm.max_children = 75
          pm.start_servers = 10
          pm.min_spare_servers = 5
          pm.max_spare_servers = 20
          pm.max_requests = 500
        '';
      };

    environment.systemPackages = with pkgs;
      [ php phab-admin nodejs which imagemagick arcanist jq ];
  };
}
