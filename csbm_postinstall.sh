#!/bin/bash

# csbm_postinstall.sh - run this after a CSBM is built from iso.
#                       This should take care of fixing up properties files.
#                       This is not a replacement for flightCheck - run flightCheck
#                       AFTER running this script. Trust but verify.

SBMDIR="/usr/sbin/r1soft"
BBSDIR="/opt/r1soft"
CTLDIR="${BBSDIR}/r1ctl"

fixup_server_properties {

	PROPERTIES=$SBMDIR/conf/server.properties
	cp $PROPERTIES $PROPERTIES.orig

	sed -i '/max-running-tasks=*/max-running-tasks=200/g' $PROPERTIES
	sed -i '/max-running-restore-tasks=*/max-running-restore-tasks=200/g' $PROPERTIES
	sed -i '/max-running-policy-tasks=*/max-running-policy-tasks=200/g' $PROPERTIES
	sed -i '/max-running-verification-tasks=*/max-running-policy-tasks=200/g' $PROPERTIES
	sed -i '/max-running-replication-tasks=*/max-running-replication-tasks=200/g' $PROPERTIES
	sed -i '/task-history-limit=*/task-history-limit=3/g' $PROPERTIES
}


fixup_api_properties {
	
	PROPERTIES=$SBMDIR/conf/api.properties
	cp $PROPERTIES $PROPERTIES.orig

	sed -i '/ssl-enabled=*/ssl-enabled=true/g' $PROPERTIES
	sed -i '/ssl-port=*/ssl-port=9443/g' $PROPERTIES
	sed -i '/ssl-max-connection=*/ssl-max-connections=1000/g' $PROPERTIES
	sed -i '/http-enabled=*/http-enabled=false/g' $PROPERTIES

}

fixup_web_properties {

	PROPERTIES=$SBMDIR/conf/web.properties
	cp $PROPERTIES $PROPERTIES.orig

	SSL_KEYSTORE="/usr/sbin/r1soft/conf/keystore"

	sed -i '/http-enabled=*/http-enabled=false/g' $PROPERTIES
	sed -i '/http-port=*/http-port=80/g' $PROPERTIES
	sed -i '/http-max-connections=*/http-max-connections=100/g' $PROPERTIES
	sed -i '/ssl-enabled=*/ssl-enabled=true/g' $PROPERTIES
	sed -i '/ssl-port=*/ssl-port=8443/g' $PROPERTIES
	sed -i '/ssl-max-connections=*/ssl-max-connections=100/g' $PROPERTIES
	sed -i '/ssl-keystore=*/ssl-keystore=$SSL_KEYSTORE/g' $PROPERTIES

}

fixup_remote_replication_properties {

	PROPERTIES=$SBMDIR/conf/remote-replication.properties
	cp $PROPERTIES $PROPERTIES.orig

	sed -i '/remote-replication-listener-enabled=*/remote-replication-listener-enabled=true/g' $PROPERTIES
}

fixup_server_properties
fixup_api_properties
fixup_web_properties
fixup_remote_replication_properties

