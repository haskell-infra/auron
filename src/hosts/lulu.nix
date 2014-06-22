/** lulu - monitor/nagios server configuration
 *
 * "You always said I looked grumpy, but those were the happiest days
 *  of my life."
 *    - Lulu, Final Fantasy X
 */
{ config, pkgs, resources, lib, ... }:

with builtins;
with import ./roles/nginx.nix { inherit lib; };

let
  nagiosCGICfgFile = pkgs.writeText "nagios.cgi.conf"
    ''
      main_config_file=/etc/nagios.cfg
      use_authentication=0
      url_html_path=/nagios
    '';
in
{
  require = [ ./roles/common.nix
              ./roles/gencert.nix
              ./roles/nagios.nix ];

  /* Networking configuration */
  networking.hostName = "lulu";
  networking.firewall.allowedTCPPorts =
    [ 80 443
    ];

  services.fcgiwrap.enable = true;
  services.fcgiwrap.bindSocket = "tcp:127.0.0.1:8999";

  /* Nginx configuration */
  services.nginx.enable = true;
  services.nginx.config = httpsOnly
    { serverNames = "monitor.haskell.org monitor";
      hsts       = false;
      xframeDeny = false;

      config = ''
        root ${pkgs.nagios}/share;

        location /nagios {
          #auth_basic "Nagios Restricted Access (via nginx)";
          #auth_basic_user_file /etc/nagios/passwd;

          alias ${pkgs.nagios}/share;
          index index.php;
        }

        location ~ ^/nagios/(.*\.php)$ {
          #auth_basic "Nagios Restricted Access (via nginx)";
          #auth_basic_user_file /etc/nagios/passwd;

          root ${pkgs.nagios}/share;
          rewrite ^/nagios/(.*) /$1 break;
          fastcgi_index index.php;
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
          fastcgi_pass   unix:/run/phpfpm/nagios.sock;
        }

        location ~ \.cgi$ {
          #auth_basic "Nagios Restricted Access (via nginx)";
          #auth_basic_user_file /etc/nagios/passwd;

          root ${pkgs.nagios}/sbin;
          rewrite ^/nagios/cgi-bin/(.*)\.cgi /$1.cgi break;
          #required if PHP was built with --enable-force-cgi-redirect
          fastcgi_param  REDIRECT_STATUS    200;
          fastcgi_param  NAGIOS_CGI_CONFIG ${nagiosCGICfgFile};
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
          fastcgi_pass 127.0.0.1:8999;
        }

        location ~ \.php$ {
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
          fastcgi_pass   unix:/run/phpfpm/nagios.sock;
        }
      '';
    };
}
