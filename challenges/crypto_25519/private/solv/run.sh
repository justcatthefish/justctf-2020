#!/bin/sh

docker build -t solve_25519 -f Dockerfile .
docker run -it solve_25519
