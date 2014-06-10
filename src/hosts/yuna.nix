/** yuna - wiki configuration
 *
 * "A lotta fiends here, ya?"
 *    - Yuna, Final Fantasy X
 */
{ config, pkgs, resources, lib, ... }:

with builtins;
with import ./roles/nginx.nix { inherit lib; };

let
  php = pkgs.php54;
  uploadLimit = "10M";

  phpIni = pkgs.runCommand "php.ini" {} ''
    cat ${php}/etc/php-recommended.ini > $out

    echo "extension=${pkgs.phpPackages.apc}/lib/php/extensions/apc.so" >> $out
    echo "apc.stat = '0'" >> $out
    substituteInPlace $out \
      --replace "upload_max_filesize = 2M" \
                "upload_max_filesize = ${uploadLimit}"
  '';
in
{
  require = [ ./roles/common.nix ./roles/gencert.nix ];

  /* Networking configuration */
  networking.hostName = "yuna";
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
    { serverNames = "wiki.haskell.org";
      hsts = false;
      xframeDeny = false;
      config = ''
        client_max_body_size ${uploadLimit};

        # Mediawiki configuration below.
        root /opt/mediawiki;
        index index.php
        charset utf-8;

        location / {
          index index.php;
          try_files $uri $uri/ @mediawiki;
        }
        location @mediawiki {
          rewrite ^/(.*)$ /index.php?title=$1&$args;
        }
        location ~ \.php5?$ {
          fastcgi_param  QUERY_STRING       $query_string;
          fastcgi_param  REQUEST_METHOD     $request_method;
          fastcgi_param  CONTENT_TYPE       $content_type;
          fastcgi_param  CONTENT_LENGTH     $content_length;
          fastcgi_param  SCRIPT_NAME        $fastcgi_script_name;
          fastcgi_param  REQUEST_URI        $request_uri;
          fastcgi_param  DOCUMENT_URI       $document_uri;
          fastcgi_param  DOCUMENT_ROOT      $document_root;
          fastcgi_param  SERVER_PROTOCOL    $server_protocol;
          fastcgi_param  HTTPS              $https if_not_empty;
          fastcgi_param  GATEWAY_INTERFACE  CGI/1.1;
          fastcgi_param  SERVER_SOFTWARE    nginx/$nginx_version;
          fastcgi_param  REMOTE_ADDR        $remote_addr;
          fastcgi_param  REMOTE_PORT        $remote_port;
          fastcgi_param  SERVER_ADDR        $server_addr;
          fastcgi_param  SERVER_PORT        $server_port;
          fastcgi_param  SERVER_NAME        $server_name;
          # PHP only, required if PHP was built with --enable-force-cgi-redirect
          fastcgi_param  REDIRECT_STATUS    200;

          fastcgi_pass unix:/run/phpfpm/mediawiki.sock;
        }
        location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
          try_files $uri /index.php;
          expires max;
          log_not_found off;
        }
        # Restrictions based on the .htaccess files
        location ^~ ^/(cache|includes|maintenance|languages|serialized|tests|images/deleted)/ {
          deny all;
        }
        location ^~ ^/(bin|docs|extensions|includes|maintenance|mw-config|resources|serialized|tests)/ {
           internal;
        }
        location ^~ /images/ {
          try_files $uri /index.php;
        }
        location ~ /\. {
          access_log off;
          log_not_found off;
          deny all;
        }
      '';
    };

  systemd.services.phpfpm.environment = { PHPRC = phpIni; };
  services.phpfpm.phpPackage = php;
  services.phpfpm.poolConfigs =
    { phabricator = ''
        listen = /run/phpfpm/mediawiki.sock
        user = nginx
        pm = dynamic
        pm.max_children = 75
        pm.start_servers = 10
        pm.min_spare_servers = 5
        pm.max_spare_servers = 20
        pm.max_requests = 500
      '';
    };

  environment.systemPackages = [ php ];
}
