{ config, pkgs, resources, lib, ... }:

let
  php = pkgs.php54;

  hostgroupsCfg = pkgs.writeText "hostgroups.cfg" ''
    define hostgroup {
      hostgroup_name ssh
      alias          servers with ssh
      members        *
    }
  '';

  servicesCfg = pkgs.writeText "services.cfg" ''
    define service {
      hostgroup ssh
      service_description SSH
      check_command check_ssh
      use generic-service
    }
  '';

  hostsCfg = pkgs.writeText "hosts.cfg" ''
    define host {
      use linux-server
      host_name new-www.haskell.org
      alias www.haskell.org
      address 88.198.224.243
    }
  '';

  contactsCfg = pkgs.writeText "contacts.cfg" ''
    define contact {
      contact_name relrod
      use generic-contact
      alias Ricky Elrod
      email ricky.haskell@elrod.me
    }
  '';

in {
  services.nagios.enable = true;
  services.nagios.enableWebInterface = true;
  services.nagios.objectDefs = [
    "${pkgs.nagios}/etc/objects/commands.cfg"
    "${pkgs.nagios}/etc/objects/contacts.cfg"
    "${pkgs.nagios}/etc/objects/templates.cfg"
    "${pkgs.nagios}/etc/objects/timeperiods.cfg"
    hostgroupsCfg
    servicesCfg
    hostsCfg
    contactsCfg
  ];

  #systemd.services.phpfpm.environment = { PHPRC = phpIni; };
  services.phpfpm.phpPackage = php;
  services.phpfpm.poolConfigs =
    { nagios = ''
        listen = /run/phpfpm/nagios.sock
        user = nagios
        pm = dynamic
        pm.max_children = 75
        pm.start_servers = 10
        pm.min_spare_servers = 5
        pm.max_spare_servers = 20
        pm.max_requests = 500
      '';
    };
}
