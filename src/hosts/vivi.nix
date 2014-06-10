/** vivi - mysql01 configuration
 *
 * "Oh, nothing... My face is always like this."
 *    - Vivi Ornitier, Final Fantasy IX
 */
{ config, pkgs, resources, lib, ... }:

with builtins;

{
  require = [ ./roles/common.nix ];

  /* Networking configuration */
  networking.hostName = "vivi";
  networking.firewall.allowedTCPPorts =
    [ 9000 # spiped, no MariaDB
    ];

  /* MariaDB configuration */
  services.mysql.enable  = true;
  services.mysql.package = pkgs.mariadb;
  services.mysql.extraOptions = ''
    sql_mode=STRICT_ALL_TABLES
  '';

  /* Spiped frontend */
  /* TODO: use a unix pipe for the target? */
  services.spiped.enable = true;
  services.spiped.config = {
    mysql =
      { keyfile = "/var/lib/spiped/mysql.key";
        decrypt = true;
        source  = "0.0.0.0:9000";
        target  = "127.0.0.1:3306";
      };
  };
}
