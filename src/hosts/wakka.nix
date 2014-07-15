/** wakka - phab-ghc01 builder
 *
 *  "Du-u-u-u-de! Our Team is gonna rock, ya?"
 *    - Wakka, Final Fantasy X
 */
{ config, pkgs, resources, lib, ... }:

with builtins;
with import ./roles/nginx.nix { inherit lib; };

{
  require = [ ./roles/common.nix ./roles/gencert.nix ];

  /* Networking configuration */
  networking.hostName = "wakka";
  networking.firewall.allowedTCPPorts =
    [ 80 443
    ];

}
