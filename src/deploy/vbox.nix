let
  vbox = { config, pkgs, ... }:
    { deployment.targetEnv = "virtualbox";
      deployment.virtualbox.memorySize = 1024;
      deployment.virtualbox.headless = true;
    };
in
{
  network.description = "Haskell.org (VirtualBox)";

  planet        = vbox;
  mysql01       = vbox;
  wiki          = vbox;
  phabricator   = vbox;
  darcs         = vbox;
  ghc           = vbox;
  www           = vbox;
  hackage       = vbox;
  monitor       = vbox;
  hackage-build = vbox;
  community     = vbox;
  mail          = vbox;
  phab-ghc01    = vbox;
  try           = vbox;
}
