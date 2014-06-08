/** vivi - mysql01 configuration
 *
 * "Oh, nothing... My face is always like this."
 *    - Vivi Ornitier, Final Fantasy IX
 */
{ config, pkgs, resources, lib, ... }:

with builtins;

{
  require = [ ./common.nix ./duosec.nix ];
  networking.hostName = "vivi";
}
