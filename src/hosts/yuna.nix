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
