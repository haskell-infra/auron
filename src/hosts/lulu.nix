/** lulu - monitor/nagios server configuration
 *
 * "You always said I looked grumpy, but those were the happiest days
 *  of my life."
 *    - Lulu, FFX
 */
{ config, pkgs, resources, lib, ... }:

with builtins;

{
  require = [ ./common.nix ./duosec.nix ];
  networking.hostName = "lulu";
}
