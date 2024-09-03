#!/bin/sh

rm -rf /tmp/misc_tf2/;
mkdir -p /tmp/misc_tf2/;
chmod 777 /tmp/misc_tf2/;
cp -f ./flag.txt /tmp/misc_tf2/flag.txt

docker-compose -p misc_tf2 -f private/docker-compose.yml rm --force --stop
docker-compose -p misc_tf2 -f private/docker-compose.yml build
docker-compose -p misc_tf2 -f private/docker-compose.yml up -d
