## c247mon.py

c247mon.py - runs each minute on monitored system, alerts if expected
production services are down or if UFW rules are wonky.

Output (from command line as root user on VirtualBox): 


############### 2016-08-21 00:20:27.469911 ###############

hostname              = scott-VirtualBox
system_type           = ftp
ip_address            = 127.0.0.1
check_cpu             = 13.44
#### DEVOPS WARNING ####
DEVOPS -- WARNING scott-VirtualBox 127.0.0.1 
#### DEVOPS WARNING ####
High swap usage on : scott-VirtualBox ip: 127.0.0.1
check_swapspace       = 36.2319
check_diskspace       = {'/': 11.79861619580845}
check_num_processes   = 194
check_max_open_files  = 6624
check_num_sockets     = 529
check_service_running = proftpd is UP on scott-VirtualBox
check_service_running = networking is UP on scott-VirtualBox
check_service_running = ssh is UP on scott-VirtualBox
check_service_running = fail2ban is UP on scott-VirtualBox
check_service_running = rsyslog is UP on scott-VirtualBox
check_service_running = ufw is UP on scott-VirtualBox
check_ufw_rules       = ufw status OK on scott-VirtualBox

############### 2016-08-21 00:21:40.097018 ###############

hostname              = scott-VirtualBox
system_type           = ftp
ip_address            = 127.0.0.1
check_cpu             = 9.58
#### DEVOPS WARNING ####
DEVOPS -- WARNING scott-VirtualBox 127.0.0.1 
#### DEVOPS WARNING ####
High swap usage on : scott-VirtualBox ip: 127.0.0.1
check_swapspace       = 36.2315
check_diskspace       = {'/': 11.798604436765359}
check_num_processes   = 192
check_max_open_files  = 6624
check_num_sockets     = 531
check_service_running = proftpd is UP on scott-VirtualBox
check_service_running = networking is UP on scott-VirtualBox
check_service_running = ssh is UP on scott-VirtualBox
check_service_running = fail2ban is UP on scott-VirtualBox
check_service_running = rsyslog is UP on scott-VirtualBox
check_service_running = ufw is UP on scott-VirtualBox
check_ufw_rules       = ufw status OK on scott-VirtualBox

Output is to be consumed by Graylog. If a service is down, the "DEVOPS" string is logged
to /var/log/syslog, where Graylog picks it up and emails / pages an alert to the DevOps
oncall team and c247devops mailing list. 
