#!/bin/sh

# This script is designed to be run from cron.
#
# It is good practice to defrag xfs filesystems on a
# regular basis. The default duration of the xfs_fsr program
# is 2 hours, which seems reasonable for our purposes. The next
# time it runs, it will pick up where it left off.
#
# xfs_fsr can be called directly from cron, but it does not
# check to see if it is already running. This script will only
# start xfs_fsr if the previous iteration is not still running.

# Check to see if a previous iteration is already running...
if [ ! "$(ps h -fC xfs_fsr)" ]; then

        # Start xfs defrag program
        xfs_fsr >/dev/null & 2>&1

fi

exit 0
