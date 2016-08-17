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

""" globals begin """
hostname = socket.gethostname()

def get_ip_address(hostname):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect((hostname, 0))
    return s.getsockname()[0]

ip_addr  = get_ip_address(hostname)

""" globals end  """

def main():
    MAX_USED_SWAP      = 25
    HIGH_CPU_COUNT     = 0
    MAX_HIGH_CPU_COUNT = 10  
    MAX_HIGH_CPU       = 75
    MAX_DISKSPACE_PCT  = 70
    MAX_OPEN_FILES     = 20000
    MAX_SOCKETS        = 20000
    MAX_PROCS          = 2500
    MAX_CM_QUEUE       = 300

    running = True

    while running:
        now = str(datetime.now())
        print("\n############### " + now + " ###############\n")
        print("hostname              = " + hostname)
        print("ip_address            = " + ip_addr)
        print("check_cpu             = " + str(check_cpu(MAX_HIGH_CPU, HIGH_CPU_COUNT)))
        print("check_swapspace       = " + str(check_swapspace(MAX_USED_SWAP)))
        print("check_diskspace       = " + str(check_diskspace(MAX_DISKSPACE_PCT)))
        print("check_service_running = " + str(check_service_running("r1rm")))
        print("check_service_running = " + str(check_service_running("apache2")))

        time.sleep(60)

def check_cpu(MAX_HIGH_CPU, HIGH_CPU_COUNT):
    usage = psutil.cpu_percent()

    if usage > MAX_HIGH_CPU:
        HIGH_CPU_COUNT = HIGH_CPU_COUNT + 1

        if HIGH_CPU_COUNT >= MAX_HIGH_CPU_COUNT:
            log_event("DEVOPS -- WARNING " + hostname + " (" + ip_addr + ") ")
            log_event("High CPU usage on : " + hostname + " ip: " + ip_addr)

    return usage


def log_event(msg):
    print("#### DEVOPS WARNING ####")
    print("sending the following message to /var/log/syslog:")
    print(msg)
    print("#### DEVOPS WARNING ####")
    my_logger = logging.getLogger('EventLogger')
    my_logger.setLevel(logging.WARN)

    handler = logging.handlers.SysLogHandler(address='/dev/log')
    my_logger.addHandler(handler)
    my_logger.warn(msg)
  
    
def check_swapspace(MAX_USED_SWAP):
    swap_inuse = psutil.swap_memory()

    if swap_inuse.percent > MAX_USED_SWAP:
        log_event("DEVOPS -- WARNING " + hostname + " (" + ip_addr + ") ")
        log_event("High swap usage on : " + hostname + " ip: " + ip_addr)

    return swap_inuse.percent

def check_diskspace(MAX_DISKSPACE_PCT):
    DF_OUTPUT = {}

    with open("/proc/mounts", "r") as f:
        for line in f:
            fs_spec, fs_file, fs_vfstype, fs_mntops, fs_freq, fs_passno = line.split()
            if fs_spec.startswith('/'):
                r = os.statvfs(fs_file)
                block_usage_pct = 100.0 - (float(r.f_bavail) / float(r.f_blocks) * 100)

                DF_OUTPUT[fs_file] = block_usage_pct
      
                if block_usage_pct > MAX_DISKSPACE_PCT:
                    log_event("DEVOPS -- disk_space_/" + fs_spec + "DiskUsage high = " + block_usage_pct + " mount_point = " + fs_file)

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



if __name__ == "__main__":
    main()

