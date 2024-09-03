#!/bin/bash

docker build -t build_plugin -f Dockerfile.buildplugin .
id=$(docker container create build_plugin)

docker cp $id:/code/addons/sourcemod/scripting/efekty_new.smx .
docker container rm $id
