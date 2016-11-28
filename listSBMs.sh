#!/bin/sh

usage(){
    echo "Usage: $(basename $0) [-e|-s|-i <UUID>|-n <NAME>|-l|-w|-h]"
    echo
    echo "  Parses json output from CloudSkiff's cloud SBM page."
    echo "  Probably pretty sensitive to changes in skiff output..."
    echo
    echo "  -e        output for /etc/hosts"
    echo "  -s        otuput for ~/.ssh/config"
    echo "  -i <UUID> search for csbm by uuid"
    echo "  -n <NAME> search for csbm by name"
    echo "  -l        long output... questionable usefulness..."
    echo "  -w        wide output... questionable usefulness..."
    echo "  -h        output this helpful(?) text ;)"
    echo
}

while getopts "esi:n:lwh" opt; do
    case $opt in
        e) otype="etc_hosts"
           ;;
        s) otype="ssh_config"
           ;;
        i) otype="id"         
           search="$OPTARG"
           ;;
        n) otype="name"
           search="$OPTARG"
           ;;
        l) otype="long"
           ;;
        w) otype="wide"
           ;;
        h) usage
           exit 0
           ;;
        *) usage
           exit 1
           ;;
    esac
done

if [ -z $otype ]; then
    usage
    exit 1
fi

url="https://skiff.itsupport247.net/sbms_byrole/cloud.json"
raw=$(wget --no-check-certificate -qO- "$url")
lines=$(echo $raw|sed 's/},/}\n/g')

for line in $(echo "$lines"); do

         agent_count=$(echo "$line" | sed 's/.*"agent_count":\([^,]*\),.*/\1/')
                  id=$(echo "$line" | sed 's/.*"id":"\([^"]*\)".*/\1/')
               #role=$(echo "$line" | sed 's/.*"role":"\([^"]*\)".*/\1/')
       storage_total=$(echo "$line" | sed 's/.*"storage_total":\([^,]*\),.*/\1/')
    storage_consumed=$(echo "$line" | sed 's/.*"storage_consumed":\([^,]*\).*/\1/')
         storage_pct=$(echo "$line" | sed 's/.*"storage_pct":\([^,]*\),.*/\1/')
         storage_max=$(echo "$line" | sed 's/.*"storage_max":\([^,]*\),.*/\1/')
            workload=$(echo "$line" | sed 's/.*"workload":\([^,]*\),.*/\1/')
            hostname=$(echo "$line" | sed 's/.*"hostname":"\([^"]*\)".*/\1/')
           inet4priv=$(echo "$line" | sed 's/.*"inet4priv":"\([^"]*\)".*/\1/')
           #lic_type=$(echo "$line" | sed 's/.*"lic_type":"\([^"]*\)".*/\1/')
              region=$(echo "$line" | sed 's/.*"region":"\([^"]*\)".*/\1/')
           shortname=$(echo "$hostname" | awk -F\. '{print $1}')

    case $otype in

        etc_hosts)
            /bin/echo -e "$inet4priv\t$shortname $id"
            ;;

        ssh_config)
            echo "host $shortname $id"
            echo "    hostname $inet4priv"
            echo "    user continuum"
            echo
            ;;

        id|name)
            if [ "$(echo $id $hostname |grep $search)" ]; then
                echo "id:               $id"
                echo "shortname:        $shortname"
                echo "hostname:         $hostname"
                echo "inet4priv:        $inet4priv"
                echo "agent_count:      $agent_count"
                echo "storage_total:    $storage_total"
                echo "storage_consumed: $storage_consumed"
                echo "storage_pct:      $storage_pct"
                echo "storage_max:      $storage_max"
                echo "workload:         $workload"
                echo "region:           $region"
                echo
            fi
            ;;

        long)
            echo "id:               $id"
            echo "shortname:        $shortname"
            echo "hostname:         $hostname"
            echo "inet4priv:        $inet4priv"
            echo "agent_count:      $agent_count"
            echo "storage_total:    $storage_total"
            echo "storage_consumed: $storage_consumed"
            echo "storage_pct:      $storage_pct"
            echo "storage_max:      $storage_max"
            echo "workload:         $workload"
            echo "region:           $region"
            echo
            ;;

        wide)
            echo "$id, agent_count: $agent_count, role: $role, storage_total: $storage_total, storage_consumed: $storage_consumed, storage_pct: $storage_pct, storage_max: $storage_max, workload: $workload, hostname: $hostname, inet4priv: $inet4priv, lic_type: $lic_type, region: $region, shortname: $shortname"
            ;;

    esac

done

