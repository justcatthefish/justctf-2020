#!/bin/bash

set -ex
name="$1"
stop_timeout="$2"
port_http="$3"
port_tf2="$4"
password_tf2="$5"

cd /sandboxtask/;

cp -f docker-compose.yml "docker-compose_$name.yml"
sed -i "s@SRCDS_PW=changeme@SRCDS_PW=$password_tf2@g" "docker-compose_$name.yml"
sed -i "s@27015:27015/udp@$port_tf2:27015/udp@g" "docker-compose_$name.yml"
sed -i "s@27015:27015/tcp@$port_tf2:27015/tcp@g" "docker-compose_$name.yml"
sed -i "s@80:80@$port_http:80@g" "docker-compose_$name.yml"
sed -i "s@- ./flag.txt@- /tmp/misc_tf2/flag.txt@g" "docker-compose_$name.yml"

docker-compose -p "sandbox_misc_tf2_$name" -f "docker-compose_$name.yml" up -d
