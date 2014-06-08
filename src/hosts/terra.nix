/** terra - hackage server configuration
 *
 * "You love this ship, more than anything, huh?"
 *    - Terra Branford, Final Fantasy VI
 */
{ config, pkgs, resources, lib, ... }:

with builtins;

{
  require = [ ./common.nix ./duosec.nix ];

  /* Networking configuration */
  networking.hostName = "terra";
  networking.firewall.allowedTCPPorts =
    [ 80 443
    ];

  /* Nginx configuration */
  services.nginx.enable = true;
  services.nginx.config = httpPlusHttps
    { serverNames = "hackage.haskell.org";

      upstreams = ''
        upstream hackage { server 127.0.0.1:8081; }
      '';

      extraHttpConfig = ''
        # Zone to rate-limit badly behaved mirror clients
        #geo $badmirrorclient_ip {
        #    default         1;
        #    54.220.210.149  0;
        #}
        #map $badmirrorclient_ip $badmirrorclient_ip_key {
        #    0 '';
        #    1 $binary_remote_addr;
        #}
        #limit_req_zone $badmirrorclient_ip_key
        #                 zone=badmirror:50k rate=1r/m;
      '';

      config = let
        proxyOpts = ''
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header Host $http_host;
          proxy_redirect off;
          proxy_buffering off;
          proxy_pass http://hackage;
        '';
      in ''
        # Redirects
        location /trac/ghc
          { return 301 $scheme://ghc.haskell.org$request_uri; }
        location /trac/haskell-prime
          { return 301 $scheme://ghc.haskell.org$request_uri; }
        location /trac/summer-of-code
          { return 301 $scheme://ghc.haskell.org$request_uri; }
        location /trac/gtk2hs
          { return 301 $scheme://trac.haskell.org/gtk2hs; }
        location /platform
          { return 301 $scheme://www.haskell.org/platform; }

        # Ensure uploads aren't *too* gigantic
        client_max_body_size 50m;

        # Restrict access to Hackage metrics
        location /server-status {
          access_log      off;
          allow           127.0.0.1;
          deny            all;
          ${proxyOpts}
        }

        # Rate-limit badly behaved mirror clients
        #location /packages/00-index.tar.gz {
        #  limit_req zone=badmirror burst=1;
        #}

        # Main proxy setup
        location / {
          ${proxyOpts}
        }
      '';
    };
}
