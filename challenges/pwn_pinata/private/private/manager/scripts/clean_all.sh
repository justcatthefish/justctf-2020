#!/bin/bash

set -ex

# clear shared volumen
rm -Rf -- /tmp/pwn_pinata/*

# kill running containers
DOCKERS_CONTAINERS=$(docker ps -a --format "{{.Names}}" | grep "sandbox_pwn_pinata_") || true
if [ -z "$DOCKERS_CONTAINERS" ]; then
  echo "no containers to kill"
else
  echo "killing"
  docker kill $DOCKERS_CONTAINERS
fi;