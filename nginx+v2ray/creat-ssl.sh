#!/bin/bash
set -e

domain="hbq.supermarvel.top"
email="lisishang@mail.com"

docker run -it --rm --name certbot \
    -v "`pwd`/nginx/ssl/:/etc/letsencrypt/" \
    -v "`pwd`/nginx/webroot/$domain/:/var/www/html/" \
    certbot/certbot certonly -n --no-eff-email --email $email \
    --agree-tos --webroot -w /var/www/html -d $domain

