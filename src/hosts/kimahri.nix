/** kimahri - tryhaskell setup
 *
 * "Only those who try will become."
 *    - Kimahri Ronso, Final Fantasy X
 */
{ config, pkgs, resources, lib, ... }:

with builtins;
with import ./roles/nginx.nix { inherit lib; };

{
  require = [ ./roles/common.nix ./roles/gencert.nix ];

  /* Networking configuration */
  networking.hostName = "kimahri";
  networking.firewall.allowedTCPPorts =
    [ 80 443
    ];

  /* Nginx configuration */
  services.nginx.enable = true;
  services.nginx.config = httpPlusHttps
    { serverNames = "try.haskell.org";
      config = ''
        location / {
        }
      '';
    };
}
