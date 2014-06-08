/** cloud - ghc/git configuration
 *
 * "You look like a bear wearing a marshmallow."
 *    - Cloud, FFVII
 */
{ config, pkgs, resources, lib, ... }:

with builtins;

{
  require = [ ./common.nix ./duosec.nix ];
  networking.hostName = "cloud";
}
