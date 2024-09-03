#!/bin/bash

set -ex
name="$1"
cpu_assign="$2"
stop_timeout="$3"

mkdir -p "/tmp/crypto_oracles/$name/"
chmod 777 "/tmp/crypto_oracles/$name/"

docker run \
  -d \
  -e PORT="/tmp/crypto_oracles/$name/sock.unix" \
  -v /tmp/crypto_oracles/$name/:/tmp/crypto_oracles/$name/ \
  --cpuset-cpus $cpu_assign \
  --stop-timeout $stop_timeout \
  --rm \
  --name "sandbox_crypto_oracles_$name" \
  -t sandboxtask

echo "1" > "/tmp/crypto_oracles/$name/server.pid"
