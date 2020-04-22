#!/bin/bash
set -e

if [ $# -eq 0 ]; then
    echo "Please add your domain and email, using like \"recreat-ssl.sh www.vultr.com xxx@gmail.com\""
    exit
fi

domain=$1
email=$2

docker run -it --rm --name certbot \
    -v "`pwd`/nginx/ssl/:/etc/letsencrypt/" \
    -v "`pwd`/nginx/webroot/$domain/:/var/www/html/" \
    certbot/certbot certonly -n --no-eff-email --email $email \
    --agree-tos --webroot -w /var/www/html -d $domain \
    && echo `docker-compose -f docker-compose.yml down` \
    && echo `docker-compose -f docker-compose.yml up -d`

