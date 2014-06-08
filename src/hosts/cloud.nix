/** cloud - ghc/git configuration
 *
 * "You look like a bear wearing a marshmallow."
 *    - Cloud Strife, FFVII
 */
{ config, pkgs, resources, lib, ... }:

with builtins;

{
  require = [ ./common.nix ./duosec.nix ];

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
