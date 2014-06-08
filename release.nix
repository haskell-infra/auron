{ auron ? { outPath = ./.; revCount = 0; shortRev = "abcdef"; rev = "HEAD"; }
, officialRelease ? false
}:

let
  pkgs   = import <nixpkgs> {};

  version = builtins.readFile ./VERSION +
    (pkgs.lib.optionalString (!officialRelease)
      "-r${toString auron.revCount}-g${auron.shortRev}");

  jobs = rec {
    shell = pkgs.stdenv.mkDerivation rec {
      name = "auron-env-${version}";
      inherit version;
      src = ./.;
      buildInputs = with pkgs;
        [ php python27 arcanist nixops nix git
        ];
      shellHook = ''
        export NIXOPS_STATE=$HOME/.haskell-org.deployments.nixops
        export NIXOPS_DEPLOYMENT=haskell-vbox
        if [[ -z `nixops list | grep ec2` ]]; then
          nixops create src/network.nix src/deploy/ec2.nix -d ec2
        fi
        if [[ -z `nixops list | grep vbox` ]]; then
          nixops create src/network.nix src/deploy/vbox.nix -d vbox
        fi
        if [[ -z `nixops list | grep rackspace` ]]; then
          nixops create src/network.nix src/deploy/rackspace.nix -d rackspace
        fi
      '';
    };
  };
in jobs
