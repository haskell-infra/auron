/** cid - main website configuration
 *
 * "I know how tough it is bein' a leader, because I've been one. I
 *  always forget who has what materia."
 *    - Cid Highwind, Final Fantasy VII
 */
{ config, pkgs, resources, lib, ... }:

with builtins;
with import ./roles/nginx.nix { inherit lib; };

{
  require = [ ./roles/common.nix ./roles/gencert.nix ];

  /* Networking configuration */
  networking.hostName = "cid";
  networking.firewall.allowedTCPPorts =
    [ 80 443
    ];

  /* Nginx configuration */
  services.nginx.enable = true;
  services.nginx.config = httpPlusHttps
    { serverNames = "haskell.org www.haskell.org";
      config = ''
        location / {
        }
      '';
    };
}
