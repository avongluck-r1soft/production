#!/bin/bash
#
# "An excellent dirty hack" -Alex
#

if [ $(whoami) != "root" ]; then
	echo "Please run me as root!"
	exit 1
fi

if [ $# -ne 2 ]; then
	echo "Usage: $0 <user@PROXY> <LOM_IP>"
	exit 1
fi

echo "Navigate to https://127.0.0.2 after connecting"
echo "running: ssh $1 -L127.0.0.2:443:$2:443 -L127.0.0.2:5900:$2:5900 -L127.0.0.2:5901:$2:5901 -L127.0.0.2:5120:$2:5920 -L127.0.0.2:5123:$2:5123 -C"
ssh $1 -L127.0.0.2.:443:$2:443 -L127.0.0.2:5900:$2:5900 -L127.0.0.2:5901:$2:5901 -L127.0.0.2:5120:$2:5920 -L127.0.0.2:5123:$2:5123 -C
