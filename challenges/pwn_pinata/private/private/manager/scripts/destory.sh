#!/bin/bash

set -ex
name="$1"

rm -rf "/tmp/pwn_pinata/$name/"
docker kill "sandbox_pwn_pinata_$name"