#!/bin/sh

# Port to which the task will be exposed
PORT=${1-1337}

cp -f ./flag.txt ./private/
cd private

docker build -t pwn-qmail -f Dockerfile .

# NOTE:
# The options below are generally INSECURE. We use them as we use nsjail anyway.
# Docker is used just for easier bootstraping of nsjail, i.e.:
# - to have a non-host chroot (and consistent environment) for jailed processes/tasks
# - to be able to run task with one command, assuming docker is installed on machine
#
# We need:
# - CHOWN, SETUID, SETGID, AUDIT_WRITE - to use `su -l jailed ...`
# - SYS_ADMIN and CHOWN to prepare (mount) cgrops for nsjail
# - no apparmor and no seccomp to prepare cgroups and to spawn jails
#

# YOLO
sysctl -w kernel.randomize_va_space=0

docker rm -f pwn-qmail
docker run -d \
    --restart=always \
    --name pwn-qmail \
    --cap-drop=all \
    --cap-add=CHOWN \
    --cap-add=SETUID \
    --cap-add=SETGID \
    --cap-add=AUDIT_WRITE \
    --cap-add=SYS_ADMIN \
    --security-opt apparmor=unconfined \
    --security-opt seccomp=unconfined \
    -p $PORT:1337 \
    pwn-qmail

