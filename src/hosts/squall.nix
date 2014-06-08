/** squall - planet/venus configuration
 *
 * "... Whatever."
 *    - Squall Leonhart, Final Fantasy VIII
 */
{ config, pkgs, resources, lib, ... }:

with builtins;
with import ./nginx.nix;
with import ../res/users.nix { inherit lib; };

{
  require = [ ./common.nix ./duosec.nix ];

  /* Networking configuration */
  networking.hostName = "squall";
  networking.firewall.allowedTCPPorts =
    [ 80 443
    ];

  /* Users - we only need Antti here */
  users.extraUsers = { inherit ajk; };

  /* Nginx configuration */
  services.nginx.enable = true;
  services.nginx.config = nginxHTTPServer ''
    server {
      server_name planet.haskell.org;
      listen [::]:80 default_server ipv6only=off;
      listen [::]:443 default_server ssl spdy ipv6only=off;
      ${httpStatusOpts}
      ${tlsServerOpts}

      location / {
        root /www/planet/public_html;
      }
    }
  '';
}
