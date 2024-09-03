#!/bin/sh

rm -rf /tmp/crypto_oracles/;
mkdir -p /tmp/crypto_oracles/;
chmod 777 /tmp/crypto_oracles/;

export MAX_CORES=$(cat /proc/cpuinfo | grep "processor" | wc -l)

docker-compose -p crypto_oracles -f private/docker-compose.yml rm --force --stop
docker-compose -p crypto_oracles -f private/docker-compose.yml build
docker-compose -p crypto_oracles -f private/docker-compose.yml up -d
