#!/bin/bash

set -ex
name="$1"
stop_timeout="$2"

mkdir -p "/tmp/web_njs/$name/"
chmod 777 "/tmp/web_njs/$name/"

docker run \
  -d \
  -e PORT="/tmp/web_njs/$name/sock.unix" \
  -v /tmp/web_njs/$name/:/tmp/task/ \
  --stop-timeout $stop_timeout \
  --rm \
  --name "sandbox_web_njs_$name" \
  -t sandboxtask

echo "1" > "/tmp/web_njs/$name/server.pid"