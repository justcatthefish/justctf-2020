#!/bin/bash

set -ex
name="$1"
stop_timeout="$2"

mkdir -p "/tmp/shared/$name/"
chmod 777 "/tmp/shared/$name/"

docker run \
  -d \
  -v /tmp/pwn_pinata/$name/:/tmp/task/ \
  -v /tmp/pwn_pinata/flag.txt:/flag.txt:ro \
  --security-opt=no-new-privileges:true \
  --cap-drop=all \
  --cap-add=cap_dac_override \
  --cap-add=chown \
  --cap-add=setgid \
  --cap-add=setuid \
  --memory=200M \
  --memory-swap=200M \
  --kernel-memory 50M \
  --shm-size=16M \
  --cpus=2 \
  --cpu-shares=2000 \
  --stop-timeout $stop_timeout \
  --rm \
  --name "sandbox_pwn_pinata_$name" \
  sandboxtask_pwn_pinata

echo "1" > "/tmp/shared/$name/server.pid"