#!/bin/bash

set -ex

# kill running containers
DOCKERS_CONTAINERS=$(docker ps -a --format "{{.Names}}" | grep "sandbox_misc_tf2_") || true
if [ -z "$DOCKERS_CONTAINERS" ]; then
  echo "no containers to kill"
else
  echo "killing"
  docker kill $DOCKERS_CONTAINERS
  docker rm --force $DOCKERS_CONTAINERS
fi;

cd /sandboxtask/;
rm -f -- docker-compose_*.yml
