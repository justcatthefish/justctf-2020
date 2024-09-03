#!/bin/bash

set -ex
name="$1"

rm -rf "/tmp/web_njs/$name/"
docker kill "sandbox_web_njs_$name"