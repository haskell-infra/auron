/* Top-level catalog of Haskell.org servers.
 *
 * Note: if you update this, you MUST update the deployment
 * expressions under ./src/deploy/*.nix
 */
{
  planet      = import ./hosts/squall.nix;
  mysql01     = import ./hosts/vivi.nix;
  wiki        = import ./hosts/yuna.nix;
  phabricator = import ./hosts/rikku.nix;
  darcs       = import ./hosts/rinoa.nix;
  ghc         = import ./hosts/cloud.nix;
  www         = import ./hosts/cid.nix;
  hackage     = import ./hosts/terra.nix;
  monitor     = import ./hosts/lulu.nix;
}
