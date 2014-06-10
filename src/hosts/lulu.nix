/** lulu - monitor/nagios server configuration
 *
 * "You always said I looked grumpy, but those were the happiest days
 *  of my life."
 *    - Lulu, Final Fantasy X
 */
{ config, pkgs, resources, lib, ... }:

with builtins;
with import ./roles/nginx.nix { inherit lib; };

{
  require = [ ./roles/common.nix ./roles/gencert.nix ];

  /* Networking configuration */
  networking.hostName = "lulu";
  networking.firewall.allowedTCPPorts =
    [ 80 443
    ];

  /* Nginx configuration */
  services.nginx.enable = true;
  services.nginx.config = httpsOnly
    { serverNames = "monitor.haskell.org";
      hsts       = false;
      xframeDeny = false;

      upstreams = ''
        upstream php { server unix:/var/run/php5-fpm.socket; }
      '';

      config = ''
        root /usr/share/nginx/html/;

        location /nagios {
          auth_basic "Nagios Restricted Access (via nginx)";
          auth_basic_user_file /etc/nagios/passwd;

          alias /usr/share/nagios/html;
          index index.php;
        }

        location ~ ^/nagios/(.*\.php)$ {
          auth_basic "Nagios Restricted Access (via nginx)";
          auth_basic_user_file /etc/nagios/passwd;

          root /usr/share/nagios/html/;
          rewrite ^/nagios/(.*) /$1 break;
          fastcgi_index index.php;
          include /etc/nginx/fastcgi_params;
          fastcgi_param SCRIPT_FILENAME
            /usr/share/nagios/html$fastcgi_script_name;
          fastcgi_pass unix:/var/run/php5-fpm.socket;
        }

        location ~ \.cgi$ {
          auth_basic "Nagios Restricted Access (via nginx)";
          auth_basic_user_file /etc/nagios/passwd;

          root /usr/lib64/nagios/cgi-bin/;
          rewrite ^/nagios/cgi-bin/(.*)\.cgi /$1.cgi break;
          include /etc/nginx/fastcgi_params;
          fastcgi_param AUTH_USER $remote_user;
          fastcgi_param REMOTE_USER $remote_user;
          fastcgi_param SCRIPT_FILENAME
            /usr/lib64/nagios/cgi-bin$fastcgi_script_name;
          fastcgi_pass 127.0.0.1:8999;
        }

        location ~ \.php$ {
          include /etc/nginx/fastcgi_params;
          fastcgi_pass php;
        }
      '';
    };
}
