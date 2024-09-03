#!/bin/bash

docker-compose -p web_computeration_fixed -f docker-compose.yml rm --force --stop
docker-compose -p web_computeration_fixed -f docker-compose.yml build
docker-compose -p web_computeration_fixed -f docker-compose.yml up -d