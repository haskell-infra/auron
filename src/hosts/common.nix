{ config, pkgs, lib, ... }:

with lib;
with builtins;
with import ../res/users.nix { inherit lib; };
with import ../res/groups.nix;

let
  gencert = import ../pkgs/gencert.nix;
in
{
  imports = [ ./roles/datadog.nix
              ./roles/duosec.nix
              ./roles/tarsnap.nix
            ];
  nixpkgs.config.allowUnfree = true;

  # -- Networking
  networking.firewall.enable        = true;
  networking.firewall.rejectPackets = true;
  networking.firewall.allowPing     = true;
  networking.firewall.allowedTCPPorts =
    [ 22 # SSH
    ];
  networking.firewall.allowedUDPPortRanges =
    [ { from = 60000; to = 61000; } # Mosh port ranges
    ];

  # -- Services
  services.printing.enable = false;
  services.xserver.enable  = false;
  services.sshd.enable = true;
  time.timeZone = "America/Chicago";

  # -- Users
  users.mutableUsers       = false;
  users.extraUsers         = admins; /* or: admins // { inherit testrix; }; */
  users.extraGroups.duosec = duosec;

  # -- Nix options
  nix = {
    gc.automatic = true;
    nrBuildUsers = 100;
    useChroot    = true;
    extraOptions = ''
      build-cores = 0
      auto-optimise-store = true
      extra-binary-caches = http://hydra.nixos.org
    '';
  };

  # -- Environment options
  environment.systemPackages = with pkgs;
    [ emacs24-nox vim subversion git darcs sqlite gcc htop mosh spiped tmux
      silver-searcher reptyr nmap ssdeep gdb python27 lsof scrypt

      # Custom packages
      gencert
    ];
}
