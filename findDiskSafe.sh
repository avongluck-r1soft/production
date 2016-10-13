#!/bin/bash

PASS=$1
DSID=$2

if [[ -z $2 ]]; then
	echo "usage: $0 <passwd> <diskSafeID>"
	exit -1
fi

for host in $(awk '/csbm/ {print $2}' /etc/hosts); do
	data=$(sshpass -p$PASS ssh -o StrictHostKeyChecking=no continuum@$host "echo $PASS | sudo -S find /storage* -name $DSID -exec du -sh {} \;" 2>/dev/null) 
	if [[ ! -z $data ]]; then
		echo "$host $data"
	fi
done
