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
PUBLIC_TSUBNET=$(echo $PUBLIC_IP| awk -F"." '{print $1"."$2"."$3}')
PUBLIC_SUBNET=$(slcli subnet list | grep $PUBLIC_TSUBNET | awk '{print $2}') 
PRIVATE_IP=$(grep private_ip tmp | awk '{print $2}')

slcli subnet detail $PUBLIC_SUBNET > tmp

PUBLIC_GATEWAY=$(grep gateway tmp | awk '{print $2}')
PUBLIC_BROADCAST=$(grep broadcast tmp | awk '{print $2}')
PUBLIC_NETMASK=$(ipcalc $PUBLIC_SUBNET |grep Netmask | awk '{print $2}')

PRIVATE_TSUBNET=$(echo $PRIVATE_IP| awk -F"." '{print $1"."$2"."$3}')
PRIVATE_SUBNET=$(slcli subnet list | grep $PRIVATE_TSUBNET | awk '{print $2}') 

slcli subnet detail $PRIVATE_SUBNET > tmp

PRIVATE_GATEWAY=$(grep gateway tmp | awk '{print $2}')
PRIVATE_BROADCAST=$(grep broadcast tmp | awk '{print $2}')
PRIVATE_NETMASK=$(ipcalc $PRIVATE_SUBNET |grep Netmask | awk '{print $2}')


echo "public ip: $PUBLIC_IP"
echo "public subnet: $PUBLIC_SUBNET"
echo "public netmask: $PUBLIC_NETMASK"
echo "public gateway: $PUBLIC_GATEWAY"
echo "public broadcast: $PUBLIC_BROADCAST"

echo ""

echo "private ip: $PRIVATE_IP"
echo "private subnet: $PRIVATE_SUBNET"
echo "private netmask: $PRIVATE_NETMASK"
echo "private gateway: $PRIVATE_GATEWAY"
echo "private broadcast: $PRIVATE_BROADCAST"
