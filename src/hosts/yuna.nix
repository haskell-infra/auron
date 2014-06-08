/** yuna - wiki configuration
 *
 * "A lotta fiends here, ya?"
 *    - Yuna, Final Fantasy X
 */
{ config, pkgs, resources, lib, ... }:

with builtins;

{
  require = [ ./common.nix ./duosec.nix ];
  networking.hostName = "yuna";
}
