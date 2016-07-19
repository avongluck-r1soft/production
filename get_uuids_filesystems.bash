#!/bin/bash

# get_filesystems_uuids.bash - quick and dirty csv builder to run after a drive failure.

for i in $(cat ~/agents); do
        getDiskSafe $i;
done | grep "Could not read disk safe meta data for Disk Safe" -A1 -B6 > failed_agents.txt 2>&1

awk '/information/ {print $6}' failed_agents.txt > uuids.txt
awk '/storage0/ {print}' failed_agents.txt  | sed "s/'//g" > filesystems.txt
paste -d',' uuids.txt filesystems.txt > uuids_filesystems.csv
