{ lib, ... }:

with lib;

rec {
  /**
   * Default nginx HTTP server block
   */
  nginxHTTPServer = content: ''
    events { worker_connections  1024; }
    worker_processes  1;
    error_log  logs/error.log;
    pid        logs/nginx.pid;

    http {
      log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

      access_log  logs/access.log  main;

      sendfile       on;
      tcp_nopush     on;
      tcp_nodelay    off;
      keepalive_timeout  65;

      gzip              on;
      gzip_vary         on;
      gzip_http_version 1.1;
      gzip_comp_level   2;
      gzip_proxied      any;
      gzip_types text/plain text/css application/x-javascript
        text/xml application/xml application/xml+rss text/javascript;

      ${content}
    }
  '';

  /**
   * Default TLS options for high security, OCSP stapling, etc.
   * See:
   *  - https://phabricator.haskell.org/T9
   *  - https://wiki.mozilla.org/Security/Server_Side_TLS
   */
  tlsServerOpts = ''
    ssl_certificate         /root/ssl/haskell.org.crt;
    ssl_trusted_certificate /root/ssl/haskell.org.crt;
    ssl_certificate_key     /root/ssl/haskell.org.key;

    resolver 8.8.8.8;
    ssl_stapling on;
    ssl_stapling_verify on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 5m;
    ssl_protocols TLSv1.2 TLSv1.1 TLSv1;
    ssl_prefer_server_ciphers on;

    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:ECDHE-RSA-RC4-SHA:ECDHE-ECDSA-RC4-SHA:AES128:AES256:RC4-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!3DES:!MD5:!PSK;
  '';

  /**
   * nginx statistics for localhost - needed for Datadog.
   */
  httpStatusOpts = ''
    location /nginx_status {
      stub_status     on;
      access_log      off;
      allow           127.0.0.1;
      deny            all;
    }
  '';

  httpPlusHttps = opts: nginxHTTPServer ''
    ${optionalString (opts ? upstreams) (getAttr "upstreams" opts)}
    ${optionalString (opts ? extraHttpConfig) (getAttr "extraHttpConfig" opts)}
    server {
      server_name ${opts.serverNames};
      listen [::]:80 default_server ipv6only=off;
      listen [::]:443 default_server ssl spdy ipv6only=off;
      ${httpStatusOpts}
      ${tlsServerOpts}

      ${opts.config}
    }
  '';

  /**
   * Creates an HTTPS only site configuration.
   */
  httpsOnly = opts: nginxHTTPServer ''
    ${optionalString (opts ? upstreams) (getAttr "upstreams" opts)}
    ${optionalString (opts ? extraHttpConfig) (getAttr "extraHttpConfig" opts)}
    server {
      server_name ${opts.serverNames};
      listen [::]:80 default_server ipv6only=off;
      ${httpStatusOpts}

      location / {
        return 302 https://$host$request_uri;
      }
    }

    server {
      server_name ${opts.serverNames};
      listen [::]:443 default_server ssl spdy ipv6only=off;
      ${tlsServerOpts}

      ${optionalString opts.hsts ''
        add_header Strict-Transport-Security "max-age=31536000";
      ''}
      ${optionalString opts.xframeDeny ''
        add_header X-Frame-Options DENY;
      ''}

      ${opts.config}
    }
  '';
}
