/** rinoa - darcs server configuration
 *
 * "You're still a teenager. Why don't you act like one for a change?"
 *    - Rinoa Heartilly, Final Fantasy VIII
 */
{ config, pkgs, resources, lib, ... }:

with builtins;
with import ./nginx.nix;
with import ../res/users.nix { inherit lib; };

{
  require = [ ./common.nix ./duosec.nix ];

  /* Networking configuration */
  networking.hostName = "rinoa";
  networking.firewall.allowedTCPPorts =
    [ 80 443
    ];

  /* Users - we really only need Malcolm here */
  users.extraUsers = { inherit malcolm; };

  /* Nginx configuration */
  services.nginx.enable = true;
  services.nginx.config = nginxHTTPServer ''
    server {
      server_name darcs.haskell.org;
      listen [::]:80 default_server ipv6only=off;
      listen [::]:443 default_server ssl spdy ipv6only=off;

      ssl_certificate     /etc/ssl/certs/haskell.org.crt;
      ssl_certificate_key /etc/ssl/private/haskell.org.key;
      ssl_trusted_certificate /etc/ssl/certs/haskell.org.crt;
      ${defaultNginxSSLServerOpts}

      # legacy Git redirects (known to work for Git 1.7.3.4 and later)
      rewrite ^/(ghc|ghc-tarballs|haddock|hsc2hs|libffi-tarballs|nofib|testsuite)\.git(/.*)?$   $scheme://git.haskell.org/$1.git$2 permanent;
      rewrite ^/packages/([0-9A-Za-z-.]*)\.git(/.*)?$                                           $scheme://git.haskell.org/packages/$1.git$2 permanent;
      rewrite ^/libraries/([0-9A-Za-z-.]*)\.git(/.*)?$                                          $scheme://git.haskell.org/packages/$1.git$2 permanent;

      # serving /home/darcs/
      index index.html index.htm;
      root /home/darcs;

      # datadog stats
      location /nginx_status {
        stub_status     on;
        access_log      off;
        allow           127.0.0.1;
        deny            all;
      }

      location / {
        autoindex on;
        try_files $uri $uri/ =404;
      }
    }
  '';
}
