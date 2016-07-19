#!/bin/bash

USER="continuum"
PASS="c0ng0*88"

HOSTS=(
sjcsbm06
sjcsbm07
sjcsbm08
sjcsbm09
sjcsbm10
sjcsbm11
sjcsbm12
sjcsbm13
sjcsbm14
sjcsbm15
wdcsbm04
wdcsbm08
wdcsbm09
wdcsbm10
wdcsbm11
wdcsbm12
wdcsbm13
wdcsbm14
wdcsbm15
wdcsbm16
wdcsbm17
loasbm02
loasbm03
loasbm04
loasbm05
lobsbm02
lobsbm04
lobsbm05
wdcsbm04
)

for host in ${HOSTS[*]}; do
	echo "*** on $host ***"
	sshpass -p $PASS ssh -f $USER@$host "echo $PASS | sudo -S find /storage* -name bbc131c1*" -exec ls -altr {} \;"
done
