#!/bin/sh

set -ex

cp -f ./flag.txt ./private/flag


(while true; do docker rm -f $(curl -s -q --unix-socket /var/run/docker.sock "http:/v1.24/containers/json" | python3 -c 'import sys, json, time; t=time.time(); x=json.loads(sys.stdin.read()); print(" ".join([a["Id"] for a in x if a["Image"] == "pwn-docker-environment" and (t-a["Created"]) > 600]))'); sleep 30; done) &

docker-compose -p pwn-docker -f private/docker-compose.yml rm --force --stop
docker build -t pwn-docker-environment -f ./private/env.Dockerfile ./private
docker-compose -p pwn-docker -f private/docker-compose.yml build
docker-compose -p pwn-docker -f private/docker-compose.yml up -d
