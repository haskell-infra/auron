/** squall - planet/venus configuration
 *
 * "... Whatever."
 *    - Squall Leonhart, Final Fantasy VIII
 */
{ config, pkgs, resources, lib, ... }:

with builtins;

{
  require = [ ./common.nix ./duosec.nix ];
  networking.hostName = "squall";
}
