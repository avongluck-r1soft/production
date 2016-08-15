#!/bin/bash

killscreens() {
        screen -ls | grep Detached | cut -d. -f1 | awk '{print $1}' | xargs kill
        echo "screen sessions nuked."
}

if [ $(screen -ls | grep "No Sockets found" >/dev/null 2>&1; echo $?) -eq 0 ]; then
	echo "No screen sessions running."
	exit 1
fi

screen -ls

read -p "Kill the above screen sessions? (y/N)" NUKEM

case "$NUKEM" in
        y|Y ) killscreens ;;
        n|N ) echo "exiting." ;;
          * ) echo "invalid input.";;
esac
