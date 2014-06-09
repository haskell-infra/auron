/** barret - hackage-build configuration
 *
 * "Who you callin' Mr. Barret? That don't sound right!"
 *    - Barret Wallace, Final Fantasy VII
 */
{ config, pkgs, resources, lib, ... }:

with builtins;

{
  require = [ ./common.nix ];

  /* Networking configuration */
  networking.hostName = "barret";
  networking.firewall.allowedTCPPorts =
    [ 80 9000
    ];
}
