/** rikku - phabricator configuration
 *
 * "You can cram your happy festival, you big meanie!"
 *    - Rikku, Final Fantasy X
 */
{ config, pkgs, resources, lib, ... }:

with lib;
with builtins;
with import ./nginx.nix { inherit lib; };

{
  require = [ ./common.nix ./duosec.nix ];

  /* Networking configuration */
  networking.hostName = "rikku";
  networking.firewall.allowedTCPPorts =
    [ 80 443
    ];

  /* Spiped backend for MariaDB */
  services.spiped.enable = true;
  services.spiped.config = {
    mysql =
      { keyfile = "/var/lib/spiped/mysql.key";
        encrypt = true;
        source  = "0.0.0.0:3306";
        target  = "mysql01:9000";
      };
  };

  /* Nginx configuration */
  services.nginx.enable = true;
  services.nginx.config = httpsOnly
    { serverNames = "phabricator.haskell.org phabricator-files.haskell.org";
      hsts       = false;
      xframeDeny = false;
      config = ''
        root /opt/phabricator/webroot;

        location / {
          index index.php;
          rewrite ^/(.*)$ /index.php?__path__=/$1 last;
        }

        location = /favicon.ico {
          try_files $uri =204;
        }

        location /index.php {
          fastcgi_pass    unix:/var/run/php5-fpm.sock;
          fastcgi_index   index.php;

          #required if PHP was built with --enable-force-cgi-redirect
          fastcgi_param  REDIRECT_STATUS    200;
          #variables to make the $_SERVER populate in PHP
          fastcgi_param  SCRIPT_FILENAME    $document_root$fastcgi_script_name;
          fastcgi_param  QUERY_STRING       $query_string;
          fastcgi_param  REQUEST_METHOD     $request_method;
          fastcgi_param  CONTENT_TYPE       $content_type;
          fastcgi_param  CONTENT_LENGTH     $content_length;
          fastcgi_param  SCRIPT_NAME        $fastcgi_script_name;
          fastcgi_param  GATEWAY_INTERFACE  CGI/1.1;
          fastcgi_param  SERVER_SOFTWARE    nginx/$nginx_version;
          fastcgi_param  REMOTE_ADDR        $remote_addr;
        }
      '';
    };
}
