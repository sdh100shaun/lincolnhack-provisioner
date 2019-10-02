# Advanced config for NGINX
    server_tokens off;
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options nosniff;

# Redirect all HTTP traffic to HTTPS
server {
   listen 80;
       server_name {{domain.server_name}} lincolnhack.org www.lincolnhack.org;
       return 301 https://{{domain.server_name}}$request_uri;
}

# SSL configuration
server {
   listen 443 ssl http2 default deferred;
   listen [::]:443 ssl http2;

   server_name {{domain.server_name}};
   root /home/lincolnhack/current/public;
   index index.php;
    ssl_certificate      /etc/pki/tls/certs/fullchain.cer;
  ssl_certificate_key  /etc/pki/tls/private/{{domain.server_name}}.key;

      # Improve HTTPS performance with session resumption
      ssl_session_cache shared:SSL:10m;
      ssl_session_timeout 5m;

    # Enable server-side protection against BEAST attacks
      ssl_prefer_server_ciphers on;
  #  ssl_ciphers ECDH+AESGCM:ECDH+AES256:ECDH+AES128:DH+3DES:!ADH:!AECDH:!MD5;
  ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384;
  ssl_ecdh_curve secp384r1;

      # Disable SSLv3
      ssl_protocols TLSv1 TLSv1.1 TLSv1.2;

        # Diffie-Hellman parameter for DHE ciphersuites
        # $ sudo openssl dhparam -out /etc/pki/tls/certs/dhparam.pem 4096
        ssl_dhparam /etc/pki/tls/certs/dhparam.pem;

    # Enable HSTS (https://developer.mozilla.org/en-US/docs/Security/HTTP_Strict_Transport_Security)
    add_header Strict-Transport-Security "max-age=63072000; includeSubdomains";

      # Enable OCSP stapling (http://blog.mozilla.org/security/2013/07/29/ocsp-stapling-in-firefox)
      ssl_stapling on;
      ssl_stapling_verify on;
      ssl_trusted_certificate /etc/pki/tls/certs/fullchain.cer;
      resolver 8.8.8.8 8.8.4.4 valid=300s;
      resolver_timeout 5s;

      # Media: images, icons, video, audio, HTC
      location ~* \.(?:jpg|jpeg|gif|png|ico|cur|gz|svg|svgz|mp4|ogg|ogv|webm|htc)$ {
        expires 1M;
        access_log off;
        add_header Cache-Control "public";
        send_timeout 100m;
        sendfile  on;
        sendfile_max_chunk  1m;
        tcp_nopush          on;
        tcp_nodelay         on;
      }

      location ~ /js/|/css/ {
          access_log          off;
          log_not_found       off;
          server_tokens       off;
          autoindex           off;
          sendfile            on;
          sendfile_max_chunk  1m;
          tcp_nopush          on;
          tcp_nodelay         on;
          keepalive_timeout   65;
          add_header          Cache-Control public;
          gzip_static         on;
          gzip_min_length     1000;
          gzip_comp_level     2;
          expires             max;
          fastcgi_hide_header Set-Cookie;
          root /home/lincolnhack/current/public/;
      }
      # Required for LE certificate enrollment using certbot
         location '/.well-known/acme-challenge' {
          default_type "text/plain";
          root /usr/share/nginx/html/;
         }
         location / {
          try_files $uri $uri/ /index.php?$query_string;
         }

         location ~ /\.ht {
                         deny all;
         }
         location ~ \.php$ {

              try_files $uri =404;
              fastcgi_split_path_info ^(.+\.php)(/.+)$;
              fastcgi_pass 127.0.0.1:9000;
              fastcgi_index index.php;
              fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
              include fastcgi_params;
          }
}
