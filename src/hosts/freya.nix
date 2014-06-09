/** freya - community.haskell.org
 *
 * "Beware, the answer you seek may forever change your life for the worse."
 *    - Freya Crescent, Final Fantasy IX
 */
{ config, pkgs, resources, lib, ... }:

with builtins;

{
  require = [ ./common.nix ];

  /* Networking configuration */
  networking.hostName = "freya";
  networking.firewall.allowedTCPPorts =
    [ 80 9000
    ];
}
