/** yuna - wiki configuration
 *
 * "A lotta fiends here, ya?"
 *    - Yuna, Final Fantasy X
 */
{ config, pkgs, resources, lib, ... }:

with builtins;

{
  require = [ ./common.nix ./duosec.nix ];

  /* Networking configuration */
  networking.hostName = "yuna";
  networking.firewall.allowedTCPPorts =
    [ 80 443
    ];

  /* Spiped backend for MariaDB */
  services.spiped.enable = true;
  services.spiped.config = {
    mysql =
      { keyfile = "/var/lib/spiped/mysql.key";
        encrypt = true;
        source  = "0.0.0.0:3306";
        target  = "mysql01:9000";
      };
  };

  /* Nginx configuration */
  services.nginx.enable = true;
  services.nginx.config = httpPlusHttps
    { serverNames = "wiki.haskell.org";
      config = ''
        location / {
          root /www/planet/public_html;
        }
      '';
    };
}
