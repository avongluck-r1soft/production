## c247mon.py

c247mon.py runs every 5 minutes on production servers. It runs basic
monitoring commands pulled from the original perl code and restarts services
if they are down. If a service is down, a crack DevOps team member suits 
up in all black protective gear, hops on their trusty time-travelling 
unicorn with it's shiny rainbow mane, and calls on unnamed powers of the
universe to get stuff fixed, usually after eating too much BBQ.

Sample output:

############### 2016-08-22 13:56:59.523272 ###############

hostname              = scott-PowerEdge-T110-II
system_type           = unknown
ip_address            = 10.80.65.125
check_cpu             = 4.14
check_swapspace       = 0.0
check_diskspace       = {'/boot': 56.93796415302534, '/boot/efi': 0.7032993914931467, '/': 6.172043341681359}
check_num_processes   = 377
check_max_open_files  = 9120
check_num_sockets     = 782
check_service_running = networking is UP on scott-PowerEdge-T110-II
check_service_running = ssh is UP on scott-PowerEdge-T110-II
check_service_running = fail2ban is UP on scott-PowerEdge-T110-II
check_service_running = rsyslog is UP on scott-PowerEdge-T110-II
DEVOPS -- WARNING scott-PowerEdge-T110-II 10.80.65.125  service ufw is DOWN
DEVOPS -- WARNING scott-PowerEdge-T110-II 10.80.65.125 service ufw restarted.
check_service_running = ufw is DOWN on scott-PowerEdge-T110-II
check_ufw_rules       = ufw status OK on scott-PowerEdge-T110-II



