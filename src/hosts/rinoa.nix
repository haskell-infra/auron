/** rinoa - darcs server configuration
 *
 * "You're still a teenager. Why don't you act like one for a change?"
 *    - Rinoa Heartilly, Final Fantasy VIII
 */
{ config, pkgs, resources, lib, ... }:

with builtins;

{
  require = [ ./common.nix ./duosec.nix ];
  networking.hostName = "rinoa";
}
