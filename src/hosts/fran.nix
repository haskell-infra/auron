/** fran - mail server configuration
 *
 * "That's what sky pirates do, they fly do they not?"
 *    - Fran, Final Fantasy XII
 */
{ config, pkgs, resources, lib, ... }:

with builtins;

{
  require = [ ./common.nix ];

  /* Networking configuration */
  networking.hostName = "fran";
  networking.firewall.allowedTCPPorts =
    [ 80 9000
    ];
}
