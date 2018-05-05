# Advanced config for NGINX
    server_tokens off;
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options nosniff;

# Redirect all HTTP traffic to HTTPS
server {
   listen 80;
       server_name 2018.lincolnhack.org;
       return 301 https://$host$request_uri;
}

# SSL configuration
server {
   listen 443 ssl http2 default deferred;
   server_name {{domain.server_name}};
    ssl_certificate      /etc/pki/tls/certs/fullchain.cer;
  ssl_certificate_key  /etc/pki/tls/private/{{domain.server_name}}.key;

      # Improve HTTPS performance with session resumption
      ssl_session_cache shared:SSL:10m;
      ssl_session_timeout 5m;

    # Enable server-side protection against BEAST attacks
      ssl_prefer_server_ciphers on;
    ssl_ciphers ECDH+AESGCM:ECDH+AES256:ECDH+AES128:DH+3DES:!ADH:!AECDH:!MD5;

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

# Required for LE certificate enrollment using certbot
   location '/.well-known/acme-challenge' {
    default_type "text/plain";
    root /usr/share/nginx/html/;
   }
   location / {
    root /usr/share/nginx/html/;
   }
}
