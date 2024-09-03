#!/bin/bash

set -ex
name="$1"

rm -rf "/tmp/crypto_oracles/$name/"
docker kill "sandbox_crypto_oracles_$name"
