#!/bin/bash

# csbm_postinstall.sh - run this after a CSBM is built from iso.
#                       This should take care of fixing up properties files.
#                       This is not a replacement for flightCheck - run flightCheck
#                       AFTER running this script. Trust but verify.

if [ $(whoami) != "root" ]; then
	echo "$0 must run as the root user account. Exiting."
	exit 42
fi

SBMDIR='/usr/sbin/r1soft'

fixup_server_properties() {

	PROPERTIES=$SBMDIR/conf/server.properties
	cp $PROPERTIES $PROPERTIES.orig

	sed -i 's/max-running-tasks=.*/max-running-tasks=200/g' $PROPERTIES
	sed -i 's/max-running-restore-tasks=.*/max-running-restore-tasks=200/g' $PROPERTIES
	sed -i 's/max-running-policy-tasks=.*/max-running-policy-tasks=200/g' $PROPERTIES
	sed -i 's/max-running-verification-tasks=.*/max-running-policy-tasks=200/g' $PROPERTIES
	sed -i 's/max-running-replication-tasks=.*/max-running-replication-tasks=200/g' $PROPERTIES
	sed -i 's/task-history-limit=.*/task-history-limit=3/g' $PROPERTIES
}


fixup_api_properties() {
	
	PROPERTIES=$SBMDIR/conf/api.properties
	cp $PROPERTIES $PROPERTIES.orig

	sed -i 's/ssl-enabled=.*/ssl-enabled=true/g' $PROPERTIES
	sed -i 's/ssl-port=.*/ssl-port=9443/g' $PROPERTIES
	sed -i 's/ssl-max-connections=.*/ssl-max-connections=1000/g' $PROPERTIES
	sed -i 's/http-enabled=.*/http-enabled=false/g' $PROPERTIES

}

fixup_web_properties() {

	PROPERTIES=$SBMDIR/conf/web.properties
	cp $PROPERTIES $PROPERTIES.orig

	sed -i 's/http-enabled=.*/http-enabled=false/g' $PROPERTIES
	sed -i 's/http-port=.*/http-port=80/g' $PROPERTIES
	sed -i 's/http-max-connections=.*/http-max-connections=100/g' $PROPERTIES
	sed -i 's/ssl-enabled=.*/ssl-enabled=true/g' $PROPERTIES
	sed -i 's/ssl-port=.*/ssl-port=8443/g' $PROPERTIES
	sed -i 's/ssl-max-connections=.*/ssl-max-connections=100/g' $PROPERTIES
	sed -i 's/ssl-keystore=.*/ssl-keystore=\/usr\/sbin\/r1soft\/conf\/keystore/g' $PROPERTIES

}

fixup_remote_replication_properties() {

	PROPERTIES=$SBMDIR/conf/remote-replication.properties
	cp $PROPERTIES $PROPERTIES.orig

	sed -i 's/remote-replication-listener-enabled=.*/remote-replication-listener-enabled=true/g' $PROPERTIES
}

fixup_dirty_cache_sysctld() {
	# sysctld dirty cache prevention
	if [ ! -f "/etc/sysctl.d/60-continuity247.conf" ]; then
		cat <<- EOF > /etc/sysctl.d/60-continuity247.conf
		########################################################
		# 2016 R1Soft DevOps
		# This prevents queuing up large amounts of dirty cache
		########################################################
		#  4GiB maximum dirty cache
		vm.dirty_bytes = 4294967296
		#  at 300MiB we begin flushing to disk in the background
		vm.dirty_background_bytes = 314572800
		########################################################
		EOF
	fi
}

fixup_repos() {
	echo "# DO NOT USE, see sources.list.d" > /etc/apt/sources.list
	echo "deb [arch=amd64] http://c247repo.itsupport247.net/c247 0.1.0 cloud" > /etc/apt/sources.list.d/c247cloud-release.list
	echo "deb [arch=amd64] http://c247repo.itsupport247.net/trusty-kernel trusty main" >> /etc/apt/sources.list.d/c247cloud-release.list
	echo "deb http://hwraid.le-vert.net/ubuntu precise main" > /etc/apt/sources.list.d/hwraid.list

	apt update

        apt install -V linux-headers-3.16.0-57-generic 
	apt install -V linux-headers-3.16.0-57 
	apt install -V linux-image-3.16.0-57-generic 
	apt install -V linux-image-extra-3.16.0-57-generic 
	update-initramfs -c -k all

	apt install -V serverbackup-enterprise
	apt install -V serverbackup-manager
	apt install -V serverbackup-setup
	apt install -V r1ctl-cloud
	apt install -V ufw-cloud
	apt install -V r1soft-docstore
	apt install -V r1ctl-cloud
	apt install -V c247cis
	apt install -V c247tools
	apt install -V c247skiff
	apt install -V c247mon # does r1ServerMon have a dpkg installer? 
}

#fixup_network_interfaces() {
#}
	
fixup_server_properties
fixup_api_properties
fixup_web_properties
fixup_remote_replication_properties
fixup_dirty_cache_sysctld
fixup_repos
