#!/bin/bash

docker build -t tf2_server -f Dockerfile .
docker tag tf2_server patryk4815/ctf-tf2server-base:latest
docker push patryk4815/ctf-tf2server-base:latest
