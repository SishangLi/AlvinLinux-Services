#!/bin/bash

# Author：Alvinlee
# function: Create https creatification and deploy v2ray and nginx!
# creat-ssl.sh www.vultr.com xxx@gmail.com host(bridge) /pathtov2ray

set -e

if [ $# -eq 0 ]; then
	echo "Please add your domain and email, using like \"creat-ssl.sh www.vultr.com xxx@gmail.com host(bridge)\""
    exit
fi

domain=$1
email=$2
mode=$3
path=$4

echo -e "\nYour domian is: $domain!\n\nYour emain is: $email!"

ping -c1 $domain &>/dev/null && echo -e "\nYour domain is valid!" || echo -e "\nYour domain \"$domain\" is invalid.Please cheak it!"

line1="\    server_name "$domain";"
line2="\                root /var/www/html/"$domain"/;"
line3="\          \"Host\": \"$domain\""
line4="\    ssl_certificate /etc/nginx/letsencrypt/live/"$domain"/fullchain.pem;"
line5="\    ssl_certificate_key /etc/nginx/letsencrypt/live/"$domain"/privkey.pem;"
echo -e "\nModify nginx and v2ray conf !" \
    && sed -in "/server_name /c$line1" ./nginx/conf/default.conf \
    && sed -in "/root \/var/c$line2" ./nginx/conf/default.conf \
    && sed -in "/"Host"/c$line3" ./v2ray/config.json \
    && sed -in "/server_name /c$line1" ./nginx/conf/default.conf.https \
    && sed -in "/ssl_certificate /c$line4" ./nginx/conf/default.conf.https \
    && sed -in "/ssl_certificate_key /c$line5" ./nginx/conf/default.conf.https

if [ $mode == 'bridge' ]; then
    line6="\      proxy_pass http://container_v2ray:52020;"
    line7="\    \"listen\": \"0.0.0.0"\"
    sed -in "/proxy_pass /c$line6" ./nginx/conf/default.conf.https \
	&& sed -in "/"listen"/c$line7" ./v2ray/config.json
fi
if [ $mode == 'host' ]; then
    line6="\      proxy_pass http://127.0.0.1:52020;"
    line7="\    \"listen\": \"127.0.0.1"\"
    sed -in "/proxy_pass /c$line6" ./nginx/conf/default.conf.https \
	&& sed -in "/"listen"/c$line7" ./v2ray/config.json
fi

if [ ! -z $path ]; then
    line8="\    location "$path" {"
    line9="\        \"path\": \"$path\","
    sed -in "/location \/source/c$line8" ./nginx/conf/default.conf.https \
	&& sed -in "/"path"/c$line9" ./v2ray/config.json
fi

echo -e "\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>http conf:\n" \
    && cat ./nginx/conf/default.conf \
    && echo -e "\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>https conf:\n" \
    && cat ./nginx/conf/default.conf.https \
    && echo -e "\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>v2ray conf:\n" \
    && cat ./v2ray/config.json \

echo -e "\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Start creat https certification<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n"
if [ $mode == "bridge" ]; then
    mv docker-compose.yml.bridge docker-compose.yml \
        && echo `docker-compose -f docker-compose.yml up -d`
else
    mv docker-compose.yml.host docker-compose.yml \
        && echo `docker-compose -f docker-compose.yml up -d`
fi

docker run -it --rm --name certbot \
    -v "`pwd`/nginx/ssl/:/etc/letsencrypt/" \
    -v "`pwd`/nginx/webroot/$domain/:/var/www/html/" \
    certbot/certbot certonly -n --no-eff-email --email $email \
    --agree-tos --webroot -w /var/www/html -d $domain

echo -e "\nStop containers and load new conf\n" \
    && mv ./nginx/conf/default.conf ./nginx/conf/default.conf.http \
    && mv ./nginx/conf/default.conf.https ./nginx/conf/default.conf \
    && echo `docker-compose -f docker-compose.yml down` \
    && echo `docker-compose -f docker-compose.yml up -d` \
    && echo -e "Everything is ok, good luck!"
