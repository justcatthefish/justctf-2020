#!/bin/sh

cp -f ./flag.txt ./private/flag.txt
docker-compose -p crypto_25519 -f private/docker-compose.yml rm --force --stop
docker-compose -p crypto_25519 -f private/docker-compose.yml build
docker-compose -p crypto_25519 -f private/docker-compose.yml up -d
