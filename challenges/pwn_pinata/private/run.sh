#!/bin/sh

rm -rf /tmp/pwn_pinata/;
mkdir -p /tmp/pwn_pinata/;
chmod 777 /tmp/pwn_pinata/;

cp -f ./flag.txt /tmp/pwn_pinata/flag.txt

docker load -i ./private/sandboxtask/8npr413lc26qjfa4yhky80z1a7if8qwf-docker-image-pinata.tar.gz
docker tag pinata:8npr413lc26qjfa4yhky80z1a7if8qwf sandboxtask_pwn_pinata

docker-compose -p pwn_pinata -f private/docker-compose.yml rm --force --stop
docker-compose -p pwn_pinata -f private/docker-compose.yml build
docker-compose -p pwn_pinata -f private/docker-compose.yml up -d
