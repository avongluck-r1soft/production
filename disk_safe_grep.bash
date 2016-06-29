#!/bin/bash

FILESYSTEMS=('/storage01/replication' '/storage02/replication' '/storage03/replication'
'/storage04/replication' '/storage05/replication' '/storage06/replication' '/storage07/replication'
'/storage08/replication' '/storage09/replication')

check_metadata_uuids() {
    for disk_safe in `du -sh * | awk '/[0-3].[0-9]T/ {print $2}'`; do
        grep $disk_safe $disk_safe/metadata2/DiskSafeMetaData >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo $disk_safe
            echo "UUID matches DiskSafeMetaData file"
            echo "$disk_safe size is: " `du -sh $disk_safe | awk '{print $1}'`
        else
            echo $disk_safe
            echo "UUID DOES NOT MATCH DiskSafeMetaData file"
        fi
    done
}

for fs in "${FILESYSTEMS[@]}"; do
    cd $fs
    echo "*****************************"
    echo "*** $fs ***" 
    echo "*****************************"
    check_metadata_uuids | awk '/[0-3].[0-9]T/ {print}'
done

exit 0
