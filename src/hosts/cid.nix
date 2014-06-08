/** cid - main website configuration
 *
 * "I know how tough it is bein' a leader, because I've been one. I
 *  always forget who has what materia."
 *    - Cid Highwind, FFVII
 */
{ config, pkgs, resources, lib, ... }:

with builtins;

{
  require = [ ./common.nix ./duosec.nix ];
  networking.hostName = "cid";
}
