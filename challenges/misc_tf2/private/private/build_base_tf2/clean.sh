#!/bin/bash

cd $SERVER/tf2/tf/maps

MAPS_KEEP=("ctf_hellfire.bsp")
MAPS_ALL=( $(find -type f -name "*.bsp" -printf "%f\n") )

# MAPS_DELETE=($(diff MAPS_ALL[@] MAPS_KEEP[@]))
MAPS_DELETE=$(echo ${MAPS_ALL[@]} ${MAPS_KEEP[@]} | tr ' ' '\n' | sort | uniq -u)

rm ${MAPS_DELETE[@]}
