/** cloud - ghc/git configuration
 *
 * "You look like a bear wearing a marshmallow."
 *    - Cloud Strife, Final Fantasy VII
 */
{ config, pkgs, resources, lib, ... }:

with builtins;
with import ./roles/nginx.nix { inherit lib; };

{
  require = [ ./roles/common.nix ./roles/gencert.nix ];

  /* Networking configuration */
  networking.hostName = "cloud";
  networking.firewall.allowedTCPPorts =
    [ 80 443
    ];

  /* Nginx configuration */
  services.nginx.enable = true;
  services.nginx.config = httpPlusHttps
    { serverNames = "git.haskell.org ghc.haskell.org";
      config = ''
        location / {
        }
      '';
    };
}
