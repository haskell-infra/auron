/** rinoa - darcs server configuration
 *
 * "You're still a teenager. Why don't you act like one for a change?"
 *    - Rinoa Heartilly, Final Fantasy VIII
 */
{ config, pkgs, resources, lib, ... }:

with builtins;
with import ./roles/nginx.nix;
with import ../res/users.nix { inherit lib; };

{
  require = [ ./common.nix ./roles/gencert.nix ];

  /* Networking configuration */
  networking.hostName = "rinoa";
  networking.firewall.allowedTCPPorts =
    [ 80 443
    ];

  /* Users - we only need Malcolm here */
  users.extraUsers = { inherit malcolm; };

  /* Nginx configuration */
  services.nginx.enable = true;
  services.nginx.config = httpPlusHttps
    { serverNames = "darcs.haskell.org";
      config = ''
        # legacy Git redirects (known to work for Git 1.7.3.4 and later)
        rewrite ^/(ghc|ghc-tarballs|haddock|hsc2hs|libffi-tarballs|nofib|testsuite)\.git(/.*)?$   $scheme://git.haskell.org/$1.git$2 permanent;
        rewrite ^/packages/([0-9A-Za-z-.]*)\.git(/.*)?$                                           $scheme://git.haskell.org/packages/$1.git$2 permanent;
        rewrite ^/libraries/([0-9A-Za-z-.]*)\.git(/.*)?$                                          $scheme://git.haskell.org/packages/$1.git$2 permanent;

        # serving /home/darcs/
        index index.html index.htm;
        root /home/darcs;

        location / {
          autoindex on;
          try_files $uri $uri/ =404;
        }
      '';
    };
}
