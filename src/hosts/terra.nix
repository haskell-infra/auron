/** terra - hackage server configuration
 *
 * "You love this ship, more than anything, huh?"
 *    - Terra Branford, Final Fantasy VI
 */
{ config, pkgs, resources, lib, ... }:

with builtins;

{
  require = [ ./common.nix ./duosec.nix ];
  networking.hostName = "terra";
}
