#!/bin/bash

set -ex
name="$1"

cd /sandboxtask/;
docker-compose -p "sandbox_misc_tf2_$name" -f "docker-compose_$name.yml" kill
docker-compose -p "sandbox_misc_tf2_$name" -f "docker-compose_$name.yml" rm --force
rm -f "docker-compose_$name.yml"
docker network prune -f