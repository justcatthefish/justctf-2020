#!/bin/bash

docker-compose -p re_reklest -f docker-compose.yml rm --force --stop
docker-compose -p re_reklest -f docker-compose.yml build
docker-compose -p re_reklest -f docker-compose.yml up -d
