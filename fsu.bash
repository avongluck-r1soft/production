#!/bin/bash

# list servers with filesystems over 80% used

n=`ls|grep out|tail -1|sed 's/[a-zA-Z_.]//g'`
n=$((n+1))
echo "writing to fs_usage.out$n..."
./get_fs_pct.rb > fs_usage.out$n
sed 's/%//g' fs_usage.out$n|awk '/storage/ {if ($2>80.0) print}'|\
sort -rk 2 > filesystems_over_80pct.out
cat filesystems_over_80pct.out 
