#!/bin/bash

PKT_SIZE=1500
HOSTNAME=10.160.189.170

count=$((`/bin/ping $HOSTNAME -c 1 -M do -s $PKT_SIZE 2>&1 | grep -c "Message too long"`))
while [ $count -eq 1 ]; do
	((PKT_SIZE--))
	echo "Testing $PKT_SIZE"
 	count=$((`/bin/ping $HOSTNAME -c 1 -M do -s $PKT_SIZE 2>&1 | grep -c "Message too long"`))
done
printf "Your Maximum MTU is [ $((PKT_SIZE + 28)) ] \n"
