#!/bin/bash
HOST=$1
PORT=$2
echo 'Subject: vesim %x abc\n\n' | nc $HOST $PORT -vvv

