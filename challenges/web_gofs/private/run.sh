#!/bin/sh

set -ex

cp -f ./flag.txt ./private/tmp/flag

docker-compose -p web_gofs -f private/docker-compose.yml rm --force --stop
docker-compose -p web_gofs -f private/docker-compose.yml build
docker-compose -p web_gofs -f private/docker-compose.yml up -d
