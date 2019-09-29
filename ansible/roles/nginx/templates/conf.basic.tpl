

# Redirect all HTTP traffic to HTTPS
server {
   listen 80;
       server_name 2018.lincolnhack.org lincolnhack.org www.lincolnhack.org;
       
      # Required for LE certificate enrollment using certbot
         location '/.well-known/acme-challenge' {
          default_type "text/plain";
          
         }
         location / {
          try_files $uri $uri/ /index.php?$query_string;
         }
}
