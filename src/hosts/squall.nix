/** squall - planet/venus configuration
 *
 * "... Whatever."
 *    - Squall Leonhart, Final Fantasy VIII
 */
{ config, pkgs, resources, lib, ... }:

with builtins;
with import ./roles/nginx.nix;
with import ../res/users.nix { inherit lib; };

{
  require = [ ./common.nix ./roles/gencert.nix ];

  /* Networking configuration */
  networking.hostName = "squall";
  networking.firewall.allowedTCPPorts =
    [ 80 443
    ];

  /* Users - we only need Antti here */
  users.extraUsers = { inherit ajk; };

  /* Nginx configuration */
  services.nginx.enable = true;
  services.nginx.config = httpPlusHttps
    { serverNames = "planet.haskell.org";
      config = ''
        location / {
          root /www/planet/public_html;
        }
      '';
    };
}
