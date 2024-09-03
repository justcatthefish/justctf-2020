#!/bin/sh

rm -rf /tmp/web_njs/;
mkdir -p /tmp/web_njs/;
chmod 777 /tmp/web_njs/;

cp -f ./flag.txt ./private/sandboxtask/flag.txt

docker-compose -p web_njs -f private/docker-compose.yml rm --force --stop
docker-compose -p web_njs -f private/docker-compose.yml build
docker-compose -p web_njs -f private/docker-compose.yml up -d
