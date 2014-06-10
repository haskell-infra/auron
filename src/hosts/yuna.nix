/** yuna - wiki configuration
 *
 * "A lotta fiends here, ya?"
 *    - Yuna, Final Fantasy X
 */
{ config, pkgs, resources, lib, ... }:

with builtins;
with import ./roles/nginx.nix { inherit lib; };

let
  uploadLimit = "10M";

  fcgiParams = ''
    try_files $uri =404;
    fastcgi_intercept_errors on;
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
    fastcgi_param  REDIRECT_STATUS    200;
    fastcgi_pass unix:/run/hhvm/hhvm.sock;
  '';
in
{
  require = [ ./roles/common.nix ./roles/gencert.nix
              ../modules/hhvm.nix
            ];

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

  /* HHVM FastCGI server */
  services.hhvm.enable = true;
  services.hhvm.uploadLimit = uploadLimit;

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
        autoindex off;
        index index.php
        charset utf-8;

        # Uncomment after installation
        #location / {
        #  index index.php;
        #  try_files $uri $uri/ @mediawiki;
        #}

        location ~ \.php5?$ { ${fcgiParams} }
        location ~ \.php?$  { ${fcgiParams} }

        # -- Common deny, drop, or internal locations

        # Exclude all access from the cache directory
        location ^~ /cache/ { deny all; }

        # Prevent access to any files starting with a dot, like
        # .htaccess or text editor temp files
        location ~ /\. { access_log off; log_not_found off; deny all; }

        # Prevent access to any files starting with a $ (usually
        # temp files)
        location ~ ~$ { access_log off; log_not_found off; deny all; }

        # Do not log access to robots.txt, to keep the logs cleaner
        location = /robots.txt { access_log off; log_not_found off; }

        # Do not log access to the favicon, to keep the logs cleaner
        location = /favicon.ico { access_log off; log_not_found off; }

        # Keep images and CSS around in browser cache for as long as
        # possible, to cut down on server load
        location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
          try_files $uri /index.php;
          expires max;
          log_not_found off;
        }

        # Mark all of these directories as "internal", which means
        # that they cannot be explicitly accessed by
        # clients. However, the web server can still use and serve
        # the files inside of them. This keeps people from poking
        # around in the wiki's internals.
        location ^~ /bin/ { internal; }
        location ^~ /docs/ { internal; }
        location ^~ /extensions/ { internal; }
        location ^~ /includes/ { internal; }
        location ^~ /maintenance/ { internal; }
        #location ^~ /mw-config/ { internal; } # Uncomment after installation
        location ^~ /resources/ { internal; }
        location ^~ /serialized/ { internal; }
        location ^~ /tests/ { internal; }

        # Force potentially-malicious files in the /images directory
        # to be served with a text/plain mime type, to prevent them
        # from being executed by the PHP handler
        location ~* ^/images/.*.(html|htm|shtml|php)$ {
          types { }
          default_type text/plain;
        }

        # Redirect all requests for unknown URLs out of images and
        # back to the root index.php file
        location ^~ /images/ {
          try_files $uri /index.php;
        }
      '';
    };
  environment.systemPackages = [ pkgs.hhvm pkgs.diffutils pkgs.git ];
}
