#!/bin/bash 

set -ex

docker-compose -p bot_worker -f docker-compose.yml rm --force --stop
docker-compose -p bot_worker -f docker-compose.yml build
docker-compose -p bot_worker -f docker-compose.yml up -d
