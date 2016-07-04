#!/bin/bash

# list servers with filesystems over 80% used

FSGT80="filesystems_over_80.out"

# cleanup
if [ $(ls fs_usage.out*|wc -l) -ge 10 ]; then
	rm ./fs_usage.out*
fi

if [ $(ls|grep fs_usage >/dev/null 2>&1; echo $?) -eq 1 ]; then
	echo "no fs_usage file exists. creating fs_usage.out0"
	touch fs_usage.out0
fi

get_fs_over_80pct() {
	n=`ls|grep out|tail -1|sed 's/[a-zA-Z_.]//g'`
	n=$((n+1))
	echo "writing to fs_usage.out$n..."
	./get_fs_pct.rb > fs_usage.out$n
	sed 's/%//g' fs_usage.out$n|awk '/storage/ {if ($2>80.0) print}'|\
	sort -rk 2 > $FSGT80
}

if [ -f $FSGT80 ]; then
	cp $FSGT80 $FSGT80.prev
else 
	touch $FSGT80
fi

get_fs_over_80pct
cat $FSGT80
