{ config, pkgs, resources, lib, ... }:

{
  services.tarsnap.enable = false; # true;
  services.tarsnap.config =
    { nixos =
        { directories = [ "/home" "/root" ];
        };
    };
}
