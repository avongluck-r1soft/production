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
		cat <<- EOF > /etc/sysctl/60-continuity247.conf
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


fixup_server_properties
fixup_api_properties
fixup_web_properties
fixup_remote_replication_properties
fixup_dirty_cache_sysctld
