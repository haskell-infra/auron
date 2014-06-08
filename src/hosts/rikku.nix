/** rikku - phabricator configuration
 *
 * "You can cram your happy festival, you big meanie!"
 *    - Rikku, FFX
 */
{ config, pkgs, resources, lib, ... }:

with builtins;

{
  require = [ ./common.nix ./duosec.nix ];
  networking.hostName = "rikku";
}
