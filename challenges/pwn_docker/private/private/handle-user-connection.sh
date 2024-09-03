#!/bin/bash

set -ex

# Hashcash
timeout 2m ./clihashcash_amd64

DURATION="10m"

# Generate random socket id...
RAND_ID="$(gpw 1 32)"

# NOTE: This path must match the one from docker-compose
SOCKET=/tmp/pwn-docker/$RAND_ID.sock

# Fail if socket already exists (it should never happen?)
if test -f $SOCKET; then
    echo "Something is wrong with task setup: could not randomize socket; please contact admins."
    exit 1
fi

echo "[*] Spawning a task manager for you..."
# Creates /sockets/$RAND_ID.sock
timeout --signal=KILL ${DURATION} \
    socat UNIX-LISTEN:${SOCKET},fork,mode=777 exec:"python3 chall.py $SOCKET" & #2>/dev/null 1>&2 &

echo "[*] Spawning a Docker container with a shell for ya, with a timeout of ${DURATION} :)"
echo "[*] Your task is to communicate with /oracle.sock and find out the answers for its questions!"
echo "[*] You can use this command for that:"
echo "[*]   socat - UNIX-CONNECT:/oracle.sock"
echo "[*] PS: If the socket dies for some reason (you cannot connect to it) just exit and get into another instance"
echo ""

timeout --signal=SIGKILL ${DURATION} docker run --rm -it \
        --user 1000:1000 \
        --cap-drop=ALL \
        --security-opt=no-new-privileges:true \
        --cpus=1 \
        --network=none \
        --memory=300M \
        --memory-swap=300M \
        --kernel-memory 200M \
        --shm-size=64M \
        -v $SOCKET:/oracle.sock \
        pwn-docker-environment \
        timeout ${DURATION} bash

