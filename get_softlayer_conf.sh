#!/bin/bash

HOSTNAME=$1

usage() {
	echo "usage: $0 <hostname>"
	exit 
}

if [ ! $HOSTNAME ]; then
	echo "no hostname provided. exiting."
	usage
	exit 
fi

slcli hardware detail $HOSTNAME > tmp

PUBLIC_IP=$(grep public_ip tmp | awk '{print $2}')
PRIVATE_IP=$(grep private_ip tmp | awk '{print $2}')
TSUBNET=$(echo $PUBLIC_IP| awk -F"." '{print $1"."$2"."$3}')
SUBNET=$(slcli subnet list | grep $TSUBNET | awk '{print $2}') 

slcli subnet detail $SUBNET > tmp

GATEWAY=$(grep gateway tmp | awk '{print $2}')
BROADCAST=$(grep broadcast tmp | awk '{print $2}')

NETMASK=$(ipcalc $SUBNET |grep Netmask | awk '{print $2}')

echo "public ip: $PUBLIC_IP"
echo "private ip: $PRIVATE_IP"
echo "subnet: $SUBNET"
echo "netmask: $NETMASK"
echo "gateway: $GATEWAY"
echo "broadcast: $BROADCAST"


