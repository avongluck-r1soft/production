#!/usr/bin/python

from datetime import datetime
from subprocess import Popen,PIPE,STDOUT

import contextlib
import commands
import time
import socket
import multiprocessing
import psutil
import logging
import logging.handlers
import os 
import subprocess
import sys


""" globals BEGIN """
hostname = socket.gethostname()

def get_ip_address(hostname):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect((hostname, 0))
    return s.getsockname()[0]

ip_addr  = get_ip_address(hostname)

HIGH_CPU_COUNT = 0
""" globals END """

def main():

    running = True
    system_type = get_system_type()

    while running:
        now = str(datetime.now())
        print("\n############### " + now + " ###############\n")

        print("hostname              = " + hostname)
        print("ip_address            = " + ip_addr)
        print("check_cpu             = " + str(check_cpu()))
        print("check_swapspace       = " + str(check_swapspace()))
        print("check_diskspace       = " + str(check_diskspace()))
        print("check_num_processes   = " + str(check_num_processes()))
        print("check_max_open_files  = " + str(check_max_open_files()))
        print("check_num_sockets     = " + str(check_num_sockets()))

        if system_type == "r1rm":
            print("check_service_running = " + str(check_service_running("r1rm")))
            print("check_service_running = " + str(check_service_running("apparmor")))

        if system_type == "r1cm":
            print("check_service_running = " + str(check_service_running("r1cm")))
            print("check_service_running = " + str(check_service_running("apparmor")))

        if system_type == "csbm":
            print("check_service_running = " + str(check_service_running("r1ctl")))
            print("check_service_running = " + str(check_service_running("cdp-server")))
            print("check_service_running = " + str(check_service_running("virtualbox")))
            print("check_service_running = " + str(check_service_running("apparmor")))
            

        #print("check_service_running = " + str(check_service_running("logentries")))
        print("check_service_running = " + str(check_service_running("networking")))
        print("check_service_running = " + str(check_service_running("ssh")))
        print("check_service_running = " + str(check_service_running("fail2ban")))
        print("check_service_running = " + str(check_service_running("rsyslog")))
        print("check_service_running = " + str(check_service_running("ufw")))

        time.sleep(60)


def get_system_type():
    if os.path.exists("/opt/r1soft/r1rm/bin/r1rm"):
        return "r1rm"
    if os.path.exists("/opt/r1soft/r1cm/bin/r1cm"):
        return "r1cm"
    if os.path.exists("/opt/r1soft/ftp/home"):
        return "ftp"
    if os.path.exists("/usr/sbin/r1soft/bin/cdpserver"):
        return "csbm"
    """ make sure this works!!! it's a glob() in the original perl """
    if os.path.exists("/opt/apache-cassandra*"):
        return "cassandra"
    if os.path.exists("/var/lib/tftpboot/pxelinux.0"):
        return "pxe"
    return "unknown"


def check_cpu():
    global HIGH_CPU_COUNT 
    cpu_usage = psutil.cpu_percent()
    THRESHHOLD = 75

    if cpu_usage > THRESHHOLD:
        HIGH_CPU_COUNT += 1

    if HIGH_CPU_COUNT >= 10:
        log_event("DEVOPS -- WARNING " + hostname + " " + ip_addr + " ")
        log_event("High CPU usage on : " + hostname + " ip: " + ip_addr)

    return cpu_usage


def log_event(msg):
    print("#### DEVOPS WARNING ####")
    print(msg)
    my_logger = logging.getLogger('EventLogger')
    my_logger.setLevel(logging.WARN)
    handler = logging.handlers.SysLogHandler(address='/dev/log')
    my_logger.addHandler(handler)
    my_logger.warn(msg)
  
    
def check_swapspace():
    MAX_USED_SWAP = 25
    swap_inuse = psutil.swap_memory()
    if swap_inuse.percent > MAX_USED_SWAP:
        log_event("DEVOPS -- WARNING " + hostname + " " + ip_addr + " ")
        log_event("High swap usage on : " + hostname + " ip: " + ip_addr)

    return swap_inuse.percent


def check_diskspace():
    DF_OUTPUT = {}

    MAX_DISKSPACE_PCT = 70

    with open("/proc/mounts", "r") as f:
        for line in f:
            fs_spec, fs_file, fs_vfstype, fs_mntops, fs_freq, fs_passno = line.split()
            if fs_spec.startswith('/'):
                r = os.statvfs(fs_file)
                block_usage_pct = 100.0 - (float(r.f_bavail) / float(r.f_blocks) * 100)

                DF_OUTPUT[fs_file] = block_usage_pct
      
                if block_usage_pct > MAX_DISKSPACE_PCT:
                    print("DEVOPS -- " + hostname + " ALERT! " + str(fs_file) + " -> " + str(block_usage_pct))
                    log_event("DEVOPS -- " + hostname + " ALERT " + str(fs_file) + " -> " + str(block_usage_pct))

    return DF_OUTPUT


def restart_service(name):
    restartcmd = ['service', name, 'restart']
    subprocess.call(restartcmd, shell=False)
    log_event(name + " service restarted on " + hostname)


def check_service_running(name):
    p = Popen(["service", name, "status"], stdout=PIPE)
    output = p.communicate()[0]
    
    if p.returncode != 0:
        log_event("DEVOPS -- Service " + name + " is DOWN on " + hostname + ".")
        restart_service(name)
        return name + " is DOWN on " + hostname
    else: 
        print("Service: " + name + " on " + hostname + " is UP.")
        
    return name + " is UP on " + hostname


def check_num_processes():
    MAXPROCS = 2500
    num_procs = len(psutil.pids())
    if int(num_procs) > MAXPROCS:
        log_event("DEVOPS -- high number of processes on " + hostname + " : " + num_procs)

    return num_procs


def check_max_open_files():
    with open ("/proc/sys/fs/file-nr") as f:
        for line in f:
            allocated, free, maximum, = line.split()

    if int(allocated) > 20000:
        log_event("DEVOPS -- high number of open files on " + hostname + " : " + str(allocated))

    return allocated, free, maximum


def check_num_sockets():
    MAX_SOCKETS = 20000
    num_sockets = len(psutil.net_connections())

    if int(num_sockets) > MAX_SOCKETS:
        log_event("DEVOPS -- high number of open network connections on " + hostname + " : " + str(num_sockets))
    
    return num_sockets

if __name__ == "__main__":
    main()
